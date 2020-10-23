	JSR main
end:	JMP end

newline:
	LCA $0a		# putchar 10
	OUT A
	JOU .
	RTS newline		# return

starline:
starline.count:	EQU $8000
starline.x:	EQU $8001
	LCA $01			# starline.x = 1
	STO A starline.x
L0:			# starline.x >= count
	LDA starline.x
	LDB starline.count
	JGE L1
	LCA $2a		# putchar 42
	OUT A
	JOU .
	LDA starline.x
	LDA A+1
	STO A starline.x
	JMP L0
L1:
			# Call newline
	JSR newline
	RTS starline		# return

main:
main.start:	EQU $8002
main.end:	EQU $8003
	LCA $01			# main.start = 1
	STO A main.start
L2:			# main.start >= 70
	LDA main.start
	LCB $46
	JGE L3
			# Call starline
	LDA main.start
	STO A starline.count
	JSR starline
	LDA main.start
	LDA A+1
	STO A main.start
	JMP L2
L3:
end:	JMP end
	RTS main		# return
