# Two-Player Snake Game Design

## Overview

A competitive two-player variant of the classic snake game where two players control separate snakes (green and yellow) on the same 64×64 LED matrix display. Each player uses their own PS2 Dualshock 2 controller.

## Game Mechanics

### Win/Loss Conditions

The game ends when **either** snake collides with:
1. **Wall** - Any edge of the 64×64 screen
2. **Itself** - Its own body segments
3. **Other snake** - Any segment of the opponent's snake

**Winner Determination**:
- If only one snake dies → Other player wins
- If both snakes die simultaneously → Draw (both lose)

### Gameplay Flow

```
START_SCREEN → (Either START button) → PLAYING → (collision) → GAME_OVER
     ↑                                                              ↓
     └──────────────── (Either START button) ─────────────────────┘
```

### Food System

- **Single food item** shared between both players
- **2×2 red block** spawns at random empty positions
- **First snake to reach food** gets the point and grows
- Food respawns immediately after being eaten
- Food cannot spawn on either snake's body

## Visual Design

### Color Scheme

| Element | Color | RGB Value |
|---------|-------|-----------|
| **Player 1 Snake** | Green | `0b010` (2) |
| **Player 2 Snake** | Yellow | `0b110` (6) |
| **Food** | Red | `0b100` (4) |
| **Background** | Black | `0b000` (0) |
| **UI Text** | White | `0b111` (7) |

### Screen Layout

```
┌────────────────────────────────────────────────────────┐
│                    64×64 Display                       │
│                                                        │
│  P1 (Green)                           P2 (Yellow)     │
│  starts left                          starts right    │
│                                                        │
│                    Food (Red 2×2)                      │
│                                                        │
└────────────────────────────────────────────────────────┘
```

## Data Structures

### Snake Storage (Per Player)

Each snake uses the same circular buffer approach as the original:

```c
// Player 1 Snake
unsigned char snake1_x[MAX_SNAKE_LENGTH];
unsigned char snake1_y[MAX_SNAKE_LENGTH];
unsigned char snake1_length;
unsigned char snake1_head_idx;
unsigned char snake1_tail_idx;
unsigned char snake1_direction;
unsigned char snake1_next_direction;
unsigned char snake1_alive;  // NEW: Track if snake is alive

// Player 2 Snake
unsigned char snake2_x[MAX_SNAKE_LENGTH];
unsigned char snake2_y[MAX_SNAKE_LENGTH];
unsigned char snake2_length;
unsigned char snake2_head_idx;
unsigned char snake2_tail_idx;
unsigned char snake2_direction;
unsigned char snake2_next_direction;
unsigned char snake2_alive;  // NEW: Track if snake is alive
```

### Memory Usage

| Component | Size | Notes |
|-----------|------|-------|
| Snake 1 X coords | 256 bytes | Circular buffer |
| Snake 1 Y coords | 256 bytes | Circular buffer |
| Snake 2 X coords | 256 bytes | Circular buffer |
| Snake 2 Y coords | 256 bytes | Circular buffer |
| Digit patterns | 50 bytes | Score display |
| Game variables | ~100 bytes | State, scores, etc. |
| **Total** | **~1,124 bytes** | Fits in 64KB RAM |

## Controller Mapping

### Player 1 (Green Snake)
- **Address**: `0x00030000`
- **D-Pad**: Movement control
- **START**: Start/restart game

### Player 2 (Yellow Snake)
- **Address**: `0x00030004`
- **D-Pad**: Movement control
- **START**: Start/restart game

### Button Definitions

```c
#define CONTROLLER_P1 ((volatile uint32_t*)0x00030000)
#define CONTROLLER_P2 ((volatile uint32_t*)0x00030004)

#define BTN_LEFT  0x8000
#define BTN_DOWN  0x4000
#define BTN_RIGHT 0x2000
#define BTN_UP    0x1000
#define BTN_START 0x0800
```

## Game Logic

### Initialization

**Player 1 (Green)**:
- Start position: `(20, 32)` - Left side of screen
- Initial direction: `DIR_RIGHT`
- Initial length: 5 segments

**Player 2 (Yellow)**:
- Start position: `(44, 32)` - Right side of screen
- Initial direction: `DIR_LEFT`
- Initial length: 5 segments

**Food**:
- Random position avoiding both snakes

### Movement Algorithm

Both snakes move simultaneously every N frames:

```c
// Pseudo-code for each frame
if (frame_counter % FRAMES_PER_MOVE == 0) {
    if (snake1_alive) {
        move_snake(&snake1);
        check_collisions(&snake1, &snake2);
    }
    
    if (snake2_alive) {
        move_snake(&snake2);
        check_collisions(&snake2, &snake1);
    }
}
```

### Collision Detection

**Wall Collision**:
```c
if (new_x < 0 || new_x >= 64 || new_y < 0 || new_y >= 64) {
    snake_alive = 0;
    game_state = STATE_GAME_OVER;
}
```

**Self-Collision**:
```c
if (check_self_collision(snake, new_x, new_y)) {
    snake_alive = 0;
    game_state = STATE_GAME_OVER;
}
```

**Other Snake Collision**:
```c
if (check_other_snake_collision(other_snake, new_x, new_y)) {
    snake_alive = 0;
    game_state = STATE_GAME_OVER;
}
```

**Food Collision**:
```c
if (check_food_collision(new_x, new_y)) {
    snake_length++;
    score++;
    spawn_food();  // Avoid both snakes
}
```

### Simultaneous Death Detection

