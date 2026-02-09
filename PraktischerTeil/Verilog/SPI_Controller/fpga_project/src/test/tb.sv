/*
    iverilog -g2012 -o tb.vvp test/tb.sv controller.sv
    vvp tb.vvp

*/
module tb_spi_controller;
    logic clk; 
    logic rst; 
    logic spi_clk;
    logic cs_n;
    logic mosi; 
    logic miso;   
    logic ctrl_miso;
    logic ctrl_mosi;
    logic ctrl_spi_clk;
    logic ctrl_cs_n;

spi_controller dut 
(
    .clk(clk),
    .rst(rst),
    .spi_clk(spi_clk),
    .cs_n(cs_n),
    .mosi(mosi),  
    .miso(miso),
    .ctrl_miso(ctrl_miso),
    .ctrl_mosi(ctrl_mosi),
    .ctrl_spi_clk(ctrl_spi_clk),
    .ctrl_cs_n(ctrl_cs_n)

);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk=~clk;

initial begin
    $dumpfile("tb_spi_controller.vcd");
    $dumpvars(0, tb_spi_controller);
    clk = 0;
    rst = 0;
end

initial begin
    rst = 1;
    #20
    rst = 0;
    #5000000;
    $finish();
end

endmodule
