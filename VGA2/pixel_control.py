#
# Pixel Control ROM for transforming pixel byte to VGA pixels
#
#   When MSB is 0 pixel is 4x4 with 64 colours
#       00rrggbb
#   When MSB is 1 pixel is 4 sub-pixels in square in 8 colours
#       1rgbABCD
#   CD
#   AB
#
from numpy import uint8

control: uint8 = [0 for f in range(1 << 17)]

for back in range(64):
    for x in range(2):
        for y in range(2):
            # 'Normal' pixels
            for p in range(64):
                address = p | (y << 9) | (x << 8) | (back<<10)
                # Normal
                control[address] = p
                # Background, same as normal + control line for background colour register
                if x&1:  # x = 1, set control line low
                    control[address+64] = p
                else:    # x = 0, set control line high
                    control[address+64] = p | (1<<6)
            # 'Highres' pixels
            for r in range(2):
                for g in range(2):
                    for b in range(2):
                        for place in range(16):
                            address = (1<<7) | (r<<6) | (g<<5) | (b<<4) | (place) | (y<<9) | (x<<8) | (back<<10)
                            if place & (1<< ((y<<1) | x)):
#                            if place & (1 << ((y << 1) + x + 1)):
                                if r+g+b == 0:
                                    control[address] = 0x34  # Orange is the new Black
                                else:
                                    control[address] = ((r*3)<<4) | ((g*3)<<2) | (b*3)
                            else:
                                control[address] = back   # Background colour

control_bytes = bytearray(control)
control_bin = open("pixel_control.bin", "wb")
control_bin.write(control_bytes)
control_bin.close()
