# Mandelbrot fractal
# FB - 201003254
import pygame
import sys
from pygame import gfxdraw

# drawing area
xa1 = -2.0
xb1 = 1.0
ya1 = -1.5
yb1 = 1.5

zoom = 1
xoff = 0
yoff = 0


# max iterations allowed
maxIt = 640

# image sized
imgx = 160
imgy = 120
pygame.init()
scale = 6
screen = pygame.display.set_mode((imgx*scale, imgy*scale))
redraw = True

while True:
    if redraw:
        xa = xa1 / zoom + xoff
        xb = xb1 / zoom + xoff
        ya = ya1 / zoom + yoff
        yb = yb1 / zoom + yoff

        redraw = False
        for y in range(imgy):
            zy = y * (yb - ya) / (imgy - 1) + ya
            for x in range(imgx):
                zx = x * (xb - xa) / (imgx - 1) + xa
                z = zx + zy * 1j
                c = z
                for j in range(maxIt):
                    # print(i, x, y, zx, zy, abs(z))
                    if abs(z) > 2.0:
                        break
                    z = z * z + c

                i = j
                if i == maxIt-1:
                    i = 0
                for xx in range(scale):
                    for yy in range(scale):
#                        gfxdraw.pixel(screen, x*scale+xx, y*scale+yy, (i % 4 * 64, i % 8 * 32, i % 16 * 16))
                        gfxdraw.pixel(screen, x*scale+xx, y*scale+yy, ((i % 4) * 64, ((i>>2) % 4) * 64, ((i>>4) % 4) * 64))

        pygame.display.update()

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            exit(0)
        if event.type == pygame.KEYDOWN:
            k = chr(event.key)
            if k == '=':
                zoom = zoom*2
                redraw = True
            if k == '-':
                if zoom > 0:
                    zoom = zoom/2
                redraw = True
            if k == 'a':
                xoff = xoff-1/zoom
                redraw = True
            if k == 'd':
                xoff = xoff+1/zoom
                redraw = True
            if k == 'w':
                yoff = yoff-1/zoom
                redraw = True
            if k == 's':
                yoff = yoff+1/zoom
                redraw = True
            if k == 'q':
                pygame.quit()
                exit(0)

