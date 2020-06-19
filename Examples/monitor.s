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
sys_cli:
	JOUT('\r')
	JOUT('\n')
	JMP prompt

terminate:
    STO 0 __paper
    JSR sys_cls # Clear video memory
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
	JEQ sys_cli
	LCB 'z'
	JEQ sys_cli
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
	JEQ sys_cli
	LCB 'z'
	JEQ sys_cli
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
sys_cls:
    STO 0 vidaddr
    STO 0 vidaddr+1
1:
    LDA __paper
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
    RTS sys_cls

###############
# Print a character (__char) at position (__xpos, __ypos) in colour (__ink, __paper)
###############
sys_pchar:
    LDA __char
    LCB $20   # space ' '
    JLT 9f # is control character
    LDA A-B

# Calculate start of character bitmap
    LCB $08
    STO A*B indx+1
    LDA A*BHI
    LHB large_font
    STO A+B indx # store character bitmap start in indx

# Calculate x,y coords for top left pixel of character
    LDA __xpos
    LCB $06
    STO A*B xcoord
    LDA __ypos
    LCB $08
    STO A*B ycoord

    LCA $08
    STO A line_count

# plot 6 pixels of character bitmap of each line
1:
    LCA $06
    STO A bit_count
    LIA indx
    STO A bmp
2: # loop through bits
    LDA __ink
    LDB bmp
    JBN 3f
    LDA __paper
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
    LDA __xpos
    STO A+1 __xpos
    RTS sys_pchar
7:
    LDA indx
    STO A+1 indx
    JMP 8b

9:
    LDA __char
    LCB '\n'
    JEQ 11f
10:
    RTS sys_pchar
11:
    STO 0 __xpos
    LDA __ypos
    STO A+1 __ypos
    JMP 10b

###############
# Print a small font character (__char) at position (__xpos, __ypos) in colour (__ink)
###############
sys_spchar:
    # Store ink in upper byte
    LDA __sink
    LCB @4
    LDA A<<B
    LCB $70
    LDA A&B
    LCB $80
    STO A|B ink

    # Get character
    LDA __schar
    # Control or character?
    LCB $20
    JLT control # is control character
    LDA A-B

    # Calculate position in ascii table and store address in 'pix'
    LCB @12
    STO A*B pix+1
    LDA A*BHI
    LHB small_font
    STO A+B pix

# Calculate x,y coords for top left pixel of character
    LDA __sxpos
    LCB $03
    STO A*B xscoord
    LDA __sypos
    LCB $04
    STO A*B yscoord

    # Init drawing of character
    LCA @2
    STO A xc
    LCA @3
    STO A yc

    # Output pixel data onto screen
next_pix:
    LIA pix
    LDB ink
#    LCB $F0
    LDA A|B
1:
    SIA yscoord
    LDA pix+1
    TST A+1 JC 2f
    STO A+1 pix+1
    JMP 3f
2:
    STO 0 pix+1
    LDA pix
    STO A+1 pix
3:
    LDA xscoord
    STO A+1 xscoord
    LDA xc
    STO A-1 xc
    JAZ next_line
    JMP next_pix
next_line:
    LCB @3
    LDA xscoord
    STO A-B xscoord
    LCA @2
    STO A xc
    LDA yscoord
    STO A+1 yscoord
    LDA yc
    STO A-1 yc
    JAZ fin_char
    JMP next_pix
fin_char:
    LDA __sxpos
    STO A+1 __sxpos
    RTS sys_spchar
control:
    # Do \n or \r (as same thing)
    LCB $0A
    JEQ 1f
    LCB $0D
    JEQ 1f
    RTS sys_spchar
1:
    STO 0 __sxpos
    LDA __sypos
    STO A+1 __sypos
    RTS sys_spchar

# Ascii chars 32-96
# Large font
    PAG
