# Draw line
import pygame
import sys
from pygame import gfxdraw
import random
import time

# drawing area
imgx = 160
imgy = 120
pygame.init()
scale = 8
screen = pygame.display.set_mode((imgx*scale, imgy*scale))


def plot(x, y, c):
    for xx in range(scale):
        for yy in range(scale):
            gfxdraw.pixel(screen, x*scale+xx, y*scale+yy, c)

# 500 REM 'DRAW A LINE' from last position to X,Y
# 510 LET PLOTx=PEEK 23677: LET PLOTy=PEEK 23678
# 520 LET dx=SGN X: LET dy=SGN Y
# 530 LET X=ABS X: LET Y=ABS Y
# 540 IF X>=Y THEN GO TO 580
# 550 LET L=X: LET B=Y
# 560 LET ddx=0: LET ddy=dy
# 570 GO TO 610
# 580 IF X+Y=0 THEN STOP
# 590 LET L=Y: LET B=X
# 600 LET ddx=dx: LET ddy=0
# 610 LET H=B
# 620 LET i=INT (B/2)
# 630 FOR N=B TO 1 STEP -1
# 640 LET i=i+L
# 650 IF i < H THEN GO TO 690
# 660 LET i=i-H
# 670 LET ix=dx: LET iy=dy
# 680 GO TO 700
# 690 LET ix=ddx: LET iy=ddy
# 700 LET PLOTy=PLOTy+iy
# 710 IF PLOTy <0 OR PLOTy > 175 THEN STOP
# 720 LET PLOTx=PLOTx+ix
# 730 IF PLOTx <0 OR PLOTx > 255 THEN STOP
# 740 PLOT PLOTx,PLOTy
# 750 NEXT N
# 760 RETURN


def draw_line_x(x0, y0, x1, y1, c):
    dx = x1 - x0
    dy = y1 - y0
    sy = 1
    if dy < 0:
        sy = -1
        dy = -dy
    d = int(dx/2)
    x = x0
    y = y0
    while x <= x1:
        plot(x, y, c)
        x += 1
        d -= dy
        if d < 0:
            d += dx
            y = y + sy


def draw_line_y(x0, y0, x1, y1, c):
    dx = x1 - x0
    dy = y1 - y0
    sx = 1
    if dx < 0:
        sx = -1
        dx = -dx
    d = int(dy/2)
    x = x0
    y = y0
    while y <= y1:
        plot(x, y, c)
        y += 1
        d -= dx
        if d < 0:
            d += dy
            x = x + sx


def draw_line(x0, y0, x1, y1, c):
    if abs(x1 - x0) > abs(y1 - y0):
        if x1 > x0:
            draw_line_x(x0, y0, x1, y1, c)
        else:
            draw_line_x(x1, y1, x0, y0, c)
    else:
        if y1 > y0:
            draw_line_y(x0, y0, x1, y1, c)
        else:
            draw_line_y(x1, y1, x0, y0, c)


while True:
    # a = 1
    # x0 = a*int(random.randrange(160/a+1))
    # x1 = a*int(random.randrange(160/a+1))
    # y0 = a*int(random.randrange(120/a+1))
    # y1 = a*int(random.randrange(120/a+1))
    # c = (random.randrange(256), random.randrange(256), random.randrange(256))
    # drawLine(x0, y0, x1, y1, c)
    # # drawLine(x0, y0, x1, y1, (0,0,0))
    # if random.randrange(100) == 0:
    #     pygame.display.update()
    #     screen.fill((0,0,0))
    x0 = int(random.randrange(160))
    y0 = int(random.randrange(120))
    x1 = int(random.randrange(160))
    y1 = int(random.randrange(120))
    r = int(random.randrange(4))*64
    g = int(random.randrange(4))*64
    b = int(random.randrange(4))*64

    draw_line(x0, y0, x1, y1, (r, g, b))

    pygame.display.update()
    time.sleep(0.01)
    # draw_line(x0, y0, x1, y1, (0, 0, 0))

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            sys.exit()

