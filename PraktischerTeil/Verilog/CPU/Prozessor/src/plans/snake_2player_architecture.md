# Two-Player Snake Architecture Diagram

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     RISC-V CPU (RV32I)                          │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                   Main Game Loop                         │  │
│  │                                                          │  │
│  │  1. Read Controllers (P1 & P2)                          │  │
│  │  2. Process Input                                       │  │
│  │  3. Update Game State                                   │  │
│  │  4. Move Snakes                                         │  │
│  │  5. Check Collisions                                    │  │
│  │  6. Render Frame                                        │  │
│  │  7. Delay (6ms)                                         │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ Memory-Mapped I/O
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Memory Map                               │
│                                                                 │
│  0x0003_0000  ┌──────────────────┐                             │
│               │  Controller P1   │  16-bit button state        │
│  0x0003_0004  ├──────────────────┤                             │
│               │  Controller P2   │  16-bit button state        │
│  0x0002_0000  ├──────────────────┤                             │
│               │   Framebuffer    │  64×64 pixels, 3-bit color  │
│               │   (4096 bytes)   │                             │
│               └──────────────────┘                             │
└─────────────────────────────────────────────────────────────────┘
```

## Game State Machine

```
┌─────────────────┐
│  START_SCREEN   │
│                 │
│  - Blinking     │
│    "PRESS       │
│     START"      │
└────────┬────────┘
         │
         │ Either player presses START
         ▼
┌─────────────────┐
│    PLAYING      │
│                 │
│  - P1 controls  │
│    green snake  │
│  - P2 controls  │
│    yellow snake │
│  - Shared food  │
└────────┬────────┘
         │
         │ Collision detected
         ▼
┌─────────────────┐
│   GAME_OVER     │
│                 │
│  - Show winner  │
│  - Show scores  │
│  - Wait for     │
│    START        │
└────────┬────────┘
         │
         │ Either player presses START
         └──────────────────────────────┐
                                        │
                                        ▼
                              Back to START_SCREEN
```

## Data Flow

### Input Processing

```
Controller P1 (0x0003_0000)     Controller P2 (0x0003_0004)
         │                               │
         │ Read button state             │ Read button state
         ▼                               ▼
    ┌─────────┐                     ┌─────────┐
    │ buttons │                     │ buttons │
    │   _p1   │                     │   _p2   │
    └────┬────┘                     └────┬────┘
         │                               │
         │ Check D-Pad                   │ Check D-Pad
         ▼                               ▼
    ┌─────────┐                     ┌─────────┐
    │ snake1_ │                     │ snake2_ │
    │  next_  │                     │  next_  │
    │direction│                     │direction│
    └─────────┘                     └─────────┘
```

### Movement & Collision

```
Frame Counter
     │
     │ Every FRAMES_PER_MOVE (16 frames)
     ▼
┌──────────────────────────────────────────┐
│         Move Both Snakes                 │
│                                          │
│  ┌────────────┐      ┌────────────┐     │
│  │ move_snake1│      │ move_snake2│     │
│  └─────┬──────┘      └─────┬──────┘     │
│        │                   │             │
│        │ Check:            │ Check:      │
│        │ - Wall            │ - Wall      │
│        │ - Self            │ - Self      │
│        │ - Snake2          │ - Snake1    │
│        │ - Food            │ - Food      │
│        ▼                   ▼             │
│  ┌────────────┐      ┌────────────┐     │
│  │ snake1_    │      │ snake2_    │     │
│  │  alive     │      │  alive     │     │
│  └────────────┘      └────────────┘     │
└──────────────────────────────────────────┘
                │
                │ If either dead
                ▼
         ┌──────────────┐
         │ Determine    │
         │ Winner       │
         │              │
         │ - P1 wins    │
         │ - P2 wins    │
         │ - Draw       │
         └──────────────┘
```

### Rendering Pipeline

```
┌──────────────────────────────────────────┐
│         Clear Screen (Black)             │
└──────────────┬───────────────────────────┘
               │
               ▼
┌──────────────────────────────────────────┐
│      Draw Food (Red 2×2 block)           │
└──────────────┬───────────────────────────┘
               │
               ▼
