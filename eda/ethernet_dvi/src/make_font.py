#!/usr/bin/env python3

from typing import Tuple
from PIL import Image
from PIL import GifImagePlugin

img = Image.open('./digits_0_to_9.png')
#img = img.convert('RGB')
print(f"{img.size} {img.format} {img.mode} {img.getpixel((0,0))}")

stride = (img.size[0] + 7) & ~7

def is_black(pixel: Tuple[int, int, int]) -> bool:
    return pixel[0] + pixel[1] + pixel[2] < 128*3
def is_transparent(pixel: Tuple[int, int, int, int]) -> bool:
    return pixel[3] < 128

def bit_reverse(b:int) -> int:
    r = 0
    for i in range(8):
        r <<= 1
        r |= b & 1
        b >>= 1
    return r

font_chars = 11
font_width = 64
font_height = 64

buffer = bytearray(font_chars * font_width * font_height // 8)
ptr = memoryview(buffer)

for font_index in range(font_chars):
    for y in range(font_height):
        pixels = 0
        for x in range(font_width):
            pixel = img.getpixel((font_index * font_width + x, y))
            pixels >>= 1
            pixels |= 128 if not is_transparent(pixel) else 0
            if (x & 7) == 7:
                ptr[0] = pixels
                ptr = ptr[1:]
                pixels = 0

with open('fonts.hex', "w") as f:
    for b in buffer:
        print(f"{b:02X}", file=f)
with open('fonts.bin', "wb") as f:
    for i in range(len(buffer)):
        buffer[i] = bit_reverse(buffer[i])
    f.write(buffer)
        
