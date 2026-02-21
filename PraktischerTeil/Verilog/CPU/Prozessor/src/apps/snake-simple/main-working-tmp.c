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
	// DEBUG TEST: SPI-Wert als Bitmuster auf Display zeigen
	// Zeigt alle 16 Bits permanent - leuchtet = Bit ist 1
	unsigned int buttons;
	
	// Erst mal eine Referenzzeile zeichnen (Zeile 30, alle Pixel an)
	for(int i = 0; i < 16; i++){
		fb[30 * 64 + i] = 7;
	}
	
	while(1){
		buttons = spi[0];
		
		// Zeige Bits 0-15 als Pixel in Zeile 32
		// Manuell ausrollen statt Schleife
		fb[32 * 64 + 0]  = (buttons & 0x0001) ? 7 : 0;
		fb[32 * 64 + 1]  = (buttons & 0x0002) ? 7 : 0;
		fb[32 * 64 + 2]  = (buttons & 0x0004) ? 7 : 0;
		fb[32 * 64 + 3]  = (buttons & 0x0008) ? 7 : 0;
		fb[32 * 64 + 4]  = (buttons & 0x0010) ? 7 : 0;
		fb[32 * 64 + 5]  = (buttons & 0x0020) ? 7 : 0;
		fb[32 * 64 + 6]  = (buttons & 0x0040) ? 7 : 0;
		fb[32 * 64 + 7]  = (buttons & 0x0080) ? 7 : 0;
		fb[32 * 64 + 8]  = (buttons & 0x0100) ? 7 : 0;
		fb[32 * 64 + 9]  = (buttons & 0x0200) ? 7 : 0;
		fb[32 * 64 + 10] = (buttons & 0x0400) ? 7 : 0;
		fb[32 * 64 + 11] = (buttons & 0x0800) ? 7 : 0;
		fb[32 * 64 + 12] = (buttons & 0x1000) ? 7 : 0;
		fb[32 * 64 + 13] = (buttons & 0x2000) ? 7 : 0;
		fb[32 * 64 + 14] = (buttons & 0x4000) ? 7 : 0;
		fb[32 * 64 + 15] = (buttons & 0x8000) ? 7 : 0;
		
		param_delay(5000);
	}
	return 0;
}
