#
# Tetris
#

import sys
import pygame
from pygame import gfxdraw


def plot(x, y, colour):
    psize = 8
    col = ((colour & 0x3) << 6, ((colour >> 2) & 0x3) << 6, ((colour >> 4) & 0x3) << 6)
    print(col)
    for yy in range(psize):
        for xx in range(psize):
            gfxdraw.pixel(screen, x*psize+xx, y*psize+yy, col)


def init_display():
    offx = 16
    offy = 16
    for y in range(21):
        for x in range(12):
            if ((x == 0 or x == 11) and y < 20) or y == 20:
                plot(x + offx, y + offy, 0x015)
    pygame.display.update()


pygame.init()
screen = pygame.display.set_mode((1280, 960))

init_display()


while True:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            sys.exit()
        pygame.display.update()


