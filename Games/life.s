# Life for the CSCvon8
# By David Clifford Oct 2020
#
    NAME "life"
start:
    STO 0 __paper
    JSR sys_cls sys_cls_ret
    LDA 0
    STO A+1 x
    STO A+1 y
1:
    JSR sys_rand sys_rand_ret
# y
    LDA __rand_seed
    LCB @8
    LDA A%B
    JAZ 3f
2:
    LDA x
    STO A+1 x
    LCB @158
    JLO 1b
    LDA 0
    STO A+1 x
    LDA y
    STO A+1 y
    LCB @118
    JLO 1b
    JMP 4f
3:
    LCA $3F
    LDB x
    STI A y,B
    JMP 2b
4:
# Do life
next_gen:
    LCB @1
    STO B x
    LCA @1
    STO A y
# count around
next_cell:
    LDB x
    VAI y,B
    STO A cell
    STO 0 count
    LDA y
    STO A-1 ny
    LDB x
    LDB B-1
    VAI ny,B
    LCB $3F
    LDA A&B
    JAZ 1f
    LDA count
    STO A+1 count
1:
    LDA y
    STO A-1 ny
    LDB x
    VAI ny,B
    LCB $3F
    LDA A&B
    JAZ 2f
    LDA count
    STO A+1 count
2:
    LDA y
    STO A-1 ny
    LDB x
    LDB B+1
    VAI ny,B
    LCB $3F
    LDA A&B
    JAZ 3f
    LDA count
    STO A+1 count
3:
    LDB x
    LDB B-1
    VAI y,B
    LCB $3F
    LDA A&B
    JAZ 4f
    LDA count
    STO A+1 count
4:
    LDB x
    LDB B+1
    VAI y,B
    LCB $3F
    LDA A&B
    JAZ 5f
    LDA count
    STO A+1 count
5:
    LDA y
    STO A+1 ny
    LDB x
    LDB B-1
    VAI ny,B
    LCB $3F
    LDA A&B
    JAZ 6f
    LDA count
    STO A+1 count
6:
    LDA y
    STO A+1 ny
    LDB x
    VAI ny,B
    LCB $3F
    LDA A&B
    JAZ 7f
    LDA count
    STO A+1 count
7:
    LDA y
    STO A+1 ny
    LDB x
    LDB B+1
    VAI ny,B
    LCB $3F
    LDA A&B
    JAZ 8f
    LDA count
    STO A+1 count
8:
# Got count!
#    LDB count
#    LCA '0'
#    LDA A+B
#    OUT A
# < 2 DIE
    LDA count
    LCB @2
    JLT die
# = 2 SAME
    LCB @3
    JLT next
# = 3 LIVE
    JEQ live
die:
    LDA cell
    JAZ next
    LCA $7f
    LDB x
    STI A y,B
    JMP next
live:
    LDA cell
    JAZ born
    JMP next
born:
    LCA $40
    LDB x
    STI A y,B
# Next x,y
next:
    LDA x
    STO A+1 x
    LCB @158
    JNE next_cell
1:
#    OUT '\n'
    LCA @1
    STO A x
    LDA y
    STO A+1 y
    LCB @118
    JNE next_cell
#    OUT '\n'

# Second Pass
    LCA @1
    STO A y
4:
    LCA @1
    STO A x
1:
    LDB x
    VAI y,B
    LCB $40
    JEQ 2f
    LCB $7f
    JNE 3f
    LDB x
    STI 0 y,B
    JMP 3f
2:
    LDB x
    LCA $3f
    STI A y,B
3:
    LDA x
    STO A+1 x
    LCB @158
    JNE 1b

    LDA y
    STO A+1 y
    LCB @118
    JNE 4b

    JIU next_gen
    INA
    LCB 'q'
    JEQ exit_game
    LCB ' '
    JEQ start
    JMP next_gen

exit_game:
    JMP sys_cli

x: BYTE
y: BYTE
ny: BYTE
count: WORD
cell: BYTE

# System variables
#include "../Examples/monitor.h"
