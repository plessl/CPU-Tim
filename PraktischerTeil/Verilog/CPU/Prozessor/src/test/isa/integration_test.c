#include <stdint.h>

#define MAGIC_ADDR 0x0001FFFC
#define PASS 1
#define FAIL 0xDEADBEEF

volatile uint32_t global_var = 0x12345678;
volatile uint32_t bss_var;

void signal_result(uint32_t result) {
    volatile uint32_t *p = (volatile uint32_t *)MAGIC_ADDR;
    *p = result;
}

// Recursive function to test stack and function calls
// Using addition instead of multiplication since M-extension is not supported
uint32_t sum_recursive(uint32_t n) {
    if (n == 0) return 0;
    return n + sum_recursive(n - 1);
}

// Function with many arguments to test stack spilling
uint32_t sum_many(uint32_t a, uint32_t b, uint32_t c, uint32_t d, uint32_t e, uint32_t f, uint32_t g, uint32_t h, uint32_t i) {
    return a + b + c + d + e + f + g + h + i;
}

int main() {
    // 1. Test Global Variable Access (.data)
    if (global_var != 0x12345678) {
        signal_result(FAIL);
        while(1);
    }

    // 2. Test Global Variable Access (.bss)
    bss_var = 0x87654321;
    if (bss_var != 0x87654321) {
        signal_result(FAIL);
        while(1);
    }

    // 3. Test Function Calls and Recursion
    if (sum_recursive(5) != 15) {
        signal_result(FAIL);
        while(1);
    }

    // 4. Test Stack Spilling
    if (sum_many(1, 2, 3, 4, 5, 6, 7, 8, 9) != 45) {
        signal_result(FAIL);
        while(1);
    }

    signal_result(PASS);
    while(1);
    return 0;
}
