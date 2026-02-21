/*
 * Test: Static Cube (No Rotation)
 * This tests the basic rendering without rotation to isolate issues
 */

#include <stdint.h>

#define SCREEN_WIDTH 64
#define SCREEN_HEIGHT 64

volatile uint32_t * const fb_base = (volatile uint32_t *) 0x00020000;

// Simple cube vertices (already projected to 2D screen space)
// Centered at (32, 32) with size 20x20 pixels
int cube_2d[8][2] = {
    {22, 22},  // 0: back-bottom-left
    {42, 22},  // 1: back-bottom-right
    {42, 42},  // 2: back-top-right
    {22, 42},  // 3: back-top-left
    {27, 27},  // 4: front-bottom-left
    {37, 27},  // 5: front-bottom-right
    {37, 37},  // 6: front-top-right
    {27, 37}   // 7: front-top-left
};

uint8_t cube_edges[12][2] = {
    {0, 1}, {1, 2}, {2, 3}, {3, 0},  // Back face
    {4, 5}, {5, 6}, {6, 7}, {7, 4},  // Front face
    {0, 4}, {1, 5}, {2, 6}, {3, 7}   // Connecting edges
};

void fb_write(int row, int col, int r, int g, int b) {
    if (row < 0 || row >= SCREEN_HEIGHT || col < 0 || col >= SCREEN_WIDTH) return;
    r = (r >= 1) ? 1 : 0;
    g = (g >= 1) ? 1 : 0;
    b = (b >= 1) ? 1 : 0;
    fb_base[(row << 6) + col] = (r << 2) | (g << 1) | b;
}

void clear_screen() {
    for (int i = 0; i < 4096; i++) {
        fb_base[i] = 0;
    }
}

void draw_line(int x0, int y0, int x1, int y1, int r, int g, int b) {
    int dx = x1 - x0;
    int dy = y1 - y0;
    int sx = (dx >= 0) ? 1 : -1;
    int sy = (dy >= 0) ? 1 : -1;
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

int main() {
    clear_screen();
    
    // Draw all 12 edges of the cube
    for (int i = 0; i < 12; i++) {
        int v0 = cube_edges[i][0];
        int v1 = cube_edges[i][1];
        
        draw_line(
            cube_2d[v0][0], cube_2d[v0][1],
            cube_2d[v1][0], cube_2d[v1][1],
            1, 1, 1
        );
    }
    
    // Infinite loop
    while (1) {
        asm volatile("nop");
    }
    
    return 0;
}
