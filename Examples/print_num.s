#
# Output num as an unsigned decimal string
#
#define OUT(x)	     JOU .; OUT x

start:
    LCA @0
    STO A count
go: LDA count
    STO count A+1
    STO num A+1
    JSR print_num
    OUT(' ')
    JMP go
    JMP $ffff

print_num:
    STO i 0
    LCA '0'
    STO str A
    LCB @1
    LDA num
    JAZ 2f
1:
    LDA num
    JAZ 4f
    LCB $0a
    STO num A/B
    LDA A%B
    LCB '0'
    LDA A+B
    LDB i
    STO A str,B
    STO i B+1
    JMP 1b
4:
    LDB i
2:
    LDB B-1
    LDA str,B
    OUT(A)
    JBZ 3f
    JMP 2b
3:
    RTS print_num

str:    EQU $F000
count:  EQU $F006
num:    EQU $F008
i:      EQU $F00A