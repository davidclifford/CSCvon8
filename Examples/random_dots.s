# Plot random dots in 'high' resolution'

    STO 0 x
    STO 0 x+1
    STO 0 y
1:
    JSR sys_rand sys_rand_ret
    LDA __rand_seed
    LCB @5
    LDA A%B
    JAZ 2f

    STO 0 x
    LDA __rand_seed+1
    STO A x+1
    JMP 3f
2:
    LCA @1
    STO A x
    LDA __rand_seed+1
    LCB @64
    STO A%B x+1
3:
    JSR sys_rand sys_rand_ret
    LDA __rand_seed
    LCB @240
    STO A%B y

#    JSR sys_rand sys_rand_ret
#    LDA __rand_seed
#    LCB @4
#    LDA A>>B
#    LDA A<<B
#    LCB $80
#    STO A|B col
    LCA $C0
    STO A col

    JSR plot

#######
    JSR sys_rand sys_rand_ret
    LDA __rand_seed
    LCB @5
    LDA A%B
    JAZ 2f

    STO 0 x
    LDA __rand_seed+1
    STO A x+1
    JMP 3f
2:
    LCA @1
    STO A x
    LDA __rand_seed+1
    LCB @64
    STO A%B x+1
3:
    JSR sys_rand sys_rand_ret
    LDA __rand_seed
    LCB @240
    STO A%B y

#    JSR sys_rand sys_rand_ret
#    LDA __rand_seed
#    LCB @4
#    LDA A>>B
#    LDA A<<B
#    LCB $80
#    STO A|B col
    LCA $C0
    STO A col

    JSR unplot

    JMP 1b

    JMP sys_cli

########
plot:
    # divide x by 2
    LDA x+1
    LCB @2
    STO A/B nx
    STO A%B ix
    LDA x
    LCB @7
    LDA A<<B
    LDB nx
    STO A|B nx

    # divide y by 2
    LDA y
    LCB @2
    STO A/B ny
    STO A%B iy

    # work out sub-pixel
    LDB ix
    LCA @1
    STO A-B sub
    LDA iy
    LCB @2
    LDB A*B
    LDA sub
    LDB A+B
    LCA @1
    STO A<<B sub

    # plot it
    LDB nx
    VAI ny,B
    LCB $0F
    LDA A&B
    LDB sub
    LDA A|B
    LDB col
    LDA A|B
    LDB nx
    STI A ny,B

    RTS plot

unplot:
    # divide x by 2
    LDA x+1
    LCB @2
    STO A/B nx
    STO A%B ix
    LDA x
    LCB @7
    LDA A<<B
    LDB nx
    STO A|B nx

    # divide y by 2
    LDA y
    LCB @2
    STO A/B ny
    STO A%B iy

    # work out sub-pixel
    LDB ix
    LCA @1
    STO A-B sub
    LDA iy
    LCB @2
    LDB A*B
    LDA sub
    LDB A+B
    LCA @1
    LDA A<<B
    STO !A sub

    # unplot it
    LDB nx
    VAI ny,B
    LCB $0F
    LDA A&B
    LDB sub
    LDA A&B
    LDB col
    LDA A|B
    LDB nx
    STI A ny,B

    RTS unplot

x:  WORD
y:  BYTE

nx: BYTE
ny: BYTE
ix: BYTE
iy: BYTE
sub: BYTE
col: BYTE

#include "monitor.h"

