# Verification Plan: RISC-V RV32I Core

## Objective
To systematically validate the RV32I instruction set implementation, specifically targeting issues with function calls (stack/linkage) and global variable access (data section/GP-relative addressing).

## Verification Strategy

### 1. Unit Testing (Instruction Level)
Each instruction category will have a dedicated assembly test file:
- **Arithmetic/Logic**: `addi`, `add`, `sub`, `sll`, `slt`, `sltu`, `xor`, `srl`, `sra`, `or`, `and`.
- **Load/Store**: `lb`, `lh`, `lw`, `lbu`, `lhu`, `sb`, `sh`, `sw`.
- **Control Flow**: `beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu`, `jal`, `jalr`.
- **Upper Immediates**: `lui`, `auipc`.

### 2. Integration Testing (C-Level)
Targeted C programs to verify compiler-generated patterns:
- **Function Calls**: Deeply nested calls, recursive calls (verifies `sp` and `ra` handling).
- **Global Variables**: Accessing variables in `.data` and `.bss` (verifies `gp` and absolute addressing).
- **Pointer Arithmetic**: Verifies complex address calculations.

### 3. Simulation Environment
- **Tool**: Icarus Verilog (`iverilog`).
- **Testbench**: `test/tb_comprehensive.sv`.
- **Golden Model**: 
    - We will use a "Self-Checking" approach where the assembly/C code itself verifies the result and writes a success/failure code to a specific memory address (e.g., `0x0001_FFFC`).
    - **Recommendation**: I recommend using **Spike** (the official RISC-V ISA simulator) or **QEMU** as a golden model if we need to compare execution traces (PC and register state) cycle-by-cycle.
    - **Alternative**: **Whisper** (from Western Digital) is also a very fast and accurate ISA simulator for RV32I.

## Tooling Requirements
- **riscv64-unknown-elf-gcc**: For compilation and assembly.
- **Icarus Verilog**: For RTL simulation.
- **Surfer**: For waveform analysis (replaces GTKWave).
- **Spike (Optional)**: For golden model trace generation.
- **riscv-tests (Optional)**: We can port the official RISC-V architectural tests to our memory map for maximum coverage.

## Testbench Design (`test/tb_comprehensive.sv`)
- Load `.mi` files into ROM.
- Monitor memory writes to a "Magic Address" for pass/fail status.
- Timeout mechanism to catch infinite loops.
- Trace dumping to `.vcd` for debugging in GTKWave.

## Execution Workflow
1. Write test case (Assembly or C).
2. Compile using `riscv64-unknown-elf-gcc`.
3. Generate `.mi` file.
4. Run Icarus Verilog simulation.
5. Check "Magic Address" for result.
