# PNG to RGB111 Converter (Text Bits Format)

Here's the updated tool that outputs each pixel as a 4-character string representing the bits:

```python
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
                
                # Store as (x_bit, r_bit, g_bit, b_bit) where x_bit is always 0
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
        description='Convert PNG to 64×64 RGB111 representation',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Output Format:
  Each line contains 4 characters: X R G B (where X is always 0)
  Each character is '0' or '1' representing bit values
  
RGB111 Color Map:
  0000 = Black     | 0001 = Blue    | 0010 = Green | 0011 = Cyan
  0100 = Red       | 0101 = Magenta | 0110 = Yellow| 0111 = White

Examples:
  %(prog)s image.png                    # Output to stdout
  %(prog)s image.png -o output.txt      # Save to file
  %(prog)s image.png -f                 # With dithering
  %(prog)s image.png -o output.txt -f   # With dithering to file
        """
    )
    
    parser.add_argument('input', type=Path, help='Input PNG file')
    parser.add_argument('-o', '--output', type=Path, help='Output file (default: stdout)')
    parser.add_argument('-f', '--dither', action='store_true',
                       help='Apply dithering for better quality')
    
    args = parser.parse_args()
    
    # Convert image
    pixels = convert_png_to_rgb111(args.input, dither=args.dither)
    
    # Validate output
    assert len(pixels) == 4096, "Expected 4096 pixels (64×64)"
    
    # Output
    file_obj = open(args.output, 'w') if args.output else sys.stdout
    try:
        for x, r, g, b in pixels:
            file_obj.write(f"{x}{r}{g}{b}\n")
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

Output displays 4096 lines (one 4-character string per pixel):
```
0000
0001
0111
0000
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

### Process output further:
```bash
# Count unique colors
./png2rgb111.py image.png | sort -u | wc -l

# Find all red pixels
./png2rgb111.py image.png | grep "^0100$"

# Convert to decimal (first convert from binary to decimal)
./png2rgb111.py image.png | awk '{print "0b"$1}' | xargs printf '%d\n'
```

## Output Format Details

Each line contains exactly **4 characters**:

| Position | Meaning | Value |
|----------|---------|-------|
| 1        | X (unused) | Always `0` |
| 2        | Red bit | `0` or `1` |
| 3        | Green bit | `0` or `1` |
| 4        | Blue bit | `0` or `1` |

**Example colors**:
- `0000` = Black
- `0100` = Red
- `0010` = Green
- `0001` = Blue
- `0110` = Yellow (Red + Green)
- `0101` = Magenta (Red + Blue)
- `0011` = Cyan (Green + Blue)
- `0111` = White

The output is in row-major order: pixels are ordered from $y = 0$ to $63$, and within each row from $x = 0$ to $63$.


