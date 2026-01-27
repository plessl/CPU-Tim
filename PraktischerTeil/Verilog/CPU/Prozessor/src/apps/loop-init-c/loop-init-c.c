volatile unsigned int * const fb_base = (volatile unsigned int *) 0x00020000;

void fb_write(int row, int col, int r, int g, int b) {
    volatile unsigned int *fb = (unsigned int *)fb_base;
    r = (r >= 1) ? 1 : 0;
    g = (g >= 1) ? 1 : 0;
    b = (b >= 1) ? 1 : 0;

    fb[row * 64 + col] = (r << 2) | (g << 1) | b;
}

int main(){

    for(int r = 0; r < 64; r++){
        for(int c = 0; c < 64; c++){
            switch(c % 4) {
                case 0:
                 fb_write(r, c, 1, 0, 0);
                 break;
                case 1:
                 fb_write(r, c, 0, 1, 0);
                 break;
                case 2:
                 fb_write(r, c, 0, 0, 1);
                 break;
                case 3:
                 fb_write(r, c, 1, 1, 1);
                 break; 
            }
        }
    }

    #if 0
    fb_base[1000] = 4;
    fb_base[1001] = 4;
    fb_base[1002] = 4;

    fb_write(31, 32, 1, 0, 0);
    fb_write(32, 31, 1, 0, 0);
    fb_write(32, 32, 1, 0, 0);
    fb_write(32, 33, 1, 0, 0);
    fb_write(33, 32, 1, 0, 0);
    #endif

}
