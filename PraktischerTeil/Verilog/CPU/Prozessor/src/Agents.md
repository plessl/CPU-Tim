# AGENTS.md - AI Assistant Context Guide

This document provides comprehensive context about the RISC-V RV32I FPGA Core project to help AI assistants understand the architecture, components, and development workflow.

---

## Project Overview

**Project Name**: RISC-V RV32I FPGA Core  
**Target Hardware**: Gowin GW5A-LV25MG121C1/I0 FPGA (SIPEED Prime 25k evaluation board)  
**Language**: SystemVerilog (hardware), C and Assembly (applications)  
**ISA**: RISC-V RV32I (User-mode, **NO M-extension** - no hardware multiply/divide)

### Purpose
A complete RISC-V processor implementation with integrated peripherals (LED matrix controller, SPI game controller interface) designed for educational purposes and embedded graphics applications.

---

## System Architecture

### CPU Core
- **Implementation**: 6-stage multi-cycle Finite State Machine (FSM)
- **Instruction Set**: RV32I base integer instruction set only
- **Pipeline Stages**:
  1. `FETCH` - Fetch instruction from ROM
  2. `DECODE` - Decode instruction and prepare immediates
  3. `EXECUTE` - Perform ALU operations or calculate addresses
  4. `MEMORY1` - Initiate memory access (RAM, Framebuffer, SPI)
  5. `MEMORY2` - Complete memory access and sample read data
  6. `WRITEBACK` - Write result to register file

### Memory Map

| Address Range | Device | Description | Access |
|---------------|--------|-------------|--------|
| `0x0000_0000` - `0x0000_FFFF` | **ROM (imem)** | Instruction Memory | 64KB, Read-only |
| `0x0001_0000` - `0x0001_FFFF` | **RAM (dmem)** | Data Memory | 64KB, Read/Write, 2-cycle latency |
| `0x0002_0000` - `0x0002_FFFF` | **Framebuffer** | LED Matrix Buffer | 64x64 pixels, Memory-mapped |
| `0x0003_0000` - `0x0003_FFFF` | **SPI Controller** | Dualshock 2 Interface | 16-bit controller state |

### Peripherals

#### 1. LED Matrix Controller
- **Display**: 64x64 pixel HUB75E-compatible LED matrix
- **Framebuffer**: Dual-ported RAM (CPU writes, controller reads simultaneously)
- **Color Depth**: 3 bits per pixel (mapped to `dout_a` and `dout_b` signals)
- **Interface**: Memory-mapped at `0x0002_0000`

#### 2. SPI Controller
- **Device**: PS2 Dualshock 2 game controller
- **Operation**: Continuous polling
- **Data Format**: 16-bit register with button states
- **Interface**: Memory-mapped at `0x0003_0000`
- **Button Mapping**: Active-high in software (hardware inverts active-low signals)

---

## Project Structure

```
src/
├── cpu.sv                      # Main SystemVerilog file (CPU + peripherals)
├── README.md                   # Project documentation
├── PINOUT.md                   # FPGA pin assignments
├── Makefile                    # Build automation
├── boot.s                      # Boot code
├── link.x                      # Linker script
├── Logbook-Captain.md          # Development log
├── Agents.md                   # This file
│
├── apps/                       # Application programs
│   ├── spinning-cube/          # 3D wireframe cube demo
│   ├── snake-simple/           # Snake game
│   ├── bouncing_cube/          # Bouncing cube animation
│   ├── led-*/                  # LED test programs
│   └── test-*/                 # Hardware test programs
│
├── test/                       # Verification suite
│   ├── unit/                   # Unit tests (9 tests for function calls/memory)
│   ├── isa/                    # ISA integration tests
│   ├── tb_debug.sv             # Enhanced testbench with tracing
│   ├── tb_comprehensive.sv     # Comprehensive testbench
│   ├── run_all_tests.sh        # Automated test runner
│   └── README.md               # Test documentation
│
├── plans/                      # Design documentation
│   ├── README.md               # Documentation index
│   ├── QUICKSTART.md           # Quick start guide
│   ├── architecture.md         # System architecture
│   ├── debugging_plan.md       # Debugging strategy
│   ├── automation_guide.md     # Test automation details
│   ├── verification_plan.md    # Verification strategy
│   └── verification_guide.md   # Verification instructions
│
├── bin/                        # Utility scripts
├── gowin_clkdiv/              # Clock divider IP
└── *.cst, *.sdc, *.rao        # FPGA synthesis constraints
```

---

## Key Files Reference

