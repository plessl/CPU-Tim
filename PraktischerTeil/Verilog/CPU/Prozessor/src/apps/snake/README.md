# Snake Game

Classic snake game implementation for the RISC-V RV32I FPGA Core with PS2 Dualshock 2 controller.

## Features

- **Growing Snake**: Snake starts with 5 segments and grows when eating food
- **Controller Input**: Full directional control using D-pad
- **Collision Detection**: Game over when hitting walls or self
- **Score Tracking**: Score displayed at game over screen
- **Start Screen**: Animated start screen with blinking prompt
- **Restart**: Press START button to begin new game

## Controls

| Button | Action |
|--------|--------|
| **D-Pad Up** | Move snake up |
| **D-Pad Down** | Move snake down |
| **D-Pad Left** | Move snake left |
| **D-Pad Right** | Move snake right |
| **START** | Start game / Restart after game over |

## Game Rules

1. **Objective**: Eat as much food as possible to grow the snake
2. **Food**: Red 2×2 blocks appear randomly on screen
3. **Growth**: Snake grows by 1 segment each time it eats food
4. **Score**: Score increases by 1 for each food eaten
5. **Game Over**: Hitting walls or snake's own body ends the game
6. **Speed**: Snake moves at medium speed (200ms per move)

## Technical Details

### CPU Constraints Handled

This implementation carefully avoids CPU limitations:

- ✅ **No const arrays**: All data in RAM (not ROM) due to ROM read bug
- ✅ **No multiplication**: Uses shift operations (`y << 6` instead of `y * 64`)
- ✅ **No division**: Uses repeated subtraction for digit extraction
- ✅ **No modulo**: Uses bitwise AND for wrapping (`& 0xFF`, `& 0x3F`)

### Data Structures

**Circular Buffer for Snake**:
- 256-element arrays for X and Y coordinates
- Head and tail indices wrap at 256 using `& 0xFF`
- O(1) add head, O(1) remove tail operations

**LFSR Random Number Generator**:
- 16-bit Linear Feedback Shift Register
- Polynomial: 0xB400
- Generates pseudo-random food positions

**Score Display**:
- 5×7 pixel digit patterns (0-9)
- Supports scores up to 999
- Digits extracted using repeated subtraction

### Memory Usage

| Component | Size |
|-----------|------|
| Snake X coordinates | 256 bytes |
| Snake Y coordinates | 256 bytes |
| Digit patterns | 50 bytes |
| Game variables | ~50 bytes |
| **Total** | **~612 bytes** |

## Building

```bash
# Build the application
just build

# Install ROM/RAM files to parent directory
just install

# Simulate (from project root)
cd ../..
make sim
```

## File Structure

```
apps/snake/
├── main.c          # Complete game implementation
├── boot.s          # Boot code and startup
├── link.ld         # Linker script
├── justfile        # Build automation
└── README.md       # This file
```

## Implementation Highlights

### Snake Movement Algorithm

```c
// Calculate new head position
new_x = snake_x[snake_head_idx];
new_y = snake_y[snake_head_idx];

// Move based on direction
if (direction == DIR_UP) new_y--;
// ... (other directions)

// Add new head
snake_head_idx = (snake_head_idx + 1) & 0xFF;
snake_x[snake_head_idx] = new_x;
snake_y[snake_head_idx] = new_y;

// If food eaten: grow (don't remove tail)
// Else: remove tail (move without growing)
if (!food_eaten) {
    snake_tail_idx = (snake_tail_idx + 1) & 0xFF;
}
```

### Framebuffer Addressing (No Multiplication)

```c
// WRONG: fb[y * 64 + x] = color;
// RIGHT: Use shift operation
unsigned int addr = (y << 6) + x;  // y * 64 + x
fb[addr] = color;
```

### Random Position Generation (No Modulo)

```c
// LFSR generates 16-bit random number
unsigned int r = lfsr_next();

// Extract 6 bits for range [0, 63]
unsigned char pos = (unsigned char)(r & 0x3F);
```

### Score Digit Extraction (No Division)

```c
// Extract hundreds digit
unsigned char hundreds = 0;
while (score >= 100) {
    score = score - 100;
    hundreds++;
}

// Extract tens digit
unsigned char tens = 0;
while (score >= 10) {
    score = score - 10;
    tens++;
}

// Ones digit is remainder
unsigned char ones = score;
```

## Game States

```
START_SCREEN → (START button) → PLAYING → (collision) → GAME_OVER
     ↑                                                        ↓
     └────────────────── (START button) ────────────────────┘
```

### Start Screen
- Displays blinking "PRESS START" prompt
- Waits for START button press

### Playing
- Snake moves continuously in current direction
- Player controls direction with D-pad
- Food spawns randomly when eaten
- Collision detection active

### Game Over
- Displays "GAME OVER" message
- Shows final score as 3-digit number
- Displays blinking "PRESS START" to restart

## Performance

- **Frame Rate**: ~166 FPS (6ms per frame)
- **Snake Speed**: 200ms per move (32 frames)
- **Input Latency**: <6ms (polled every frame)
- **Rendering**: Full screen clear + redraw each frame

## Known Limitations

1. **No pause**: Game cannot be paused during play
2. **Fixed speed**: Snake speed doesn't increase with score
3. **Simple graphics**: Minimal text/graphics due to display size
4. **Score limit**: Display limited to 3 digits (0-999)

## Future Enhancements

Possible improvements:
- Increase speed as score increases
- Add high score tracking
- Add pause functionality (SELECT button)
- Add obstacles or walls
- Improve start screen graphics

## References

- Design Document: [`plans/snake_game_design.md`](../../plans/snake_game_design.md)
- CPU Architecture: [`README.md`](../../README.md)
- ROM Bug Info: [`plans/rom_const_array_bug.md`](../../plans/rom_const_array_bug.md)
