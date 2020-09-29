# https://b2d-f9r.blogspot.com/2010/08/16-bit-xorshift-rng-now-with-more.html
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
a = 0x0000
b = 0x0001


def rand(fac):
    global a, b
    t = (a^(a<<5))
    t = t & 0xFFFF
    a = b
    b = (b^(b>>1))^(t^(t>>3))
    b = b & 0xFFFF
    # print(hex(b))
    return (b % fac)


def plot(x, y, r, g, b):
    pz = 8
    for j in range(pz):
        for i in range(pz):
            gfxdraw.pixel(screen, x*pz+i, y*pz+j, (r, g, b))


k = 0
while True:
    x = rand(160)
    y = rand(120)
    r = rand(256)
    g = rand(256)
    b = rand(256)
    # print(i, x, y, r, g, b)
    plot(x, y, r, g, b)
    k += 1
    if k > 1000:
        pygame.display.update()
        k = 0

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            sys.exit()
