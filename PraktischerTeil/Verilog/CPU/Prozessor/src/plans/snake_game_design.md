# Snake Game - Design Specification

**Date**: 2026-02-21  
**Target**: RISC-V RV32I FPGA Core (64x64 LED Matrix)  
**Application**: [`apps/snake/`](../apps/snake/)

---

## Overview

Classic snake game implementation for the RISC-V RV32I processor with PS2 Dualshock 2 controller input and 64x64 LED matrix display.

### Game Features

- **Snake Movement**: Continuous movement with directional control via game controller
- **Growing Snake**: Snake grows when eating food (starts at 5 segments)
- **Collision Detection**: Game over when hitting walls or self
- **Score Tracking**: Score displayed at game over screen
- **Start Screen**: Animated start screen with "PRESS START" prompt
- **Game States**: Start screen → Playing → Game over → Restart

### Technical Constraints

**CRITICAL**: This CPU has specific limitations that must be followed:

1. ❌ **NO const arrays** - ROM data reads don't work (see [`rom_const_array_bug.md`](rom_const_array_bug.md))
2. ❌ **NO multiplication/division** - CPU doesn't implement M-extension
3. ❌ **NO modulo operator** - Use bitwise AND for power-of-2 wrapping
4. ✅ **Use shift operations** for multiply/divide by powers of 2
5. ✅ **Use lookup tables** in RAM (not ROM) for complex calculations

---

## Game Specifications (Preset B)

| Parameter | Value | Notes |
|-----------|-------|-------|
| **Snake Speed** | 200ms per move | Medium difficulty |
| **Initial Length** | 5 segments | Good starting size |
| **Start Screen** | Animated | Simple animation loop |
| **Score Display** | Game over only | Shown as number pattern |
| **Food Size** | 2x2 pixels | Better visibility |
| **Food Color** | Red (4) | Distinct from snake |
| **Snake Color** | Green (2) | Classic snake color |
| **Background** | Black (0) | Clear contrast |
| **Game Over Color** | White (7) | High visibility |

---

## System Architecture

### Game State Machine

```
┌─────────────┐
│ START_SCREEN│
│             │
│ - Show title│
│ - Animate   │
│ - Wait START│
└──────┬──────┘
       │ START button pressed
       ▼
┌─────────────┐
│   PLAYING   │
│             │
│ - Move snake│
│ - Check food│
│ - Check coll│
└──────┬──────┘
       │ Collision detected
       ▼
┌─────────────┐
│ GAME_OVER   │
│             │
│ - Show score│
│ - Wait START│
└──────┬──────┘
       │ START button pressed
       │
       └──────► (back to START_SCREEN)
```

### Memory Layout

```
RAM (.data section):
├── Snake body buffer [256 segments max]
│   ├── x coordinates [256 bytes]
│   └── y coordinates [256 bytes]
├── Game state variables
│   ├── snake_length (current length)
│   ├── snake_head_idx (circular buffer index)
│   ├── snake_tail_idx (circular buffer index)
│   ├── direction (current direction)
│   ├── next_direction (buffered input)
│   ├── food_x, food_y (food position)
│   ├── score (current score)
│   └── game_state (enum)
├── Digit patterns for score display [10 patterns × 5×7 pixels]
└── Animation frame counter

Total RAM usage: ~3KB (well within 64KB limit)
```

---

## Data Structures

### Snake Representation

**Circular Buffer Design** (efficient for growing/shrinking):

```c
// Snake body storage (NOT const - must be in RAM)
unsigned char snake_x[256];  // X coordinates of each segment
unsigned char snake_y[256];  // Y coordinates of each segment

// Snake state
unsigned char snake_length;      // Current length (5 to 256)
unsigned char snake_head_idx;    // Index of head in circular buffer
unsigned char snake_tail_idx;    // Index of tail in circular buffer

// Direction encoding (1-4, never 0)
#define DIR_UP    1
#define DIR_DOWN  2
#define DIR_LEFT  3
#define DIR_RIGHT 4

unsigned char direction;         // Current movement direction
unsigned char next_direction;    // Buffered direction (prevents 180° turns)
```

