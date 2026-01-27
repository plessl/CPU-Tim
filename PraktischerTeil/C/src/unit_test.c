#include <stdio.h>
#include <stdint.h>
#include <assert.h>

#include <stdint.h>

/*int32_t j_imm(uint32_t instruction) {
    int32_t immediate = 0;
    immediate |= ((instruction >> 31) & 0x1) << 20;
    immediate |= ((instruction >> 21) & 0x3FF) << 1;
    immediate |= ((instruction >> 20) & 0x1) << 11;
    immediate |= ((instruction >> 12) & 0xFF) << 12;
    if (immediate & 0x100000) {
        immediate |= 0xFFE00000;
    }

    return immediate;
}*/

int32_t j_imm(uint32_t instruction){
    int32_t imm   = (int32_t)instruction >> 20;
    return imm;
}


void test_j_imm() {
    struct {
        uint32_t instr;
        int32_t expected;
    } tests[] = {
        {0x400002ef, 1024},   // jal x5, 0x400
        {0x000002ef, 0},      // jal x0, 0
        {0xfd1ff2ef, -48},    // jal x0, -48
    };

    for (int i = 0; i < sizeof(tests)/sizeof(tests[0]); i++) {
        int32_t imm = j_imm(tests[i].instr);
        printf("Test %d: got %d, expected %d\n", i, imm, tests[i].expected);
        assert(imm == tests[i].expected);
    }

    printf("✅ All tests passed!\n");
}

int main() {
    test_j_imm();
    return 0;
}