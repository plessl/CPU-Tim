/*
 * Spinning 3D Wireframe Cube
 * 
 * Renders a continuously rotating wireframe cube on a 64x64 pixel display.
 * Uses only integer arithmetic with fixed-point math and lookup tables.
 * No multiplication, division, or modulo hardware instructions.
 */

#include <stdint.h>

#define SCREEN_WIDTH 64
#define SCREEN_HEIGHT 64

// Framebuffer base address
volatile uint32_t * const fb_base = (volatile uint32_t *) 0x00020000;

// Fixed-point format: Q16.16 (16-bit integer, 16-bit fractional)
#define FIXED_SHIFT 16
#define FIXED_ONE (1 << FIXED_SHIFT)  // 1.0 in fixed-point

// ============================================================================
// SINE/COSINE LOOKUP TABLE (360 entries, Q16.16 format)
// ============================================================================

// Precomputed sine values for 0-359 degrees in Q16.16 fixed-point format
// sin(x) ranges from -1.0 to 1.0, stored as -65536 to 65536
// NOTE: Not const because ROM reads may not work correctly on this CPU
int32_t sin_table[360] = {
    0, 1144, 2287, 3430, 4572, 5712, 6850, 7987, 9121, 10252,
    11380, 12505, 13626, 14742, 15855, 16962, 18064, 19161, 20252, 21336,
    22415, 23486, 24550, 25607, 26656, 27697, 28729, 29753, 30767, 31772,
    32768, 33754, 34729, 35693, 36647, 37590, 38521, 39441, 40348, 41243,
    42126, 42995, 43852, 44695, 45525, 46341, 47143, 47930, 48703, 49461,
    50203, 50931, 51643, 52339, 53020, 53684, 54332, 54963, 55578, 56175,
    56756, 57319, 57865, 58393, 58903, 59396, 59870, 60326, 60764, 61183,
    61584, 61966, 62328, 62672, 62997, 63303, 63589, 63856, 64104, 64332,
    64540, 64729, 64898, 65048, 65177, 65287, 65376, 65446, 65496, 65526,
    65536, 65526, 65496, 65446, 65376, 65287, 65177, 65048, 64898, 64729,
    64540, 64332, 64104, 63856, 63589, 63303, 62997, 62672, 62328, 61966,
    61584, 61183, 60764, 60326, 59870, 59396, 58903, 58393, 57865, 57319,
    56756, 56175, 55578, 54963, 54332, 53684, 53020, 52339, 51643, 50931,
    50203, 49461, 48703, 47930, 47143, 46341, 45525, 44695, 43852, 42995,
    42126, 41243, 40348, 39441, 38521, 37590, 36647, 35693, 34729, 33754,
    32768, 31772, 30767, 29753, 28729, 27697, 26656, 25607, 24550, 23486,
    22415, 21336, 20252, 19161, 18064, 16962, 15855, 14742, 13626, 12505,
    11380, 10252, 9121, 7987, 6850, 5712, 4572, 3430, 2287, 1144,
    0, -1144, -2287, -3430, -4572, -5712, -6850, -7987, -9121, -10252,
    -11380, -12505, -13626, -14742, -15855, -16962, -18064, -19161, -20252, -21336,
    -22415, -23486, -24550, -25607, -26656, -27697, -28729, -29753, -30767, -31772,
    -32768, -33754, -34729, -35693, -36647, -37590, -38521, -39441, -40348, -41243,
    -42126, -42995, -43852, -44695, -45525, -46341, -47143, -47930, -48703, -49461,
    -50203, -50931, -51643, -52339, -53020, -53684, -54332, -54963, -55578, -56175,
    -56756, -57319, -57865, -58393, -58903, -59396, -59870, -60326, -60764, -61183,
    -61584, -61966, -62328, -62672, -62997, -63303, -63589, -63856, -64104, -64332,
    -64540, -64729, -64898, -65048, -65177, -65287, -65376, -65446, -65496, -65526,
    -65536, -65526, -65496, -65446, -65376, -65287, -65177, -65048, -64898, -64729,
    -64540, -64332, -64104, -63856, -63589, -63303, -62997, -62672, -62328, -61966,
    -61584, -61183, -60764, -60326, -59870, -59396, -58903, -58393, -57865, -57319,
    -56756, -56175, -55578, -54963, -54332, -53684, -53020, -52339, -51643, -50931,
    -50203, -49461, -48703, -47930, -47143, -46341, -45525, -44695, -43852, -42995,
    -42126, -41243, -40348, -39441, -38521, -37590, -36647, -35693, -34729, -33754,
    -32768, -31772, -30767, -29753, -28729, -27697, -26656, -25607, -24550, -23486,
    -22415, -21336, -20252, -19161, -18064, -16962, -15855, -14742, -13626, -12505,
    -11380, -10252, -9121, -7987, -6850, -5712, -4572, -3430, -2287, -1144
};