┌──────────────────────────────────────────┐
│   Draw Snake1 (Green) if alive           │
│                                          │
│   For each segment in circular buffer:   │
│   fb_write(snake1_x[i], snake1_y[i],    │
│            COLOR_GREEN)                  │
└──────────────┬───────────────────────────┘
               │
               ▼
┌──────────────────────────────────────────┐
│   Draw Snake2 (Yellow) if alive          │
│                                          │
│   For each segment in circular buffer:   │
│   fb_write(snake2_x[i], snake2_y[i],    │
│            COLOR_YELLOW)                 │
└──────────────┬───────────────────────────┘
               │
               ▼
┌──────────────────────────────────────────┐
│         Framebuffer → LED Matrix         │
└──────────────────────────────────────────┘
```

## Memory Layout

### Snake Data Structures

```
RAM (0x0001_0000 - 0x0001_FFFF)
│
├── Snake 1 Data (512 bytes)
│   ├── snake1_x[256]        (256 bytes)
│   ├── snake1_y[256]        (256 bytes)
│   ├── snake1_length        (1 byte)
│   ├── snake1_head_idx      (1 byte)
│   ├── snake1_tail_idx      (1 byte)
│   ├── snake1_direction     (1 byte)
│   ├── snake1_next_direction(1 byte)
│   └── snake1_alive         (1 byte)
│
├── Snake 2 Data (512 bytes)
│   ├── snake2_x[256]        (256 bytes)
│   ├── snake2_y[256]        (256 bytes)
│   ├── snake2_length        (1 byte)
│   ├── snake2_head_idx      (1 byte)
│   ├── snake2_tail_idx      (1 byte)
│   ├── snake2_direction     (1 byte)
│   ├── snake2_next_direction(1 byte)
│   └── snake2_alive         (1 byte)
│
├── Shared Game State (~100 bytes)
│   ├── food_x               (1 byte)
│   ├── food_y               (1 byte)
│   ├── game_state           (1 byte)
│   ├── winner               (1 byte)
│   ├── score_p1             (4 bytes)
│   ├── score_p2             (4 bytes)
│   ├── frame_counter        (4 bytes)
│   ├── lfsr_state           (4 bytes)
│   └── digit_patterns[10][7](70 bytes)
│
└── Stack & Heap
```

### Circular Buffer Visualization

```
Snake 1 Circular Buffer (256 elements)

    tail_idx                head_idx
        ↓                       ↓
    ┌───┬───┬───┬───┬───┬───┬───┬───┬───┐
    │ 3 │ 4 │ 5 │ 6 │ 7 │ 8 │ 9 │10 │11 │ ... (256 total)
    └───┴───┴───┴───┴───┴───┴───┴───┴───┘
      ↑                           ↑
    Tail                        Head
    (oldest)                    (newest)

Movement:
1. Add new head: head_idx = (head_idx + 1) & 0xFF
2. If food eaten: keep tail (grow)
3. If no food: tail_idx = (tail_idx + 1) & 0xFF (move)
```

## Collision Detection Matrix

```
                    Wall    Self    Other   Food
                    ────────────────────────────
Snake 1 Head    │   DEAD    DEAD    DEAD    GROW
Snake 2 Head    │   DEAD    DEAD    DEAD    GROW
```

### Collision Check Order

```
For each snake:
  1. Calculate new_x, new_y based on direction
  2. Check wall collision → DEAD if true
  3. Check self-collision → DEAD if true
  4. Check other snake collision → DEAD if true
  5. Add new head to buffer
  6. Check food collision → GROW if true
  7. Remove tail (unless growing)
```

## Timing Diagram

```
Time (ms)    0    6   12   18   24   30   36   42   48   54   60
             │    │    │    │    │    │    │    │    │    │    │
Frame        0    1    2    3    4    5    6    7    8    9   10
             │    │    │    │    │    │    │    │    │    │    │
Input        ●────●────●────●────●────●────●────●────●────●────●
             │    │    │    │    │    │    │    │    │    │    │
