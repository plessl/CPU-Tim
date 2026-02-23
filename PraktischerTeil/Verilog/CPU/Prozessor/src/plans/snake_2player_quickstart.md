# Two-Player Snake Quick Start Guide

## Overview

This guide provides step-by-step instructions to implement the two-player snake game based on the existing single-player version.

## Prerequisites

- Existing single-player snake game: [`apps/snake/main.c`](../apps/snake/main.c)
- Dual controller support enabled in hardware
- Understanding of RISC-V RV32I constraints (no M-extension)

## Quick Implementation Steps

### Step 1: Create Project Directory

```bash
cd apps/
cp -r snake snake-2player
cd snake-2player
```

### Step 2: Update Build Configuration

Edit [`justfile`](../apps/snake-2player/justfile):

```justfile
# Change app name
APP := "snake-2player"
```

### Step 3: Modify main.c - Add Dual Controller Support

**Replace single controller definition:**

```c
// OLD (single player)
volatile uint32_t * const spi = (volatile uint32_t *) 0x00030000;

// NEW (two players)
volatile uint32_t * const controller_p1 = (volatile uint32_t *) 0x00030000;
volatile uint32_t * const controller_p2 = (volatile uint32_t *) 0x00030004;
```

### Step 4: Add Player 2 Color

**Add to color definitions:**

```c
#define COLOR_BLACK  0u
#define COLOR_GREEN  2u  // Player 1
#define COLOR_RED    4u  // Food
#define COLOR_YELLOW 6u  // Player 2 (NEW)
#define COLOR_WHITE  7u
```

### Step 5: Duplicate Snake Data Structures

**Add after existing snake variables:**

```c
// Player 1 Snake (rename existing variables)
unsigned char snake1_x[MAX_SNAKE_LENGTH];
unsigned char snake1_y[MAX_SNAKE_LENGTH];
unsigned char snake1_length;
unsigned char snake1_head_idx;
unsigned char snake1_tail_idx;
unsigned char snake1_direction;
unsigned char snake1_next_direction;
unsigned char snake1_alive;  // NEW

// Player 2 Snake (NEW)
unsigned char snake2_x[MAX_SNAKE_LENGTH];
unsigned char snake2_y[MAX_SNAKE_LENGTH];
unsigned char snake2_length;
unsigned char snake2_head_idx;
unsigned char snake2_tail_idx;
unsigned char snake2_direction;
unsigned char snake2_next_direction;
unsigned char snake2_alive;  // NEW
```

**Add winner tracking:**

```c
#define WINNER_NONE   0
#define WINNER_P1     1
#define WINNER_P2     2
#define WINNER_DRAW   3

unsigned char winner;
unsigned int score_p2;  // Add P2 score
```

### Step 6: Duplicate Helper Functions

Create versions for both snakes:

```c
// Original: is_snake_at() → is_snake1_at()
// Add: is_snake2_at()
// Add: is_occupied() - checks both snakes

// Original: check_self_collision() → check_snake1_self_collision()
// Add: check_snake2_self_collision()
// Add: check_collision_with_snake1()
// Add: check_collision_with_snake2()
```

### Step 7: Update Food Spawning

**Modify spawn_food() to avoid both snakes:**

```c
void spawn_food(void) {
    unsigned char attempts = 0;
    do {
        food_x = random_pos();
        food_y = random_pos();
        
        if (food_x > 62) food_x = 62;
        if (food_y > 62) food_y = 62;
        
        attempts++;
        if (attempts > 100) break;
    } while (is_occupied(food_x, food_y) ||      // Check both snakes
             is_occupied(food_x + 1, food_y) ||
             is_occupied(food_x, food_y + 1) ||
             is_occupied(food_x + 1, food_y + 1));
}
```

### Step 8: Duplicate Movement Functions

**Create move_snake1() and move_snake2():**

Key changes from original:
- Check `snake1_alive` / `snake2_alive` before moving
- Check collision with other snake
- Set `alive = 0` on collision instead of `game_state = STATE_GAME_OVER`

```c
void move_snake1(void) {
    if (!snake1_alive) return;
    
    // ... calculate new_x, new_y ...
    
    // Check wall collision
    if (new_x < 0 || new_x >= 64 || new_y < 0 || new_y >= 64) {
        snake1_alive = 0;
        return;
    }
    
    // Check self-collision
    if (check_snake1_self_collision(new_x, new_y)) {
        snake1_alive = 0;
        return;
    }
    
    // Check collision with snake2 (NEW)
    if (check_collision_with_snake2(new_x, new_y)) {
        snake1_alive = 0;
        return;
    }
    
    // ... rest of movement logic ...
}
```

