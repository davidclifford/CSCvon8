#
# VGA PIC converter
#

from numpy import uint8
from PIL import Image

image = Image.open('gf4.png')
pixels = image.load()

pic_file = open('gf4.bin', 'wb')

for y in range(512):
    for x in range(256):
        try:
            pix = pixels[x, y]
            red = pix[0] >> 5
            grn = pix[1] >> 5
            blu = pix[2] >> 6
            colour = red | grn << 3 | blu << 6
            print(x, y, red, grn, blu, colour)
            pic_file.write(uint8(colour))
        except IndexError:
            pic_file.write(uint8(0))

pic_file.close()

