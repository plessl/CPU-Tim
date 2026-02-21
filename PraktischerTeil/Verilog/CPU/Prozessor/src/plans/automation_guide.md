# Automation Guide: CPU Verification Workflow

This guide provides the complete automation setup for running the CPU verification suite. Since these are non-markdown files, they will need to be created in Code mode.

## File Structure to Create

```
test/
├── unit/                      # Unit test directory
│   ├── test_1_1_simple_call.c
│   ├── test_1_2_return_value.c
│   ├── test_1_3_single_arg.c
│   ├── test_1_4_stack_usage.c
│   ├── test_1_5_nested_calls.c
│   ├── test_1_6_global_read.c
│   ├── test_1_7_global_write.c
│   ├── test_1_8_func_global.c
│   ├── test_1_9_array_access.c
│   ├── boot.s                 # Copy from test/isa/boot.s
│   ├── link.ld                # Copy from test/isa/link.ld
│   └── common.h               # Shared definitions
├── tb_debug.sv                # Enhanced testbench
└── run_all_tests.sh           # Automation script
```

## 1. Common Header File

**File**: `test/unit/common.h`

```c
#ifndef COMMON_H
#define COMMON_H

#include <stdint.h>

#define MAGIC_ADDR 0x0001FFFC
#define PASS 1
#define FAIL 0xDEADBEEF

static inline void signal_result(uint32_t result) {
    volatile uint32_t *p = (volatile uint32_t *)MAGIC_ADDR;
    *p = result;
    while(1);  // Halt
}

#endif // COMMON_H
```

## 2. Unit Test Files

### Test 1.1: Simple Function Call

**File**: `test/unit/test_1_1_simple_call.c`

```c
#include "common.h"

void dummy() {
    // Do nothing
}

int main() {
    dummy();
    signal_result(PASS);
    return 0;
}
```

### Test 1.2: Return Value

**File**: `test/unit/test_1_2_return_value.c`

```c
#include "common.h"

uint32_t get_value() {
    return 0x12345678;
}

int main() {
    uint32_t result = get_value();
    if (result == 0x12345678) {
        signal_result(PASS);
    } else {
        signal_result(FAIL);
    }
    return 0;
}
```

### Test 1.3: Single Argument

**File**: `test/unit/test_1_3_single_arg.c`

```c
#include "common.h"

uint32_t add_one(uint32_t x) {
    return x + 1;
}

int main() {
    uint32_t result = add_one(5);
    if (result == 6) {
        signal_result(PASS);
    } else {
        signal_result(FAIL);
    }
    return 0;
}
```

### Test 1.4: Stack Usage

**File**: `test/unit/test_1_4_stack_usage.c`

```c
#include "common.h"

uint32_t add_two(uint32_t a, uint32_t b) {
    uint32_t local = a + b;
    return local;
}

int main() {
    uint32_t result = add_two(3, 4);
    if (result == 7) {
        signal_result(PASS);
    } else {
        signal_result(FAIL);
    }
    return 0;
}
```

### Test 1.5: Nested Calls

**File**: `test/unit/test_1_5_nested_calls.c`

```c
#include "common.h"

uint32_t inner() {
    return 42;
}

uint32_t outer() {
    return inner();
}

int main() {
    uint32_t result = outer();
    if (result == 42) {
        signal_result(PASS);
    } else {
        signal_result(FAIL);
    }
    return 0;
}
```

### Test 1.6: Global Read

**File**: `test/unit/test_1_6_global_read.c`

```c
#include "common.h"

volatile uint32_t global = 0xDEADBEEF;

int main() {
    if (global == 0xDEADBEEF) {
        signal_result(PASS);
    } else {
        signal_result(FAIL);
    }
    return 0;
}
```

### Test 1.7: Global Write

**File**: `test/unit/test_1_7_global_write.c`

```c
#include "common.h"

volatile uint32_t global;

int main() {
    global = 0xCAFEBABE;
    if (global == 0xCAFEBABE) {
        signal_result(PASS);
    } else {
        signal_result(FAIL);
    }
    return 0;
}
```

### Test 1.8: Function Accessing Global

**File**: `test/unit/test_1_8_func_global.c`

