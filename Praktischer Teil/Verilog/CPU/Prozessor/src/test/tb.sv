`timescale 1ns/1ns

module tb_cpu();

reg clk;
reg rst;
reg[3:0] pc_trace;

topmodule uut(
    .clk(clk),
    .rst(rst),
    .pc_trace(pc_trace)
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


    /*
    $display("x0 (zero): %d (expected 0)", uut.machine.regfile[0]);
    $display("x1: %d (expected 5)", uut.machine.regfile[1]);
    $display("x2: %d (expected 10)", uut.machine.regfile[2]);
    $display("x3: %d (expected -7)", $signed(uut.machine.regfile[3]));
    $display("x4: %d (expected 15)", uut.machine.regfile[4]);
    $display("x5: %d (expected -5)", $signed(uut.machine.regfile[5]));
    $display("x6: %d (expected 15)", uut.machine.regfile[6]);
    $display("x7: %d (expected 15)", uut.machine.regfile[7]);
    $display("x8: %d (expected 0)", uut.machine.regfile[8]);
    $display("x9: %d (expected 5120)", uut.machine.regfile[9]);
    $display("x10: %d (expected 0)", uut.machine.regfile[10]);
    $display("x11: %d (expected 0)", uut.machine.regfile[11]);
    $display("x12: %d (expected 1)", uut.machine.regfile[12]);
    */

end

initial begin
    #10000;
    $display("ERROR: Test timeout!");
    $finish;
end

endmodule

//iverilog -g2012 -o build/tb.vvp test/tb.sv src/cpu.sv
