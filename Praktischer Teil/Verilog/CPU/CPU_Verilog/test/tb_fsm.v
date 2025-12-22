`timescale 1ns/1ps

module tb_fsm;
    reg clk;
    reg rst;
    reg [31:0] instr;
    reg [31:0] mem_rdata;
    wire rom_ce;
    wire ram_ce;
    wire [31:0] pc;
    wire mem_read;
    wire mem_write;
    wire [15:0] mem_addr;
    wire [31:0] mem_wdata;
    
    integer i;
    
    fsm uut (
        .clk(clk),
        .rst(rst),
        .instr(instr),
        .mem_rdata(mem_rdata),
        .rom_ce(rom_ce),
        .ram_ce(ram_ce),
        .pc(pc),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata)
    );
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    task wait_cycles;
        input integer n;
        begin
            repeat(n) @(posedge clk);
        end
    endtask
    
    task execute_instruction;
        input [31:0] instruction;
        input [31:0] mem_data;
        begin
            instr = instruction;
            mem_rdata = mem_data;
        end
    endtask
    
    // Test stimulus
    initial begin
        $dumpfile("tb_fsm.vcd");
        $dumpvars(0, tb_fsm);
        
        // Initialize signals
        rst = 1;
        instr = 32'h00000013; // NOP (addi x0, x0, 0)
        mem_rdata = 32'h0;
        
        #1500;
        rst = 0;
        #1000;
        
        // Test 1: ADDI x1, x0, 5 (addi x1, x0, 5) - Load immediate
        $display("\n=== Test 1: ADDI x1, x0, 5 ===");
        execute_instruction(32'h00500093, 32'h0); // addi x1, x0, 5
        #50;
        $display("PC: %d, Register x1: %d", pc, uut.regfile[1]);
        if (uut.regfile[1] == 32'd5)
            $display("PASS: x1 = 5");
        else
            $display("FAIL: x1 expected 5, got %d", uut.regfile[1]);
        
        // Test 2: ADDI x2, x0, 10
        $display("\n=== Test 2: ADDI x2, x0, 10 ===");
        execute_instruction(32'h00A00113, 32'h0); // addi x2, x0, 10
        #50;
        $display("PC: %d, Register x2: %d", pc, uut.regfile[2]);
        if (uut.regfile[2] == 32'd10)
            $display("PASS: x2 = 10");
        else
            $display("FAIL: x2 expected 10, got %d", uut.regfile[2]);
        
        // Test 3: ADD x3, x1, x2 (x3 = x1 + x2 = 5 + 10 = 15)
        $display("\n=== Test 3: ADD x3, x1, x2 ===");
        execute_instruction(32'h002081B3, 32'h0); // add x3, x1, x2
        #50;
        $display("PC: %d, Register x3: %d", pc, uut.regfile[3]);
        if (uut.regfile[3] == 32'd15)
            $display("PASS: x3 = 15 (5 + 10)");
        else
            $display("FAIL: x3 expected 15, got %d", uut.regfile[3]);
        
        // Test 4: SUB x4, x2, x1 (x4 = x2 - x1 = 10 - 5 = 5)
        $display("\n=== Test 4: SUB x4, x2, x1 ===");
        execute_instruction(32'h40110233, 32'h0); // sub x4, x2, x1
        #50;
        $display("PC: %d, Register x4: %d", pc, uut.regfile[4]);
        if (uut.regfile[4] == 32'd5)
            $display("PASS: x4 = 5 (10 - 5)");
        else
            $display("FAIL: x4 expected 5, got %d", uut.regfile[4]);
        
        // Test 5: AND x5, x1, x2 (x5 = x1 & x2 = 5 & 10 = 0)
        $display("\n=== Test 5: AND x5, x1, x2 ===");
        execute_instruction(32'h0020F2B3, 32'h0); // and x5, x1, x2
        #50;
        $display("PC: %d, Register x5: %d", pc, uut.regfile[5]);
        if (uut.regfile[5] == 32'd0)
            $display("PASS: x5 = 0 (5 & 10)");
        else
            $display("FAIL: x5 expected 0, got %d", uut.regfile[5]);
        
        // Test 6: OR x6, x1, x2 (x6 = x1 | x2 = 5 | 10 = 15)
        $display("\n=== Test 6: OR x6, x1, x2 ===");
        execute_instruction(32'h0020E333, 32'h0); // or x6, x1, x2
        #50;
        $display("PC: %d, Register x6: %d", pc, uut.regfile[6]);
        if (uut.regfile[6] == 32'd15)
            $display("PASS: x6 = 15 (5 | 10)");
        else
            $display("FAIL: x6 expected 15, got %d", uut.regfile[6]);
        
        // Test 7: XOR x7, x1, x2 (x7 = x1 ^ x2 = 5 ^ 10 = 15)
        $display("\n=== Test 7: XOR x7, x1, x2 ===");
        execute_instruction(32'h0020C3B3, 32'h0); // xor x7, x1, x2
        #50;
        $display("PC: %d, Register x7: %d", pc, uut.regfile[7]);
        if (uut.regfile[7] == 32'd15)
            $display("PASS: x7 = 15 (5 ^ 10)");
        else
            $display("FAIL: x7 expected 15, got %d", uut.regfile[7]);
        
        // Test 8: LUI x8, 0x12345 (Load upper immediate)
        $display("\n=== Test 8: LUI x8, 0x12345 ===");
        execute_instruction(32'h12345437, 32'h0); // lui x8, 0x12345
        #50;
        $display("PC: %d, Register x8: 0x%h", pc, uut.regfile[8]);
        if (uut.regfile[8] == 32'h12345000)
            $display("PASS: x8 = 0x12345000");
        else
            $display("FAIL: x8 expected 0x12345000, got 0x%h", uut.regfile[8]);
        
        // Test 9: SLL x9, x1, x1 (x9 = x1 << x1 = 5 << 5 = 160)
        $display("\n=== Test 9: SLL x9, x1, x1 ===");
        execute_instruction(32'h001094B3, 32'h0); // sll x9, x1, x1
        #50;
        $display("PC: %d, Register x9: %d", pc, uut.regfile[9]);
        if (uut.regfile[9] == 32'd160)
            $display("PASS: x9 = 160 (5 << 5)");
        else
            $display("FAIL: x9 expected 160, got %d", uut.regfile[9]);
        
        // Test 10: PC increment verification
        $display("\n=== Test 10: PC Increment ===");
        $display("Current PC: %d", pc);
        if (pc == 32'd40) // 10 instructions * 4 bytes
            $display("PASS: PC correctly incremented to %d", pc);
        else
            $display("FAIL: PC expected 40, got %d", pc);
        
        #500;
        $display("\n=== FSM tests completed ===");
        $finish;
    end
    
endmodule
