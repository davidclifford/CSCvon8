# Rom based simple breadboard VGA

Resolution 400 x 600, 12-bit colour depth, 4096 colours 4 bits per channel RGB

# Convert picture

* Resize a picture to 400 x 600, 24 bpp in Pixelformer and export as PNG
* Run pic_converter.py changing variable filename to base name of PNG file in the code
<br> This will produce file \<filename\>.bin
* Use 'split' command in unix to split it into 2 files of max 512k each 
<br> e.g.  split finch.bin -b 512k finch -d
* Load each file produced in MiniPro 
* Set IC to AM27C4096 DIP40
* Use adapter on the MiniPro to burn the two files to 0 and 1 on adapter board

# Using ROM

Use 18 MHz Crystal oscillator, 3 74hc590 counters, a 27c322 ROM, a ladder resistor DAC and a lot of wires
and decoupling caps on a breadboard or two.
Place ROM on breadboard, connect VGA monitor & power-up.
You should see lovely picture in 12-bit true colour.

Check the timings:
* Screen refresh: 56Hz
* Vertical refresh: 35.15625 khz

Positive sync

Horizontal 400, 12, 36, 64, 512

Vertical 600, 1, 2, 22, 625

 
