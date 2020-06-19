#include "monitor.h"

# Print string to VGA
#
    LCA $01
    STO A __paper
    JSR sys_cls sys_cls_ret

# Set up X & Y position, background and foreground colour
    LCA $00 # x = 0
    STO A __xpos
    LCB $00 # y = 0
    STO B __ypos
    LCA $3C # YELLOW
    STO A __ink
    LCB message
    STO B pos

# Iterate through the string
1:
    LDB pos
    LDA message,B
    JAZ 2f
    STO A __char
    JSR sys_pchar sys_pchar_ret
    LDB pos
    STO B+1 pos
    JMP 1b
2:
# Output ALL printable characters
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
    JMP 2b

pos: BYTE
char: BYTE
    PAG
message: STR "CSCvon8 Monitor\nRevision: 2.01\ntype ? for help\nBy Warren Toomey\nand David Clifford\n"


