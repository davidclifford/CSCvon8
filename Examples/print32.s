#
# Print a 32-bit unsigned number in base 10
#

#define OUT(x)	     JOU .; OUT x
    STO     0 __xpos
    STO     0 __ypos
    STO     0 __paper
    LCA     $3c
    STO     A __ink

    STO     0 __sxpos
    STO     0 __sypos
    LCA     $06
    STO     A __sink

    LCA     $00
    STO     A number
    LCA     $00
    STO     A number+1
    LCA     $00
    STO     A number+2
    LCA     $00
    STO     A number+3

loop:
    LDA     number
    STO     A __number
    LDA     number+1
    STO     A __number+1
    LDA     number+2
    STO     A __number+2
    LDA     number+3
    STO     A __number+3

    JSR     sys_num_str_32 sys_num_str_32_ret

# print out number
out_number:
    LHA     __num_str
    STO     A __string
    LDA     __num_ptr
    STO     A __string+1
    JSR     sys_pstring sys_pstring_ret
    LCA     ' '
    STO     A __char
    JSR     sys_pchar sys_pchar_ret

    LDB     __num_ptr
1:  LDA     __num_str,B
    JAZ     next_number
    OUT(A)
    LDB     B+1
    JMP     1b

# Increment number
next_number:
    OUT(' ')
    LDB     number+3
    LDB     B+1
    STO     B number+3
    JBZ     1f
    JMP     loop
1:
    LDB     number+2
    LDB     B+1
    STO     B number+2
    JBZ     2f
    JMP     loop
2:
    LDB     number+1
    LDB     B+1
    STO     B number+1
    JBZ     3f
    JMP     loop
3:
    LDB     number
    LDB     B+1
    STO     B number
    JBZ     exit
    JMP     loop

# Back to command prompt
exit:
    JMP     sys_cli

number: WORD @2

#include "monitor.h"