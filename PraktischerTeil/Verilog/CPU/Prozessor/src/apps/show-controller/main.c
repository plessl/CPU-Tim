#define SCREEN_WIDTH 64
#define SCREEN_HEIGHT 64

volatile unsigned int * const fb_base = (volatile unsigned int *) 0x00020000;
volatile unsigned int * const pad_base = (volatile unsigned int *) 0x00030000;

void fb_write(unsigned row, unsigned col, unsigned value) {
    fb_base[row * SCREEN_WIDTH + col] = (value & 0x1) ? 7 : 0;
}


int main(){    
    unsigned b;
    while(1) {
        volatile unsigned int pad_data = *pad_base;
        b = ((pad_data &    0x1) ? 1 : 0); fb_write(0, 15, b);
        b = ((pad_data &    0x2) ? 1 : 0); fb_write(0, 14, b);
        b = ((pad_data &    0x4) ? 1 : 0); fb_write(0, 13, b);
        b = ((pad_data &    0x8) ? 1 : 0); fb_write(0, 12, b);

        b = ((pad_data &   0x10) ? 1 : 0); fb_write(0, 11, b);
        b = ((pad_data &   0x20) ? 1 : 0); fb_write(0, 10, b);
        b = ((pad_data &   0x40) ? 1 : 0); fb_write(0, 9, b);
        b = ((pad_data &   0x80) ? 1 : 0); fb_write(0, 8, b);

        b = ((pad_data &  0x100) ? 1 : 0); fb_write(0, 7, b);
        b = ((pad_data &  0x200) ? 1 : 0); fb_write(0, 6, b);
        b = ((pad_data &  0x400) ? 1 : 0); fb_write(0, 5, b);
        b = ((pad_data &  0x800) ? 1 : 0); fb_write(0, 4, b);

        b = ((pad_data & 0x1000) ? 1 : 0); fb_write(0, 3, b);
        b = ((pad_data & 0x2000) ? 1 : 0); fb_write(0, 2, b);
        b = ((pad_data & 0x4000) ? 1 : 0); fb_write(0, 1, b);
        b = ((pad_data & 0x8000) ? 1 : 0); fb_write(0, 0, b);


    }
}
