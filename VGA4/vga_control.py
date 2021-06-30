#
# VGA4 Control ROM generator
# 200 x 150 (800 x 600 @ 56Hz)
#

from numpy import uint8

Hsync = uint8(1) << 0
Vsync = uint8(1) << 1
Blank = uint8(1) << 2
Creset = uint8(1) << 3
B = uint8(1) << 4
G = uint8(1) << 5
R = uint8(1) << 6

control: uint8 = [0 for f in range(1 << 17)]

for a in range(0, 80000):
    # if a < 80000:
    control[a] |= Creset
    x = a % 128
    y = a // 128

    if 100 + 3 <= x < 100 + 3 + 9:
        control[a] |= Hsync
    if 600 + 1 <= y < 600 + 1 + 2:
        control[a] |= Vsync
    if x >= 100 or y >= 600:
        control[a] |= Blank
    if x < 100 and y < 600:
        if x & 4 == 0:
            control[a] |= R
        if x & 2 == 0:
            control[a] |= G
        if x & 1 == 0:
            control[a] |= B

control_bytes = bytearray(control)
control_bin = open("vga_control.bin", "wb")
control_bin.write(control_bytes)
control_bin.close()
