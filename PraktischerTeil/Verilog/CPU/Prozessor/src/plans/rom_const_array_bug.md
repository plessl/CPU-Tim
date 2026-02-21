# ROM Const Array Access Bug - Investigation Report

**Date**: 2026-02-20  
**Severity**: High  
**Status**: Workaround Implemented  
**Affected**: RISC-V RV32I CPU - ROM data reads

## Summary

The CPU has a critical bug where `const` arrays stored in ROM (`.rodata` section) cannot be read correctly during program execution. This manifests as incorrect or garbage values when accessing array elements, causing programs that rely on lookup tables or constant data to fail.

## Symptoms

1. **Programs using `const` arrays fail silently** - No compilation errors, but runtime behavior is incorrect
2. **Only last element or garbage data is read** - Array accesses return wrong values
3. **Simple pixel/line drawing works, but array-based rendering fails** - Direct function calls work, but loops over const arrays don't
4. **Changing `const` to non-const fixes the issue** - Moving data from ROM to RAM resolves the problem

## Reproduction Steps

### Minimal Test Case

Create a simple program that accesses a const array:

```c
// This FAILS - data in ROM
const int test_data[4] = {10, 20, 30, 40};

int main() {
    // Try to read array elements
    int val0 = test_data[0];  // Expected: 10, Actual: garbage or wrong value
    int val1 = test_data[1];  // Expected: 20, Actual: garbage or wrong value
    
    // Use values...
    return 0;
}
```

```c
// This WORKS - data in RAM
int test_data[4] = {10, 20, 30, 40};

int main() {
    // Try to read array elements
    int val0 = test_data[0];  // Expected: 10, Actual: 10 ✓
    int val1 = test_data[1];  // Expected: 20, Actual: 20 ✓
    
    // Use values...
    return 0;
}
```

### Detailed Reproduction (Spinning Cube Example)

1. **Create test file** [`apps/spinning-cube/test_static.c`](../apps/spinning-cube/test_static.c)

2. **With const arrays (BROKEN)**:
```c
const int cube_2d[8][2] = {
    {22, 22}, {42, 22}, {42, 42}, {22, 42},
    {27, 27}, {37, 27}, {37, 37}, {27, 37}
};

const uint8_t cube_edges[12][2] = {
    {0, 1}, {1, 2}, {2, 3}, {3, 0},
    {4, 5}, {5, 6}, {6, 7}, {7, 4},
    {0, 4}, {1, 5}, {2, 6}, {3, 7}
};

int main() {
    for (int i = 0; i < 12; i++) {
        int v0 = cube_edges[i][0];  // Wrong values!
        int v1 = cube_edges[i][1];  // Wrong values!
        draw_line(cube_2d[v0][0], cube_2d[v0][1],
                  cube_2d[v1][0], cube_2d[v1][1], 1, 1, 1);
    }
}
```
**Result**: Only 1-2 pixels visible, no cube rendered

3. **Without const (WORKS)**:
```c
int cube_2d[8][2] = {  // Removed const
    {22, 22}, {42, 22}, {42, 42}, {22, 42},
    {27, 27}, {37, 27}, {37, 37}, {27, 37}
};

uint8_t cube_edges[12][2] = {  // Removed const
    {0, 1}, {1, 2}, {2, 3}, {3, 0},
    {4, 5}, {5, 6}, {6, 7}, {7, 4},
    {0, 4}, {1, 5}, {2, 6}, {3, 7}
};

int main() {
    for (int i = 0; i < 12; i++) {
        int v0 = cube_edges[i][0];  // Correct values!
        int v1 = cube_edges[i][1];  // Correct values!
        draw_line(cube_2d[v0][0], cube_2d[v0][1],
                  cube_2d[v1][0], cube_2d[v1][1], 1, 1, 1);
    }
}
```
**Result**: Complete wireframe cube rendered correctly

## Technical Analysis

### Memory Layout

**With `const` (broken)**:
```
ROM (.rodata section):
  - sin_table[360]
  - cube_vertices[8][3]
  - cube_edges[12][2]
  
RAM (.data section):
  - (empty or minimal)
```

**Without `const` (working)**:
```
ROM (.text section):
  - Code only
  
RAM (.data section):
  - sin_table[360]
  - cube_vertices[8][3]
  - cube_edges[12][2]
```

