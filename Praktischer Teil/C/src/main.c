#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include <string.h>

#define DATA_RAM_SIZE 16384
#define DATA_RAM_OFFSET (64*1024)

#define SIGN_EXTEND(val, bits) (((int32_t)(val) << (32 - (bits))) >> (32 - (bits)))
#define MSB_EXTEND(value, bits) \
    ((uint32_t)((int32_t)((value) << (32 - (bits))) >> (32 - (bits))))

struct CPU{
    uint32_t PC;
    uint32_t PC_next;
    uint8_t program[16384];
    uint8_t data[DATA_RAM_SIZE];
    uint32_t registers[32];
};

bool show_instruction = true;
struct CPU cpu;

static uint32_t fetch(int PC){
    uint32_t instruction;
    instruction = ((uint32_t)cpu.program[PC])
                | ((uint32_t)cpu.program[PC+1] << 8) 
                | ((uint32_t)cpu.program[PC+2] << 16) 
                | ((uint32_t)cpu.program[PC+3] << 24);
    return instruction;
}

static void decodeAndExecute(uint32_t instruction){
    uint8_t opcode = instruction & 0x7F;

    switch (opcode)
    {
    case 0x33: {             //R-Type
        uint8_t rd     = (instruction >> 7)  & 0x1F;
        uint8_t funct3 = (instruction >> 12) & 0x07;
        uint8_t rs1    = (instruction >> 15) & 0x1F;
        uint8_t rs2    = (instruction >> 20) & 0x1F;
        uint8_t funct7 = (instruction >> 25) & 0x7F;
        
        if(show_instruction){
            printf("rd: x%d, ", rd);
            printf("funct3: %d, ", funct3);
            printf("rs1: x%d, ", rs1);
            printf("rs2: x%d, ", rs2);
            printf("funct7: %d, ", funct7);
        }

        switch (funct3)
        {
        case 0x0:
            
            switch (funct7)
            {
            case 0x00:
                // add
                cpu.registers[rd] = cpu.registers[rs1] + cpu.registers[rs2];
                cpu.PC += 4;
                printf("add\n");
                break;
                
            
            case 0x20:
                //sub
                cpu.registers[rd] = cpu.registers[rs1] - cpu.registers[rs2];
                cpu.PC += 4;
                printf("sub\n");
                break;
            
            default:
                
                break;
                
            }
            
            break;
        
        case 0x1:
            //sll
            cpu.registers[rd] = cpu.registers[rs1] << (cpu.registers[rs2] & 0x1F);
            cpu.PC += 4;
            printf("sll\n");
            break;

        case 0x4:
            //xor
            cpu.registers[rd] = cpu.registers[rs1] ^ cpu.registers[rs2];
            cpu.PC += 4;
            printf("xor\n");
            break;

        case 0x6:
            //or
            cpu.registers[rd] = cpu.registers[rs1] | cpu.registers[rs2];
            cpu.PC += 4;
            printf("or\n");
            break;

        case 0x7:
            //and
            cpu.registers[rd] = cpu.registers[rs1] & cpu.registers[rs2];
            cpu.PC += 4;
            printf("and\n");
            break;
        
        case 0x5:
            switch (funct7)
            {
            case 0x00:
                //srl
                cpu.registers[rd] = cpu.registers[rs1] >> (cpu.registers[rs2] & 0x1F);
                cpu.PC += 4;
                printf("srl\n");
                break;

            case 0x20:
                //sra
                cpu.registers[rd] = (uint32_t)((int32_t)cpu.registers[rs1] >> (cpu.registers[rs2] & 0x1F));
                cpu.PC += 4;
                printf("sra\n");
                break;

            }
            break;
        
        case 0x2:
            //slt
            cpu.registers[rd] = ((int32_t)cpu.registers[rs1] < (int32_t)cpu.registers[rs2])?1:0;
            cpu.PC += 4;
            printf("slt\n");
            break;

        case 0x3:
            //sltu
            cpu.registers[rd] = (cpu.registers[rs1] < cpu.registers[rs2])?1u:0u;
            cpu.PC += 4;
            printf("sltu\n");
            break;
        }
    }
        break;

    case 0x13: {             //I-Type arithmetic

        uint8_t rd     = (instruction >> 7)  & 0x1F;
        uint8_t funct3 = (instruction >> 12) & 0x07;
        uint8_t rs1    = (instruction >> 15) & 0x1F;
        int32_t imm   = (int32_t)instruction >> 20;
        int32_t imm_5_11 = imm >> 5;
        
        if(show_instruction){
            printf("rd: x%d, ", rd);
            printf("funct3: %d, ", funct3);
            printf("rs1: x%d, ", rs1);
            printf("imm: %d, ", imm);
        }

        switch (funct3)
        {
        case 0x0: 
            //addi
            cpu.registers[rd] = cpu.registers[rs1] + MSB_EXTEND(imm, 12);
            cpu.PC += 4;
            printf("addi\n");
            break;
        
        case 0x4:
            //xori
            cpu.registers[rd] = cpu.registers[rs1] ^ MSB_EXTEND(imm, 12);
            cpu.PC += 4;
            break;
            
        case 0x6:
            //ori
            cpu.registers[rd] = cpu.registers[rs1] | MSB_EXTEND(imm, 12);
            cpu.PC += 4;
            printf("ori\n");
            break;
        
        case 0x7:
            //andi
            cpu.registers[rd] = cpu.registers[rs1] & MSB_EXTEND(imm, 12);
            cpu.PC += 4;
            break;
        
        case 0x1:
            //slli
            cpu.registers[rd] = cpu.registers[rs1] << (imm & 0x1F);
            cpu.PC += 4;
            printf("slli\n");
            break;
        
        case 0x5:
            
            if(imm_5_11 == 0x00){
                //srli
                cpu.registers[rd] = cpu.registers[rs1] >> (imm & 0x1F);
                cpu.PC += 4;
                printf("srli\n");
                break;
            }else if(imm_5_11 == 0x20) {
                //srai
                cpu.registers[rd] = ((int32_t)cpu.registers[rs1]) >> ((int32_t)imm & 0x1F);
                cpu.PC += 4;
                printf("srai\n");
                break;
            }else{
                printf("Error\n");
                break;
            }
        
        case 0x2:
            //slti
            cpu.registers[rd] = ((int32_t)cpu.registers[rs1] < (int32_t)MSB_EXTEND(imm, 12))?1:0;
            cpu.PC += 4;
            printf("slti\n");
            break;

        case 0x3:
            //sltiu
            cpu.registers[rd] = (cpu.registers[rs1] < MSB_EXTEND(imm, 12))?1u:0u;
            cpu.PC += 4;
            printf("sltiu\n");
            break;
            
        default:
            
            break;
        }
    }
        break;
    
    case 0x3: {             //I-Type load
        uint32_t addr;
        uint32_t base_addr;
        uint8_t rd     = (instruction >> 7)  & 0x1F;
        uint8_t funct3 = (instruction >> 12) & 0x07;
        uint8_t rs1    = (instruction >> 15) & 0x1F;
        int16_t imm   = (int32_t)instruction >> 20;

        if(show_instruction){
            printf("rd: x%d, ", rd);
            printf("funct3: %d, ", funct3);
            printf("rs1: x%d, ", rs1);
            printf("imm: %d, ", imm);
        }

        switch (funct3)
        {
        case 0x0:
            //lb
            addr = cpu.registers[rs1] + MSB_EXTEND(imm, 12);
            if(addr < sizeof(cpu.data)){
                cpu.registers[rd] = SIGN_EXTEND(cpu.data[addr-DATA_RAM_OFFSET], 8);
                printf("lb\n");
            }else{
                printf("Load address out of bounds!\n");
            }
            cpu.PC += 4;
            break;

        case 0x1:
            //lh
            base_addr = cpu.registers[rs1] + MSB_EXTEND(imm, 12);

            if((base_addr + 1) < sizeof(cpu.data)){
                uint32_t half = SIGN_EXTEND(((uint16_t)cpu.data[base_addr-DATA_RAM_OFFSET]) | ((uint16_t)cpu.data[base_addr-DATA_RAM_OFFSET+1] << 8), 16);
                cpu.registers[rd] = half;
                printf("lh\n");
            }else{
                printf("Load address out of bounds!\n");
            }
            cpu.PC += 4;
            break;

        case 0x2:
            //lw
            base_addr = cpu.registers[rs1] + MSB_EXTEND(imm, 12);

            if((base_addr+3) < sizeof(cpu.data)){
                uint32_t word = SIGN_EXTEND((((uint32_t)cpu.data[base_addr-DATA_RAM_OFFSET])
                | ((uint32_t)cpu.data[base_addr-DATA_RAM_OFFSET+1] << 8) 
                | ((uint32_t)cpu.data[base_addr-DATA_RAM_OFFSET+2] << 16) 
                | ((uint32_t)cpu.data[base_addr-DATA_RAM_OFFSET+3] << 24)), 32);
                cpu.registers[rd] = word;
                printf("lw\n");
            }else{
                printf("Load address out of bounds\n");
            }
            cpu.PC += 4;
            break;
        
        case 0x4:
            //lbu
            addr = cpu.registers[rs1] + MSB_EXTEND(imm, 12);

            if(addr < sizeof(cpu.data)){
                cpu.registers[rd] = cpu.data[addr-DATA_RAM_OFFSET];
                printf("lbu\n");
            }else{
                printf("Load address out of bounds\n");
            }
            cpu.PC += 4;
            break;
        
        case 0x5:
            //lhu
            base_addr = cpu.registers[rs1] + MSB_EXTEND(imm, 12);

            if((base_addr+1) < sizeof(cpu.data)){
                cpu.registers[rd] = ((uint16_t)cpu.data[base_addr-DATA_RAM_OFFSET]) | ((uint16_t)cpu.data[base_addr-DATA_RAM_OFFSET+1] << 8);
                printf("lhu\n");
            }else{
                printf("Load address out of bounds\n");
            }
            cpu.PC += 4;
            break;

        default:
            break;
        }
        break;
    }
    case 0x23: {              //S-Type 
        uint32_t addr;
        uint8_t funct3 = (instruction >> 12) & 0x07;
        uint8_t rs1    = (instruction >> 15) & 0x1F;
        uint8_t rs2    = (instruction >> 20) & 0x1F;
        uint32_t imm2   = (instruction >> 25) & 0x7F;
        uint32_t imm1   = (instruction >> 7)  & 0x1F;
        uint32_t imm   = SIGN_EXTEND(imm1 | (imm2 << 5), 12);

        if(show_instruction){
            printf("funct3: %d, ", funct3);
            printf("rs1: x%d, ", rs1);
            printf("rs2: x%d, ", rs2);
            printf("imm: %d, ", imm);
        }
        
        switch (funct3)
        {
        case 0x0:
            //sb
            addr = cpu.registers[rs1] + imm;
            if(addr < sizeof(cpu.data)){
                cpu.data[addr-DATA_RAM_OFFSET] = cpu.registers[rs2] & 0xFF;
                printf("sb\n");
            }else{
                printf("Store address out of bounds\n");
            }
            cpu.PC += 4;
            break;
        
        case 0x1:
            //sh
            addr = cpu.registers[rs1] + imm;
            if((addr + 1) < sizeof(cpu.data)){
                cpu.data[addr-DATA_RAM_OFFSET] = cpu.registers[rs2] & 0xFF;
                cpu.data[addr-DATA_RAM_OFFSET+1] = (cpu.registers[rs2] >> 8) & 0xFF;
                printf("sh\n");
            }else{
                printf("Store address out of bounds\n");
            }
            cpu.PC += 4;
            break;
        case 0x2:
            //sw
            addr = cpu.registers[rs1] + imm;
            if((addr + 3) < sizeof(cpu.data)){
                cpu.data[addr-DATA_RAM_OFFSET] = cpu.registers[rs2] & 0xFF;
                cpu.data[addr-DATA_RAM_OFFSET+1] = (cpu.registers[rs2] >> 8) & 0xFF;
                cpu.data[addr-DATA_RAM_OFFSET+2] = (cpu.registers[rs2] >> 16) & 0xFF;
                cpu.data[addr-DATA_RAM_OFFSET+3] = (cpu.registers[rs2] >> 24) & 0xFF;
                printf("sw\n");
            }else{
                printf("Store address out of bounds\n");
            }
            cpu.PC += 4;
            break;

        default:
            break;
        }
        break;
    }
    case 0x63:{              //B-Type

        uint8_t funct3 = (instruction >> 12) & 0x07;
        uint8_t rs1    = (instruction >> 15) & 0x1F;
        uint8_t rs2    = (instruction >> 20) & 0x1F;
        
        uint32_t imm = (
        ((instruction >> 31) & 0x1) << 12 |   // imm[12]
        ((instruction >> 7) & 0x1) << 11 |    // imm[11]
        ((instruction >> 25) & 0x3f) << 5 |   // imm[10:5]
        ((instruction >> 8) & 0xf) << 1       // imm[4:1]
        );
        
        imm = SIGN_EXTEND(imm, 13);

        if(show_instruction){
            printf("funct3: %d, ", funct3);
            printf("rs1: x%d, ", rs1);
            printf("rs2: x%d, ", rs2);
            printf("imm: %d, ", imm);
        }

        switch (funct3)
        {
        case 0x0:
            //beq
            if(cpu.registers[rs1] == cpu.registers[rs2]){
                cpu.PC += imm;
                printf("beq\n");
            }else{
                printf("PC + imm < sizeof(cpu.program)\n");
                cpu.PC = cpu.PC + 4;
                printf("beq\n");
            }
            break;
        
        case 0x1:
            //bne
            if((cpu.registers[rs1] != cpu.registers[rs2])){
                cpu.PC += imm;
                printf("bne\n");
            }else{
                printf("PC + imm < sizeof(cpu.program)\n");
                cpu.PC = cpu.PC + 4;
                printf("bne\n");
            }
            break;
        
        case 0x4:
            //blt
            if(((int32_t)cpu.registers[rs1] < (int32_t)cpu.registers[rs2])){
                cpu.PC += imm;
                printf("blt\n");
            }else{
                printf("PC + imm < sizeof(cpu.program)\n");
                cpu.PC = cpu.PC + 4;
                printf("blt\n");
            }
            break;
        
        case 0x5:
            //bge
            if(((int32_t)cpu.registers[rs1] >= (int32_t)cpu.registers[rs2])){
                cpu.PC += imm;
                printf("bge\n");
            }else{
                printf("PC + imm < sizeof(cpu.program)\n");
                cpu.PC = cpu.PC + 4;
                printf("bge\n");
            }
            break;
        
        case 0x6:
            //bltu
            if(((uint32_t)cpu.registers[rs1] < (uint32_t)cpu.registers[rs2])){
                cpu.PC += imm;
                printf("bltu\n");  
            }else{
                printf("PC + imm < sizeof(cpu.program)\n");
                cpu.PC = cpu.PC + 4;
                printf("bltu\n");   
            }
            break;

        case 0x7:
            //bgeu
            if(((uint32_t)cpu.registers[rs1] >= (uint32_t)cpu.registers[rs2])){
                cpu.PC += imm;
                printf("bgeu\n");
            }else{
                printf("PC + imm < sizeof(cpu.program)\n");
                cpu.PC = cpu.PC + 4;
                printf("bgeu\n");
            }
            break;

        default:

            break;
        }
        break;
    }
    case 0x6F: {              //J-Type (jal only)
        
        uint8_t rd     = (instruction >> 7)  & 0x1F;
        
        int32_t imm = 0;
        imm |= ((instruction >> 31) & 0x1) << 20;
        imm |= ((instruction >> 21) & 0x3FF) << 1;
        imm |= ((instruction >> 20) & 0x1) << 11;
        imm |= ((instruction >> 12) & 0xFF) << 12;
        
        if (imm & 0x100000) {
            imm |= 0xFFE00000;
        }

        if(show_instruction){
            printf("rd: x%d, ", rd);
            printf("imm: %d, ", imm);
        }

        cpu.registers[rd] = cpu.PC +4;
        cpu.PC += imm;  
        printf("jal\n");  
        break;
    }
    case 0x67: {             //I-Type (jalr only)
        
        uint8_t rd     = (instruction >> 7)  & 0x1F;
        uint8_t funct3 = (instruction >> 12) & 0x07;
        uint8_t rs1    = (instruction >> 15) & 0x1F;
        uint16_t imm   = SIGN_EXTEND((instruction >> 20) & 0xFFF, 12) & ~1u;

        if(show_instruction){
            printf("rd: x%d, ", rd);
            printf("funct3: %d, ", funct3);
            printf("rs1: x%d, ", rs1);
            printf("imm: %d, ", imm);
        }

        cpu.registers[rd] = cpu.PC + 4;
        cpu.PC = cpu.registers[rs1] + imm;
        printf("jalr\n");
        break;
    }
    case 0x37: {             //U-Type (lui)

        uint8_t rd = (instruction >> 7) & 0x1F;
        uint32_t imm = instruction & 0xFFFFF000;

        if(show_instruction){
            printf("rd: x%d, ", rd);
            printf("imm: %d, ", imm);
        }

        cpu.registers[rd] = imm;
        cpu.PC += 4;
        printf("lui\n");
        break;
    }
    case 0x17: {             //U-Type (auipc)
        uint8_t rd = (instruction >> 7) & 0x1F;
        uint32_t imm20 = (instruction >> 12);
        uint32_t shifted = imm20 << 12;
        int32_t imm = SIGN_EXTEND(shifted, 32);

        if(show_instruction){
            printf("rd: x%d, ", rd);
            printf("imm: %d, ", imm);
        }

        cpu.registers[rd] = cpu.PC + imm;
        printf("auipc\n");
        cpu.PC += 4;
        break;
    }
    case 0x73:{             //I-Type (ecall and ebreak)
        uint32_t funct3 = (instruction >> 12) & 0x7;
        uint32_t funct7 = (instruction >> 20) & 0xFFF;
        
        if (funct7 == 0 && funct3 == 0) {  // ecall
            handle_ecall();
        } else {
            printf("ebreak, not implemented yet\n");
            cpu.PC += 4;
        }
        break;
    }
    }
}

