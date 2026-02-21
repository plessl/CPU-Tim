/*
 * Test: Line Drawing
 * Test the Bresenham line drawing algorithm
 */

#include <stdint.h>

#define SCREEN_WIDTH 64
#define SCREEN_HEIGHT 64

volatile uint32_t * const fb_base = (volatile uint32_t *) 0x00020000;

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
    
    // Draw horizontal line
    draw_line(10, 10, 50, 10, 1, 0, 0);  // Red horizontal
    
    // Draw vertical line
    draw_line(10, 20, 10, 50, 0, 1, 0);  // Green vertical
    
    // Draw diagonal line
    draw_line(20, 20, 40, 40, 0, 0, 1);  // Blue diagonal
    
    // Draw another diagonal
    draw_line(20, 40, 40, 20, 1, 1, 0);  // Yellow diagonal
    
    // Draw a box
    draw_line(25, 25, 35, 25, 1, 1, 1);  // Top
    draw_line(35, 25, 35, 35, 1, 1, 1);  // Right
    draw_line(35, 35, 25, 35, 1, 1, 1);  // Bottom
    draw_line(25, 35, 25, 25, 1, 1, 1);  // Left
    
    while (1) {
        asm volatile("nop");
    }
    
    return 0;
}
