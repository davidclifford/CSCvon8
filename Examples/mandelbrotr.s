#
# Plot Mandelbrot set
# 22/08/2021
# Updated 30/12/2021 - Use mult 2 directly by shift left 1 place
# Timing - 2:05 @ 6.3Mhz
#
    NAME "mandr"

#   Init
for_py:
# for py=0 to 119
# py=0, yz=$FF00 (-256 = -1.0)
    STO 0 py
    LCA $FF
    STO A yz
    LCA $10
    STO A yz+1
for_px:
# for px=0 to 159
next_py:
# px=0, xz=$FE00 (-512 = -2.0)
    STO 0 px
    LCA $FE
    STO A xz
    LCA $10
    STO A xz+1
next_px:
# plot white pixel
    LCA @63
    LDB px
    STI A py,B
# x=0, y=0
    STO 0 x
    STO 0 x+1
    STO 0 y
    STO 0 y+1

for_i:
# for i=0 to 64
    STO 0 i
next_i:
# x2=x*x
    LCA $10
    STO A $F000

    LDA x
    STO A $0000
    STO A $0002
    LDA x+1
    STO A $0001
    STO A $0003

    LVA $0001
    STO A x2
    LVA $0002
    STO A x2+1

    STO 0 $F000

# y2=y*y
    LCA $10
    STO A $F000

    LDA y
    STO A $0000
    STO A $0002
    LDA y+1
    STO A $0001
    STO A $0003

    LVA $0001
    STO A y2
    LVA $0002
    STO A y2+1

    STO 0 $F000

# t = x2+y2
    STO 0 t
    LDA x2+1
    LDB y2+1
    STO A+B t+1
    TST A+B JC 1f
    JMP 2f
1:
    LDA t
    STO A+1 t
2:
    LDA x2
    LDB t
    LDA A+B
    LDB y2
    STO A+B t
    TST A+B JC 1f
    JMP 2f
1:
    JMP break_out
2:
# when t > 4 ($400) break
    LDA t
    LCB $04
    JHI break_out
    JEQ break_out
# xt = x2 - y2
    LDA x2+1
    LDB y2+1
    STO A-B xt+1
#    TST A-B JC 1f
    JLO 1f
    JMP 2f
1:
# carry
    LDA x2
    STO A-1 x2
2:
    LDA x2
    LDB y2
    STO A-B xt

# xt = xt + xz
    LDA xt+1
    LDB xz+1
    STO A+B xt+1
    TST A+B JC 1f
    JMP 2f
1:
# carry
    LDA xt
    STO A+1 xt
2:
    LDA xt
    LDB xz
    STO A+B xt

# y = x*y*2 + yz

    LCA $10
    STO A $F000

    LDA x
    STO A $0000
    LDA x+1
    STO A $0001

    LDA y
    STO A $0002
    LDA y+1
    STO A $0003

    LVA $0001
    STO A answ+1
    LVA $0002
    STO A answ+2

    STO 0 $F000

# 2*(x*y)
    LDA answ+2
    LCB @2
    STO A*B answ+2
    STO A*BHI t
    LDA answ+1
    LDA A*B answ+1
    LDB t
    LDA A|B
# y = (2*x*y)
    STO A y
    LDA answ+2
    LDB yz+1
    STO A+B y+1
    TST A+B JC 1f
    JMP 2f
1:
    LDA y
    STO A+1 y
2:
    LDA yz
    LDB y
    STO A+B y
# x = xt
    LDA xt
    LDB xt+1
    STO A x
    STO B x+1
# i = i+1
    LDA i
    LDA A+1
    STO A i
    LCB @63
    JHI break_out
# next i
    JMP next_i
break_out:
# plot!!!
    LDA i
    LDB px
    STI A py,B

# xz += 4
    LDA xz+1
    LCB @4
    STO A+B xz+1
    TST A+B JC 1f
    JMP 2f
1:
# carry
    LDA xz
    STO A+1 xz
# Next px
2:
    LDA px
    STO A+1 px
    LCB @159
    JEQ 1f
    JMP next_px
# yz += 4
1:
    LDA yz+1
    LCB @4
    STO A+B yz+1
    TST A+B JC 1f
    JMP 2f
1:
# carry
    LDA yz
    STO A+1 yz
# Next py
2:
    LDA py
    STO A+1 py
    LCB @119
    JEQ 1f
    JMP next_py
# Stop
1:
    JMP sys_cli

#include "vars16i.h"

#PAG
px: BYTE
py: BYTE
x:  WORD
y:  WORD
xz: WORD
yz: WORD
i:  BYTE
x2: WORD
y2: WORD
xt: WORD
t:  WORD
plot_y: BYTE


#include "monitor.h"
