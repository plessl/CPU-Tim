/*
 * Two-Player Snake Game
 * 
 * Features:
 * - Two independent snakes (green and yellow)
 * - Dual PS2 Dualshock 2 controller support
 * - Competitive gameplay with winner determination
 * - Game over when either snake collides with wall, itself, or other snake
 * - Shared food system (first to reach gets the point)
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
volatile uint32_t * const controller_p1 = (volatile uint32_t *) 0x00030000; // Controller P1
volatile uint32_t * const controller_p2 = (volatile uint32_t *) 0x00030004; // Controller P2

// Controller button mapping
#define BTN_LEFT  0x8000
#define BTN_DOWN  0x4000
#define BTN_RIGHT 0x2000
#define BTN_UP    0x1000
#define BTN_START 0x0800

// Colors (3-bit RGB)
#define COLOR_BLACK  0u
#define COLOR_GREEN  2u  // Player 1
#define COLOR_RED    4u  // Food
#define COLOR_YELLOW 6u  // Player 2
#define COLOR_WHITE  7u  // UI text

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

// Winner states
#define WINNER_NONE   0
#define WINNER_P1     1
#define WINNER_P2     2
#define WINNER_DRAW   3

// Timing
#define FRAMES_PER_MOVE 16  // Snake moves every 16 frames (~100ms at 6ms/frame)

// ============================================================================
// GLOBAL VARIABLES (NOT const - must be in RAM)
// ============================================================================

// Player 1 Snake (Green)
unsigned char snake1_x[MAX_SNAKE_LENGTH];
unsigned char snake1_y[MAX_SNAKE_LENGTH];
unsigned char snake1_length;
unsigned char snake1_head_idx;
unsigned char snake1_tail_idx;
unsigned char snake1_direction;
unsigned char snake1_next_direction;
unsigned char snake1_alive;

// Player 2 Snake (Yellow)
unsigned char snake2_x[MAX_SNAKE_LENGTH];
unsigned char snake2_y[MAX_SNAKE_LENGTH];
unsigned char snake2_length;
unsigned char snake2_head_idx;
unsigned char snake2_tail_idx;
unsigned char snake2_direction;
unsigned char snake2_next_direction;
unsigned char snake2_alive;

// Shared game state
unsigned char food_x;
unsigned char food_y;
unsigned char game_state;
unsigned char winner;
unsigned int score_p1;
unsigned int score_p2;
unsigned int frame_counter;

// LFSR state for random number generation
unsigned int lfsr_state = 0xACE1u;

// Digit patterns for score display (5×7 pixels, NOT const)
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
// Apply 90-degree clockwise rotation: (x, y) -> (y, 63-x)
void fb_write(unsigned char x, unsigned char y, unsigned char color) {
    if (x >= SCREEN_WIDTH || y >= SCREEN_HEIGHT) return;
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
// SNAKE HELPER FUNCTIONS
// ============================================================================

// Check if snake1 occupies position (x, y)
int is_snake1_at(unsigned char x, unsigned char y) {
    unsigned char idx = snake1_tail_idx;
    unsigned char count = snake1_length;
    
    while (count > 0) {
        if (snake1_x[idx] == x && snake1_y[idx] == y) {
            return 1;
        }
        idx = (idx + 1) & 0xFF;
        count--;
    }
    return 0;
}

// Check if snake2 occupies position (x, y)
int is_snake2_at(unsigned char x, unsigned char y) {
    unsigned char idx = snake2_tail_idx;
    unsigned char count = snake2_length;
    
    while (count > 0) {
        if (snake2_x[idx] == x && snake2_y[idx] == y) {
            return 1;
        }
        idx = (idx + 1) & 0xFF;
        count--;
    }
    return 0;
}

// Check if position is occupied by either snake
int is_occupied(unsigned char x, unsigned char y) {
    return is_snake1_at(x, y) || is_snake2_at(x, y);
}

// ============================================================================
// COLLISION DETECTION
// ============================================================================

// Check if snake1 collides with its own body (excluding tail)
int check_snake1_self_collision(unsigned char x, unsigned char y) {
    unsigned char idx = snake1_tail_idx;
    unsigned char count = snake1_length - 1;  // Don't check tail
    
    while (count > 0) {
        idx = (idx + 1) & 0xFF;
        if (snake1_x[idx] == x && snake1_y[idx] == y) {
            return 1;
        }
        count--;
    }
    return 0;
}

// Check if snake2 collides with its own body (excluding tail)
int check_snake2_self_collision(unsigned char x, unsigned char y) {
    unsigned char idx = snake2_tail_idx;
    unsigned char count = snake2_length - 1;
    
    while (count > 0) {
        idx = (idx + 1) & 0xFF;
        if (snake2_x[idx] == x && snake2_y[idx] == y) {
            return 1;
        }
        count--;
    }
    return 0;
}

// Check if position collides with snake1 (for snake2 to check)
int check_collision_with_snake1(unsigned char x, unsigned char y) {
    return is_snake1_at(x, y);
}

// Check if position collides with snake2 (for snake1 to check)
int check_collision_with_snake2(unsigned char x, unsigned char y) {
    return is_snake2_at(x, y);
}

// Check if head overlaps food (2×2 block)
int check_food_collision(unsigned char x, unsigned char y) {
    if (x >= food_x && x < food_x + 2 &&
        y >= food_y && y < food_y + 2) {
        return 1;
    }
    return 0;
}

// ============================================================================
// FOOD SPAWNING
// ============================================================================

// Spawn food at random empty position (avoid both snakes)
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
    } while (is_occupied(food_x, food_y) || 
             is_occupied(food_x + 1, food_y) ||
             is_occupied(food_x, food_y + 1) ||
             is_occupied(food_x + 1, food_y + 1));
}

// ============================================================================
// SNAKE MOVEMENT
// ============================================================================

// Move snake1 in current direction
void move_snake1(void) {
    if (!snake1_alive) return;
    
    // Calculate new head position
    unsigned char new_x = snake1_x[snake1_head_idx];
    unsigned char new_y = snake1_y[snake1_head_idx];
    
    if (snake1_direction == DIR_UP) {
        if (new_y == 0) {
            snake1_alive = 0;  // Hit top wall
            return;
        }
        new_y = new_y - 1;
    } else if (snake1_direction == DIR_DOWN) {
        new_y = new_y + 1;
        if (new_y >= SCREEN_HEIGHT) {
            snake1_alive = 0;  // Hit bottom wall
            return;
        }
    } else if (snake1_direction == DIR_LEFT) {
        if (new_x == 0) {
            snake1_alive = 0;  // Hit left wall
            return;
        }
        new_x = new_x - 1;
    } else if (snake1_direction == DIR_RIGHT) {
        new_x = new_x + 1;
        if (new_x >= SCREEN_WIDTH) {
            snake1_alive = 0;  // Hit right wall
            return;
        }
    }
    
    // Check self-collision
    if (check_snake1_self_collision(new_x, new_y)) {
        snake1_alive = 0;
        return;
    }
    
    // Check collision with snake2
    if (check_collision_with_snake2(new_x, new_y)) {
        snake1_alive = 0;
        return;
    }
    
    // Add new head
    snake1_head_idx = (snake1_head_idx + 1) & 0xFF;
    snake1_x[snake1_head_idx] = new_x;
    snake1_y[snake1_head_idx] = new_y;
    
    // Check if food eaten
    if (check_food_collision(new_x, new_y)) {
        snake1_length++;
        score_p1++;
        spawn_food();
        // Don't remove tail (snake grows)
    } else {
        // Remove tail (snake moves without growing)
        snake1_tail_idx = (snake1_tail_idx + 1) & 0xFF;
    }
}

// Move snake2 in current direction
void move_snake2(void) {
    if (!snake2_alive) return;
    
    // Calculate new head position
    unsigned char new_x = snake2_x[snake2_head_idx];
    unsigned char new_y = snake2_y[snake2_head_idx];
    
    if (snake2_direction == DIR_UP) {
        if (new_y == 0) {
            snake2_alive = 0;
            return;
        }
        new_y = new_y - 1;
    } else if (snake2_direction == DIR_DOWN) {
        new_y = new_y + 1;
        if (new_y >= SCREEN_HEIGHT) {
            snake2_alive = 0;
            return;
        }
    } else if (snake2_direction == DIR_LEFT) {
        if (new_x == 0) {
            snake2_alive = 0;
            return;
        }
        new_x = new_x - 1;
    } else if (snake2_direction == DIR_RIGHT) {
        new_x = new_x + 1;
        if (new_x >= SCREEN_WIDTH) {
            snake2_alive = 0;
            return;
        }
    }
    
    // Check self-collision
    if (check_snake2_self_collision(new_x, new_y)) {
        snake2_alive = 0;
        return;
    }
    
    // Check collision with snake1
    if (check_collision_with_snake1(new_x, new_y)) {
        snake2_alive = 0;
        return;
    }
    
    // Add new head
    snake2_head_idx = (snake2_head_idx + 1) & 0xFF;
    snake2_x[snake2_head_idx] = new_x;
    snake2_y[snake2_head_idx] = new_y;
    
    // Check if food eaten
    if (check_food_collision(new_x, new_y)) {
        snake2_length++;
        score_p2++;
        spawn_food();
    } else {
        snake2_tail_idx = (snake2_tail_idx + 1) & 0xFF;
    }
}

// ============================================================================
// INPUT HANDLING
// ============================================================================

void process_input(void) {
    unsigned int buttons_p1 = controller_p1[0];
    unsigned int buttons_p2 = controller_p2[0];
    
    if (game_state == STATE_START_SCREEN || game_state == STATE_GAME_OVER) {
        // Either player can start/restart
        if ((buttons_p1 & BTN_START) || (buttons_p2 & BTN_START)) {
            delay_ms(200);  // Debounce
            
            // Initialize Player 1 (Green, left side)
            snake1_length = INITIAL_SNAKE_LENGTH;
            snake1_head_idx = INITIAL_SNAKE_LENGTH - 1;
            snake1_tail_idx = 0;
            snake1_direction = DIR_RIGHT;
            snake1_next_direction = DIR_RIGHT;
            snake1_alive = 1;
            
            for (unsigned char i = 0; i < INITIAL_SNAKE_LENGTH; i++) {
                snake1_x[i] = 16 + i;  // Start at x=16
                snake1_y[i] = 32;
            }
            
            // Initialize Player 2 (Yellow, right side)
            snake2_length = INITIAL_SNAKE_LENGTH;
            snake2_head_idx = INITIAL_SNAKE_LENGTH - 1;
            snake2_tail_idx = 0;
            snake2_direction = DIR_LEFT;
            snake2_next_direction = DIR_LEFT;
            snake2_alive = 1;
            
            for (unsigned char i = 0; i < INITIAL_SNAKE_LENGTH; i++) {
                snake2_x[i] = 48 - i;  // Start at x=48, moving left
                snake2_y[i] = 32;
            }
            
            // Spawn initial food
            spawn_food();
            
            // Reset scores
            score_p1 = 0;
            score_p2 = 0;
            frame_counter = 0;
            winner = WINNER_NONE;
            
            // Start playing
            game_state = STATE_PLAYING;
        }
    } else if (game_state == STATE_PLAYING) {
        // Player 1 input (if alive)
        if (snake1_alive) {
            if (buttons_p1 & BTN_UP && snake1_direction != DIR_DOWN) {
                snake1_next_direction = DIR_UP;
            } else if (buttons_p1 & BTN_DOWN && snake1_direction != DIR_UP) {
                snake1_next_direction = DIR_DOWN;
            } else if (buttons_p1 & BTN_LEFT && snake1_direction != DIR_RIGHT) {
                snake1_next_direction = DIR_RIGHT;  // Swapped due to rotation
            } else if (buttons_p1 & BTN_RIGHT && snake1_direction != DIR_LEFT) {
                snake1_next_direction = DIR_LEFT;   // Swapped due to rotation
            }
        }
        
        // Player 2 input (if alive)
        if (snake2_alive) {
            if (buttons_p2 & BTN_UP && snake2_direction != DIR_DOWN) {
                snake2_next_direction = DIR_UP;
            } else if (buttons_p2 & BTN_DOWN && snake2_direction != DIR_UP) {
                snake2_next_direction = DIR_DOWN;
            } else if (buttons_p2 & BTN_LEFT && snake2_direction != DIR_RIGHT) {
                snake2_next_direction = DIR_RIGHT;  // Swapped due to rotation
            } else if (buttons_p2 & BTN_RIGHT && snake2_direction != DIR_LEFT) {
                snake2_next_direction = DIR_LEFT;   // Swapped due to rotation
            }
        }
    }
}

// ============================================================================
// RENDERING
// ============================================================================

// Draw a single digit at position
void draw_digit(unsigned char digit, unsigned char start_x, unsigned char start_y) {
    if (digit > 9) return;
    
    for (unsigned char row = 0; row < 7; row++) {
        unsigned char pattern = digit_patterns[digit][row];
        for (unsigned char col = 0; col < 5; col++) {
            if (pattern & (1 << (4 - col))) {
                fb_write(start_x + col, start_y + row, COLOR_WHITE);
            }
        }
    }
}

// Draw 2-digit score
void draw_score_2digit(unsigned int score_value, unsigned char start_x, unsigned char start_y) {
    // Extract tens digit
    unsigned char tens = 0;
    unsigned int temp = score_value;
    while (temp >= 10) {
        temp = temp - 10;
        tens++;
    }
    unsigned char ones = temp;
    
    // Draw digits
    draw_digit(tens, start_x, start_y);
    draw_digit(ones, start_x + 8, start_y);
}

// Render start screen
void render_start_screen(void) {
    clear_screen();
    
    // Blinking "PRESS START" animation
    if ((frame_counter >> 4) & 1) {
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
    for (unsigned char y = 8; y < 16; y++) {
        for (unsigned char x = 16; x < 48; x++) {
            fb_write(x, y, COLOR_RED);
        }
    }
    
    // Draw P1 score (left)
    draw_score_2digit(score_p1, 12, 24);
    
    // Draw P2 score (right)
    draw_score_2digit(score_p2, 44, 24);
    
    // Draw winner indicator
    if (winner == WINNER_P1) {
        // Green box around P1 score
        for (unsigned char x = 10; x < 30; x++) {
            fb_write(x, 22, COLOR_GREEN);
            fb_write(x, 33, COLOR_GREEN);
        }
        for (unsigned char y = 22; y < 34; y++) {
            fb_write(10, y, COLOR_GREEN);
            fb_write(29, y, COLOR_GREEN);
        }
    } else if (winner == WINNER_P2) {
        // Yellow box around P2 score
        for (unsigned char x = 42; x < 62; x++) {
            fb_write(x, 22, COLOR_YELLOW);
            fb_write(x, 33, COLOR_YELLOW);
        }
        for (unsigned char y = 22; y < 34; y++) {
            fb_write(42, y, COLOR_YELLOW);
            fb_write(61, y, COLOR_YELLOW);
        }
    } else if (winner == WINNER_DRAW) {
        // White box around both scores
        for (unsigned char x = 10; x < 62; x++) {
            fb_write(x, 22, COLOR_WHITE);
            fb_write(x, 33, COLOR_WHITE);
        }
        for (unsigned char y = 22; y < 34; y++) {
            fb_write(10, y, COLOR_WHITE);
            fb_write(61, y, COLOR_WHITE);
        }
    }
    
    // Draw "PRESS START" pattern (bottom)
    if ((frame_counter >> 3) & 1) {
        for (unsigned char y = 46; y < 54; y++) {
            for (unsigned char x = 16; x < 48; x++) {
                fb_write(x, y, COLOR_WHITE);
            }
        }
    }
}

// Render game (both snakes and food)
void render_game(void) {
    clear_screen();
    
    // Draw food (2×2 block)
    for (unsigned char dy = 0; dy < 2; dy++) {
        for (unsigned char dx = 0; dx < 2; dx++) {
            fb_write(food_x + dx, food_y + dy, COLOR_RED);
        }
    }
    
    // Draw snake1 (green) if alive
    if (snake1_alive) {
        unsigned char idx = snake1_tail_idx;
        unsigned char count = snake1_length;
        while (count > 0) {
            fb_write(snake1_x[idx], snake1_y[idx], COLOR_GREEN);
            idx = (idx + 1) & 0xFF;
            count--;
        }
    }
    
    // Draw snake2 (yellow) if alive
    if (snake2_alive) {
        unsigned char idx = snake2_tail_idx;
        unsigned char count = snake2_length;
        while (count > 0) {
            fb_write(snake2_x[idx], snake2_y[idx], COLOR_YELLOW);
            idx = (idx + 1) & 0xFF;
            count--;
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
    winner = WINNER_NONE;
    score_p1 = 0;
    score_p2 = 0;
    snake1_alive = 0;
    snake2_alive = 0;
    
    // Main loop
    while (1) {
        // Process controller input
        process_input();
        
        // Update game state
        if (game_state == STATE_PLAYING) {
            // Apply buffered directions
            snake1_direction = snake1_next_direction;
            snake2_direction = snake2_next_direction;
            
            // Move snakes every N frames
            if ((frame_counter & (FRAMES_PER_MOVE - 1)) == 0) {
                move_snake1();
                move_snake2();
                
                // Check if game over
                if (!snake1_alive || !snake2_alive) {
                    game_state = STATE_GAME_OVER;
                    
                    // Determine winner
                    if (!snake1_alive && !snake2_alive) {
                        winner = WINNER_DRAW;
                    } else if (!snake1_alive) {
                        winner = WINNER_P2;
                    } else {
                        winner = WINNER_P1;
                    }
                }
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
