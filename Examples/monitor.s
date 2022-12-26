# Warren's monitor ROM for the CSCvon8 CPU
# (c) 2019, GPL3
# Modified by David Clifford 2020, 2022
# With added Filesystem

#define printstr(x)  LHA x; STO A strptr; LCA x; STO A strptr+1; JSR puts
#define putc(x)	     LCA x; JOU .; OUT A
#define getc(x)	     JIU .; INA; STO A x
#define JOUT(x)	     JOU .; OUT x
#define JINA	     JIU .; INA
#define cmd_key()    JIU .; INA; JOUT(A); LDB cmd_ptr; STO A command,B; STO B+1 cmd_ptr
#define nxt_cmd()    LDB cmd_ptr; LDA command,B; STO B+1 cmd_ptr
#define peek_cmd()   LDB cmd_ptr; LDA command,B

main:
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP

# Reset drive partition to A ($F0)
    LCA $F0
    STO A partition
reset:
# Reset banked memory to VGA
    STO 0 $F000

	LCB welcome			# Print out the welcome message
1:	LDA welcome,B
	JAZ prompt
	JOUT(A)
	LDB B+1
	JMP 1b

prompt:
    STO 0 cmd_ptr
    STO 0 $F000
    JOUT('>')		# Print out the prompt
	JOUT(' ')
1:
    LDA __rand_seed+1
    LDA A+1
    STO A __rand_seed+1
    JAZ 2f
    JMP 3f
2:
    LDA __rand_seed
    STO A+1 __rand_seed
3:
    cmd_key()       # get next keypress in command buffer
	LCB '\n'		# Execute command when we get a newline
	JEQ execute_cmd
	LCB '\r'		# Execute command when we get a carriage return
	JEQ execute_cmd
	LCB $08
	JEQ 4f
	JMP 3b
4:
# Backspace
	JOUT(' ')
	LDB cmd_ptr
	LDB B-1
	STO B cmd_ptr
	JBZ 3b
	STO 0 command,B
	STO B-1 cmd_ptr
	JOUT($08)
	JMP 3b

execute_cmd:
    LDB cmd_ptr
    LDB B-1
    STO 0 command,B # zero terminate command buffer
    STO 0 cmd_ptr   # set command pointer to start of command

docmd:
    nxt_cmd()
    STO A cmdchar
	LCB '?'			# ?, print the usage
	JEQ printusage
	LCB 'D'			# D and d, dump memory
	JEQ dump
	LCB 'd'
	JEQ dump
	LCB 'V'			# V and v, dump video memory
	JEQ vdump
	LCB 'v'
	JEQ vdump
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
	LCB 'T'			# T and t, table of contents
	JEQ table
	LCB 't'
	JEQ table
	LCB 'S'			# S and s, save file
	JEQ save_command
	LCB 's'
	JEQ save_command
	LCB 'L'			# L and l, load file
	JEQ load_command
	LCB 'l'
	JEQ load_command
	LCB 'G'			# G and g, load file and go (run it!)
	JEQ load_command
	LCB 'g'
	JEQ load_command
	LCB 'E'			# E and e, erase file
	JEQ erase_command
	LCB 'e'
	JEQ erase_command
	LCB 'F'			# F and f, format SSD
	JEQ format_ssd
	LCB 'f'
	JEQ format_ssd
	JMP prompt
sys_cli:
    JOUT('\n')
	JMP prompt

terminate:
    STO 0 __paper
    JSR sys_cls # Clear video memory
	JMP reset

printusage:
	printstr(usage)
	printstr(usage2)
	JMP prompt

run:
    JSR cmd2addr
    LCB $70			# Set a JMP instruction
	STO B jmpaddr	# at the jmpaddr and go there
	JMP jmpaddr
	JMP prompt

cmd2addr:
    STO 0 addr
    STO 0 addr+1
1:
    nxt_cmd()
    JAZ 2f
    LCB ' '
    JEQ 2f
    LCB '0'
    JLT 2f
    LCB ':'
    JLT 3f
    LCB 'A'
    JLT 2f
    LCB 'G'
    JLT 5f
    LCB 'a'
    JLT 2f
    LCB 'g'
    JLT 6f
    JMP 2f
3:
    LCB '0'
    LDA A-B
    JMP 4f
5:
    LCB 'A'
    LDA A-B
    LCB @10
    LDA A+B
    JMP 4f
6:
    LCB 'a'
    LDA A-B
    LCB @10
    LDA A+B
4:
    STO A digit
# Multiply addr by 16 and add digit
    LCB @16
    LDA addr
    STO A*B addr
    LDA addr+1
    STO A*B addr+1
    LDA A*BHI
    LDB addr
    STO A+B addr
    LDA addr+1
    LDB digit
    STO A+B addr+1
    JMP 1b
2:
    RTS cmd2addr

dump:
    JSR cmd2addr
    LCB $0F         # Set a count of 15, which will be 16
    STO B count+1
4:  LCB $0F			# Set a count of 15, which will be 16
	STO B count
	LDB addr		# Print out the address in hex
	STO B __hex
	JSR sys_phex
	LDB addr+1
	STO B __hex
	JSR sys_phex
	JOUT(':')
	JOUT(' ')
1:	LDB addr+1
    LAI addr,B		# Get a byte through the pointer
	STO A __hex
	JSR sys_phex		# Print it in hex
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
5:	LDB count+1
	LDB B-1
	JBN prompt
	STO B count+1
	JMP 4b
