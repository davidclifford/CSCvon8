#
# Tetris
#

import sys
import pygame
import random
import time
from pygame import gfxdraw
from pygame import freetype

# square
shapes = [
    # I
    [
        [[1, 1, 1, 1], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
        [[1, 0, 0, 0], [1, 0, 0, 0], [1, 0, 0, 0], [1, 0, 0, 0]],
        [[1, 1, 1, 1], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
        [[1, 0, 0, 0], [1, 0, 0, 0], [1, 0, 0, 0], [1, 0, 0, 0]],
    ],
    # O
    [
        [[1, 1], [1, 1]],
        [[1, 1], [1, 1]],
        [[1, 1], [1, 1]],
        [[1, 1], [1, 1]],
    ],
    # T
    [
        [[1, 1, 1], [0, 1, 0], [0, 0, 0]],
        [[0, 1, 0], [1, 1, 0], [0, 1, 0]],
        [[0, 1, 0], [1, 1, 1], [0, 0, 0]],
        [[1, 0, 0], [1, 1, 0], [1, 0, 0]],
    ],
    # L
    [
        [[1, 1, 1], [1, 0, 0], [0, 0, 0]],
        [[1, 1, 0], [0, 1, 0], [0, 1, 0]],
        [[0, 0, 1], [1, 1, 1], [0, 0, 0]],
        [[1, 0, 0], [1, 0, 0], [1, 1, 0]],
    ],
    # J
    [
        [[1, 1, 1], [0, 0, 1], [0, 0, 0]],
        [[0, 1, 0], [0, 1, 0], [1, 1, 0]],
        [[1, 0, 0], [1, 1, 1], [0, 0, 0]],
        [[1, 1, 0], [1, 0, 0], [1, 0, 0]],
    ],
    # Z
    [
        [[1, 1, 0], [0, 1, 1], [0, 0, 0]],
        [[0, 1, 0], [1, 1, 0], [1, 0, 0]],
        [[1, 1, 0], [0, 1, 1], [0, 0, 0]],
        [[0, 1, 0], [1, 1, 0], [1, 0, 0]],
    ],
    # S
    [
        [[0, 1, 1], [1, 1, 0], [0, 0, 0]],
        [[1, 0, 0], [1, 1, 0], [0, 1, 0]],
        [[0, 1, 1], [1, 1, 0], [0, 0, 0]],
        [[1, 0, 0], [1, 1, 0], [0, 1, 0]],
    ]
]

blocks = [4, 2, 3, 3, 3, 3, 3]
colours = [0x30, 0x0C, 0x0F, 0x3D, 0x33, 0x03, 0x34]
offx = 30
offy = 16
score = 0


def plot(x, y, colour):
    psize = 16
    col = (((colour >> 4) & 0x3) << 6, ((colour >> 2) & 0x3) << 6, (colour & 0x3) << 6)
    for yy in range(psize):
        for xx in range(psize):
            gfxdraw.pixel(screen, x*psize+xx, y*psize+yy, col)


def init_display():
    # render text
    label = font.render("TETRIS", 1, (255, 255, 0))
    screen.blit(label, (540, 100))
    for y in range(23):
        for x in range(14):
            if ((x <= 1 or x >= 12) and y <= 20) or y > 20:
                plot(x + offx, y + offy, 0x15)
    pygame.display.update()


def draw_shape(column, height, shape, orentation, colour):
    dims = blocks[shape]
    column = column + 32
    height = height + 16
    for y in range(dims):
        for x in range(dims):
            if shapes[shape][orentation][y][x] == 1:
                plot(x+column, y+height, colour)


def does_it_fit(column, height, shape, dir):
    dims = blocks[shape]
    for y in range(dims):
        for x in range(dims):
            if shapes[shape][dir][y][x] == 1:
                try:
                    if board[column+x][height+y] > 0:
                        return False
                except IndexError as e:
                    return False
    return True


def update_board(column, height, shape, dir):
    dims = blocks[shape]
    for y in range(dims):
        for x in range(dims):
            if shapes[shape][dir][y][x] == 1:
                board[column+x][height+y] = colours[shape]

    delete_lines()

    draw_whole_board()
    pygame.display.update()


def draw_whole_board():
    for y in range(20):
        for x in range(10):
            plot(x+offx+2, y+offy+1, board[x][y])


def delete_lines():
    global score
    lines = 0
    for y in range(20):
        filled = True
        for x in range(10):
            if board[x][y] == 0:
                filled = False
        if filled:
            scroll_down_board(y)
            lines += 1
    if lines > 0:
        score += (lines-1)*60 + 40
    else:
        score += 5


def scroll_down_board(height):
    for y in range(height, 2, -1):
        for x in range(10):
            try:
                board[x][y] = board[x][y-1]
            except IndexError:
                print(x, y)


pygame.init()
screen = pygame.display.set_mode((1280, 960))
font = pygame.font.SysFont("monospace", 30)
quited = False

while not quited:
    screen.fill((0, 0, 0))
    init_display()
    shp = random.randint(0, 6)
    next = random.randint(0, 6)
    dir = 0
    height = 0
    random.seed()
    then = time.time()
    column = 4
    board = [[0] * 20 for _ in range(10)]
    play = True
    draw_shape(4, -3, next, 0, colours[next])
    drop = False
    score = 0

    while play:

        draw_shape(column, height, shp, dir, 0x0)
        _column = column
        _dir = dir
        _height = height
        score_label = font.render("Score: " + str(score), 1, (128, 128, 128))
        pygame.draw.rect(screen, (0, 0, 0), (520, 144, 180, 30))
        screen.blit(score_label, (520, 140))

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()

            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_ESCAPE:
                    pygame.quit()
                    sys.exit()
                if event.key == pygame.K_DOWN:
                    drop = True

            if event.type == pygame.KEYUP:

                if event.key == pygame.K_LEFT:
                    if column > 0:
                        column = (column - 1)
                if event.key == pygame.K_RIGHT:
                    if column < 9:
                        column = (column + 1)
                if event.key == pygame.K_UP:
                    dir = (dir - 1) % 4
                if event.key == pygame.K_s:
                    dir = (dir + 1) % 4

        now = time.time()
        if now - then >= (.01 if drop else .5):
            height += 1
            then = now

        if not does_it_fit(column, height, shp, dir):
            if column == _column and dir == _dir:
                draw_shape(column, height, shp, dir, colours[shp])
                update_board(column, height-1, shp, dir)
                if height < 3:
                    play = False

                draw_shape(4, -3, next, 0, 0)
                shp = next
                next = random.randint(0, 6)
                dir = 0
                height = 0
                column = 4
                draw_shape(4, -3, next, 0, colours[next])
                drop = False
            else:
                column = _column
                dir = _dir

        draw_shape(column, height, shp, dir, colours[shp])
        # draw_whole_board()

        pygame.display.flip()

    label = font.render("GAME OVER", 1, (0, 255, 0))
    screen.blit(label, (510, 120))
    pygame.display.flip()
    now = time.time()

    loop_back = True
    while loop_back:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()

            if event.type == pygame.KEYUP:
                if time.time() > now + 2:
                    loop_back = False

