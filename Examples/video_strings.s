#include "monitor.h"

# Print char to VGA
#
    LCA $02
    STO A bakg
    JSR cls cls_ret

# Set up X & Y position, background and foreground colour
    LCA $00 # x = 0
    STO A xpos
    LCB $00 # y = 0
    STO B ypos
    LCA $3C # YELLOW
    STO A forg
    LCB $03 # BLUE
    STO B bakg
    LCA $00
    STO A pos

# Iterate through the string
1:
    LDB pos
    LDA message,B
    JAZ 2f
    STO A char
    JSR pchar pchar_ret
    LDB pos
    STO B+1 pos
    JMP 1b
2:
    JMP newprompt # return to the Monitor

pos: HEX "00"

    PAG
message: STR "CSCvon8 Monitor\nRevision: 2.01\ntype ? for help\nBy Warren Toomey\nand David Clifford\n{|}~"