3:	LDB addr
	STO B+1 addr
	JMP 5b

vdump:
    JSR cmd2addr
    LCB $0F         # Set a count of 15, which will be 16
    STO B count+1
4:  LCB $0F			# Set a count of 15, which will be 16
	STO B count
	LDB addr		# Print out the address in hex
	STO B __hex
	JSR sys_phex
	LDB addr+1
	STO B __hex
	JSR sys_phex
	JOUT(':')
	JOUT(' ')
1:  LDB addr+1
 	VAI addr,B		# Get a byte through the pointer
	STO A __hex
	JSR sys_phex		# Print it in hex
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
5:	LDB count+1
	LDB B-1
	JBN prompt
	STO B count+1
	JMP 4b
3:	LDB addr
	STO B+1 addr
	JMP 5b

change:
    JSR cmd2addr
	printstr(setstr)
changeloop:
	JINA			# Get a character and echo it
	JOUT(A)
	LCB ' '
	JEQ changeloop	# Start afresh for spaces and newlines
	LCB '\n'
	JEQ changeloop
	LCB '\r'
	JEQ changeloop
	LCB 'Z'         # when we get a Z or z, end of changes
	JEQ sys_cli
	LCB 'z'
	JEQ sys_cli
	STO A __hex		# Store first hex nibble, do it again
	JINA			# Get a character and echo it
	JOUT(A)
	LCB ' '
	JEQ changeloop	# Start afresh for spaces and newlines
	LCB '\n'
	JEQ changeloop
	LCB '\r'
	JEQ changeloop
	LCB 'Z'	        # when we get a Z or z, end of changes
	JEQ sys_cli
	LCB 'z'
	JEQ sys_cli
	STO A __hex2	# Store second hex nibble

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

## hexcvt subroutine. Given four hex digits stored in the __hex
#	buffer, convert them into a 16-bit big endian address
#	stored in addr.
hexcvt:
    LDB __hex		# Get the first character
	LCA $3F			# Add on $3F
	LDA A+B
	JAN 1f			# If -ve, was A-F
	LDA B
	JMP 2f			# Otherwise, was a 0-9 char
1:	LCB $0A			# Add on $0A to convert char to nibble
	LDA A+B
2:	LCB $04
	STO addr A<<B		# Save top nibble into addr

	LDB __hex2		# Repeat the process on the 2nd char
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

	LDB __hex3		# Repeat the process on the 3rd char
	LCA $3F			# Add on $3F
	LDA A+B
	JAN 5f			# If -ve, was A-F
	LDA B
	JMP 6f			# Otherwise, was a 0-9 char
5:	LCB $0A			# Add on $0A to convert char to nibble
	LDA A+B
6:	LCB $04
	STO addr+1 A<<B		# Save top nibble into addr

	LDB __hex4		# Repeat the process on the 4th char
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

## bytecvt subroutine. Given two hex digits stored in the __hex
#	buffer, convert them into a 8-bit value stored in cmdchar
bytecvt:
	LDB __hex		# Get the first character
	LCA $3F			# Add on $3F
	LDA A+B
	JAN 1f			# If -ve, was A-F
	LDA B
	JMP 2f			# Otherwise, was a 0-9 char
1:	LCB $0A			# Add on $0A to convert char to nibble
	LDA A+B
2:	LCB $04
	STO cmdchar A<<B	# Save top nibble into addr

	LDB __hex2		# Repeat the process on the 2nd char
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

# sys_phex function: Print the value in __hex
# out as two hex digits
sys_phex:	LDA __hex	# Load a copy of A
	LCB $04		# Get high nibble of A
	LDA A>>B
	LCB $09
	JGT 1f		# Skip if in range A to F
	LCB $30		# Otherwise add '0'
	JMP 2f		# and print it
1:	LCB $37		# Add 55 to get it in 'A' to 'F'
2:	LDA A+B
	JOUT(A)

	LDA __hex	# Get A back again
	LCB $0F		# Get the low nibble of A
	LDA A&B
	LCB $09
	JGT 1f		# Skip if in range A to F
	LCB $30		# Otherwise add '0'
	JMP 2f		# and print it
1:	LCB $37		# Add 55 to get it in 'A' to 'F'
2:	LDA A+B
	JOUT(A)
	RTS sys_phex

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
    LDA __paper
    LCB $40
    LDA A|B
    STO A $789f
    RTS sys_cls

###############
# Print a large font character (__char) at position (__xpos, __ypos) in colour (__ink, __paper)
###############
sys_pchar:
    LDA __char
    LCB ' ' # space
    JLT 9f  # is control character
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
    LCB @25
    JEQ 11f
    JMP 10f
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
    LCB @14
    JEQ 12f
    STO A+1 __ypos
    JMP 10b
12:
    JSR sys_scroll8
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
    LCB @52
    JEQ 1f
    RTS sys_spchar
control:
    # Do \n or \r (as same thing)
    LCB '\n'
    JEQ 1f
    LCB '\r'
    JNE 2f
1:
    STO 0 __sxpos
    LDA __sypos
    LCB @29
    JEQ 1f
    STO A+1 __sypos
2:
    RTS sys_spchar
1:
    JSR sys_scroll4
    JMP 2b

###################################################
# Scroll screen up 1 pixels and blank last line
###################################################
sys_scroll:
    STO 0 scroll_to
    LCB @1
    STO B scroll_from
