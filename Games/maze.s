# Maze Generator
# David Clifford Feb 2021
#

#define GRID_SIZE @6
#define GRID_SIZE2 @3
#define GRID_COLOUR $30
#define GRID_X @4
#define GRID_Y @4

#define NORTH @1
#define EAST @2
#define SOUTH @4
#define WEST @8

#define INPUT JIU .; INA

start:
# Clear screen
    STO 0 __paper
    JSR sys_cls sys_cls_ret

#########################
# Generate Maze 16 x 16 #
#########################
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

    #   r = rand(c)
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
    ##STO A yy
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
#############
# Draw Maze #
#############

    # Cells  x & y are top left coords
    # Draw border top and left
    LCA GRID_SIZE
    LCB @16
    STO A*B wid
    # for i = 0 to 16
    LCA GRID_X
    STO A x
    LCA GRID_Y
    STO A y
    STO 0 i
1:
    #   plot x+i,y,colour
    LDA x
    LDB i
    LDB A+B
    LCA GRID_COLOUR
    STI A y,B
    #   plot x,y+i,colour
    LDA y
    LDB i
    STO A+B yy
    LDB x
    LCA GRID_COLOUR
    STI A yy,B
    # next i
    LDA i
    LDA A+1
    STO A i
    LDB wid
    JLO 1b
##############
# Draw walls #
##############
    # yy = GRID_SIZE-1
    LCA GRID_SIZE
    LCB GRID_Y
    LDA A+B
    STO A yy
    # for y=0 to 15
    STO 0 y
    #   xx = GRID_SIZE-1
1:
    LCA GRID_SIZE
    LCB GRID_X
    LDA A+B
    STO A xx
    #   for x=0 to 15
    STO 0 x
8:
    #     c = maze[y*16+x]
    LDA y
    LCB @16
    LDA A*B
    LDB x
    LDB A+B
    LDA maze,B
    STO A c
    #     when c & EAST == 0
    LCB EAST
    LDA A&B
    JAZ 2f
4:
    #     when c & SOUTH == 0
    LDA c
    LCB SOUTH
    LDA A&B
    JAZ 3f
    JMP 7f
    # Draw East wall
2:
    #        for i=0 to GRID_SIZE-1
    LCA GRID_SIZE
    STO A i
    #          plot xx,yy+i
5:
    LDB xx
    LCA GRID_COLOUR
    STI A yy,B
    LDA yy
    STO A-1 yy
    LDA i
    STO A-1 i
    JAZ 6f
    JMP 5b
6:
    LDA yy
    LCB GRID_SIZE
    STO A+B+1 yy
    JMP 4b
    # Draw South wall
3:
    #        for i=0 to GRID_SIZE-1
    LCA GRID_SIZE
    STO A i
    #          plot xx+i, yy
5:
    LDB xx
    LCA GRID_COLOUR
    STI A yy,B
    STO B-1 xx
    LDA i
    STO A-1 i
    JAZ 4f
    JMP 5b
4:
    LDA xx
    LCB GRID_SIZE
    STO A+B+1 xx
7:
    #     xx += GRID_SIZE
    LDA xx
    LCB GRID_SIZE
    STO A+B xx

    #   next x
    LDA x
    STO A+1 x
    LCB @15
    JLO 8b

    #   yy += GRID_SIZE
    LDA yy
    LCB GRID_SIZE
    STO A+B yy

    # next y
    LDA y
    STO A+1 y
    LCB @15
    JLO 1b

    STO 0 x
    STO 0 y
move:
    LDA x
    LCB GRID_SIZE
    LDA A*B
    LCB GRID_SIZE2
    LDA A+B
    LCB GRID_X
    LDA A+B
    STO A xx

    LDA y
    LCB GRID_SIZE
    LDA A*B
    LCB GRID_SIZE2
    LDA A+B
    LCB GRID_Y
    LDA A+B
    STO A yy

    LCA $3C
    LDB xx
    STI A yy,B

# Wait for keypress
5:
# c = maze[y*16+x]
    LDA y
    LCB @16
    LDA A*B
    LDB x
    LDB A+B
    LDA maze,B
    STO A c
# Input
    JIU .
    INA
    LCB 'q'
    JEQ sys_cli
# WASD
    LCB 'a'
    JEQ 1f
    LCB 'd'
    JEQ 2f
    LCB 'w'
    JEQ 3f
    LCB 's'
    JEQ 4f
# Restart
    LCB ' '
    JEQ start
    JMP 5b
1:
    # WEST
    LDA c
    LCB WEST
    LDA A&B
    JAZ 5b
    LDA x
    STO A-1 x
    JMP 6f
2:
    # EAST
    LDA c
    LCB EAST
    LDA A&B
    JAZ 5b
    LDA x
    STO A+1 x
    JMP 6f
3:
    # NORTH
    LDA c
    LCB NORTH
    LDA A&B
    JAZ 5b
    LDA y
    STO A-1 y
    JMP 6f
4:
    # SOUTH
    LDA c
    LCB SOUTH
    LDA A&B
    JAZ 5b
    LDA y
    STO A+1 y
    JMP 6f
6:
    LDB xx
    STI 0 yy,B
    JMP move

PAG
choice: BYTE @4
# Directions = N E S W
dx: HEX "00 01 00 FF"
dy: HEX "FF 00 01 00"
x:  BYTE
y:  BYTE
c:  BYTE
d:  BYTE
i:  BYTE
sp: BYTE
xx: BYTE
yy: BYTE
addr: BYTE
wid: BYTE

PAG
maze: BYTE
PAG
xs: BYTE
PAG
ys: BYTE

# System variables
#include "../Examples/monitor.h"
