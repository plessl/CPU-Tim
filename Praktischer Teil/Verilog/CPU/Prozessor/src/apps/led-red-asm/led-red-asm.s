/*

riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -nostartfiles -Tlink.x -o led-red-asm.elf led-red-asm.s
riscv64-unknown-elf-objcopy -O binary -j .text led-red-asm.elf led-red-asm.bin
hexdump -v -e '1/4 "%08x\n"' led-red-asm.bin > led-red-asm.mi

riscv64-unknown-elf-objdump -M numeric,no-aliases --disassemble-all led-red-asm.elf

*/

.equ FB_BASE_ADR, 0x00020000
.equ COL_RED, 0x4
.equ COL_GREEN, 0x2
.equ COL_BLUE, 0x1

.globl _start

li x1,FB_BASE_ADR     # laod base framebuffer base address
li x3, COL_GREEN       # Load immediate value for red LED bit mask

_start:

li  x2, 4096         # framebuffer has 4096 elements (64x64 pixel display)
sll x2, x2, 2        # each element is 4 bytes (32 bits)
add x2, x2, x1       # x2 points to the end of the LED control area
addi x2, x2, -4      # x2 points to the last valid address

loop:
    sw x3, 0(x2)       # Store red LED value at the current address
    addi x2, x2, -4    # Decrement pointer by 4 bytes
    bne x2, x1, loop   # Repeat until all 4096 addresses are written

j _start               # Infinite loop
