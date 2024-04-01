# Usage:
# `py converter.py filename.png` to convert `filename.png` into instructions
# `py converter.py filename.png > output.txt` stores in `output.txt` instead of standard output

import sys
from PIL import Image

# CONSTANTS
FILENAME = 'slime.png'                  # Filename; overwritten if a command line argument is passed
COLOUR_REG = r'$t0'                     # Register used to store colours; will be overwritten
ADDRESS_REG = r'PLAYER_LOCATION'        # Register containing the address of the top left location to draw
LEFT_PADDING = '\t'                     # String prepended to every instruction
VERBOSE = True                          # Output extra information (filename, width and height)


# Read first command-line arg
if len(sys.argv) >= 2:
    FILENAME = sys.argv[1]
if VERBOSE:
    print(f'Converting file "{FILENAME}"')


# Open image file
im = Image.open(FILENAME)
width, height = im.size
if VERBOSE:
        print(f'{width=} {height=}')


# Convert to instructions
pixels = iter(im.getdata())     # next(pixels) = (red, green, blue, alpha)

for i in range(height):
    for j in range(width):
        r, g, b, _ = next(pixels)
        offset = i * width + j
        
        load_col_instruction = f'li {COLOUR_REG}, {hex(r << 16 | g << 8 | b)}'
        draw_pixel_instruction = f'sw {COLOUR_REG}, {offset}({ADDRESS_REG})'

        print(LEFT_PADDING + load_col_instruction)
        print(LEFT_PADDING + draw_pixel_instruction)