// ============================================================================
// CUBE GEOMETRY
// ============================================================================

// 8 vertices of a cube centered at origin (Q16.16 format)
// Using ±10 units = ±655360 in fixed-point
// NOTE: Not const because ROM reads may not work correctly on this CPU
int32_t cube_vertices[8][3] = {
    {-655360, -655360, -655360},  // 0: back-bottom-left
    { 655360, -655360, -655360},  // 1: back-bottom-right
    { 655360,  655360, -655360},  // 2: back-top-right
    {-655360,  655360, -655360},  // 3: back-top-left
    {-655360, -655360,  655360},  // 4: front-bottom-left
    { 655360, -655360,  655360},  // 5: front-bottom-right
    { 655360,  655360,  655360},  // 6: front-top-right
    {-655360,  655360,  655360}   // 7: front-top-left
};

// 12 edges connecting vertices
// NOTE: Not const because ROM reads may not work correctly on this CPU
uint8_t cube_edges[12][2] = {
    // Back face (z = -10)
    {0, 1}, {1, 2}, {2, 3}, {3, 0},
    // Front face (z = 10)
    {4, 5}, {5, 6}, {6, 7}, {7, 4},
    // Connecting edges
    {0, 4}, {1, 5}, {2, 6}, {3, 7}
};

// ============================================================================
// DATA STRUCTURES
// ============================================================================

typedef struct {
    int32_t x, y, z;  // Q16.16 fixed-point
} Vec3;

typedef struct {
    int x, y;  // Screen coordinates (pixels)
} Point2D;

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

// Angle normalization - keep in range [0, 359]
int normalize_angle(int angle) {
    while (angle < 0) angle += 360;
    while (angle >= 360) angle -= 360;
    return angle;
}

// Get cosine value (sine shifted by 90 degrees)
int32_t get_cos(int angle) {
    return sin_table[normalize_angle(angle + 90)];
}

// ============================================================================
// FIXED-POINT ARITHMETIC (NO HARDWARE MULTIPLY)
// ============================================================================

// Multiply two 32-bit integers using shift-and-add
// This is a pure software implementation
int32_t mul32(int32_t a, int32_t b) {
    int32_t result = 0;
    int negative = 0;
    
    // Handle signs
    if (a < 0) { a = -a; negative = !negative; }
    if (b < 0) { b = -b; negative = !negative; }
    
    // Shift-and-add multiplication
    while (b > 0) {
        if (b & 1) {
            result += a;
        }
        a <<= 1;
        b >>= 1;
    }
    
    return negative ? -result : result;
}

// Multiply two Q16.16 fixed-point numbers
int32_t fixed_mul(int32_t a, int32_t b) {
    // Split into high and low 16 bits
    int32_t a_hi = a >> 16;
    int32_t a_lo = a & 0xFFFF;
    int32_t b_hi = b >> 16;
    int32_t b_lo = b & 0xFFFF;
    
    // (a_hi * 2^16 + a_lo) * (b_hi * 2^16 + b_lo) / 2^16
    // = a_hi * b_hi * 2^16 + a_hi * b_lo + a_lo * b_hi + (a_lo * b_lo) / 2^16
    
    int32_t result = 0;
    
    // a_hi * b_hi * 2^16
    result += mul32(a_hi, b_hi) << 16;
    
    // a_hi * b_lo
    result += mul32(a_hi, b_lo);
    
    // a_lo * b_hi
    result += mul32(a_lo, b_hi);
    
    // (a_lo * b_lo) >> 16
    result += mul32(a_lo, b_lo) >> 16;
    
    return result;
}

// ============================================================================
// 3D ROTATION FUNCTIONS
// ============================================================================

void rotate_x(Vec3* v, int angle_deg) {
    angle_deg = normalize_angle(angle_deg);
    int32_t cos_a = get_cos(angle_deg);
    int32_t sin_a = sin_table[angle_deg];
    
    int32_t y_new = fixed_mul(v->y, cos_a) - fixed_mul(v->z, sin_a);
    int32_t z_new = fixed_mul(v->y, sin_a) + fixed_mul(v->z, cos_a);
    
    v->y = y_new;
    v->z = z_new;
}

void rotate_y(Vec3* v, int angle_deg) {
    angle_deg = normalize_angle(angle_deg);
    int32_t cos_a = get_cos(angle_deg);
    int32_t sin_a = sin_table[angle_deg];
    
    int32_t x_new = fixed_mul(v->x, cos_a) + fixed_mul(v->z, sin_a);
    int32_t z_new = -fixed_mul(v->x, sin_a) + fixed_mul(v->z, cos_a);
    
    v->x = x_new;
    v->z = z_new;
}

