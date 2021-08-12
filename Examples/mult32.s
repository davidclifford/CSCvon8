#
# 11/08/2021
# Multiply 2 32-bit numbers together
#

#define PRI(x)       LCA x ; STO A __schar; JSR sys_spchar sys_spchar_ret;

# Clear screen, set ink RED
    STO     0 __sxpos
    STO     0 __sypos
    LCA     $06
    STO     A __sink
    STO     0 __paper
    JSR     sys_cls sys_cls_ret

# init num1
    LCA     $aa
    STO     A num1
    LCA     $55
    STO     A num1+1

# init num2
    LCA     $a5
    STO     A num2
    LCA     $5a
    STO     A num2+1
loop:
# init answ to 0000
    STO     0 answ
    STO     0 answ+1
    STO     0 answ+2
    STO     0 answ+3

# multiply answ = num1 * num2
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
    PRI     ('\n')

    LDA     answ+2
    LDB     answ+3
    STO     A+B num1

    LDA     answ
    LDB     answ+1
    STO     A+B num2

    JMP     loop
1:
    JMP sys_cli

PAG
num1:   BYTE @2
num2:   BYTE @2
answ:   BYTE @4
temp:   BYTE
temp2:  BYTE
count:  BYTE

#include "monitor.h"