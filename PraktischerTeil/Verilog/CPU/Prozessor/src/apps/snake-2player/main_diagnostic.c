/*
 * Diagnostic version of Two-Player Snake
 * Tests initialization step-by-step to identify failure point
 */

#include <stdint.h>

// Hardware definitions
#define SCREEN_WIDTH 64
#define SCREEN_HEIGHT 64

volatile uint32_t * const fb = (volatile uint32_t *) 0x00020000;
volatile uint32_t * const controller_p1 = (volatile uint32_t *) 0x00030000;
volatile uint32_t * const controller_p2 = (volatile uint32_t *) 0x00030004;

// Colors
#define COLOR_BLACK  0u
#define COLOR_GREEN  2u
#define COLOR_RED    4u
#define COLOR_YELLOW 6u
#define COLOR_WHITE  7u

// Test pattern: Draw a colored square at position to show progress
void draw_test_square(unsigned char x, unsigned char y, unsigned char color) {
    for (unsigned char dy = 0; dy < 4; dy++) {
        for (unsigned char dx = 0; dx < 4; dx++) {
            if (x + dx < SCREEN_WIDTH && y + dy < SCREEN_HEIGHT) {
                unsigned int addr = ((y + dy) << 6) + (x + dx);
                fb[addr] = color;
            }
        }
    }
}

// Clear screen
void clear_screen(void) {
    for (unsigned int i = 0; i < (SCREEN_WIDTH << 6); i++) {
        fb[i] = COLOR_BLACK;
    }
}

// Delay
void delay_ms(unsigned int ms) {
    for (unsigned int i = 0; i < ms; i++) {
        for (volatile unsigned int j = 0; j < 1000; j++) {
            // Busy wait
        }
    }
}

int main(void) {
    // Test 1: Can we clear the screen?
    clear_screen();
    delay_ms(500);
    
    // Test 2: Can we draw a test square? (top-left, green)
    draw_test_square(0, 0, COLOR_GREEN);
    delay_ms(500);
    
    // Test 3: Can we draw another square? (top-right, red)
    draw_test_square(60, 0, COLOR_RED);
    delay_ms(500);
    
    // Test 4: Can we draw bottom squares? (yellow and white)
    draw_test_square(0, 60, COLOR_YELLOW);
    delay_ms(500);
    draw_test_square(60, 60, COLOR_WHITE);
    delay_ms(500);
    
    // Test 5: Can we read controller?
    unsigned int test_counter = 0;
    while (1) {
        unsigned int buttons_p1 = controller_p1[0];
        unsigned int buttons_p2 = controller_p2[0];
        
        // Draw center square that changes color based on controller input
        unsigned char color = COLOR_BLACK;
        if (buttons_p1 != 0) color = COLOR_GREEN;
        if (buttons_p2 != 0) color = COLOR_YELLOW;
        if (buttons_p1 != 0 && buttons_p2 != 0) color = COLOR_WHITE;
        
        draw_test_square(30, 30, color);
        
        delay_ms(100);
        test_counter++;
        
        // Blink corner squares to show we're alive
        if (test_counter & 1) {
            draw_test_square(0, 0, COLOR_GREEN);
            draw_test_square(60, 60, COLOR_WHITE);
        } else {
            draw_test_square(0, 0, COLOR_BLACK);
            draw_test_square(60, 60, COLOR_BLACK);
        }
    }
    
    return 0;
}
