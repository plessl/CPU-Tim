`timescale 1ns/1ps

module tb_cpu;
    reg clk;
    reg rst;
    
    // Instantiate top module
    topmodule uut (
        .clk(clk),
        .rst(rst)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    integer i;
    
    // Test program
    initial begin
        $dumpfile("tb_cpu.vcd");
        $dumpvars(0, tb_cpu);
        
        // Initialize ROM with test program
        // Test program: Simple arithmetic and memory operations
        
        // Instruction 0: ADDI x1, x0, 10 (x1 = 10)
        uut.rom.mem[0] = 32'h00a00093;
        
        // Instruction 1: ADDI x2, x0, 20 (x2 = 20)
        uut.rom.mem[1] = 32'h01400113;
        
        // Instruction 2: ADD x3, x1, x2 (x3 = x1 + x2 = 30)
        uut.rom.mem[2] = 32'h002081B3;
        
        // Instruction 3: SW x3, 0(x0) (store x3 to RAM address 0)
        uut.rom.mem[3] = 32'h00302023;
        
        // Instruction 4: LW x4, 0(x0) (load from RAM address 0 to x4)
        uut.rom.mem[4] = 32'h00002203;
        
        // Instruction 5: SUB x5, x3, x1 (x5 = x3 - x1 = 30 - 10 = 20)
        uut.rom.mem[5] = 32'h401182B3;
        
        // Instruction 6: AND x6, x1, x2 (x6 = x1 & x2 = 10 & 20 = 0)
        uut.rom.mem[6] = 32'h0020F333;
        
        // Instruction 7: OR x7, x1, x2 (x7 = x1 | x2 = 10 | 20 = 30)
        uut.rom.mem[7] = 32'h0020E3B3;
        
        // Instruction 8: XOR x8, x1, x2 (x8 = x1 ^ x2 = 10 ^ 20 = 30)
        uut.rom.mem[8] = 32'h0020C433;
        
        // Instruction 9: ADDI x9, x1, -5 (x9 = x1 - 5 = 5)
        uut.rom.mem[9] = 32'hFFB08493;
        
        // Instruction 10: SLL x10, x1, x9 (x10 = x1 << x9 = 10 << 5 = 320)
        uut.rom.mem[10] = 32'h00909533;
        
        // Initialize signals
        rst = 1;
        #20;
        rst = 0;
        
        // Run program
        $display("=== Starting CPU Integration Test ===\n");
        
        // Wait for instructions to execute (each takes ~5 cycles)
        #2600;
        
        // Check results
        $display("\n=== Checking Register File ===");
        $display("x0 (zero): %d (expected 0)", uut.machine.regfile[0]);
        $display("x1: %d (expected 10)", uut.machine.regfile[1]);
        $display("x2: %d (expected 20)", uut.machine.regfile[2]);
        $display("x3: %d (expected 30)", uut.machine.regfile[3]);
        $display("x4: %d (expected 30)", uut.machine.regfile[4]);
        $display("x5: %d (expected 20)", uut.machine.regfile[5]);
        $display("x6: %d (expected 0)", uut.machine.regfile[6]);
        $display("x7: %d (expected 30)", uut.machine.regfile[7]);
        $display("x8: %d (expected 30)", uut.machine.regfile[8]);
        $display("x9: %d (expected 5)", uut.machine.regfile[9]);
        $display("x10: %d (expected 320)", uut.machine.regfile[10]);
        
        // Verify critical results
        $display("\n=== Test Results ===");
        
        if (uut.machine.regfile[1] == 32'd10)
            $display("PASS: x1 = 10");
        else
            $display("FAIL: x1 expected 10, got %d", uut.machine.regfile[1]);
            
        if (uut.machine.regfile[2] == 32'd20)
            $display("PASS: x2 = 20");
        else
            $display("FAIL: x2 expected 20, got %d", uut.machine.regfile[2]);
            
        if (uut.machine.regfile[3] == 32'd30)
            $display("PASS: x3 = 30 (ADD)");
        else
            $display("FAIL: x3 expected 30, got %d", uut.machine.regfile[3]);
            
        if (uut.machine.regfile[4] == 32'd30)
            $display("PASS: x4 = 30 (Load from memory)");
        else
            $display("FAIL: x4 expected 30, got %d", uut.machine.regfile[4]);
            
        if (uut.machine.regfile[5] == 32'd20)
            $display("PASS: x5 = 20 (SUB)");
        else
            $display("FAIL: x5 expected 20, got %d", uut.machine.regfile[5]);
            
        if (uut.machine.regfile[6] == 32'd0)
            $display("PASS: x6 = 0 (AND)");
        else
            $display("FAIL: x6 expected 0, got %d", uut.machine.regfile[6]);
            
        if (uut.machine.regfile[7] == 32'd30)
            $display("PASS: x7 = 30 (OR)");
        else
            $display("FAIL: x7 expected 30, got %d", uut.machine.regfile[7]);
            
        if (uut.machine.regfile[8] == 32'd30)
            $display("PASS: x8 = 30 (XOR)");
        else
            $display("FAIL: x8 expected 30, got %d", uut.machine.regfile[8]);
            
        if (uut.machine.regfile[9] == 32'd5)
            $display("PASS: x9 = 5 (ADDI with negative)");
        else
            $display("FAIL: x9 expected 5, got %d", uut.machine.regfile[9]);
            
        if (uut.machine.regfile[10] == 32'd320)
            $display("PASS: x10 = 320 (Shift left)");
        else
            $display("FAIL: x10 expected 320, got %d", uut.machine.regfile[10]);
        
        // Check RAM
        $display("\n=== Checking RAM ===");
        $display("RAM[0]: %d (expected 30)", uut.ram.mem[0]);
        if (uut.ram.mem[0] == 32'd30)
            $display("PASS: RAM store/load working correctly");
        else
            $display("FAIL: RAM[0] expected 30, got %d", uut.ram.mem[0]);
        
        $display("\n=== CPU Integration Test Completed ===");
        #100;
        $finish;
    end
    
    // Timeout watchdog
    initial begin
        #10000;
        $display("ERROR: Test timeout!");
        $finish;
    end
    
endmodule
