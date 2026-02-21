/*
 * Classic Snake Game
 * 
 * Features:
 * - Snake that grows when eating food
 * - Movement controls using PS2 Dualshock 2 controller
 * - Game over when hitting walls or itself
 * - Score counter displayed at game over
 * - Start screen with animation
 * - Restart with START button
 * 
 * Technical constraints:
 * - NO const arrays (ROM read bug)
 * - NO multiplication/division (no M-extension)
 * - NO modulo operator (use bitwise AND)
 */

#include <stdint.h>

// ============================================================================
// HARDWARE DEFINITIONS
// ============================================================================

#define SCREEN_WIDTH 64
#define SCREEN_HEIGHT 64

// Memory-mapped I/O
volatile uint32_t * const fb = (volatile uint32_t *) 0x00020000;  // Framebuffer
volatile uint32_t * const spi = (volatile uint32_t *) 0x00030000; // SPI controller

// Controller button mapping
#define BTN_LEFT  0x8000
#define BTN_DOWN  0x4000
#define BTN_RIGHT 0x2000
#define BTN_UP    0x1000
#define BTN_START 0x0800

// Colors (3-bit RGB)
#define COLOR_BLACK 0u
#define COLOR_GREEN 2u
#define COLOR_RED   4u
#define COLOR_WHITE 7u

// ============================================================================
// GAME CONSTANTS
// ============================================================================

#define MAX_SNAKE_LENGTH 256
#define INITIAL_SNAKE_LENGTH 5

// Direction encoding
#define DIR_UP    1
#define DIR_DOWN  2
#define DIR_LEFT  3
#define DIR_RIGHT 4

// Game states
#define STATE_START_SCREEN 0
#define STATE_PLAYING      1
#define STATE_GAME_OVER    2

// Timing
#define FRAMES_PER_MOVE 16  // Snake moves every 16 frames (~100ms at 6ms/frame)

// ============================================================================
// GLOBAL VARIABLES (NOT const - must be in RAM)
// ============================================================================

// Snake body storage (circular buffer)
unsigned char snake_x[MAX_SNAKE_LENGTH];
unsigned char snake_y[MAX_SNAKE_LENGTH];

// Snake state
unsigned char snake_length;
unsigned char snake_head_idx;
unsigned char snake_tail_idx;
unsigned char direction;
unsigned char next_direction;

// Food position
unsigned char food_x;
unsigned char food_y;

// Game state
unsigned char game_state;
unsigned int score;
unsigned int frame_counter;

// LFSR state for random number generation
unsigned int lfsr_state = 0xACE1u;

// Digit patterns for score display (5×7 pixels, NOT const)
// Each digit is 7 rows, each row is 5 bits (stored as bytes)
unsigned char digit_patterns[10][7] = {
    // 0
    {0b01110, 0b10001, 0b10011, 0b10101, 0b11001, 0b10001, 0b01110},
    // 1
    {0b00100, 0b01100, 0b00100, 0b00100, 0b00100, 0b00100, 0b01110},
    // 2
    {0b01110, 0b10001, 0b00001, 0b00010, 0b00100, 0b01000, 0b11111},
    // 3
    {0b11111, 0b00010, 0b00100, 0b00010, 0b00001, 0b10001, 0b01110},
    // 4
    {0b00010, 0b00110, 0b01010, 0b10010, 0b11111, 0b00010, 0b00010},
    // 5
    {0b11111, 0b10000, 0b11110, 0b00001, 0b00001, 0b10001, 0b01110},
    // 6
    {0b00110, 0b01000, 0b10000, 0b11110, 0b10001, 0b10001, 0b01110},
    // 7
    {0b11111, 0b00001, 0b00010, 0b00100, 0b01000, 0b01000, 0b01000},
    // 8
    {0b01110, 0b10001, 0b10001, 0b01110, 0b10001, 0b10001, 0b01110},
    // 9
    {0b01110, 0b10001, 0b10001, 0b01111, 0b00001, 0b00010, 0b01100}
};

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

// Write pixel to framebuffer (using shift instead of multiply)
// Framebuffer is row-major: fb[row * 64 + col]
// Apply 90-degree clockwise rotation: (x, y) -> (y, 63-x)
void fb_write(unsigned char x, unsigned char y, unsigned char color) {
    if (x >= SCREEN_WIDTH || y >= SCREEN_HEIGHT) return;
    // Rotate 90 degrees clockwise: new_row = y, new_col = 63 - x
    unsigned char new_row = y;
    unsigned char new_col = 63 - x;
    unsigned int addr = (new_row << 6) + new_col;  // row * 64 + col
    fb[addr] = color;
}

// Clear entire screen
void clear_screen(void) {
    for (unsigned int i = 0; i < (SCREEN_WIDTH << 6); i++) {
        fb[i] = COLOR_BLACK;
    }
}

// Delay function (busy wait)
void delay_ms(unsigned int ms) {
    for (unsigned int i = 0; i < ms; i++) {
        for (volatile unsigned int j = 0; j < 1000; j++) {
            // Busy wait
        }
    }
}