### Hardware
- [`cpu.sv`](cpu.sv) - Complete CPU implementation with FSM, memory modules, and peripherals
- [`Prozessor.cst`](Prozessor.cst) - Physical constraints for FPGA synthesis
- [`PINOUT.md`](PINOUT.md) - Pin assignments for LED matrix, SPI controller, and board I/O

### Documentation
- [`README.md`](README.md) - Main project documentation
- [`plans/README.md`](plans/README.md) - Documentation index and debugging workflow
- [`plans/QUICKSTART.md`](plans/QUICKSTART.md) - **START HERE** for debugging
- [`plans/architecture.md`](plans/architecture.md) - Detailed system architecture
- [`test/README.md`](test/README.md) - Test suite documentation

### Build System
- [`Makefile`](Makefile) - Simulation and schematic generation
- [`link.x`](link.x) - Linker script for memory layout
- [`boot.s`](boot.s) - Boot code and startup routine

---

## Development Workflow

### 1. Building Applications

Applications use the RISC-V GCC toolchain:

```bash
cd apps/spinning-cube/
just build          # Compile application
just install        # Copy ROM/RAM files to parent directory
```

**Toolchain**: `riscv64-unknown-elf-gcc`  
**Target**: `-march=rv32i -mabi=ilp32` (NO M-extension)  
**Optimization**: `-Og` (debug-friendly) or `-O2` (performance)

**Build Outputs**:
- `*.elf` - Executable with debug symbols
- `*.bin` - Raw binary
- `*.mi` - Memory initialization file (hexadecimal)
- `*.disasm` - Disassembly listing

### 2. Simulation

```bash
# Basic simulation
make sim

# With debug tracing
iverilog -g2012 -DENABLE_TRACE -o test.vvp cpu.sv test/tb.sv
vvp test.vvp

# Generate waveforms
iverilog -g2012 -o test.vvp cpu.sv test/tb.sv
vvp test.vvp
gtkwave test.vcd    # or use surfer
```

### 3. Verification

```bash
cd test/
./run_all_tests.sh                              # Run all unit tests
./run_all_tests.sh --continue-from test_1_4_*   # Resume from specific test
```

**Test Suite**:
- 9 unit tests for function calls and memory access
- Integration tests for ISA compliance
- Automated test runner with detailed reporting

### 4. Debugging

**Enable Trace Output**:
```bash
iverilog -g2012 -DENABLE_TRACE -o test.vvp cpu.sv test/tb_debug.sv
vvp test.vvp
```

**Trace Output Includes**:
- Instruction disassembly for each executed instruction
- Memory operations (loads/stores to RAM, framebuffer, SPI)
- SPI controller reads
- Framebuffer writes with addresses and data
- Illegal instruction detection

**Waveform Analysis**:
- Use GTKWave or Surfer to view `test.vcd`
- Saved state available in [`surfer-state`](surfer-state)

---

## Critical Implementation Details

### 1. Memory Timing

**RAM (dmem)**:
- **Read Latency**: 2 cycles
- **Write Latency**: 1 cycle
- **FSM Handling**: `MEMORY1` initiates access, `MEMORY2` samples read data
- **Critical**: Control signals (`ce`, `re`, `we`) must be stable for required duration

**ROM (imem)**:
- **Read Latency**: 1 cycle
- **Access**: Synchronous, addressed by PC

### 2. Function Call ABI

**Register Convention** (RISC-V calling convention):
- `a0-a7` (x10-x17): Arguments and return values
- `ra` (x1): Return address
- `sp` (x2): Stack pointer
- `s0-s11` (x8-x9, x18-x27): Saved registers

**Stack Management**:
- Stack grows downward (decreasing addresses)
- Frame pointer: `s0` (optional)
- Return address saved on stack for nested calls

### 3. Known Issues & Limitations

**Current Issues** (see [`plans/debugging_plan.md`](plans/debugging_plan.md)):
- RAM module 2-cycle latency may not be properly handled by FSM
- Signal timing for control signals needs verification
- Function call stack pointer and return address management
- Global variable access (`.data` and `.bss` sections)

**Planned Enhancements**:
- Reduce RAM access latency to 1 cycle
- Remove MEM2 stage when all memory is 1-cycle latency
- Add support for reading program memory (constants in ROM)
- M-Extension support (hardware multiply/divide)
- Interrupt support (machine-mode)

### 4. No Hardware Multiply/Divide

**Important**: The CPU does NOT support the M-extension. Applications must:
- Use software multiplication (shift-and-add)
- Use software division (iterative subtraction)
- Use lookup tables for trigonometry
- Use fixed-point arithmetic instead of floating-point

