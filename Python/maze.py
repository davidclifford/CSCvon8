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

wid = 5
hight = 5
x_max = wid * 2 + 1
y_max = hight * 2 + 1

maze = [[0]*wid]*hight

stack = []

print(maze)


def choose_neighbour(x, y):
    neighbour = []
    print(maze)
    for i in ((0,-1), (1,0), (0, 1), (-1, 0)):
        ix, iy = i
        print(ix, iy)
        if x+ix >= 0 and x+ix<wid-1 and y+iy >= 0 and y+iy<hight-1:
            if maze[x+ix][y+iy] == 0:
                neighbour.append((x+ix, y+iy))

    print(neighbour)
    if len(neighbour) == 0:
        return

    maze[x][y] = 1
    r = random.randrange(len(neighbour))
    nx, ny = neighbour[r]
    print(nx ,ny)
    plot(nx*2-1, ny*2-1, (128, 128, 128))
    choose_neighbour(nx, ny)


for y in range(0, y_max, 2):
    for x in range(0, x_max):
        plot(x, y, (128, 192, 255))

for y in range(0, y_max):
    for x in range(0, x_max, 2):
        plot(x, y, (128, 192, 255))


start_x = 0
start_y = 0

choose_neighbour(start_x, start_y)
pygame.display.update()
print(maze)

while True:

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            sys.exit()

    if event.type == pygame.KEYDOWN:
        if event.key == pygame.K_ESCAPE:
            pygame.quit()
            sys.exit()

