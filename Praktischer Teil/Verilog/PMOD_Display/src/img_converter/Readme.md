# PNG to RGB111 Converter

Here's a command-line tool that converts PNG images to 64×64 RGB111 format with output in row-major order:

```python
#!/usr/bin/env python3
"""
Convert PNG images to 64×64 RGB111 representation.
Output: Row-major order (y=0..63, x=0..63), one pixel per line in XRGB format.
"""

import sys
import argparse
from pathlib import Path
from PIL import Image

def convert_png_to_rgb111(input_path, dither=False):
    """
    Convert a PNG image to 64x64 RGB111 format.
    
    RGB111: 1 bit per channel (8 possible colors)
    XRGB format: Bits 2-0 contain RGB, bits 31-3 are 0
    
    Args:
        input_path: Path to input PNG file
        dither: If True, use dithering for better visual quality
        
    Returns:
        List of 4096 pixels (0-7) in row-major order
    """
    try:
        # Load and convert image
        img = Image.open(input_path)
        if img.mode != 'RGB':
            img = img.convert('RGB')
        
        # Resize to 64x64
        img = img.resize((64, 64), Image.Resampling.LANCZOS)
        
        # Optional dithering before quantization
        if dither:
            img = img.quantize(colors=8)
            img = img.convert('RGB')
        
        # Process pixels in row-major order
        pixels = []
        for y in range(64):
            for x in range(64):
                r, g, b = img.getpixel((x, y))
                
                # Quantize to 1-bit per channel (threshold at midpoint)
                r_bit = 1 if r >= 128 else 0
                g_bit = 1 if g >= 128 else 0
                b_bit = 1 if b >= 128 else 0
                
                # Pack as XRGB: [0][R][G][B] = bit pattern
                xrgb = (r_bit << 2) | (g_bit << 1) | b_bit
                pixels.append(xrgb)
        
        return pixels
    
    except FileNotFoundError:
        print(f"Error: File not found: {input_path}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error processing image: {e}", file=sys.stderr)
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser(
        description='Convert PNG to 64×64 RGB111 representation',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Output Format:
  Text mode (default): One hexadecimal value per line (000000-000007)
  Binary mode (--binary): 4 bytes per pixel, big-endian (00000000-00000007)
  
RGB111 Color Map:
  000000 = Black    | 000001 = Blue   | 000010 = Green | 000011 = Cyan
  000004 = Red      | 000005 = Magenta| 000006 = Yellow| 000007 = White

Examples:
  %(prog)s image.png                    # Hex output to stdout
  %(prog)s image.png -o output.txt      # Save to file
  %(prog)s image.png -f                 # With dithering
  %(prog)s image.png --binary -o out.bin  # Binary output
        """
    )
    
    parser.add_argument('input', type=Path, help='Input PNG file')
    parser.add_argument('-o', '--output', type=Path, help='Output file (default: stdout)')
    parser.add_argument('-f', '--dither', action='store_true',
                       help='Apply dithering for better quality')
    parser.add_argument('--binary', action='store_true',
                       help='Output binary (4 bytes per pixel, big-endian)')
    
    args = parser.parse_args()
    
    # Convert image
    pixels = convert_png_to_rgb111(args.input, dither=args.dither)
    
    # Validate output
    assert len(pixels) == 4096, "Expected 4096 pixels (64×64)"
    assert all(0 <= p <= 7 for p in pixels), "All pixels should be 0-7"
    
    # Output
    if args.binary:
        file_obj = sys.stdout.buffer if not args.output else open(args.output, 'wb')
        try:
            for pixel in pixels:
                file_obj.write(pixel.to_bytes(4, 'big'))
        finally:
            if args.output:
                file_obj.close()
    else:
        file_obj = open(args.output, 'w') if args.output else sys.stdout
        try:
            for pixel in pixels:
                file_obj.write(f"{pixel:08x}\n")
        finally:
            if args.output:
                file_obj.close()

if __name__ == '__main__':
    main()
```

## Installation

```bash
# Install required dependencies
pip install Pillow

# Make script executable
chmod +x png2rgb111.py
```

## Usage Examples

### Basic conversion to stdout:
```bash
./png2rgb111.py image.png
```

Output displays 4096 lines (one per pixel):
```
000000
000001
000111
...
```

### Save to file:
```bash
./png2rgb111.py image.png -o output.txt
```

### With dithering for better color representation:
```bash
./png2rgb111.py image.png -f -o output.txt
```

### Binary output format (4 bytes per pixel, big-endian):
```bash
./png2rgb111.py image.png --binary -o output.bin
```

### Process output further:
```bash
# Count unique colors used
./png2rgb111.py image.png | sort -u | wc -l

# Convert hex to decimal
./png2rgb111.py image.png | xargs -I {} echo $((16#{}))
```

## Format Details

- **Resolution**: 64×64 pixels (4096 total)
- **Color Depth**: RGB111 (1 bit per channel = 8 colors)
- **Ordering**: Row-major ($y$ from 0 to 63, then $x$ from 0 to 63)
- **Output Format**: Each pixel as `0x000000VV` where $VV \in [00, 07]$
  - Bit 2: Red (0 or 1)
  - Bit 1: Green (0 or 1)
  - Bit 0: Blue (0 or 1)

This tool automatically handles RGBA, grayscale, and other PNG formats by converting to RGB before quantization.
