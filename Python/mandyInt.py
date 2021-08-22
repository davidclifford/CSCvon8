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

scale = 8
imgx = 160
imgy = 120
pygame.init()
screen = pygame.display.set_mode((imgx*scale, imgy*scale))
refresh = True

while True:

    if refresh:
        refresh = False
        for py in range(imgy):
            for px in range(imgx):
                xz = px / 64 - 2
                yz = py / 64 - 1
                x = 0
                y = 0

                for j in range(64):
                    if x*x + y*y > 4:
                        break
                    xt = x*x - y*y + xz
                    y = 2*x*y + yz
                    x = xt
                    print(x, y)

                i = 63-j
                for xx in range(scale):
                    for yy in range(scale):
                        c1 = (i % 4) * 64
                        c2 = ((i >> 2) % 4) * 64
                        c3 = ((i >> 4) % 4) * 64
                        gfxdraw.pixel(screen, px*scale + xx, py*scale + yy, (c1, c2, c3))

            pygame.display.update()

    for event in pygame.event.get():
        if event.type == pygame.KEYDOWN:
            k = chr(event.key)
            if k == 'q':
                exit(0)
