#include "common.h"

uint32_t add_two(uint32_t a, uint32_t b) {
    uint32_t local = a + b;
    return local;
}

int main() {
    uint32_t result = add_two(3, 4);
    if (result == 7) {
        signal_result(PASS);
    } else {
        signal_result(FAIL);
    }
    return 0;
}
