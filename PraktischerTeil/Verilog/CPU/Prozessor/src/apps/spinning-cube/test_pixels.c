/*
 * Test: Individual Pixels
 * Draw specific pixels to test fb_write function
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

int main() {
    clear_screen();
    
    // Draw a cross pattern in the center
    fb_write(32, 32, 1, 1, 1);  // Center
    fb_write(32, 30, 1, 0, 0);  // Left - red
    fb_write(32, 34, 0, 1, 0);  // Right - green
    fb_write(30, 32, 0, 0, 1);  // Top - blue
    fb_write(34, 32, 1, 1, 0);  // Bottom - yellow
    
    // Draw corners
    fb_write(0, 0, 1, 1, 1);      // Top-left
    fb_write(0, 63, 1, 1, 1);     // Top-right
    fb_write(63, 0, 1, 1, 1);     // Bottom-left
    fb_write(63, 63, 1, 1, 1);    // Bottom-right
    
    // Draw a diagonal line manually
    for (int i = 0; i < 20; i++) {
        fb_write(10 + i, 10 + i, 1, 0, 1);  // Magenta diagonal
    }
    
    while (1) {
        asm volatile("nop");
    }
    
    return 0;
}