static void handle_ecall(){
    uint32_t syscall_number = cpu.registers[17]; // a7
    switch (syscall_number)
    {
    case 64:
        
        break;
    
    default:
        break;
    }
}

static void show_registers(){
    printf(" Register | ABI Name | Value  \n");
    const char* abi_names[32] = {"  zero ", "  ra   ", "  sp   ", "  gp   ", "  tp   ", "  t0   ", "  t1   ", "  t2   ", "  s0/fp", "  s1   ", " a0   ",
                                 " a1   ", " a2   ", " a3   ", " a4   ", " a5   ", " a6   ", " a7   ", " s2   ", " s3   ", " s4   ", " s5   ", " s6   ",
                                 " s7   ", " s8   ", " s9   ", " s10  ", " s11  ", " t3   ", " t4   ", " t5   ", " t6   "};
    for(int i = 0; i<=31; i++){
        printf("    x%d     ",i);
        printf(" %s   ", abi_names[i]);
        printf("   %d  ", cpu.registers[i]);
        printf("\n");
    }
    printf("PC: %d, \n", cpu.PC);
}

int main() {
    
    for(int i = 0; i < 32; i++) {
        cpu.registers[i] = 0;
    }

    cpu.PC = 0;
    cpu.PC_next = 0;

   const uint32_t program[] = {
    0x00008137, 0x0c4000ef, 0x00000013, 0x00000013, 0x00000013,
    0x00000013, 0x00000013, 0x00000063, 0xfd010113, 0x02112623,
    0x02812423, 0x03212223, 0x03312023, 0x03010413, 0xfca42e23,
    0x00100713, 0x00000793, 0xfee42423, 0xfef42623, 0x00200793,
    0xfef42223, 0x0400006f, 0xfe442783, 0x00078913, 0x00000993,
    0x00090613, 0x00098693, 0xfe842503, 0xfec42583, 0x0b0000ef,
    0x00050713, 0x00058793, 0xfee42423, 0xfef42623, 0xfe442783,
    0x00178793, 0xfef42223, 0xfe442703, 0xfdc42783, 0xfae7fee3,
    0xfe842703, 0xfec42783, 0x00070513, 0x00078593, 0x02c12083,
    0x02812403, 0x02412903, 0x02012983, 0x03010113, 0x00008067,
    0xfd010113, 0x02112623, 0x02812423, 0x03010413, 0x00a00793,
    0xfcf42e23, 0xfdc42783, 0xfef42623, 0xfec42783, 0xfef42623,
    0xfec42503, 0xf2dff0ef, 0xfea42023, 0xfeb42223, 0x000047b7,
    0x0007a783, 0x00078513, 0xfe042783, 0x00078513, 0x02c12083,
    0x02812403, 0x03010113, 0x00008067, 0xff010113, 0x00068313,
    0x00112623, 0x00050e13, 0x00050693, 0x00060893, 0x00000713,
    0x00000793, 0x00000813, 0x0018fe93, 0x00171513, 0x000e8a63,
    0x01068833, 0x00e787b3, 0x00d83733, 0x00f707b3, 0x01f6d713,
    0x0018d893, 0x00e56733, 0x00169693, 0xfc089ae3, 0x00058863,
    0x00060513, 0x030000ef, 0x00a787b3, 0x00030a63, 0x000e0513,
    0x00030593, 0x01c000ef, 0x00f507b3, 0x00c12083, 0x00080513,
    0x00078593, 0x01010113, 0x00008067, 0x00050613, 0x00000513,
    0x0015f693, 0x00068463, 0x00c50533, 0x0015d593, 0x00161613,
    0xfe0596e3, 0x00008067
};

    memcpy(cpu.program, program, sizeof(program) < sizeof(cpu.program) ? sizeof(program) : sizeof(cpu.program));
    /* optional: zero remaining bytes (not required) */
    if (sizeof(program) < sizeof(cpu.program)) {
        memset(cpu.program + sizeof(program), 0, sizeof(cpu.program) - sizeof(program));
    }

    int steps = 0;
    bool halt = false;

    while(!halt) {
        printf("How many steps? (0 to quit): ");
        scanf("%d", &steps);
        if(steps == 0) break;

        for(int s = 0; s < steps; s++) {
            cpu.registers[0] = 0;
            uint32_t instruction = fetch(cpu.PC);
            if(instruction == 0) { 
                halt = true;
                break;
            }
            decodeAndExecute(instruction);
        }
        show_registers();
    }
    show_registers();
    return 0;
}

