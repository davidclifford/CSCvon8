    LDA __rand_seed
    LDB __rand_seed+1
    LDA A|B
    LDB __rand_seed0
    LDA A|B
    LDB __rand_seed0+1
    LDA A|B
    JAZ 1f
    JMP start
1:
    STO A+1 __rand_seed0+1
    JMP start

# Init seeds
# X
    LCA $45
    STO A __rand_seed0
    LCA $32
    STO A __rand_seed0+1
# Y
    LCA $A5
    STO A __rand_seed
    LCA $BC
    STO A __rand_seed+1

start:
    STO 0 yc
    STO 0 xc
loop:
# plot
    JSR sys_rand sys_rand_ret
    LDA __rand_seed
    LCB @2
    LDA A>>B
    LDB xc

# plot pixel
    STI A yc,B

    LDA xc
    LCB @160
    JEQ 1f
    STO A+1 xc
    JMP loop
1:
    STO 0 xc
    LDA yc
    LCB @120
    JEQ 1f
    STO A+1 yc
    JMP loop
1:
    JMP sys_cli


yc: BYTE
xc: BYTE

#include "monitor.h"