large_font:
	HEX "00 00 00 00 00 00 00 00" #
	HEX "10 38 38 10 10 00 10 00" #  !
	HEX "6c 6c 48 00 00 00 00 00" #  "
	HEX "00 28 7c 28 28 7c 28 00" #  #
	HEX "20 38 40 30 08 70 10 00" #  $
	HEX "64 64 08 10 20 4c 4c 00" #  %
	HEX "20 50 50 20 54 48 34 00" #  &
	HEX "30 30 20 00 00 00 00 00" #  '
	HEX "10 20 20 20 20 20 10 00" #  (
	HEX "20 10 10 10 10 10 20 00" #  )
	HEX "00 28 38 7c 38 28 00 00" #  *
	HEX "00 10 10 7c 10 10 00 00" #  +
	HEX "00 00 00 00 00 30 30 20" #  ,
	HEX "00 00 00 7c 00 00 00 00" #  -
	HEX "00 00 00 00 00 30 30 00" #  .
	HEX "00 04 08 10 20 40 00 00" #  /
	HEX "38 44 4c 54 64 44 38 00" #  0
	HEX "10 30 10 10 10 10 38 00" #  1
	HEX "38 44 04 18 20 40 7c 00" #  2
	HEX "38 44 04 38 04 44 38 00" #  3
	HEX "08 18 28 48 7c 08 08 00" #  4
	HEX "7c 40 40 78 04 44 38 00" #  5
	HEX "18 20 40 78 44 44 38 00" #  6
	HEX "7c 04 08 10 20 20 20 00" #  7
	HEX "38 44 44 38 44 44 38 00" #  8
	HEX "38 44 44 3c 04 08 30 00" #  9
	HEX "00 00 30 30 00 30 30 00" #  :
	HEX "00 00 30 30 00 30 30 20" #  ;
	HEX "08 10 20 40 20 10 08 00" #  <
	HEX "00 00 7c 00 00 7c 00 00" #  =
	HEX "20 10 08 04 08 10 20 00" #  >
	HEX "38 44 04 18 10 00 10 00" #  ?
PAG
	HEX "38 44 5c 54 5c 40 38 00" #  @
	HEX "38 44 44 44 7c 44 44 00" #  A
	HEX "78 44 44 78 44 44 78 00" #  B
	HEX "38 44 40 40 40 44 38 00" #  C
	HEX "78 44 44 44 44 44 78 00" #  D
	HEX "7c 40 40 78 40 40 7c 00" #  E
	HEX "7c 40 40 78 40 40 40 00" #  F
	HEX "38 44 40 5c 44 44 3c 00" #  G
	HEX "44 44 44 7c 44 44 44 00" #  H
	HEX "38 10 10 10 10 10 38 00" #  I
	HEX "04 04 04 04 44 44 38 00" #  J
	HEX "44 48 50 60 50 48 44 00" #  K
	HEX "40 40 40 40 40 40 7c 00" #  L
	HEX "44 6c 54 44 44 44 44 00" #  M
	HEX "44 64 54 4c 44 44 44 00" #  N
	HEX "38 44 44 44 44 44 38 00" #  O
	HEX "78 44 44 78 40 40 40 00" #  P
	HEX "38 44 44 44 54 48 34 00" #  Q
	HEX "78 44 44 78 48 44 44 00" #  R
	HEX "38 44 40 38 04 44 38 00" #  S
	HEX "7c 10 10 10 10 10 10 00" #  T
	HEX "44 44 44 44 44 44 38 00" #  U
	HEX "44 44 44 44 44 28 10 00" #  V
	HEX "44 44 54 54 54 54 28 00" #  W
	HEX "44 44 28 10 28 44 44 00" #  X
	HEX "44 44 44 28 10 10 10 00" #  Y
	HEX "78 08 10 20 40 40 78 00" #  Z
	HEX "38 20 20 20 20 20 38 00" #  [
	HEX "00 40 20 10 08 04 00 00" #  \
	HEX "38 08 08 08 08 08 38 00" #  ]
	HEX "10 28 44 00 00 00 00 00" #  ^
	HEX "00 00 00 00 00 00 00 fc" #  _
