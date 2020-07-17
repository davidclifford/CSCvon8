#
# Pixel Control ROM for transforming pixel byte to VGA pixels
#
#   When MSB is 0 pixel is 4x4 with 64 colours
#       00rrggbb
#   When MSB is 1 then lower 7-bits are ascii-char
#
#
from numpy import uint8

font_file = open("spec-font.bin", "rb")
font = list(font_file.read())

control: uint8 = [0 for f in range(1 << 15)]

for pix in range(256):
    if pix >= 160: print(pix-128)
    for y2 in range(2):
        for y1 in range(2):
            for y0 in range(2):
                for x0 in range(2):
                    for clk in range(2):
                        for clk2 in range(2):
                            address = pix | (clk << 8) | (y1 << 9) | (clk2 << 10) | (y0 << 11) | (x0 << 12) | (y2 << 13)
                            if pix < 128:
                                control[address] = pix & 0x3f  # lower 6 bits
                            else:
                                char = pix & 0x7f # lower 7 bits - 32
                                control[address] = 0  # set pixel to black
                                if char >= 32:
                                    row = y0 | (y1<<1) | (y2<<2)
                                    byte = font[(char-32)*8 + row]
                                    column = clk2 | (clk<<1) | (x0<<2)
                                    # print(row, column, end=' | ')
                                    on = (byte<<column) & 0x80
                                    if on != 0:
                                        control[address] = 0x3f  # white
                                        print('#', end='')
                                    else:
                                        print('.', end='')
                                        fred = 0
                if pix >= 160: print()

control_bytes = bytearray(control)
control_bin = open("pixel_control2.bin", "wb")
control_bin.write(control_bytes)
control_bin.close()
