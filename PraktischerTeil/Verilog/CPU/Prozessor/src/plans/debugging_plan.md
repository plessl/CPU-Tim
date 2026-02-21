# CPU Debugging Plan: Function Calls & Memory Access Issues

## Executive Summary

This plan addresses systematic debugging of the RISC-V RV32I processor core, specifically targeting issues with function calls and memory variable access. The previous verification attempt using Google Gemini 3 Flash was unsuccessful. This updated plan provides a more targeted, automated approach with specific focus on the identified problem areas.

## Critical Issues Identified in Current Implementation

### 1. **RAM Module Has 2-Cycle Read Latency**
The [`ram_module`](../cpu.sv:346) uses a **two-stage pipeline** for reads:
- Cycle 1: Data is read into `dout_reg` (line 385)
- Cycle 2: `dout_reg` is transferred to `data_out` (line 398)

**Problem**: The CPU FSM currently uses only 2 memory stages (MEMORY1, MEMORY2), which may not properly account for this 2-cycle latency, especially when the address calculation happens in EXECUTE.

### 2. **Inconsistent Signal Timing in Load Operations**
In the [`EXECUTE`](../cpu.sv:876) state for loads:
- `bus_addr` is set
- `dmem_ce` and `dmem_read` are activated

In [`MEMORY1`](../cpu.sv:955) state:
- Signals are kept active (lines 961-962)

In [`MEMORY2`](../cpu.sv:1038) state:
- Data is sampled from `bus_rdata`

**Potential Issue**: The timing may not align with the RAM's 2-cycle latency. The address needs to be stable for 2 full cycles before valid data appears.

### 3. **Function Call Stack Management**
Function calls rely on:
- `jalr` instruction for returns (line 933-936)
- Stack pointer (`sp` = x2) management by compiler
- Return address (`ra` = x1) storage

**Risk Areas**:
- Stack pointer arithmetic in load/store address calculation
- Return address corruption
- Register save/restore in function prologue/epilogue

### 4. **Global Variable Access**
Global variables in `.data` and `.bss` sections require:
- Correct GP-relative or absolute addressing
- Proper load/store to RAM region (0x0001_xxxx)

**Potential Issues**:
- Address calculation errors
- Memory timing issues affecting reads/writes

## Analysis of Current Verification Approach

### Strengths
1. ✅ Good test structure with magic address for pass/fail signaling
2. ✅ Comprehensive integration test covering recursion and stack spilling
3. ✅ Proper toolchain setup with RISC-V GCC
4. ✅ VCD waveform generation for debugging

### Weaknesses
1. ❌ **Too coarse-grained**: Integration test combines multiple failure modes
2. ❌ **No incremental testing**: Hard to isolate which specific operation fails
3. ❌ **Limited observability**: No intermediate checkpoints in tests
4. ❌ **No golden model comparison**: Relies only on self-checking
5. ❌ **Insufficient memory access testing**: Doesn't specifically test RAM latency edge cases

## Updated Verification Strategy

### Phase 1: Minimal Reproducible Tests (Isolation)

Create ultra-simple tests that isolate individual operations:

#### Test 1.1: Single Function Call (No Arguments)
```c
void dummy() { }
int main() {
    dummy();
    signal_result(PASS);
}
```
**Purpose**: Verify basic `jal`/`jalr` without stack operations.

#### Test 1.2: Function Call with Return Value
```c
uint32_t get_value() { return 0x12345678; }
int main() {
    if (get_value() == 0x12345678) signal_result(PASS);
    else signal_result(FAIL);
}
```
**Purpose**: Verify return value passing via register.

#### Test 1.3: Function Call with Single Argument
```c
uint32_t add_one(uint32_t x) { return x + 1; }
int main() {
    if (add_one(5) == 6) signal_result(PASS);
    else signal_result(FAIL);
}
```
**Purpose**: Verify argument passing via register.

#### Test 1.4: Function Call with Stack Usage
```c
uint32_t add_two(uint32_t a, uint32_t b) {
    uint32_t local = a + b;
    return local;
}
int main() {
    if (add_two(3, 4) == 7) signal_result(PASS);
    else signal_result(FAIL);
}
```
**Purpose**: Verify stack frame allocation for local variables.

