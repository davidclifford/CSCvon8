#
# Output
#
from numpy import uint8

control: uint8 = [0 for f in range(1 << 15)]

for x in range(2):
    for y in range(2):
        # 'Normal' pixels
        for p in range(64):
            address = p | (y << 9) | (x << 8)
            control[address] = p
            control[address+64] = 64 - p
        # 'Highres' pixels
        for r in range(2):
            for g in range(2):
                for b in range(2):
                    for place in range(16):
                        address = (1<<7) | (r<<6) | (g<<5) | (b<<4) | (place) | (y<<9) | (x<<8)
                        if place & (1<< (y<<1 | x)):
                            control[address] = ((r*3)<<4) | ((g*3)<<2) | (b*3)
                        else:
                            control[address] = 0

control_bytes = bytearray(control)
control_bin = open("pixel_control.bin", "wb")
control_bin.write(control_bytes)
control_bin.close()
