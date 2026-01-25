#!/bin/sh

APP=test-dram-minimal
CFLAGS="-march=rv32i -mabi=ilp32 -nostdlib -nostartfiles -Tlink.x"
riscv64-unknown-elf-gcc ${CFLAGS} -o ${APP}.elf ${APP}.s
riscv64-unknown-elf-objcopy -O binary -j .text ${APP}.elf ${APP}.bin
hexdump -v -e '1/4 "%08x\n"' ${APP}.bin > ${APP}.mi
cp ${APP}.mi rom.mi

#riscv64-unknown-elf-objdump -M numeric,no-aliases --disassemble-all test-dram-minimal.elf