#### Test 1.5: Nested Function Calls (Depth 2)
```c
uint32_t inner() { return 42; }
uint32_t outer() { return inner(); }
int main() {
    if (outer() == 42) signal_result(PASS);
    else signal_result(FAIL);
}
```
**Purpose**: Verify `ra` save/restore on stack.

#### Test 1.6: Global Variable Read
```c
volatile uint32_t global = 0xDEADBEEF;
int main() {
    if (global == 0xDEADBEEF) signal_result(PASS);
    else signal_result(FAIL);
}
```
**Purpose**: Verify `.data` section access.

#### Test 1.7: Global Variable Write
```c
volatile uint32_t global;
int main() {
    global = 0xCAFEBABE;
    if (global == 0xCAFEBABE) signal_result(PASS);
    else signal_result(FAIL);
}
```
**Purpose**: Verify `.bss` section write and read-back.

#### Test 1.8: Function Accessing Global Variable
```c
volatile uint32_t counter = 0;
void increment() { counter++; }
int main() {
    increment();
    if (counter == 1) signal_result(PASS);
    else signal_result(FAIL);
}
```
**Purpose**: Verify global access from within function.

#### Test 1.9: Multiple Loads/Stores in Sequence
```c
volatile uint32_t array[4] = {1, 2, 3, 4};
int main() {
    uint32_t sum = array[0] + array[1] + array[2] + array[3];
    if (sum == 10) signal_result(PASS);
    else signal_result(FAIL);
}
```
**Purpose**: Stress-test RAM latency with consecutive accesses.

### Phase 2: Enhanced Testbench with Detailed Tracing

Modify [`tb_comprehensive.sv`](../test/tb_comprehensive.sv) to add:

1. **Register File Monitoring**: Track `ra` (x1) and `sp` (x2) on every cycle
2. **Memory Access Logging**: Log all RAM reads/writes with timing
3. **PC Trace**: Show execution flow to identify where failures occur
4. **Cycle-Accurate Timing**: Verify RAM access timing

### Phase 3: Automated Test Execution

Create a test runner script that:
1. Compiles each test case
2. Runs simulation
3. Captures pass/fail status
4. Generates summary report
5. On failure: Automatically opens waveform at failure point

## Automated Verification Workflow

### Directory Structure
```
test/
├── unit/
│   ├── test_1_1_simple_call.c
│   ├── test_1_2_return_value.c
│   ├── test_1_3_single_arg.c
│   ├── test_1_4_stack_usage.c
│   ├── test_1_5_nested_calls.c
│   ├── test_1_6_global_read.c
│   ├── test_1_7_global_write.c
│   ├── test_1_8_func_global.c
│   ├── test_1_9_array_access.c
│   ├── boot.s
│   ├── link.ld
│   └── justfile
├── tb_debug.sv          # Enhanced testbench
└── run_all_tests.sh     # Automation script
```

### Test Execution Script

The script will:
1. Iterate through all test cases
2. For each test:
   - Compile with `riscv64-unknown-elf-gcc`
   - Generate `.mi` file
   - Run `iverilog` simulation
   - Parse output for PASS/FAIL/TIMEOUT
   - Log results
3. Generate summary report
4. On first failure: Stop and report which test failed

### Enhanced Testbench Features

```systemverilog
// Additional monitoring in tb_debug.sv
always @(posedge clk) begin
    if (uut.machine.state == WRITEBACK) begin
        $display("[%t] WB: PC=0x%h rd=x%0d val=0x%h ra=0x%h sp=0x%h", 
                 $time, pc, uut.machine.rd, uut.machine.tmp_rd,
                 uut.machine.regfile[1], uut.machine.regfile[2]);
    end
    
    if (dmem_ce && dmem_read) begin
        $display("[%t] RAM_RD: addr=0x%h state=%s", 
                 $time, bus_addr, uut.machine.state.name());
    end
    
    if (dmem_ce && |dmem_we) begin
        $display("[%t] RAM_WR: addr=0x%h data=0x%h we=%b", 
                 $time, bus_addr, bus_wdata, dmem_we);
    end
end
```

## Execution Procedure

### Step 1: Setup Test Environment
```bash
cd test/unit
# Ensure boot.s and link.ld are present
# Ensure ram.mi and led.mi exist in project root
```

