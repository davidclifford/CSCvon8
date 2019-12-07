#
# VGA PIC converter
#

from numpy import uint8
from PIL import Image
import sys
import pygame
from pygame import gfxdraw

filename = 'manicminer'


def plot(x, y, r, g, b):
    psize = 8
    col = (r << 6, g << 6, b << 6)
    for yy in range(psize):
        for xx in range(psize):
            gfxdraw.pixel(screen, x*psize+xx, y*psize+yy, col)


pygame.init()
screen = pygame.display.set_mode((1280, 960))

image = Image.open(filename+'.png')
pixels = image.load()

pic_file = open(filename+'.bin', 'wb')

for y in range(512):
    for x in range(256):
        try:
            pix = pixels[x, y]
            red = pix[0] >> 6
            grn = pix[1] >> 6
            blu = pix[2] >> 6
            colour = red << 4 | grn << 2 | blu << 0
            pic_file.write(uint8(colour))
            plot(x, y, red, grn, blu)

        except IndexError:
            pic_file.write(uint8(0))
    pygame.display.update()

pic_file.close()

while True:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            sys.exit()

