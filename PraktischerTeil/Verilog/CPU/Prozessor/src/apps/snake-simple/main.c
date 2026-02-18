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

void delay(){
	for(volatile int d = 0; d < 10000; d++){
		
	}
}

const unsigned CPI = 6; // cycles per instruction

__attribute__((noinline)) void udelay(unsigned int d){
	for (unsigned int i = 0; i < d; i++) {
		__asm__ volatile("nop");
	}
}

void clear_display(){
	for(int i = 0; i < SCREEN_H; i++){
		for(int j = 0; j < SCREEN_W; j++){
			fb_write(i, j, 0);
		}
	}
}

int main(){
	x = 32;
	y = 32;
	x_n = x;
	y_n = y;
	int dx = 0;
	int dy = 0;
	unsigned buttons;

	unsigned col = 1;
	//clear_display();
	while(1){
		//fb_write(x, y, 4);
		fb[x * 64 + y] = col;
		//udelay(100000);

		// TODO: Diese Instruktion ist nicht wirksam! Die LED bleibt einfach an!
		// Compiler Problem?

		//fb_write(x, y, 0);
		fb[x * 64 + y] = 0;

#if 0
		buttons = spi[0];
		if(buttons & BTN_DOWN){
			dx = 0;
			dy = -1;
		} else if (buttons & BTN_LEFT){
			dx = -1;
			dy = 0;
		} else if (buttons & BTN_RIGHT){
			dx = 1;
			dy = 0;
		} else if (buttons & BTN_UP){
			dx = 0;
			dy = 1;
		} else {
			dx = 0;
			dy = 0;	
		}
#endif

		
		col = col + 1;
		if (col > 5) col = 1;

		dx = dy = 1;

		x = (x + dx) % SCREEN_W;
		y = (y + dy) % SCREEN_H;
	}

	#if 0
	while(1){
		fb_write(x_n, y_n, 1);
		fb_write(x, y, 0);
		x = x_n;
		y = y_n; 
		delay();
	}
	#endif
	return 0;
}