3:
    LDB 0
4:
    VAI scroll_from,B
    STI A scroll_to,B
    LDB B+1
    LCA @160
    JNE 4b
    LDA scroll_to
    STO A+1 scroll_to
    LDA scroll_from
    STO A+1 scroll_from
    LCB @119
    JNE 3b
5:
    LDB 0
6:
    STI 0 scroll_to,B
    LDB B+1
    LCA @160
    JNE 6b
    LDA scroll_to
    STO A+1 scroll_to
    LCB @120
    JNE 5b
    RTS sys_scroll

###################################################
# Scroll screen up 4 pixels and blank last 4 lines
###################################################
sys_scroll4:
    STO 0 scroll_to
    LCB @4
    STO B scroll_from
3:
    LDB 0
4:
    VAI scroll_from,B
    STI A scroll_to,B
    LDB B+1
    LCA @160
    JNE 4b
    LDA scroll_to
    STO A+1 scroll_to
    LDA scroll_from
    STO A+1 scroll_from
    LCB @119
    JNE 3b
5:
    LDB 0
6:
    STI 0 scroll_to,B
    LDB B+1
    LCA @160
    JNE 6b
    LDA scroll_to
    STO A+1 scroll_to
    LCB @120
    JNE 5b
    RTS sys_scroll4

###################################################
# Scroll screen up 8 pixels and blank last 8 lines
###################################################
sys_scroll8:
    STO 0 scroll_to
    LCB @8
    STO B scroll_from
3:
    LDB 0
4:
    VAI scroll_from,B
    STI A scroll_to,B
    LDB B+1
    LCA @160
    JNE 4b
    LDA scroll_to
    STO A+1 scroll_to
    LDA scroll_from
    STO A+1 scroll_from
    LCB @119
    JNE 3b
5:
    LDB 0
6:
    STI 0 scroll_to,B
    LDB B+1
    LCA @160
    JNE 6b
    LDA scroll_to
    STO A+1 scroll_to
    LCB @120
    JNE 5b
    RTS sys_scroll8

##################################
# Print string in large characters
##################################
sys_pstring:
2:
    LIA __string
    JAZ 1f
    STO A __char
    JSR sys_pchar
    LDB __string+1
    STO B+1 __string+1
    JMP 2b
1:
    RTS sys_pstring

##################################
# Print string in small characters
##################################
sys_spstring:
2:
    LIA __string
    JAZ 1f
    STO A __schar
    JSR sys_spchar
    LDB __string+1
    TST B+1 JC 3f
    STO B+1 __string+1
    JMP 2b
1:
    RTS sys_spstring
3:
    LDA __string
    STO A+1 __string
    STO 0 __string+1
    JMP 2b

###################################
# Random number generator
###################################
sys_rand:
# T = x^(x<<5)
    LDA __rand_seed0+1
    LCB @5
    LDA AROLB
    LCB $E0
    STO A&B rand_temp+1
    LCB $1F
    STO A&B rand_temp

    LDA __rand_seed0
    LCB @5
    LDA A<<B
    LCB $E0
    LDA A&B
    LDB rand_temp
    STO A|B rand_temp

    LDA __rand_seed0
    LDB rand_temp
    STO A^B rand_temp
    LDA __rand_seed0+1
    LDB rand_temp+1
    STO A^B rand_temp+1

# X = Y
    LDA __rand_seed
    STO A __rand_seed0
    LDA __rand_seed+1
    STO A __rand_seed0+1

# Z = T>>3
    LDA rand_temp
    LCB @3
    LDA ARORB
    LCB $E0
    STO A&B rand_z+1
    LCB $1F
    STO A&B rand_z
    LDA rand_temp+1
    LCB @3
    LDA A>>B
    LDB rand_z+1
    STO A|B rand_z+1

# T = T^Z
    LDA rand_z
    LDB rand_temp
    STO A^B rand_temp
    LDA rand_z+1
    LDB rand_temp+1
    STO A^B rand_temp+1

# Z = Y>>1
    LDA __rand_seed
    LCB @1
    LDA ARORB
    LCB $80
    STO A&B rand_z+1
    LCB $7F
    STO A&B rand_z
    LDA __rand_seed+1
    LCB @1
    LDA A>>B
    LDB rand_z+1
    STO A|B rand_z+1

# Y = Y^Z
    LDA __rand_seed
    LDB rand_z
    STO A^B __rand_seed
    LDA __rand_seed+1
    LDB rand_z+1
    STO A^B __rand_seed+1

# Y = Y^T
    LDA __rand_seed
    LDB rand_temp
    STO A^B __rand_seed
    LDA __rand_seed+1
    LDB rand_temp+1
    STO A^B __rand_seed+1

    RTS sys_rand

###############################################
# Convert 32-bit number to string
# Copy 32-bit unsigned integer to __number
# Use __num_str as base and __num_ptr as offset
#  of string to print out
###############################################

sys_num_str_32:
    LCB     __num_str+10
    STO     B __num_ptr
    STO     0 __num_str+11
1:  LDB     0

    LDA     __number
    STO     ADIVB __number
    LDB     AREMB

    LDA     __number+1
    STO     ADIVB __number+1
    LDB     AREMB

    LDA     __number+2
    STO     ADIVB __number+2
    LDB     AREMB

    LDA     __number+3
    STO     ADIVB __number+3
    LDA     AREMB

    LCB     '0'
    LDA     A+B
    LDB     __num_ptr
    STO     A __num_str,B
    STO     B-1 __num_ptr
