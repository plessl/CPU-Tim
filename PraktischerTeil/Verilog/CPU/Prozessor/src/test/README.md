# CPU Verification Test Suite

## Quick Start

```bash
# Run all tests
cd test
./run_all_tests.sh

# Continue from a specific test after fixing
./run_all_tests.sh --continue-from test_1_4_stack_usage
```

## Test Files

### Unit Tests (`unit/`)
- [`test_1_1_simple_call.c`](unit/test_1_1_simple_call.c) - Basic function call
- [`test_1_2_return_value.c`](unit/test_1_2_return_value.c) - Return value passing
- [`test_1_3_single_arg.c`](unit/test_1_3_single_arg.c) - Single argument
- [`test_1_4_stack_usage.c`](unit/test_1_4_stack_usage.c) - Stack frame allocation
- [`test_1_5_nested_calls.c`](unit/test_1_5_nested_calls.c) - Nested function calls
- [`test_1_6_global_read.c`](unit/test_1_6_global_read.c) - Global variable read
- [`test_1_7_global_write.c`](unit/test_1_7_global_write.c) - Global variable write
- [`test_1_8_func_global.c`](unit/test_1_8_func_global.c) - Function accessing globals
- [`test_1_9_array_access.c`](unit/test_1_9_array_access.c) - Array access

### Testbenches
- [`tb_debug.sv`](tb_debug.sv) - Enhanced testbench with detailed tracing
- [`tb_comprehensive.sv`](tb_comprehensive.sv) - Original comprehensive testbench

### Automation
- [`run_all_tests.sh`](run_all_tests.sh) - Automated test runner

## Documentation

See [`../plans/`](../plans/) for complete documentation:
- [`QUICKSTART.md`](../plans/QUICKSTART.md) - Step-by-step execution guide
- [`debugging_plan.md`](../plans/debugging_plan.md) - Detailed technical analysis
- [`automation_guide.md`](../plans/automation_guide.md) - Implementation details
- [`README.md`](../plans/README.md) - Documentation index

## File Structure

```
test/
├── unit/                      # Unit tests
│   ├── common.h               # Shared definitions
│   ├── test_1_*.c             # 9 test files
│   ├── boot.s                 # Boot code
│   └── link.ld                # Linker script
├── tb_debug.sv                # Enhanced testbench
├── run_all_tests.sh           # Automation script
└── README.md                  # This file
```

## Expected Output

### Success
```
[1/9] test_1_1_simple_call         ... PASS ✓
[2/9] test_1_2_return_value        ... PASS ✓
...
All tests passed! ✓
```

### Failure
```
[4/9] test_1_4_stack_usage         ... FAIL ✗

  → Check waveform: results_20260220_210000/test_1_4_stack_usage.vcd
  → Check disassembly: unit/test_1_4_stack_usage.disasm
  → Check log: results_20260220_210000/test_1_4_stack_usage.log
```

## Debugging

When a test fails:
1. Open waveform: `surfer results_*/test_*.vcd`
2. Review disassembly: `less unit/test_*.disasm`
3. Check execution log: `less results_*/test_*.log`
4. Fix [`cpu.sv`](../cpu.sv)
5. Rerun: `./run_all_tests.sh --continue-from test_*`

## Manual Test Execution

```bash
# Compile a single test
cd unit
riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 \
    -ffreestanding -nostdlib -static \
    -fno-pic -fno-pie -Og -g \
    -Wl,-T,link.ld -Wl,--gc-sections \
    boot.s test_1_1_simple_call.c -o test_1_1_simple_call.elf

riscv64-unknown-elf-objcopy -O binary test_1_1_simple_call.elf test_1_1_simple_call.bin
hexdump -v -e '1/4 "%08x\n"' test_1_1_simple_call.bin > test_1_1_simple_call.mi
riscv64-unknown-elf-objdump --disassemble-all -S test_1_1_simple_call.elf > test_1_1_simple_call.disasm
cp test_1_1_simple_call.mi ../../rom.mi

# Run simulation
cd ..
iverilog -g2012 -DENABLE_TRACE -o test.vvp tb_debug.sv ../cpu.sv
vvp test.vvp
```

## Integration Test

After all unit tests pass, run the integration test:

```bash
cd isa
just build
just install
cd ../..
iverilog -g2012 -o tb.vvp test/tb_comprehensive.sv cpu.sv
vvp tb.vvp
```
