# Warren's monitor ROM for the CSCvon8 CPU
# (c) 2019, GPL3
# Modified by David Clifford 2020

#define printstr(x)  LHA x; STO A strptr; LCA x; STO A strptr+1; JSR puts
#define putc(x)	     LCA x; JOU .; OUT A
#define getc(x)	     JIU .; INA; STO A x
#define JOUT(x)	     JOU .; OUT x
#define JINA	     JIU .; INA

main:
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP

    STO 0 bakg
    JSR cls         # Clear video memory

	LCB $00			# Print out the welcome message
1:	LDA welcome,B
	JAZ prompt
	JOUT(A)
	LDB B+1
	JMP 1b

prompt:	putc('>')		# Print out the prompt
	putc(' ')
	getc(cmdchar)		# Get the command letter and
	JOUT(A)			# echo it out to the user
	LCB '\n'		# Loop when we get a newline
	JEQ prompt
	LCB '\r'		# Loop when we get a carriage return
	JEQ prompt

	STO 0 hexcnt		# Set count of hex chars to zero
sploop: JINA			# Get further characters and echo them
	JOUT(A)
	LCB ' '			# Skip spaces
	JEQ sploop
	LCB '\n'		# Exit when we get a newline
	JEQ docmd
	LCB '\r'		# Exit when we get a carriage return
	JEQ docmd
	
	LDB hexcnt		# Assume it's a hex digit, store it
	STO A hexchar,B
	STO B+1 hexcnt		# Increment the counter
	LCA $03
	JEQ waitnl		# Exit loop when B==3 (highest offset)
	JMP sploop		# Otherwise loop back

waitnl: JINA			# Echo chars until a '\n' or '\r'
	JOUT(A)
	LCB '\n'
	JEQ cvtaddr
	LCB '\r'
	JEQ cvtaddr
	JMP waitnl

cvtaddr: JSR hexcvt		# Convert the four characters into an address

docmd:	JOUT('\n')

	LDA cmdchar		# Get the command character
	LCB '?'			# ?, print the usage
	JEQ printusage
	LCB 'D'			# D and d, dump memory
	JEQ dump
	LCB 'd'
	JEQ dump
	LCB 'R'			# R and r, run code at addr
	JEQ run
	LCB 'r'
	JEQ run
	LCB 'C'			# C and c, change memory
	JEQ change
	LCB 'c'
	JEQ change
	LCB 'X'			# X and x, exit csim
	JEQ terminate
	LCB 'x'
	JEQ terminate
newprompt:
	JOUT('\r')
	JOUT('\n')
	JMP prompt

terminate:
	JMP $0000

printusage:
	printstr(usage)
	JMP prompt

run:	LCB $70			# Set a JMP instruction
	STO B jmpaddr		# at the jmpaddr and go there
	JMP jmpaddr
	JMP prompt

dump:	LCB $0F			# Set a count of 15, which will be 16
	STO B count
	LDB addr		# Print out the address in hex
	STO B hexchar
	JSR prhex
	LDB addr+1
	STO B hexchar
	JSR prhex
	JOUT(':')
	JOUT(' ')
1:	LIA addr		# Get a byte through the pointer
	STO A hexchar
	JSR prhex		# Print it in hex
	JOUT(' ')		# followed by a space
	LDB count		# Decrement the count
	LDB B-1
	JBN 2f			# Exit when we get to $FF
	STO B count
	LDB addr+1		# Keep going, so move the pointer up
	STO B+1 addr+1
	JMP 1b			# and loop back

2:	JOUT('\r')
	JOUT('\n')		# End of loop, print a newline
	LDB addr+1		# Also bump up the address for the next dump
	STO B+1 addr+1
	TST B+1 JC 3f
	JMP prompt
3:	LDB addr
	STO B+1 addr
	JMP prompt

change:
	printstr(setstr)
