#include <stdint.h>

#define FRAMEBUFFER ((volatile uint8_t*)0x00020000)
#define CONTROLLER_P1 ((volatile uint16_t*)0x00030000)
#define CONTROLLER_P2 ((volatile uint16_t*)0x00030004)

// Button bit definitions (active-high)
#define BTN_UP       (1 << 12)
#define BTN_RIGHT    (1 << 13)
#define BTN_DOWN     (1 << 14)
#define BTN_LEFT     (1 << 15)



// Clear entire screen
void clear_screen(void) {
    for (unsigned int i = 0; i < (SCREEN_WIDTH << 6); i++) {
        FRAMEBUFFER[i] = 0b000;
    }
}

// Set a single pixel
void set_pixel(int x, int y, uint8_t color) {
    if (x >= 0 && x < 64 && y >= 0 && y < 64) {
        FRAMEBUFFER[y * 64 + x] = color;
    }
}

// Draw a 3x3 cursor
void draw_cursor(int x, int y, uint8_t color) {
    for (int dy = -1; dy <= 1; dy++) {
        for (int dx = -1; dx <= 1; dx++) {
            set_pixel(x + dx, y + dy, color);
        }
    }
}

int main(void) {
    // Clear screen first
    clear_screen();
    
    // Wait a bit for screen to clear
    for (volatile int i = 0; i < 1000000; i++);
    
    // Initialize positions
    int p1_x = 16;
    int p1_y = 32;
    int p2_x = 48;
    int p2_y = 32;
    
    // Draw initial cursors
    draw_cursor(p1_x, p1_y, 0b100);  // Red
    draw_cursor(p2_x, p2_y, 0b001);  // Blue
    
    while (1) {
        // Read controller states
        uint16_t p1 = *CONTROLLER_P1;
        uint16_t p2 = *CONTROLLER_P2;
        
        // Calculate new positions
        int new_p1_x = p1_x;
        int new_p1_y = p1_y;
        
        if (p1 & BTN_UP)    new_p1_y = (p1_y > 1)  ? p1_y - 1 : p1_y;
        if (p1 & BTN_DOWN)  new_p1_y = (p1_y < 62) ? p1_y + 1 : p1_y;
        if (p1 & BTN_LEFT)  new_p1_x = (p1_x > 1)  ? p1_x - 1 : p1_x;
        if (p1 & BTN_RIGHT) new_p1_x = (p1_x < 62) ? p1_x + 1 : p1_x;
        
        int new_p2_x = p2_x;
        int new_p2_y = p2_y;
        
        if (p2 & BTN_UP)    new_p2_y = (p2_y > 1)  ? p2_y - 1 : p2_y;
        if (p2 & BTN_DOWN)  new_p2_y = (p2_y < 62) ? p2_y + 1 : p2_y;
        if (p2 & BTN_LEFT)  new_p2_x = (p2_x > 1)  ? p2_x - 1 : p2_x;
        if (p2 & BTN_RIGHT) new_p2_x = (p2_x < 62) ? p2_x + 1 : p2_x;
        
        // Update P1 if moved
        if (new_p1_x != p1_x || new_p1_y != p1_y) {
            draw_cursor(p1_x, p1_y, 0);  // Clear old
            p1_x = new_p1_x;
            p1_y = new_p1_y;
            draw_cursor(p1_x, p1_y, 0b100);  // Draw new (red)
        }
        
        // Update P2 if moved
        if (new_p2_x != p2_x || new_p2_y != p2_y) {
            draw_cursor(p2_x, p2_y, 0);  // Clear old
            p2_x = new_p2_x;
            p2_y = new_p2_y;
            draw_cursor(p2_x, p2_y, 0b001);  // Draw new (blue)
        }
        
        // Delay
        for (volatile int i = 0; i < 100000; i++);
    }
    
    return 0;
}
