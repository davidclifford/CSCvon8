# Bounce balls over screen
# David Clifford Nov 2020
    NAME "bounce"

restart:
    STO 0 __paper
    JSR sys_cls sys_cls_ret
    STO 0 index
init:
    LDB index
    LCA @80
    STO A ix,B
    LCA @60
    STO A iy,B

    JSR sys_rand sys_rand_ret
    LDA __rand_seed
    LCB $3F
    LDA A&B
    LDB index
    STO A iink,B
    LDB B+1
    STO 0 iink,B

    # Random vx,vy
    JSR sys_rand sys_rand_ret
    LDB index
    LDA __rand_seed
    STO 0 ivx,B
    LDB B+1
    STO A ivx,B
    LDA __rand_seed+1
    LDB index
    STO 0 ivy,B
    LDB B+1
    STO A ivy,B

    # Random change direction
    JSR sys_rand sys_rand_ret
    LDB index
    LDA __rand_seed
    JAN 1f
    LDA __rand_seed+1
    JAN 2f
    JMP 3f
1:
    LDA ivx,B
    LDA !A
    STO A ivx,B
    LDB B+1
    LDA ivx,B
    LDA !A
    STO A ivx,B
    LDA __rand_seed+1
    JAN 2f
    JMP 3f
2:
    LDB index
    LDA ivy,B
    LDA !A
    STO A ivy,B
    LDB B+1
    LDA ivy,B
    LDA !A
    STO A ivy,B
3:
    # ox, oy = 0
    LDB index
    STO 0 iox,B
    LDB B+1
    STO 0 iox,B

    LDB index
    STO 0 ioy,B
    LDB B+1
    STO 0 ioy,B

    LDA index
    LCB @2
    LDA A+B
    STO A index
    JAZ next_frame
    JMP init

next_frame:
    JIU 1f
    INA
    LCB ' '
    JEQ restart
    LCB 'q'
    JEQ end
1:
    LCA @0
    STO A index
next_ball:
    LDB index

    LDA ix,B
    STO A x
    LDB B+1
    LDA ix,B
    STO A x+1
    LDB B-1

    LDA iy,B
    STO A y
    LDB B+1
    LDA iy,B
    STO A y+1
    LDB B-1

    LDA ivx,B
    STO A vx
    LDB B+1
    LDA ivx,B
    STO A vx+1
    LDB B-1

    LDA ivy,B
    STO A vy
    LDB B+1
    LDA ivy,B
    STO A vy+1
    LDB B-1

    LDA iox,B
    STO A ox
    LDB B+1
    LDA iox,B
    STO A ox+1
    LDB B-1

    LDA ioy,B
    STO A oy
    LDB B+1
    LDA ioy,B
    STO A oy+1
    LDB B-1

    LDA iink,B
    STO A ink

    # unplot(ox, oy)
    LDB ox
    STI 0 oy,B

    # Check x and y
    LDA x
    LCB @159
    JHI 1f
    LDA y
    LCB @119
    JHI 1f
    JMP 2f
1:
    # Out of bounds!!!
    LCA @80
    STO A x
    LCA @60
    STO A y
#    JMP restart
2:
    # plot(x, y, ink)
    LDB x
    LDA ink
    STI A y,B

    LDA x
    STO A ox
    LDA y
    STO A oy

#1:
    # x = x + vx
    LDB vx+1
    LDA x+1
    STO A+B x+1
    TST A+B JC 1f
    LDA x
3:
    LDB vx
    STO A+B x
    JMP 2f
1:
    LDA x
    LDA A+1
    JMP 3b
2:
    # y = y + vy
    LDB vy+1
    LDA y+1
    STO A+B y+1
    TST A+B JC 1f
    LDA y
3:
    LDB vy
    STO A+B y
    JMP 2f
1:
    LDA y
    LDA A+1
    JMP 3b
2:
    LDA x
    LCB @158
    JHI 1f
    LCB @2
    JLO 1f
    LDA y
    LCB @118
    JHI 2f
    LCB @2
    JLO 2f
    JMP 3f
1:
    # vx = -vx
    LDA vx
    STO !A vx
    LDA vx+1
    STO !A vx+1
    JMP 3f
2:
    # vy = -vy
    LDA vy
    STO !A vy
    LDA vy+1
    STO !A vy+1
    JMP 3f

3:
    LDB index

    LDA x
    STO A ix,B
    LDB B+1
    LDA x+1
    STO A ix,B
    LDB B-1

    LDA y
    STO A iy,B
    LDB B+1
    LDA y+1
    STO A iy,B
    LDB B-1

    LDA vx
    STO A ivx,B
    LDB B+1
    LDA vx+1
    STO A ivx,B
    LDB B-1

    LDA vy
    STO A ivy,B
    LDB B+1
    LDA vy+1
    STO A ivy,B
    LDB B-1

    LDA ox
    STO A iox,B
    LDB B+1
    LDA ox+1
    STO A iox,B
    LDB B-1

    LDA oy
    STO A ioy,B
    LDB B+1
    LDA oy+1
    STO A ioy,B
    LDB B-1

    LDA ink
    STO A iink,B

    LDA B+1 # index+1
    LDA A+1 # index+2

    STO A index
    JAZ next_frame
    JMP next_ball
end:
    JMP sys_cli

x: WORD
y: WORD
vx: WORD
vy: WORD
ox: WORD
oy: WORD
ink: BYTE
index: BYTE

PAG
ix: WORD @128
iy: WORD @128
ivx: WORD @128
ivy: WORD @128
iox: WORD @128
ioy: WORD @128
iink: WORD @128

#include "monitor.h"

EXPORT ix
EXPORT iy
EXPORT ivx
EXPORT ivy
EXPORT iox
EXPORT ioy
EXPORT iink
EXPORT index