```c
#include "common.h"

volatile uint32_t counter = 0;

void increment() {
    counter++;
}

int main() {
    increment();
    if (counter == 1) {
        signal_result(PASS);
    } else {
        signal_result(FAIL);
    }
    return 0;
}
```

### Test 1.9: Array Access

**File**: `test/unit/test_1_9_array_access.c`

```c
#include "common.h"

volatile uint32_t array[4] = {1, 2, 3, 4};

int main() {
    uint32_t sum = array[0] + array[1] + array[2] + array[3];
    if (sum == 10) {
        signal_result(PASS);
    } else {
        signal_result(FAIL);
    }
    return 0;
}
```

## 3. Enhanced Testbench

**File**: `test/tb_debug.sv`

```systemverilog
`timescale 1ns/1ns

module tb_debug();

    reg clk;
    reg rst;
    
    // CPU signals
    wire [31:0] pc;
    wire [31:0] instr;
    wire [31:0] bus_addr;
    wire [31:0] bus_rdata;
    wire [31:0] bus_wdata;
    wire [3:0]  dmem_we;
    wire        dmem_ce;
    wire        dmem_read;
    wire [2:0]  state;
    
    // Register file access
    wire [31:0] ra;  // x1 - return address
    wire [31:0] sp;  // x2 - stack pointer
    wire [31:0] gp;  // x3 - global pointer
    wire [4:0]  rd;
    wire [31:0] tmp_rd;

    // Instantiate the top module
    topmodule uut(
        .clk(clk),
        .rst(rst),
        .miso(1'b1)
    );

    // Access internal signals
    assign pc = uut.machine.pc;
    assign instr = uut.machine.instr;
    assign bus_addr = uut.machine.bus_addr;
    assign bus_rdata = uut.machine.bus_rdata;
    assign bus_wdata = uut.machine.bus_wdata;
    assign dmem_we = uut.machine.dmem_we;
    assign dmem_ce = uut.machine.dmem_ce;
    assign dmem_read = uut.machine.dmem_read;
    assign state = uut.machine.state;
    assign ra = uut.machine.regfile[1];
    assign sp = uut.machine.regfile[2];
    assign gp = uut.machine.regfile[3];
    assign rd = uut.machine.rd;
    assign tmp_rd = uut.machine.tmp_rd;

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 50MHz
    end

    // VCD file name from compile-time define
    `ifdef VCD_FILE
        string vcd_filename = `VCD_FILE;
    `else
        string vcd_filename = "tb_debug.vcd";
    `endif

    // Test sequence
    initial begin
        $dumpfile(vcd_filename);
        $dumpvars(0, tb_debug);
        
        $display("========================================");
        $display("CPU Debug Testbench");
        $display("========================================");
        
        rst = 1;
        #100;
        rst = 0;
        
        $display("Starting execution...");
        
        // Monitor for magic address writes
        forever begin
            @(posedge clk);
            if (dmem_ce && |dmem_we && (bus_addr == 32'h0001_FFFC)) begin
                if (bus_wdata == 32'h1) begin
                    $display("");
                    $display("========================================");
                    $display("TEST PASSED at PC: 0x%h", pc);
                    $display("========================================");
                    $finish;
                end else if (bus_wdata == 32'hDEADBEEF) begin
                    $display("");
                    $display("========================================");
                    $display("TEST FAILED at PC: 0x%h", pc);
                    $display("Last values: ra=0x%h sp=0x%h", ra, sp);
                    $display("========================================");
                    $finish;
                end
            end
        end
    end

    // Timeout mechanism
    initial begin
        #1000000; // 1ms simulation time
        $display("");
        $display("========================================");
        $display("TIMEOUT: Test did not complete");
        $display("Last PC: 0x%h", pc);
        $display("Last state: %0d", state);
        $display("========================================");
        $finish;
    end

    // Detailed execution trace
    `ifdef ENABLE_TRACE
    always @(posedge clk) begin
        // Trace writeback stage
        if (state == 3'd5) begin // WRITEBACK
            if (uut.machine.set_rd_flag && rd != 0) begin
                $display("[%t] WB: PC=0x%08h x%0d=0x%08h | ra=0x%08h sp=0x%08h", 
                         $time, pc, rd, tmp_rd, ra, sp);
            end
        end
        
        // Trace memory reads
        if (dmem_ce && dmem_read && state == 3'd3) begin // MEMORY1
            $display("[%t] MEM_RD: addr=0x%08h state=%0d", $time, bus_addr, state);
        end
        
        // Trace memory writes
        if (dmem_ce && |dmem_we) begin
            $display("[%t] MEM_WR: addr=0x%08h data=0x%08h we=%b", 
                     $time, bus_addr, bus_wdata, dmem_we);
        end
        
        // Trace function calls (JAL/JALR)
        if (state == 3'd2) begin // EXECUTE
            if (uut.machine.opcode == 7'b1101111) begin // JAL
                $display("[%t] JAL: PC=0x%08h -> 0x%08h (ra will be 0x%08h)", 
                         $time, pc, pc + uut.machine.imm, pc + 4);
            end
            if (uut.machine.opcode == 7'b1100111) begin // JALR
                $display("[%t] JALR: PC=0x%08h -> 0x%08h (ra will be 0x%08h)", 
                         $time, pc, (uut.machine.regfile[uut.machine.rs1] + uut.machine.imm) & ~32'b1, pc + 4);
            end
        end
    end
    `endif

endmodule
```

## 4. Test Runner Script

**File**: `test/run_all_tests.sh`

```bash
#!/bin/bash

# CPU Verification Test Runner
# Automatically compiles and runs all unit tests

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
UNIT_TEST_DIR="unit"
PROJECT_ROOT=".."
TESTBENCH="tb_debug.sv"
CPU_MODULE="../cpu.sv"

# Test list
TESTS=(
    "test_1_1_simple_call"
    "test_1_2_return_value"
    "test_1_3_single_arg"
    "test_1_4_stack_usage"
    "test_1_5_nested_calls"
    "test_1_6_global_read"
    "test_1_7_global_write"
    "test_1_8_func_global"
    "test_1_9_array_access"
)

# Results tracking
PASSED=0
FAILED=0
TIMEOUT=0
TOTAL=${#TESTS[@]}

# Parse command line arguments
START_FROM=""
if [ "$1" == "--continue-from" ] && [ -n "$2" ]; then
    START_FROM="$2"
fi

# Create results directory
RESULTS_DIR="results_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$RESULTS_DIR"

echo "=========================================="
echo "CPU Verification Suite"
echo "=========================================="
echo "Total tests: $TOTAL"
echo "Results directory: $RESULTS_DIR"
echo ""

# Function to compile a test
compile_test() {
    local test_name=$1
    local test_file="${UNIT_TEST_DIR}/${test_name}.c"
    
    if [ ! -f "$test_file" ]; then
        echo "Error: Test file $test_file not found"
        return 1
    fi
    
    cd "$UNIT_TEST_DIR"
    
    # Compile
    riscv64-unknown-elf-gcc \
        -march=rv32i -mabi=ilp32 \
        -ffreestanding -nostdlib -static \
        -fno-pic -fno-pie \
        -fdata-sections -ffunction-sections \
        -Og \
        -g \
        -Wl,-T,link.ld \
        -Wl,--gc-sections \
        -Wall -Wextra \
        boot.s "${test_name}.c" \
        -o "${test_name}.elf" 2>&1 | tee "${test_name}.compile.log"
    
    # Generate binary
    riscv64-unknown-elf-objcopy -O binary "${test_name}.elf" "${test_name}.bin"
    
    # Generate memory initialization file
    hexdump -v -e '1/4 "%08x\n"' "${test_name}.bin" > "${test_name}.mi"
    
    # Generate disassembly
    riscv64-unknown-elf-objdump --disassemble-all -S "${test_name}.elf" > "${test_name}.disasm"
    
    # Copy to project root as rom.mi
    cp "${test_name}.mi" "../../rom.mi"
    
    cd - > /dev/null
    return 0
}

# Function to run simulation
run_simulation() {
    local test_name=$1
    local vvp_file="${RESULTS_DIR}/${test_name}.vvp"
    local vcd_file="${RESULTS_DIR}/${test_name}.vcd"
    local log_file="${RESULTS_DIR}/${test_name}.log"
    
    # Compile testbench
    iverilog -g2012 -DENABLE_TRACE -DVCD_FILE=\"${vcd_file}\" \
        -o "$vvp_file" "$TESTBENCH" "$CPU_MODULE" 2>&1 | tee "${RESULTS_DIR}/${test_name}.iverilog.log"
    
    if [ $? -ne 0 ]; then
        echo "Error: iverilog compilation failed"
        return 2
    fi
    
    # Run simulation
    timeout 10s vvp "$vvp_file" > "$log_file" 2>&1
    local exit_code=$?
    
    # Check result
    if grep -q "TEST PASSED" "$log_file"; then
        return 0  # PASS
    elif grep -q "TEST FAILED" "$log_file"; then
        return 1  # FAIL
    elif grep -q "TIMEOUT" "$log_file" || [ $exit_code -eq 124 ]; then
        return 3  # TIMEOUT
    else
        return 2  # ERROR
    fi
}

# Main test loop
SKIP_UNTIL_FOUND=false
if [ -n "$START_FROM" ]; then
    SKIP_UNTIL_FOUND=true
fi

for i in "${!TESTS[@]}"; do
    test_name="${TESTS[$i]}"
    test_num=$((i + 1))
    
    # Skip tests if continuing from a specific test
    if [ "$SKIP_UNTIL_FOUND" = true ]; then
        if [ "$test_name" == "$START_FROM" ]; then
            SKIP_UNTIL_FOUND=false
        else
            echo "[$test_num/$TOTAL] Skipping $test_name"
            continue
        fi
    fi
    
    printf "[$test_num/$TOTAL] %-30s ... " "$test_name"
    
    # Compile test
    if ! compile_test "$test_name" > /dev/null 2>&1; then
        echo -e "${RED}COMPILE ERROR${NC}"
        FAILED=$((FAILED + 1))
        continue
    fi
    
    # Run simulation
    run_simulation "$test_name"
    result=$?
    
    case $result in
        0)
            echo -e "${GREEN}PASS ✓${NC}"
            PASSED=$((PASSED + 1))
            ;;
        1)
            echo -e "${RED}FAIL ✗${NC}"
            FAILED=$((FAILED + 1))
            echo ""
            echo "  → Check waveform: ${RESULTS_DIR}/${test_name}.vcd"
            echo "  → Check disassembly: ${UNIT_TEST_DIR}/${test_name}.disasm"
            echo "  → Check log: ${RESULTS_DIR}/${test_name}.log"
            echo ""
            # Stop on first failure
            break
            ;;
        3)
            echo -e "${YELLOW}TIMEOUT ⏱${NC}"
            TIMEOUT=$((TIMEOUT + 1))
            echo ""
            echo "  → Check waveform: ${RESULTS_DIR}/${test_name}.vcd"
            echo "  → Check log: ${RESULTS_DIR}/${test_name}.log"
            echo ""
            # Stop on timeout
            break
            ;;
        *)
            echo -e "${RED}ERROR${NC}"
            FAILED=$((FAILED + 1))
            break
            ;;
    esac
done

# Summary
echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo "Total:   $TOTAL"
echo -e "Passed:  ${GREEN}$PASSED${NC}"
echo -e "Failed:  ${RED}$FAILED${NC}"
echo -e "Timeout: ${YELLOW}$TIMEOUT${NC}"
echo ""

if [ $FAILED -eq 0 ] && [ $TIMEOUT -eq 0 ] && [ $PASSED -eq $TOTAL ]; then
    echo -e "${GREEN}All tests passed! ✓${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi
```

## 5. Usage Instructions

### Initial Setup

```bash
# 1. Create directory structure
cd test
mkdir -p unit

# 2. Copy boot.s and link.ld
cp isa/boot.s unit/
cp isa/link.ld unit/

# 3. Create all test files (use the content above)
# Create common.h and all test_*.c files in test/unit/

# 4. Create enhanced testbench
# Create tb_debug.sv in test/

# 5. Create automation script
# Create run_all_tests.sh in test/
chmod +x run_all_tests.sh

# 6. Ensure ram.mi and led.mi exist in project root
cd ..
touch ram.mi led.mi  # Or use existing files
```

### Running Tests

```bash
# Run all tests
cd test
./run_all_tests.sh

# Continue from a specific test (after fixing an issue)
./run_all_tests.sh --continue-from test_1_4_stack_usage

# Run a single test manually
cd unit
riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 \
    -ffreestanding -nostdlib -static \
    -fno-pic -fno-pie -Og -g \
    -Wl,-T,link.ld -Wl,--gc-sections \
    boot.s test_1_1_simple_call.c -o test_1_1_simple_call.elf

riscv64-unknown-elf-objcopy -O binary test_1_1_simple_call.elf test_1_1_simple_call.bin
hexdump -v -e '1/4 "%08x\n"' test_1_1_simple_call.bin > test_1_1_simple_call.mi
cp test_1_1_simple_call.mi ../../rom.mi

cd ..
iverilog -g2012 -DENABLE_TRACE -o test.vvp tb_debug.sv ../cpu.sv
vvp test.vvp
```

### Debugging Failed Tests

```bash
# View waveform
surfer test/results_YYYYMMDD_HHMMSS/test_1_4_stack_usage.vcd

# View disassembly
less test/unit/test_1_4_stack_usage.disasm

# View execution log
less test/results_YYYYMMDD_HHMMSS/test_1_4_stack_usage.log

# View compilation log
less test/unit/test_1_4_stack_usage.compile.log
```

## 6. Expected Output

### Successful Run
```
==========================================
CPU Verification Suite
==========================================
Total tests: 9
Results directory: results_20260220_210000

[1/9] test_1_1_simple_call         ... PASS ✓
[2/9] test_1_2_return_value        ... PASS ✓
[3/9] test_1_3_single_arg          ... PASS ✓
[4/9] test_1_4_stack_usage         ... PASS ✓
[5/9] test_1_5_nested_calls        ... PASS ✓
[6/9] test_1_6_global_read         ... PASS ✓
[7/9] test_1_7_global_write        ... PASS ✓
[8/9] test_1_8_func_global         ... PASS ✓
[9/9] test_1_9_array_access        ... PASS ✓

==========================================
Test Summary
==========================================
Total:   9
Passed:  9
Failed:  0
Timeout: 0

All tests passed! ✓
```

### Failed Test
```
==========================================
CPU Verification Suite
==========================================
Total tests: 9
Results directory: results_20260220_210000

[1/9] test_1_1_simple_call         ... PASS ✓
[2/9] test_1_2_return_value        ... PASS ✓
[3/9] test_1_3_single_arg          ... PASS ✓
[4/9] test_1_4_stack_usage         ... FAIL ✗

  → Check waveform: results_20260220_210000/test_1_4_stack_usage.vcd
  → Check disassembly: unit/test_1_4_stack_usage.disasm
  → Check log: results_20260220_210000/test_1_4_stack_usage.log

==========================================
Test Summary
==========================================
Total:   9
Passed:  3
Failed:  1
Timeout: 0

Some tests failed.
```

## 7. Integration with Existing Workflow

This automation complements the existing verification:

1. **Unit tests** (this guide) - Find the specific bug
2. **Integration test** (existing `test/isa/integration_test.c`) - Verify comprehensive functionality
3. **Application tests** (existing `apps/`) - Verify real-world usage

Workflow:
1. Run unit tests → Find which operation fails
2. Fix the bug in `cpu.sv`
3. Rerun unit tests → Verify fix
4. Run integration test → Verify no regressions
5. Run application tests → Verify real-world functionality

## 8. Troubleshooting

### Script doesn't run
```bash
chmod +x test/run_all_tests.sh
```

### Compilation errors
- Check that `boot.s` and `link.ld` are in `test/unit/`
- Verify RISC-V toolchain is installed: `riscv64-unknown-elf-gcc --version`

### Simulation errors
- Ensure `ram.mi` and `led.mi` exist in project root
- Check iverilog version: `iverilog -V`

### All tests timeout
- CPU might be stuck in reset or not fetching instructions
- Check waveform to see if PC is incrementing
- Verify ROM is loaded correctly

## Next Steps

After creating these files:
1. Run the test suite
2. Identify which test fails first
3. Use the waveform and disassembly to debug
4. Fix the issue in `cpu.sv`
5. Rerun tests to verify
6. Repeat until all tests pass