**Why Circular Buffer?**
- No array shifting needed when snake moves
- O(1) add head, O(1) remove tail
- Simple index arithmetic (no multiplication)
- Wraps automatically with `& 0xFF` (256 = 2^8)

### Game State

```c
// Game state enum
#define STATE_START_SCREEN  0
#define STATE_PLAYING       1
#define STATE_GAME_OVER     2

unsigned char game_state;

// Food position
unsigned char food_x;
unsigned char food_y;

// Score
unsigned int score;  // 32-bit for large scores

// Timing
unsigned int frame_counter;  // For animations and delays
```

### Display Patterns

**Digit Patterns for Score Display** (5×7 pixels each):

```c
// NOT const - must be in RAM due to ROM read bug
// Each digit is 5 bytes (5 columns × 7 rows, packed as bits)
unsigned char digit_patterns[10][5] = {
    // 0
    {0b01110, 0b10001, 0b10001, 0b10001, 0b01110},
    // 1
    {0b00100, 0b01100, 0b00100, 0b00100, 0b01110},
    // 2
    {0b01110, 0b10001, 0b00010, 0b00100, 0b11111},
    // ... (digits 3-9)
};
```

---

## Core Algorithms

### 1. Snake Movement (No Multiplication)

**Challenge**: Calculate framebuffer address without multiplication

**Solution**: Use shift and add for `row * 64 + col`

```c
// WRONG (uses multiplication):
// fb[y * 64 + x] = color;

// CORRECT (uses shift):
// y * 64 = y << 6 (shift left by 6 = multiply by 64)
unsigned int addr = (y << 6) + x;
fb[addr] = color;
```

**Movement Algorithm**:

```c
void move_snake() {
    // Calculate new head position based on direction
    unsigned char new_x = snake_x[snake_head_idx];
    unsigned char new_y = snake_y[snake_head_idx];
    
    if (direction == DIR_UP) {
        new_y = new_y - 1;  // Will wrap to 63 if at 0
    } else if (direction == DIR_DOWN) {
        new_y = new_y + 1;
        if (new_y >= 64) new_y = 0;
    } else if (direction == DIR_LEFT) {
        new_x = new_x - 1;  // Will wrap to 63 if at 0
    } else if (direction == DIR_RIGHT) {
        new_x = new_x + 1;
        if (new_x >= 64) new_x = 0;
    }
    
    // Check collision BEFORE adding new head
    if (check_collision(new_x, new_y)) {
        game_state = STATE_GAME_OVER;
        return;
    }
    
    // Add new head
    snake_head_idx = (snake_head_idx + 1) & 0xFF;  // Wrap at 256
    snake_x[snake_head_idx] = new_x;
    snake_y[snake_head_idx] = new_y;
    
    // Check if food eaten
    if (check_food_collision(new_x, new_y)) {
        snake_length++;
        score++;
        spawn_food();  // Don't remove tail (snake grows)
    } else {
        // Remove tail (snake moves without growing)
        snake_tail_idx = (snake_tail_idx + 1) & 0xFF;
    }
}
```

### 2. Collision Detection

**Wall Collision**: Check if head is out of bounds

```c
int check_wall_collision(unsigned char x, unsigned char y) {
    // Since we're using unsigned char, values wrap automatically
    // But we need to check if we hit the boundary
    return (x >= 64 || y >= 64);
}
```

**Self Collision**: Check if head overlaps any body segment

```c
int check_self_collision(unsigned char x, unsigned char y) {
    // Check all body segments except the tail (which will move)
    unsigned char idx = snake_tail_idx;
    unsigned char count = snake_length - 1;  // Don't check new head
    
    while (count > 0) {
        idx = (idx + 1) & 0xFF;
        if (snake_x[idx] == x && snake_y[idx] == y) {
            return 1;  // Collision!
        }
        count--;
    }
    return 0;  // No collision
}
```

