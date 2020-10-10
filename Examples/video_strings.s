#include "monitor.h"

# Print string to VGA
#
    LCA $00
    STO A __paper
    JSR sys_cls sys_cls_ret

# Set up X & Y position, background and foreground colour
    LCA $00 # x = 0
    STO A __xpos
    LCB $00 # y = 0
    STO B __ypos
    LCA $03 # BLUE
    STO A col
    STO A __ink
    LCB message
    STO B pos

# Iterate through the string
1:
    LDA message,B
    JAZ 2f
    STO A __char
    JSR sys_pchar sys_pchar_ret
    LDA __char
    LCB ' '
    JEQ 3f
    LCB '\n'
    JEQ 3f
#    JMP 3f
4:
    LDB pos
    LDB B+1
    STO B pos
    JMP 1b
3:
    LDA __ink
    LCB @2
    STO A+B __ink
    JMP 4b
2:
# Output ALL printable characters
    LCA $03
    STO A __ink
    LCA ' '
    STO A char
1:
    LDA char
    STO A+1 char
    STO A __char
    JSR sys_pchar sys_pchar_ret
    LDA __xpos
    LCB @24
    LDA A%B
    JAZ 3f
2:
    LDA char
    LCB @128
    JNE 1b

    JMP sys_cli # return to the Monitor
3:
    LCA '\n'
    STO A __char
    JSR sys_pchar sys_pchar_ret
    LDA __ink
    LCB @2
    STO A*B __ink
    JMP 2b

PAG
pos: BYTE
char: BYTE
col: BYTE

message: STR "To be, or not to be, that\nis the question?\nWhether 'tis nobler in the\nmind to suffer the slings\nand arrows of outrageous\nfortune, Or to take Arms\nagainst a Sea of troubles\n\n"