# is number now zero ?
    LDA     __number
    LDB     __number+1
    LDA     A|B
    LDB     __number+2
    LDA     A|B
    LDB     __number+3
    LDA     A|B
    JAZ     1f
    JMP     1b
1:
    LDA     __num_ptr
    STO     A+1 __num_ptr
    RTS     sys_num_str_32

###############################################
# Convert 16-bit number to string
# Copy 16-bit unsigned integer to __number
# Use __num_str as base and __num_ptr as offset
#  of string to print out
###############################################

sys_num_str_16:
    LCB     __num_str+10
    STO     B __num_ptr
    STO     0 __num_str+11
1:  LDB     0

    LDA     __number
    STO     ADIVB __number
    LDB     AREMB

    LDA     __number+1
    STO     ADIVB __number+1
    LDA     AREMB

    LCB     '0'
    LDA     A+B
    LDB     __num_ptr
    STO     A __num_str,B
    STO     B-1 __num_ptr
# is number now zero ?
    LDA     __number
    LDB     __number+1
    LDA     A|B
    JAZ     1f
    JMP     1b
1:
    LDA     __num_ptr
    STO     A+1 __num_ptr
    RTS     sys_num_str_16

###############################################
# Convert 8-bit number to string
# Copy 8-bit unsigned integer to __number
# Use __num_str as base and __num_ptr as offset
#  of string to print out
###############################################

sys_num_str_8:
    LCB     __num_str+10
    STO     B __num_ptr
    STO     0 __num_str+11
1:  LDB     0

    LDA     __number
    STO     ADIVB __number
    LDA     AREMB

    LCB     '0'
    LDA     A+B
    LDB     __num_ptr
    STO     A __num_str,B
    STO     B-1 __num_ptr
# is number now zero ?
    LDA     __number
    JAZ     1f
    JMP     1b
1:
    LDA     __num_ptr
    STO     A+1 __num_ptr
    RTS     sys_num_str_8

##########################################################################################
# File system
#
# filename address  length  data
# <- 20 -> <-  2 -> <- 2 -> <- data x length ->|<-- next file -->|<-- FF FF FF ... -->|
#
# David Clifford 23 Dec 2022
##########################################################################################

#####################
# Partition command
#####################
print_partition:
    printstr(part)
    LDA $F000
    LCB $0F
    LDA A&B
    LCB 'A'
    LDA A+B
    OUT A
    OUT '\n'
    RTS print_partition

###########################################
# Table - Output directory of contents of SSD
###########################################
# TODO: Output free space not used space (must know how big SSD is first)
table:
    LDA partition
    STO A $F000
    nxt_cmd()
    JAZ 5f
    LCB 'p'
    JHI 3f
    LCB '`'
    JHI 1f
    LCB 'P'
    JHI 3f
    LCB '@'
    JHI 2f
3:
    printstr(inv_part)
    JMP 5f
1:
    LCB 'a'
    LDA A-B
    JMP 4f
2:
    LCB 'A'
    LDA A-B
4:
    LCB $F0
    STO A|B $F000
    STO A|B partition
5:
    JSR print_partition
    OUT '\n'
    STO 0 ptrB
    STO 0 ptrB+1

dir_next_filename:
    LDA ptrB
    STO A ptrA
    LDA ptrB+1
    STO A ptrA+1

# While (ptrA) != FF
    LDB ptrA+1
    VAI ptrA,B
    LCB $FF
    JEQ dir_finish

# While (ptrA) != 0
1:
    LDB ptrA+1
    VAI ptrA,B
    JAZ dir_filename_done
    OUT A
    LDA ptrA+1
    LDA A+1
    STO A ptrA+1
    JAZ 2f
    JMP 1b
2:
    LDA ptrA
    STO A+1 ptrA
    JMP 1b
dir_filename_done:
    OUT ' '
    OUT '$'
# Skip over filename to get address
    LCB @20
    LDA ptrB+1
    STO A+B ptrB+1
    TST A+B JC 1f
    JMP 2f
1:
    LDA ptrB
    STO A+1 ptrB
2:
# Find address
    LDB ptrB+1
    VAI ptrB,B
    STO A addr
# increment ptrB
    LDA ptrB+1
    LDA A+1
    STO A ptrB+1
    JAZ 1f
    JMP 2f
1:
    LDA ptrB
    STO A+1 ptrB
2:
    LDB ptrB+1
    VAI ptrB,B
    STO A addr+1
# Got address, output as HEX
    LDA addr
    STO A __hex
    JSR sys_phex
    LDA addr+1
    STO A __hex
    JSR sys_phex
    OUT ' '
# Find length ...
# increment ptrB
    LDA ptrB+1
    LDA A+1
    STO A ptrB+1
    JAZ 1f
    JMP 2f
1:
    LDA ptrB
    STO A+1 ptrB
2:
    LDB ptrB+1
    VAI ptrB,B
    STO A length
# increment ptrB
    LDA ptrB+1
    LDA A+1
    STO A ptrB+1
    JAZ 1f
    JMP 2f
1:
    LDA ptrB
    STO A+1 ptrB
2:
    LDB ptrB+1
    VAI ptrB,B
    STO A length+1
# Got length, convert to decimal
    LDA length
    STO A __number
    LDA length+1
    STO A __number+1
    JSR sys_num_str_16
# Printout ___num_str
    LDB __num_ptr
