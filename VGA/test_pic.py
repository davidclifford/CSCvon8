#
# VGA Test PIC generator
#

from numpy import uint8
import random

pic: uint8 = [0 for f in range(1 << 17)]

for y in range(0, 512):
    for x in range(0, 256):
        addr = y << 8 | x
        if x < 160 and y < 120:
            pic[addr] = random.randint(0, 7)


pic_bytes = bytearray(pic)
pic_bin = open("pic.bin", "wb")
pic_bin.write(pic_bytes)
pic_bin.close()
