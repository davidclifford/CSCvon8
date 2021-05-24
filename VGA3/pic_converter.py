import json#
# VGA PIC converter
#

from numpy import uint8, uint16
from PIL import Image
import sys
import pygame
from pygame import gfxdraw

filename = 'finch'

RESET = 0b0000000000000001
HS = 0b0000000000000010
VS = 0b0000000000000100


def plot(x, y, r, g, b):
    xsize = 2
    ysize = 1
    col = (r << 4, g << 4, b << 4)
    for yy in range(ysize):
        for xx in range(xsize):
            gfxdraw.pixel(screen, x*xsize+xx, y*ysize+yy, col)


pygame.init()
screen = pygame.display.set_mode((800, 600))

image = Image.open(filename+'.png')
pixels = image.load()

rom_file = open(filename + '.bin', 'wb')

for y in range(625):
    for x in range(512):
        data = 0
        if x < 400 and y < 600:
            pix = pixels[x, y]
            red = pix[0] >> 4
            grn = pix[1] >> 4
            blu = pix[2] >> 4
            colour = red << 8 | grn << 4 | blu << 0
            data = data | uint16(colour << 3)
            plot(x, y, red, grn, blu)

        if 412 <= x < 448:
            data = data | HS
        if 601 <= y < 603:
            data = data | VS
        if y < 624 or x < 511:
            data = data | RESET

        rom_file.write(uint16(data))

    pygame.display.update()

rom_file.close()

while True:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            sys.exit()
