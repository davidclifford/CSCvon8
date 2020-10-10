#
# VGA PIC converter
#

from numpy import uint8
from PIL import Image
import sys
import pygame
from pygame import gfxdraw

filename = 'gf4'

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
hex_file = open(filename+'.hex', 'w')

for y in range(120):
    hex_file.write(f'C{y:02x}00\n')
    for x in range(160):
        pix = pixels[x, y]
        red = pix[0] >> 6
        grn = pix[1] >> 6
        blu = pix[2] >> 6
        colour = red << 4 | grn << 2 | blu << 0
        pic_file.write(uint8(colour))
        hex_file.write(f'{colour:02x}')
        plot(x, y, red, grn, blu)
    hex_file.write('Z')
    pygame.display.update()

pic_file.close()
hex_file.close()

while True:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            sys.exit()
