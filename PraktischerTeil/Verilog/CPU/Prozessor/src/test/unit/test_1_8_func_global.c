#include "common.h"

volatile uint32_t counter = 0;

void increment() {
    counter++;
}

int main() {
    increment();
    if (counter == 1) {
        signal_result(PASS);
    } else {
        signal_result(FAIL);
    }
    return 0;
}