1:
    LDA __num_str,B
    JAZ 2f
    OUT A
    LDB B+1
    JMP 1b
2:
    OUT '\n'
# add length+1 to ptrB
# increment ptrB
    LDA ptrB+1
    LDA A+1
    STO A ptrB+1
    JAZ 1f
    JMP 2f
1:
    LDA ptrB
    STO A+1 ptrB
2:
    LDA length+1
    LDB ptrB+1
    STO A+B ptrB+1
    TST A+B JC 1f
    JMP 2f
1:
    LDA ptrB
    STO A+1 ptrB
2:
    LDA length
    LDB ptrB
    STO A+B ptrB
    JMP dir_next_filename

dir_finish:
    printstr(used)

    LDA ptrB
    STO A __number
    LDA ptrB+1
    STO A __number+1
    JSR sys_num_str_16
# Printout ___num_str
    LDB __num_ptr
1:
    LDA __num_str,B
    JAZ 2f
    OUT A
    LDB B+1
    JMP 1b
2:
    printstr(bytes)
    JMP prompt

#####################
# Load file command
#####################
load_command:
    LDA partition
    STO A $F000
    LCA filename
    STO A fn_ptr
1:
    nxt_cmd()
    LCB ' '
    JEQ 1b
    LDB fn_ptr
    STO A filename,B
    STO B+1 fn_ptr
# Filename known
    JAZ 4f
    JMP 1b
4:
    JSR load_file
5:
    JMP prompt

######################################
# Load file
# input: filename
# output: 'not found' or 'file loaded'
######################################
load_file:
    JSR find_file
    LDB ptrA+1
    VAI ptrA,B
    LCB $FF
    JEQ 5f
### FILE FOUND ###
# ptrA += 20
    LDA ptrA+1
    LCB @20
    STO A+B ptrA+1
    TST A+B JC 1f
    JMP 2f
1:
    LDA ptrA
    STO A+1 ptrA
2:
# Get address MSB
    LDB ptrA+1
    VAI ptrA,B
    STO A addr
    STO A run_addr
# incr ptrA
    LDA ptrA+1
    LDA A+1
    STO A ptrA+1
    JAZ 1f
    JMP 2f
1:
    LDA ptrA
    STO A+1 ptrA
2:
# Get address LSB
    LDB ptrA+1
    VAI ptrA,B
    STO A addr+1
    STO A run_addr+1
# incr ptrA
    LDA ptrA+1
    LDA A+1
    STO A ptrA+1
    JAZ 1f
    JMP 2f
1:
    LDA ptrA
    STO A+1 ptrA
2:
# Get length MSB
    LDB ptrA+1
    VAI ptrA,B
    STO A length
# incr ptrA
    LDA ptrA+1
    LDA A+1
    STO A ptrA+1
    JAZ 1f
    JMP 2f
1:
    LDA ptrA
    STO A+1 ptrA
2:
# print out 'file found'
    printstr(fld)
    LDA run_addr
    STO A __hex
    JSR sys_phex
    LDA run_addr+1
    STO A __hex
    JSR sys_phex
    JOUT('\n')
# Get length LSB
    LDB ptrA+1
    VAI ptrA,B
    STO A length+1
# incr ptrA
    LDA ptrA+1
    LDA A+1
    STO A ptrA+1
    JAZ 1f
    JMP 2f
1:
    LDA ptrA
    STO A+1 ptrA
2:
# Copy from ptrA to addr
9:
    LDB ptrA+1
    VAI ptrA,B
    LDB addr+1
    STI A addr,B
# incr addr
    LDA addr+1
    LDA A+1
    STO A addr+1
    JAZ 1f
    JMP 2f
1:
    LDA addr
    STO A+1 addr
2:
# incr ptrA
    LDA ptrA+1
    LDA A+1
    STO A ptrA+1
    JAZ 1f
    JMP 2f
1:
    LDA ptrA
    STO A+1 ptrA
2:
# decr length
    LDA length+1
    LDA A-1
    STO A length+1
    JAZ 1f
    JMP 9b
1:
    LDA length
    JAZ 6f
    STO A-1 length
    JMP 9b
5:
    printstr(fnf)
    JMP prompt
6:
    LDA cmdchar
    LCB 'L'
    JEQ prompt
    LCB 'l'
    JEQ prompt
    LCB $70			# Set a JMP instruction
	STO B runaddr	# at the jmpaddr and go there
	JMP runaddr

#################
# Find File
# input: filename
# output: ptrA - points to found file or 0xFF
#################
find_file:
    STO 0 ptrA
    STO 0 ptrA+1
1:
# detect end of file system
    LDB ptrA+1
    VAI ptrA,B
    LCB $FF
    JEQ 4f
# copy ptrA to ptrB
    LDA ptrA
    STO A ptrB
    LDA ptrA+1
    STO A ptrB+1
# compare filename to file-system
    LCA filename
    STO A fn_ptr
3:
    LDB ptrB+1
    VAI ptrB,B
    STO A char

    LDB fn_ptr
    LDA filename,B
    LDB char
    JEQ 2f
# Filenames don't match
    JSR file_find_next
    JMP 1b
2:
    JAZ 4f
    LDA fn_ptr
    STO A+1 fn_ptr
    LDA ptrB+1
    LDA A+1
    STO A ptrB+1
    JAZ 1f
    JMP 2f
1:
    LDA ptrB
    STO A+1 ptrB
