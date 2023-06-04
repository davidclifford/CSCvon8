# Draw line
import pygame
import sys
from pygame import gfxdraw
import random
import time

# drawing area
imgx = 640
imgy = 480
pygame.init()
scale = 1

wid = 640
height = 480
x_max = wid * 2 + 1
y_max = height * 2 + 1
screen = pygame.display.set_mode((x_max*scale, y_max*scale))
max_ever = 0
min_ever = wid * height

NORTH = 1 << 0
EAST  = 1 << 1
SOUTH = 1 << 2
WEST  = 1 << 3


def plot(x1, y1, c):
    for xx in range(scale):
        for yy in range(scale):
            gfxdraw.pixel(screen, x1 * scale + xx, y1 * scale + yy, c)


def point(x1, y1):
    pix = screen.get_at((x1 * scale, y1 * scale))
    return pix


def disp_grid():
    for yy in range(0, y_max, 2):
        for xx in range(0, x_max):
            plot(xx, yy, (128, 192, 255))

    for yy in range(0, y_max):
        for xx in range(0, x_max, 2):
            plot(xx, yy, (128, 192, 255))
    pygame.display.update()


while True:
    maze = [[0]*wid for i in range(height)]
    stack = []

    x = random.randint(0, wid-1)
    y = random.randint(0, height-1)
    visited = 1

    screen.fill((0, 0, 0))
    plot(x * 2 + 1, y * 2 + 1, (128, 128, 128))

    direct = ((0, -1, NORTH, SOUTH), (1, 0, EAST, WEST), (0, 1, SOUTH, NORTH), (-1, 0, WEST, EAST))
    # disp_grid()

    col = (random.randint(64, 255), random.randint(64, 255), random.randint(64, 255))
    max_sp = 0

    choices = []
    while True:
        choices.clear()
        for d in direct:
            ix, iy, _, _ = d
            nx = x + ix
            ny = y + iy
            if 0 <= nx < wid and 0 <= ny < height:
                if maze[ny][nx] == 0:
                    choices.append(d)
        if choices:
            stack.append((x, y))
            if len(stack) > max_sp:
                max_sp = len(stack)

            visited += 1

            ix, iy, c, n = random.choice(choices)

            plot(x * 2 + 1 + ix, y * 2 + 1 + iy, col)

            maze[y][x] |= c

            x += ix
            y += iy

            maze[y][x] |= n

            plot(x * 2 + 1, y * 2 + 1, col)
        else:
            col2 = col
            while col == col2:
                col2 = (random.randint(64, 255), random.randint(64, 255), random.randint(64, 255))
            col = col2
            x, y = stack.pop()
            if not stack:
                break

    pygame.display.flip()



    max_ever = max(max_sp, max_ever)
    min_ever = min(max_sp, min_ever)
    print('MAX', visited, max_sp, min_ever, max_ever)

    x = 0
    y = 0

    go = True
    while go:
        # if max_sp < max_ever and max_sp > min_ever:
        #     go = False

        ix = 0
        iy = 0
        d = 0

        col = point(x * 2 + 1, y * 2 + 1)
        plot(x * 2 + 1, y * 2 + 1, (255, 255, 255))
        pygame.display.update()

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()

            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_ESCAPE:
                    pygame.quit()
                    sys.exit()
                if event.key == pygame.K_SPACE:
                    go = False
                if event.key == pygame.K_w:
                    iy = -1
                    d = NORTH
                if event.key == pygame.K_s:
                    iy = 1
                    d = SOUTH
                if event.key == pygame.K_d:
                    ix = 1
                    d = EAST
                if event.key == pygame.K_a:
                    ix = -1
                    d = WEST

        plot(x * 2 + 1, y * 2 + 1, col)

        xx = x + ix
        yy = y + iy

        if 0 <= xx < wid and 0 <= yy < height:
            if (maze[y][x] & d) != 0:
                x = xx
                y = yy