//single step function or x step function       
//show all registers with multiple names and values eg.  
//
//    Register | ABI Name | value 
//      x0,    |   zero   |   0 
//      x1,    |    ra    |   x
//      x2,    |    sp    |   x
//      x3,    |    gp    |   x
//      x4,    |    tp    |   x
//      x5,    |    t0    |   x
//      x6,    |    t1    |   x
//      x7,    |    t2    |   x
//      x8,    |   s0/fp  |   x
//      x9,    |    s1    |   x
//      x10,   |    a0    |   x
//      x11,   |    a1    |   x
//      x12,   |    a2    |   x
//      x13,   |    a3    |   x
//      x14,   |    a4    |   x
//      x15,   |    a5    |   x
//      x16,   |    a6    |   x
//      x17,   |    a7    |   x
//      x18,   |    s2    |   x
//      x19,   |    s3    |   x
//      x20,   |    s4    |   x
//      x21,   |    s5    |   x
//      x22,   |    s6    |   x
//      x23,   |    s7    |   x
//      x24,   |    s8    |   x
//      x25,   |    s9    |   x
//      x26,   |   s10    |   x
//      x27,   |   s11    |   x
//      x28,   |    t3    |   x
//      x29,   |    t4    |   x
//      x30,   |    t5    |   x
//      x31,   |    t6    |   x
//      PC: x, PC_next: x
