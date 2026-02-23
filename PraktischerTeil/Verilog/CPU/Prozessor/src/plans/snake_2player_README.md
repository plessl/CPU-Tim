# Two-Player Snake Game - Planning Documentation

## Overview

Complete planning and design documentation for implementing a two-player competitive snake game on the RISC-V RV32I FPGA Core with dual PS2 Dualshock 2 controller support.

## Game Concept

Two players control separate snakes (green and yellow) on a shared 64×64 LED matrix display. Players compete to eat food and grow their snakes while avoiding walls, themselves, and each other. The game ends when either snake collides, with the surviving player declared the winner.

## Documentation Index

### 1. Quick Start Guide ⚡
**File**: [`snake_2player_quickstart.md`](snake_2player_quickstart.md)

**Purpose**: Step-by-step implementation guide for developers

**Contents**:
- 11-step implementation process
- Code modification checklist
- Build and test instructions
- Common issues and solutions
- Success criteria

**Start here if**: You want to implement the game immediately

---

### 2. Design Document 📐
**File**: [`snake_2player_design.md`](snake_2player_design.md)

**Purpose**: High-level game design and mechanics

**Contents**:
- Game mechanics and win/loss conditions
- Visual design and color scheme
- Data structures and memory layout
- Controller mapping
- Game logic and collision detection
- Performance considerations
- Implementation phases

**Start here if**: You want to understand the overall design before coding

---

### 3. Implementation Guide 🔧
**File**: [`snake_2player_implementation.md`](snake_2player_implementation.md)

**Purpose**: Detailed code structure and implementation details

**Contents**:
- Complete code structure breakdown
- Hardware definitions
- Global variables
- All function implementations with code examples
- Rendering pipeline
- Main game loop
- Testing checklist

**Start here if**: You need detailed code examples and function signatures

---

### 4. Architecture Diagram 🏗️
**File**: [`snake_2player_architecture.md`](snake_2player_architecture.md)

**Purpose**: Visual system architecture and data flow

**Contents**:
- System overview diagrams
- Game state machine
- Data flow diagrams
- Memory layout visualization
- Collision detection matrix
- Timing diagrams
- Performance characteristics

**Start here if**: You prefer visual diagrams and system-level understanding

---

## Key Features

### Gameplay
- ✅ **Two independent snakes** - Green (P1) and Yellow (P2)
- ✅ **Dual controller support** - Each player uses their own PS2 controller
- ✅ **Shared food system** - First snake to reach food gets the point
- ✅ **Multiple collision types** - Wall, self, and snake-to-snake
- ✅ **Winner determination** - P1 wins, P2 wins, or draw

### Technical
- ✅ **RV32I compliant** - No M-extension (no multiply/divide)
- ✅ **Memory efficient** - ~1.1KB RAM usage
- ✅ **High performance** - ~166 FPS, 200ms snake movement
- ✅ **Dual controller I/O** - Memory-mapped at 0x30000 and 0x30004

## Implementation Summary

### Files to Create
```
apps/snake-2player/
├── main.c          # Complete two-player implementation
├── boot.s          # Copy from apps/snake/boot.s
├── link.ld         # Copy from apps/snake/link.ld
├── justfile        # Copy from apps/snake/justfile (update APP name)
└── README.md       # Game documentation
```

### Key Code Changes

| Component | Change |
|-----------|--------|
| **Controllers** | Add P2 controller at 0x30004 |
| **Data Structures** | Duplicate all snake variables for P2 |
| **Colors** | Add COLOR_YELLOW (6) for P2 |
| **Movement** | Create move_snake1() and move_snake2() |
| **Collision** | Add snake-to-snake collision detection |
| **Input** | Handle both controllers independently |
| **Rendering** | Draw both snakes with different colors |
| **Game Over** | Determine and display winner |

### Memory Usage

| Component | Size |
|-----------|------|
| Snake 1 data | 512 bytes |
| Snake 2 data | 512 bytes |
| Shared state | ~100 bytes |
| **Total** | **~1,124 bytes** |

## Quick Reference

### Controller Addresses
```c
#define CONTROLLER_P1 ((volatile uint32_t*)0x00030000)
#define CONTROLLER_P2 ((volatile uint32_t*)0x00030004)
```

### Colors
```c
#define COLOR_BLACK  0u  // Background
#define COLOR_GREEN  2u  // Player 1
#define COLOR_RED    4u  // Food
#define COLOR_YELLOW 6u  // Player 2
#define COLOR_WHITE  7u  // UI text
```

### Game States
```c
#define STATE_START_SCREEN 0
#define STATE_PLAYING      1
#define STATE_GAME_OVER    2
```

### Winner States
```c
#define WINNER_NONE   0
#define WINNER_P1     1
#define WINNER_P2     2
#define WINNER_DRAW   3
```

