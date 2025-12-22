`timescale 1ns/1ps

module tb_topmodule;
reg clk;
initial clk = 0;
reg rst;
wire [7:0] data_wire;

topmodule dut
(
    .rst (rst),
    .clk (clk),
    .out(data_wire)
);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk=~clk;

initial begin
    $dumpfile("tb_topmodule.vcd");
    $dumpvars(0, tb_topmodule);
end

initial begin
    dut.rom.mem[0] = 32'h00000005;
    dut.rom.mem[1] = 32'h000000C8;

    rst <= 1;
    #5
    rst <= 0;
    #100
    $finish;
end
endmodule
