/* boot.S — RV32 Startup/Boot Code
 *
 * Aufgaben:
 *  - Stack setzen
 *  - .data aus LMA (im TEXT) nach VMA (im DATA) kopieren
 *  - .bss nullen
 *  - optional: main() aufrufen, danach Endlosschleife
 *
 * Erwartete Linker-Symbole (aus dem Linker-Skript):
 *  __stack_top
 *  __data_load_start, __data_start, __data_end
 *  __bss_start, __bss_end
 */

    .section .init
    .globl _start
    .type  _start, @function

_start:
    /* Stackpointer initialisieren */
    la      sp, __stack_top

    /* ------------------------------------------------------------ */
    /* .data kopieren: src = __data_load_start (TEXT),              */
    /*              dst = __data_start (DATA), end = __data_end     */
    /* ------------------------------------------------------------ */
    la      a0, __data_load_start   /* src */
    la      a1, __data_start        /* dst */
    la      a2, __data_end          /* end */

1:  beq     a1, a2, 2f              /* fertig, wenn dst == end */
    lw      t0, 0(a0)
    sw      t0, 0(a1)
    addi    a0, a0, 4
    addi    a1, a1, 4
    j       1b

2:  /* ------------------------------------------------------------ */
    /* .bss nullen                                                  */
    /* ------------------------------------------------------------ */
    la      a0, __bss_start
    la      a1, __bss_end
    li      t0, 0

3:  beq     a0, a1, 4f
    sw      t0, 0(a0)
    addi    a0, a0, 4
    j       3b

4:  /* ------------------------------------------------------------ */
    /* Optional: C-Runtime init / main                              */
    /* ------------------------------------------------------------ */
    .option push
    .option norelax
    la      gp, __global_pointer$   /* falls Toolchain GP nutzt */
    .option pop

    /* Falls libc/newlib genutzt wird: call __libc_init_array */
    /* call    __libc_init_array */

    /* main() aufrufen */
    call    main

    /* Wenn main zurückkehrt: Endlosschleife */
5:  wfi
    j       5b

    .size _start, . - _start


/* Optional: global pointer Symbol bereitstellen, falls nicht vorhanden.
 * Normalerweise kommt __global_pointer$ aus dem Linker/ABI, ggf. entfernen,
 * wenn die Toolchain es bereits liefert oder du kein -msmall-data nutzt.
 */
    .section .text
    .globl __global_pointer$
__global_pointer$:
    .word 0
