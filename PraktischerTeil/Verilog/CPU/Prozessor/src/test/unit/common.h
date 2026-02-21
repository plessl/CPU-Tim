#ifndef COMMON_H
#define COMMON_H

#include <stdint.h>

#define MAGIC_ADDR 0x0001FFFC
#define PASS 1
#define FAIL 0xDEADBEEF

static inline void signal_result(uint32_t result) {
    volatile uint32_t *p = (volatile uint32_t *)MAGIC_ADDR;
    *p = result;
    while(1);  // Halt
}

#endif // COMMON_H
