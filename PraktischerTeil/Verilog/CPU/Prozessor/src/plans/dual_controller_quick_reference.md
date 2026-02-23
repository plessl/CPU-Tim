# Dual Controller Quick Reference Card

## Memory Addresses
```c
#define CONTROLLER_P1  0x00030000  // Player 1
#define CONTROLLER_P2  0x00030004  // Player 2
```

## Pin Assignments

| Signal | P1 Pin | P2 Pin |
|--------|--------|--------|
| CS_N   | F5     | G5     |
| MOSI   | G7     | G8     |
| MISO   | H8     | H7     |
| SCLK   | H5     | J5     |

## Button Bit Map (Active-High)

```
Bit 15: LEFT      Bit 7:  SQUARE
Bit 14: DOWN      Bit 6:  CROSS
Bit 13: RIGHT     Bit 5:  CIRCLE
Bit 12: UP        Bit 4:  TRIANGLE
Bit 11: START     Bit 3:  R1
Bit 10: R3        Bit 2:  L1
Bit 9:  L3        Bit 1:  R2
Bit 8:  SELECT    Bit 0:  L2
```

## C Code Template

```c
#include <stdint.h>

#define CONTROLLER_P1 ((volatile uint16_t*)0x00030000)
#define CONTROLLER_P2 ((volatile uint16_t*)0x00030004)

// D-Pad
#define BTN_UP     (1 << 12)
#define BTN_DOWN   (1 << 14)
#define BTN_LEFT   (1 << 15)
#define BTN_RIGHT  (1 << 13)

// Face buttons
#define BTN_TRIANGLE (1 << 4)
#define BTN_CIRCLE   (1 << 5)
#define BTN_CROSS    (1 << 6)
#define BTN_SQUARE   (1 << 7)

// Shoulder buttons
#define BTN_L1 (1 << 2)
#define BTN_L2 (1 << 0)
#define BTN_R1 (1 << 3)
#define BTN_R2 (1 << 1)

// Other
#define BTN_SELECT (1 << 8)
#define BTN_START  (1 << 11)
#define BTN_L3     (1 << 9)
#define BTN_R3     (1 << 10)

void game_loop(void) {
    while (1) {
        uint16_t p1 = *CONTROLLER_P1;
        uint16_t p2 = *CONTROLLER_P2;
        
        if (p1 & BTN_UP) {
            // P1 pressed UP
        }
        
        if (p2 & BTN_UP) {
            // P2 pressed UP
        }
    }
}
```

## Assembly Code Template

```assembly
.equ CONTROLLER_P1, 0x00030000
.equ CONTROLLER_P2, 0x00030004

.equ BTN_UP,    0x1000
.equ BTN_DOWN,  0x4000
.equ BTN_LEFT,  0x8000
.equ BTN_RIGHT, 0x2000

game_loop:
    # Read P1
    li   t0, CONTROLLER_P1
    lw   t1, 0(t0)
    
    # Read P2
    li   t0, CONTROLLER_P2
    lw   t2, 0(t0)
    
    # Check P1 UP
    li   t3, BTN_UP
    and  t4, t1, t3
    bnez t4, p1_up_pressed
    
    # Check P2 UP
    and  t4, t2, t3
    bnez t4, p2_up_pressed
    
    j game_loop
```

## Implementation Checklist

### Hardware Changes
- [ ] Add P2 I/O ports to `topmodule`
- [ ] Declare `controller_state_p2` wire
- [ ] Instantiate `spi_ctrl_p2` module
- [ ] Add `controller_state_p2` to FSM interface
- [ ] Update FSM instantiation with P2 signal
- [ ] Modify MEMORY2 address decoding for P2

### Pin Constraints
- [ ] Rename P1 signals in Prozessor.cst
- [ ] Add P2 pin constraints to Prozessor.cst

### Documentation
- [ ] Update PINOUT.md with P1/P2 sections
- [ ] Update architecture.md memory map
- [ ] Update README.md peripherals section

### Testing
- [ ] Create test application
- [ ] Simulate and verify waveforms
- [ ] Test on hardware with two controllers

## Common Code Patterns

### Reading Both Controllers
```c
uint16_t p1 = *CONTROLLER_P1;
uint16_t p2 = *CONTROLLER_P2;
```

### Checking Specific Button
```c
if (p1 & BTN_START) {
    // P1 pressed START
}
```

### Checking Multiple Buttons
```c
if ((p1 & (BTN_UP | BTN_RIGHT)) == (BTN_UP | BTN_RIGHT)) {
    // P1 pressed UP and RIGHT simultaneously
}
```

### Debouncing (Simple)
```c
static uint16_t p1_prev = 0;
uint16_t p1 = *CONTROLLER_P1;
uint16_t p1_pressed = p1 & ~p1_prev;  // Rising edge
p1_prev = p1;

if (p1_pressed & BTN_START) {
    // START was just pressed (not held)
}
```

## Address Decoding Logic

```
Address bits [31:16] = 0x0003 → SPI controller range
Address bit [2]:
  - 0 → P1 controller (0x0003_0000)
  - 1 → P2 controller (0x0003_0004)
```

## Timing Characteristics

- **Polling Rate**: ~66 Hz per controller
- **Transaction Time**: ~10 ms per poll
- **Idle Delay**: ~5 ms between polls
- **Update Latency**: <15 ms typical

## Troubleshooting

### P2 Always Reads 0x0000
- Check P2 SPI controller instantiation
- Verify P2 pins in Prozessor.cst
- Check cable connections

### P2 Reads Same as P1
- Verify address decoding logic (bit 2)
- Check FSM MEMORY2 stage implementation

### Buttons Inverted
- Buttons should be active-high in software
- Hardware inverts active-low controller signals
- Check `controller_state` assignment in SPI module

## File Locations

| File | Purpose |
|------|---------|
| [`cpu.sv`](../cpu.sv) | Hardware implementation |
| [`Prozessor.cst`](../Prozessor.cst) | Pin constraints |
| [`PINOUT.md`](../PINOUT.md) | Pin documentation |
| [`plans/controller_register_bits.md`](controller_register_bits.md) | Button mapping details |
| [`plans/dual_controller_design.md`](dual_controller_design.md) | Design specification |
| [`plans/dual_controller_implementation_guide.md`](dual_controller_implementation_guide.md) | Implementation guide |

## Example Applications

- **Dual Cursor**: Two players control separate cursors
- **2-Player Snake**: Classic snake game with two players
- **Pong**: Paddle game with two controllers
- **Fighting Game**: Simple 2-player combat game

## Performance Notes

- Both controllers poll independently at full rate
- No performance degradation vs single controller
- CPU can read either controller at any time
- No synchronization required between controllers
