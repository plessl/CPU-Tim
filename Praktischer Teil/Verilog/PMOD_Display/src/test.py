import random

NUM_LINES = 4096
BITS_PER_LINE = 4
BLOCK_SIZE = 64


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


random_lines()