**Verification**:
```bash
grep -E "^\s+[0-9a-f]+:\s+[0-9a-f]+\s+(mul|div|rem)" app.disasm
# Should return no results
```

---

## Common Tasks for AI Assistants

### Task 1: Debugging Function Calls

**Context**: Function calls may fail due to RAM timing or stack management issues.

**Approach**:
1. Read [`plans/QUICKSTART.md`](plans/QUICKSTART.md)
2. Run unit tests: `cd test && ./run_all_tests.sh`
3. Identify failing test (e.g., `test_1_4_stack_usage`)
4. Examine waveform: `surfer results_*/test_*.vcd`
5. Review disassembly: `less test/unit/test_*.disasm`
6. Check RAM timing in [`cpu.sv`](cpu.sv) FSM states `MEMORY1` and `MEMORY2`
7. Fix and retest

**Key Files**:
- [`cpu.sv`](cpu.sv) - FSM implementation
- [`test/unit/`](test/unit/) - Unit test source files
- [`plans/debugging_plan.md`](plans/debugging_plan.md) - Detailed analysis

### Task 2: Creating New Applications

**Context**: Applications target RV32I without M-extension.

**Approach**:
1. Create directory in [`apps/`](apps/)
2. Copy [`boot.s`](apps/spinning-cube/boot.s) and [`link.ld`](apps/spinning-cube/link.ld)
3. Write C code (no multiply/divide/modulo)
4. Create `justfile` or `build.sh` for compilation
5. Build: `just build`
6. Install: `just install` (copies to parent directory)
7. Simulate: `cd ../.. && make sim`

**Example**: See [`apps/spinning-cube/`](apps/spinning-cube/) for complex application

### Task 3: Adding Peripheral Support

**Context**: New peripherals use memory-mapped I/O.

**Approach**:
1. Choose unused address range (e.g., `0x0004_0000`)
2. Add module instantiation in [`cpu.sv`](cpu.sv)
3. Add address decoding in FSM
4. Add chip enable signal
5. Connect to bus (`bus_addr`, `bus_wdata`, `bus_rdata`)
6. Update memory map in documentation
7. Create test application

**Key Files**:
- [`cpu.sv`](cpu.sv) - Add module and address decoding
- [`plans/architecture.md`](plans/architecture.md) - Update memory map
- [`README.md`](README.md) - Update documentation

### Task 4: Optimizing Performance

**Context**: 6-stage FSM may be inefficient for non-memory instructions.

