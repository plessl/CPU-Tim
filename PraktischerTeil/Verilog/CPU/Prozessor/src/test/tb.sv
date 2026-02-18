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
logic [6:0] pc_trace;
logic clk_trace;
logic [4:0] row_addr;
logic [5:0] col_addr;
logic display_oe;
logic latch;
logic display_clk;
logic [3:0] dout_a;
logic [3:0] dout_b;

// SPI signals
logic spi_clk;
logic cs_n;
logic mosi;
reg miso;

// SPI debug signals
logic ctrl_miso;
logic ctrl_mosi;
logic ctrl_spi_clk;
logic ctrl_cs_n;
logic ctrl_clk;

// Button outputs
logic button_up;
logic button_down;
logic button_left;
logic button_right;

// SPI test signals
reg spi_test_passed = 1'b1;

topmodule uut(
    .clk(clk),
    .rst(rst),
    .pc_trace(pc_trace),
    .clk_trace(clk_trace),
    .row_addr(row_addr),
    .col_addr(col_addr),
    .display_oe(display_oe),
    .latch(latch),
    .display_clk(display_clk),
    .dout_a(dout_a),
    .dout_b(dout_b),
    .spi_clk(spi_clk),
    .cs_n(cs_n),
    .mosi(mosi),
    .miso(miso),
    .ctrl_miso(ctrl_miso),
    .ctrl_mosi(ctrl_mosi),
    .ctrl_spi_clk(ctrl_spi_clk),
    .ctrl_cs_n(ctrl_cs_n),
    .ctrl_clk(ctrl_clk),
    .button_up(button_up),
    .button_down(button_down),
    .button_left(button_left),
    .button_right(button_right)
);

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
