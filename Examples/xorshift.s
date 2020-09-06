#    t = (a^(a<<5))&FFFF
#    a = b
#    b = (b^(b>>1))^(t^(t>>3))

# Init seeds
# X
    LCA $FF
    STO A x
    LCA $FF
    STO A x+1
# Y
    LCA $FF
    STO A y
    LCA $FF
    STO A y+1

loop:

# T = x^(x<<5)
    LDA x+1
    LCB @5
    LDA AROLB
    LCB $E0
    STO A&B t+1
    LCB $1F
    STO A&B t

    LDA x
    LCB @5
    LDA A<<B
    LCB $E0
    LDA A&B
    LDB t
    STO A|B t

    LDA x
    LDB t
    STO A^B t
    LDA x+1
    LDB t+1
    STO A^B t+1

# X = Y
    LDA y
    STO A x
    LDA y+1
    STO A x+1

# Z = T>>3
    LDA t
    LCB @3
    LDA ARORB
    LCB $E0
    STO A&B z+1
    LCB $1F
    STO A&B z
    LDA t+1
    LCB @3
    LDA A>>B
    LDB z+1
    STO A|B z+1

# T = T^Z
    LDA z
    LDB t
    STO A^B t
    LDA z+1
    LDB t+1
    STO A^B t+1

# Z = Y>>1
    LDA y
    LCB @1
    LDA ARORB
    LCB $80
    STO A&B z+1
    LCB $7F
    STO A&B z
    LDA y+1
    LCB @1
    LDA A>>B
    LDB z+1
    STO A|B z+1

# Y = Y^Z
    LDA y
    LDB z
    STO A^B y
    LDA y+1
    LDB z+1
    STO A^B y+1

# Y = Y^T
    LDA y
    LDB t
    STO A^B y
    LDA y+1
    LDB t+1
    STO A^B y+1

# Output Y
#    LDA y
#    STO A hexchar
#    JSR prhex prhex_ret
#    LDA y+1
#    STO A hexchar
#    JSR prhex prhex_ret
#    OUT '\n'

# plot
    LDA y+1
    LCB @120
    STO A%B yc

    LDA y
    LCB @160
    LDB A%B

    LDA x

# plot pixel
    STI A yc,B

    JMP loop
    JMP sys_cli

PAG

x:  WORD
y:  WORD
z:  WORD
t:  WORD

yc: BYTE
xc: BYTE

#include "monitor.h"
