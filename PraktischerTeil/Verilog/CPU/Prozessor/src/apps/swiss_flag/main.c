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

void fb_write_2(unsigned row, unsigned col, unsigned value) {
    volatile unsigned int *fb = (volatile unsigned int *)fb_base;
    /*if (row < 0 || row >= SCREEN_HEIGHT || col < 0 || col >= SCREEN_WIDTH) {
        return;
    }*/
    fb[row * SCREEN_WIDTH + col] = value;
}


//print swiss flag
int main(){
    for(int row = 0; row < SCREEN_HEIGHT; row++){
        for(int col = 0; col < SCREEN_WIDTH; col++){
            if(row <= 10){
                fb_write(row, col, 1, 0, 0);
            }
            else if(row >= 53){
                fb_write(row, col, 1, 0, 0);
            }
            else{
                if(col <= 10){
                    fb_write(row, col, 1, 0, 0);
                }
                else if(col >= 53){
                    fb_write(row, col, 1, 0, 0);
                }
                else{
                    if(col >= 26 && col <= 37){
                        fb_write(row, col, 1, 1, 1);
                    }
                    else if(row >= 26 && row <= 37){
                        fb_write(row, col, 1, 1, 1);
                    }
                    else{
                        fb_write(row, col, 1, 0, 0);
                    }
                }
            }
        }
    }
    return 0;
}