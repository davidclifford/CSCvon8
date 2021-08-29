#
# 11/08/2021
# Multiply 2 16-bit numbers together
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
    LCA     $fe
    STO     A num1
    LCA     $00
    STO     A num1+1

# init num2
    LCA     $fe
    STO     A num2
    LCA     $00
    STO     A num2+1

    JSR     mult16f

print:
    LCA     $06
    STO     A __sink
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
    LDA     answ+1
    STO     A __number
    LDA     answ+2
    STO     A __number+1
    JSR     sys_num_str_16 sys_num_str_16_ret
    LHA     __num_str
    LDB     __num_ptr
    STO     A __string
    STO     B __string+1
    JSR     sys_spstring sys_spstring_ret

    PRI     ('\n')

    JMP sys_cli

PAG
count:  BYTE

#include "mult.h"
#include "monitor.h"
