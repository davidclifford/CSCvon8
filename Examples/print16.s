#
# Print a 16-bit unsigned number in base 10
#

#define OUT(x)	     JOU .; OUT x

    LCA     $00
    STO     A number
    LCA     $00
    STO     A number+1

loop:
    LDA     number
    LDB     number+1
    STO     A num # MSD
    STO     B num+1 # LSD

# Divide 16 bit number by 10 (33 clock cycles)
    STO     0 cnt
    STO     0 out
1:  LDB     0
    LDA     num
    # high byte
    STO     ADIVB num
    LDB     AREMB
    # low byte
    LDA     num+1
    STO     ADIVB num+1
    STO     AREMB rem
    LDA     rem
    LCB     '0'
    LDA     A+B
    LDB     cnt
    STO     A out,B
    STO     B+1 cnt
    LDA     num+1
    JAZ     2f
    JMP     1b
2:  LDA     num
    JAZ     out_number
    JMP     1b

# print out number
out_number:
    LDB     cnt
    LDB     B-1
1:  LDA     out,B
    OUT(A)
    LDB     B-1
    JAZ     next_number
    JMP     1b

# Increment number
next_number:
    OUT(' ')
    LDB     number+1
    LDB     B+1
    STO     B number+1
    JBZ     carry
    JMP     loop
carry:
    LDB     number
    LDB     B+1
    STO     B number
    JBZ     exit
    JMP     loop

# Back to command prompt
exit:
    JMP     sys_cli

number: WORD
num:    WORD
rem:    BYTE
cnt:    BYTE
PAG
out:    STR ""

#include "monitor.h"