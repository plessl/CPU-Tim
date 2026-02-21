#include "common.h"

volatile uint32_t global = 0xDEADBEEF;

int main() {
    if (global == 0xDEADBEEF) {
        signal_result(PASS);
    } else {
        signal_result(FAIL);
    }
    return 0;
}