### 3. Food Spawning (No Division/Modulo)

**Challenge**: Generate pseudo-random position without modulo operator

**Solution**: Use Linear Feedback Shift Register (LFSR) + bitwise AND

```c
// LFSR state (must be non-zero)
unsigned int lfsr_state = 0xACE1u;  // Seed value

// Generate pseudo-random number (16-bit LFSR)
unsigned int lfsr_next() {
    unsigned int lsb = lfsr_state & 1;
    lfsr_state = lfsr_state >> 1;
    if (lsb) {
        lfsr_state = lfsr_state ^ 0xB400u;  // Polynomial for 16-bit LFSR
    }
    return lfsr_state;
}

// Get random position in range [0, 63]
unsigned char random_pos() {
    unsigned int r = lfsr_next();
    // Use only lower 6 bits (0-63)
    return (unsigned char)(r & 0x3F);
}

void spawn_food() {
    // Keep trying until we find empty position
    do {
        food_x = random_pos();
        food_y = random_pos();
    } while (is_snake_at(food_x, food_y));
}

int is_snake_at(unsigned char x, unsigned char y) {
    unsigned char idx = snake_tail_idx;
    unsigned char count = snake_length;
    
    while (count > 0) {
        if (snake_x[idx] == x && snake_y[idx] == y) {
            return 1;
        }
        idx = (idx + 1) & 0xFF;
        count--;
    }
    return 0;
}
```

### 4. Food Collision (2×2 Block)

```c
int check_food_collision(unsigned char x, unsigned char y) {
    // Food is 2×2 block at (food_x, food_y)
    // Check if head overlaps any of the 4 pixels
    if (x >= food_x && x < food_x + 2 &&
        y >= food_y && y < food_y + 2) {
        return 1;
    }
    return 0;
}
```

### 5. Score Display (Number Patterns)

**Challenge**: Display score as digits without font library

**Solution**: Use 5×7 pixel digit patterns

```c
void draw_digit(unsigned char digit, unsigned char start_x, unsigned char start_y) {
    // Draw 5×7 digit pattern
    for (unsigned char col = 0; col < 5; col++) {
        unsigned char pattern = digit_patterns[digit][col];
        for (unsigned char row = 0; row < 7; row++) {
            if (pattern & (1 << row)) {
                unsigned int addr = ((start_y + row) << 6) + start_x + col;
                fb[addr] = COLOR_WHITE;
            }
        }
    }
}

void draw_score(unsigned int score) {
    // Extract digits without division
    // For scores up to 999, we need 3 digits
    
    // Hundreds digit (score / 100)
    unsigned char hundreds = 0;
    unsigned int temp = score;
    while (temp >= 100) {
        temp = temp - 100;
        hundreds++;
    }
    
    // Tens digit ((score % 100) / 10)
    unsigned char tens = 0;
    while (temp >= 10) {
        temp = temp - 10;
        tens++;
    }
    
    // Ones digit (score % 10)
    unsigned char ones = temp;
    
    // Draw digits centered on screen
    draw_digit(hundreds, 20, 28);
    draw_digit(tens, 28, 28);
    draw_digit(ones, 36, 28);
}
```

---

## Controller Input Handling

### Button Mapping

```c
#define BTN_LEFT  0x8000
#define BTN_DOWN  0x4000
#define BTN_RIGHT 0x2000
#define BTN_UP    0x1000
#define BTN_START 0x0800

volatile unsigned int * const spi = (volatile unsigned int *) 0x00030000;
```

### Input Processing

```c
void process_input() {
    unsigned int buttons = spi[0];
    
    if (game_state == STATE_START_SCREEN || game_state == STATE_GAME_OVER) {
        // Wait for START button
        if (buttons & BTN_START) {
            start_game();
        }
    } else if (game_state == STATE_PLAYING) {
        // Buffer direction change (prevents 180° turns)
        if (buttons & BTN_UP && direction != DIR_DOWN) {
            next_direction = DIR_UP;
        } else if (buttons & BTN_DOWN && direction != DIR_UP) {
            next_direction = DIR_DOWN;
        } else if (buttons & BTN_LEFT && direction != DIR_RIGHT) {
            next_direction = DIR_LEFT;
        } else if (buttons & BTN_RIGHT && direction != DIR_LEFT) {
            next_direction = DIR_RIGHT;
        }
    }
}
```

