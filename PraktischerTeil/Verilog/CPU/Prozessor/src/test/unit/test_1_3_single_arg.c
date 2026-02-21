#include "common.h"

uint32_t add_one(uint32_t x) {
    return x + 1;
}

int main() {
    uint32_t result = add_one(5);
    if (result == 6) {
        signal_result(PASS);
    } else {
        signal_result(FAIL);
    }
    return 0;
}
