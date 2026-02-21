#!/bin/sh

APP=main

riscv64-unknown-elf-gcc \
  -march=rv32i -mabi=ilp32 \
  -ffreestanding -nostdlib -static \
  -fno-pic -fno-pie \
  -fdata-sections -ffunction-sections \
  -O2 \
  -Wl,-T,link.ld \
  -Wl,--gc-sections \
  -Wall -Wextra \
  -g \
  boot.s ${APP}.c \
  -o ${APP}.elf

riscv64-unknown-elf-objcopy -O binary ${APP}.elf ${APP}.bin
hexdump -v -e '1/4 "%08x\n"' ${APP}.bin > ${APP}.mi
riscv64-unknown-elf-objdump -S --disassemble-all ${APP}.elf > ${APP}.disasm
cp ${APP}.mi rom.mi

