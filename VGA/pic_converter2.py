import json#
# VGA PIC converter
#

from numpy import uint8
from PIL import Image
import sys
import pygame
from pygame import gfxdraw

filename = 'finch'
dither = False


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

if dither:
    filename = filename + '_d'
pic_file = open(filename+'.bin', 'wb')
hex_file = open(filename+'.hex', 'w')


def pix_update(x, y, r, g, b, fact):
    if x < 0 or x > 159 or y < 0 or y > 119:
        return
    p = pixels[x, y]
    rr = p[0] + int(r * fact)
    gg = p[1] + int(g * fact)
    bb = p[2] + int(b * fact)
    rr = max(min(rr, 255), 0)
    gg = max(min(gg, 255), 0)
    bb = max(min(bb, 255), 0)
    print(rr)
    p = (rr, gg, bb)
    pixels[x, y] = p


for y in range(120):
    hex_file.write(f'C{y:02x}00\n')
    for x in range(256):
        if x < 160:
            pix = pixels[x, y]
            r = pix[0] >> 6
            g = pix[1] >> 6
            b = pix[2] >> 6

            red = r << 6
            green = g << 6
            blue = b << 6

            err_r = pix[0] - red
            err_g = pix[1] - green
            err_b = pix[2] - blue

            if dither:
                pix_update(x+1, y, err_r, err_b, err_g, 7.0/16.0)
                pix_update(x-1, y+1, err_r, err_b, err_g, 3.0/16.0)
                pix_update(x, y+1, err_r, err_b, err_g, 5.0/16.0)
                pix_update(x+1, y+1, err_r, err_b, err_g, 1.0/16.0)

            colour = r << 4 | g << 2 | b << 0
            pic_file.write(uint8(colour))
            hex_file.write(f'{colour:02x}')
            plot(x, y, r, g, b)
        else:
            pic_file.write(uint8(0))

    hex_file.write('Z')
    pygame.display.update()

pic_file.close()
hex_file.close()

while True:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            sys.exit()