2:
    JMP 3b
4:
    RTS find_file

#####################
# Find next file
# input: ptrA
#####################
file_find_next:
    LDA ptrA+1
    LCB @22
    STO A+B ptrA+1
    TST A+B JC 1f
    JMP 2f
1:
    LDA ptrA
    STO A+1 ptrA
2:
# Get size of next block
    LDB ptrA+1
    VAI ptrA,B
    STO A length
# ptrA++
    LDB B+1
    STO B ptrA+1
    JBZ 1f
    JMP 2f
1:
    LDA ptrA
    STO A+1 ptrA
2:
    LDB ptrA+1
    VAI ptrA,B
    STO A length+1
# ptrA++
    LDB ptrA+1
    LDB B+1
    STO B ptrA+1
    JBZ 1f
    JMP 2f
1:
    LDA ptrA
    STO A+1 ptrA
2:
# Add length to pointer
    LDA ptrA+1
    LDB length+1
    STO A+B ptrA+1
    TST A+B JC 1f
    JMP 2f
1:
    LDA ptrA
    STO A+1 ptrA
2:
    LDA ptrA
    LDB length
    STO A+B ptrA

    RTS file_find_next

#####################
# Erase file command
#####################
erase_command:
1:
    printstr(sure)
    JIU .
    INA
    LCB 'Y'
    JEQ 2f
    LCB 'y'
    JEQ 2f
    JMP 4f
2:
    LDA partition
    STO A $F000
3:
    nxt_cmd()
    STO A char
    JAZ 4f
    LCB ' '
    JEQ 3b
# copy to filename variable
1:
    LCA filename
    STO A fn_ptr
    LDA char
2:
    JAZ 3f
    LDB fn_ptr
    STO B+1 fn_ptr
    STO A filename,B
    nxt_cmd()
    JMP 2b
3:
    LDB fn_ptr
    STO 0 filename,B
# Filename known
    JSR erase_file
    JMP 5f
4:
    printstr(abort)
5:
    JMP prompt

##################
# Erase File
# input: filename
# output: 'file not found' or 'file deleted'
##################
erase_file:
    JSR find_file
# was it found?
    LDB ptrA+1
    VAI ptrA,B
    LCB $FF
# NOT found so abort
    JEQ 9f
# FILE FOUND
# Save start of found file
    LDA ptrA
    STO A start
    LDA ptrA+1
    STO A start+1
# Save start of next file in source (i.e. start of next file)
    JSR file_find_next
    LDA ptrA
    STO A source
    LDA ptrA+1
    STO A source+1
1:
    LDB ptrA+1
    VAI ptrA,B
    LCB $FF
    JEQ 2f
# next file
    JSR file_find_next
    JMP 1b
2:
# Save very end
    LDA ptrA
    STO A very_end
    LDA ptrA+1
    STO A very_end+1
# start, end and very_end have been found
# Set mem_buff to buffer address (0xE000)
    LCA $E0
    STO A mem_buff
    STO 0 mem_buff+1
# find start of 4k block (12 LSBs set to 0) and set to dest and ssd_save
    STO 0 dest+1
    STO 0 ssd_save+1
    LDA start
    LCB $F0
    STO A&B dest
    STO A&B ssd_save
# Start loop
7:
# exit if ssd_save == start
    LDA start
    LDB ssd_save
    JNE 2f
    LDA ssd_save+1
    LDB start+1
    JEQ 6f
# copy block from fs to mem buff ($e000) from start of 4k block to start of erased file
2:
    LDB mem_buff+1
    VAI ssd_save,B
    STI A mem_buff,B
# incr B
    LDB B+1
    STO B mem_buff+1
    STO B ssd_save+1
    JBZ 1f
    JMP 7b
# carry
1:
    LDA mem_buff
    STO A+1 mem_buff
    LDA ssd_save
    STO A+1 ssd_save
    JMP 7b
# End of loop
6:
# Copy rest to RAM
# Make sure to fill FF
    LDB mem_buff+1
    LCA $FF
    STI A mem_buff,B
# check to see not off end of FS
# TODO: change when FS > $8000 bytes (>32kb)
#
    LDA source
    LCB $80
    JEQ 1f
# copy FS to RAM
    LDB source+1
    VAI source,B
    LDB mem_buff+1
    STI A mem_buff,B
# incr source
1:
    LDA source+1
    LDA A+1
    STO A source+1
    JAZ 3f
# incr mem_buff
4:
    LDA mem_buff+1
    LDA A+1
    STO A mem_buff+1
    JAZ 5f
    JMP 6b
3:
# Carry source
    LDA source
    STO A+1 source
    JMP 4b
# Carry mem_buff
5:
    LDA mem_buff
    LDA A+1
    STO A mem_buff
# Check end of RAM buffer (mem_buff)
    LCB $F0
    JNE 6b
# Finish loop

# MAIN LOOP
erase_file_loop:

# 4k buffer filled - erase fs block
    JSR erase_sector
# Set mem_buff to $E000
    LCA $E0
    STO A mem_buff
    STO 0 mem_buff+1

# Copy buffer back to fs
erase_copy_loop:
    LCA $AA
    STO A $5555
    LCA $55
    STO A $2AAA
    LCA $A0
    STO A $5555
# (mem_buff) -> (dest)
    LIA mem_buff
    STO A char
    SIA dest

# Wait for write to complete
10:
    LDB dest+1
    VAI dest,B
    LDB char
    JNE 10b
