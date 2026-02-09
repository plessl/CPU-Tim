#define DISPLAY_HEIGHT 64
#define DISPLAY_WIDTH 64


int direction;
int direction_n;
int score;
int x, y; //Coordinates of head
int x_n, y_n; //New coordinates of head
char game_over;
char game_win;

volatile unsigned int * const fb_base = (volatile unsigned int *) 0x00020000;

void fb_write(unsigned row, unsigned col, unsigned r, unsigned g, unsigned b) {
    volatile unsigned int *fb = (volatile unsigned int *)fb_base;
    /*if (row < 0 || row >= SCREEN_HEIGHT || col < 0 || col >= SCREEN_WIDTH) {
        return;
    }*/
    r = (r >= 1) ? 1 : 0;
    g = (g >= 1) ? 1 : 0;
    b = (b >= 1) ? 1 : 0;

    fb[row * 64 + col] = (r << 2) | (g << 1) | b;
}

enum dir
{
    up = 1,
    down = 2,
    left = 3,
    right = 4
};

enum states
{
    snake = 1,
    head = 2,
    tail = 3,
    food = 4,
    empty = 0
};

unsigned char board[DISPLAY_HEIGHT][DISPLAY_WIDTH];

unsigned lfsr16(unsigned *reg) {
    // Bits 16, 14, 13, 11 XORen (1-basiert -> 15, 13, 12, 10 0-basiert)
    unsigned bit = ((*reg >> 0) ^ (*reg >> 2) ^ (*reg >> 3) ^ (*reg >> 5)) & 1;
    *reg = (*reg >> 1) | (bit << 15);
    return *reg;
}

void place_food(){
    unsigned seed = 0xACE1u;
    int food_x, food_y;
    do 
    {
        food_x = lfsr16(&seed) % DISPLAY_WIDTH;
        food_y = lfsr16(&seed) % DISPLAY_HEIGHT;
    } 
    while (board[food_y][food_x] != empty);
    board[food_y][food_x] = food;
}

void move_snake(int direction){
    if(direction == up){
        x_n +=1;
    }
    if(direction == down){
        x_n-=1;
    }
    if(direction == left){
        y_n-=1;
    }
    if(direction == right){
        y_n+=1;
    }

    if(x_n < 0 || x_n >= DISPLAY_HEIGHT || y_n < 0 || y_n >= DISPLAY_WIDTH || board[x_n][y_n] == snake){
        game_over = 1;
        return;
    }

    for(int i = 0; i< 64; i++){
        for(int j = 0; j < 0; j++){
            if(board[i][j]==tail){
                board[i][j] = empty;
                //add new tail
                if(direction_n == up){
                    board[i+1][j] = tail;
                }
                if(direction_n == down){
                    board[i-1][j] = tail;   
                }
                if(direction_n == left){
                    board[i][j+1] = tail;
                }
                if(direction_n == right){
                    board[i][j-1] = tail;
                }
            }
            if(board[i][j] == head){
                board[i][j] = snake;
            }
            if(board[i][j] == food && i == x_n && j == y_n){
                place_food();
                score++;
                //grow snake
                if(direction_n == up){
                    board[i+1][j] = head;
                    board[i][j] = snake;
                }
                if(direction_n == down){
                    board[i-1][j] = head;   
                    board[i][j] = snake;
                }
                if(direction_n == left){
                    board[i][j+1] = head;
                    board[i][j] = snake;
                }
                if(direction_n == right){
                    board[i][j-1] = head;
                    board[i][j] = snake;
                }
            }
        }
    }

    board[x_n][y_n] = head;
}

void write_board(){
    for(int i = 0; i< DISPLAY_HEIGHT; i++){
        for(int j = 0; j < DISPLAY_WIDTH; j++){
            if(board[i][j] == empty){
                fb_write(i, j, 0, 0, 0);
            }
            if(board[i][j] == food){
                fb_write(i, j, 1, 0, 0);
            }
            if(board[i][j] == snake || board[i][j] == head){
                fb_write(i, j, 0, 1, 0);
            }
        }
    }
}

// Simple 3x5 digit font
const unsigned char digits[10][5] = {
    {0x07,0x05,0x05,0x05,0x07}, // 0
    {0x02,0x06,0x02,0x02,0x07}, // 1
    {0x07,0x01,0x07,0x04,0x07}, // 2
    {0x07,0x01,0x07,0x01,0x07}, // 3
    {0x05,0x05,0x07,0x01,0x01}, // 4
    {0x07,0x04,0x07,0x01,0x07}, // 5
    {0x07,0x04,0x07,0x05,0x07}, // 6
    {0x07,0x01,0x02,0x04,0x04}, // 7
    {0x07,0x05,0x07,0x05,0x07}, // 8
    {0x07,0x05,0x07,0x01,0x07}  // 9
};

void draw_digit(int row, int col, int digit){
    if(digit < 0 || digit > 9) return;
    for(int i=0;i<5;i++){
        for(int j=0;j<3;j++){
            int pixel = (digits[digit][i] >> (2-j)) & 0x01;
            fb_write(row+i, col+j, pixel, pixel, pixel);
        }
    }
}

void draw_score(int row, int col, int score){
    int tens = 0;
    while(score >= 10){
        score -= 10;
        tens++;
    }
    if(tens > 0){
        draw_digit(row, col, tens);
        col += 4;
    }
    draw_digit(row, col, score);
}

void check_win(){
    for(int i = 0; i< DISPLAY_HEIGHT; i++){
        for(int j = 0; j < DISPLAY_WIDTH; j++){
            if(board[i][j] == empty || board[i][j] == food){
                return;
            }
        }
    }
    game_win = 1;
}

//prevent optimization for this function, otherwise the game will run too fast to be playable
#pragma GCC push_options
#pragma GCC optimize ("O0")
void delay(){
    for(int i = 0; i < 100000; i++){
        asm volatile("addi x0, x0, 0");
    }
}
#pragma GCC pop_options


int main(){
    //init board
    for(int i = 0; i< DISPLAY_HEIGHT; i++){
        for(int j = 0; j < DISPLAY_WIDTH; j++){
            board[i][j] = empty;
        }
    }    
    write_board();

    //init snake
    x_n = 0;
    y_n = 0;
    x = DISPLAY_HEIGHT/2;
    y = DISPLAY_WIDTH/2;
    score = 0;
    board[x][y] = head;
    direction = right;

    place_food();

    while(!game_over && !game_win){
        move_snake(direction);
        direction_n = direction;
        write_board();
        check_win();
        delay();
    }

    if(game_over){
        //display game over screen
        for(int i = 0; i< DISPLAY_HEIGHT; i++){
            for(int j = 0; j < DISPLAY_WIDTH; j++){
                fb_write(i, j, 0, 0, 0);
            }
        }
        //display score in center
        draw_score(DISPLAY_HEIGHT/2-2, DISPLAY_WIDTH/2 - 8, score);
        while(1); // stop here
    }
    if(game_win){
        //display win screen
        for(int i = 0; i< DISPLAY_HEIGHT; i++){
            for(int j = 0; j < DISPLAY_WIDTH; j++){
                fb_write(i, j, 0, 0, 0);
            }
        }
        //display score in center
        draw_score(DISPLAY_HEIGHT/2-2, DISPLAY_WIDTH/2 - 8, score);
        while(1); // stop here
    }
}