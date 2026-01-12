volatile int *fb_base = 0x00100000;

*fb_base = 0x00000004; // Set pixel at (0,0) to red

void fb_write(int row, int col, int r, int g, int b) {
    volatile unsigned int fb[64*64] = (unsigned int *)fb_base;
    r = r > 1 ? 1 : 0;
    g = g > 1 ? 1 : 0;
    b = b > 1 ? 1 : 0;

    fb[row * 64 + col] = (r << 2) | (g << 1) | b;
}

