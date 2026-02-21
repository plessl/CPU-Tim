#include "common.h"

volatile uint32_t global;

int main() {
    global = 0xCAFEBABE;
    if (global == 0xCAFEBABE) {
        signal_result(PASS);
    } else {
        signal_result(FAIL);
    }
    return 0;
}
