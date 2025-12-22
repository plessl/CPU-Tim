`timescale 1ns/1ps

module tb_rom;
    reg clk;
    reg rst;
    reg ce;
    reg [15:0] addr;
    wire [31:0] dout;
    
    // Instantiate ROM module
    rom_module uut (
        .clk(clk),
        .rst(rst),
        .ce(ce),
        .addr(addr),
        .dout(dout)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Initialize ROM with test data
    integer i;
    initial begin
        // Pre-load ROM memory for testing
        for (i = 0; i < 16; i = i + 1) begin
            uut.mem[i] = 32'h00000000 + (i << 8);
        end
    end
    
    // Test stimulus
    initial begin
        $dumpfile("tb_rom.vcd");
        $dumpvars(0, tb_rom);
        
        // Initialize signals
        rst = 1;
        ce = 0;
        addr = 0;
        
        // Reset
        #10;
        rst = 0;
        #10;
        
        // Test 1: Read from address 0 with ce enabled
        $display("Test 1: Read from address 0");
        ce = 1;
        addr = 16'h0000;
        #10; // Wait for clock edge
        #1;  // Small delay to see registered output
        if (dout == 32'h00000000)
            $display("PASS: Address 0 = 0x%h", dout);
        else
            $display("FAIL: Address 0 expected 0x00000000, got 0x%h", dout);
        
        // Test 2: Read from address 4
        $display("Test 2: Read from address 4");
        addr = 16'h0004;
        #10;
        #1;
        if (dout == 32'h00000100)
            $display("PASS: Address 4 = 0x%h", dout);
        else
            $display("FAIL: Address 4 expected 0x00000100, got 0x%h", dout);
        
        // Test 3: Test chip enable disabled
        $display("Test 3: Test chip enable disabled");
        ce = 0;
        addr = 16'h0008;
        #10;
        #1;
        if (dout == 32'h00000100) // Should keep previous value
            $display("PASS: Output unchanged when ce=0");
        else
            $display("INFO: Output changed to 0x%h when ce=0", dout);
        
        // Test 4: Re-enable and read
        $display("Test 4: Re-enable and read address 8");
        ce = 1;
        addr = 16'h0008;
        #10;
        #1;
        if (dout == 32'h00000200)
            $display("PASS: Address 8 = 0x%h", dout);
        else
            $display("FAIL: Address 8 expected 0x00000200, got 0x%h", dout);
        
        // Test 5: Sequential reads
        $display("Test 5: Sequential reads");
        for (i = 0; i < 8; i = i + 1) begin
            addr = i * 4;
            #10;
            #1;
            $display("Address %d (0x%h): Data = 0x%h", i*4, i*4, dout);
        end
        
        // Test 6: Reset test
        $display("Test 6: Reset test");
        rst = 1;
        #10;
        #1;
        if (dout == 32'h00000000)
            $display("PASS: Output is 0 after reset");
        else
            $display("FAIL: Output should be 0 after reset, got 0x%h", dout);
        
        rst = 0;
        #10;
        
        #20;
        $display("ROM tests completed");
        $finish;
    end
    
endmodule