```c
// After both snakes move
if (!snake1_alive && !snake2_alive) {
    winner = DRAW;
} else if (!snake1_alive) {
    winner = PLAYER_2;
} else if (!snake2_alive) {
    winner = PLAYER_1;
}
```

## Input Handling

### Dual Controller Input

```c
void process_input(void) {
    uint32_t buttons_p1 = CONTROLLER_P1[0];
    uint32_t buttons_p2 = CONTROLLER_P2[0];
    
    // Start screen: Either player can start
    if (game_state == STATE_START_SCREEN || game_state == STATE_GAME_OVER) {
        if ((buttons_p1 & BTN_START) || (buttons_p2 & BTN_START)) {
            init_game();
            game_state = STATE_PLAYING;
        }
    }
    
    // Playing: Each player controls their snake
    if (game_state == STATE_PLAYING) {
        // Player 1 input
        if (snake1_alive) {
            if (buttons_p1 & BTN_UP && snake1_direction != DIR_DOWN) {
                snake1_next_direction = DIR_UP;
            }
            // ... other directions
        }
        
        // Player 2 input
        if (snake2_alive) {
            if (buttons_p2 & BTN_UP && snake2_direction != DIR_DOWN) {
                snake2_next_direction = DIR_UP;
            }
            // ... other directions
        }
    }
}
```

### Direction Buffering

Each snake maintains separate direction buffers to prevent 180° turns:
- `snake1_direction` - Current direction
- `snake1_next_direction` - Buffered next direction
- `snake2_direction` - Current direction
- `snake2_next_direction` - Buffered next direction

## Rendering

### Frame Rendering Order

1. **Clear screen** - Set all pixels to black
2. **Draw food** - Red 2×2 block
3. **Draw Player 1 snake** - Green segments (if alive)
4. **Draw Player 2 snake** - Yellow segments (if alive)
5. **Draw UI** - Scores, game over messages

### Game Over Screen

```
┌────────────────────────────────────────┐
│          GAME OVER                     │
│                                        │
│  P1: [score]        P2: [score]       │
│                                        │
│  Winner: [P1/P2/DRAW]                 │
│                                        │
│  PRESS START                           │
└────────────────────────────────────────┘
```

### Score Display

- **Player 1 Score**: Left side of screen
- **Player 2 Score**: Right side of screen
- **Format**: 2-digit numbers (0-99)

## Performance Considerations

### Frame Rate
- **Target**: ~166 FPS (6ms per frame)
- **Snake Speed**: 200ms per move (32 frames)
- **No performance impact** from dual controllers

### Optimization Strategies

1. **Shared food spawn logic** - Single LFSR for randomness
2. **Efficient collision checks** - Early exit on first collision
3. **Minimal screen clears** - Full clear each frame (simple)
4. **No multiplication** - Use shift operations (`<< 6` for `* 64`)

## Technical Constraints

### CPU Limitations (RV32I)

✅ **Handled**:
- No const arrays (all data in RAM)
- No multiplication (use shifts: `y << 6`)
- No division (use repeated subtraction)
- No modulo (use bitwise AND: `& 0xFF`, `& 0x3F`)

### Memory Constraints

- **RAM Available**: 64KB
- **RAM Used**: ~1.1KB
- **Plenty of headroom** for future features

## Implementation Phases

### Phase 1: Core Mechanics
1. Duplicate snake data structures
2. Implement dual controller input
3. Implement simultaneous movement
4. Basic collision detection

### Phase 2: Collision Logic
1. Wall collision for both snakes
2. Self-collision for both snakes
3. Snake-to-snake collision
4. Food collision (first-come-first-served)

### Phase 3: Game Flow
1. Start screen (either player can start)
2. Game over detection
3. Winner determination
4. Restart logic

### Phase 4: Visual Polish
1. Color differentiation (green vs yellow)
2. Score display for both players
3. Winner announcement
4. Start screen animation

## Testing Strategy

### Unit Tests
- [ ] Snake 1 movement in all directions
- [ ] Snake 2 movement in all directions
- [ ] Snake 1 wall collision
- [ ] Snake 2 wall collision
- [ ] Snake 1 self-collision
- [ ] Snake 2 self-collision
- [ ] Snake-to-snake collision
- [ ] Food collision (both snakes)
- [ ] Simultaneous death detection

### Integration Tests
- [ ] Full game playthrough (P1 wins)
- [ ] Full game playthrough (P2 wins)
- [ ] Full game playthrough (draw)
- [ ] Restart after game over
- [ ] Food spawning avoids both snakes

### Hardware Tests
- [ ] Dual controller input
- [ ] Visual appearance on LED matrix
- [ ] Performance (no lag)

## File Structure

```
apps/snake-2player/
├── main.c          # Complete 2-player implementation
├── boot.s          # Boot code (copy from snake/)
├── link.ld         # Linker script (copy from snake/)
├── justfile        # Build automation
└── README.md       # Documentation
```

## Future Enhancements

Possible improvements:
- **Power-ups**: Speed boost, invincibility, etc.
- **Obstacles**: Static walls or moving hazards
- **Game modes**: Cooperative mode, time trial
- **Difficulty levels**: Faster speed, smaller arena
- **High score tracking**: Best scores for each player

## References

- Original Snake Game: [`apps/snake/main.c`](../apps/snake/main.c)
- Dual Controller Test: [`apps/test-dual-controller/main.c`](../apps/test-dual-controller/main.c)
- Controller Reference: [`plans/dual_controller_quick_reference.md`](dual_controller_quick_reference.md)
- Snake Design Doc: [`plans/snake_game_design.md`](snake_game_design.md)
