/* boot.s - RV32I bare-metal startup (no traps, no SystemInit, no interrupts) */

    .option norvc
    .section .text.startup
    .globl _start
    .type  _start, @function

_start:
    /* Set up stack */
    la      sp, __stack_top

    /* Set up global pointer (for small data) */
    .option push
    .option norelax
    la      gp, __global_pointer$
    .option pop

    /* Copy .data from ROM image to RAM */
    la      a0, __data_load      /* src (ROM) */
    la      a1, __data_start     /* dst (RAM) */
    la      a2, __data_end       /* end */
1:
    beq     a1, a2, 2f
    lw      t0, 0(a0)
    sw      t0, 0(a1)
    addi    a0, a0, 4
    addi    a1, a1, 4
    j       1b
2:

    /* Zero .bss */
    la      a1, __bss_start
    la      a2, __bss_end
3:
    beq     a1, a2, 4f
    sw      zero, 0(a1)
    addi    a1, a1, 4
    j       3b
4:

    /* Optional: clear framebuffer */
    /*
    la      a1, __fb_start
    la      a2, __fb_end
5:
    beq     a1, a2, 6f
    sw      zero, 0(a1)
    addi    a1, a1, 4
    j       5b
6:
    */

    /* Call main */
    call    main

    /* If main returns, spin forever */
hang:
    j       hang

    .size _start, . - _start
    