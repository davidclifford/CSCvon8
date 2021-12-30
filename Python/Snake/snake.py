import sys
import pygame
import random
import time
from pygame import gfxdraw

pygame.init()
screen = pygame.display.set_mode((1280, 960))
font = pygame.font.SysFont("monospace", 30)
quited = False

area = [0] * 1200
_empty = 0
_up = 1
_right = 2
_down = 3
_left = 4
_food = 5
_wall = 6


def new_food():
    while True:
        p = random.randint(0, 1200-1)
        if area[p] == _empty:
            area[p] = _food
            break


def plot(x, y, colour):
    psize = 16
    col = (((colour >> 4) & 0x3) << 6, ((colour >> 2) & 0x3) << 6, (colour & 0x3) << 6)
    for yy in range(psize):
        for xx in range(psize):
            gfxdraw.pixel(screen, x * psize + xx, y * psize + yy, col)


def display():
    for y in range(30):
        for x in range(40):
            addr = y*40+x
            sq = area[addr]
            col = 0
            if sq == _food:
                col = 0x30
            if sq == _up or sq == _down or sq == _left or sq == _right:
                col = 0x0c
            if sq == _wall:
                col = 0x03
            if addr == snake_head:
                col = 0x3c
            if addr == snake_tail:
                col = 0x0f
            plot(x, y, col)
    pygame.display.update()


while not quited:
    screen.fill((0, 0, 0))

    # Init area
    area = [0] * 1200

    for i in range(40):
        area[i] = _wall
        area[29*40 + i] = _wall

    for i in range(30):
        area[i*40] = _wall
        area[i*40 + 39] = _wall

    snake_head = 581
    snake_tail = 580
    d = _right
    score = 0

    area[snake_head] = d
    area[snake_tail] = d

    for _ in range(8):
        new_food()

    last_step = time.time()

    play = True
    display()

    while play:
        display()
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()

            if event.type == pygame.KEYDOWN:
                key = event.key

                if key == pygame.K_a:
                    # go left
                    d = _left
                if key == pygame.K_w:
                    # go up
                    d = _up
                if key == pygame.K_s:
                    # go down
                    d = _down
                if key == pygame.K_d:
                    # go right
                    d = _right
                if key == pygame.K_q:
                    play = False

        next_place = snake_head
        if d == _up:
            next_place -= 40
        if d == _down:
            next_place += 40
        if d == _left:
            next_place -= 1
        if d == _right:
            next_place += 1

        last_step = time.time()

        into = area[next_place]
        if into == _food:
            new_food()
            score += 1

        if into == _food or into == _empty:
            area[snake_head] = d
            snake_head = next_place

        if into == _empty:
            tail = area[snake_tail]
            area[snake_tail] = _empty
            if tail == _up:
                snake_tail -= 40
            if tail == _down:
                snake_tail += 40
            if tail == _left:
                snake_tail -= 1
            if tail == _right:
                snake_tail += 1

        area[snake_head] = d
        snake_head = next_place

        if into != _empty and into != _food:
            play = False
        # display()

    # Game over
    stop = False
    while not stop:
        for event in pygame.event.get():
            if event.type == pygame.KEYUP:
                key = event.key
                if key == pygame.K_RETURN:
                    stop = True

pygame.quit()
sys.exit()
