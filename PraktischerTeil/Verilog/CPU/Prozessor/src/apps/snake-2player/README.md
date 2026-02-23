# Two-Player Snake Game

Competitive two-player snake game for the RISC-V RV32I FPGA Core with dual PS2 Dualshock 2 controller support.

## Features

- **Two Independent Snakes**: Player 1 (green) and Player 2 (yellow)
- **Dual Controller Support**: Each player uses their own PS2 controller
- **Competitive Gameplay**: First to reach food gets the point
- **Multiple Collision Types**: Wall, self, and snake-to-snake collisions
- **Winner Determination**: P1 wins, P2 wins, or draw
- **Score Tracking**: Individual scores displayed at game over

## Controls

### Player 1 (Green Snake)
- **Controller**: Port 1 (0x00030000)
- **D-Pad**: Movement control
- **START**: Start/restart game

### Player 2 (Yellow Snake)
- **Controller**: Port 2 (0x00030004)
- **D-Pad**: Movement control
- **START**: Start/restart game

## Game Rules

1. **Objective**: Eat food to grow your snake and outlast your opponent
2. **Food**: Red 2×2 blocks appear randomly on screen
3. **Growth**: First snake to reach food gets the point and grows
4. **Game Over**: Game ends when either snake collides with:
   - Wall (screen edges)
   - Itself (own body)
   - Other snake (opponent's body)
5. **Winner**: 
   - If only one snake dies → Other player wins
   - If both snakes die simultaneously → Draw

## Starting Positions

- **Player 1 (Green)**: Starts at left side (x=16, y=32), moving RIGHT
- **Player 2 (Yellow)**: Starts at right side (x=48, y=32), moving LEFT

## Visual Design

| Element | Color | RGB Value |
|---------|-------|-----------|
| Player 1 Snake | Green | 0b010 (2) |
| Player 2 Snake | Yellow | 0b110 (6) |
| Food | Red | 0b100 (4) |
| Background | Black | 0b000 (0) |
| UI Text | White | 0b111 (7) |

## Technical Details

### CPU Constraints Handled

- ✅ **No const arrays**: All data in RAM (not ROM)
- ✅ **No multiplication**: Uses shift operations (`y << 6`)
- ✅ **No division**: Uses repeated subtraction
- ✅ **No modulo**: Uses bitwise AND (`& 0xFF`, `& 0x3F`)

### Memory Usage

| Component | Size |
|-----------|------|
| Snake 1 data | 512 bytes |
| Snake 2 data | 512 bytes |
| Shared state | ~100 bytes |
| **Total** | **~1,124 bytes** |

### Performance

- **Frame Rate**: ~166 FPS (6ms per frame)
- **Snake Speed**: 200ms per move (32 frames)
- **Input Latency**: <6ms (polled every frame)

## Building

```bash
# Build the application
just build

# Install ROM/RAM files to parent directory
just install

# Simulate (from project root)
cd ../..
make sim

# Check for illegal instructions
just check

# View memory usage
just size
```

## File Structure

```
apps/snake-2player/
├── main.c          # Complete two-player implementation
├── boot.s          # Boot code and startup
├── link.ld         # Linker script
├── justfile        # Build automation
└── README.md       # This file
```

## Implementation Highlights

### Dual Snake Management

Each snake has independent:
- Position arrays (256 elements each)
- Head/tail indices
- Direction state
- Alive status
- Score counter

### Collision Detection

```c
// Check all collision types for each snake
1. Wall collision → DEAD
2. Self-collision → DEAD
3. Other snake collision → DEAD
4. Food collision → GROW
```

### Winner Determination

```c
After both snakes move:
  if (!snake1_alive && !snake2_alive) → DRAW
  else if (!snake1_alive) → P2 WINS
  else if (!snake2_alive) → P1 WINS
```

### Simultaneous Movement

Both snakes move on the same frame:
```c
if (frame_counter % FRAMES_PER_MOVE == 0) {
    move_snake1();
    move_snake2();
    check_game_over();
}
```

## Game States

```
START_SCREEN → (Either START) → PLAYING → (Collision) → GAME_OVER
     ↑                                                        ↓
     └──────────────── (Either START) ─────────────────────┘
```

### Start Screen
- Displays blinking "PRESS START" prompt
- Either player can start the game

### Playing
- Both snakes move continuously
- Players control direction with D-pad
- Food spawns randomly when eaten
- Collision detection active

### Game Over
- Displays "GAME OVER" message
- Shows both players' scores
- Highlights winner with colored box
- Either player can restart

## Known Limitations

1. **No pause**: Game cannot be paused during play
2. **Fixed speed**: Snake speed doesn't increase with score
3. **Simple graphics**: Minimal text/graphics due to display size
4. **Score limit**: Display limited to 2 digits (0-99)

## Future Enhancements

Possible improvements:
- Power-ups (speed boost, invincibility, shrink opponent)
- Obstacles or walls
- Different game modes (cooperative, time trial)
- Difficulty levels (faster speed, smaller arena)
- High score tracking
- Pause functionality

## Troubleshooting

### Issue: Snakes overlap at start
**Solution**: Check initial positions (P1 at x=16, P2 at x=48)

### Issue: Food spawns on snake
**Solution**: Verify `is_occupied()` checks both snakes

### Issue: Wrong winner displayed
**Solution**: Check winner determination logic after both snakes move

### Issue: Controller input not working
**Solution**: Verify controller addresses (P1: 0x30000, P2: 0x30004)

## References

- Design Document: [`plans/snake_2player_design.md`](../../plans/snake_2player_design.md)
- Implementation Guide: [`plans/snake_2player_implementation.md`](../../plans/snake_2player_implementation.md)
- Architecture Diagram: [`plans/snake_2player_architecture.md`](../../plans/snake_2player_architecture.md)
- Quick Start Guide: [`plans/snake_2player_quickstart.md`](../../plans/snake_2player_quickstart.md)
- Original Snake: [`apps/snake/main.c`](../snake/main.c)
- Dual Controller Reference: [`plans/dual_controller_quick_reference.md`](../../plans/dual_controller_quick_reference.md)
