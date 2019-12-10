# VGA card for CSCvon8

An add-on VGA card for the CSCvon8 or any other CPU that can output 15
bits for the X & Y coords and 8 bits for pixel colour plus a write
signal e.g. an Arduino Mega 2560.

For the CSCvon8 the 15 bits for the XY coords come from the address bus
and the pixel colour from 6 bits of the data bus and I will have to
solder a wire for the memory write signal.

It works by writing a byte to the ROM address space of the CSCvon8
but this will instead be written to the VGA internal memory, so that
STO instructions can be used to display pixels as if it was a memory
mapped device. As the ROM is not usually written to and has a 32kb
address space it can be used for the VGA memory memory space.
The disadvantage is that it wont be possible to read from the video
memory as it will return the contents of the ROM instead.

## How it works




