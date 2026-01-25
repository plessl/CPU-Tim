volatile int *fb_base = (int *)0b00100000;

void fb_write(int row, int col, int r, int g, int b) {
    volatile unsigned int *fb = (unsigned int *)fb_base;
    r = r > 1 ? 1 : 0;
    g = g > 1 ? 1 : 0;
    b = b > 1 ? 1 : 0;

    fb[row * 64 + col] = (r << 2) | (g << 1) | b;
}


int main(){
    for(int r = 0; r < 64; r++){
        for(int c = 0; c < 64; c++){
           if (r <= 5){
            fb_write(r, c, 1, 1, 1);
           }
        }
    }
}