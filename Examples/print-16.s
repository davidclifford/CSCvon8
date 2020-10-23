#
# Print a 16-bit unsigned number in base 10
#

#define OUT(x)	     # JOU .; OUT x;
#define PRT(x)       STO x __schar; JSR sys_spchar sys_spchar_ret;
#define PRI(x)       LCA x ; STO A __schar; JSR sys_spchar sys_spchar_ret;

    STO     0 number
    STO     0 number+1
restart:
# Clear screen, set ink RED
    STO     0 __sxpos
    STO     0 __sypos
    LCA     $04
    STO     A __sink
    JSR     sys_cls sys_cls_ret
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
    PRT     (A)
2:
    LDA     out+1
    OUT     (A)
    PRT     (A)
3:
    LDA     out+2
    OUT     (A)
    PRT     (A)
4:
    LDA     out+3
    OUT     (A)
    PRT     (A)
5:
    LDA     out+4
    OUT     (A)
    PRT     (A)
    OUT     (' ')
    PRI     (' ')

    LDA     __sxpos
    LCB     @48
    JLT     1f
    OUT     ('\n')
    PRI     ('\n')
1:
    LDA     __sypos
    LCB     @30
    JNE     1f
    STO     A-1 __sypos
    JSR sys_scroll4 sys_scroll4_ret
#    JSR     sys_cls sys_cls_ret
#    STO     0 __sxpos
#    STO     0 __sypos
1:
    LDA     __sink
    LDA     A+1
    LCB     $07
    STO     A&B __sink

    LDA     number
    LDB     number+1
    LDB     B+1
    STO     B number+1
    JBZ     carry
    JMP     loop
carry:
    STO     0 number+1
    STO     A+1 number
    JMP     loop

# Back to command prompt
    JMP     sys_cli


PAG

number: WORD
num0:   BYTE
num1:   BYTE
rem:    BYTE
cnt:    BYTE
PAG
out:    BYTE @6

#include "monitor.h"