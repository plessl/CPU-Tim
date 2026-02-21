#include "common.h"

uint32_t get_value() {
    return 0x12345678;
}

int main() {
    uint32_t result = get_value();
    if (result == 0x12345678) {
        signal_result(PASS);
    } else {
        signal_result(FAIL);
    }
    return 0;
}
