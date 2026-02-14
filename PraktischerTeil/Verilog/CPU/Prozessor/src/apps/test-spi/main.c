#define SCREEN_WIDTH 64
#define SCREEN_HEIGHT 64

//volatile unsigned int * const fb_base = (volatile unsigned int *) 0x00020000;
//volatile unsigned int *fb = (volatile unsigned int *)fb_base;
volatile unsigned int * const spi_base = (volatile unsigned int *) 0x00030000;
volatile unsigned int *spi = (volatile unsigned int *)spi_base;
/*
void fb_write(unsigned row, unsigned col, unsigned r, unsigned g, unsigned b) {
    if (row < 0 || row >= SCREEN_HEIGHT || col < 0 || col >= SCREEN_WIDTH) {
        return;
    }
    r = (r >= 1) ? 1 : 0;
    g = (g >= 1) ? 1 : 0;
    b = (b >= 1) ? 1 : 0;

    fb[row * SCREEN_WIDTH + col] = (r << 2) | (g << 1) | b;
}
*/

int main(){
    volatile int i = 0;
    while (1)
    {
        asm volatile (
            "lui   t0, 0x00030\n" 
            "lw    %0, 0(t0)\n"     
            : "=r" (i)          
            :                     
            : "t0"
        );
    }    
    return 0;
}