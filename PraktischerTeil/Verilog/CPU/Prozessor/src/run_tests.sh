#!/bin/bash

# CPU Verification Test Runner
# Run from project root directory

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
UNIT_TEST_DIR="test/unit"
TESTBENCH="test/tb_debug.sv"
CPU_MODULE="cpu.sv"

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
RESULTS_DIR="test_results_$(date +%Y%m%d_%H%M%S)"
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
    
    # Generate memory initialization file for ROM (code + rodata)
    hexdump -v -e '1/4 "%08x\n"' "${test_name}.bin" > "${test_name}.mi"
    
    # Extract .data section and create RAM initialization file
    riscv64-unknown-elf-objcopy -O binary --only-section=.data "${test_name}.elf" "${test_name}.data.bin"
    if [ -s "${test_name}.data.bin" ]; then
        # .data section exists and is non-empty
        hexdump -v -e '1/4 "%08x\n"' "${test_name}.data.bin" > "${test_name}.data.mi"
        # Pad to start at RAM address 0x10000 (word address 0x4000)
        # Create ram.mi with zeros up to .data start, then .data content
        python3 -c "
import sys
# Read data section
with open('${test_name}.data.mi', 'r') as f:
    data_lines = f.readlines()
# Write ram.mi with data at correct offset
with open('../../ram.mi', 'w') as f:
    # Write zeros for addresses before .data (0x0000 to 0x0FFF in RAM = 0x10000 to 0x10FFF absolute)
    # .data starts at 0x10000, which is offset 0 in RAM
    # Just write the data section content
    for line in data_lines:
        f.write(line)
"
    else
        # No .data section, create empty ram.mi
        touch "../../ram.mi"
    fi
    
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
        -o "$vvp_file" "$TESTBENCH" "$CPU_MODULE" 2>&1 > "${RESULTS_DIR}/${test_name}.iverilog.log"
    
    if [ $? -ne 0 ]; then
        echo "Error: iverilog compilation failed"
        cat "${RESULTS_DIR}/${test_name}.iverilog.log"
        return 2
    fi
    
    # Run simulation (with background timeout for macOS compatibility)
    vvp "$vvp_file" > "$log_file" 2>&1 &
    local vvp_pid=$!
    local timeout_secs=10
    local elapsed=0
    
    # Wait for process with timeout
    while kill -0 $vvp_pid 2>/dev/null && [ $elapsed -lt $timeout_secs ]; do
        sleep 1
        elapsed=$((elapsed + 1))
    done
    
    # Kill if still running
    if kill -0 $vvp_pid 2>/dev/null; then
        kill -9 $vvp_pid 2>/dev/null
        wait $vvp_pid 2>/dev/null
        local exit_code=124  # Timeout exit code
    else
        wait $vvp_pid
        local exit_code=$?
    fi
    
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
