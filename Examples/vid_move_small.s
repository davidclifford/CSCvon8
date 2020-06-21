#define JINA	     JIU .; INA
#define JOUA	     JOU .; OUT A

#
# Move small char around screen
#
    LCA $02
    STO A __paper
    JSR sys_cls sys_cls_ret

# Set up X & Y position, background and foreground colour
    LCA @10 # x = 10
    STO A __sxpos
    LCB @10 # y = 10
    STO B __sypos
    LCA @4 # RED
    STO A __sink
    LCB $0C # GREEN
    STO B __paper

    LCA '*'
    STO A __schar

next_input:
    JSR sys_spchar sys_spchar_ret
    LDA __sxpos
    STO A-1 __sxpos

    JINA
    JOUA

    LCB 'd'
    JEQ right
    LCB 'a'
    JEQ left
    LCB 'w'
    JEQ up
    LCB 's'
    JEQ down
    LCB 'q'
    JEQ sys_cli # return to the Monitor
    LCB ','
    JEQ char_dn
    LCB '.'
    JEQ char_up
    LCB 'n'
    JEQ col_dn
    LCB 'm'
    JEQ col_up

    JMP next_input

left:
    LDA __sxpos
    STO A-1 __sxpos
    JMP next_input
right:
    LDA __sxpos
    STO A+1 __sxpos
    JMP next_input
up:
    LDA __sypos
    STO A-1 __sypos
    JMP next_input
down:
    LDA __sypos
    STO A+1 __sypos
    JMP next_input
char_up:
    LDA __schar
    STO A+1 __schar
    JMP next_input
char_dn:
    LDA __schar
    STO A-1 __schar
    JMP next_input
col_up:
    LDA __sink
    STO A+1 __sink
    JMP next_input
col_dn:
    LDA __sink
    STO A-1 __sink
    JMP next_input


#include "monitor.h"

