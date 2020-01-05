# VGA card for CSCvon8

A 64 colour, 160x120 pixel add-on VGA card for the CSCvon8 or any other
CPU that can output 15 bits for the X & Y co-ords and 8 bits for pixel
colour plus a write signal e.g. an Arduino Mega 2560.

For the CSCvon8 the 15 bits for the XY co-ords come from the address bus
and the pixel colour from 6 bits of the data bus. A wire from the memory
write signal will have to soldered to the CSCvon8 to the VGA card.

It works by writing a byte to the ROM address space of the CSCvon8
but this will instead be written to the VGA internal memory, so that
STO instructions can be used to display pixels as if it was a memory
mapped device. As the ROM is not usually written to and has a 32kb
address space it can be used for the VGA memory memory space.
The disadvantage is that it won't be possible to read from the video
memory as it will return the contents of the ROM instead (and would
make the VGA card far more complex).

## How it works

When the pixel clock is high the RAM is read with the address bus set
to the XY co-ords from the counters using 2 8-bit bus transceivers.
The pixel data and the V & H syncs are latched into a register and
this will output the required VGA signal through some resistor/diode
2 bit DACs.

When the pixel clock is low, the RAM is written to from the D register
with the address set to the X & Y registers. As the VGA signal is
latched when the pixel clock is high, this will not affect the
VGA signal. The registers have 3 state output and will only output when
the bus transceivers do not. As the RAM is written to every pixel clock
as long as the X,Y & D registers do not change the same pixel value
will be written to the same address all the time but this does not
matter. I have used 25ns RAM to be able to cope with the address bus
changing rapidly.

## Operation

To output a pixel to the screen, write the X & Y co-ords to the X & Y
registers and the pixel data to the D register, and store the data
with a write signal from the CPU or Arduino. As long as the X,Y & D
data arrives as the same time with a write signal and at a slower
frequency than it can be copied to the RAM, no pixels will be lost.
Only if you send data faster than 6.3 MHz would that happen and
the CSCvon8 or Arduino MEGA 2560 are not that fast (though a RPi would
be).

## Use with the CSCvon8

Wire the address bus to the VGA card so that the X register has the
lower 8-bits and the Y register has the higher 8-bits (only 32k address
space is used), and wire the data bus to the D register.

Solder a wire from a point where the MEMload line is accessible to the
store input for the VGA registers. Connect a ground wire between the
boards and use the VGA 6.3MHz clock, if possible,(or the 3.147MHz clock)
as the CSSvon8 clock (remove its crystal).

To output a pixel write to the bottom 32k address space (where the ROM
is located) so that the X co-ord is the bottom 8-bits and the Y co-ord
is the next 7-bits (the 16th bit is not used) with the pixel data in
64 colours (00rrggbb in binary)

e.g:

To output a red pixel to co-ords 0,0

LCA $30
STO A,$0000

To output a green pixel to co-ords 4,8

LCA $0C
STO A,$0804

Self modifying code and/or indexed instructions could be used.