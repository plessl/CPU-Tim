`timescale 1ns/1ns

module tb_cpu();

// run testbench for cpu.sv
/*

must be run in src directory:

iverilog -g2012 -o tb.vvp test/tb.sv cpu.sv
vvp tb.vvp


*/

reg clk;
reg rst;
reg[6:0] pc_trace;
logic [4:0] row_addr;
logic [5:0] col_addr;
logic display_oe;
logic latch;
logic display_clk;
logic [3:0] dout_a;
logic [3:0] dout_b;
logic [3:0] buttons;

// SPI test signals
reg miso;
reg spi_test_passed = 1'b1;

// Additional wires for monitoring
wire [31:0] spi_rdata_connect;

topmodule uut(
    .clk(clk),
    .rst(rst),
    .trace(pc_trace),
    .row_addr(row_addr),
    .col_addr(col_addr),
    .display_oe(display_oe),
    .latch(latch),
    .display_clk(display_clk),
    .dout_a(dout_a),
    .dout_b(dout_b),
    .buttons(buttons),
    .miso(miso)
);

// Monitor internal signals
assign spi_rdata_connect = uut.spi_rdata_connect;

initial begin
    clk = 0;
    forever #25 clk = ~clk;
end

integer i;

initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb_cpu);
    $display("test");

    rst = 1;
    #150;
    rst = 0;

end

// SPI MISO driver - proactive version that drives immediately
reg [7:0] miso_send_data = 8'h00;
reg miso_active = 1'b0;
integer miso_bit_idx = 0;

// Calculate which bit to drive based on word_cntr and bit_cntr
always @(*) begin
    if (miso_active) begin
        if (uut.spi_inst.word_cntr == 3) begin
            miso_send_data = 8'h55;  // Data for word_cntr 3
        end else if (uut.spi_inst.word_cntr == 4) begin
            miso_send_data = 8'hAA;  // Data for word_cntr 4
        end else begin
            miso_send_data = 8'h00;
        end
        
        // Calculate bit position (MSB first)
        case (uut.spi_inst.bit_cntr)
            4'd0: miso = miso_send_data[7];
            4'd1: miso = miso_send_data[6];
            4'd2: miso = miso_send_data[5];
            4'd3: miso = miso_send_data[4];
            4'd4: miso = miso_send_data[3];
            4'd5: miso = miso_send_data[2];
            4'd6: miso = miso_send_data[1];
            4'd7: miso = miso_send_data[0];
            default: miso = 1'b0;
        endcase
    end else begin
        miso = 1'b1;  // Idle high
    end
end

// MISO driver controller - tracks transaction state
initial begin
    forever begin
        // Wait for SPI transaction to start
        wait(uut.spi_inst.cs_n == 1'b0);
        miso_active = 1'b1;
        $display("MISO: Transaction started at time %0t, word_cntr=%0d", 
                 $time, uut.spi_inst.word_cntr);
        
        // Wait for transaction to end
        wait(uut.spi_inst.cs_n == 1'b1);
        miso_active = 1'b0;
        $display("MISO: Transaction ended at time %0t", $time);
    end
end

// SPI Controller Test - verify recv_msg values
initial begin
    // Initialize MISO to idle state (high)
    miso = 1'b1;
    
    // Wait for reset to be deasserted
    wait(rst == 1'b0);
    #100;
    
    $display("=== SPI Controller Test ===");
    $display("Testing SPI receive path...");
    
    // Wait for SPI transaction to complete (cs_n goes high AND state is IDLE)
    wait(uut.spi_inst.cs_n == 1'b1 && uut.spi_inst.state == 3'd1);
    #100;
    
    $display("SPI transaction completed at time %0t", $time);
    $display("SPI state: %d", uut.spi_inst.state);
    $display("recv_msg[4] = 0x%h", uut.spi_inst.recv_msg[4]);
    $display("recv_msg[3] = 0x%h", uut.spi_inst.recv_msg[3]);
    
    // Check received data
    $display("Received data check:");
    $display("  recv_msg[4] = 8'b%b", uut.spi_inst.recv_msg[4]);
    $display("  recv_msg[3] = 8'b%b", uut.spi_inst.recv_msg[3]);
    $display("  spi_rdata = 32'h%h", uut.spi_inst.spi_rdata);
    
    // Verify recv_msg[3] received 0x55 during word_cntr=3
    if (uut.spi_inst.recv_msg[3] !== 8'h55) begin
        $display("ERROR: recv_msg[3] = 8'h%h, expected 8'h55", uut.spi_inst.recv_msg[3]);
        spi_test_passed = 1'b0;
    end else begin
        $display("PASS: recv_msg[3] = 0x55");
    end
    
    // Verify recv_msg[4] received 0xAA during word_cntr=4
    if (uut.spi_inst.recv_msg[4] !== 8'hAA) begin
        $display("ERROR: recv_msg[4] = 8'h%h, expected 8'hAA", uut.spi_inst.recv_msg[4]);
        spi_test_passed = 1'b0;
    end else begin
        $display("PASS: recv_msg[4] = 0xAA");
    end
    
    // Check spi_rdata contains the correct bits
    // spi_rdata = {16'b0, recv_msg[4], recv_msg[3]} = {16'b0, 0xAA, 0x55}
    if (uut.spi_inst.spi_rdata !== 32'h0000AA55) begin
        $display("ERROR: spi_rdata = 32'h%h, expected 32'h0000AA55", uut.spi_inst.spi_rdata);
        spi_test_passed = 1'b0;
    end else begin
        $display("PASS: spi_rdata = 0x0000AA55");
    end
    
    if (spi_test_passed) begin
        $display("=== SPI TEST PASSED ===");
    end else begin
        $display("=== SPI TEST FAILED ===");
    end
    
end

// CPU lw SPI Test - verify data ends up in a CPU register
initial begin
    reg [31:0] expected_data;
    reg [31:0] x5_value;
    integer timeout;
    
    $display("\n=== CPU lw SPI Register Test ===");
    
    // Expected SPI data: {16'b0, recv_msg[4], recv_msg[3]] = {16'b0, 0xAA, 0x55}
    expected_data = 32'h0000AA55;
    
    // Wait for SPI Controller Test to complete first
    wait(spi_test_passed !== 1'bx);
    #500;
    
    $display("SPI Controller Test complete, checking CPU register...");
    $display("Time: %0t ns", $time);
    
    $display("Expected SPI data: 0x%h", expected_data);
    $display("SPI controller spi_rdata: 0x%h", uut.spi_inst.spi_rdata);
    $display("spi_rdata_connect: 0x%h", spi_rdata_connect);
    
    // Force bus to read from SPI to verify path
    force uut.spi_re = 1'b1;
    force uut.bus_addr = 32'h00030000;
    #50;
    
    $display("bus_rdata (forced SPI read): 0x%h", uut.machine.bus_rdata);
    
    if (uut.machine.bus_rdata == expected_data) begin
        $display("PASS: Bus path correctly returns SPI data");
    end else begin
        $display("ERROR: Bus path returned 0x%h, expected 0x%h", uut.machine.bus_rdata, expected_data);
    end
    
    release uut.spi_re;
    release uut.bus_addr;
    
    // Now check if CPU's own lw instruction loads the data correctly
    $display("\n=== CPU lw Instruction Test ===");
    
    // Wait for CPU to execute lw from SPI address
    timeout = 0;
    while (uut.machine.regfile[5] == 32'b0 && timeout < 500000) begin
        #100;
        timeout = timeout + 100;
    end
    
    #1000;  // Wait for register to update
    
    x5_value = uut.machine.regfile[5];
    
    $display("After waiting for CPU lw instruction:");
    $display("Time: %0t ns", $time);
    $display("regfile[5] (x5): 0x%h", x5_value);
    
    // Check if x5 got the SPI data
    if (x5_value !== expected_data) begin
        $display("ERROR: regfile[5] = 0x%h, expected 0x%h", x5_value, expected_data);
        $display("FAIL: SPI data did NOT end up in CPU register x5!");
    end else begin
        $display("PASS: SPI data correctly loaded into regfile[5] via lw instruction");
    end
    
    $display("=== CPU SPI Register Test Complete ===\n");
end

function string state_name(logic [3:0] state);
    case(state)
        4'd0: return "FETCH";
        4'd1: return "SHIFT1";
        4'd2: return "SHIFT2";
        4'd3: return "LATCH_HIGH";
        4'd4: return "LATCH_LOW";
        4'd5: return "WAIT";
        default: return "UNKNOWN";
    endcase
endfunction

initial begin
    #2000000;
    $display("ERROR: Test timeout!");
    $finish;
end

endmodule

//iverilog -g2012 -o build/tb.vvp test/tb.sv src/cpu.sv
