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
reg clk_trace;
logic [4:0] row_addr;
logic [5:0] col_addr;
logic display_oe;
logic latch;
logic display_clk;
logic [3:0] dout_a;
logic [3:0] dout_b;

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
    .dout_b(dout_b)
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

    // Monitor LED controller signals
    //$monitor("Time=%0t: state=%d row=%2d col=%2d clk=%b latch=%b oe=%b fbuf_re=%b dout_a=%h dout_b=%h", 
    //         $time, uut.led_inst.con_state, row_addr, col_addr, 
    //         display_clk, latch, display_oe, uut.led_inst.fbuf_re, dout_a, dout_b);

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
    #1000000;
    $display("ERROR: Test timeout!");
    $finish;
end

endmodule

//iverilog -g2012 -o build/tb.vvp test/tb.sv src/cpu.sv
