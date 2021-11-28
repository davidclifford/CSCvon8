#
# VGA5 Control ROM generator for 39SF040
# 256 x 768 (1024 x 768 @ 60Hz)
#

from numpy import uint8, uint16
from PIL import Image
import sys
import pygame
from pygame import gfxdraw

filename = 'the-hobbit'

Hsync = uint8(1) << 0
Vsync = uint8(1) << 1
Xinc = uint8(1) << 2
Creset = uint8(1) << 3
B = uint8(1) << 4
G = uint8(1) << 5
R = uint8(1) << 6
Yinc = uint8(1) << 7

pygame.init()
screen = pygame.display.set_mode((1024, 768))

image = Image.open(filename+'.png')
pixels = image.load()


def plot(x, y, r, g, b):
    xsize = 4
    ysize = 1
    col = (r*255, g*255, b*255)
    for yy in range(ysize):
        for xx in range(xsize):
            gfxdraw.pixel(screen, x*xsize+xx, y*ysize+yy, col)


# Initialise ROM image to all zeros (19 bit addresses for 39SF040)
control: uint8 = [0 for f in range(1 << 19)]
img_rom: uint8 = [0 for f in range(1 << 17)]

img_count = 0

# Set bits for complete ROM address space
for a in range(0, 2**19):
    # Reset is active low, keep high until all VGA lines completed
    if a < 336 * 806 - 2:
        control[a] |= Creset

    # Calculate x and y co-ords from address (336 is 1344/4)
    x = a % 336
    y = a // 336

    # Horizontal sync pulse (34 pixels)
    if x <= 256 + 6 or x >= 256 + 6 + 34:
        control[a] |= Hsync

    # Vertical sync pulse (6 lines)
    if y <= 768 + 3 or y >= 768 + 3 + 6:
        control[a] |= Vsync

    # Increment X counter
    if (256 <= x < 355) or y >= 768:
        control[a] |= Xinc

    # Increment Y counter
    if y % 4 < 3 or x < 335:
        control[a] |= Yinc

    # Test pixel output
    if x < 256 and y < 768:
        pix = pixels[x, y]
        red = 0 if pix[0] < 128 else 1
        grn = 0 if pix[1] < 128 else 1
        blu = 0 if pix[2] < 128 else 1
        colour = red << 2 | grn << 1 | blu << 0
        control[a] |= uint8(colour << 4)
        plot(x, y, red, grn, blu)

        if y % 4 == 0:
            img_rom[img_count] = colour
            img_count += 1

    if a % 1000 == 0:
        pygame.display.update()

control_bytes = bytearray(control)
control_bin = open("control_rom.bin", "wb")
control_bin.write(control_bytes)
control_bin.close()

image_bytes = bytearray(img_rom)
image_bin = open(filename+"_img.bin", "wb")
image_bin.write(image_bytes)
image_bin.close()

while True:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            sys.exit()