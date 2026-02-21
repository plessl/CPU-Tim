#include "common.h"

volatile uint32_t array[4] = {1, 2, 3, 4};

int main() {
    uint32_t sum = array[0] + array[1] + array[2] + array[3];
    if (sum == 10) {
        signal_result(PASS);
    } else {
        signal_result(FAIL);
    }
    return 0;
}
