#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <stdint.h>

#define SIGN_EXTEND(val, bits) (((int32_t)(val) << (32 - (bits))) >> (32 - (bits)))

void reset_cpu();  // Forward declaration

void test_i_type_imm() {
    printf("Testing I-type immediates...\n");
    
    struct {
        uint32_t instr;
        int32_t expected;
        const char* desc;
    } cases[] = {
        {0x00000013, 0,     "addi x0, x0, 0"},      // Zero
        {0x00100093, 1,     "addi x1, x0, 1"},      // Small positive
        {0xFFF00093, -1,    "addi x1, x0, -1"},     // Small negative
        {0x7FF00093, 2047,  "addi x1, x0, 2047"},   // Max positive
        {0x80000093, -2048, "addi x1, x0, -2048"},  // Max negative
    };
    
    for(size_t i = 0; i < sizeof(cases)/sizeof(cases[0]); i++) {
        int32_t imm = (int32_t)(cases[i].instr) >> 20;
        printf("Test %s: expected=%d, got=%d\n", cases[i].desc, cases[i].expected, imm);
        assert(imm == cases[i].expected);
    }
    printf("I-type immediate tests passed\n");
}

void test_s_type_imm() {
    printf("Testing S-type immediates...\n");
    
    struct {
        uint32_t instr;
        int32_t expected;
        const char* desc;
    } cases[] = {
        {0x00012023, 0,     "sw x0, 0(x2)"},     // Zero offset
        {0x00112023, 1,     "sw x1, 1(x2)"},     // Small positive
        {0xFE112FA3, -1,    "sw x1, -1(x2)"},    // Small negative
        {0x7FF12023, 2047,  "sw x1, 2047(x2)"},  // Max positive
        {0x80012023, -2048, "sw x1, -2048(x2)"}, // Max negative
    };
    
    for(size_t i = 0; i < sizeof(cases)/sizeof(cases[0]); i++) {
        uint32_t imm_11_5 = (cases[i].instr >> 25) & 0x7F;
        uint32_t imm_4_0 = (cases[i].instr >> 7) & 0x1F;
        int32_t imm = (imm_11_5 << 5) | imm_4_0;
        if (imm_11_5 & 0x40) imm |= 0xFFFFF000;
        
        printf("Test %s: expected=%d, got=%d\n", cases[i].desc, cases[i].expected, imm);
        assert(imm == cases[i].expected);
    }
    printf("S-type immediate tests passed\n");
}

void test_b_type_imm() {
    printf("Testing B-type immediates...\n");
    
    struct {
        uint32_t instr;
        int32_t expected;
        const char* desc;
    } cases[] = {
        {0x00058063, 0,    "beq x11, x0, 0"},     // Zero offset
        {0x00058463, 8,    "beq x11, x0, 8"},     // Small positive
        {0xFE058EE3, -4,   "beq x11, x0, -4"},    // Small negative
        {0x7FE58063, 2046, "beq x11, x0, 2046"},  // Large positive
        {0x80058063, -2048,"beq x11, x0, -2048"}, // Max negative
    };
    
    for(size_t i = 0; i < sizeof(cases)/sizeof(cases[0]); i++) {
        uint32_t instr = cases[i].instr;
        int32_t imm = (((instr >> 31) & 0x1) << 12) |
                      (((instr >> 7) & 0x1) << 11) |
                      (((instr >> 25) & 0x3F) << 5) |
                      (((instr >> 8) & 0xF) << 1);
        if (instr & 0x80000000) imm |= 0xFFFFE000;
        
        printf("Test %s: expected=%d, got=%d\n", cases[i].desc, cases[i].expected, imm);
        assert(imm == cases[i].expected);
    }
    printf("B-type immediate tests passed\n");
}

void test_u_type_imm() {
    printf("Testing U-type immediates...\n");
    
    struct {
        uint32_t instr;
        uint32_t expected;
        const char* desc;
    } cases[] = {
        {0x00000037, 0x00000000, "lui x0, 0"},
        {0x000FF037, 0x000FF000, "lui x0, 0xFF"},
        {0xFFFFF037, 0xFFFFF000, "lui x0, 0xFFFFF"},
        {0x80000037, 0x80000000, "lui x0, 0x80000"},
    };
    
    for(size_t i = 0; i < sizeof(cases)/sizeof(cases[0]); i++) {
        uint32_t imm = cases[i].instr & 0xFFFFF000;
        printf("Test %s: expected=0x%08x, got=0x%08x\n", cases[i].desc, cases[i].expected, imm);
        assert(imm == cases[i].expected);
    }
    printf("U-type immediate tests passed\n");
}

void test_j_type_imm() {
    printf("Testing J-type immediates...\n");
    
    struct {
        uint32_t instr;
        int32_t expected;
        const char* desc;
    } cases[] = {
        {0x0000006F, 0,      "jal x0, 0"},        // Zero offset
        {0x0040006F, 4,      "jal x0, 4"},        // Small positive
        {0xFFFFF06F, -4,     "jal x0, -4"},       // Small negative
        {0x7FFFF06F, 0xFFFFE,"jal x0, 0xFFFFE"},  // Max positive
        {0x80000067, -524288,"jal x0, -524288"},  // Max negative
    };
    
    for(size_t i = 0; i < sizeof(cases)/sizeof(cases[0]); i++) {
        uint32_t instr = cases[i].instr;
        int32_t imm = (((instr >> 31) & 0x1) << 20) |
                      (((instr >> 12) & 0xFF) << 12) |
                      (((instr >> 20) & 0x1) << 11) |
                      (((instr >> 21) & 0x3FF) << 1);
        if (instr & 0x80000000) imm |= 0xFFE00000;
        
        printf("Test %s: expected=%d, got=%d\n", cases[i].desc, cases[i].expected, imm);
        assert(imm == cases[i].expected);
    }
    printf("J-type immediate tests passed\n");
}

int main() {
    printf("Running immediate decoding tests...\n");
    
    test_i_type_imm();
    test_s_type_imm();
    test_b_type_imm();
    test_u_type_imm();
    test_j_type_imm();
    
    printf("All immediate decoding tests passed!\n");
    return 0;
}
