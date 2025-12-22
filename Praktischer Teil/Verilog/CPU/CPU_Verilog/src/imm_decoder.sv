module imm_dec(
    input [31:0] instr,
    output reg [31:0] imm
);

    reg [6:0] opcode;
    reg [4:0] rd;
    reg [2:0] funct3;
    reg [4:0] rs1;
    reg [4:0] rs2;
    reg [6:0] funct7;

    always @(*) begin
        opcode = instr[6:0];
        rd = instr[11:7];
        funct3 = instr[14:12];
        rs1 = instr[19:15];
        rs2 = instr[24:20];
        funct7 = instr[31:25];

        case (opcode)
            7'b0010011:     // I type arithmetic
                imm = {{20{instr[31]}}, instr[31:20]};
            7'b0000011:     // I type load
                imm = {{20{instr[31]}}, instr[31:20]};
            7'b0100011:     // S type
                imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            7'b1100011:     // B type
                imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            7'b1101111:     // J type jal
                imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
            7'b1100111:     // I type jalr
                imm = {{20{instr[31]}}, instr[31:20]};
            7'b0110111:     // U type lui
                imm = {instr[31:12], 12'b0};
            7'b0010111:     // U type auipc
                imm = {instr[31:12], 12'b0};
            default:
                imm = 32'b0;
        endcase
    end

endmodule