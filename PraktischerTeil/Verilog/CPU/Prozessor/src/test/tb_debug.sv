`timescale 1ns/1ns

module tb_debug();

    reg clk;
    reg rst;
    
    // CPU signals
    wire [31:0] pc;
    wire [31:0] instr;
    wire [31:0] bus_addr;
    wire [31:0] bus_rdata;
    wire [31:0] bus_wdata;
    wire [3:0]  dmem_we;
    wire        dmem_ce;
    wire        dmem_read;
    wire [2:0]  state;
    
    // Register file access
    wire [31:0] ra;  // x1 - return address
    wire [31:0] sp;  // x2 - stack pointer
    wire [31:0] gp;  // x3 - global pointer
    wire [4:0]  rd;
    wire [31:0] tmp_rd;

    // Instantiate the top module
    topmodule uut(
        .clk(clk),
        .rst(rst),
        .miso(1'b1)
    );

    // Access internal signals
    assign pc = uut.machine.pc;
    assign instr = uut.machine.instr;
    assign bus_addr = uut.machine.bus_addr;
    assign bus_rdata = uut.machine.bus_rdata;
    assign bus_wdata = uut.machine.bus_wdata;
    assign dmem_we = uut.machine.dmem_we;
    assign dmem_ce = uut.machine.dmem_ce;
    assign dmem_read = uut.machine.dmem_read;
    assign state = uut.machine.state;
    assign ra = uut.machine.regfile[1];
    assign sp = uut.machine.regfile[2];
    assign gp = uut.machine.regfile[3];
    assign rd = uut.machine.rd;
    assign tmp_rd = uut.machine.tmp_rd;

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 50MHz
    end

    // VCD file name from compile-time define
    `ifdef VCD_FILE
        string vcd_filename = `VCD_FILE;
    `else
        string vcd_filename = "tb_debug.vcd";
    `endif

    // Test sequence
    initial begin
        $dumpfile(vcd_filename);
        $dumpvars(0, tb_debug);
        
        $display("========================================");
        $display("CPU Debug Testbench");
        $display("========================================");
        
        rst = 1;
        #100;
        rst = 0;
        
        $display("Starting execution...");
        
        // Monitor for magic address writes
        forever begin
            @(posedge clk);
            if (dmem_ce && |dmem_we && (bus_addr == 32'h0001_FFFC)) begin
                if (bus_wdata == 32'h1) begin
                    $display("");
                    $display("========================================");
                    $display("TEST PASSED at PC: 0x%h", pc);
                    $display("========================================");
                    $finish;
                end else if (bus_wdata == 32'hDEADBEEF) begin
                    $display("");
                    $display("========================================");
                    $display("TEST FAILED at PC: 0x%h", pc);
                    $display("Last values: ra=0x%h sp=0x%h", ra, sp);
                    $display("========================================");
                    $finish;
                end
            end
        end
    end

    // Timeout mechanism
    initial begin
        #1000000; // 1ms simulation time
        $display("");
        $display("========================================");
        $display("TIMEOUT: Test did not complete");
        $display("Last PC: 0x%h", pc);
        $display("Last state: %0d", state);
        $display("========================================");
        $finish;
    end

    // Detailed execution trace
    `ifdef ENABLE_TRACE
    always @(posedge clk) begin
        // Trace writeback stage
        if (state == 3'd5) begin // WRITEBACK
            if (uut.machine.set_rd_flag && rd != 0) begin
                $display("[%t] WB: PC=0x%08h x%0d=0x%08h | ra=0x%08h sp=0x%08h", 
                         $time, pc, rd, tmp_rd, ra, sp);
            end
        end
        
        // Trace memory reads
        if (dmem_ce && dmem_read && state == 3'd3) begin // MEMORY1
            $display("[%t] MEM_RD: addr=0x%08h state=%0d", $time, bus_addr, state);
        end
        
        // Trace memory writes
        if (dmem_ce && |dmem_we) begin
            $display("[%t] MEM_WR: addr=0x%08h data=0x%08h we=%b", 
                     $time, bus_addr, bus_wdata, dmem_we);
        end
        
        // Trace function calls (JAL/JALR)
        if (state == 3'd2) begin // EXECUTE
            if (uut.machine.opcode == 7'b1101111) begin // JAL
                $display("[%t] JAL: PC=0x%08h -> 0x%08h (ra will be 0x%08h)", 
                         $time, pc, pc + uut.machine.imm, pc + 4);
            end
            if (uut.machine.opcode == 7'b1100111) begin // JALR
                $display("[%t] JALR: PC=0x%08h -> 0x%08h (ra will be 0x%08h)", 
                         $time, pc, (uut.machine.regfile[uut.machine.rs1] + uut.machine.imm) & ~32'b1, pc + 4);
            end
        end
    end
    `endif

endmodule
