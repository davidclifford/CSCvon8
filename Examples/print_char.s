# Print char to VGA
#

# Set up X & Y position, background and foreground colour
    LCA $00 # x = 0
    STO A xpos
    LCB $00 # y = 0
    STO B ypos
    LCA $3C # forg = YELLOW
    STO A forg
    LCB $03 # bakg = BLUE
    STO B bakg
    LCA $00
    STO A pos
# Iterate through the string
1:
    LDB pos
    LDA message,B
    JAZ 2f
    STO A char
    JSR pchar
    LDB pos
    STO B+1 pos
    JMP 1b
2:
    JMP $001c # return to the Monitor

#
# Print a character (char) at position (xpos, ypos) in colour (forg, bakg)
pchar:
    LDA char
    LCB $20   # space ' '
    JLT cntrl # is control character
    LDA A-B

# Calculate start of character bitmap
    LCB $07
    STO A*B indx+1
    LDA A*BHI
    LHB ascii
    STO A+B indx # store character bitmap start in indx

# Calculate x,y coords for top left pixel of character
    LDA xpos
    LCB $06
    STO A*B xcoord
    LDA ypos
    LCB $08
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
    LDA forg
    LDB bmp
    JBN 3f
    LDA bakg
3:
    SIA ycoord  # plot bit
    LDA bmp     # roll bit map left one
    LCB $01
    STO AROLB bmp # store it
    LDB bit_count   # dec bitcount
    LDB B-1
    STO B bit_count
    JBZ 5f
    LDA xcoord  # inc x coord
    STO A+1 xcoord
    JMP 2b      # loop to next bit in bitmap
5:
    # loop to next line in bit map
    LDA indx+1
    STO A+1 indx+1
    TST A+1 JC 7f
8:
    LDA xcoord  # restore x coord (ie go back 6 pixels)
    LCB $05
    STO A-B xcoord
    LDA ycoord # increment y coord
    STO A+1 ycoord
    LDA line_count
    LDA A-1
    STO A line_count
    JAZ 6f
    JMP 1b
6:
    LDA xpos
    STO A+1 xpos
    RTS pchar
7:
    LDA indx
    STO A+1 indx
    JMP 8b

cntrl:
    LDA char
    LCB '\n'
    JEQ newline
ret:
    RTS pchar
newline:
    STO 0 xpos
    LDA ypos
    STO A+1 ypos
    LDA bakg
    LCB $07
    STO A+B bakg
    JMP ret

    PAG
char: HEX "21"
xpos: HEX "00"
ypos: HEX "00"
ycoord: HEX "00"
xcoord: HEX "00"
indx: HEX "00 00"
bakg: HEX "03"
forg: HEX "3C"
bit_count: HEX "00"
line_count: HEX "00"
bmp: HEX "00"
hexchar: HEX "00"
pos: HEX "00"

    PAG
message: STR "The quick\nbrown fox\njumps over\nthe lazy\ndog!"

# Ascii chars 32-96
    PAG