# inc mem_buff
11:
    LDA mem_buff+1
    LDA A+1
    STO A mem_buff+1
    JAZ 3f
    JMP 4f
3:
    LDA mem_buff
    STO A+1 mem_buff
4:
# inc dest
    LDA dest+1
    LDA A+1
    STO A dest+1
    JAZ 5f
    JMP 6f
5:
    LDA dest
    STO A+1 dest
6:
    LDA mem_buff
    LCB $F0
    JNE erase_copy_loop
8:
# Have we copied everything (source > very_end)?
    LDA source
    LDB very_end
    JEQ 1f
    JHI 10f
    JMP 7f
1:
    LDA source+1
    LDB very_end+1
    JHI 10f
7:
# Copy next 4k to RAM
    LCA $E0
    STO A mem_buff
    STO 0 mem_buff+1
2:
    LDB source+1
    VAI source,B
    LDB mem_buff+1
    STI A mem_buff,B
# incr source
    LDA source+1
    LDA A+1
    STO A source+1
    JAZ 3f
    JMP 4f
# source carry
3:
    LDA source
    LDA A+1
    STO A source
    LCB $80
    JEQ erase_file_loop
# incr mem_buff
4:
    LDA mem_buff+1
    LDA A+1
    STO A mem_buff+1
    JAZ 5f
    JMP 2b
# mem_buff carry
5:
    LDA mem_buff
    LDA A+1
    STO A mem_buff
    LCB $F0
    JEQ erase_file_loop
    JMP 2b
10:
# Erase any blocks not yet erased
    LDA dest
    LDB very_end
    JEQ 5f
    JHI 11f
    JMP 6f
5:
    LDA dest+1
    LDB very_end+1
    JHI 11f
6:
    JSR erase_sector
# Add $1000 (4k) to dest
    LDA dest
    LCB $10
    STO A+B dest
    JMP 10b
11:
# print out 'file deleted'
    printstr(fdel)
    JMP prompt
9:
# print out 'file not found'
    printstr(fnf)
    JMP prompt

# Erase sector
# Input: dest - address in SSD of block to erase
erase_sector:
    LCA $AA
    STO A $5555
    LCA $55
    STO A $2AAA
    LCA $80
    STO A $5555
    LCA $AA
    STO A $5555
    LCA $55
    STO A $2AAA
    LCA $30
    LDB dest+1
    STI A dest,B
1:
    LDB dest+1
    VAI dest,B
    JAN 2f
    JMP 1b
2:
    RTS erase_sector

#####################
# Format file system
#####################
format_ssd:
    printstr(sure)
    JIU .
    INA
    LCB 'Y'
    JEQ 2f
    LCB 'y'
    JEQ 2f
    JMP 3f
2:
    STO 0 $F000
    LCA $AA
    STO A $5555
    LCA $55
    STO A $2AAA
    LCA $80
    STO A $5555
    LCA $AA
    STO A $5555
    LCA $55
    STO A $2AAA
    LCA $10
    STO A $5555
    printstr(formatted)
4:
    JMP prompt
3:
    printstr(abort)
    JMP 4b

#####################
# Save file command
#####################
# TODO: Check duplicate filename & if enough space in SSD before writing file
save_command:
    LDA partition
    STO A $F000
1:
    peek_cmd()
    JAZ 5f
    LCB ' '
    JNE 1f
    nxt_cmd()
    JMP 1b
# copy to filename variable
1:
    LCA filename
    STO A fn_ptr+1
2:
    nxt_cmd()
    LCB ' '
    JEQ 3f
    JAZ 4f
    LDB fn_ptr+1
    STO B+1 fn_ptr+1
    STO A filename,B
    JMP 2b
3:
    LDB fn_ptr+1
    STO 0 filename,B
# start of address
    JSR cmd2addr
    LDA addr
    STO A start_addr
    LDA addr+1
    STO A start_addr+1
# start of size
2:
    JSR cmd2addr
    LDA addr
    STO A size
    LDA addr+1
    STO A size+1
# Write the flipping file NOW!
    JSR write_file
    JMP prompt
4:
    printstr(abort)
    JMP prompt
5:
    # Auto save
    printstr(saved)
    # filename, size, addr
    LDA $F002
    STO A start_addr
    LDA $F003
    STO A start_addr+1
    LDA $F004
    STO A size
    LDA $F005
    STO A size+1

    LCB $06
    STO B source
    LCB filename
    STO B dest
6:
    LDB source
    LDA $F000,B
    JOUT(A)
    LDB B+1
    STO B source
    LDB dest
    STO A filename,B
    JAZ 7f
    JAN 7f
    LDB B+1
    STO B dest
    JMP 6b
7:
    JOUT('\n')
    JSR write_file
    JMP prompt

###############################
# Write file
# input: filename, size, start_addr
###############################
write_file:
# find end of file system
    STO 0 ptrA
    STO 0 ptrA+1
write_find_next:
    LDB ptrA+1
    VAI ptrA,B
    LCB $FF
    JEQ write_start
    JSR file_find_next
    JMP write_find_next
write_start:
### FOUND END OF FS ###
# write filename
# ptrA points to EEPROM address to write to
    LDA ptrA
    STO A dest
    LDA ptrA+1
    STO A dest+1
    LHA filename
    STO A source
    LCA filename
    STO A source+1
    LCA @20
    STO 0 length
    STO A length+1
    JSR write_data