**Approach**:
1. Profile instruction execution (use trace output)
2. Identify bottlenecks (e.g., ALU ops don't need MEMORY stages)
3. Consider FSM optimization:
   - Bypass MEMORY stages for register-only ops
   - Reduce ROM latency
   - Optimize RAM timing
4. Measure improvement with benchmarks
5. Verify correctness with test suite

**Key Files**:
- [`cpu.sv`](cpu.sv) - FSM implementation
- [`test/run_all_tests.sh`](test/run_all_tests.sh) - Regression testing

### Task 5: Verification and Testing

**Context**: Systematic testing ensures correctness.

**Approach**:
1. **Unit Tests**: Test individual features (function calls, memory access)
   - Location: [`test/unit/`](test/unit/)
   - Run: `cd test && ./run_all_tests.sh`
2. **Integration Tests**: Test ISA compliance
   - Location: [`test/isa/`](test/isa/)
   - Run: `cd test/isa && just build && just install && cd ../.. && make sim`
3. **Application Tests**: Test real-world programs
   - Location: [`apps/`](apps/)
   - Run: Build app, install, simulate

**Key Files**:
- [`test/README.md`](test/README.md) - Test documentation
- [`plans/verification_guide.md`](plans/verification_guide.md) - Verification instructions

---

## Debugging Checklist

When investigating issues, check:

- [ ] **Compilation**: Does the application compile without errors?
- [ ] **Disassembly**: Are only RV32I instructions used (no mul/div/rem)?
- [ ] **Memory Map**: Are addresses within valid ranges?
- [ ] **Trace Output**: What instructions are executing?
- [ ] **Waveforms**: Are control signals stable and correctly timed?
- [ ] **RAM Timing**: Is 2-cycle read latency properly handled?
- [ ] **Stack Pointer**: Is `sp` correctly managed?
- [ ] **Return Address**: Is `ra` saved/restored for nested calls?
- [ ] **Register File**: Are registers being written correctly?
- [ ] **Test Suite**: Do all unit tests pass?

---

## Useful Commands

### Simulation
```bash
make sim                                    # Basic simulation
make show                                   # Open waveform viewer
iverilog -g2012 -DENABLE_TRACE -o test.vvp cpu.sv test/tb.sv
vvp test.vvp                               # Run with trace output
```

### Testing
```bash
cd test && ./run_all_tests.sh              # Run all unit tests
cd test/isa && just build && just install  # Build integration test
```

### Application Development
```bash
cd apps/spinning-cube/
just build                                  # Compile
just install                                # Install to parent directory
riscv64-unknown-elf-objdump -d main.elf    # View disassembly
```

### Verification
```bash
# Check for illegal instructions (mul/div/rem)
grep -E "^\s+[0-9a-f]+:\s+[0-9a-f]+\s+(mul|div|rem)" app.disasm

# View memory layout
riscv64-unknown-elf-nm -n app.elf

# Check section sizes
riscv64-unknown-elf-size app.elf
```

---

## Important Constraints

### Hardware Constraints
- **No M-Extension**: No hardware multiply, divide, or modulo
- **Memory Latency**: RAM has 2-cycle read latency
- **Address Space**: 32-bit address space, 4 regions (ROM, RAM, FB, SPI)
- **Register File**: 32 registers (x0-x31), x0 hardwired to zero

### Software Constraints
- **Toolchain**: Must use `riscv64-unknown-elf-gcc` with `-march=rv32i`
- **ABI**: Must follow RISC-V calling convention
- **Memory Layout**: Defined by linker script
- **Stack**: Must be initialized in boot code

### Synthesis Constraints
- **Target FPGA**: Gowin GW5A-LV25MG121C1/I0
- **Clock**: External clock input (frequency TBD)
- **I/O**: Defined in [`PINOUT.md`](PINOUT.md) and [`Prozessor.cst`](Prozessor.cst)

---

## Resources

### Documentation
- [`README.md`](README.md) - Main project documentation
- [`plans/`](plans/) - Design documents and debugging guides
- [`test/README.md`](test/README.md) - Test suite documentation

### External References
- [RISC-V ISA Specification](https://riscv.org/technical/specifications/)
- [RISC-V Calling Convention](https://riscv.org/wp-content/uploads/2015/01/riscv-calling.pdf)
- [Gowin FPGA Documentation](https://www.gowinsemi.com/en/support/home/)

### Example Applications
- [`apps/spinning-cube/`](apps/spinning-cube/) - Complex 3D graphics without M-extension
- [`apps/snake-simple/`](apps/snake-simple/) - Game with controller input
- [`apps/bouncing_cube/`](apps/bouncing_cube/) - Simple animation

---

## Tips for AI Assistants

### Understanding the Codebase
1. **Start with documentation**: Read [`README.md`](README.md) and [`plans/README.md`](plans/README.md)
2. **Understand the FSM**: The 6-stage FSM in [`cpu.sv`](cpu.sv) is the heart of the system
3. **Check memory map**: All I/O is memory-mapped
4. **Review test suite**: [`test/unit/`](test/unit/) shows expected behavior

### Making Changes
1. **Read before editing**: Understand the context and existing implementation
2. **Follow conventions**: Match existing code style and structure
3. **Test thoroughly**: Run test suite after changes
4. **Update documentation**: Keep docs in sync with code

### Debugging
1. **Use trace output**: Enable with `-DENABLE_TRACE`
2. **Check waveforms**: Visual inspection often reveals timing issues
3. **Review disassembly**: Ensure correct instruction generation
4. **Run unit tests**: Isolate issues with focused tests

### Common Pitfalls
- **Forgetting M-extension limitation**: Always use software multiply/divide
- **Ignoring memory latency**: RAM reads take 2 cycles
- **Incorrect address ranges**: Check memory map
- **Missing control signals**: Ensure `ce`, `re`, `we` are properly set
- **Stack management**: Stack grows downward, must be initialized

---

## Version Information

**Last Updated**: 2026-02-21  
**Project Status**: Active development  
**Known Issues**: See [`plans/debugging_plan.md`](plans/debugging_plan.md)  
**Next Steps**: See [`README.md`](README.md) "Future Enhancements"

---

## Contact & Contribution

This is an educational project. When contributing or making changes:
1. Understand the existing architecture
2. Follow RISC-V specifications
3. Maintain test coverage
4. Update documentation
5. Verify with test suite

For questions or issues, refer to the documentation in [`plans/`](plans/) or examine existing applications in [`apps/`](apps/) for examples.
