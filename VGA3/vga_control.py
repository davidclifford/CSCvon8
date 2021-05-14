#
# VGA2 Control ROM generator
# Version 2
#

from numpy import uint8

Yreset = uint8(1) << 0
Xreset = uint8(1) << 1
Ynext = uint8(1) << 2
Hsync  = uint8(1) << 3
Vsync  = uint8(1) << 4
PICout = uint8(1) << 5
TESTout = uint8(1) << 6
PIXout = uint8(1) << 7

control: uint8 = [0 for f in range(1 << 17)]

for y in range(0, 2048):
    for x in range(0, 64):
        addr = y << 6 | x
        if y < 525 or x < 50:
            control[addr] |= Yreset
        if x < 50:
            control[addr] |= Xreset
        if x == 49:
            control[addr] |= Ynext

        if x < 41 or x > 46:
            control[addr] |= Hsync
        if y < 490 or y > 491:
                control[addr] |= Vsync
        if x > 39 or y > 480:
            control[addr] |= PICout
        if x < 40 and y < 480:
            control[addr] |= TESTout
        if x < 40 and y < 480 and ((x) % 2 == 0):
            control[addr] |= PIXout
        # if x > 50 or y > 525:
        #     control[addr] = 0x0

control_bytes = bytearray(control)
control_bin = open("control.bin", "wb")
control_bin.write(control_bytes)
control_bin.close()
