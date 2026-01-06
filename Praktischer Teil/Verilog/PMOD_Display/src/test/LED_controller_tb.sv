`timescale 1ns/1ps

module tb_LED_controller;
reg clk;
reg rst;
reg[4:0] row_addr;
reg[5:0] col_addr;
reg oe;
logic re;
reg latch;
reg display_clk;

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

localparam CLOCK_PERIOD = 50;
localparam CYCLETIME = CLOCK_PERIOD/2;

initial begin
    clk = 0;
    forever #CLOCK_PERIOD clk = ~clk;
end

initial begin
    $dumpfile("tb_LED_controller.vcd");
    $dumpvars(0, tb_LED_controller);
end

initial begin
    rst <= 1;
    #50
    rst <= 0;
    #500000
    $finish;
end

endmodule