changeloop:
	JINA			# Get a character and echo it
	JOUT(A)
	LCB ' '
	JEQ changeloop		# Start afresh for spaces and newlines
	LCB '\n'
	JEQ changeloop
	LCB '\r'
	JEQ changeloop
	LCB 'Z'			# If we get a 'Z' or 'z', end of changes
	JEQ newprompt
	LCB 'z'
	JEQ newprompt
	STO A hexchar		# Store first hex nibble, do it again
	JINA			# Get a character and echo it
	JOUT(A)
	LCB ' '
	JEQ changeloop		# Start afresh for spaces and newlines
	LCB '\n'
	JEQ changeloop
	LCB '\r'
	JEQ changeloop
	LCB 'Z'			# If we get a 'Z' or 'z', end of changes
	JEQ newprompt
	LCB 'z'
	JEQ newprompt
	STO A hexchar2		# Store second hex nibble

	JSR bytecvt		# Convert to a single byte in cmdchar
	LDA cmdchar
	SIA addr		# Store the byte through the addr pointer

	LDB addr+1		# Increment the addr pointer
	STO B+1 addr+1
	TST B+1 JC 1f
	JMP changeloop
1:	LDB addr
	STO B+1 addr
	JMP changeloop


## puts subroutine
##
puts:	LIA strptr		# Get character through the ptr
	JAZ 1f			# Exit when we get the NUL character
	JOU .			# Print out the character
	OUT A
	LDB strptr+1		# Increment the low byte of the pointer
	STO B+1 strptr+1
	JMP puts		# and loop back
1:	RTS puts

## hexcvt subroutine. Given four hex digits stored in the hexchar
#	buffer, convert them into a 16-bit big endian address
#	stored in addr.
hexcvt: LDB hexchar		# Get the first character
	LCA $3F			# Add on $3F
	LDA A+B
	JAN 1f			# If -ve, was A-F
	LDA B
	JMP 2f			# Otherwise, was a 0-9 char
1:	LCB $0A			# Add on $0A to convert char to nibble
	LDA A+B
2:	LCB $04
	STO addr A<<B		# Save top nibble into addr

	LDB hexchar2		# Repeat the process on the 2nd char
	LCA $3F			# Add on $3F
	LDA A+B
	JAN 3f			# If -ve, was A-F
	LDA B
	JMP 4f			# Otherwise, was a 0-9 char
3:	LCB $0A			# Add on $0A to convert char to nibble
	LDA A+B
4:	LCB $0F			# Get the low nibble
	LDB A&B
	LDA addr
	STO addr A|B		# Combine both nibbles and store

	LDB hexchar3		# Repeat the process on the 3rd char
	LCA $3F			# Add on $3F
	LDA A+B
	JAN 5f			# If -ve, was A-F
	LDA B
	JMP 6f			# Otherwise, was a 0-9 char
5:	LCB $0A			# Add on $0A to convert char to nibble
	LDA A+B
6:	LCB $04
	STO addr+1 A<<B		# Save top nibble into addr

	LDB hexchar4		# Repeat the process on the 4th char
	LCA $3F			# Add on $3F
	LDA A+B
	JAN 7f			# If -ve, was A-F
	LDA B
	JMP 8f			# Otherwise, was a 0-9 char
7:	LCB $0A			# Add on $0A to convert char to nibble
	LDA A+B
8:	LCB $0F			# Get the low nibble
	LDB A&B
	LDA addr+1
	STO addr+1 A|B		# Combine both nibbles and store
	RTS hexcvt

## bytecvt subroutine. Given two hex digits stored in the hexchar
#	buffer, convert them into a 8-bit value stored in cmdchar
bytecvt:
	LDB hexchar		# Get the first character
	LCA $3F			# Add on $3F
	LDA A+B
	JAN 1f			# If -ve, was A-F
	LDA B
	JMP 2f			# Otherwise, was a 0-9 char
1:	LCB $0A			# Add on $0A to convert char to nibble
	LDA A+B
