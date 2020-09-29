# Random number generator
    LCA rand_seed+1
    STO A+1 rand_seed+1
start:
    STO 0 yc
    STO 0 xc
loop:
# plot
    JSR rand
    LDA rand_seed+1
#    LCB $0F
#    LDA A&B
#    LCB $F0
#    LDA A|B
    LCB $3F
    LDA A&B
    LDB xc

# plot pixel
    STI A yc,B

    LDA xc
    LCB @160
    JEQ 1f
    STO A+1 xc
    JMP loop
1:
    STO 0 xc
    LDA yc
    LCB @120
    JEQ 1f
    STO A+1 yc
#    INA
#    LCB 'q'
#    JEQ sys_cli
    JMP loop
1:
    JMP start

###################################
# Random number generator
###################################
rand:
# T = X<<5
    LDA rand_seed0+1
    LCB $20
    STO A*B rand_temp+1
    STO A*BHI rand_temp
    LDA rand_seed0
    LDA A*B
    LDB rand_temp
    STO A+B rand_temp

# T = T^X
    LDA rand_seed0+1
    LDB rand_temp+1
    STO A^B rand_temp+1
    LDA rand_seed0
    LDB rand_temp
    STO A^B rand_temp

# X = Y
    LDA rand_seed
    STO A rand_seed0
    LDA rand_seed+1
    STO A rand_seed0+1

# Z = T>>3
    LDA rand_temp
    LCB @3
    STO A>>B rand_z
    LDA rand_temp+1
    STO A>>B rand_z+1
    LDA rand_temp
    LCB @5
    LDA A<<B
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
    STO A>>B rand_z
    LDA rand_seed+1
    STO A>>B rand_z+1
    LDA rand_seed
    LCB @7
    LDA A<<B
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

PAG

rand_seed: WORD       # Seed for RNG
rand_seed0: WORD      # Seed 0 for RNG
rand_z:  WORD
rand_temp:  WORD

yc: BYTE
xc: BYTE

#include "monitor.h"
