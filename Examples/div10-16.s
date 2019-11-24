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
    LDB     num+1

    JMP     $FFFF

num:    EQU $f000