#  dest SHOULD still be the correct address (start+20)
# write address
    LHA start_addr
    STO A source
    LCA start_addr
    STO A source+1
    LCA @2
    STO 0 length
    STO A length+1
    JSR write_data
# write size
    LHA size
    STO A source
    LCA size
    STO A source+1
    LCA @2
    STO 0 length
    STO A length+1
    JSR write_data
# write data
    LDA start_addr
    STO A source
    LDA start_addr+1
    STO A source+1
    LDA size
    STO A length
    LDA size+1
    STO A length+1
    JSR write_data

    RTS write_file

#######################################
# Write data from source to destination
# input: source, dest, length
#######################################
write_data:
1:
# Exit when length is $0000
    LDA length+1
    JAZ 8f
    JMP 9f
8:
    LDA length
    JAZ 2f
9:
    LCA $AA
    STO A $5555
    LCA $55
    STO A $2AAA
    LCA $A0
    STO A $5555
# (source) -> (dest)
    LIA source
    STO A char
    SIA dest

# Wait for write to complete
10:
    LDB dest+1
    VAI dest,B
    LDB char
    JNE 10b

# inc source
11:
    LDA source+1
    LDA A+1
    STO A source+1
    JAZ 3f
    JMP 4f
3:
    LDA source
    STO A+1 source
4:
# inc dest
    LDA dest+1
    LDA A+1
    STO A dest+1
    JAZ 5f
    JMP 6f
5:
    LDA dest
    STO A+1 dest
6:
# decrement length
    LDA length+1
    STO A-1 length+1
    JAZ 7f
    JMP 1b
7:
    LDA length
    STO A-1 length
# loop
    JMP 1b
2:
    RTS write_data

##################
# puts subroutine
##################
puts:
    LIA strptr		# Get character through the ptr
	JAZ 1f			# Exit when we get the NUL character
	JOU .			# Print out the character
	OUT A
	LDB strptr+1		# Increment the low byte of the pointer
	STO B+1 strptr+1
	JMP puts		# and loop back
1:	RTS puts


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
welcome: STR "[2J[HCSCvon8 Monitor, Revision: 3.00, 23/12/2022\nType ? for help\n\n"
usage:	 STR "Usage: D dump, V video dump, C change, R run, X clear/reset, ? help\n"
usage2:  STR "File system: L load, G go, S save, T table, E erase, F format\n"
setstr:	 STR "Enter space separated hex digits, end with Z\n\n"
PAG
part:   STR "Table "
inv_part: STR "Invalid Table - choose A-P\n"
cnr:    STR "Command not recognised\n"
bye:    STR "File system exited\n"
fnf:    STR "File not found\n"
fld:    STR "File loaded at $"
fdel:   STR "File deleted\n\n"
used:   STR "\nUsed "
bytes:  STR " Bytes\n"
sure:   STR "Are you sure? Y/N\n"
saved:  STR "Saved file "
formatted: STR "SSD formatted\n"
abort: STR "Command aborted\n"


	  ORG $FC00
__hex:  HEX "00"		# Place to store four hex chars, page aligned
__hex2: HEX "00"
__hex3: HEX "00"
__hex4: HEX "00"
strptr:	  HEX "00"		# String pointer for puts
	  HEX "00"
cmdchar:  HEX "00"		# Command character
hexcnt:	  HEX "00"		# Count of hex chars left to store
jmpaddr:  HEX "00"
addr:	  HEX "80"		# Address used by all commands
	  HEX "00"
count:	  HEX "00"		# 16-bit counter, used when loading a program
	  HEX "00"
digit:  BYTE
runaddr: HEX "70"
run_addr: WORD

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

__string: WORD          # Address of zero terminated string to print

__rand_seed: WORD       # Seed for RNG
__rand_seed0: WORD      # Seed 0 for RNG
rand_z:  WORD
rand_temp:  WORD

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
temp: BYTE
scroll_to: BYTE
scroll_from: BYTE

length: WORD
ptrA:   WORD
ptrB:   WORD
string: WORD
partition: BYTE
filename: BYTE @20
fn_ptr: BYTE
char:   BYTE
start:  WORD
end:    WORD
very_end: WORD
block:  WORD
mem_buff: WORD
ssd_save: WORD
dest:   WORD
source: WORD
start_addr: WORD
size: WORD

__number: BYTE @4 # 32-bit number
__num_str: BYTE @12 # String containing number in decimal
__num_ptr: BYTE # offset into __num_str that is start of string
PAG
command: BYTE @32
cmd_ptr: BYTE

# Temp store 4k of data when erasing blocks
data_buffer: EQU $E000

EXPORT sys_cli
EXPORT sys_cls

EXPORT sys_pchar
EXPORT sys_spchar

EXPORT sys_scroll
EXPORT sys_scroll4
EXPORT sys_scroll8

EXPORT __char
EXPORT __xpos
EXPORT __ypos
EXPORT __paper
EXPORT __ink

EXPORT __schar
EXPORT __sypos
EXPORT __sxpos
EXPORT __sink

EXPORT sys_phex
EXPORT __hex

EXPORT __string
EXPORT sys_pstring
EXPORT sys_spstring

EXPORT __rand_seed
EXPORT __rand_seed0
EXPORT sys_rand

EXPORT __number
EXPORT __num_str
EXPORT __num_ptr
EXPORT sys_num_str_32
EXPORT sys_num_str_16
EXPORT sys_num_str_8
