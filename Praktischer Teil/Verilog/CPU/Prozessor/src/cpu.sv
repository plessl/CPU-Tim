module topmodule (
    input wire clk,
    input wire rst,
    output reg[3:0] pc_trace 
);

wire [31:0] instr_connect;
wire [31:0] dmem_rdata_connect;
wire imem_ce;
wire dmem_ce;
wire [31:0] pc;
wire dmem_read;
wire dmem_write;
wire [31:0] dmem_addr;
wire [31:0] dmem_wdata;
wire [31:0] instr_addr;
wire [31:0] instr;

ram_module dmem (
        .clk(clk),
        .we(dmem_write),
        .ce(dmem_ce),
        .rst(rst),
        .addr(dmem_addr),
        .data_in(dmem_wdata),
        .data_out(dmem_rdata_connect)
);

rom_module imem (
        .clk(clk),
        .rst(rst),
        .ce(imem_ce),
        .addr(instr_addr),
        .dout(instr)
);

fsm machine(
    .clk(clk),
    .rst(rst),

    // instruction memory
    .imem_ce(imem_ce),
    .instr_addr(instr_addr),
    .instr(instr),
    .pc(pc),

    //data memory
    .dmem_addr(dmem_addr),
    .dmem_rdata(dmem_rdata_connect),
    .dmem_ce(dmem_ce),
    .dmem_read(dmem_read),
    .dmem_write(dmem_write),
    .dmem_wdata(dmem_wdata)
    );

always @(posedge clk) begin
    pc_trace <= pc[3:0];
end

endmodule


module ram_module(
    input wire clk,
    input wire we,
    input wire ce,
    input wire rst,
    input wire[31:0] addr,
    input wire[31:0] data_in,
    output wire[31:0] data_out
);

reg [31:0] mem [4095:0];

assign data_out = (ce & !we) ? mem[addr >> 2] : 32'b0;

always @(posedge clk) begin
    if(ce & we)
        mem[addr >> 2] <= data_in;
end

endmodule


module rom_module (
        input wire clk,
        input wire rst,
        input wire ce,
        input wire[31:0] addr,
        output reg [31:0] dout
    );

    reg [31:0] mem [4095:0];

    /*initial begin
        $readmemh("program.hex", mem);
    end*/

    wire [31:0] comb_read = mem[addr >> 2];

    always @(posedge clk or posedge rst) begin
        if(rst)
            dout <= 0;
        else begin
            if(ce) begin
                dout <= comb_read;
            end
        end
    end

endmodule