## Build Commands

```bash
# Create project
cd apps/
cp -r snake snake-2player
cd snake-2player

# Build
just build

# Install
just install

# Simulate
cd ../..
make sim
```

## Testing Strategy

### Unit Tests
- Snake movement (both players)
- Wall collision (both players)
- Self-collision (both players)
- Snake-to-snake collision
- Food collision (both players)
- Winner determination

### Integration Tests
- Full game playthrough (P1 wins)
- Full game playthrough (P2 wins)
- Full game playthrough (draw)
- Restart functionality

### Hardware Tests
- Dual controller input
- Visual appearance on LED matrix
- Performance verification

## Technical Constraints

### CPU Limitations (RV32I)
- ❌ No const arrays (ROM read bug)
- ❌ No multiplication (use shifts: `<< 6`)
- ❌ No division (use repeated subtraction)
- ❌ No modulo (use bitwise AND: `& 0xFF`)

### Solutions
- ✅ All data in RAM (not ROM)
- ✅ Shift operations for addressing
- ✅ Repeated subtraction for digit extraction
- ✅ Bitwise AND for circular buffer wrapping

## Performance Targets

| Metric | Target | Actual |
|--------|--------|--------|
| Frame Rate | ~166 FPS | 6ms per frame |
| Snake Speed | 200ms/move | 32 frames per move |
| Input Latency | <10ms | <6ms (polled every frame) |
| Memory Usage | <2KB | ~1.1KB |

## Recommended Reading Order

### For Quick Implementation
1. [`snake_2player_quickstart.md`](snake_2player_quickstart.md) - Follow step-by-step
2. [`snake_2player_implementation.md`](snake_2player_implementation.md) - Reference for code details
3. Original snake game: [`apps/snake/main.c`](../apps/snake/main.c) - Copy utility functions

### For Deep Understanding
1. [`snake_2player_design.md`](snake_2player_design.md) - Understand game mechanics
2. [`snake_2player_architecture.md`](snake_2player_architecture.md) - Study system architecture
3. [`snake_2player_implementation.md`](snake_2player_implementation.md) - Learn implementation details
4. [`snake_2player_quickstart.md`](snake_2player_quickstart.md) - Implement the game

## Related Documentation

### Project Documentation
- [`README.md`](../README.md) - Main project documentation
- [`Agents.md`](../Agents.md) - AI assistant context guide
- [`plans/README.md`](README.md) - Documentation index

### Original Snake Game
- [`apps/snake/main.c`](../apps/snake/main.c) - Single-player implementation
- [`apps/snake/README.md`](../apps/snake/README.md) - Single-player documentation
- [`plans/snake_game_design.md`](snake_game_design.md) - Original design document

### Dual Controller Support
- [`plans/dual_controller_quick_reference.md`](dual_controller_quick_reference.md) - Controller API
- [`plans/dual_controller_design.md`](dual_controller_design.md) - Hardware design
- [`apps/test-dual-controller/main.c`](../apps/test-dual-controller/main.c) - Test application

### CPU Architecture
- [`plans/architecture.md`](architecture.md) - System architecture
- [`plans/QUICKSTART.md`](QUICKSTART.md) - Debugging guide
- [`cpu.sv`](../cpu.sv) - Hardware implementation

## Future Enhancements

Possible improvements after basic implementation:

### Gameplay
- **Power-ups**: Speed boost, invincibility, shrink opponent
- **Obstacles**: Static walls or moving hazards
- **Game modes**: Cooperative mode, time trial, survival
- **Difficulty levels**: Faster speed, smaller arena, more obstacles

### Visual
- **Better graphics**: Improved start screen, animations
- **Score display**: Real-time score during gameplay
- **High score tracking**: Best scores for each player
- **Visual effects**: Snake death animation, food spawn effect

### Technical
- **Pause functionality**: SELECT button to pause
- **Speed increase**: Snake speeds up as score increases
- **Sound effects**: Using additional peripherals
- **Replay system**: Record and playback games

## Support

For questions or issues:
1. Check [`snake_2player_quickstart.md`](snake_2player_quickstart.md) common issues section
2. Review original snake game: [`apps/snake/main.c`](../apps/snake/main.c)
3. Consult dual controller reference: [`plans/dual_controller_quick_reference.md`](dual_controller_quick_reference.md)
4. Examine test application: [`apps/test-dual-controller/main.c`](../apps/test-dual-controller/main.c)

## Version History

- **v1.0** (2026-02-23) - Initial design and planning documentation

## Contributors

Based on:
- Original snake game implementation
- Dual controller hardware support
- RISC-V RV32I FPGA Core architecture

---

**Ready to start?** Begin with [`snake_2player_quickstart.md`](snake_2player_quickstart.md) for step-by-step implementation instructions.
