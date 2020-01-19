#
# VGA Control ROM generator
#

from numpy import uint8

Yreset = uint8(1) << 0
Xreset = uint8(1) << 1
Ynext = uint8(1) << 2
Hsync  = uint8(1) << 3
Vsync  = uint8(1) << 4
PICout = uint8(1) << 5

control: uint8 = [0 for f in range(1 << 17)]

for y in range(0, 1024):
    for x in range(0, 128):
        addr = y << 7 | x
        if y < 525:
            control[addr] |= Yreset
        if x < 100:
            control[addr] |= Xreset
        if x == 100:
            control[addr] |= Ynext
        if x < 82 or x > 94:
            control[addr] |= Hsync
        if y < 490 or y > 492:
            control[addr] |= Vsync
        if x >= 80 or y >= 480:
            control[addr] |= PICout
        if x > 100 or y > 525:
            control[addr] = 0xff

control_bytes = bytearray(control)
control_bin = open("control.bin", "wb")
control_bin.write(control_bytes)
control_bin.close()
