`timescale 1ns/1ps

module imm_decoder_tb;
    // Declare testbench signals
    reg clk;
    reg rst;
    reg [31:0] instr;
    wire signed [31:0] imm;
    // Instantiate DUT
    imm_dec uut (
        .instr(instr),
        .imm(imm)
    );

    // Clock generation (only if required by DUT)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test program
    initial begin
        $dumpfile("tb_imm_decoder.vcd");
        $dumpvars(0, imm_decoder_tb);

        rst = 1;
        instr = 32'b0;
        #2;
        rst = 0;

        instr = 32'h00500093; //addi x1, x0, 5
        #1;
        $display("instr=%h imm=%d", instr, imm);
        instr = 32'hf3800093; //addi x1, x0, -200
        #1;
        $display("instr=%h imm=%d", instr, imm);
        instr = 32'h00112223; //sw x1, 4(x2)
        #1;
        $display("instr=%h imm=%d", instr, imm);
        instr = 32'hf2112c23; //sw x1, -200(x2)
        #1;
        $display("instr=%h imm=%d", instr, imm);
        instr = 32'hf3812083; //lw x1, -200(x2)
        #1;
        $display("instr=%h imm=%d", instr, imm);
        instr = 32'h06412083; //lw x1, 100(x2)
        #1;
        $display("instr=%h imm=%d", instr, imm);
        instr = 32'h12c0006f; //jal x0, 300
        #1;
        $display("instr=%h imm=%d", instr, imm);
        instr = 32'hf39ff06f; //jal x0, -200
        #1;
        $display("instr=%h imm=%d", instr, imm);
        instr = 32'h01e180e7; //jalr x1, x3, 30
        #1;
        $display("instr=%h imm=%d", instr, imm);
        instr = 32'hf34180e7; //jalr x1, x3, -204
        #1;
        $display("instr=%h imm=%d", instr, imm);
        instr = 32'h000c8137; //lui x2, 200
        #1;
        $display("instr=%h imm=%d", instr, imm);

        #100;
        $finish;
    end

    // Timeout watchdog
    initial begin
        #10000;
        $display("ERROR: Test timeout!");
        $finish;
    end

endmodule