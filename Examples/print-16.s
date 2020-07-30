#
# Print a 16-bit unsigned number in base 10
#

#define OUT(x)	     JOU .; OUT x

loop:
    LDA     number
    LDB     number+1
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
    LDA     rem
    LCB     '0'
    LDA     A+B
    STO     A out+4

    LDB     0           # 3
    LDA     num1        # 5
    # high byte
    STO     ADIVB num1  # 5
    LDB     AREMB       # 5
    # low byte
    LDA     num0        # 5
    STO     ADIVB num0  # 5
    STO     AREMB rem   # 5
    LDA     rem
    LCB     '0'
    LDA     A+B
    STO     A out+3

    LDB     0           # 3
    LDA     num1        # 5
    # high byte
    STO     ADIVB num1  # 5
    LDB     AREMB       # 5
    # low byte
    LDA     num0        # 5
    STO     ADIVB num0  # 5
    STO     AREMB rem   # 5
    LDA     rem
    LCB     '0'
    LDA     A+B
    STO     A out+2

    LDB     0           # 3
    LDA     num1        # 5
    # high byte
    STO     ADIVB num1  # 5
    LDB     AREMB       # 5
    # low byte
    LDA     num0        # 5
    STO     ADIVB num0  # 5
    STO     AREMB rem   # 5
    LDA     rem
    LCB     '0'
    LDA     A+B
    STO     A out+1

    LDB     0           # 3
    LDA     num1        # 5
    # high byte
    STO     ADIVB num1  # 5
    LDB     AREMB       # 5
    # low byte
    LDA     num0        # 5
    STO     ADIVB num0  # 5
    STO     AREMB rem   # 5
    LDA     rem
    LCB     '0'
    LDA     A+B
    STO     A out

    LCB     '0'
    LDA     out
    JNE     1f
    LDA     out+1
    JNE     2f
    LDA     out+2
    JNE     3f
    LDA     out+3
    JNE     4f
    JMP     5f
1:
    LDA     out
    OUT     (A)
2:
    LDA     out+1
    OUT     (A)
3:
    LDA     out+2
    OUT     (A)
4:
    LDA     out+3
    OUT     (A)
5:
    LDA     out+4
    OUT     (A)
    OUT     ('\n')

    LDA     number
    LDB     number+1
    TST     B+1 JC carry
    STO     B+1 number+1
    JMP     loop
carry:
    STO     0 number+1
    STO     A+1 number
    JMP loop

# Back to command prompt
    JMP     sys_cli

number: BYTE @2
num0:   BYTE
num1:   BYTE
rem:    BYTE
cnt:    BYTE
PAG
out:    BYTE @6

#include "monitor.h"