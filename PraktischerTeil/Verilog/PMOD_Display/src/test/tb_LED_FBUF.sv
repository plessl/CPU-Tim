`timescale 1ns/1ps


/*
iverilog -g2012 -o tb_LED_FBUF.vvp test/tb_LED_FBUF.sv LED_controller.sv
vvp tb_LED_FBUF.vvp
*/

module tb_LED_FBUF;
logic clk;
logic rst;

logic [4:0] row_addr;
logic [5:0] col_addr;
logic oe;
logic re;
logic latch;
logic display_clk;

logic [3:0] din;
logic ce;
logic [11:0] waddr;
logic we;
logic [11:0] raddr_a;
logic [11:0] raddr_b;
logic [3:0] dout_a;
logic [3:0] dout_b;

LED_controller dut(
    .clk(clk),
    .rst(rst),
    .row_addr(row_addr),
    .col_addr(col_addr),
    .oe(oe),
    .re(re),
    .latch(latch),
    .display_clk(display_clk)
);

framebuffer fbuf(
    .clk(clk),
    .rst(rst),
    .din(din),
    .ce(1'b1),
    .re(re),
    .waddr(waddr),
    .we(we),
    .raddr_a({1'b0, row_addr, col_addr}),
    .raddr_b({1'b1, row_addr, col_addr}),
    .dout_a(dout_a),
    .dout_b(dout_b)
);

localparam CLOCK_PERIOD = 50;
localparam CYCLETIME = CLOCK_PERIOD/2;

initial begin
    clk = 0;
    forever #CLOCK_PERIOD clk = ~clk;
end

initial begin
    $dumpfile("tb_LED_FBUF.vcd");
    $dumpvars(0, tb_LED_FBUF);
end

initial begin
    rst <= 1;
    #50
    rst <= 0;
    #50000000
    $finish;
end

endmodule