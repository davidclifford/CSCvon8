#
# Clear screen. Self modifying code, must be in RAM
#
	STO 0 vid+1
loop:
	LDA 0
	LDB 0
vid:
    STO A $0000,B
	LDB B+1
	JBZ next
	JMP vid
next:
    LDA vid+1
    STO A+1 vid+1
    LCB $7F
    JLT loop

end:	JMP $FFFF
