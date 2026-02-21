# RISC-V RV32I FPGA Core

This project implements a RISC-V core that supports the user-mode RV32I instruction set in System Verilog. The hardware description is synthesized for a Gowin GW5A FPGA architecture targeting a SIPEED Prime 25k evaluation board.

## System Architecture

The CPU core is realized as a 6-stage multi-cycle implementation with dedicated instruction and data memories.

### CPU Core
- **Instruction Set**: RV32I (User-mode)
- **Implementation**: 6-stage multi-cycle FSM (`FETCH`, `DECODE`, `EXECUTE`, `MEMORY1`, `MEMORY2`, `WRITEBACK`)

### Memory Map
The system uses a simple memory-mapped I/O scheme:

| Address Range | Device | Description |
|---------------|--------|-------------|
| `0x0000_0000` - `0x0000_FFFF` | **ROM** | Instruction Memory (64KB) |
| `0x0001_0000` - `0x0001_FFFF` | **RAM** | Data Memory (64KB) |
| `0x0002_0000` - `0x0002_FFFF` | **Framebuffer** | 64x64 LED Matrix Buffer |
| `0x0003_0000` - `0x0003_FFFF` | **SPI Controller** | Dualshock 2 Controller Interface |

### Peripherals
- **SPI Controller**: Continuously queries a PS2 Dualshock 2 game controller.
- **LED Matrix Controller**: Drives a HUB75E-compatible 64x64 LED matrix using a dual-ported framebuffer.

## Project Structure
- `cpu.sv`: Main System Verilog file containing the CPU, FSM, and peripheral controllers.
- `apps/`: C and Assembly applications targeting the core.
- `test/`: Testbenches for simulation.
- `plans/`: Architectural documentation and design plans.

## Simulation and Debugging

### Debug Tracing

The CPU supports detailed execution tracing for simulation and debugging. Enable trace output by defining `ENABLE_TRACE` when compiling with Icarus Verilog:

```bash
iverilog -g2012 -DENABLE_TRACE -o test.vvp cpu.sv test/tb.sv
vvp test.vvp
```

**Trace Output Includes**:
- Instruction disassembly for each executed instruction
- Memory operations (loads/stores to RAM, framebuffer, SPI)
- SPI controller reads
- Framebuffer writes with addresses and data
- Illegal instruction detection

**Example Trace Output**:
```
Read from SPI: addr = 0x00030000 , data 0x000000ff
Store to framebuffer at addr 0x00020400 data 0x00000007
ADDI x10, x0, 42
LW x11, 0(x10)
```

**Note**: Trace output is automatically disabled for synthesis (`ifndef SYNTHESIS`) to prevent inclusion in FPGA builds.

### Waveform Analysis

Generate VCD waveforms for detailed signal analysis:

```bash
iverilog -g2012 -o test.vvp cpu.sv test/tb.sv
vvp test.vvp
# Generates test.vcd
gtkwave test.vcd  # or use surfer, etc.
```

Waveform files can be viewed with:
- **GTKWave**: `gtkwave test.vcd`
- **Surfer**: Load `test.vcd` with saved state from `surfer-state`

## Verification
A comprehensive verification suite is available in the `test/` directory.
- **[`plans/verification_plan.md`](plans/verification_plan.md)**: Systematic testing strategy.
- **[`plans/verification_guide.md`](plans/verification_guide.md)**: Step-by-step instructions on running tests and evaluating results.

## Future Enhancements (Planned)
- **Reducing memory latency**: Reduce RAM access latency for framebuffer to 1 cycle latency
- **Remove MEM2 stage in controller**: When all memory access latencies are 1 cycle, the MEM2 stage can be removed to improve performance and simplify the design
- **Add support for reading program memory**: All for reading program memory, such that constants can be loaded directly from program memory
- **M-Extension Support**: Implement hardware multiplication and division (`mul`, `div`, `rem`).
- **Performance Benchmarking**: Analyze and optimize cycles per instruction (CPI).
- **FSM Optimization**: Compress the 6-stage execution cycle for non-memory instructions.
- **Interrupt Support**: Add support for machine-mode interrupts and exceptions.
