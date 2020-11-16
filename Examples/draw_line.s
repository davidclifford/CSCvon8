# Draw lines using Bresenham's algorithm
# David Clifford Nov 2020

1:
    JSR sys_rand sys_rand_ret
# ink
    LDA __rand_seed
    LCB $3F
    STO A&B ink

    JSR sys_rand sys_rand_ret
    LDA __rand_seed
    LCB @160
    STO A%B x0
    LDA __rand_seed+1
    STO A%B x1

    JSR sys_rand sys_rand_ret
    LDA __rand_seed
    LCB @120
    STO A%B y0
    LDA __rand_seed+1
    STO A%B y1


    JSR draw_line

    JMP 1b

draw_line:
# is x0 < x1 ? dx = abs(x0 - x1)
    LDA x0
    LDB x1
    JLO 1f
    STO A-B dx
    JMP 2f
1:
    STO B-A dx
2:
# is y0 < y1 ? dy = abs(y0 - y1)
    LDA y0
    LDB y1
    JLO 1f
    STO A-B dy
    JMP 2f
1:
    STO B-A dy
2:
# is dx < dy ?
    LDA dx
    LDB dy
    LDA A|B
    JAZ 1f
    LDA dx
    JLO go_hi
    JMP go_low
1:
    RTS draw_line
go_hi:
    # dx = x1 - x0
    # dy = y1 - y0
    # sx = 1
    # is dx < 0
    #     sx = -1
    #     dx = -dx
    # d = int(dy/2)
    # x = x0
    # y = y0
    # while y <= y1
    #     plot(x, y, c)
    #     y += 1
    #     d -= dx
    #     is d < 0
    #         d += dy
    #         x = x + sx

    # is y0 > y1
    LDA y0
    LDB y1
    JHI 1f
    JMP 2f
1:
    # swap x0,x1 and y0,y1
    LDB x0
    LDA x1
    STO A x0
    STO B x1
    LDB y0
    LDA y1
    STO A y0
    STO B y1
2:
    # sx = sgn(x1 - x0)
    LCA @1
    STO A sx
    LDA x0
    LDB x1
    JLO 1f
    LCA $FF
    STO A sx
1:
    # d = d/2
    LCB @1
    LDA dy
    STO A>>B d
3:
    # While y0 <= y1
    LDA y0
    LDB y1
    JHI 1f

    # plot x0, y0
    LDB x0
    LDA ink
    STI A y0,B

    # y0 += 1
    LDA y0
    STO A+1 y0

    # d = d - dx
    LDA d
    LDB dx
    LDA A-B
    STO A d
    # is d<0
    JAN 2f
    # end while
    JMP 3b
2:
    # d = d + dy
    LDA d
    LDB dy
    STO A+B d
    # x = x + sx
    LDA x0
    LDB sx
    STO A+B x0
    # end while
    JMP 3b
1:
    RTS draw_line

go_low:
    # dx = x1 - x0
    # dy = y1 - y0
    # sy = 1
    # is dy < 0
    #     sy = -1
    #     dy = -dy
    # d = int(dx/2)
    # x = x0
    # y = y0
    # while x0 <= x1
    #     plot(x0, y0, ink)
    #     x0 += 1
    #     d -= yx
    #     is d < 0
    #         d += dx
    #         y0 = y0 + sy

    # is x0 > x1
    LDA x0
    LDB x1
    JHI 1f
    JMP 2f
1:
    # swap x0,x1 and y0,y1
    LDB x0
    LDA x1
    STO A x0
    STO B x1
    LDB y0
    LDA y1
    STO A y0
    STO B y1
2:
    # sy = sgn(y1 - y0)
    LCA @1
    STO A sy
    LDA y0
    LDB y1
    JLO 1f
    LCA $FF
    STO A sy
1:
    # d = d/2
    LCB @1
    LDA dy
    STO A>>B d
3:
    # While x0 <= x1
    LDA x0
    LDB x1
    JHI 1f

    # plot x0, y0
    LDB x0
    LDA ink
    STI A y0,B

    # x0 += 1
    LDA x0
    STO A+1 x0

    # d = d - dy
    LDA d
    LDB dy
    LDA A-B
    STO A d
    # is d<0
    JAN 2f
    # end while
    JMP 3b
2:
    # d = d + dx
    LDA d
    LDB dx
    STO A+B d
    # y0 = y0 + sy
    LDA y0
    LDB sy
    STO A+B y0
    # end while
    JMP 3b
1:
    RTS draw_line

PAG

x0: BYTE
y0: BYTE
x1: BYTE
y1: BYTE
d:  BYTE
dx: BYTE
dy: BYTE
sx: BYTE
sy: BYTE
ink: BYTE
#include "monitor.h"