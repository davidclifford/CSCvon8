# VGA card for CSCvon8

A 64 colour (6-bit tru-color), 160x120 pixel add-on VGA card for the CSCvon8
or any other CPU that can output 8 bits for the X co-ord, 7-bits for
the Y co-ord and 8 bits for pixel colour and a write signal.
e.g. an Arduino Mega 2560.

There are 3 input registers, called X, Y and D. They hold the X, Y 
co-ordinates and pixel colour respectively.

For the CSCvon8 the 15 bits for the X/Y co-ords come from the address
bus and the pixel colour from 8 bits of the data bus. A wire for the
memory write signal is run from the CSCvon8 to the VGA card.

If you write byte to the ROM address space (0x000 - 0x7fff) of the CSCvon8 this will
be written to the VGA internal memory. Therefore store instructions (STO)
can be used to display pixels as if it was a memory mapped device.
As the ROM is not usually written to and has a 32kb address space it can
be used for the VGA memory memory space.

To read back from the video memory I have updated the CSCvon8 microcode
to use a previously unused control line as a video read signal. I have
created some new opcodes to use this control line and read back data from the
VGA memory.

## How it works

When the pixel clock is low the RAM is read with the address bus set
to the XY co-ords from the counters using two 8-bit bus transceivers.
The pixel data and the vertical & horizontal syncs are latched into a register and
this will output the required VGA signal through some resistor/diode
2 bit DACs giving 4 levels of red, green and blue making 64 possible colours.

When the pixel clock is high, the RAM is written to from the D register
with the address set to the X & Y registers. As the VGA signal is
latched when the pixel clock is high, this will not affect the
VGA signal. The registers have 3 state output and will only output when
the bus transceivers do not. As the RAM is written to every pixel clock,
as long as the X,Y & D registers do not change the same pixel value
will be written to the same address all the time but this does not
matter. I have used 15ns RAM to be able to cope with the address bus
changing rapidly. 

The data sent to the X,Y & D registers is also sent
to another 32k RAM chip on the VGA board so that it can be read back
by the CSCvon8. As long as the readable RAM and the video RAM have the same contents
it doesn't matter that they are physically different chips, they contain
the same data. It was done this way because I couldn't work out an easy way to
read the video RAM directly without adding a lot of extra logic chips.

## Operation

To output a pixel to the screen, write the X & Y co-ords to the X & Y
registers and the pixel data to the D register, and latch the data
with a write signal from the CPU or Arduino. As long as the X,Y & D
data arrives as the same time with a write signal and at a slower
frequency than it can be copied by the VGA card to the Video RAM,
no pixels will be lost. Only if you send data faster than 6.3 MHz would
that happen and the CSCvon8 or Arduino MEGA 2560 are not that fast
(though a RPi would be). Synchronising the CPU clock with the VGA card
clock is better as glitches sometimes happen if the clocks don't
match, e.g. 16MHz for Arduino, 6.3MHz for VGA Card.

## Pixel data

Originally the VGA card was designed to have 64 colours using 6 bits (00rrggbb).
The top 2 bits were unused and normally set to zeros. Later I realized that
I could exploit the 2 most significant bits for a new pixel mode. Instead of
having a large pixel in 64 colours I could divide the pixel into 4 smaller sub-pixels
in a 2x2 square but only be able to have 7 colours (+black) with a black background.

When the MSD of the pixel is 1 then the next 3 bits is interpreted as the foreground colour
and the last 4 bits tells it to use either the foreground colour or black as the sub-pixel
colour. Format is: 1rgbabcd where rgb is the red, green & blue components of the colour, abcd is
which sub-pixel is on or off in this pattern. a=bottom left, b=bottom right, c=top left, d=top right.

This can be used for text as you can now have 53 by 30 characters, with a 6x8 font, on the screen.
The disadvantage is that you can only use 7 colours (red, green, blue, cyan, magenta and yellow) and
the background pixel is always black. This is a compromise to keep the complexity of the circuit low. 

## Use with the CSCvon8

Wire the address bus to the VGA card so that the X register has the
lower 8-bits and the Y register has the higher 8-bits (only 32k address
space is used), and wire the data bus to the D register.

Connect a wire from a point where the MEMload line is accessible to the
store input for the VGA registers. Connect a ground wire between the
boards and use the VGA 6.3MHz clock, if possible,(or the 3.147MHz clock)
as the CSCvon8 clock (remove its crystal).

To output a pixel write to the bottom 32k address space (where the ROM
is located) so that the X co-ord is the bottom 8-bits and the Y co-ord
is the next 7-bits, and the 16th MSB low, with the pixel data in
64 colours (00rrggbb in binary) or 'hi-res' text (1rgbabcd) where rgb 
is one of 7 colours and abcd is which pixel is on or off.

e.g:

To output a red pixel to co-ords 0,0
```
LCA $30
STO A,$0000
```
To output a green pixel to co-ords 4,8
```
LCA $0C
STO A,$0804
```
Self modifying code and/or indexed instructions could be used.
Indexed instructions (SIA and SIB) are slow (9 clock cycles) and destroy
the contents of A and B regs but can be used in code stored in the ROM.
STO instructions are faster (5 cycles) and  more versatile and can be
indexed (e.g. STO $0800,B) but need the overhead of the address changed
by self modifying the code (another STO, @ 5 cycles) and need to be,
obviously, stored in RAM, so the speed difference not as much as first
seems.

## New CSCvon8 opcodes 
```
LVA: Load A from absolute video location $HHLL
LVB: Load B from absolute video location $HHLL

LVA_,B: Load A with Video memory indexed by B
LVB_,B: Load B with Video memory indexed by B

LAI_,B: Load A indirect, high byte from variable and indexed by B
LBI_,B: Load B indirect, high byte from variable and indexed by B

STI_A_,B: Store A indirect, high byte from variable and indexed by B
STI_B_,B: Store B indirect, high byte from variable and indexed by B
STI_0_,B: Store 0 indirect, high byte from variable and indexed by B

VAI_,B: Load A indirect from video mem, high byte from variable and indexed by B
VBI_,B: Load B indirect from video mem, high byte from variable and indexed by B

CL4_A_,B: Clear 4 bytes starting at address AB, B+=4
CLR_A_,B: Clear byte at address AB
```
