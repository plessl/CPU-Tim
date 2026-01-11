#!/usr/bin/env python3
"""
Convert PNG images to 64×64 RGB111 representation.
Output: Row-major order (y=0..63, x=0..63), one pixel per line as 4-bit text string.
"""

import sys
import argparse
from pathlib import Path
from PIL import Image


def convert_png_to_rgb111(input_path, dither=False):
    """
    Convert a PNG image to 64x64 RGB111 format.
    
    RGB111: 1 bit per channel (8 possible colors)
    XRGB format: X=0 (always), followed by R, G, B bits
    
    Args:
        input_path: Path to input PNG file
        dither: If True, use dithering for better visual quality
        
    Returns:
        List of 4096 pixels as (x, r, g, b) bit tuples
    """
    try:
        img = Image.open(input_path)
        if img.mode != 'RGB':
            img = img.convert('RGB')
        
        img = img.resize((64, 64), Image.Resampling.LANCZOS)
        
        if dither:
            img = img.quantize(colors=8)
            img = img.convert('RGB')
        
        pixels = []
        for y in range(64):
            for x in range(64):
                r, g, b = img.getpixel((x, y))
                
                r_bit = 1 if r >= 128 else 0
                g_bit = 1 if g >= 128 else 0
                b_bit = 1 if b >= 128 else 0
                
                pixels.append((0, r_bit, g_bit, b_bit))
        
        return pixels
    
    except FileNotFoundError:
        print(f"Error: File not found: {input_path}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error processing image: {e}", file=sys.stderr)
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(
        description='Convert PNG to 64x64 RGB111 representation'
    )
    
    parser.add_argument('input', type=Path, help='Input PNG file')
    parser.add_argument('-o', '--output', type=Path, help='Output file (default: stdout)')
    parser.add_argument('-f', '--dither', action='store_true',
                        help='Apply dithering for better quality')
    
    args = parser.parse_args()
    
    pixels = convert_png_to_rgb111(args.input, dither=args.dither)
    
    assert len(pixels) == 4096, "Expected 4096 pixels (64x64)"
    
    file_obj = open(args.output, 'w') if args.output else sys.stdout
    try:
        for x, r, g, b in pixels:
            file_obj.write(f"{x}{r}{g}{b}\n")
    finally:
        if args.output:
            file_obj.close()


if __name__ == '__main__':
    main()
