#
# Print out fibonacci sequence using 32-bits
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
    STO     0 curr+1
    STO     0 curr+2
    STO     A curr+3
    STO     A count
    LCA     @1
    STO     0 prev
    STO     0 prev+1
    STO     0 prev+2
    STO     A prev+3

loop:
    LDA     count
    STO     A __number
    JSR     sys_num_str_8 sys_num_str_8_ret
    LHA     __num_str
    LDB     __num_ptr
    STO     A __string
    STO     B __string+1
    JSR     sys_spstring sys_spstring_ret

    LHA     mess
    LCB     mess
    STO     A __string
    STO     B __string+1
    JSR     sys_spstring sys_spstring_ret

    LDA     curr
    STO     A __number
    LDA     curr+1
    STO     A __number+1
    LDA     curr+2
    STO     A __number+2
    LDA     curr+3
    STO     A __number+3
    JSR     sys_num_str_32 sys_num_str_32_ret
    LHA     __num_str
    LDB     __num_ptr
    STO     A __string
    STO     B __string+1
    JSR     sys_spstring sys_spstring_ret

    OUT     ('\n')
    PRI     ('\n')

# Change to next colour
1:
    LDA     __sink
    LDA     A+1
    LCB     $07
    STO     A&B __sink

# temp = current
    LDA     curr
    STO     A temp
    LDA     curr+1
    STO     A temp+1
    LDA     curr+2
    STO     A temp+2
    LDA     curr+3
    STO     A temp+3

# current = current + prev
    LDA     curr+3
    LDB     prev+3
    STO     A+B curr+3
    TST     A+B JC 1f
    JMP     2f
1:
    LDA     curr+2
    STO     A+1 curr+2
2:
    LDA     curr+2
    LDB     prev+2
    STO     A+B curr+2
    TST     A+B JC 3f
    JMP     4f
3:
    LDA     curr+1
    STO     A+1 curr+1
4:
    LDA     curr+1
    LDB     prev+1
    STO     A+B curr+1
    TST     A+B JC 5f
    JMP     6f
5:
    LDA     curr
    STO     A+1 curr
6:
    LDA     curr
    LDB     prev
    STO     A+B curr
    TST     A+B JC sys_cli

# prev = temp
    LDA     temp
    STO     A prev
    LDA     temp+1
    STO     A prev+1
    LDA     temp+2
    STO     A prev+2
    LDA     temp+3
    STO     A prev+3

# increment count

    LDA     count
    STO     A+1 count
    JMP     loop

# Back to command prompt
    JMP     sys_cli

PAG
count:  BYTE
curr:   BYTE @4
prev:   BYTE @4
temp:   BYTE @4
mess:   STR " fibonacci number = "
pos:    BYTE

PAG
out:    BYTE @6

#include "monitor.h"