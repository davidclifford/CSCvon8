# VGA card for CSCvon8

# Description

* Resolution: 160 by 120 pixels
* Colours: 64 (6-bit true colour)
* 8 colour double resolution pixel mode giving effective 320 by 240 resolution suitable for text

# Design

* Designed to be simple and easy to construct
* Uses a small number of chips
* Only uses 74 logic family chips plus ROMS and RAMS
* Easy to interface to a CPU, no waiting needed to read or write data to or from the display
* Bit mapped and memory mapped
* Fits on 4 x 830 breadboards
* Supplies 3.15 mhz clock for CPU to help sychronize reading and writing

When using a display with an 8-bit CPU some compromises have to be made.
The more colours and/or the higher resolution you use, the more memory you have to use and
the higher the clock signal needs to be. The memory footprint has to fit in a 64kb space
and still leave memory for programs.
The more memory it uses, the more pixels you have to move around which impacts the speed
of the display. Also it is also easier to implement if the resolution is a integer fraction of a VGA mode
like 640 by 480 or 800 by 600 e.g. 160 by 120 is 640/4 by 480/4.

I followed the Gigatron resolution as it gives a good enough resolution and not too difficult to implement
with 74 series logic chips. However when the first version of my display was finished, I realised that
the text is vey chunky and takes a lot of space. I thought I could improve on this without adding very
much work and did it with only a few more chips. See bellow for an explanation of the 'text' pixel mode.

# Interface

There are 3 input registers, called X, Y and P. They hold the X, Y co-ordinates  
and colour of the pixel respectively.

For the CSCvon8 the 15 bits for the X/Y co-ordinates come from the address
bus and the pixel colour from 8 bits of the data bus. A wire for the
memory write signal is run from the CSCvon8 to the display.

If you write byte to the ROM address space (0x000 - 0x7fff) of the CSCvon8 this will
be written not to the ROM but to the display's internal memory. 
Therefore store instructions (STO) can be used to display pixels as if it was a memory mapped device.
As the ROM is not usually written to and has a 32kb address space it can
be used for the display memory memory space.

To read back from the video memory I have updated the CSCvon8 microcode
to use a previously unused control line as a video read signal. I have
created some new opcodes to use this control line and read back data from the
VGA memory.

## How it works

A 25.175 Mhz clock is divided to produce both a 12.6 Mhz and 6.3 mhz clock.
The 6.3 Mhz signal is used to drive counters for the X and Y co-ordinates and
they fed into a control ROM to produce the horizontal, vertical, blanking, X reset and Y reset signals. 

When the clock is low the RAM is read with the address bus set
to the X/Y co-ords from the counters using two 8-bit bus transceivers.
The pixel data and the vertical & horizontal syncs are latched into a register and
this will output the required VGA signal through some resistor/diode
2 bit DACs giving 4 levels of red, green and blue making 64 possible colours.

When the pixel clock is high, the RAM is written to from the P register
with the address set to the X & Y registers. As the VGA signal is
latched when the pixel clock is high, this will not affect the
VGA signal. The registers have 3 state output and will only output when
the bus transceivers do not. As the RAM is written to every pixel clock,
as long as the X,Y & D registers do not change the same pixel value
will be written to the same address all the time but this does not
matter. I have used 15ns RAM to be able to cope with the address bus
changing rapidly. 

The data sent to the X,Y & P registers is also sent
to another 32k RAM chip on the VGA board so that it can be read back
by the CSCvon8. As long as the readable RAM and the video RAM have the same contents
it doesn't matter that they are physically different chips, they contain
the same data. I did it this way because I couldn't work out an easy way to
read the video RAM directly without adding a lot of extra logic chips.

## Operation

To output a pixel to the screen, write the X & Y co-ords to the X & Y
registers and the pixel data to the P register, and latch the data
with a write signal from the CPU or Arduino. As long as the X,Y & P
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
I could exploit the 2 most significant bits for new pixel modes. Instead of
having a large pixel in 64 colours I could divide the pixel into 4 smaller sub-pixels
in a 2x2 square but only be able to have 8 colours with a programmable background.

When the MSD of the pixel is 1 then the next 3 bits is interpreted as the foreground colour
and the last 4 bits tells it to use either the foreground colour or background colour as the sub-pixel
colour. Format is: 1rgbABCD where rgb is the red, green & blue components of the colour, ABCD is
which sub-pixel is on or off in this pattern. A=bottom left, B=bottom right, C=top left, D=top right.

This can be used for text as you can now have 53 by 30 characters, with a 6x8 font, on the screen.
The disadvantage is that you can only use 8 colours (red, green, blue, cyan, magenta, yellow, white and orange) and
the background has to be set by another pixel mode. This is a compromise to keep the complexity of the circuit low.

## Background colour 

Format: 01rrggbb

This a pixel mode to change the background colour of the higher resolution pixels used for text.
When a background pixel is set it is shown on the display in that colour and evey text pixel after
that will use that colour as its background colour. 

When the pixel's top 2 bits are set to 01 then the lower 6 bits are interpreted as a 64 colour 
pixel just like a normal pixel and shown on the display. However it also stores that colour in the
background colour register, so when a text mode pixel is displayed, it uses that colour stored as
its background colour. The register is NOT reset at the start of a frame, so setting the background 
colour in the middle of the screen will also be used as a background colour from the start of the screen.
To change the background colour it will have to use a whole pixel so there will always be a pixel colour
change BEFORE the background colour. This is a compromise to keep things simple.  

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
is the next 7-bits, and the 16th bit low, with the pixel data in
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
