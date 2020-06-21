
# Print string in small font to VGA
#
    OUT 'X'
    LCA $00
    STO A __paper
    JSR sys_cls sys_cls_ret

# Set up X & Y position, background and foreground colour
    LCA $00 # x = 0
    STO A __sxpos
    LCB $00 # y = 0
    STO B __sypos
    LCA $04 # YELLOW
    STO A __sink
    LCB message
    STO B pos

# Iterate through the string
1:
    LDB pos
    LDA message,B
    JAZ 2f
    STO A __schar
    JSR sys_spchar sys_spchar_ret
    LDB pos
    STO B+1 pos

    LDA __schar
    LCB ' '
    JNE 1b
    LDA __sink
    LDA A+1
    LCB $07
    LDA A&B
    JAZ 3f
    STO A __sink
    JMP 1b
3:
    LDA A+1
    STO A __sink
    JMP 1b
2:
# Output ALL printable characters
    LCA ' '
    STO A char
1:
    LDA char
    STO A+1 char
    STO A __schar
    JSR sys_spchar sys_spchar_ret
    LDA __sxpos
    LCB @53
    LDA A%B
    JAZ 3f
2:
    LDA char
    LCB @128
    JNE 1b

    JMP sys_cli # return to the Monitor
3:
    LCA '\n'
    STO A __schar
    JSR sys_spchar sys_spchar_ret
    JMP 2b

pos: BYTE
char: BYTE
    PAG
message: STR "CSCvon8 Monitor, Revision: 2.02 ,type ? for help \nBy Warren Toomey and David Clifford June 2020 \n\n"

#include "monitor.h"

