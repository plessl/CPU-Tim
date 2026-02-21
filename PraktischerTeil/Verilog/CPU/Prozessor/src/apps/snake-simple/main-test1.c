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

// Funktion mit Parameter (wie udelay)
__attribute__((noinline)) void param_delay(unsigned int count) {
	for(unsigned int i = 0; i < count; i++) {
		__asm__ volatile("nop");
	}
}

int main(){
	// Test mit globalen Variablen - sollte jetzt nach RAM-Fix funktionieren
	x = 32;
	y = 32;
	
	while(1) {
		// Alte Position löschen
		fb_write(y, x, COLOR_BLACK);
		
		// Bewegung basierend auf Buttons
		move();
		
		// Neue Position übernehmen (mit Wrap-around)
		x = x_n;
		y = y_n;
		if (x < 0) x = SCREEN_W - 1;
		if (x >= SCREEN_W) x = 0;
		if (y < 0) y = SCREEN_H - 1;
		if (y >= SCREEN_H) y = 0;
		
		// Neue Position zeichnen  
		fb_write(y, x, COLOR_WHITE);
		
		// Verzögerung
		param_delay(50000);
	}
	return 0;
}
