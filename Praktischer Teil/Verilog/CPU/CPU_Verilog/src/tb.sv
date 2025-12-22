`timescale 1ns/1ps

module tb_cpu();

reg clk;
reg rst;
/*reg[3:0] pc_trace;*/

topmodule uut(
    .clk(clk),
    .rst(rst),
    /*.pc_trace(pc_trace)*/
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

integer i;

initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb_cpu);
    $display("test");

    uut.imem.mem[0] = 32'h00500093; //addi x1, x0, 5
    uut.imem.mem[1] = 32'hf3800093; //addi x1, x0, -200
    uut.imem.mem[2] = 32'h00112223; //sw x1, 4(x2)
    uut.imem.mem[3] = 32'hf2112c23; //sw x1, -200(x2)
    uut.imem.mem[4] = 32'hf3812083; //lw x1, -200(x2)
    uut.imem.mem[5] = 32'h06412083; //lw x1, 100(x2)
    uut.imem.mem[6] = 32'h12c0006f; //jal x0, 300
    uut.imem.mem[7] = 32'hf39ff06f; //jal x0, -200 
    uut.imem.mem[8] = 32'h01e180e7; //jalr x1, x3, 30 
    uut.imem.mem[9] = 32'hf34180e7; //jalr x1, x3, -204 
    uut.imem.mem[10] = 32'h000c8137; //lui x2, 200
    /*
    uut.imem.mem[0] = 32'h00500093;   //addi x1, x0, 5
    uut.imem.mem[1] = 32'h00a00113;   //addi x2, x0, 10
    uut.imem.mem[2] = 32'hff900193;   //addi x3, x0, -7
    uut.imem.mem[3] = 32'h00208233;   //add x4, x1, x2
    uut.imem.mem[4] = 32'h402082b3;   //sub x5, x1, x2
    uut.imem.mem[5] = 32'h0020c333;   //xor x6, x1, x2
    uut.imem.mem[6] = 32'h0020e3b3;   //or x7, x1, x2
    uut.imem.mem[7] = 32'h0020f433;   //and x8, x1, x2
    uut.imem.mem[8] = 32'h002094b3;   //sll x9, x1, x2
    uut.imem.mem[9] = 32'h4020d533;   //sra x10, x1, x2
    uut.imem.mem[10] = 32'h0030a5b3;   //slt x11, x1, x3
    uut.imem.mem[11] = 32'h0020b633;   //sltu x12, x1, x2
    */

    rst = 1;
    #20;
    rst = 0;
        
    #2600;
    
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
