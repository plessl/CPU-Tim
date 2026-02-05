#define SCREEN_WIDTH 64
#define SCREEN_HEIGHT 64

volatile unsigned int * const fb_base = (volatile unsigned int *) 0x00020000;

/* Simple LFSR for pseudo-random number generation */
static unsigned int lfsr = 23456;

unsigned int random_next() {
    unsigned int bit = ((lfsr >> 0) ^ (lfsr >> 2) ^ (lfsr >> 3) ^ (lfsr >> 5)) & 1;
    lfsr = (lfsr >> 1) | (bit << 15);
    return lfsr;
}

void fb_write(unsigned row, unsigned col, unsigned r, unsigned g, unsigned b) {
    if (row >= SCREEN_HEIGHT || col >= SCREEN_WIDTH) return;
    
    volatile unsigned int *fb = (volatile unsigned int *)fb_base;
    r = (r >= 1) ? 1 : 0;
    g = (g >= 1) ? 1 : 0;
    b = (b >= 1) ? 1 : 0;

    fb[row * SCREEN_WIDTH + col] = (r << 2) | (g << 1) | b;
}

void draw_box(int x, int y, int w, int h, int r, int g, int b) {
    for (int dy = 0; dy < h; dy++) {
        for (int dx = 0; dx < w; dx++) {
            if (y + dy >= 0 && y + dy < SCREEN_HEIGHT && 
                x + dx >= 0 && x + dx < SCREEN_WIDTH) {
                fb_write(y + dy, x + dx, r, g, b);
            }
        }
    }
}

void clear_screen() {
    volatile unsigned int *fb = (volatile unsigned int *)fb_base;
    for (int i = 0; i < SCREEN_WIDTH * SCREEN_HEIGHT; i++) {
        fb[i] = 0;
    }
}

int main(){
    int x = 28;
    int y = 28;
    int dx = 1;
    int dy = 1;
    int color = 0;
    
    while (1) {
        clear_screen();
        
        /* Get current color */
        int r = 0, g = 0, b = 0;
        if (color == 0) { r = 1; g = 0; b = 0; }
        else if (color == 1) { r = 0; g = 1; b = 0; }
        else if (color == 2) { r = 0; g = 1; b = 1; }
        else if (color == 3) { r = 1; g = 1; b = 0; }
        else if (color == 4) { r = 1; g = 0; b = 1; }
        else if (color == 5) { r = 1; g = 1; b = 1; }
        else { r = 0; g = 0; b = 1; }
        
        /* Draw square */
        draw_box(x, y, 8, 8, r, g, b);
        
        /* Move first */
        x = x + dx;
        y = y + dy;
        
        /* Bounce logic - check all four corners explicitly */
        int at_left = (x <= 0);
        int at_right = (x >= 56);
        int at_top = (y <= 0);
        int at_bottom = (y >= 56);
        
        /* Clamp to bounds */
        if (x < 0) x = 0;
        if (x > 56) x = 56;
        if (y < 0) y = 0;
        if (y > 56) y = 56;
        
        /* Check if we hit a corner (both x and y boundaries) */
        if ((at_left || at_right) && (at_top || at_bottom)) {
            /* Corner hit - reverse both and change color */
            dx = -dx;
            dy = -dy;
            color = (color + 1) & 0x7;
        } else {
            /* Only wall hit - reverse that axis */
            if (at_left || at_right) {
                dx = -dx;
                color = (color + 1) & 0x7;
            }
            if (at_top || at_bottom) {
                dy = -dy;
                color = (color + 1) & 0x7;
            }
        }
        
        /* Delay */
        for (int d = 0; d < 50000; d++) {
            asm volatile("nop");
        }
    }
    
    return 0;
}