Render       ●────●────●────●────●────●────●────●────●────●────●
             │    │    │    │    │    │    │    │    │    │    │
Move         ●────────────────────────────────────────────────●
(every 16    │                                                 │
 frames)     0                                                16

Legend:
  ● = Event occurs
  ─ = Time passes
```

## Color Encoding (3-bit RGB)

```
Bit:  2   1   0
      R   G   B
      ─   ─   ─
Black:0   0   0  = 0b000 = 0
Green:0   1   0  = 0b010 = 2  (Player 1)
Red:  1   0   0  = 0b100 = 4  (Food)
Yellow:1  1   0  = 0b110 = 6  (Player 2)
White:1   1   1  = 0b111 = 7  (UI)
```

## Screen Coordinate System

```
(0,0) ────────────────────────────────► X (63)
  │
  │    P1 Start (16, 32)      P2 Start (48, 32)
  │         ●                      ●
  │         │                      │
  │    ─────┴─────            ─────┴─────
  │    Green Snake            Yellow Snake
  │    Moving RIGHT           Moving LEFT
  │
  │              Food (random)
  │                  ■■
  │                  ■■
  │
  ▼
  Y
 (63)

Note: 90° rotation applied in fb_write()
      Physical display rotated clockwise
```

## Winner Determination Logic

```
After both snakes move:

┌─────────────────────────────────────────┐
│  Check snake1_alive and snake2_alive    │
└──────────────┬──────────────────────────┘
               │
               ▼
        ┌──────────────┐
        │ Both alive?  │
        └──┬────────┬──┘
           │ Yes    │ No
           │        │
           ▼        ▼
      Continue   ┌──────────────┐
      Playing    │ Both dead?   │
                 └──┬────────┬──┘
                    │ Yes    │ No
                    │        │
                    ▼        ▼
              ┌─────────┐  ┌──────────────┐
              │  DRAW   │  │ Only P1 dead?│
              └─────────┘  └──┬────────┬──┘
                              │ Yes    │ No
                              │        │
                              ▼        ▼
                        ┌─────────┐  ┌─────────┐
                        │ P2 WINS │  │ P1 WINS │
                        └─────────┘  └─────────┘
```

## Performance Characteristics

| Metric | Value | Notes |
|--------|-------|-------|
| **Frame Rate** | ~166 FPS | 6ms per frame |
| **Snake Speed** | 200ms/move | 32 frames per move |
| **Input Latency** | <6ms | Polled every frame |
| **Memory Usage** | ~1.1KB | Well within 64KB RAM |
| **Controller Polling** | ~66 Hz | Independent per controller |

## Critical Implementation Notes

### 1. No Multiplication
```c
// WRONG: addr = y * 64 + x;
// RIGHT: addr = (y << 6) + x;
```

### 2. No Division
```c
// Extract digits using repeated subtraction
while (score >= 10) {
    score = score - 10;
    tens++;
}
```

### 3. No Modulo
```c
// WRONG: idx = (idx + 1) % 256;
// RIGHT: idx = (idx + 1) & 0xFF;
```

### 4. No Const Arrays
```c
// WRONG: const unsigned char patterns[10][7] = {...};
// RIGHT: unsigned char patterns[10][7] = {...};
```

### 5. Controller Address Offset
```c
// P1: 0x0003_0000
// P2: 0x0003_0004 (offset by 4 bytes)
```

### 6. Button Mapping (Active-High)
```c
// Hardware inverts active-low controller signals
// Software sees active-high buttons
#define BTN_UP    0x1000  // Bit 12
#define BTN_DOWN  0x4000  // Bit 14
#define BTN_LEFT  0x8000  // Bit 15
#define BTN_RIGHT 0x2000  // Bit 13
```

## References

- Design Document: [`plans/snake_2player_design.md`](snake_2player_design.md)
- Implementation Guide: [`plans/snake_2player_implementation.md`](snake_2player_implementation.md)
- Original Snake: [`apps/snake/main.c`](../apps/snake/main.c)
- Dual Controller: [`plans/dual_controller_quick_reference.md`](dual_controller_quick_reference.md)