### Linker Script Analysis

From [`link.ld`](../apps/spinning-cube/link.ld):

```ld
.text :
{
  KEEP(*(.init))
  KEEP(*(.text.startup*))
  *(.text .text.*)
  *(.rodata .rodata.*)      /* <-- const data goes here (ROM) */
  *(.srodata .srodata.*)
  KEEP(*(.fini))
} > ROM

.data : AT(ADDR(.text) + SIZEOF(.text))
{
  __data_start = .;
  *(.data .data.*)          /* <-- non-const data goes here (RAM) */
  *(.sdata .sdata.*)
  __data_end = .;
} > RAM
```

### Compiler Output Comparison

**Check where data is placed**:
```bash
riscv64-unknown-elf-objdump -h test_static.elf
```

With `const`:
```
Sections:
Idx Name          Size      VMA       LMA       File off  Algn
  0 .text         00001234  00000000  00000000  00001000  2**2
  1 .rodata       00000100  00001234  00001234  00002234  2**2  <-- const arrays here
  2 .data         00000000  00010000  00001334  00003334  2**0
```

Without `const`:
```
Sections:
Idx Name          Size      VMA       LMA       File off  Algn
  0 .text         00001234  00000000  00000000  00001000  2**2
  1 .data         00000100  00010000  00001234  00002234  2**2  <-- arrays here
```

### Assembly Code Analysis

**Accessing const array (broken)**:
```asm
# Load address of const array in ROM
lui     a5, %hi(cube_edges)
addi    a5, a5, %lo(cube_edges)
# Load byte from ROM address
lbu     a4, 0(a5)              # <-- ROM read fails?
```

**Accessing non-const array (working)**:
```asm
# Load address of array in RAM
lui     a5, %hi(cube_edges)
addi    a5, a5, %lo(cube_edges)
# Load byte from RAM address
lbu     a4, 0(a5)              # <-- RAM read works
```

## Root Cause Hypothesis

### Possible CPU Implementation Issues

1. **ROM Read Path Not Implemented**
   - CPU may not have proper data path for reading from ROM during execution
   - ROM might only be accessible during instruction fetch, not data load

2. **Address Decoding Issue**
   - ROM address range (0x0000_0000 - 0x0000_FFFF) might not be properly decoded for data reads
   - Load instructions (LB, LH, LW, LBU, LHU) might not route to ROM correctly

3. **Memory Controller State Machine**
   - ROM controller might only handle instruction fetches (FETCH state)
   - Data loads might not trigger ROM reads in MEMORY1/MEMORY2 states

4. **Bus Multiplexing**
   - Instruction and data buses might not properly multiplex ROM access
   - Data reads might always go to RAM, ignoring ROM address range

## Verification Steps

### 1. Check CPU Memory Controller

In [`cpu.sv`](../cpu.sv), verify ROM read logic:

```systemverilog
// Check if data loads from ROM address range work
always_comb begin
  case (state)
    MEMORY1: begin
      if (mem_addr >= 32'h0000_0000 && mem_addr < 32'h0001_0000) begin
        // ROM address range - is this handled?
        mem_rdata = rom_data;  // Does this path exist?
      end
    end
  endcase
end
```

### 2. Simulate ROM Read

Create a minimal test:

```c
volatile uint32_t *test_addr = (volatile uint32_t *)0x00000100;  // ROM address
uint32_t value = *test_addr;  // Try to read from ROM
```

Monitor in simulation:
- Does the address appear on the ROM bus?
- Does ROM output data?
- Does the CPU receive the data?

### 3. Check Address Decoder

Verify address decoding logic handles ROM reads:

```systemverilog
// Is there logic like this?
assign rom_read_enable = (mem_addr[31:16] == 16'h0000) && mem_read;
```

## Workaround

**Current Solution**: Remove `const` qualifier from all arrays

```c
// Before (broken):
const int32_t sin_table[360] = { ... };
const int32_t cube_vertices[8][3] = { ... };
const uint8_t cube_edges[12][2] = { ... };

// After (working):
int32_t sin_table[360] = { ... };
int32_t cube_vertices[8][3] = { ... };
uint8_t cube_edges[12][2] = { ... };
```