PAG
	HEX "30 30 10 00 00 00 00 00" #  `
	HEX "00 00 38 04 3c 44 3c 00" #  a
	HEX "40 40 78 44 44 44 78 00" #  b
	HEX "00 00 38 44 40 44 38 00" #  c
	HEX "04 04 3c 44 44 44 3c 00" #  d
	HEX "00 00 38 44 78 40 38 00" #  e
	HEX "18 20 20 78 20 20 20 00" #  f
	HEX "00 00 3c 44 44 3c 04 38" #  g
	HEX "40 40 70 48 48 48 48 00" #  h
	HEX "10 00 10 10 10 10 18 00" #  i
	HEX "08 00 18 08 08 08 48 30" #  j
	HEX "40 40 48 50 60 50 48 00" #  k
	HEX "10 10 10 10 10 10 18 00" #  l
	HEX "00 00 68 54 54 44 44 00" #  m
	HEX "00 00 70 48 48 48 48 00" #  n
	HEX "00 00 38 44 44 44 38 00" #  o
	HEX "00 00 78 44 44 44 78 40" #  p
	HEX "00 00 3c 44 44 44 3c 04" #  q
	HEX "00 00 58 24 20 20 70 00" #  r
	HEX "00 00 38 40 38 04 38 00" #  s
	HEX "00 20 78 20 20 28 10 00" #  t
	HEX "00 00 48 48 48 58 28 00" #  u
	HEX "00 00 44 44 44 28 10 00" #  v
	HEX "00 00 44 44 54 7c 28 00" #  w
	HEX "00 00 48 48 30 48 48 00" #  x
	HEX "00 00 48 48 48 38 10 60" #  y
	HEX "00 00 78 08 30 40 78 00" #  z
	HEX "18 20 20 60 20 20 18 00" #  {
	HEX "10 10 10 00 10 10 10 00" #  |
	HEX "30 08 08 0c 08 08 30 00" #  }
	HEX "28 50 00 00 00 00 00 00" #  ~
	HEX "10 38 6c 44 44 7c 00 00" #  

