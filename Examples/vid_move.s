#define JINA	     JIU .; INA
#define JOUA	     JOU .; OUT A

#
# Move char around screen
#
    LCA $02
    STO A __paper
    JSR sys_cls sys_cls_ret

# Set up X & Y position, background and foreground colour
    LCA @10 # x = 0
    STO A __xpos
    LCB @10 # y = 0
    STO B __ypos
    LCA $30 # RED
    STO A __ink
    LCB $0C # GREEN
    STO B __paper

next_input:
    LCA '*'
    STO A __char

    JSR sys_pchar sys_pchar_ret
    LDA __xpos
    STO A-1 __xpos

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
    LCB @27
    JEQ sys_cli # return to the Monitor
    JMP next_input

left:
    LDA __xpos
    STO A-1 __xpos
    JMP next_input
right:
    LDA __xpos
    STO A+1 __xpos
    JMP next_input
up:
    LDA __ypos
    STO A-1 __ypos
    JMP next_input
down:
    LDA __ypos
    STO A+1 __ypos
    JMP next_input

#include "monitor.h"

