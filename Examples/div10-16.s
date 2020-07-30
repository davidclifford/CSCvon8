#
# Divide a 16-bit unsigned number by 10
#

#define OUT(x)	     JOU .; OUT x

    LCA     $19
    LCB     $99
    STO     A num1 # MSD
    STO     B num0 # LSD

# Divide 16 bit number by 10 (33 clock cycles)
divide:
    LDB     0           # 3
    LDA     num1        # 5
    # high byte
    STO     ADIVB num1  # 5
    LDB     AREMB       # 5
    # low byte
    LDA     num0        # 5
    STO     ADIVB num0  # 5
    STO     AREMB rem   # 5

# Print out num1 num0 rem
    LDA     num1
    STO     A hexchar
    JSR     prhex prhex_ret
    OUT     (' ')
    LDA     num0
    STO     A hexchar
    JSR     prhex prhex_ret
    OUT     (' ')
    LDA     rem
    STO     A hexchar
    JSR     prhex prhex_ret
    OUT     ('\n')

# Back to command prompt

    JMP     sys_cli

num0:   BYTE
num1:   BYTE
rem:    BYTE
cnt:    BYTE
PAG
out:    BYTE @6

#include "monitor.h"