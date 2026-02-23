# PS2 Dualshock 2 Controller Register Bit Mapping

## Overview

The PS2 Dualshock 2 controller state is accessible via memory-mapped I/O at address `0x0003_0000`. The controller state is stored in a 16-bit register where each bit represents a button. The hardware automatically inverts the active-low signals from the controller to provide active-high logic in software (bit = 1 when button is pressed).

## Memory-Mapped Address

- **Base Address**: `0x0003_0000`
- **Register Size**: 32-bit (only lower 16 bits used)
- **Access**: Read-only
- **Update Rate**: Continuous polling by SPI controller

## Bit Mapping (Descending Order)

### Bits 31-16: Unused (Reserved)

```
Bit 31: Reserved (0)
Bit 30: Reserved (0)
Bit 29: Reserved (0)
Bit 28: Reserved (0)
Bit 27: Reserved (0)
Bit 26: Reserved (0)
Bit 25: Reserved (0)
Bit 24: Reserved (0)
Bit 23: Reserved (0)
Bit 22: Reserved (0)
Bit 21: Reserved (0)
Bit 20: Reserved (0)
Bit 19: Reserved (0)
Bit 18: Reserved (0)
Bit 17: Reserved (0)
Bit 16: Reserved (0)
```

### Bits 15-0: Controller Buttons (Active-High)

```
Bit 15: LEFT    - D-Pad Left button
Bit 14: DOWN    - D-Pad Down button
Bit 13: RIGHT   - D-Pad Right button
Bit 12: UP      - D-Pad Up button
Bit 11: START   - START button
Bit 10: R3      - Right analog stick button (press down)
Bit  9: L3      - Left analog stick button (press down)
Bit  8: SELECT  - SELECT button
Bit  7: □       - Square button
Bit  6: ✕       - Cross button
Bit  5: ○       - Circle button
Bit  4: △       - Triangle button
Bit  3: R1      - Right shoulder button 1
Bit  2: L1      - Left shoulder button 1
Bit  1: R2      - Right shoulder button 2
Bit  0: L2      - Left shoulder button 2
```

## Hardware Implementation Details

### SPI Protocol

The controller uses SPI Mode 3:
- **Clock Polarity (CPOL)**: 1 (idle high)
- **Clock Phase (CPHA)**: 1 (data captured on rising edge)
- **Bit Order**: LSB first
- **Message Format**: 5 bytes TX, 5 bytes RX

### Message Structure

```
TX: 01 42 00 00 00
RX: FF 41 5A [byte3] [byte4]
          ├┘  └┬─┘
          ID   └─ Button data (active-low)
```

### Hardware Inversion

The SPI controller module inverts the button data to provide active-high logic:

```systemverilog
controller_state <= ~{recv_msg[3], recv_msg[4]};
```

This means:
- **Hardware wire**: Button pressed = 0 (active-low)
- **Software register**: Button pressed = 1 (active-high)

## Usage Examples

### C Code

```c
// Memory-mapped SPI controller
volatile uint32_t * const spi = (volatile uint32_t *) 0x00030000;

// Button bit masks
#define BTN_LEFT   0x8000  // Bit 15
#define BTN_DOWN   0x4000  // Bit 14
#define BTN_RIGHT  0x2000  // Bit 13
#define BTN_UP     0x1000  // Bit 12
#define BTN_START  0x0800  // Bit 11
#define BTN_R3     0x0400  // Bit 10
#define BTN_L3     0x0200  // Bit  9
#define BTN_SELECT 0x0100  // Bit  8
#define BTN_SQUARE 0x0080  // Bit  7
#define BTN_CROSS  0x0040  // Bit  6
#define BTN_CIRCLE 0x0020  // Bit  5
#define BTN_TRIANGLE 0x0010 // Bit  4
#define BTN_R1     0x0008  // Bit  3
#define BTN_L1     0x0004  // Bit  2
#define BTN_R2     0x0002  // Bit  1
#define BTN_L2     0x0001  // Bit  0

// Read controller state
uint32_t controller = *spi;

// Check individual buttons
if (controller & BTN_LEFT) {
    // Left button is pressed
}

if (controller & BTN_START) {
    // START button is pressed
}
```

### Assembly Code

```assembly
# Load controller state
li   t0, 0x00030000    # SPI controller base address
lw   t1, 0(t0)         # Read controller state

# Check LEFT button (bit 15)
li   t2, 0x8000
and  t3, t1, t2
bnez t3, left_pressed

# Check START button (bit 11)
li   t2, 0x0800
and  t3, t1, t2
bnez t3, start_pressed
```

## Verified Button Values (from Logic Analyzer Traces)

When a button is pressed, the corresponding bit is set to 1 (after hardware inversion):

| Button | Hex Value | Binary (bits 15-0) | Active Bit |
|--------|-----------|-------------------|------------|
| LEFT   | 0x8000 | 1000 0000 0000 0000 | Bit 15 |
| DOWN   | 0x4000 | 0100 0000 0000 0000 | Bit 14 |
| RIGHT  | 0x2000 | 0010 0000 0000 0000 | Bit 13 |
| UP     | 0x1000 | 0001 0000 0000 0000 | Bit 12 |
| START  | 0x0800 | 0000 1000 0000 0000 | Bit 11 |
| R3     | 0x0400 | 0000 0100 0000 0000 | Bit 10 |
| L3     | 0x0200 | 0000 0010 0000 0000 | Bit  9 |
| SELECT | 0x0100 | 0000 0001 0000 0000 | Bit  8 |
| SQUARE | 0x0080 | 0000 0000 1000 0000 | Bit  7 |
| CROSS  | 0x0040 | 0000 0000 0100 0000 | Bit  6 |
| CIRCLE | 0x0020 | 0000 0000 0010 0000 | Bit  5 |
| TRIANGLE | 0x0010 | 0000 0000 0001 0000 | Bit  4 |
| R1     | 0x0008 | 0000 0000 0000 1000 | Bit  3 |
| L1     | 0x0004 | 0000 0000 0000 0100 | Bit  2 |
| R2     | 0x0002 | 0000 0000 0000 0010 | Bit  1 |
| L2     | 0x0001 | 0000 0000 0000 0001 | Bit  0 |

## References

- **Hardware Implementation**: [`cpu.sv`](../cpu.sv) lines 155-339 (SPI controller module)
- **Button Mapping**: [`Logbook-Captain.md`](../Logbook-Captain.md) lines 13-58
- **Usage Example**: [`apps/snake/main.c`](../apps/snake/main.c) lines 31-36
- **Memory Map**: [`README.md`](../README.md) and [`Agents.md`](../Agents.md)

## Notes

1. **Multiple Buttons**: Multiple buttons can be pressed simultaneously. The register value will be the bitwise OR of all pressed buttons.

2. **Polling Rate**: The SPI controller continuously polls the game controller. Software reads always get the most recent state.

3. **No Analog Data**: This implementation only reads digital button states. Analog stick positions and pressure-sensitive button data are not captured.

4. **Debouncing**: No hardware debouncing is implemented. Software should implement debouncing if needed.

5. **Compatibility**: Designed for PS2 Dualshock 2 controllers. Other controllers may have different button mappings.
