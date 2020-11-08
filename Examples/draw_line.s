# Draw lines using Bresenham's algorithm
# David Clifford Nov 2020

# x0, y0
    LCA $7f
    STO A x0
    LCA $00
    STO A y0

# x1, y1
    LCA $80
    STO A x1
    LCA $00
    STO A y1

# is x0 < x1 ?
    STO 0 dx
    LCA $01
    STO A sx
    LDA x0
    LDB x1
    JLO 1f
    STO A-B dx+1
    LCA $FF
    STO A sx
    JMP 2f
1:
    STO B-A dx
2:
# is y0 < y1 ?
    STO 0 dy
    LCA $01
    STO A sy
    LDA y0
    LDB y1
    JLO 1f
    STO A-B dy+1
    LCA $FF
    STO A sy
    JMP 2f
1:
    STO B-A dy
2:
# dy = -dy
    LDA dy
    STO -A dy
    LDA dy+1
    STO -A dy+1

    STO 0 err
    LDA dx
    LDB dy
    STO A+B err+1
    TST A+B JC 1f
    JMP 2f
1:
    LCA $01
    STO err
2:
end:
    JMP $FFFF

x0: BYTE
y0: BYTE
x1: BYTE
y1: BYTE
dx: WORD
dy: WORD
sx: BYTE
sy: BYTE
err: WORD
e2: WORD

#include "monitor.h"