---

## Rendering System

### Frame Update Strategy

```c
void render_frame() {
    if (game_state == STATE_START_SCREEN) {
        render_start_screen();
    } else if (game_state == STATE_PLAYING) {
        render_game();
    } else if (game_state == STATE_GAME_OVER) {
        render_game_over();
    }
}

void render_game() {
    // Clear screen
    clear_screen();
    
    // Draw snake
    unsigned char idx = snake_tail_idx;
    unsigned char count = snake_length;
    while (count > 0) {
        unsigned char x = snake_x[idx];
        unsigned char y = snake_y[idx];
        unsigned int addr = (y << 6) + x;
        fb[addr] = COLOR_GREEN;
        idx = (idx + 1) & 0xFF;
        count--;
    }
    
    // Draw food (2×2 block)
    for (unsigned char dy = 0; dy < 2; dy++) {
        for (unsigned char dx = 0; dx < 2; dx++) {
            unsigned int addr = ((food_y + dy) << 6) + food_x + dx;
            fb[addr] = COLOR_RED;
        }
    }
}
```

### Start Screen Animation

```c
void render_start_screen() {
    // Simple blinking "PRESS START" text
    // Use frame counter for animation
    if ((frame_counter >> 4) & 1) {  // Blink every 16 frames
        draw_text_press_start();
    } else {
        clear_screen();
    }
}

void draw_text_press_start() {
    // Draw simple pattern for "PRESS START"
    // Use horizontal lines as simplified text
    for (unsigned char y = 28; y < 36; y++) {
        for (unsigned char x = 16; x < 48; x++) {
            unsigned int addr = (y << 6) + x;
            fb[addr] = COLOR_WHITE;
        }
    }
}
```

---

## Timing and Game Loop

### Main Game Loop

```c
int main() {
    // Initialize game
    init_game();
    
    while (1) {
        // Process input
        process_input();
        
        // Update game state
        if (game_state == STATE_PLAYING) {
            // Apply buffered direction
            direction = next_direction;
            
            // Move snake every N frames
            if ((frame_counter & 0x1F) == 0) {  // Every 32 frames
                move_snake();
            }
        }
        
        // Render frame
        render_frame();
        
        // Delay (approximately 200ms / 32 frames ≈ 6ms per frame)
        delay_ms(6);
        
        // Increment frame counter
        frame_counter++;
    }
    
    return 0;
}
```

### Delay Function

```c
void delay_ms(unsigned int ms) {
    // Approximate delay using busy loop
    // Adjust multiplier based on CPU clock frequency
    for (unsigned int i = 0; i < ms; i++) {
        for (volatile unsigned int j = 0; j < 1000; j++) {
            // Busy wait
        }
    }
}
```

---

## Initialization

### Game Initialization

```c
void init_game() {
    // Set initial game state
    game_state = STATE_START_SCREEN;
    frame_counter = 0;
    
    // Initialize LFSR seed
    lfsr_state = 0xACE1u;
}

void start_game() {
    // Reset snake to center, moving right
    snake_length = 5;
    snake_head_idx = 4;
    snake_tail_idx = 0;
    direction = DIR_RIGHT;
    next_direction = DIR_RIGHT;
    
    // Initialize snake body (horizontal line)
    for (unsigned char i = 0; i < 5; i++) {
        snake_x[i] = 28 + i;  // Start at x=28-32
        snake_y[i] = 32;      // Center vertically
    }
    
    // Spawn initial food
    spawn_food();
    
    // Reset score
    score = 0;
    
    // Start playing
    game_state = STATE_PLAYING;
}
```

---

## Memory Budget

