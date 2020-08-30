#
# Print out fibonacci sequence using 16-bits
#

#define OUT(x)	     #JOU .; OUT x;
#define PRT(x)       STO x __schar; JSR sys_spchar sys_spchar_ret;
#define PRI(x)       LCA x ; STO A __schar; JSR sys_spchar sys_spchar_ret;

# Clear screen, set ink RED
    STO     0 __sxpos
    STO     0 __sypos
    LCA     $04
    STO     A __sink
    JSR     sys_cls sys_cls_ret

restart:
    LCA     @1
    STO     0 curr
    STO     A curr+1
    STO     0 count
    STO     A count+1
    LCA     @1
    STO     0 prev
    STO     A prev+1

loop:
    LDA     count
    LDB     count+1
    STO     A number
    STO     B number+1
    JSR     print16

    JSR     prints

    LDA     curr
    LDB     curr+1
    STO     A number
    STO     B number+1
    JSR     print16

    OUT     ('\n')
    PRI     ('\n')

# Check to scroll screen
    LDA     __sypos
    LCB     @30
    JNE     1f
    STO     A-1 __sypos
    JSR     sys_scroll4 sys_scroll4_ret

# Change to next colour
1:
    LDA     __sink
    LDA     A+1
    LCB     $07
    STO     A&B __sink

# temp = current
    LDA     curr
    LDB     curr+1
    STO     A temp
    STO     B temp+1

# current = current + prev
    LDA     curr+1
    LDB     prev+1
    STO     A+B curr+1
    TST     A+B JC 1f
    JMP     2f
1:
    LDA     curr
    STO     A+1 curr
2:
    LDA     curr
    LDB     prev
    TST     A+B JC sys_cli #restart
    STO     A+B curr

# prev = temp
    LDA     temp
    LDB     temp+1
    STO     A prev
    STO     B prev+1

# increment count

    LDA     count
    LDB     count+1
    TST     B+1 JC 1f
    STO     B+1 count+1
    JMP     loop
1:
    STO     0 count+1
    STO     A+1 count
    JMP     loop

# PRINT message
prints:
    LCB     mess
    STO     B pos
1:
    LDA     mess,B
    JAZ     2f
    OUT     (A)
    PRT     (A)
    LDB     pos
    LDB     B+1
    STO     B pos
    JMP     1b
2:
    RTS prints

# PRINT 16 bit number as unsigned base 10 number
print16:
    LDA     number
    LDB     number+1
    STO     A num1 # MSD
    STO     B num0 # LSD

# Divide 16 bit number by 10 (33 clock cycles)
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
    RTS     print16

# Back to command prompt
    JMP     sys_cli

PAG
number: WORD
count:  WORD
curr:   WORD
prev:   WORD
temp:   WORD
num0:   BYTE
num1:   BYTE
rem:    BYTE
cnt:    BYTE
mess:   STR " fibonacci number = "
pos:    BYTE

PAG
out:    BYTE @6

#include "monitor.h"