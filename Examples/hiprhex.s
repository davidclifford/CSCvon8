	JSR main
end:	JMP $FFFF

main:
main.i:	EQU $8000
	LCA $00			# main.i = 0
	STO A main.i
L0:			# main.i >= 100
	LDA main.i
	LCB $64
	JGE L1
	LDA main.i		# prhexn main.i high nibble
	LCB $04
	LDA A>>B
	LCB $09
	JGT L2
	LCB $30
	JMP L3
L2:	LCB $37
L3:	LDA A+B
	OUT A
	JOU .
	LDA main.i		# prhexn main.i low nibble
	LCB $0F
	LDA A&B
	LCB $09
	JGT L4
	LCB $30
	JMP L5
L4:	LCB $37
L5:	LDA A+B
	OUT A
	JOU .
	LCA $0A
	OUT A
	JOU .
	LDA main.i
	LDA A+1
	STO A main.i
	JMP L0
L1:
end:	JMP $FFFF
	RTS main		# return
