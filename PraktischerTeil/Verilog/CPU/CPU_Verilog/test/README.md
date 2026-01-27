# CPU Verilog Test Suite

This directory contains comprehensive testbenches for the RISC-V CPU implementation.

## Test Files

### Unit Tests

1. **tb_ram.v** - RAM Module Tests
   - Write/read operations
   - Word-aligned addressing
   - Chip enable functionality
   - Multiple consecutive writes

2. **tb_rom.v** - ROM Module Tests
   - Read operations
   - Chip enable functionality
   - Sequential reads
   - Reset behavior

3. **tb_fsm.v** - FSM (CPU Core) Tests
   - Basic arithmetic instructions (ADD, SUB, ADDI)
   - Logical operations (AND, OR, XOR)
   - Load upper immediate (LUI)
   - Shift operations (SLL)
   - Program counter increment verification

### Integration Tests

4. **tb_cpu.v** - Full CPU Integration Test
   - Complete instruction sequence execution
   - Memory operations (load/store)
   - Register file verification
   - End-to-end CPU functionality

## Running Tests

### Prerequisites

- **iverilog** - Icarus Verilog simulator
- **yosys** - Synthesis tool (optional, for synthesis checks)
- **gtkwave** - Waveform viewer (optional, for debugging)

Install on macOS:
```bash
brew install icarus-verilog yosys gtkwave
```

### Using Make

From the project root directory (`CPU_Verilog/`):

```bash
# Run all tests
make test

# Run individual tests
make test_ram
make test_rom
make test_fsm
make test_cpu

# Synthesize with Yosys
make synth

# View waveforms (requires GTKWave)
make wave_cpu

# Clean build artifacts
make clean

# Show help
make help
```

### Manual Test Execution

You can also run tests manually with iverilog:

```bash
# RAM test
iverilog -g2012 -o build/tb_ram.vvp test/tb_ram.v src/cpu.v
vvp build/tb_ram.vvp

# ROM test
iverilog -g2012 -o build/tb_rom.vvp test/tb_rom.v src/cpu.v
vvp build/tb_rom.vvp

# FSM test
iverilog -g2012 -o build/tb_fsm.vvp test/tb_fsm.v src/cpu.v
vvp build/tb_fsm.vvp

# CPU integration test
iverilog -g2012 -o build/tb_cpu.vvp test/tb_cpu.v src/cpu.v
vvp build/tb_cpu.vvp
```

## Test Output

Each test will produce:
- Console output with PASS/FAIL results
- VCD waveform file in the `build/` directory

Example output:
```
Test 1: Write 0xDEADBEEF to address 0
Test 2: Read from address 0
PASS: Read correct value 0xDEADBEEF
...
```

## Viewing Waveforms

To debug test failures or examine signal behavior:

```bash
gtkwave build/tb_cpu.vcd &
```

## Test Coverage

The test suite covers:

### Instructions Tested
- **I-Type**: ADDI, LW
- **R-Type**: ADD, SUB, AND, OR, XOR, SLL
- **S-Type**: SW
- **U-Type**: LUI

### Features Tested
- Arithmetic operations
- Logical operations
- Memory read/write
- Register file operations
- Program counter management
- State machine transitions

### Edge Cases
- Negative immediates
- Zero register behavior
- Memory alignment
- Chip enable signals
- Reset functionality

## Synthesis Verification

Use Yosys to verify synthesizability:

```bash
make synth_cpu
cat build/synth_cpu.log
```

This checks for:
- Synthesizable Verilog constructs
- Inferred hardware (flip-flops, memories, etc.)
- Basic design statistics

## Troubleshooting

### Common Issues

1. **Module not found**
   - Ensure you're running from the project root
   - Check that `src/cpu.v` exists

2. **Syntax errors**
   - The testbenches require Verilog-2012 (`-g2012` flag)
   - Check for SystemVerilog features in source files

3. **Variable declaration errors**
   - Some testbenches use `integer` for loop variables
   - FSM module uses undeclared `i` - add `integer i;` at line 146

4. **Test failures**
   - View VCD waveforms to debug timing issues
   - Check instruction encodings
   - Verify FSM state transitions

## Adding New Tests

To add a new test:

1. Create `test/tb_newtest.v`
2. Add target to Makefile:
   ```make
   .PHONY: test_newtest
   test_newtest: $(BUILD_DIR)
       $(IVERILOG) -g2012 -o $(BUILD_DIR)/tb_newtest.vvp $(TEST_DIR)/tb_newtest.v $(CPU_SRC)
       $(VVP) $(BUILD_DIR)/tb_newtest.vvp
   ```
3. Add to `test` target dependencies

## References

- [Icarus Verilog Documentation](http://iverilog.icarus.com/)
- [Yosys Manual](https://yosyshq.net/yosys/)
- [GTKWave Documentation](http://gtkwave.sourceforge.net/)
- [RISC-V Instruction Set Manual](https://riscv.org/specifications/)
