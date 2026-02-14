volatile unsigned int * const spi_base = (volatile unsigned int *) 0x00030000;
volatile unsigned int *control_reg = (volatile unsigned int*) spi_base;

#define SCREEN_WIDTH 64
#define SCREEN_HEIGHT 64

volatile unsigned int * const fb_base = (volatile unsigned int *) 0x00020000;

void fb_write(unsigned row, unsigned col, unsigned r, unsigned g, unsigned b) {
    volatile unsigned int *fb = (volatile unsigned int *)fb_base;
    /*if (row < 0 || row >= SCREEN_HEIGHT || col < 0 || col >= SCREEN_WIDTH) {
        return;
    }*/
    r = (r >= 1) ? 1 : 0;
    g = (g >= 1) ? 1 : 0;
    b = (b >= 1) ? 1 : 0;

    fb[row * SCREEN_WIDTH + col] = (r << 2) | (g << 1) | b;
}
#if 0
void clear_fb(){
    for(int i = 0; i < 4096; i++){
        fb[i]=0;
    }
}
#endif

int main()
{
//    clear_fb();
    for(int i = 0; i < 64; i++){
        fb_write(0, i, 0,0,0);
    }
    while(1){
        volatile unsigned int reg = control_reg[0];
        for (int i = 0; i < 32; i++) {
            unsigned color = ((reg >> i) & 1u) ? 7 : 0;
            fb_write(0, i, (color >> 2) & 1, (color >> 1) & 1, color & 1);
        }
    }
    return 0;
}
