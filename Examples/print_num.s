# First testing program
#
start:  LCA $FF
    STO 0 i
    STO A num
loop:   LDA num
    JAZ print
    LCB $0a
    STO num A/B
    LDA A%B
    LCB '0'
    LDA A+B
    LDB i
    STO A str,B
    STO i B+1
    JMP loop
print:  LDB i
next:   LDB B-1
    LDA str,B
    OUT A
    JBZ end
    JMP next
end:    OUT $0A
    JMP .

str:    EQU $F000
num:    EQU $F008
i:      EQU $F00A


