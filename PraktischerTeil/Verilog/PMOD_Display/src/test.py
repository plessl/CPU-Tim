import random

NUM_LINES = 4096
BITS_PER_LINE = 4
BLOCK_SIZE = 64

def green_square():
    for x in range(8):
        for x in range(8):
            print("0010")
        for y in range(64-8):
            print("0000")
    for x in range((64-8)*64):
        print("0000")
        
def horizontal_line(a):
    for x in range(64):
        print(a)
    for x in range(63*64):
        print("0000")

def red_vertical_line():
    for x in range(64):
        print("0100")
        for y in range(63):
            print("0000")

def colorful_corners():
    print("0001")
    for x in range(62):
        print("0000")
    print("0100")
    for x in range(62*64):
        print("0000")
    print("0010")
    for x in range(62):
        print("0000")
    print("0111")

def one_pixel(x):
    for x in range(x-1):
        print("0000")
    print("0100")
    for x in range((64*64)-(x)):
        print("0000")

def one_pixel_bottom():
    for x in range(32*64):
        print("0000")
    print("0100")
    for x in range((32*64)-1):
        print("0000")

def two_lines():
    for x in range(64):
        print("0001")
    for x in range(64):
        print("0100")
    for x in range(62*64):
        print("0000")

def line():
    for x in range(32):
        print("0100")
    for x in range(32):
        print("0001")
    for x in range((64*64)-64):
        print("0000")

def line_in_middle():
    for x in range(31*64):
        print("0000")
    for x in range(64):
        print("0100")
    for x in range(32*64):
        print("0000")

def pyramid():
    for row in range(32):
        # Left half (top to middle)
        left_empty = 31 - row
        colored = 2 + (2 * row)
        right_empty = 31 - row
        
        for _ in range(left_empty):
            print("0000")
        for _ in range(colored):
            print("0111")
        for _ in range(right_empty):
            print("0000")
    
    for row in range(32):
        # Right half (mirror of top)
        left_empty = row
        colored = 64 - (2 * row)
        right_empty = row
        
        for _ in range(left_empty):
            print("0000")
        for _ in range(colored):
            print("0111")
        for _ in range(right_empty):
            print("0000")

def test_pattern():
    """
    PMOD RGB111 test pattern with all 8 colors.
    Displays 8 horizontal color bars (8 rows each).
    Useful for identifying addressing issues:
    - Row addressing: vertical lines indicate column addressing issues
    - Column addressing: missing columns within a row
    
    Color format: 0RGB (LSB = B)
    """
    colors = [
        "0000",  # off
        "0001",  # blue
        "0010",  # green
        "0011",  # cyan
        "0100",  # red
        "0101",  # magenta
        "0110",  # yellow
        "0111"   # white
    ]
    
    # 8 horizontal color bars, 8 rows each (64 / 8 = 8)
    for color_idx in range(8):
        color = colors[color_idx]
        for row in range(8):
            for col in range(64):
                print(color)

def test_pattern_checkered():
    """
    Alternative test pattern with checkered 8x8 blocks.
    Alternates between color and black to test addressing precision.
    Useful for identifying pixel-level addressing errors.
    """
    colors = [
        "0001",  # blue
        "0010",  # green
        "0100",  # red
        "0111"   # white
    ]
    
    block_size = 8
    for row in range(64):
        for col in range(64):
            block_x = col // block_size
            block_y = row // block_size
            # Checkered pattern alternates blocks
            if (block_x + block_y) % 2 == 0:
                # Rotate through colors based on block position
                color = colors[(block_x + block_y) % len(colors)]
            else:
                color = "0000"
            print(color)

def lines():
    for x in range(8):
        print("0010")
    for y in range(56):
        print("0000")
    for x in range(7):
        print("0001")
        for y in range(63):
            print("0000")
    for x in range((64*(64-8))):
        print("0000")

lines()