# Verification Guide: RISC-V RV32I Core

This guide explains how to run the verification suite and evaluate the results to debug the CPU core.

## 1. Building the Test Software

The tests are located in `test/isa/`. You must compile them into a memory initialization file (`rom.mi`) before running the simulation.

### C Integration Test
This test validates function calls, recursion, stack spilling, and global variable access.
```bash
cd test/isa
just build          # Default: -Og
# OR
just build OPT="-O0" # Stress-test stack usage
just install        # Copies rom.mi to the project root
```

### Assembly Test
This test validates basic RV32I arithmetic and control flow instructions.
```bash
cd test/isa
just build-asm
just install
```

## 2. Running the Simulation

Navigate to the project root and use Icarus Verilog to run the comprehensive testbench.

**Note:** The simulation requires `ram.mi` and `led.mi` files to be present in the root directory for memory initialization.

```bash
cd ../..
# Compile the RTL and Testbench
iverilog -g2012 -o tb_comprehensive.vvp test/tb_comprehensive.sv cpu.sv

# Run the simulation (Silent mode)
vvp tb_comprehensive.vvp

# Run with instruction tracing enabled
iverilog -g2012 -DENABLE_TRACE -o tb_comprehensive.vvp test/tb_comprehensive.sv cpu.sv
vvp tb_comprehensive.vvp
```

## 3. Evaluating Results

### Terminal Output
The testbench automatically monitors memory writes to the "Magic Address" `0x0001_FFFC`.
- **`TEST PASSED`**: The software reached the end of its verification routine successfully.
- **`TEST FAILED`**: The software detected a mismatch in expected values and signaled a failure.
- **`TIMEOUT`**: The CPU likely entered an infinite loop or crashed.

### Waveform Analysis (Surfer)
If a test fails, analyze the `tb_comprehensive.vcd` file using **Surfer**.

```bash
surfer --state-file test/tb_comprehensive.surfer.ron tb_comprehensive.vcd
```

**Note:** If you encounter errors loading the state file, ensure that the `.surfer.ron` file is correctly formatted and does not have any trailing characters in its filename.

#### Key Signals to Inspect:
1.  **`PC` & `FSM State`**: Identify the exact instruction where the failure occurred.
2.  **`regfile[1]` (ra)**: Check if the return address is correct after a `jal` or `jalr`.
3.  **`regfile[2]` (sp)**: Ensure the stack pointer is correctly decremented in the function prologue and restored in the epilogue.
4.  **`bus_addr` & `bus_wdata`**: Verify that global variables are being read from/written to the correct addresses in the `0x0001_xxxx` range.

## 4. Debugging Workflow
1.  **Reproduce**: Run `just build` and `vvp` to confirm the failure.
2.  **Locate**: Use the `integration_test.disasm` file to map the failing `PC` from the waveform back to the C code.
3.  **Fix**: Modify the logic in `cpu.sv`.
4.  **Verify**: Re-run the simulation to ensure the test now passes.
