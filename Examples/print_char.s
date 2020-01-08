# Print char to VGA
#
    LCA 'A'
    STO A char
    JSR pchar
    JMP $0000
    
pchar:
    LDA char
    LCB $20   # space ' '
    JLT cntrl # is control character
    STO A-B chr

# Calculate start of character bitmap
    LDA chr   # index  = chr*7
    LDB $07
    STO A*B indx+1
    LDA A*BHI
    LHB ascii
    STO A+B indx # store character bitmap start in indx

# Calculate x,y coords for top left pixel of character
    LDA xpos
    LCB $06
    STO A*B xcoord
    LDA ypos
    LCB $07
    STO A*B ycoord

    LCA $07
    STO A line_count

# plot 6 pixels of character bitmap of each line
1:
    LCA $06
    STO A bit_count
    LIA indx
    STO A bmp
2: # loop through bits
    LDA bmp
    JAN 3f
    LDA bakg
    JMP 4f
3:
    LDA forg
4:
    SIA coord  # plot bit
    LDA bmp     # roll bit map left one
    LCB $01
    STO AROLB bmp # store it
    LDB bit_count   # dec bitcount
    LDB B-1
    STO B bit_count
    JAZ 5f
    LDA xcoord  # inc x coord
    STO A+1 xcoord
    JMP 2b      # loop to next bit in bitmap
5:
    # loop to next line in bit map
    LDA indx
    STO A+1 indx
    LDA xcoord  # restore x coord (ie go back 6 pixels)
    LCB $06
    STO A-B xcoord
    LDA ycoord # increment y coord
    STO A+1 ycoord
    LDA line_count
    LDA A-1
    STO A line_count
    JAZ 6f
    JMP 1b
6:
    RTS pchar

cntrl:
    RTS pchar

    PAG
char: HEX "21"
xpos: HEX "00"
ypos: HEX "00"
coord:
ycoord: HEX "00"
xcoord: HEX "00"
chr: HEX "00 00"
indx: HEX "00 00"
bakg: HEX "03"
forg: HEX "3C"
bit_count: HEX "00"
line_count: HEX "00"
bmp: HEX "00"

# Ascii chars 32-96
    PAG
ascii:
	PAG
	HEX "00 00 00 00 00 00 00 "
	HEX "10 10 10 10 10 00 10 "
	HEX "24 24 48 00 00 00 00 "
	HEX "28 28 7c 28 7c 28 28 "
	HEX "10 3c 50 38 14 78 10 "
	HEX "64 64 08 10 20 4c 4c "
	HEX "10 28 28 28 54 48 34 "
	HEX "10 10 20 00 00 00 00 "
	PAG
	HEX "08 10 20 20 20 10 08 "
	HEX "20 10 08 08 08 10 20 "
	HEX "10 54 38 7c 38 54 10 "
	HEX "00 10 10 7c 10 10 00 "
	HEX "00 00 00 00 10 10 20 "
	HEX "00 00 00 7c 00 00 00 "
	HEX "00 00 00 00 00 30 30 "
	HEX "04 04 08 10 20 40 40 "
	PAG
	HEX "38 44 4c 54 64 44 38 "
	HEX "10 30 10 10 10 10 38 "
	HEX "38 44 04 08 10 20 7c "
	HEX "38 44 04 18 04 44 38 "
	HEX "08 18 28 48 7c 08 08 "
	HEX "7c 40 78 04 04 44 38 "
	HEX "18 20 40 78 44 44 38 "
	HEX "7c 04 08 10 20 20 20 "
	PAG
	HEX "38 44 44 38 44 44 38 "
	HEX "38 44 44 3c 04 08 30 "
	HEX "00 30 30 00 30 30 00 "
	HEX "00 30 30 00 30 10 20 "
	HEX "08 10 20 40 20 10 08 "
	HEX "00 00 7c 00 7c 00 00 "
	HEX "20 10 08 04 08 10 20 "
	HEX "38 44 04 08 10 00 10 "
	PAG
	HEX "38 44 5c 54 5c 40 3c "
	HEX "10 28 44 44 7c 44 44 "
	HEX "78 44 44 78 44 44 78 "
	HEX "38 44 40 40 40 44 38 "
	HEX "78 24 24 24 24 24 78 "
	HEX "7c 40 40 70 40 40 7c "
	HEX "7c 40 40 7c 40 40 40 "
	HEX "38 44 40 40 4c 44 3c "
	PAG
	HEX "44 44 44 7c 44 44 44 "
	HEX "38 10 10 10 10 10 38 "
	HEX "7c 08 08 08 08 48 30 "
	HEX "44 48 50 60 50 48 44 "
	HEX "40 40 40 40 40 40 7c "
	HEX "44 6c 54 44 44 44 44 "
	HEX "44 44 64 54 4c 44 44 "
	HEX "38 44 44 44 44 44 38 "
	PAG
	HEX "78 44 44 78 40 40 40 "
	HEX "38 44 44 44 54 48 34 "
	HEX "78 44 44 78 50 48 44 "
	HEX "38 44 40 38 04 44 38 "
	HEX "7c 10 10 10 10 10 10 "
	HEX "44 44 44 44 44 44 38 "
	HEX "44 44 44 44 44 28 10 "
	HEX "44 44 44 54 54 6c 44 "
	PAG
	HEX "44 44 28 10 28 44 44 "
	HEX "44 44 28 10 10 10 10 "
	HEX "7c 04 08 10 20 40 7c "
	HEX "38 20 20 20 20 20 38 "
	HEX "40 40 20 10 08 04 04 "
	HEX "38 08 08 08 08 08 38 "
	HEX "10 28 44 00 00 00 00 "
	HEX "00 00 00 00 00 00 7c "
	PAG
	HEX "10 10 08 00 00 00 00 "
	HEX "00 38 04 34 4c 4c 34 "
	HEX "40 40 40 70 48 48 70 "
	HEX "00 00 00 38 40 40 38 "
	HEX "04 04 04 1c 24 24 1c "
	HEX "00 00 38 44 7c 40 3c "
	HEX "18 24 20 70 20 20 20 "
	HEX "38 44 4c 34 04 04 38 "
	PAG
	HEX "40 40 40 58 64 44 44 "
	HEX "00 10 00 30 10 10 38 "
	HEX "08 00 18 08 08 48 30 "
	HEX "40 40 48 50 60 50 48 "
	HEX "30 10 10 10 10 10 10 "
	HEX "00 00 28 54 54 44 44 "
	HEX "00 00 58 64 44 44 44 "
	HEX "00 00 38 44 44 44 38 "
	PAG
	HEX "00 70 48 48 70 40 40 "
	HEX "00 1c 24 24 1c 04 04 "
	HEX "00 00 58 64 40 40 40 "
	HEX "00 00 3c 40 38 04 78 "
	HEX "20 20 70 20 20 24 18 "
	HEX "00 00 44 44 44 4c 34 "
	HEX "00 00 44 44 44 28 10 "
	HEX "00 00 44 44 54 54 28 "
	PAG
	HEX "00 00 44 28 10 28 44 "
	HEX "00 44 44 3c 04 44 38 "
	HEX "00 00 7c 08 10 20 7c "
	HEX "18 20 20 40 20 20 18 "
	HEX "10 10 10 00 10 10 10 "
	HEX "30 08 08 04 08 08 30 "
	HEX "20 54 08 00 00 00 00 "
	HEX "7c 7c 7c 7c 7c 7c 7c "
