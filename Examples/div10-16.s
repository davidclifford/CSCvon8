#
# Divide a 16-bit unsigned number by 10
#

#define OUT(x)	     JOU .; OUT x

    LCA     @255
    STO     A num
div10:
    STO     0 rem
div10next:
    LCB     $07
    STO     B cnt

2:
    LCB     $02
    LDA     num
    STO     A*B num   # num*2
    STO     A*BHI ovfl
    LDA     rem
    LDA     A*B rem
    LDB     ovfl
    LDA     A+B
    STO     A rem
    LCB     $0A         # if rem < 10 skip
    JLT     1f
    STO     A-B rem     # sub 10 from rem
    LDA     num
    STO     A+1 num     # add 1 to num
1:
    LDA     cnt
    JAZ     print
    STO     A-1 cnt
    JMP     2b

# Print out num and rem in hex
print:
    LDA     num
    STO     A hexchar
    JSR     prhex prhex_ret
    OUT     (' ')
    LDA     rem
    STO     A hexchar
    JSR     prhex prhex_ret
    OUT     ('\n')

# Back to command prompt

    JMP     prompt

num:    HEX "0B"
rem:    HEX "00"
ovfl:   HEX "00"
cnt:    HEX "08"

hexchar: EQU $FD00
prhex:   EQU $0279
prhex_ret:EQU $FFF8
prompt:  EQU $001f