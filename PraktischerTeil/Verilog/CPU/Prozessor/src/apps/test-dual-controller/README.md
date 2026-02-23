# Dual Controller Test Application

This application demonstrates the dual PS2 DualShock controller support by displaying two independently controlled cursors on the LED matrix.

## Features

- **P1 Controller** (Red cursor): Controls a red 3x3 cursor starting at position (16, 32)
- **P2 Controller** (Blue cursor): Controls a blue 3x3 cursor starting at position (48, 32)
- Both cursors can be moved independently using the D-pad on each controller
- Cursors are constrained to the 64x64 display area

## Memory Addresses

- **P1 Controller**: `0x0003_0000`
- **P2 Controller**: `0x0003_0004`

## Controls

### Player 1 (Red Cursor)
- **D-Pad**: Move cursor up/down/left/right

### Player 2 (Blue Cursor)
- **D-Pad**: Move cursor up/down/left/right

## Building

```bash
just build
```

## Installing

To install the ROM and RAM files to the parent directory for simulation:

```bash
just install
```

## Running

After installing, run the simulation from the project root:

```bash
make sim
```

## Expected Behavior

1. Two cursors appear on the display (red on left, blue on right)
2. Each controller independently controls its respective cursor
3. Cursors move smoothly across the display
4. Cursors cannot move outside the display boundaries

## Testing Checklist

- [ ] P1 controller moves red cursor
- [ ] P2 controller moves blue cursor
- [ ] Both controllers work simultaneously
- [ ] Cursors stay within display bounds
- [ ] No interference between controllers

## Implementation Details

- Uses memory-mapped I/O to read controller states
- Implements simple cursor rendering with 3x3 pixel blocks
- Color coding: Red (0b100) for P1, Blue (0b001) for P2
- Delay loop for smooth movement (~50,000 iterations)

## Troubleshooting

### P2 cursor doesn't move
- Verify P2 controller is connected to correct pins (see PINOUT.md)
- Check that P2 SPI controller is instantiated in cpu.sv
- Verify address decoding logic in FSM MEMORY2 stage

### Both cursors move together
- Check address decoding (bit 2 should select controller)
- Verify controller_state_p2 is properly wired

### Cursors flicker
- Increase delay loop iterations
- Check framebuffer write timing
