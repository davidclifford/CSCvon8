#    t = (a^(a<<5))&FFFF
#    a = b
#    b = (b^(b>>1))^(t^(t>>3))

# Init seeds
# X
    LCA $45
    STO A rand_seed0
    LCA $32
    STO A rand_seed0+1
# Y
    LCA $A5
    STO A rand_seed
    LCA $BC
    STO A rand_seed+1

loop:
# plot
    JSR rand
    LDA rand_seed
    LCB @120
    STO A%B yc

#    JSR rand
    LDA rand_seed+1
    LCB @160
    STO A%B xc

#    JSR rand
    LDA rand_seed0+1
    LCB @2
    LDA A>>B
    LDB xc

# plot pixel
    STI A yc,B

    JMP loop

###########################
rand:
# T = x^(x<<5)
    LDA rand_seed0+1
    LCB @5
    LDA AROLB
    LCB $E0
    STO A&B rand_temp+1
    LCB $1F
    STO A&B rand_temp

    LDA rand_seed0
    LCB @5
    LDA A<<B
    LCB $E0
    LDA A&B
    LDB rand_temp
    STO A|B rand_temp

    LDA rand_seed0
    LDB rand_temp
    STO A^B rand_temp
    LDA rand_seed0+1
    LDB rand_temp+1
    STO A^B rand_temp+1

# X = Y
    LDA rand_seed
    STO A rand_seed0
    LDA rand_seed+1
    STO A rand_seed0+1

# Z = T>>3
    LDA rand_temp
    LCB @3
    LDA ARORB
    LCB $E0
    STO A&B rand_z+1
    LCB $1F
    STO A&B rand_z
    LDA rand_temp+1
    LCB @3
    LDA A>>B
    LDB rand_z+1
    STO A|B rand_z+1

# T = T^Z
    LDA rand_z
    LDB rand_temp
    STO A^B rand_temp
    LDA rand_z+1
    LDB rand_temp+1
    STO A^B rand_temp+1

# Z = Y>>1
    LDA rand_seed
    LCB @1
    LDA ARORB
    LCB $80
    STO A&B rand_z+1
    LCB $7F
    STO A&B rand_z
    LDA rand_seed+1
    LCB @1
    LDA A>>B
    LDB rand_z+1
    STO A|B rand_z+1

# Y = Y^Z
    LDA rand_seed
    LDB rand_z
    STO A^B rand_seed
    LDA rand_seed+1
    LDB rand_z+1
    STO A^B rand_seed+1

# Y = Y^T
    LDA rand_seed
    LDB rand_temp
    STO A^B rand_seed
    LDA rand_seed+1
    LDB rand_temp+1
    STO A^B rand_seed+1

    RTS rand
############################

# Output Y
#    LDA y
#    STO A hexchar
#    JSR prhex prhex_ret
#    LDA y+1
#    STO A hexchar
#    JSR prhex prhex_ret
#    OUT '\n'

PAG

rand_seed0:  WORD
rand_seed:  WORD
rand_z:  WORD
rand_temp:  WORD

yc: BYTE
xc: BYTE

#include "monitor.h"
