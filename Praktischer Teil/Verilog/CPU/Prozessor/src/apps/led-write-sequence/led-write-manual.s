/*

riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -nostartfiles -Tlink.x -o led-red-asm.elf led-red-asm.s
riscv64-unknown-elf-objcopy -O binary -j .text led-red-asm.elf led-red-asm.bin
hexdump -v -e '1/4 "%08x\n"' led-red-asm.bin > led-red-asm.mi
cp led-red-asm.mi rom.mi

riscv64-unknown-elf-objdump -M numeric,no-aliases --disassemble-all led-red-asm.elf

*/

.equ FB_BASE_ADR, 0x00020000
.equ COL_RED, 0x4
.equ COL_GREEN, 0x2
.equ COL_BLUE, 0x1

.globl _start

_start:

li x1,FB_BASE_ADR     # laod base framebuffer base address
li x3, COL_GREEN       # Load immediate value for red LED bit mask

sw x3, 0(x2)
sw x3, 4(x2)
sw x3, 8(x2)
sw x3, 12(x2)

j _start               # Infinite loop
