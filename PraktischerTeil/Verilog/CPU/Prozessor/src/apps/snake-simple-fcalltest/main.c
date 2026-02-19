#define SCREEN_W 64
#define SCREEN_H 64

#define BTN_LEFT  0x8000
#define BTN_DOWN  0x4000
#define BTN_RIGHT 0x2000
#define BTN_UP    0x1000
#define BTN_START 0x0800

#define COLOR_BLACK 0u
#define COLOR_GREEN 2u
#define COLOR_RED 4u
#define COLOR_WHITE 7u

volatile unsigned int * const spi = (volatile unsigned int * ) 0x00030000;
volatile unsigned int * const fb  = (volatile unsigned int * ) 0x00020000;

enum dir{
	up = 1,
	down = 2,
	left = 3,
	right = 4
};

int x, y;
int x_n, y_n;
int dir_l;

void fb_write(unsigned row, unsigned col, unsigned value) {
    fb[row * 64 + col] = value;
}


void move(){
	int buttons = spi[0];
	x_n = x;
	y_n = y;

	if(buttons & BTN_DOWN){
		y_n = y - 1;
		x_n = x;
	}
	if(buttons & BTN_LEFT){
		x_n = x - 1;
		y_n = y;
	}
	if(buttons & BTN_RIGHT){
		x_n = x + 1;
		y_n = y;
	}
	if(buttons & BTN_UP){
		y_n = y + 1;
		x_n = x;
	}
}




void init_display(unsigned color){
	for(int i = 0; i < SCREEN_H; i++){
		for(int j = 0; j < SCREEN_W; j++){
			fb_write(i, j, color);
		}
	}
}

// TODO: change and calibrate function such that parameter is in milliseconds and calculate count based on CPI and clock frequency
// CPI = 6
// f = 50 MHz
__attribute__((noinline)) void param_delay(unsigned int count) {
	for(unsigned int i = 0; i < count; i++) {
		__asm__ volatile("nop");
	}
}

int main(){
	// Funktionierende Button-Steuerung
	unsigned int px = 32;
	unsigned int py = 32;
	int dx = 0;
	int dy = 0;
	unsigned int buttons;
	
	init_display(2);
	while(1){
		// Pixel an
		//fb[py * 64 + px] = 7;
		fb_write(py, px, 7);
		param_delay(30000);
		
		// Pixel aus
		fb_write(py, px, 0);
		param_delay(30000);
		
		// Buttons lesen
		buttons = spi[0];
		
		if(buttons & BTN_LEFT){
			dx = -1;
			dy = 0;
		} else if(buttons & BTN_RIGHT){
			dx = 1;
			dy = 0;
		} else if(buttons & BTN_UP){
			dx = 0;
			dy = -1;
		} else if(buttons & BTN_DOWN){
			dx = 0;
			dy = 1;
		} else {
			dx = 0;
			dy = 0;
		}
		
		px = (px + dx + 64) & 63;
		py = (py + dy + 64) & 63;
	}
	return 0;
}