| Component | Size | Notes |
|-----------|------|-------|
| Snake X coords | 256 bytes | Circular buffer |
| Snake Y coords | 256 bytes | Circular buffer |
| Digit patterns | 50 bytes | 10 digits × 5 bytes |
| Game variables | ~50 bytes | State, score, positions, etc. |
| **Total** | **~612 bytes** | Well within 64KB RAM |

---

## Implementation Checklist

### Phase 1: Basic Structure
- [ ] Set up data structures (snake buffers, game state)
- [ ] Implement framebuffer write helper (with shift instead of multiply)
- [ ] Implement clear screen function
- [ ] Test basic rendering

### Phase 2: Snake Movement
- [ ] Implement circular buffer logic
- [ ] Implement direction handling
- [ ] Implement snake movement (without growth)
- [ ] Test snake movement with controller

### Phase 3: Collision Detection
- [ ] Implement wall collision check
- [ ] Implement self-collision check
- [ ] Test collision detection

### Phase 4: Food System
- [ ] Implement LFSR random number generator
- [ ] Implement food spawning
- [ ] Implement food collision detection (2×2 block)
- [ ] Implement snake growth on food eaten
- [ ] Test food system

### Phase 5: Game States
- [ ] Implement start screen rendering
- [ ] Implement game over screen rendering
- [ ] Implement state transitions
- [ ] Test state machine

### Phase 6: Score Display
- [ ] Create digit patterns (0-9)
- [ ] Implement digit rendering
- [ ] Implement score extraction (without division)
- [ ] Implement score display on game over
- [ ] Test score display

### Phase 7: Polish
- [ ] Tune timing and delays
- [ ] Add start screen animation
- [ ] Test full game loop
- [ ] Verify all features work

---

## Testing Strategy

### Unit Tests
1. **Circular buffer**: Test wrap-around at 256
2. **Collision detection**: Test wall and self-collision
3. **LFSR**: Verify pseudo-random sequence
4. **Score extraction**: Test digit extraction without division

### Integration Tests
1. **Snake movement**: Verify smooth movement in all directions
2. **Food spawning**: Verify food doesn't spawn on snake
3. **Growth**: Verify snake grows correctly when eating
4. **Game over**: Verify collision triggers game over

### Full Game Test
1. Play complete game from start to game over
2. Verify score display is correct
3. Verify restart works properly

---

## Known Limitations

1. **No pause feature**: Game cannot be paused (could add with SELECT button)
2. **Fixed speed**: Snake speed doesn't increase with score
3. **Simple graphics**: No fancy animations or effects
4. **Score limit**: Score display limited to 3 digits (0-999)
5. **Food placement**: May take multiple attempts if snake is very long

---

## Future Enhancements (Optional)

1. **Difficulty levels**: Increase speed as score increases
2. **High score**: Save high score in RAM (persists until power off)
3. **Sound effects**: Use spare GPIO for simple beeper
4. **Better graphics**: More detailed start screen and game over screen
5. **Obstacles**: Add walls or obstacles to increase difficulty

---

## References

- CPU Architecture: [`README.md`](../README.md)
- ROM Bug Documentation: [`rom_const_array_bug.md`](rom_const_array_bug.md)
- Controller Interface: [`apps/show-controller/main.c`](../apps/show-controller/main.c)
- Spinning Cube Example: [`apps/spinning-cube/main.c`](../apps/spinning-cube/main.c)
- Memory Map: [`README.md`](../README.md) - Memory Map section

---

## Conclusion

This design provides a complete, playable snake game that respects all CPU constraints:
- ✅ No const arrays (all data in RAM)
- ✅ No multiplication/division (uses shifts and loops)
- ✅ No modulo (uses bitwise AND for wrapping)
- ✅ Efficient memory usage (~612 bytes)
- ✅ Smooth gameplay with controller input
- ✅ All requested features implemented

The implementation is straightforward and can be completed in a single [`main.c`](../apps/snake/main.c) file with approximately 500-700 lines of code.
