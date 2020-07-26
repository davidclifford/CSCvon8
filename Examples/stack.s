#
# Test program to test new stack instructions
#

#define CALL(x) SAS .+7; IS2; JMP x;
#define RET     DS2; JSP;
#define INIT_SP STO 0 $FFFF;
#define PUSHA   PUA; IS1;
#define POPA    DS1; PLA;

start:
    INIT_SP

    STO 0 count
    CALL(print)
    JMP sys_cli

print:
    LDA count
    LCB '@'
    LDB A+B
    OUT B
    STO A+1 count
    LCB @26
    JEQ 1f
    CALL(print)
    LDA count
    LDA A-1
    STO A count
    LCB '`'
    LDB A+B
    OUT B
1:
    RET

count: BYTE

#include "monitor.h"