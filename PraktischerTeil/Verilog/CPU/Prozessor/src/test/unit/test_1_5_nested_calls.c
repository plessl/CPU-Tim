#include "common.h"

uint32_t inner() {
    return 42;
}

uint32_t outer() {
    return inner();
}

int main() {
    uint32_t result = outer();
    if (result == 42) {
        signal_result(PASS);
    } else {
        signal_result(FAIL);
    }
    return 0;
}
