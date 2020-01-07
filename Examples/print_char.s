# Print char to VGA
#
pchar:
    LDA char
    LCB $20   # space ' '
    JLT cntrl # is control character
    STO A-B chr

1: # Calculate start of character bitmap
    LDA chr   # index  = chr*7
    LDB $07
    STO A*B indx+1
    LDA chr
    LDB $07
    LDA A*BHI
    LBH ascii
    STO A+B indx

2: # Calculate x,y coords for top left pixel of character
    LDA xpos
    LCB $06
    STO A*B xcoord
    LDA ypos
    LDC $07
    STO A*B ycoord

3: # plot 6 pixels of character bitmap
    LCA $06
    STO A count
4:
    LIA indx
    LCB $04
    LDB A*BHI
    JAZ background
    LDA forg
    SIA ycoord
    JMP 5f
background:
    LDA bakg
    SIA ycoord
5:
    LDB count
    LDB B-1
    STO B count
    JPZ 6f
    JMP 4b
6:
    LDA xcoord
    LCB

    JMP $0000

cntrl:
    RTS pchar

    PAG
char: HEX "21"
xpos: HEX "00"
ypos: HEX "00"
ycoord: HEX "00"
xcoord: HEX "00"
chr: HEX "00 00"
indx: HEX "00 00"
bakg: HEX "03"
forg: HEX "3C"
count: HEX "00"

# Ascii chars 32-96
    PAG
ascii:
	HEX "00 00 00 00 00 00 00 "
	HEX "04 04 04 04 04 00 04 "
	HEX "09 09 12 00 00 00 00 "
	HEX "0a 0a 1f 0a 1f 0a 0a "
	HEX "04 0f 14 0e 05 1e 04 "
	HEX "19 19 02 04 08 13 13 "
	HEX "04 0a 0a 0a 15 12 0d "
	HEX "04 04 08 00 00 00 00 "
	PAG
	HEX "02 04 08 08 08 04 02 "
	HEX "08 04 02 02 02 04 08 "
	HEX "04 15 0e 1f 0e 15 04 "
	HEX "00 04 04 1f 04 04 00 "
	HEX "00 00 00 00 04 04 08 "
	HEX "00 00 00 1f 00 00 00 "
	HEX "00 00 00 00 00 0c 0c "
	HEX "01 01 02 04 08 10 10 "
	PAG
	HEX "0e 11 13 15 19 11 0e "
	HEX "04 0c 04 04 04 04 0e "
	HEX "0e 11 01 02 04 08 1f "
	HEX "0e 11 01 06 01 11 0e "
	HEX "02 06 0a 12 1f 02 02 "
	HEX "1f 10 1e 01 01 11 0e "
	HEX "06 08 10 1e 11 11 0e "
	HEX "1f 01 02 04 08 08 08 "
	PAG
	HEX "0e 11 11 0e 11 11 0e "
	HEX "0e 11 11 0f 01 02 0c "
	HEX "00 0c 0c 00 0c 0c 00 "
	HEX "00 0c 0c 00 0c 04 08 "
	HEX "02 04 08 10 08 04 02 "
	HEX "00 00 1f 00 1f 00 00 "
	HEX "08 04 02 01 02 04 08 "
	HEX "0e 11 01 02 04 00 04 "
	PAG
	HEX "0e 11 17 15 17 10 0f "
	HEX "04 0a 11 11 1f 11 11 "
	HEX "1e 11 11 1e 11 11 1e "
	HEX "0e 11 10 10 10 11 0e "
	HEX "1e 09 09 09 09 09 1e "
	HEX "1f 10 10 1c 10 10 1f "
	HEX "1f 10 10 1f 10 10 10 "
	HEX "0e 11 10 10 13 11 0f "
	PAG
	HEX "11 11 11 1f 11 11 11 "
	HEX "0e 04 04 04 04 04 0e "
	HEX "1f 02 02 02 02 12 0c "
	HEX "11 12 14 18 14 12 11 "
	HEX "10 10 10 10 10 10 1f "
	HEX "11 1b 15 11 11 11 11 "
	HEX "11 11 19 15 13 11 11 "
	HEX "0e 11 11 11 11 11 0e "
	PAG
	HEX "1e 11 11 1e 10 10 10 "
	HEX "0e 11 11 11 15 12 0d "
	HEX "1e 11 11 1e 14 12 11 "
	HEX "0e 11 10 0e 01 11 0e "
	HEX "1f 04 04 04 04 04 04 "
	HEX "11 11 11 11 11 11 0e "
	HEX "11 11 11 11 11 0a 04 "
	HEX "11 11 11 15 15 1b 11 "
	PAG
	HEX "11 11 0a 04 0a 11 11 "
	HEX "11 11 0a 04 04 04 04 "
	HEX "1f 01 02 04 08 10 1f "
	HEX "0e 08 08 08 08 08 0e "
	HEX "10 10 08 04 02 01 01 "
	HEX "0e 02 02 02 02 02 0e "
	HEX "04 0a 11 00 00 00 00 "
	HEX "00 00 00 00 00 00 1f "
	PAG
	HEX "04 04 02 00 00 00 00 "
	HEX "00 0e 01 0d 13 13 0d "
	HEX "10 10 10 1c 12 12 1c "
	HEX "00 00 00 0e 10 10 0e "
	HEX "01 01 01 07 09 09 07 "
	HEX "00 00 0e 11 1f 10 0f "
	HEX "06 09 08 1c 08 08 08 "
	HEX "0e 11 13 0d 01 01 0e "
	PAG
	HEX "10 10 10 16 19 11 11 "
	HEX "00 04 00 0c 04 04 0e "
	HEX "02 00 06 02 02 12 0c "
	HEX "10 10 12 14 18 14 12 "
	HEX "0c 04 04 04 04 04 04 "
	HEX "00 00 0a 15 15 11 11 "
	HEX "00 00 16 19 11 11 11 "
	HEX "00 00 0e 11 11 11 0e "
	PAG
	HEX "00 1c 12 12 1c 10 10 "
	HEX "00 07 09 09 07 01 01 "
	HEX "00 00 16 19 10 10 10 "
	HEX "00 00 0f 10 0e 01 1e "
	HEX "08 08 1c 08 08 09 06 "
	HEX "00 00 11 11 11 13 0d "
	HEX "00 00 11 11 11 0a 04 "
	HEX "00 00 11 11 15 15 0a "
	PAG
	HEX "00 00 11 0a 04 0a 11 "
	HEX "00 11 11 0f 01 11 0e "
	HEX "00 00 1f 02 04 08 1f "
	HEX "06 08 08 10 08 08 06 "
	HEX "04 04 04 00 04 04 04 "
	HEX "0c 02 02 01 02 02 0c "
	HEX "08 15 02 00 00 00 00 "
	HEX "1f 1f 1f 1f 1f 1f 1f "
