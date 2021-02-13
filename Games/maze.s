# Maze Generator
# David Clifford Feb 2021
#
start:
# Clear screen
#    STO 0 __paper
#    JSR sys_cls sys_cls_ret

# Maze is 16 x 16
# Empty maze
    LDB 0
1:
    STO 0 maze,B
    LDB B+1
    JBZ 2f
    JMP 1b
2:
    STO 0 x
    STO 0 y
    STO 0 sp

# Recursively fill maze
4:
    # c = 0
    STO 0 c
    # for i=0 to 3
    STO 0 i
1:
    #   xx = x + dx[i]
    LDA i
    LCB dx
    LDB A+B
    LDA dx,B
    LDB x
    LDA A+B
    STO A xx
    #   yy = y + dy[i]
    LDA i
    LCB dy
    LDB A+B
    LDA dy,B
    LDB y
    LDA A+B
    STO A yy
    #   when xx >= 0 and xx < 16 and yy >=0 and yy < 16
    LCB @15
    JHI 2f
    LDA xx
    JHI 2f
    #     when maze[xx + yy*16] == 0
    LCB @16
    LDA yy
    LDA A*B
    LDB xx
    LDB A+B
    LDA maze,B
    JAZ 3f
    JMP 2f
3:
    #       choice[c] = i
    LDA c
    LCB choice
    LDB A+B
    LDA i
    STO A choice,B
    #       c++
    LDA c
    STO A+1 c
2:
    # next i
    LDA i
    STO A+1 i
    LCB @3
    JLO 1b

    # when c != 0
    LDA c
    JAZ 3f

    #   xs[sp] = x
    LDB sp
    LDA x
    STO A xs,B
    #   ys[sp] = y
    LDA y
    STO A ys,B
    #   sp++
    LDA sp
    STO A+1 sp

    #   r = rand(c) ## r = 0..(c-1)
    JSR sys_rand sys_rand_ret
    LDA __rand_seed
    LDB c
    LDB A%B
    #   c = choice[r]
    LCA choice
    LDB A+B
    LDB choice,B
    STO B c

    #   d = 1 << c
    LCA @1
    LDA A<<B
    STO A d

    #   maze[x+y*16] |= d
    LCB @16
    LDA y
    LDB A*B
    LDA x
    LDB A+B
    STO B addr
    LDA maze,B
    LDB d
    LDA A|B
    LDB addr
    STO A maze,B

    #   xx = dx[c]
    LCA dx
    LDB c
    LDB A+B
    LDA dx,B
    STO A xx
    #   yy = dy[c]
    LCA dy
    LDB c
    LDB A+B
    LDA dy,B
    STO A yy
    #   y = y + yy
    LDB y
    STO A+B y
    #   x = x + xx
    LDA xx
    LDB x
    STO A+B x
    #   d = 1 << ((c+2)%4)
    LDA c
    LDA A+1
    LDA A+1
    LCB @4
    LDB A%B
    LCA @1
    LDA A<<B
    STO A d
    #   maze[x+y*16] |= d
    LCB @16
    LDA y
    LDB A*B
    LDA x
    LDB A+B
    STO B addr
    LDA maze,B
    LDB d
    LDA A|B
    LDB addr
    STO A maze,B

    JMP 4b
    # otherwise
3:
    #   sp--
    LDB sp
    LDB B-1
    STO B sp
    #   when sp == 0
    JBZ 2f
    #      break
    #   x = xs[sp]
    LDA xs,B
    STO A x
    #   y = ys[sp]
    LDA ys,B
    STO A y

    # goto next
    JMP 4b
2:
# Return to OS
    JMP sys_cli

PAG
choice: BYTE @4
# Directions = N E S W
x:  BYTE
y:  BYTE
c:  BYTE
d:  BYTE
i:  BYTE
sp: BYTE
xx: BYTE
yy: BYTE
addr: BYTE
dx: HEX "00 01 00 FF"
dy: HEX "FF 00 01 00"
PAG
maze: BYTE
PAG
xs: BYTE
PAG
ys: BYTE

# System variables
#include "../Examples/monitor.h"