# Small font
PAG
small_font:
	HEX "00 00 00 00 00 00 00 00 00 00 00 00" #
	HEX "00 0d 08 00 07 02 00 01 00 00 01 00" #  !
	HEX "05 0a 0f 01 00 02 00 00 00 00 00 00" #  "
	HEX "00 08 08 01 0b 0b 04 0e 0e 00 02 02" #  #
	HEX "00 0e 08 01 0c 00 04 0c 02 00 01 00" #  $
	HEX "05 0a 05 00 04 02 04 02 0c 01 00 03" #  %
	HEX "04 06 00 01 09 00 05 01 09 00 03 01" #  &
	HEX "00 0f 00 00 02 00 00 00 00 00 00 00" #  '
	HEX "00 09 00 00 0a 00 00 0a 00 00 01 00" #  (
	HEX "00 06 00 00 05 00 00 05 00 00 02 00" #  )
	HEX "00 08 08 04 0f 0e 00 0b 0a 00 00 00" #  *
	HEX "00 04 00 04 0d 0c 00 05 00 00 00 00" #  +
	HEX "00 00 00 00 00 00 00 0c 00 00 0b 00" #  ,
	HEX "00 00 00 04 0c 0c 00 00 00 00 00 00" #  -
	HEX "00 00 00 00 00 00 00 0c 00 00 03 00" #  .
	HEX "00 00 04 00 04 02 04 02 00 00 00 00" #  /
	HEX "04 03 06 05 04 07 05 02 05 00 03 02" #  0
	HEX "00 0d 00 00 05 00 00 05 00 00 03 02" #  1
	HEX "04 03 06 00 04 09 04 02 00 01 03 03" #  2
	HEX "04 03 06 00 0c 09 04 00 05 00 03 02" #  3
	HEX "00 04 0a 04 02 0a 01 03 0b 00 00 02" #  4
	HEX "05 03 03 05 0c 08 04 00 05 00 03 02" #  5
	HEX "00 09 02 05 0c 08 05 00 05 00 03 02" #  6
	HEX "01 03 07 00 04 02 00 0a 00 00 02 00" #  7
	HEX "04 03 06 01 0c 09 05 00 05 00 03 02" #  8
	HEX "04 03 06 01 0c 0d 00 00 09 00 03 00" #  9
	HEX "00 00 00 00 0f 00 00 0c 00 00 03 00" #  :
	HEX "00 00 00 00 0f 00 00 0c 00 00 0b 00" #  ;
	HEX "00 04 02 04 02 00 00 06 00 00 00 02" #  <
	HEX "00 00 00 01 03 03 04 0c 0c 00 00 00" #  =
	HEX "00 06 00 00 00 06 00 04 02 00 02 00" #  >
	HEX "04 03 06 00 04 09 00 01 00 00 01 00" #  ?
	HEX "04 03 06 05 05 07 05 01 03 00 03 02" #  @
	HEX "04 03 06 05 00 05 05 03 07 01 00 01" #  A
	HEX "05 03 06 05 0c 09 05 00 05 01 03 02" #  B
	HEX "04 03 06 05 00 00 05 00 04 00 03 02" #  C
	HEX "05 03 06 05 00 05 05 00 05 01 03 02" #  D
	HEX "05 03 03 05 0c 08 05 00 00 01 03 03" #  E
	HEX "05 03 03 05 0c 08 05 00 00 01 00 00" #  F
	HEX "04 03 06 05 04 0c 05 00 05 00 03 03" #  G
	HEX "05 00 05 05 0c 0d 05 00 05 01 00 01" #  H
	HEX "00 07 02 00 05 00 00 05 00 00 03 02" #  I
	HEX "00 00 05 00 00 05 05 00 05 00 03 02" #  J
	HEX "05 00 09 05 09 00 05 01 08 01 00 01" #  K
	HEX "05 00 00 05 00 00 05 00 00 01 03 03" #  L
	HEX "05 08 0d 05 01 05 05 00 05 01 00 01" #  M
	HEX "05 08 05 05 01 0d 05 00 05 01 00 01" #  N
	HEX "04 03 06 05 00 05 05 00 05 00 03 02" #  O
	HEX "05 03 06 05 0c 09 05 00 00 01 00 00" #  P
	HEX "04 03 06 05 00 05 05 01 09 00 03 01" #  Q
	HEX "05 03 06 05 0c 09 05 00 06 01 00 01" #  R
	HEX "04 03 06 01 0c 08 04 00 05 00 03 02" #  S
	HEX "01 07 03 00 05 00 00 05 00 00 01 00" #  T
	HEX "05 00 05 05 00 05 05 00 05 00 03 02" #  U
	HEX "05 00 05 05 00 05 01 08 09 00 01 00" #  V
	HEX "05 00 05 05 05 05 05 05 05 00 02 02" #  W
	HEX "05 00 05 00 06 02 04 02 06 01 00 01" #  X
	HEX "05 00 05 01 08 09 00 05 00 00 01 00" #  Y
	HEX "01 03 0a 00 09 00 05 00 00 01 03 02" #  Z
	HEX "00 0b 02 00 0a 00 00 0a 00 00 03 02" #  [
	HEX "04 00 00 00 06 00 00 00 06 00 00 00" #  \
