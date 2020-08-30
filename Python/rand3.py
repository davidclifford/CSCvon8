# uint16_t rnd_xorshift_32() {
#   static uint16_t x=1,y=1;
#   uint16_t t=(x^(x<<5));
#   x=y;
#   return y=(y^(y>>1))^(t^(t>>3));
# }

import pygame
from pygame import gfxdraw
import sys

pygame.init()
screen = pygame.display.set_mode((1280, 960))

global a, b
a = 4122
b = 94


def rand(fac):
    global a, b
    t = (a^(a<<5))
    a = b
    b = (b^(b>>1))^(t^(t>>3))
    b = b & 0xFFFF
    return (b % fac)

# def rand(x, y):
#     t = (x^(x<<5))
#     x = y
#     y=(y^(y>>1))^(t^(t>>3))
#     y = y & 0xFFFF
#     return x, y


def plot(x, y, r, g, b):
    pz = 4
    for j in range(pz):
        for i in range(pz):
            gfxdraw.pixel(screen, x*pz+i, y*pz+j, (r, g, b))


for i in range(10000):
    x = rand(160)
    y = rand(120)
    r = rand(256)
    g = rand(256)
    b = rand(256)
    # print(i, x, y, r, g, b)
    plot(x, y, r, g, b)
    if i % 100 == 0:
        pygame.display.update()

while True:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            sys.exit()