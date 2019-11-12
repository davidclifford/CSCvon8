	JSR main
end:	JMP $FFFF

main:
main.x:	EQU $8000
main.y:	EQU $8001
main.i:	EQU $8002
main.tmp:	EQU $8003
	LCA $3a			# main.x = 58
	STO A main.x
	LCA $00			# main.y = 0
	STO A main.y
L0:			# while (1)
	LDA main.x		# main.tmp= main.x >> 4
	LCB $04
	LDA A>>BA
	STO A main.tmp
	LDA main.y			# main.y = main.y - tmp
	LDB main.tmp
	LDA A-B
	STO A main.y
	LDA main.y		# main.tmp= main.y >> 4
	LCB $04
	LDA A>>BA
	STO A main.tmp
	LDA main.x			# main.x = main.x + tmp
	LDB main.tmp
	LDA A+B
	STO A main.x
	LCA $00			# main.i = 0
	STO A main.i
	LDA main.x			# main.tmp = main.x + 59
	LCB $3b
	LDA A+B
	STO A main.tmp
L2:			# main.i >= tmp
	LDA main.i
	LDB main.tmp
	JGE L3
	LCA $20		# putchar 32
	OUT A
	JOU .
	LDA main.i
	LDA A+1
	STO A main.i
	JMP L2
L3:
	LCA $2a		# putchar 42
	OUT A
	JOU .
	LCA $0a		# putchar 10
	OUT A
	JOU .
	JMP L0
L1:
	RTS main		# return