void rotate_z(Vec3* v, int angle_deg) {
    angle_deg = normalize_angle(angle_deg);
    int32_t cos_a = get_cos(angle_deg);
    int32_t sin_a = sin_table[angle_deg];
    
    int32_t x_new = fixed_mul(v->x, cos_a) - fixed_mul(v->y, sin_a);
    int32_t y_new = fixed_mul(v->x, sin_a) + fixed_mul(v->y, cos_a);
    
    v->x = x_new;
    v->y = y_new;
}

// ============================================================================
// 3D TO 2D PROJECTION
// ============================================================================

Point2D project_vertex(Vec3* v) {
    Point2D p;
    
    // Orthographic projection with scaling
    // Scale from ±10 units to ±18 pixels (fits nicely in 64x64 screen)
    // Scaling factor: 18/10 = 1.8 = 117965 in Q16.16
    // Then add 32 to center on screen
    
    int32_t scale = 117965;  // 1.8 in Q16.16
    
    // x_screen = (x * scale) >> 16 + 32
    int32_t x_scaled = fixed_mul(v->x, scale);
    int32_t y_scaled = fixed_mul(v->y, scale);
    
    p.x = (x_scaled >> FIXED_SHIFT) + 32;
    p.y = (y_scaled >> FIXED_SHIFT) + 32;
    
    // Clamp to screen bounds
    if (p.x < 0) p.x = 0;
    if (p.x >= SCREEN_WIDTH) p.x = SCREEN_WIDTH - 1;
    if (p.y < 0) p.y = 0;
    if (p.y >= SCREEN_HEIGHT) p.y = SCREEN_HEIGHT - 1;
    
    return p;
}

// ============================================================================
// FRAMEBUFFER OPERATIONS
// ============================================================================

void fb_write(int row, int col, int r, int g, int b) {
    if (row < 0 || row >= SCREEN_HEIGHT || col < 0 || col >= SCREEN_WIDTH) return;
    
    r = (r >= 1) ? 1 : 0;
    g = (g >= 1) ? 1 : 0;
    b = (b >= 1) ? 1 : 0;
    
    // row * 64 + col = (row << 6) + col
    fb_base[(row << 6) + col] = (r << 2) | (g << 1) | b;
}

void clear_screen() {
    // 64 * 64 = 4096
    for (int i = 0; i < 4096; i++) {
        fb_base[i] = 0;
    }
}

// ============================================================================
// LINE DRAWING - BRESENHAM'S ALGORITHM
// ============================================================================

void draw_line(int x0, int y0, int x1, int y1, int r, int g, int b) {
    int dx = x1 - x0;
    int dy = y1 - y0;
    
    // Determine step direction
    int sx = (dx >= 0) ? 1 : -1;
    int sy = (dy >= 0) ? 1 : -1;
    
    // Make deltas positive
    if (dx < 0) dx = -dx;
    if (dy < 0) dy = -dy;
    
    int err = dx - dy;
    
    while (1) {
        fb_write(y0, x0, r, g, b);
        
        if (x0 == x1 && y0 == y1) break;
        
        int e2 = err << 1;
        
        if (e2 > -dy) {
            err -= dy;
            x0 += sx;
        }
        
        if (e2 < dx) {
            err += dx;
            y0 += sy;
        }
    }
}

// ============================================================================
// MAIN ANIMATION LOOP
// ============================================================================

int main() {
    int angle_x = 0;
    int angle_y = 0;
    int angle_z = 0;
    
    Vec3 rotated_vertices[8];
    Point2D projected_vertices[8];
    
    while (1) {
        // Clear screen
        clear_screen();
        
        // Update rotation angles
        angle_x = normalize_angle(angle_x + 2);
        angle_y = normalize_angle(angle_y + 3);
        angle_z = normalize_angle(angle_z + 1);
        
        // Transform all vertices
        for (int i = 0; i < 8; i++) {
            // Copy original vertex
            rotated_vertices[i].x = cube_vertices[i][0];
            rotated_vertices[i].y = cube_vertices[i][1];
            rotated_vertices[i].z = cube_vertices[i][2];
            
            // Apply rotations in sequence
            rotate_x(&rotated_vertices[i], angle_x);
            rotate_y(&rotated_vertices[i], angle_y);
            rotate_z(&rotated_vertices[i], angle_z);
            
            // Project to 2D screen space
            projected_vertices[i] = project_vertex(&rotated_vertices[i]);
        }
        
        // Draw all edges
        for (int i = 0; i < 12; i++) {
            int v0 = cube_edges[i][0];
            int v1 = cube_edges[i][1];
            
            draw_line(
                projected_vertices[v0].x,
                projected_vertices[v0].y,
                projected_vertices[v1].x,
                projected_vertices[v1].y,
                1, 1, 1  // White color
            );
        }
        
        // Frame delay for animation speed
        for (int d = 0; d < 30000; d++) {
            asm volatile("nop");
        }
    }
    
    return 0;
}
