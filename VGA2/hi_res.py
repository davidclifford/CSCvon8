#
# VGA Test PIC generator
#

from numpy import uint8
import random

pic: uint8 = [0 for f in range(1 << 15)]

for y in range(0, 128):
    for x in range(0, 256):
        addr = y << 8 | x
        if x < 160 and y < 120:
            pic[addr] = (x+y) % 256
            if (y%2) == 0:
                pic[addr] = x & 0x3F


pic_bytes = bytearray(pic)
pic_bin = open("hires.bin", "wb")
pic_bin.write(pic_bytes)
pic_bin.close()