### Step 9: Update Input Handling

**Modify process_input() for dual controllers:**

```c
void process_input(void) {
    uint32_t buttons_p1 = controller_p1[0];
    uint32_t buttons_p2 = controller_p2[0];
    
    if (game_state == STATE_START_SCREEN || game_state == STATE_GAME_OVER) {
        // Either player can start
        if ((buttons_p1 & BTN_START) || (buttons_p2 & BTN_START)) {
            // Initialize both snakes
            // P1: start at (16, 32), moving RIGHT
            // P2: start at (48, 32), moving LEFT
            // ...
        }
    } else if (game_state == STATE_PLAYING) {
        // P1 input
        if (snake1_alive) {
            if (buttons_p1 & BTN_UP && snake1_direction != DIR_DOWN) {
                snake1_next_direction = DIR_UP;
            }
            // ... other directions ...
        }
        
        // P2 input
        if (snake2_alive) {
            if (buttons_p2 & BTN_UP && snake2_direction != DIR_DOWN) {
                snake2_next_direction = DIR_UP;
            }
            // ... other directions ...
        }
    }
}
```

### Step 10: Update Rendering

**Modify render_game() to draw both snakes:**

```c
void render_game(void) {
    clear_screen();
    
    // Draw food
    for (unsigned char dy = 0; dy < 2; dy++) {
        for (unsigned char dx = 0; dx < 2; dx++) {
            fb_write(food_x + dx, food_y + dy, COLOR_RED);
        }
    }
    
    // Draw snake1 (green) if alive
    if (snake1_alive) {
        unsigned char idx = snake1_tail_idx;
        unsigned char count = snake1_length;
        while (count > 0) {
            fb_write(snake1_x[idx], snake1_y[idx], COLOR_GREEN);
            idx = (idx + 1) & 0xFF;
            count--;
        }
    }
    
    // Draw snake2 (yellow) if alive
    if (snake2_alive) {
        unsigned char idx = snake2_tail_idx;
        unsigned char count = snake2_length;
        while (count > 0) {
            fb_write(snake2_x[idx], snake2_y[idx], COLOR_YELLOW);
            idx = (idx + 1) & 0xFF;
            count--;
        }
    }
}
```

**Update render_game_over() to show winner:**

```c
void render_game_over(void) {
    clear_screen();
    
    // Draw "GAME OVER" pattern
    // ...
    
    // Draw P1 score (left side)
    draw_score_2digit(score_p1, 12, 24);
    
    // Draw P2 score (right side)
    draw_score_2digit(score_p2, 44, 24);
    
    // Highlight winner with colored box
    if (winner == WINNER_P1) {
        // Green box around P1 score
    } else if (winner == WINNER_P2) {
        // Yellow box around P2 score
    } else if (winner == WINNER_DRAW) {
        // White box around both scores
    }
    
    // Draw "PRESS START" pattern
    // ...
}
```

### Step 11: Update Main Loop

**Modify main() to handle both snakes:**

```c
int main(void) {
    game_state = STATE_START_SCREEN;
    frame_counter = 0;
    lfsr_state = 0xACE1u;
    winner = WINNER_NONE;
    
    while (1) {
        process_input();
        
        if (game_state == STATE_PLAYING) {
            // Apply buffered directions
            snake1_direction = snake1_next_direction;
            snake2_direction = snake2_next_direction;
            
            // Move snakes every N frames
            if ((frame_counter & (FRAMES_PER_MOVE - 1)) == 0) {
                move_snake1();
                move_snake2();
                
                // Check if game over
                if (!snake1_alive || !snake2_alive) {
                    game_state = STATE_GAME_OVER;
                    
                    // Determine winner
                    if (!snake1_alive && !snake2_alive) {
                        winner = WINNER_DRAW;
                    } else if (!snake1_alive) {
                        winner = WINNER_P2;
                    } else {
                        winner = WINNER_P1;
                    }
                }
            }
        }
        
        render_frame();
        delay_ms(6);
        frame_counter++;
    }
    
    return 0;
}
```

## Build and Test

### Build

```bash
just build
```

**Expected output:**
- `main.elf` - Executable with debug symbols
- `main.bin` - Raw binary
- `main.mi` - Memory initialization file
- `main.disasm` - Disassembly listing

### Verify No M-Extension

```bash
grep -E "^\s+[0-9a-f]+:\s+[0-9a-f]+\s+(mul|div|rem)" main.disasm
```