// ============================================================================
// RANDOM NUMBER GENERATION (LFSR)
// ============================================================================

// Generate next pseudo-random number using 16-bit LFSR
unsigned int lfsr_next(void) {
    unsigned int lsb = lfsr_state & 1;
    lfsr_state = lfsr_state >> 1;
    if (lsb) {
        lfsr_state = lfsr_state ^ 0xB400u;
    }
    return lfsr_state;
}

// Get random position in range [0, 63]
unsigned char random_pos(void) {
    unsigned int r = lfsr_next();
    return (unsigned char)(r & 0x3F);  // Use lower 6 bits
}

// ============================================================================
// SNAKE LOGIC
// ============================================================================

// Check if snake occupies position (x, y)
int is_snake_at(unsigned char x, unsigned char y) {
    unsigned char idx = snake_tail_idx;
    unsigned char count = snake_length;
    
    while (count > 0) {
        if (snake_x[idx] == x && snake_y[idx] == y) {
            return 1;
        }
        idx = (idx + 1) & 0xFF;  // Wrap at 256
        count--;
    }
    return 0;
}

// Check if position collides with snake body (excluding tail)
int check_self_collision(unsigned char x, unsigned char y) {
    unsigned char idx = snake_tail_idx;
    unsigned char count = snake_length - 1;  // Don't check tail (it will move)
    
    while (count > 0) {
        idx = (idx + 1) & 0xFF;
        if (snake_x[idx] == x && snake_y[idx] == y) {
            return 1;
        }
        count--;
    }
    return 0;
}

// Check if head overlaps food (2×2 block)
int check_food_collision(unsigned char x, unsigned char y) {
    if (x >= food_x && x < food_x + 2 &&
        y >= food_y && y < food_y + 2) {
        return 1;
    }
    return 0;
}

// Spawn food at random empty position
void spawn_food(void) {
    unsigned char attempts = 0;
    do {
        food_x = random_pos();
        food_y = random_pos();
        
        // Ensure food doesn't spawn at edge (2×2 block needs space)
        if (food_x > 62) food_x = 62;
        if (food_y > 62) food_y = 62;
        
        attempts++;
        if (attempts > 100) break;  // Prevent infinite loop
    } while (is_snake_at(food_x, food_y) || 
             is_snake_at(food_x + 1, food_y) ||
             is_snake_at(food_x, food_y + 1) ||
             is_snake_at(food_x + 1, food_y + 1));
}

// Move snake in current direction
void move_snake(void) {
    // Calculate new head position
    unsigned char new_x = snake_x[snake_head_idx];
    unsigned char new_y = snake_y[snake_head_idx];
    
    if (direction == DIR_UP) {
        // UP button moves up on screen (y decreases)
        if (new_y == 0) {
            game_state = STATE_GAME_OVER;  // Hit top wall
            return;
        }
        new_y = new_y - 1;
    } else if (direction == DIR_DOWN) {
        // DOWN button moves down on screen (y increases)
        new_y = new_y + 1;
        if (new_y >= SCREEN_HEIGHT) {
            game_state = STATE_GAME_OVER;  // Hit bottom wall
            return;
        }
    } else if (direction == DIR_LEFT) {
        // LEFT button moves left on screen (x decreases)
        if (new_x == 0) {
            game_state = STATE_GAME_OVER;  // Hit left wall
            return;
        }
        new_x = new_x - 1;
    } else if (direction == DIR_RIGHT) {
        // RIGHT button moves right on screen (x increases)
        new_x = new_x + 1;
        if (new_x >= SCREEN_WIDTH) {
            game_state = STATE_GAME_OVER;  // Hit right wall
            return;
        }
    }
    
    // Check self-collision
    if (check_self_collision(new_x, new_y)) {
        game_state = STATE_GAME_OVER;
        return;
    }
    
    // Add new head
    snake_head_idx = (snake_head_idx + 1) & 0xFF;
    snake_x[snake_head_idx] = new_x;
    snake_y[snake_head_idx] = new_y;
    
    // Check if food eaten
    if (check_food_collision(new_x, new_y)) {
        snake_length++;
        score++;
        spawn_food();
        // Don't remove tail (snake grows)
    } else {
        // Remove tail (snake moves without growing)
        snake_tail_idx = (snake_tail_idx + 1) & 0xFF;
    }
}

// ============================================================================
// INPUT HANDLING
// ============================================================================