ascii:
	HEX "00 00 00 00 00 00 00 " # SPACE
	HEX "10 10 10 10 10 00 10 " # !
	HEX "24 24 48 00 00 00 00 " # "
	HEX "28 28 7c 28 7c 28 28 " # #
	HEX "10 3c 50 38 14 78 10 " # $
	HEX "64 64 08 10 20 4c 4c " # %
	HEX "10 28 28 28 54 48 34 " # &
	HEX "10 10 20 00 00 00 00 " # '
	HEX "08 10 20 20 20 10 08 " # (
	HEX "20 10 08 08 08 10 20 " # )
	HEX "10 54 38 7c 38 54 10 " # *
	HEX "00 10 10 7c 10 10 00 " # +
	HEX "00 00 00 00 10 10 20 " # ,
	HEX "00 00 00 7c 00 00 00 " # -
	HEX "00 00 00 00 00 30 30 " # .
	HEX "04 04 08 10 20 40 40 " # /
	HEX "38 44 4c 54 64 44 38 " # 0
	HEX "10 30 10 10 10 10 38 " # 1
	HEX "38 44 04 08 10 20 7c " # 2
	HEX "38 44 04 18 04 44 38 " # 3
	HEX "08 18 28 48 7c 08 08 " # 4
	HEX "7c 40 78 04 04 44 38 " # 5
	HEX "18 20 40 78 44 44 38 " # 6
	HEX "7c 04 08 10 20 20 20 " # 7
	HEX "38 44 44 38 44 44 38 " # 8
	HEX "38 44 44 3c 04 08 30 " # 9
	HEX "00 30 30 00 30 30 00 " # :
	HEX "00 30 30 00 30 10 20 " # ;
	HEX "08 10 20 40 20 10 08 " # <
	HEX "00 00 7c 00 7c 00 00 " # =
	HEX "20 10 08 04 08 10 20 " # >
	HEX "38 44 04 08 10 00 10 " # ?
	HEX "38 44 5c 54 5c 40 3c " # @
	HEX "10 28 44 44 7c 44 44 " # A
	HEX "78 44 44 78 44 44 78 " # B
	HEX "38 44 40 40 40 44 38 " # C
	HEX "78 24 24 24 24 24 78 " # D
	HEX "7c 40 40 70 40 40 7c " # E
	HEX "7c 40 40 7c 40 40 40 " # F
	HEX "38 44 40 40 4c 44 3c " # G
	HEX "44 44 44 7c 44 44 44 " # H
	HEX "38 10 10 10 10 10 38 " # I
	HEX "7c 08 08 08 08 48 30 " # J
	HEX "44 48 50 60 50 48 44 " # K
	HEX "40 40 40 40 40 40 7c " # L
	HEX "44 6c 54 44 44 44 44 " # M
	HEX "44 44 64 54 4c 44 44 " # N
	HEX "38 44 44 44 44 44 38 " # O
	HEX "78 44 44 78 40 40 40 " # P
	HEX "38 44 44 44 54 48 34 " # Q
	HEX "78 44 44 78 50 48 44 " # R
	HEX "38 44 40 38 04 44 38 " # S
	HEX "7c 10 10 10 10 10 10 " # T
	HEX "44 44 44 44 44 44 38 " # U
	HEX "44 44 44 44 44 28 10 " # V
	HEX "44 44 44 54 54 6c 44 " # W
	HEX "44 44 28 10 28 44 44 " # X
	HEX "44 44 28 10 10 10 10 " # Y
	HEX "7c 04 08 10 20 40 7c " # Z
	HEX "38 20 20 20 20 20 38 " # [
	HEX "40 40 20 10 08 04 04 " # \
	HEX "38 08 08 08 08 08 38 " # ]
	HEX "10 28 44 00 00 00 00 " # ^
	HEX "00 00 00 00 00 00 7c " # _
	HEX "10 10 08 00 00 00 00 " # back-tick
	HEX "10 10 08 00 00 00 00 " # back-tick
	HEX "00 38 04 34 4c 4c 34 " # a
	HEX "40 40 40 70 48 48 70 " # b
	HEX "00 00 00 38 40 40 38 " # c
	HEX "04 04 04 1c 24 24 1c " # d
	HEX "00 00 38 44 7c 40 3c " # e
	HEX "18 24 20 70 20 20 20 " # f
	HEX "38 44 4c 34 04 04 38 " # g
	HEX "40 40 40 58 64 44 44 " # h
	HEX "00 10 00 30 10 10 38 " # i
	HEX "10 00 18 08 08 48 30 " # j
	HEX "40 40 48 50 60 50 48 " # k
	HEX "30 10 10 10 10 10 10 " # l
	HEX "00 00 28 54 54 44 44 " # m
	HEX "00 00 58 64 44 44 44 " # n
	HEX "00 00 38 44 44 44 38 " # o
	HEX "00 70 48 48 70 40 40 " # p
	HEX "00 1c 24 24 1c 04 04 " # q
	HEX "00 00 58 64 40 40 40 " # r
	HEX "00 00 3c 40 38 04 78 " # s
	HEX "20 20 70 20 20 24 18 " # t
	HEX "00 00 44 44 44 4c 34 " # u
	HEX "00 00 44 44 44 28 10 " # v
	HEX "00 00 44 44 54 54 28 " # w
	HEX "00 00 44 28 10 28 44 " # x
	HEX "00 44 44 3c 04 44 38 " # y
	HEX "00 00 7c 08 10 20 7c " # z
	HEX "18 20 20 40 20 20 18 " # {
	HEX "10 10 10 00 10 10 10 " # |
	HEX "30 08 08 04 08 08 30 " # }
	HEX "20 54 08 00 00 00 00 " # ~
	HEX "7c 7c 7c 7c 7c 7c 7c " # DEL
