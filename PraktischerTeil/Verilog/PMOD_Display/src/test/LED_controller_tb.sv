`timescale 1ns/1ps

module tb_LED_controller;

logic clk;
logic rst;
logic [4:0] row_addr;
logic [5:0] col_addr;
logic oe;
logic latch;
logic display_clk;
logic [3:0] dout_a;
logic [3:0] dout_b;

top dut(
    .rst(rst),
    .clk(clk),
    .col_addr(col_addr),
    .row_addr(row_addr),
    .oe(oe),
    .latch(latch),
    .display_clk(display_clk),
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
    $dumpfile("tb_LED_controller.vcd");
    $dumpvars(0, tb_LED_controller);
end

initial begin
    rst <= 1;
    #50
    rst <= 0;
    #5000000
    $finish;
end

endmodule