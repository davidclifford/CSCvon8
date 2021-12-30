# 10 SCREEN 0
# 100 FOR PY=0 TO 21
# 110 FOR PX=0 TO 31
# 120 XZ = PX*3.5/32-2.5
# 130 YZ = PY*2/22-1
# 140 X = 0
# 150 Y = 0
# 160 FOR I=0 TO 14
# 170 IF X*X+Y*Y > 4 THEN GOTO 215
# 180 XT = X*X - Y*Y + XZ
# 190 Y = 2*X*Y + YZ
# 200 X = XT
# 210 NEXT I
# 215 I = I-1
# 230 VPOKE 0,PY*256+PX*2+1,I*16
# 240 NEXT PX
# 250 PRINT ""
# 260 NEXT PY

import pygame
from pygame import gfxdraw
import time

BITS = 8
SCALE = 1 << BITS


def mult(a, b):
    sign = 0
    if a < 0:
        a = -a
        sign = 1
    if b < 0:
        b = -b
        sign = sign ^ 1

    r = int(a*b*SCALE)/SCALE
    #r = a*b
    if sign == 1:
        r = -r
    return r


scale = 8
imgx = 160
imgy = 120
pygame.init()
screen = pygame.display.set_mode((imgx*scale, imgy*scale))
refresh = True


def h(n):
    n *= 256
    if n < 0:
        n += 65536
    return hex(int(n+0.5))


tim = time.time()

while True:
    if refresh:
        refresh = False
        for py in range(imgy):
            for px in range(imgx):
                xz = px / 64 - 2
                yz = py / 64 - 1
                x = 0
                y = 0
                # print('xz, yz', xz, yz)

                for j in range(64):
                    x2 = mult(x, x)
                    y2 = mult(y, y)
                    # print('xz={} yz={} x={} x2={} y={} y2={} t={} '.format(h(xz), h(yz), h(x), h(x2), h(y), h(y2), h(x2+y2)), end='')
                    if y2 + x2 >= 4.0:
                        print()
                        break
                    xt = x2 - y2 + xz
                    # print('xt={}'.format(h(xt)))
                    y = mult(2, mult(x, y)) + yz
                    x = xt
                    # print('x, y', x, y)
                    # print('sx, sy', x*SCALE, y*SCALE)

                # print('-----------')
                i = j
                if i == 63:
                    i = 0
                for xx in range(scale):
                    for yy in range(scale):
                        c3 = (i % 4) * 64
                        c2 = ((i >> 2) % 4) * 64
                        c1 = ((i >> 4) % 4) * 64
                        gfxdraw.pixel(screen, px*scale + xx, py*scale + yy, (c1, c2, c3))

                if time.time() - tim > 1.0/60.0:
                    pygame.display.update()
                    tim = time.time()

    pygame.display.update()

    for event in pygame.event.get():
        if event.type == pygame.KEYDOWN:
            k = chr(event.key)
            if k == 'q':
                pygame.quit()
                exit(0)
        if event.type == pygame.QUIT:
            pygame.quit()
            exit(0)
