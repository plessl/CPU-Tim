`timescale 1ns/1ps

module tb_ram;
    reg clk;
    reg we;
    reg ce;
    reg rst;
    reg [15:0] addr;
    reg [31:0] data_in;
    wire [31:0] data_out;
    
    // Instantiate RAM module
    ram_module uut (
        .clk(clk),
        .we(we),
        .ce(ce),
        .rst(rst),
        .addr(addr),
        .data_in(data_in),
        .data_out(data_out)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test stimulus
    initial begin
        $dumpfile("tb_ram.vcd");
        $dumpvars(0, tb_ram);
        
        // Initialize signals
        rst = 1;
        we = 0;
        ce = 0;
        addr = 0;
        data_in = 0;
        
        // Reset
        #10;
        rst = 0;
        #10;
        
        // Test 1: Write data to address 0
        $display("Test 1: Write 0xDEADBEEF to address 0");
        ce = 1;
        we = 1;
        addr = 16'h0000;
        data_in = 32'hDEADBEEF;
        #10;
        we = 0;
        #10;
        
        // Test 2: Read data from address 0
        $display("Test 2: Read from address 0");
        addr = 16'h0000;
        #10;
        if (data_out == 32'hDEADBEEF)
            $display("PASS: Read correct value 0x%h", data_out);
        else
            $display("FAIL: Expected 0xDEADBEEF, got 0x%h", data_out);
        
        // Test 3: Write to address 4 (word-aligned)
        $display("Test 3: Write 0x12345678 to address 4");
        we = 1;
        addr = 16'h0004;
        data_in = 32'h12345678;
        #10;
        we = 0;
        #10;
        
        // Test 4: Read from address 4
        $display("Test 4: Read from address 4");
        addr = 16'h0004;
        #10;
        if (data_out == 32'h12345678)
            $display("PASS: Read correct value 0x%h", data_out);
        else
            $display("FAIL: Expected 0x12345678, got 0x%h", data_out);
        
        // Test 5: Verify address 0 still has original value
        $display("Test 5: Verify address 0 unchanged");
        addr = 16'h0000;
        #10;
        if (data_out == 32'hDEADBEEF)
            $display("PASS: Address 0 still contains 0x%h", data_out);
        else
            $display("FAIL: Address 0 corrupted, got 0x%h", data_out);
        
        // Test 6: Test chip enable (ce = 0)
        $display("Test 6: Test chip enable disabled");
        ce = 0;
        addr = 16'h0000;
        #10;
        if (data_out == 32'h00000000)
            $display("PASS: Output is 0 when ce=0");
        else
            $display("FAIL: Expected 0x00000000 when ce=0, got 0x%h", data_out);
        
        // Test 7: Multiple consecutive writes
        $display("Test 7: Multiple consecutive writes");
        ce = 1;
        we = 1;
        addr = 16'h0008;
        data_in = 32'hAAAAAAAA;
        #10;
        addr = 16'h000C;
        data_in = 32'h55555555;
        #10;
        we = 0;
        
        // Verify both writes
        addr = 16'h0008;
        #10;
        if (data_out == 32'hAAAAAAAA)
            $display("PASS: Address 8 = 0x%h", data_out);
        else
            $display("FAIL: Address 8 expected 0xAAAAAAAA, got 0x%h", data_out);
            
        addr = 16'h000C;
        #10;
        if (data_out == 32'h55555555)
            $display("PASS: Address C = 0x%h", data_out);
        else
            $display("FAIL: Address C expected 0x55555555, got 0x%h", data_out);
        
        #20;
        $display("RAM tests completed");
        $finish;
    end
    
endmodule