module fsm(
    // general
    input wire clk,
    input wire rst,
    
    // instruction memory
    output reg imem_ce,    
    output reg[31:0] instr_addr,
    input wire[31:0] instr,
    output reg [31:0] pc,
    
    // data memory
    output reg[31:0] dmem_addr,
    input wire[31:0] dmem_rdata,
    output reg dmem_ce,
    output reg dmem_read,
    output reg dmem_write,
    output reg[31:0] dmem_wdata
);

    typedef enum reg[2:0]{
        FETCH = 0,
        DECODE = 1,
        EXECUTE = 2,
        MEMORY = 3,
        WRITEBACK = 4
    } statetype;

    reg [31:0] pc_next;
    statetype state;
    reg [31:0] regfile [31:0];
    reg [4:0]  rd, rs1, rs2;
    reg [31:0] imm;
    reg [6:0]  opcode;
    reg [2:0]  funct3;
    reg [6:0] funct7;

    reg [31:0] tmp_rd;
    reg [31:0] tmp_mem_addr;
    reg [4:0] shift_amt;
    reg [31:0] tmp_memw_data;
    integer i;
    integer d;

    always @(posedge clk or posedge rst) begin
        if(rst)begin
            state <= FETCH;
            pc <= 0;
            dmem_read <= 0;
            dmem_write <= 0;
            dmem_ce <= 0;
            imem_ce <= 0;
            dmem_addr <= 0;
            pc_next <= 0;
            for (i = 0; i < 32; i = i + 1)
                regfile[i] <= 0;
        end
        else begin
            case (state)
                FETCH: begin
                    imem_ce <= 1;
                    instr_addr <= pc;
                    pc_next <= pc + 4;
                    state <= DECODE;
                end
                DECODE: begin
                    opcode <= instr[6:0];
                    rd <= instr[11:7];
                    funct3 <= instr[14:12];
                    rs1 <= instr[19:15];
                    rs2 <= instr[24:20];
                    funct7 <= instr[31:25];

                    case (opcode)
                        7'b0010011:     //I type arithmetic
                            imm <= {{20{instr[31]}}, instr[31:20]};
                        7'b0000011:     //I type load
                            imm <= {{20{instr[31]}}, instr[31:20]};
                        7'b0100011:     //S type
                            imm <= {{20{instr[31]}}, instr[31:25], instr[11:7]};
                        7'b1100011:     //B type
                            imm <= {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
                        7'b1101111:     //J type jal
                            imm <= {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
                        7'b1100111:     // I type jalr
                            imm <= {{20{instr[31]}}, instr[31:20]};
                        7'b0110111:     //U type lui
                            imm <= {instr[31:12], 12'b0};
                        7'b0010111:     //U type auipc
                            imm <= {instr[31:12], 12'b0};
                        default:
                            imm <= 32'b0;
                    endcase
                    state <= EXECUTE;
                end
                EXECUTE: begin
                    imem_ce <= 0;
                    case (opcode)
                        7'b0110011: begin        //R type
                            shift_amt <= regfile[rs2][4:0];
                            case (funct3)
                                3'b000: begin
                                    case (funct7)
                                        7'b0000000:
                                            tmp_rd <= regfile[rs1] + regfile[rs2];   //add
                                        7'b0100000:
                                            tmp_rd <= regfile[rs1] - regfile[rs2];   //sub
                                        default:
                                            tmp_rd <= 32'b0;
                                    endcase
                                end
                                3'b100:
                                    tmp_rd <= regfile[rs1] ^ regfile[rs2];   //xor
                                3'b110:
                                    tmp_rd <= regfile[rs1] | regfile[rs2];   //or
                                3'b111:
                                    tmp_rd <= regfile[rs1] & regfile[rs2];   //and
                                3'b001:
                                    tmp_rd <= regfile[rs1] << shift_amt;  //sll
                                3'b101: begin
                                    case (funct7)
                                        7'b0000000:
                                            tmp_rd <= regfile[rs1] >> shift_amt;  //srl
                                        7'b0100000:
                                            tmp_rd <= $signed(regfile[rs1]) >>> shift_amt;  //sra
                                        default:
                                            tmp_rd <= 32'b0;
                                    endcase
                                end

                                3'b010:
                                    tmp_rd <= ($signed(regfile[rs1]) < $signed(regfile[rs2]))?1:0;   //slt
                                3'b011:
                                    tmp_rd <= ($unsigned(regfile[rs1]) < $unsigned(regfile[rs2]))?1:0; //sltu
                                default:
                                    tmp_rd <= 32'b0;
                            endcase
                        end

                        7'b0010011: begin       //I type arithmetic
                            case (funct3)
                                3'b000:
                                    tmp_rd <= regfile[rs1] + imm;    //addi
                                3'b100:
                                    tmp_rd <= regfile[rs1] ^ imm;    //xori
                                3'b110:
                                    tmp_rd <= regfile[rs1] | imm;    //ori
                                3'b111:
                                    tmp_rd <= regfile[rs1] & imm;    //andi
                                3'b001:
                                    tmp_rd <= regfile[rs1] << imm[4:0];   //slli
                                3'b101: begin
                                        case (imm[11:5])
                                            7'b0000000:
                                                tmp_rd <= regfile[rs1] >> imm[4:0];   //srli
                                            7'b0100000:
                                                tmp_rd <= $signed(regfile[rs1]) >>> imm[4:0];     //srai (arithmetic, use signed)
                                            default:
                                                tmp_rd <= 32'b0;
                                        endcase
                                    end
                                3'b010:
                                    tmp_rd <= ($signed(regfile[rs1]) < $signed(imm))?1:0;    //slti
                                3'b011:
                                    tmp_rd <= ($unsigned(regfile[rs1]) < $unsigned(imm))?1:0;   //sltiu
                                default:
                                    tmp_rd <= 32'b0;
                            endcase
                        end
                        7'b0000011: begin
                            dmem_ce <= 1;
                            case (funct3)
                                3'b000: begin
                                    tmp_mem_addr <= regfile[rs1] + imm;    //lb
                                    dmem_addr <= (regfile[rs1] + imm) >> 2;
                                end
                                3'b001: begin
                                    tmp_mem_addr <= (regfile[rs1] + imm);    //lh
                                    dmem_addr <= (regfile[rs1] + imm) >> 2;
                                end
                                3'b010: begin
                                    tmp_mem_addr <= (regfile[rs1] + imm);    //lw
                                    dmem_addr <= (regfile[rs1] + imm) >> 2;
                                end
                                3'b100: begin
                                    tmp_mem_addr <= (regfile[rs1] + imm);    //lbu
                                    dmem_addr <= (regfile[rs1] + imm) >> 2;
                                end
                                3'b101: begin
                                    tmp_mem_addr <= (regfile[rs1] + imm);    //lhu
                                    dmem_addr <= (regfile[rs1] + imm) >> 2;
                                end
                                default:
                                    tmp_rd <= 32'b0;
                            endcase
                        end
                        7'b0100011: begin   //S type
                            dmem_ce <= 1;
                            dmem_write <= 1;
                            tmp_mem_addr <= (regfile[rs1] + imm);
                            dmem_addr <= (regfile[rs1] + imm) >> 2;
                            tmp_memw_data <= regfile[rs2];
                        end

                        7'b1100011: begin   //B type
                            pc_next <= pc + 4;
                            case (funct3)
                                3'b000:
                                    if((regfile[rs1]) == (regfile[rs2])) pc_next <= pc+imm;   //beq
                                3'b001:
                                    if((regfile[rs1]) != (regfile[rs2])) pc_next <= pc+imm;   //bne
                                3'b100:
                                    if($signed(regfile[rs1]) < $signed(regfile[rs2])) pc_next <= pc+imm;    //blt (signed)
                                3'b101:
                                    if($signed(regfile[rs1]) >= $signed(regfile[rs2])) pc_next <= pc+imm;   //bge (signed)
                                3'b110:
                                    if($unsigned(regfile[rs1]) < $unsigned(regfile[rs2])) pc_next <= pc+imm;    //bltu
                                3'b111:
                                    if($unsigned(regfile[rs1]) >= $unsigned(regfile[rs2])) pc_next <= pc+imm;   //bgeu
                                default:
                                    pc_next <= pc+4;
                            endcase
                        end

                        7'b1101111: begin       //jal
                            tmp_rd <= pc + 4;
                            pc_next <= (pc + imm)& ~1;
                        end
                        7'b1100111: begin       //jalr
                            if(funct3 == 3'b000) begin
                                tmp_rd <= pc + 4;
                                pc_next <= (regfile[rs1] + imm) & ~1;
                            end
                        end
                        7'b0110111: begin       //lui
                            tmp_rd <= imm;
                        end
                        7'b0010111: begin
                            tmp_rd <= pc + imm;    //auipc
                        end
                        default:
                            $display("illegal instruction");
                    endcase
                    state <= MEMORY;
                end
                MEMORY: begin
                    case (opcode)
                    7'b0000011: begin
                        dmem_read <= 1;
                        case (funct3)
                            3'b000: begin     //lb
                                case (tmp_mem_addr[1:0])
                                    2'b00:
                                        tmp_rd <= {{24{dmem_rdata[7]}}, dmem_rdata[7:0]};
                                    2'b01:
                                        tmp_rd <= {{24{dmem_rdata[15]}}, dmem_rdata[15:8]};
                                    2'b10:
                                        tmp_rd <= {{24{dmem_rdata[23]}}, dmem_rdata[23:16]};
                                    2'b11:
                                        tmp_rd <= {{24{dmem_rdata[31]}}, dmem_rdata[31:24]};
                                    default:
                                        tmp_rd <= 32'b0;
                                endcase
                            end
                            3'b001: begin     //lh
                                case (tmp_mem_addr[1:0])
                                    2'b00:
                                        tmp_rd <= {{16{dmem_rdata[15]}}, dmem_rdata[15:0]};
                                    2'b10:
                                        tmp_rd <= {{16{dmem_rdata[31]}}, dmem_rdata[31:16]};
                                    default:
                                        tmp_rd <= 32'b0;
                                endcase
                            end
                            3'b010:       //lw
                                tmp_rd <= dmem_rdata;
                            3'b100: begin     //lbu
                                case (tmp_mem_addr[1:0])
                                    2'b00:
                                        tmp_rd <= {24'b0, dmem_rdata[7:0]};
                                    2'b01:
                                        tmp_rd <= {24'b0, dmem_rdata[15:8]};
                                    2'b10:
                                        tmp_rd <= {24'b0, dmem_rdata[23:16]};
                                    2'b11:
                                        tmp_rd <= {24'b0, dmem_rdata[31:24]};
                                    default:
                                        tmp_rd <= 32'b0;
                                endcase
                            end
                            3'b101: begin
                                case (tmp_mem_addr[1:0])
                                    2'b00:
                                        tmp_rd <= {16'b0, dmem_rdata[15:0]};
                                    2'b10:
                                        tmp_rd <= {16'b0, dmem_rdata[31:16]};
                                    default:
                                        tmp_rd <= 32'b0;
                                endcase
                            end
                            default:
                                tmp_rd <= 32'b0;
                        endcase
                    end
                    7'b0100011: begin
                        dmem_read <= 0;
                        dmem_wdata <= 32'b0;
                        dmem_write <= 1;
                        dmem_wdata <= 32'b0;
                        case (funct3)
                            3'b000: begin      //sb
                                case (tmp_mem_addr[1:0])
                                    2'b00: dmem_wdata <= {24'b0, tmp_memw_data[7:0]};
                                    2'b01: dmem_wdata <= {16'b0, tmp_memw_data[7:0], 8'b0};
                                    2'b10: dmem_wdata <= {8'b0, tmp_memw_data[7:0], 16'b0};
                                    2'b11: dmem_wdata <= {tmp_memw_data[7:0], 24'b0};
                                    default: dmem_wdata <= 0;
                                endcase
                            end
                            3'b001:  begin   //sh
                                case (tmp_mem_addr[1:0])
                                    2'b00: dmem_wdata <= {16'b0, tmp_memw_data[15:0]};
                                    2'b10: dmem_wdata <= {tmp_memw_data[15:0], 16'b0};
                                    default: dmem_wdata <= 0;
                                endcase
                            end
                            3'b010: begin
                                if (tmp_mem_addr[1:0] == 2'b00)
                                    dmem_wdata <= tmp_memw_data;
                                else
                                    dmem_wdata <= 32'b0;
                            end
                            default:
                                dmem_wdata <= 0;
                        endcase
                    end
                    default:
                        $display("undefined");
                    endcase
                        state <= WRITEBACK;
                end
                WRITEBACK: begin
                    dmem_ce <= 0;
                    dmem_write <= 0;
                    dmem_read <= 0;
                    pc <= pc_next;
                    if(rd != 0) regfile[rd] <= tmp_rd;
                    state <= FETCH;
                    show_instruction(instr);
                    /*for (d = 0; d < 32; d = d + 1)
                        $display("register: %d, value: %d", d, regfile[d]);
                    */
                end
            default:
                $display("fvcdfdcdc");
            endcase
        end
    end
    
task show_instruction;
        input [31:0] instr;
        reg [6:0] opcode;
        reg [4:0] rd, rs1, rs2;
        reg [31:0] imm;
        reg [2:0] funct3;
        reg [6:0] funct7;

        begin
            opcode = instr[6:0];
            rd = instr[11:7];
            funct3 = instr[14:12];
            rs1 = instr[19:15];
            rs2 = instr[24:20];
            funct7 = instr[31:25];

            case (opcode)
                7'b0010011:     //I type arithmetic
                    imm = {{20{instr[31]}}, instr[31:20]};
                7'b0000011:     //I type load
                    imm = {{20{instr[31]}}, instr[31:20]};
                7'b0100011:     //S type
                    imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
                7'b1100011:     //B type
                    imm = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
                7'b1101111:     //J type jal
                    imm = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
                7'b1100111:     // I type jalr
                    imm = {{20{instr[31]}}, instr[31:20]};
                7'b0110111:     //U type lui
                    imm = {instr[31:12], 12'b0};
                7'b0010111:     //U type auipc
                    imm = {instr[31:12], 12'b0};
                default:
                    imm = 32'b0;
            endcase

            case (opcode)
                7'b0110011: begin
                    case (funct3)
                        3'b000: begin
                            case (funct7)
                                7'b0000000:
                                    $display("add x%d, x%d, x%d", rd, rs1, rs2);
                                7'b0100000:
                                    $display("sub x%d, x%d, x%d", rd, rs1, rs2);
                                default:
                                    $display("illegal instruction");
                            endcase
                        end
                        3'b100:
                            $display("xor x%d, x%d, x%d", rd, rs1, rs2);
                        3'b110:
                            $display("or x%d, x%d, x%d", rd, rs1, rs2);
                        3'b111:
                            $display("and x%d, x%d, x%d", rd, rs1, rs2);
                        3'b001:
                            $display("sll x%d, x%d, x%d", rd, rs1, rs2);
                        3'b101: begin
                            case (funct7)
                                7'b0000000:
                                    $display("srl x%d, x%d, x%d", rd, rs1, rs2);
                                7'b0100000:
                                    $display("sra x%d, x%d, x%d", rd, rs1, rs2);
                                default:
                                    $display("illegal instruction");
                            endcase
                        end
                        3'b010:
                            $display("slt x%d, x%d, x%d", rd, rs1, rs2);
                        3'b011:
                            $display("sltu x%d, x%d, x%d", rd, rs1, rs2);
                        default:
                            $display("illegal instruction");
                    endcase
                end
                7'b0010011: begin
                    case (funct3)
                        3'b000:
                            $display("addi x%d, x%d, %d", rd, rs1, imm);
                        3'b100:
                            $display("xori x%d, x%d, %d", rd, rs1, imm);
                        3'b110:
                            $display("ori x%d, x%d, %d", rd, rs1, imm);
                        3'b111:
                            $display("andi x%d, x%d, %d", rd, rs1, imm);
                        3'b001: begin
                            case (imm[11:5])
                                7'b0000000:
                                    $display("slli x%d, x%d, %d", rd, rs1, imm);
                                default: $display("xori x%d, x%d, %d", rd, rs1, imm);
                            endcase
                        end
                        3'b101: begin
                            case (imm[11:5])
                                7'b0000000:
                                    $display("srli x%d, x%d, %d", rd, rs1, imm);
                                7'b0100000:
                                    $display("srai x%d, x%d, %d", rd, rs1, imm);
                                default: $display("illegal instruction");
                            endcase
                        end
                        3'b010:
                            $display("slti x%d, x%d, %d", rd, rs1, imm);
                        3'b011:
                            $display("sltiu x%d, x%d, %d", rd, rs1, imm);
                        default: $display("illegal instruction");
                    endcase
                end
                7'b0000011: begin
                    case (funct3)
                        3'b000:
                            $display("lb x%d, x%d, %d", rd, rs1, imm);
                        3'b001:
                            $display("lh x%d, x%d, %d", rd, rs1, imm);
                        3'b010:
                            $display("lw x%d, x%d, %d", rd, rs1, imm);
                        3'b100:
                            $display("lbu x%d, x%d, %d", rd, rs1, imm);
                        3'b101:
                            $display("lhu x%d, x%d, %d", rd, rs1, imm);
                        default: $display("illegal instruction");
                    endcase
                end
                7'b0100011: begin
                    case (funct3)
                        3'b000:
                            $display("sb x%d, x%d, %d", rs1, rs2, imm);
                        3'b001:
                            $display("sh x%d, x%d, %d", rs1, rs2, imm);
                        3'b010:
                            $display("sw x%d, x%d, %d", rs1, rs2, imm);
                        default: $display("illegal instruction");
                    endcase
                end
                7'b1100011: begin
                    case (funct3)
                        3'b000:
                            $display("beq x%d, x%d, %d", rs1, rs2, imm);
                        3'b001:
                            $display("bne x%d, x%d, %d", rs1, rs2, imm);
                        3'b100:
                            $display("blt x%d, x%d, %d", rs1, rs2, imm);
                        3'b101:
                            $display("bge x%d, x%d, %d", rs1, rs2, imm);
                        3'b110:
                            $display("bltu x%d, x%d, %d", rs1, rs2, imm);
                        3'b111:
                            $display("bgeu x%d, x%d, %d", rs1, rs2, imm);
                        default:  $display("illegal instruction");
                    endcase
                end
                7'b1101111:
                    $display("jal x%d, %d", rd, imm);
                7'b1100111:
                    $display("jalr x%d, x%d, %d", rd, rs1, imm);
                7'b0110111:
                    $display("lui x%d, %d", rd, imm);
                7'b0010111:
                    $display("auipc x%d, %d", rd, imm);
                default:
                    $display("illegal instruction");
            endcase
        end
    endtask
endmodule