# Draw lines using Bresenham's algorithm
# David Clifford Nov 2020
start:
    STO 0 __paper
    JSR sys_cls sys_cls_ret

    JSR sys_rand sys_rand_ret
    LDA __rand_seed
    LCB @160
    STO A%B x0
    LDA __rand_seed+1
    LCB @120
    STO A%B y0
1:
    JSR sys_rand sys_rand_ret
# ink
    LDA __rand_seed
    LCB $3F
    STO A&B ink

    JSR sys_rand sys_rand_ret
    LDA __rand_seed
    LCB @160
    STO A%B x1
    LDA __rand_seed+1
    LCB @120
    STO A%B y1
#    JSR sys_cls sys_cls_ret

    JSR draw_line
    JIU 1b
    INA
    LCB 'q'
    JEQ sys_cli
    LCB ' '
    JEQ start
    JMP 1b

    # dx = x1 - x0
    # dy = y1 - y0
    # sx = 1 if dx > 0 else -1
    # sy = 1 if dy > 0 else -1
    # dx = abs(dx)
    # dy = abs(dy)
    # is dx >= dy:
    #     l = dy
    #     h = dx
    #     tx = sx
    #     ty = 0
    # otherwise
    #     l = dx
    #     h = dy
    #     tx = 0
    #     ty = sy
    # i = int(h/2)
    # for n in range(h+1):
    #     plot(x0, y0, c)
    #     j = i
    #     i = (i + l) % 256
    #     is j > 255 or i >= h:
    #         i = (i - h) % 256
    #         x0 += sx
    #         y0 += sy
    #     otherwise
    #         x0 += tx
    #         y0 += ty

draw_line:
# is x0 < x1 ? dx = abs(x0 - x1)
    LDA x0
    LDB x1
    JLO 1f
    STO A-B dx
    LCA $FF
    STO A sx
    JMP 2f
1:
    STO B-A dx
    LCA @1
    STO A sx
2:
# is y0 < y1 ? dy = abs(y0 - y1)
    LDA y0
    LDB y1
    JLO 1f
    STO A-B dy
    LCA $FF
    STO A sy
    JMP 2f
1:
    STO B-A dy
    LCA @1
    STO A sy
2:
# is dx < dy ?
    LDA dx
    LDB dy
    JLO 1f
    #     l = dy
    #     h = dx
    #     tx = sx
    #     ty = 0
    LDA dy
    STO A l
    LDA dx
    STO A h
    LDA sx
    STO A tx
    STO 0 ty
    JMP 2f
1:
    #     l = dx
    #     h = dy
    #     tx = 0
    #     ty = sy
    LDA dx
    STO A l
    LDA dy
    STO A h
    STO 0 tx
    LDA sy
    STO A ty
2:
    # i = int(h/2)
    LDA h
    LCB @1
    STO A>>B i
    # n = h
    STO A n

draw_loop:
    # plot(x0, y0, c)
    LDB x0
    LDA ink
    STI A y0,B

    # n -= 1 : is n==0 then stop
    LDA n
    STO A-1 n
    JAZ draw_fin

    #     i += l (el)
    LDA i
    LDB l
    TST A+B JC 2f
    LDA A+B
    STO A i

    #     is i >= h
    LDB h
    JLO 1f

    #         i = (i - h)
    STO A-B i

    #         x0 += sx
    #         y0 += sy
3:
    LDA x0
    LDB sx
    STO A+B x0
    LDA y0
    LDB sy
    STO A+B y0

    JMP draw_loop
2:
    # i += l
    # i -= h
    LDA A+B
    LDB h
    STO A-B i
    JMP 3b

    # otherwise
    #         x0 += tx
    #         y0 += ty
1:
    LDA x0
    LDB tx
    STO A+B x0
    LDA y0
    LDB ty
    STO A+B y0
    JMP draw_loop

draw_fin:
    RTS draw_line

#PAG

x0: BYTE
y0: BYTE
x1: BYTE
y1: BYTE
i:  BYTE
n:  BYTE
l:  BYTE
h:  BYTE
dx: BYTE
dy: BYTE
sx: BYTE
sy: BYTE
tx: BYTE
ty: BYTE
ink: BYTE
#include "monitor.h"