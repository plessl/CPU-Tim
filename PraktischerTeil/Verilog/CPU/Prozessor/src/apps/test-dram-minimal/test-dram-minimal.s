
.equ RAM_BASE_ADR, 0x00010000

.globl _start

_start:

li x1,RAM_BASE_ADR
addi x2, x0, 42
sw x2, 0(x1)         # Write 42 at RAM_BASE_ADR
lw x3, 0(x1)         # Read back from RAM_BASE_ADR

