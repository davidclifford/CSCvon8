#
# Divide a 16-bit unsigned number by 10
#
#define OUT(x)	     JOU .; OUT x

    LCA     $00
    LCB     $01
    STO     A num
    STO     B num+1
start:
    LDA     num
    LDB     $99
    STO     A*B mul1
    STO     A*BHI mul2

    LDA     num+1
    LDB     $19
    STO     A*B mul3
    STO     A*BHI mul4

    JMP     $FFFF

num:    EQU $f000
mul1:   EQU $f002
mul2:   EQU $f003
mul3:   EQU $f004
mul4:   EQU $f005
