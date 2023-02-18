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
    LCA     $7f
    STO     A num1
    LCA     $Ff
    STO     A num1+1

# init num2
    LCA     $7F
    STO     A num2
    LCA     $Ff
    STO     A num2+1

#######################
    LCA $10
    STO A $F000

    LDA num1+0
    STO A $0000
    LDA num1+1
    STO A $0001
    LDA num2+0
    STO A $0002
    LDA num2+1
    STO A $0003

    LVA $0000
    STO A answ+0
    LVA $0001
    STO A answ+1
    LVA $0002
    STO A answ+2
    LVA $0003
    STO A answ+3

    STO 0 $F000

#######################
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
    LDA     answ+0
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

    JMP sys_cli

PAG
count:  BYTE
num1:   WORD
num2:   WORD
answ:   BYTE @4

#include "monitor.h"