void process_input(void) {
    unsigned int buttons = spi[0];
    
    if (game_state == STATE_START_SCREEN || game_state == STATE_GAME_OVER) {
        // Wait for START button
        if (buttons & BTN_START) {
            // Small delay to debounce
            delay_ms(200);
            
            // Reset and start game
            snake_length = INITIAL_SNAKE_LENGTH;
            snake_head_idx = INITIAL_SNAKE_LENGTH - 1;
            snake_tail_idx = 0;
            direction = DIR_RIGHT;
            next_direction = DIR_RIGHT;
            
            // Initialize snake body (horizontal line in center)
            for (unsigned char i = 0; i < INITIAL_SNAKE_LENGTH; i++) {
                snake_x[i] = 28 + i;
                snake_y[i] = 32;
            }
            
            // Spawn initial food
            spawn_food();
            
            // Reset score
            score = 0;
            frame_counter = 0;
            
            // Start playing
            game_state = STATE_PLAYING;
        }
    } else if (game_state == STATE_PLAYING) {
        // Buffer direction change (prevents 180° turns)
        // Note: LEFT and RIGHT are swapped due to 90° rotation
        if (buttons & BTN_UP && direction != DIR_DOWN) {
            next_direction = DIR_UP;
        } else if (buttons & BTN_DOWN && direction != DIR_UP) {
            next_direction = DIR_DOWN;
        } else if (buttons & BTN_LEFT && direction != DIR_RIGHT) {
            next_direction = DIR_RIGHT;  // LEFT button -> move RIGHT
        } else if (buttons & BTN_RIGHT && direction != DIR_LEFT) {
            next_direction = DIR_LEFT;   // RIGHT button -> move LEFT
        }
    }
}

// ============================================================================
// RENDERING
// ============================================================================

// Draw a single digit at position
void draw_digit(unsigned char digit, unsigned char start_x, unsigned char start_y) {
    if (digit > 9) return;
    
    // Draw 5×7 digit pattern (row by row)
    for (unsigned char row = 0; row < 7; row++) {
        unsigned char pattern = digit_patterns[digit][row];
        for (unsigned char col = 0; col < 5; col++) {
            if (pattern & (1 << (4 - col))) {  // MSB is leftmost pixel
                fb_write(start_x + col, start_y + row, COLOR_WHITE);
            }
        }
    }
}

// Draw score as 3-digit number
void draw_score(unsigned int score_value) {
    // Extract digits without division (using repeated subtraction)
    unsigned char hundreds = 0;
    unsigned int temp = score_value;
    
    while (temp >= 100) {
        temp = temp - 100;
        hundreds++;
    }
    
    unsigned char tens = 0;
    while (temp >= 10) {
        temp = temp - 10;
        tens++;
    }
    
    unsigned char ones = temp;
    
    // Draw digits centered on screen
    draw_digit(hundreds, 20, 28);
    draw_digit(tens, 28, 28);
    draw_digit(ones, 36, 28);
}

// Render start screen
void render_start_screen(void) {
    clear_screen();
    
    // Simple blinking animation
    if ((frame_counter >> 4) & 1) {  // Blink every 16 frames
        // Draw "PRESS START" as simple pattern
        for (unsigned char y = 28; y < 36; y++) {
            for (unsigned char x = 16; x < 48; x++) {
                fb_write(x, y, COLOR_WHITE);
            }
        }
    }
}

// Render game over screen
void render_game_over(void) {
    clear_screen();
    
    // Draw "GAME OVER" pattern (top)
    for (unsigned char y = 10; y < 18; y++) {
        for (unsigned char x = 16; x < 48; x++) {
            fb_write(x, y, COLOR_RED);
        }
    }
    
    // Draw score
    draw_score(score);
    
    // Draw "PRESS START" pattern (bottom)
    if ((frame_counter >> 3) & 1) {  // Blink faster
        for (unsigned char y = 46; y < 54; y++) {
            for (unsigned char x = 16; x < 48; x++) {
                fb_write(x, y, COLOR_WHITE);
            }
        }
    }
}

// Render game (snake and food)
void render_game(void) {
    clear_screen();
    
    // Draw snake
    unsigned char idx = snake_tail_idx;
    unsigned char count = snake_length;
    while (count > 0) {
        unsigned char x = snake_x[idx];
        unsigned char y = snake_y[idx];
        fb_write(x, y, COLOR_GREEN);
        idx = (idx + 1) & 0xFF;
        count--;
    }
    
    // Draw food (2×2 block)
    for (unsigned char dy = 0; dy < 2; dy++) {
        for (unsigned char dx = 0; dx < 2; dx++) {
            fb_write(food_x + dx, food_y + dy, COLOR_RED);
        }
    }
}

// Main render function
void render_frame(void) {
    if (game_state == STATE_START_SCREEN) {
        render_start_screen();
    } else if (game_state == STATE_PLAYING) {
        render_game();
    } else if (game_state == STATE_GAME_OVER) {
        render_game_over();
    }
}

// ============================================================================
// MAIN GAME LOOP
// ============================================================================

int main(void) {
    // Initialize game state
    game_state = STATE_START_SCREEN;
    frame_counter = 0;
    lfsr_state = 0xACE1u;
    
    // Main loop
    while (1) {
        // Process controller input
        process_input();
        
        // Update game state
        if (game_state == STATE_PLAYING) {
            // Apply buffered direction
            direction = next_direction;
            
            // Move snake every N frames
            if ((frame_counter & (FRAMES_PER_MOVE - 1)) == 0) {
                move_snake();
            }
        }
        
        // Render frame
        render_frame();
        
        // Delay (~6ms per frame)
        delay_ms(6);
        
        // Increment frame counter
        frame_counter++;
    }
    
    return 0;
}
