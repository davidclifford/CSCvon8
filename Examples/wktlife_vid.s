# Conway's Game of Life for the CSCvon8 CPU.
# (c) 2019 Warren Toomey, GPL3
#
# We have a board of 32 rows by 128 columns. The edges are set to zero.
# We iterate across rows 1 to 31, and columns 1 to 127 within eah row.
# For some efficiency, we keep a cache of the sum of the three neighbours
# to our right and to our left; there is also a cache of our cell's value
# and the sum of the two neighbours above and below us. As we walk right
# along a row, these cache values get propagated down.
#
# Also for efficiency, we self-modify the addresses of the three rows
# that we are working on each time through the row loop. The 32 rows live
# in memory at $D000, $D100, $D200 ... $EE00, $EF00. Each row only uses
# the offset values $00 to $7F to have 128 columns.
#
# We modify the RAM version of the midcell with its new value. Therefore,
# we need to keep copies of the original mid row and the row above us
# to get our calculations right.
#
#define JOUT(x)	JOU .; OUT x

# Variables
rightsum:	EQU $F000		# Sum of 3 neighbours to our right
leftsum:	EQU $F001		# Sum of 3 neighbours to our left
midsum:		EQU $F002		# Sum of neighbours above/below us
rightcell:	EQU $F003		# Copy of cell to our right
toprightcell:	EQU $F004		# Copy of cell to our top-right
botrightcell:	EQU $F005		# Copy of cell to our bot-right
midcell:	EQU $F006		# Cached copy of our cell value
row:		EQU $F007		# Current row number: $D0 .. $EF
col:		EQU $F008		# Current column number: $00 .. $7F
cell:       EQU $F009       # Current cell colour
seed:       EQU $F00A       # random number
seed2:      EQU $F00B

midrowcache:	EQU $9F00		# Cache of the previous mid row
toprowcache:	EQU $9E00		# Cache of the previous top row

#
# Clear screen.
#
	STO 0 cls+1
1:
	LDA @160
	LDB $00
cls:
    STO 0 $0000,B
	LDB B+1
	JNE cls
    LDB cls+1
    STO B+1 cls+1
    LCA @120
    JNE 1b

# Initialisation. Zero both cached rows and the board. Use
# self-modifying code to do this.
		LHA toprowcache		# A is the row hi-byte
1:		LCB $00			# B is the index
sm1:	STO 0 toprowcache,B
		LDB B+1			# Increment B and loop
		JBN 2f			# while we are below $80
		JMP sm1
2:		LDA A+1			# Move up to the next row
		STO A sm1+1
		LCB $F1			# Stop when we get past the
		JNE 1b			# last row

# Set up an r-pentomino pattern in the centre of the board
		LCA $01
		STO A $C040
		STO A $C041
		STO A $C13F
		STO A $C140
		STO A $C240

# Add some random stuff
        STO 0 row
1:
        JSR random
        LDA seed
        LCB $7F
        STO A&B col
        JSR random
        LDA seed
        LCB $20
        LDA A%B
        LCB $A0
        STO A+B plot+1
        LDB col
        LCA $01
plot:
        STO A $A000,B
        LDA row
        LDA A-1
        JAZ firstrow
        STO A row
        JMP 1b

# Do some set up before we can start work on the first row
# Set up row below us and column we are in.
firstrow:	LCA $01
		STO A col
		LCA $A2
		STO A row

# Clear the two row caches
		LCB $00			# B is the index
		LCA $80			# A is the exit value
1:		STO 0 toprowcache,B
		STO 0 midrowcache,B
		LDB B+1			# Increment B and loop
		JNE 1b			# while we are below $80

# Self-modify all the row addresses used in the loop below
		LCA $A1; STO A sm6+1
		LCA $A2; STO A sm5+1

# Set up the left and mid sum to zero, and our cell value to zero
firstcolumn:	LCA $00
		STO A leftsum
		STO A midsum
		STO A midcell

# Get the three cells to our right. Also update the
# cached row values
columloop:	LDB col
		LDB B+1
		LDA toprowcache,B
		STO A toprightcell
		LDA midrowcache,B
		STO A rightcell; STO A toprowcache,B
sm5:		LDA $A200,B
		STO A botrightcell; STO A midrowcache,B

# Add them to get the three neighbour sum to our right
		LDB rightcell
		LDA A+B
		LDB toprightcell
		STO A+B rightsum

# Add up the neighbours and apply the rules of Conway's Game of Life
calccell:	LDA leftsum
		LDB midsum
		LDA A+B
		LDB rightsum
		LDA A+B			# A has the sum of neighbours
		LCB $01
		JLE deadcell		# 0 or 1 neighbours, dead
		LCB $04
		JGE deadcell		# 4 or more neighbours, dead
		LCB $03
		JEQ livecell		# 3 neighbours, cell is alive
samecell:	LDA midcell		# Otherwise, same cell value as before
		JMP updatecell

deadcell:	LCA $00; JMP updatecell

livecell:	LCA $01

updatecell:	LDB col
sm6:		STO A $A100,B		# Update the actual cell in RAM

		LCB $01
		JEQ pralive		# Print either '@' or '.'
prdead:
        LCA $03 # Blue
        JMP 1f
pralive:
        LCA $3C # Yellow
1:
        STO A cell
# Output to video memory
        LDB row
        LCA $A0
        STO B-A vid+1
        LDB col
        LDA cell
vid:    STO A $0000,B

# Now move up to the next column. Break out of the loop when we hit $80
		LDB col
		STO B+1 col
		LCA $80
		JEQ rowsend

# Before we loop back, copy the midsum+midcell to leftsum.
		LDA midsum
		LDB midcell
		STO A+B leftsum

# Copy rightsum-rightcell to midsum.
		LDA rightsum
		LDB rightcell
		STO A-B midsum

# Copy rightcell to midcell and loop back
		STO B midcell
		JMP columloop

# We've reached the end of a row, move down a line
rowsend:

# Increment the row. If this is the last row, skip some
# code to deal with that fact
# the first row.
		LDB row
		LCA $F0
		JEQ firstrow
		STO B+1 row

# Ripple down the row values and start on the first column of the next row
		LDA sm5+1; STO A sm6+1
		LDA row; STO A sm5+1
		LCA $01
        STO A col
		JMP firstcolumn

random:
    LDA seed
    LDA A+1             # seed+1
    LCB @33
    STO A*BHI seed2    # (seed+1)*33
    LDA A*B
    LDB seed2
    TST A-B JC 1f
    STO A-B-1 seed
    JMP 2f
1:
    LDA A-B
    STO A seed
    LCB $ff
    JNE 2f
    LCA @223 # Hack
    STO A seed
2:
    RTS random