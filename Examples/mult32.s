#
# 11/08/2021
# Multiply 2 16-bit numbers together
# Giving a 32-bit number
#

#define PRI(x)       LCA x ; STO A __schar; JSR sys_spchar sys_spchar_ret;

# Clear screen, set ink RED
    STO     0 __sxpos
    STO     0 __sypos
    LCA     $06
    STO     A __sink
    STO     0 __paper
    JSR     sys_cls sys_cls_ret

    LCA     @28
    STO     A count

# init num1
    LCA     $ff
    STO     A num1
    LCA     $00
    STO     A num1+1

# init num2
    LCA     $ff
    STO     A num2
    LCA     $00
    STO     A num2+1
loop:
# init answ to 0000
    STO     0 answ
    STO     0 answ+1
    STO     0 answ+2
    STO     0 answ+3
    STO     0 sign1
    STO     0 sign2
    STO     0 signA

# multiply answ = num1 * num2
# Is num1 negative?
    LDA     num1
    JAN     1f
    JMP     4f
# Num1 is negative
1:
    STO     !A num1
    LDA     num1+1
    LDA     !A
    STO     A+1 num1+1
    TST     A+1 JC 2f
    JMP     3f
2:
    LDA     num1
    STO     A+1 num1
3:
    LCA     @1
    STO     A sign1
    STO     A signA
4:
# Is num2 negative?
    LDA     num2
    JAN     1f
    JMP     4f
# Num2 is negative
1:
    STO     !A num2
    LDA     num2+1
    LDA     !A
    STO     A+1 num2+1
    TST     A+1 JC 2f
    JMP     3f
2:
    LDA     num2
    STO     A+1 num2
3:
    LCA     @1
    STO     A sign2
    LDB     signA
    STO     A^B signA
4:
# Multiply num1 * num2
    LDA     num1+1
    LDB     num2+1
    STO     A*B answ+3
    STO     A*BHI answ+2

    LDA     num1+1
    LDB     num2
    STO     A*B temp
    STO     A*BHI answ+1

    LDA     answ+2
    LDB     temp
    STO     A+B answ+2
    TST     A+B JC 1f
    JMP 2f
1:
    LDA     answ+1
    STO     A+1 answ+1
2:
    LDA     num1
    LDB     num2+1
    STO     A*B temp
    STO     A*BHI temp2

    LDA     answ+2
    LDB     temp
    STO     A+B answ+2
    TST     A+B JC 1f
    JMP 2f
1:
    LDA     answ+1
    STO     A+1 answ+1
2:
    LDA     answ+1
    LDB     temp2
    STO     A+B answ+1
    TST     A+B JC 1f
    JMP 2f
1:
    LDA     answ
    STO     A+1 answ
2:
    LDA     num1
    LDB     num2
    STO     A*B temp
    STO     A*BHI temp2

    LDA     answ+1
    LDB     temp
    STO     A+B answ+1
    TST     A+B JC 1f
    JMP 2f
1:
    LDA     answ
    STO     A+1 answ
2:
    LDA     answ
    LDB     temp2
    STO     A+B answ

print:
    LCA     $06
    STO     A __sink
# print num1
    LDA     sign1
    JAZ     1f
    PRI     ('-')
1:
    LDA     num1
    STO     A __number
    LDA     num1+1
    STO     A __number+1
    JSR     sys_num_str_16 sys_num_str_16_ret
    LHA     __num_str
    LDB     __num_ptr
    STO     A __string
    STO     B __string+1
    JSR     sys_spstring sys_spstring_ret

    LCA     $01
    STO     A __sink
    PRI     ('*')

# print num2
    LCA     $03
    STO     A __sink

    LDA     sign2
    JAZ     1f
    PRI     ('-')
1:

    LDA     num2
    STO     A __number
    LDA     num2+1
    STO     A __number+1
    JSR     sys_num_str_16 sys_num_str_16_ret
    LHA     __num_str
    LDB     __num_ptr
    STO     A __string
    STO     B __string+1
    JSR     sys_spstring sys_spstring_ret

    LCA     $02
    STO     A __sink
    PRI     ('=')

# print answer
    LCA     $07
    STO     A __sink

    LDA     signA
    JAZ     1f
    PRI     ('-')
1:
    LDA     answ
    STO     A __number
    LDA     answ+1
    STO     A __number+1
    LDA     answ+2
    STO     A __number+2
    LDA     answ+3
    STO     A __number+3
    JSR     sys_num_str_32 sys_num_str_32_ret
    LHA     __num_str
    LDB     __num_ptr
    STO     A __string
    STO     B __string+1
    JSR     sys_spstring sys_spstring_ret

# Normalise >> 8
    LDA     answ+2
    STO     A answ+3
    LDA     answ+1
    STO     A answ+2
    LDA     answ
    STO     A answ+1
    STO     0 answ

# print normalised answer
    LCA     $04
    STO     A __sink

    PRI     (':')

    LCA     $00
    STO     A __sink

    LDA     signA
    JAZ     1f
    PRI     ('-')
1:
    LDA     answ+2
    STO     A __number
    LDA     answ+3
    STO     A __number+1
    JSR     sys_num_str_16 sys_num_str_16_ret
    LHA     __num_str
    LDB     __num_ptr
    STO     A __string
    STO     B __string+1
    JSR     sys_spstring sys_spstring_ret

    PRI     ('\n')

# 2s complement negative answers
    LDA     signA
    JAZ     1f
    LDA     answ+2
    STO     !A answ+2
    LDA     answ+3
    LDA     !A
    STO     A+1 answ+3
    TST     A+1 JC 2f
    JMP     1f
2:
    LDA     answ+2
    STO     A+1 answ+2
1:
# num1 = answer
    LDA     answ+2
    STO     A num1
    LDA     answ+3
    STO     A num1+1

    LDA     count
    LDA     A-1
    STO     A count
    JAZ     1f
#    JMP     loop
1:
    JMP sys_cli

PAG
num1:   BYTE @2
num2:   BYTE @2
answ:   BYTE @4
sign1:  BYTE
sign2:  BYTE
signA:  BYTE
temp:   BYTE
temp2:  BYTE
count:  BYTE

#include "monitor.h"