PAG
	HEX "00 03 0a 00 00 0a 00 00 0a 00 03 02" #  ]
	HEX "00 09 08 01 00 01 00 00 00 00 00 00" #  ^
	HEX "00 00 00 00 00 00 00 00 00 0c 0c 0c" #  _
	HEX "00 0f 00 00 01 00 00 00 00 00 00 00" #  `
	HEX "00 00 00 00 03 06 04 03 07 00 03 03" #  a
	HEX "05 00 00 05 03 06 05 00 05 01 03 02" #  b
	HEX "00 00 00 04 03 06 05 00 04 00 03 02" #  c
	HEX "00 00 05 04 03 07 05 00 05 00 03 03" #  d
	HEX "00 00 00 04 03 06 05 03 02 00 03 02" #  e
	HEX "00 09 02 04 0e 08 00 0a 00 00 02 00" #  f
	HEX "00 00 00 04 03 07 01 0c 0d 00 0c 09" #  g
	HEX "05 00 00 05 03 08 05 00 0a 01 00 02" #  h
	HEX "00 01 00 00 05 00 00 05 00 00 01 02" #  i
	HEX "00 00 02 00 01 0a 00 00 0a 01 0c 02" #  j
	HEX "05 00 00 05 04 02 05 06 00 01 00 02" #  k
	HEX "00 05 00 00 05 00 00 05 00 00 01 02" #  l
	HEX "00 00 00 05 06 06 05 01 05 01 00 01" #  m
	HEX "00 00 00 05 03 08 05 00 0a 01 00 02" #  n
	HEX "00 00 00 04 03 06 05 00 05 00 03 02" #  o
	HEX "00 00 00 05 03 06 05 00 05 05 03 02" #  p
	HEX "00 00 00 04 03 07 05 00 05 00 03 07" #  q
	HEX "00 00 00 01 09 06 00 0a 00 01 03 00" #  r
	HEX "00 00 00 04 03 02 00 03 06 00 03 02" #  s
	HEX "00 08 00 01 0b 02 00 0a 08 00 01 00" #  t
	HEX "00 00 00 05 00 0a 05 04 0a 00 02 02" #  u
	HEX "00 00 00 05 00 05 01 08 09 00 01 00" #  v
	HEX "00 00 00 05 00 05 05 0d 0d 00 02 02" #  w
	HEX "00 00 00 05 00 0a 04 03 08 01 00 02" #  x
	HEX "00 00 00 05 00 0a 01 0c 0a 04 09 00" #  y
	HEX "00 00 00 01 03 0a 04 03 00 01 03 02" #  z
	HEX "00 09 02 04 0a 00 00 0a 00 00 01 02" #  {
	HEX "00 05 00 00 01 00 00 05 00 00 01 00" #  |
	HEX "00 03 08 00 00 0e 00 00 0a 00 03 00" #  }
	HEX "04 06 02 00 00 00 00 00 00 00 00 00" #  ~
	HEX "00 0d 08 05 02 07 05 0c 0d 00 00 00" #  

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
__ypos: HEX "00"        # Character Y position
__xpos: HEX "00"        # Character X position
__char: HEX "00"        # Character to print at current position
__paper: HEX "00"       # Paper colour (0-63) 00rrggbb
__ink: HEX "00"         # Ink colour (0-63) 00rrggbb

__schar: BYTE           # Small Character
__sypos: BYTE           # Small character Y position
__sxpos: BYTE           # Small character X position
__sink: BYTE            # Small character ink colour (0-7) rgb

indx: HEX "00 00"       # Index of char
asc:  HEX "00"          # Character minus 'space'
ycoord: HEX "00"        # Y co-ord of char in pixels
xcoord: HEX "00"        # X co-ord of char inpixels
bit_count: HEX "00"
line_count: HEX "00"
bmp: HEX "00"
pix: WORD
yscoord: BYTE
xscoord: BYTE
yc: BYTE
xc: BYTE
ink: BYTE

EXPORT sys_cli
EXPORT sys_cls
EXPORT sys_pchar
EXPORT sys_spchar

EXPORT __char
EXPORT __xpos
EXPORT __ypos
EXPORT __paper
EXPORT __ink

EXPORT __schar
EXPORT __sypos
EXPORT __sxpos
EXPORT __sink