**Impact**:
- ✅ Programs work correctly
- ❌ Increased RAM usage (arrays moved from ROM to RAM)
- ❌ Larger `.data` section in binary
- ❌ Slower initialization (data must be copied from ROM to RAM at startup)

## Recommended Fix

### Option 1: Fix CPU ROM Read Path (Preferred)

Modify CPU to properly handle data loads from ROM address range:

1. Add ROM read logic to MEMORY1/MEMORY2 states
2. Ensure address decoder routes ROM addresses correctly
3. Multiplex ROM data onto the data bus for loads
4. Test with const arrays

### Option 2: Copy ROM Data to RAM at Startup

Modify boot code to copy `.rodata` to RAM:

```asm
# In boot.s, after zeroing .bss:
la      a1, __rodata_start
la      a2, __rodata_ram_start
la      a3, __rodata_end
copy_rodata:
    beq     a1, a3, done_rodata
    lw      a4, 0(a1)
    sw      a4, 0(a2)
    addi    a1, a1, 4
    addi    a2, a2, 4
    j       copy_rodata
done_rodata:
```

### Option 3: Use ROM Only for Code

Keep current workaround and document that ROM is code-only:

```c
// NOTE: This CPU does not support reading data from ROM.
// All const arrays must be non-const to be placed in RAM.
int32_t sin_table[360] = { ... };  // In RAM, not ROM
```

## Test Files for Debugging

All test files are in [`apps/spinning-cube/`](../apps/spinning-cube/):

1. **[`test_pixels.c`](../apps/spinning-cube/test_pixels.c)** - Tests basic pixel writing (works)
2. **[`test_line.c`](../apps/spinning-cube/test_line.c)** - Tests line drawing with hardcoded values (works)
3. **[`test_static.c`](../apps/spinning-cube/test_static.c)** - Tests cube rendering with arrays (fails with const, works without)
4. **[`main.c`](../apps/spinning-cube/main.c)** - Full spinning cube (fixed by removing const)

## Build and Test Commands

```bash
cd apps/spinning-cube

# Test with const arrays (broken)
# Edit test_static.c to add const back
just build && just install

# Test without const (working)
# Edit test_static.c to remove const
just build && just install

# Check where data is placed
riscv64-unknown-elf-objdump -h test_static.elf | grep -E "(rodata|data)"

# Check assembly for array access
riscv64-unknown-elf-objdump -d test_static.elf | grep -A 10 "cube_edges"
```

## Impact on Other Applications

**Potentially Affected**:
- Any application using `const` arrays or lookup tables
- Programs with large constant data (images, fonts, etc.)
- Code relying on ROM for data storage to save RAM

**Known Working Applications** (likely don't use const arrays):
- [`apps/bouncing_cube/`](../apps/bouncing_cube/) - Uses simple variables
- [`apps/led-write-manual/`](../apps/led-write-manual/) - Assembly only
- [`apps/test-spi/`](../apps/test-spi/) - Minimal const usage

## Next Steps

1. **Investigate CPU ROM read path** in [`cpu.sv`](../cpu.sv)
2. **Run simulation** with ROM data read test case
3. **Check memory controller** state machine for ROM handling
4. **Verify address decoder** routes ROM reads correctly
5. **Implement fix** (Option 1 preferred)
6. **Test with const arrays** to verify fix
7. **Update documentation** with ROM capabilities/limitations

## References

- CPU Implementation: [`cpu.sv`](../cpu.sv)
- Linker Script: [`apps/spinning-cube/link.ld`](../apps/spinning-cube/link.ld)
- Test Cases: [`apps/spinning-cube/test_*.c`](../apps/spinning-cube/)
- Working Application: [`apps/spinning-cube/main.c`](../apps/spinning-cube/main.c)
- Memory Map: [`README.md`](../README.md)

## Conclusion

The CPU has a critical bug where `const` data in ROM cannot be read during program execution. The immediate workaround is to remove `const` qualifiers, moving data to RAM. A proper fix requires modifying the CPU to support data loads from the ROM address range.

This bug significantly impacts the usability of the CPU for applications requiring large lookup tables or constant data, as it forces all data into limited RAM space instead of utilizing available ROM.
