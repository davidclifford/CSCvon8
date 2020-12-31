import sys
import pygame
import time
from pygame import gfxdraw

pygame.init()
screen = pygame.display.set_mode((1280, 960))
seed = 777


def plot(x, y, c):
    psize = 8
    r = (c >> 4) & 3
    g = (c >> 2) & 3
    b = c & 3
    col = (r << 6 | 0x3f, g << 6 | 0x3f, b << 6 | 0x3f)
    for yy in range(psize):
        for xx in range(psize):
            gfxdraw.pixel(screen, x*psize+xx, y*psize+yy, col)


def rand():
    global seed
    seed = seed ^ ((seed << 7) & 0xffff)
    seed = seed ^ ((seed >> 9) & 0xffff)
    seed = seed ^ ((seed << 8) & 0xffff)


t = time.time()
while True:
    for y in range(120):
        for x in range(160):
            rand()
            c = (seed>>8) & 0x3f
            plot(x, y, c)
            if time.time() - t > 0.01:
                pygame.display.update()
                t = time.time()

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            sys.exit()