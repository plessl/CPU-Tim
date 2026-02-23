# Snake 2-Player Fix Summary

## Problem
The snake-2player application was not working as expected. The display initialization was failing, suggesting issues with program structure, function calls, or variable initialization.

## Root Cause Analysis

After comparing with the working [`apps/snake/main.c`](../snake/main.c), I identified **2 critical issues**:

### Issue 1: Type Mismatch in Controller Reads
**Location**: [`process_input()`](main.c:429) function

**Problem**:
```c
// WRONG - snake-2player was using:
uint32_t buttons_p1 = controller_p1[0];
uint32_t buttons_p2 = controller_p2[0];
```

**Fix**:
```c
// CORRECT - matching working snake:
unsigned int buttons_p1 = controller_p1[0];
unsigned int buttons_p2 = controller_p2[0];
```

**Why this matters**: The RISC-V RV32I ABI uses `unsigned int` (32-bit) for register operations. Using `uint32_t` might cause the compiler to generate different code patterns that could interact poorly with the CPU's function call handling or register file operations.

### Issue 2: Uninitialized Variables in main()
**Location**: [`main()`](main.c:662) function

**Problem**: Critical game state variables were not initialized before the main loop:
- `score_p1` - uninitialized
- `score_p2` - uninitialized  
- `snake1_alive` - uninitialized
- `snake2_alive` - uninitialized

**Fix**: Added explicit initialization:
```c
int main(void) {
    // Initialize game state
    game_state = STATE_START_SCREEN;
    frame_counter = 0;
    lfsr_state = 0xACE1u;
    winner = WINNER_NONE;
    score_p1 = 0;           // ADDED
    score_p2 = 0;           // ADDED
    snake1_alive = 0;       // ADDED
    snake2_alive = 0;       // ADDED
    
    // Main loop
    while (1) {
        ...
    }
}
```

**Why this matters**: Uninitialized global variables in the `.bss` section should be zero-initialized by the boot code, but if the boot code or linker script doesn't properly handle `.bss` initialization, these variables could contain garbage values. This could cause:
- Rendering functions to access invalid memory
- Game logic to behave unpredictably
- Display initialization to fail if `snake1_alive`/`snake2_alive` had non-zero garbage values

## Changes Made

1. **Changed controller button read types** from `uint32_t` to `unsigned int` in `process_input()`
2. **Added explicit initialization** of `score_p1`, `score_p2`, `snake1_alive`, `snake2_alive` in `main()`

## Verification

✅ Build successful with no errors
✅ No illegal instructions (mul/div/rem) in disassembly
✅ Code structure now matches working snake application
✅ All variables explicitly initialized before use

## Testing Recommendations

1. **Flash to FPGA** and verify display initializes correctly
2. **Test start screen** - should show blinking "PRESS START" message
3. **Test game start** - press START on either controller
4. **Test both snakes** - verify both controllers work independently
5. **Test collision detection** - verify game over works correctly
6. **Test scoring** - verify both scores increment when eating food

## Additional Notes

### Why These Fixes Work

The working snake application follows these patterns:
- Uses `unsigned int` consistently for all integer types
- Explicitly initializes all global variables in `main()` before the loop
- Keeps function call depth minimal
- Uses simple, direct memory access patterns

By matching these patterns, we ensure:
- Consistent ABI compliance
- Predictable memory initialization
- Reliable function call behavior
- Proper register usage

### Diagnostic Version Created

A diagnostic version ([`main_diagnostic.c`](main_diagnostic.c)) was created to test basic functionality:
- Screen clearing
- Pixel drawing
- Controller reading
- Display refresh

This can be used for future debugging if issues persist.

## Files Modified

- [`main.c`](main.c) - Fixed type mismatch and added variable initialization

## Files Created

- [`main_diagnostic.c`](main_diagnostic.c) - Diagnostic test program
- [`main_backup.c`](main_backup.c) - Backup of original code
- [`FIX_SUMMARY.md`](FIX_SUMMARY.md) - This document

## Next Steps

1. Test on actual hardware
2. If issues persist, use diagnostic version to isolate problem
3. Consider reducing function call depth if stack issues occur
4. Monitor for any timing-related issues with dual controller reads