2:	LCB $04
	STO cmdchar A<<B	# Save top nibble into addr

	LDB hexchar2		# Repeat the process on the 2nd char
	LCA $3F			# Add on $3F
	LDA A+B
	JAN 3f			# If -ve, was A-F
	LDA B
	JMP 4f			# Otherwise, was a 0-9 char
3:	LCB $0A			# Add on $0A to convert char to nibble
	LDA A+B
4:	LCB $0F			# Get the low nibble
	LDB A&B
	LDA cmdchar
	STO cmdchar A|B		# Combine both nibbles and store
	RTS bytecvt

# prhex function: Print the value in hexchar
# out as two hex digits
prhex:	LDA hexchar	# Load a copy of A
	LCB $04		# Get high nibble of A
	LDA A>>B
	LCB $09
	JGT 1f		# Skip if in range A to F
	LCB $30		# Otherwise add '0'
	JMP 2f		# and print it
1:	LCB $37		# Add 55 to get it in 'A' to 'F'
2:	LDA A+B
	JOUT(A)

	LDA hexchar	# Get A back again
	LCB $0F		# Get the low nibble of A
	LDA A&B
	LCB $09
	JGT 1f		# Skip if in range A to F
	LCB $30		# Otherwise add '0'
	JMP 2f		# and print it
1:	LCB $37		# Add 55 to get it in 'A' to 'F'
2:	LDA A+B
	JOUT(A)
	RTS prhex

## Clear screen. Using indirect addressing
#
cls:
    STO 0 vidaddr
    STO 0 vidaddr+1
1:
    LDA bakg
    SIA vidaddr
    LDA vidaddr+1
    STO A+1 vidaddr+1
    LCB @160
    JNE 1b

# Next line
    STO 0 vidaddr+1
    LDA vidaddr
    STO A+1 vidaddr
    LCB @120
    JNE 1b
    RTS cls

###############
# Print a character (char) at position (xpos, ypos) in colour (forg, bakg)
###############
pchar:
    LDA char
    LCB $20   # space ' '
    JLT 9f # is control character
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

9:
    LDA char
    LCB '\n'
    JEQ 11f
10:
    RTS pchar
11:
    STO 0 xpos
    LDA ypos
    STO A+1 ypos
    JMP 10b

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

# String constants
	 PAG
welcome: STR "[2J[HCSCvon8 Monitor, Revision: 2.01, type ? for help\n\n"
usage:	 STR "Usage: D dump, C change, R run, ? help, X exit\n"
setstr:	 STR "Enter space separated hex digits, end with Z\n\n"

	  ORG $FD00
hexchar:  HEX "00"		# Place to store four hex chars, page aligned
hexchar2: HEX "00"
hexchar3: HEX "00"
hexchar4: HEX "00"
strptr:	  HEX "00"		# String pointer for puts
	  HEX "00"
cmdchar:  HEX "00"		# Command character
hexcnt:	  HEX "00"		# Count of hex chars left to store
jmpaddr:  HEX "00"
addr:	  HEX "80"		# Address used by all commands
	  HEX "00"
count:	  HEX "00"		# 16-bit counter, used when loading a program
	  HEX "00"

vidaddr: HEX "00 00"    # Video address
ypos: HEX "00"          # Character Y position
xpos: HEX "00"          # Character X position
char: HEX "00"          # Character to print at current position
bakg: HEX "00"          # Background colour
forg: HEX "00"          # Forground colour
indx: HEX "00 00"       # Index of char
asc:  HEX "00"          # Character minus 'space'
ycoord: HEX "00"        # Y co-ord of char in pixels
xcoord: HEX "00"        # X co-ord of char inpixels
bit_count: HEX "00"
line_count: HEX "00"
bmp: HEX "00"

EXPORT newprompt
EXPORT cls
EXPORT pchar
EXPORT char
EXPORT xpos
EXPORT ypos
EXPORT bakg
EXPORT forg
