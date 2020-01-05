#
# Clear screen. Using indirect addressing
#
cls:
    STO 0 vidaddr
    STO 0 vidaddr+1
1:
    LCA $00
    SIA vidaddr
    LDA vidaddr+1
    STO A+1 vidaddr+1
    LCB $FE
    JNE 1b

# Next line
    STO 0 vidaddr+1
    LDA vidaddr
    STO A+1 vidaddr
    LCB $77
    JNE 1b

end:
	JMP $FFFF

vidaddr: EQU $FF0C
