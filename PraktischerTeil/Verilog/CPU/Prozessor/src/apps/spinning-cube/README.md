# Spinning 3D Wireframe Cube

A continuously rotating 3D wireframe cube rendered on a 64x64 pixel LED matrix display, implemented for a RISC-V RV32I processor without hardware multiplication, division, or modulo operations.

## Overview

This application demonstrates advanced graphics programming under severe constraints:
- **No M-Extension**: All arithmetic uses only addition, subtraction, bitwise operations, and shifts
- **Fixed-Point Math**: Q16.16 format (16-bit integer, 16-bit fractional) for all calculations
- **Lookup Tables**: Precomputed sine/cosine values for trigonometric operations
- **Software Multiply**: Shift-and-add algorithm for multiplication
- **Integer-Only**: No floating-point operations

## Features

- **3D Rotation**: Continuous rotation around X, Y, and Z axes
- **Wireframe Rendering**: 12 edges connecting 8 vertices
- **Smooth Animation**: Optimized for real-time performance
- **Bounds Checking**: Cube remains fully within 64x64 display at all times
- **Bresenham Lines**: Efficient integer-only line drawing algorithm

## Technical Details

### Fixed-Point Arithmetic

The implementation uses Q16.16 fixed-point format:
- **Range**: -32768 to +32767 with 1/65536 precision
- **Scaling**: 65536 (2^16) represents 1.0
- **Operations**: All math performed with integer arithmetic

### Software Multiplication

Since the RV32I ISA lacks hardware multiply, we implement multiplication using shift-and-add:

```c
int32_t mul32(int32_t a, int32_t b) {
    int32_t result = 0;
    while (b > 0) {
        if (b & 1) result += a;
        a <<= 1;
        b >>= 1;
    }
    return result;
}
```

### Trigonometric Lookup Tables

- **Size**: 360 entries (one per degree)
- **Format**: Q16.16 fixed-point
- **Range**: -65536 to +65536 (representing -1.0 to +1.0)
- **Memory**: 1440 bytes for sine table
- **Cosine**: Derived as `sin(angle + 90°)`

### 3D Rotation Matrices

Rotations are applied using standard 3D rotation matrices:

**X-axis rotation:**
```
y' = y * cos(θ) - z * sin(θ)
z' = y * sin(θ) + z * cos(θ)
```

**Y-axis rotation:**
```
x' = x * cos(θ) + z * sin(θ)
z' = -x * sin(θ) + z * cos(θ)
```

**Z-axis rotation:**
```
x' = x * cos(θ) - y * sin(θ)
y' = x * sin(θ) + y * cos(θ)
```

### Projection

Orthographic projection with scaling:
- **Cube size**: ±10 units in 3D space
- **Screen size**: ±18 pixels (36x36 cube on 64x64 screen)
- **Centering**: Offset by 32 pixels to center on display
- **Scaling factor**: 1.8 (117965 in Q16.16)

### Cube Geometry

**8 Vertices:**
```
0: (-10, -10, -10)  back-bottom-left
1: ( 10, -10, -10)  back-bottom-right
2: ( 10,  10, -10)  back-top-right
3: (-10,  10, -10)  back-top-left
4: (-10, -10,  10)  front-bottom-left
5: ( 10, -10,  10)  front-bottom-right
6: ( 10,  10,  10)  front-top-right
7: (-10,  10,  10)  front-top-left
```

**12 Edges:**
- Back face: 0-1, 1-2, 2-3, 3-0
- Front face: 4-5, 5-6, 6-7, 7-4
- Connecting: 0-4, 1-5, 2-6, 3-7

### Line Drawing

Bresenham's algorithm for efficient integer-only line drawing:
- No division or multiplication required
- Handles all line orientations
- Includes bounds checking

## Building

```bash
just build
```

This compiles the application using:
- `riscv64-unknown-elf-gcc` with `-march=rv32i` (no M-extension)
- Optimization level `-Og` (debug-friendly optimization)
- Generates `main.elf`, `main.bin`, `main.mi`, and `main.disasm`

## Installation

```bash
just install
```

Copies the ROM and RAM initialization files to the parent directory for FPGA synthesis.

## Memory Usage

| Component | Size | Location |
|-----------|------|----------|
| Sine lookup table | 1440 bytes | ROM (.rodata) |
| Cube vertices | 96 bytes | ROM (.rodata) |
| Cube edges | 96 bytes | ROM (.rodata) |
| Code | ~2-3 KB | ROM (.text) |
| Rotated vertices | 96 bytes | Stack |
| Projected vertices | 64 bytes | Stack |

## Performance

- **Rotation angles**: Increment by 2°, 3°, and 1° per frame (X, Y, Z)
- **Frame delay**: 30,000 NOP cycles
- **Calculations per frame**:
  - 8 vertices × 3 rotations × ~6 multiplications = ~144 software multiplies
  - 12 edges × ~20 pixels average = ~240 pixel writes
- **Expected frame rate**: 10-20 FPS (depending on CPU clock)

## Verification

To verify no hardware multiply/divide/modulo instructions are used:

```bash
grep -E "^\s+[0-9a-f]+:\s+[0-9a-f]+\s+(mul|div|rem)" main.disasm
```

This should return no results, confirming only RV32I base instructions are used.

## Code Structure

```
main.c
├── Sine/Cosine lookup tables (360 entries)
├── Cube geometry definitions
├── Data structures (Vec3, Point2D)
├── Helper functions (normalize_angle, get_cos)
├── Fixed-point arithmetic (mul32, fixed_mul)
├── 3D rotation functions (rotate_x, rotate_y, rotate_z)
├── 3D to 2D projection (project_vertex)
├── Framebuffer operations (fb_write, clear_screen)
├── Line drawing (draw_line - Bresenham's algorithm)
└── Main animation loop
```

## Animation Loop

Each frame:
1. Clear the screen
2. Update rotation angles
3. For each vertex:
   - Copy original coordinates
   - Apply X rotation
   - Apply Y rotation
   - Apply Z rotation
   - Project to 2D screen space
4. For each edge:
   - Draw line between projected vertices
5. Delay for frame rate control
6. Repeat

## Constraints Met

✅ No hardware multiplication instructions  
✅ No hardware division instructions  
✅ No hardware modulo instructions  
✅ Integer arithmetic only  
✅ Fixed-point math with lookup tables  
✅ Continuous 3D rotation  
✅ Wireframe rendering (12 edges)  
✅ Stays within 64x64 display bounds  
✅ Smooth animation  
✅ Clear code structure  

## Future Enhancements

- **Perspective projection**: Add depth perception
- **Multiple cubes**: Render several rotating cubes
- **Color cycling**: Change edge colors based on rotation
- **User input**: Control rotation speed via game controller
- **Depth sorting**: Draw edges in correct order for hidden line removal
- **Optimization**: Further optimize software multiply for better frame rate

## References

- [Architecture Plan](../../plans/spinning_cube_architecture.md) - Detailed design document
- [RISC-V RV32I Specification](https://riscv.org/technical/specifications/)
- [Fixed-Point Arithmetic](https://en.wikipedia.org/wiki/Fixed-point_arithmetic)
- [Bresenham's Line Algorithm](https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm)
- [3D Rotation Matrices](https://en.wikipedia.org/wiki/Rotation_matrix)