### Step 2: Run Individual Test (Manual)
```bash
# Compile test
just build TEST=test_1_1_simple_call

# Run simulation
cd ../..
iverilog -g2012 -DENABLE_TRACE -o tb_debug.vvp test/tb_debug.sv cpu.sv
vvp tb_debug.vvp

# Check result
# Look for "TEST PASSED" or "TEST FAILED" in output
```

### Step 3: Run All Tests (Automated)
```bash
cd test
./run_all_tests.sh
```

The script will output:
```
Running CPU Verification Suite...
[1/9] test_1_1_simple_call............ PASS
[2/9] test_1_2_return_value........... PASS
[3/9] test_1_3_single_arg............. PASS
[4/9] test_1_4_stack_usage............ FAIL ❌

Test failed at: test_1_4_stack_usage
Check waveform: test/unit/test_1_4_stack_usage.vcd
Check disassembly: test/unit/test_1_4_stack_usage.disasm
```

### Step 4: Debug Failed Test
```bash
# Open waveform
surfer test/unit/test_1_4_stack_usage.vcd

# Review disassembly
less test/unit/test_1_4_stack_usage.disasm

# Check detailed trace
less test/unit/test_1_4_stack_usage.log
```

### Step 5: Fix and Retest
```bash
# After fixing cpu.sv
cd test
./run_all_tests.sh --continue-from test_1_4_stack_usage
```

## Expected Outcomes

### Success Criteria
- All 9 unit tests pass
- Integration test passes
- Complex applications (snake-simple-fcalltest) work correctly

### Likely Failure Points

Based on code analysis, expect failures in:

1. **Test 1.4 or 1.5**: Stack operations
   - **Root Cause**: RAM latency not properly handled
   - **Fix**: Adjust FSM timing or add wait states

2. **Test 1.8 or 1.9**: Global variable access from functions
   - **Root Cause**: Address calculation or timing issue
   - **Fix**: Verify address computation in EXECUTE stage

3. **Test 1.9**: Consecutive memory accesses
   - **Root Cause**: RAM not ready for back-to-back reads
   - **Fix**: Ensure proper cycle spacing

## Comparison with Previous Approach

| Aspect | Previous Approach | New Approach |
|--------|------------------|--------------|
| Test Granularity | Coarse (all-in-one) | Fine (isolated tests) |
| Failure Isolation | Difficult | Easy (know exact operation) |
| Automation | Manual | Fully automated |
| Debugging Time | High (complex waveforms) | Low (minimal waveforms) |
| Coverage | Good | Better (incremental) |
| Observability | Limited | Enhanced (detailed traces) |

## Timeline

1. **Setup** (30 min): Create test directory structure and files
2. **Test Creation** (1-2 hours): Write 9 unit tests
3. **Testbench Enhancement** (30 min): Add detailed logging
4. **Automation Script** (1 hour): Create run_all_tests.sh
5. **Execution** (15 min): Run all tests
6. **Debug** (Variable): Fix identified issues
7. **Verification** (15 min): Rerun to confirm fixes

**Total Setup**: ~3-4 hours
**Per Debug Cycle**: ~30 min

## Tools Required

- `riscv64-unknown-elf-gcc` (already installed)
- `iverilog` (already installed)
- `surfer` or `gtkwave` (for waveform viewing)
- `bash` (for automation script)
- `just` (optional, for build automation)

## Next Steps

1. Review this plan and confirm approach
2. Create test directory structure
3. Implement unit tests
4. Create enhanced testbench
5. Write automation script
6. Execute verification suite
7. Debug and fix identified issues

## Appendix: RAM Timing Analysis

The RAM module has this timing:

```
Cycle N:   addr=X, re=1, ce=1 asserted
Cycle N+1: dout_reg <= ram_mem[X]  (internal)
Cycle N+2: data_out <= dout_reg    (output valid)
```

The CPU FSM timing:

```
EXECUTE:  addr calculated, dmem_ce=1, dmem_read=1
MEMORY1:  signals held
MEMORY2:  data sampled from bus_rdata
```

**Analysis**: If EXECUTE is cycle N, then:
- N: Address set
- N+1: MEMORY1 (RAM cycle 1)
- N+2: MEMORY2 (RAM cycle 2) ✓ Data should be valid

This appears correct, BUT there may be issues with:
1. Address stability (needs to be held from EXECUTE through MEMORY2)
2. Control signal timing (ce/re must be stable)
3. Back-to-back accesses (no pipeline hazards)

The unit tests will reveal which scenario fails.
