`timescale 1ns/1ns

module tb_comprehensive();

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

    // Instantiate the top module
    topmodule uut(
        .clk(clk),
        .rst(rst),
        .miso(1'b1) // Default MISO to high
    );

    // Access internal signals for monitoring (using hierarchical paths)
    assign pc = uut.machine.pc;
    assign instr = uut.machine.instr;
    assign bus_addr = uut.machine.bus_addr;
    assign bus_rdata = uut.machine.bus_rdata;
    assign bus_wdata = uut.machine.bus_wdata;
    assign dmem_we = uut.machine.dmem_we;
    assign dmem_ce = uut.machine.dmem_ce;

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 50MHz
    end

    // Test sequence
    initial begin
        $dumpfile("tb_comprehensive.vcd");
        $dumpvars(0, tb_comprehensive);
        
        $display("Starting Comprehensive Verification...");
        
        rst = 1;
        #100;
        rst = 0;
        
        // Monitor for "Magic Address" 0x0001_FFFC
        // We use this to signal test completion and status
        // 0x1 = PASS, 0xDEADBEEF = FAIL
        forever begin
            @(posedge clk);
            if (dmem_ce && |dmem_we && (bus_addr == 32'h0001_FFFC)) begin
                if (bus_wdata == 32'h1) begin
                    $display("TEST PASSED at PC: 0x%h", pc);
                    $finish;
                end else if (bus_wdata == 32'hDEADBEEF) begin
                    $display("TEST FAILED at PC: 0x%h", pc);
                    $finish;
                end
            end
        end
    end

    // Timeout mechanism
    initial begin
        #1000000; // 1ms simulation time
        $display("TIMEOUT: Test did not complete in time.");
        $finish;
    end

    // Optional: Instruction trace
    always @(posedge clk) begin
        if (uut.machine.state == 3'd0) begin // FETCH
            $display("Time: %t | PC: 0x%h | Instr: 0x%h", $time, pc, instr);
        end
    end

endmodule