**Expected:** No results (no multiply/divide/modulo instructions)

### Install

```bash
just install
```

**Copies to parent directory:**
- `imem.mi` - ROM initialization
- `dmem.mi` - RAM initialization

### Simulate

```bash
cd ../..
make sim
```

## Testing Checklist

### Basic Functionality
- [ ] Game starts with "PRESS START" screen
- [ ] Either controller can start game
- [ ] P1 (green) snake appears on left
- [ ] P2 (yellow) snake appears on right
- [ ] Food appears as red 2×2 block

### Movement
- [ ] P1 D-pad controls green snake
- [ ] P2 D-pad controls yellow snake
- [ ] Snakes cannot reverse 180°
- [ ] Snakes move at correct speed

### Collisions
- [ ] P1 dies on wall collision
- [ ] P2 dies on wall collision
- [ ] P1 dies on self-collision
- [ ] P2 dies on self-collision
- [ ] P1 dies when hitting P2
- [ ] P2 dies when hitting P1
- [ ] First snake to food gets point

### Game Over
- [ ] Game ends when either snake dies
- [ ] Winner displayed correctly (P1/P2/DRAW)
- [ ] Scores displayed correctly
- [ ] Either controller can restart

## Common Issues & Solutions

### Issue: Snakes start overlapping
**Solution:** Check initial positions (P1 at x=16, P2 at x=48)

### Issue: Food spawns on snake
**Solution:** Verify `is_occupied()` checks both snakes

### Issue: Wrong winner displayed
**Solution:** Check winner determination logic after both snakes move

### Issue: Controller input not working
**Solution:** Verify controller addresses (P1: 0x30000, P2: 0x30004)

### Issue: Colors wrong
**Solution:** Check color definitions (Green=2, Yellow=6)

### Issue: Compilation errors about multiply/divide
**Solution:** Use shift (`<< 6`) instead of multiply, repeated subtraction instead of divide

## Performance Expectations

| Metric | Expected Value |
|--------|----------------|
| Memory Usage | ~1.1KB RAM |
| Frame Rate | ~166 FPS |
| Snake Speed | 200ms per move |
| Input Latency | <6ms |

## Next Steps

After basic implementation works:

1. **Test on hardware** with two controllers
2. **Tune game balance** (speed, starting positions)
3. **Add polish** (better game over screen, animations)
4. **Consider enhancements** (power-ups, obstacles, game modes)

## Reference Documents

- **Design**: [`plans/snake_2player_design.md`](snake_2player_design.md)
- **Implementation**: [`plans/snake_2player_implementation.md`](snake_2player_implementation.md)
- **Architecture**: [`plans/snake_2player_architecture.md`](snake_2player_architecture.md)
- **Original Snake**: [`apps/snake/main.c`](../apps/snake/main.c)
- **Dual Controller**: [`plans/dual_controller_quick_reference.md`](dual_controller_quick_reference.md)

## Summary of Key Changes

| Component | Original | Two-Player |
|-----------|----------|------------|
| **Controllers** | 1 (0x30000) | 2 (0x30000, 0x30004) |
| **Snakes** | 1 (green) | 2 (green, yellow) |
| **Colors** | Green, Red, White | Green, Yellow, Red, White |
| **Collision** | Wall, Self | Wall, Self, Other Snake |
| **Winner** | N/A | P1, P2, Draw |
| **Scores** | 1 score | 2 scores |
| **Memory** | ~612 bytes | ~1,124 bytes |

## Code Modification Summary

```
Files to modify:
  ✓ main.c          - Complete rewrite with dual snake logic
  ✓ justfile        - Update APP name
  
Files to copy unchanged:
  ✓ boot.s          - No changes needed
  ✓ link.ld         - No changes needed
  
Files to create:
  ✓ README.md       - Document two-player features
```

## Estimated Implementation Time

- **Setup & file copying**: 5 minutes
- **Data structure changes**: 15 minutes
- **Movement & collision logic**: 30 minutes
- **Input handling**: 15 minutes
- **Rendering updates**: 20 minutes
- **Testing & debugging**: 30 minutes
- **Total**: ~2 hours

## Success Criteria

✅ Game compiles without errors  
✅ No M-extension instructions in disassembly  
✅ Both controllers work independently  
✅ Snakes move correctly and independently  
✅ All collision types detected correctly  
✅ Winner determined correctly  
✅ Game can be restarted  
✅ Visual appearance correct (colors, positions)  

---

**Ready to implement?** Start with Step 1 and work through sequentially. Test after each major change to catch issues early.
