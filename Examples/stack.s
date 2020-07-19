# Test program to test new stack instructions
#

#define CALL(x) SAS .+7; DSP; JMP x;
#define RET     ISP; JSP;
#define INIT_SP LCA $FE; STO A $FFFF

start:
    INIT_SP
    STO 0 count
    OUT 'A'

    CALL(recure)

    OUT 'Z'

    JMP .

recure:
    LDA count
    LCB @96
    JNE 1f
    RET
1:
    OUT '>'
    LDA count
    LCB ' '
    LDA A+B
    OUT A
    LDA count
    STO A+1 count
    CALL(recure)
    OUT '<'
    LDA count
    LCB ' '
    LDA A+B
    OUT A
    LDA count
    STO A-1 count
    RET

count: BYTE

#include "monitor.h"