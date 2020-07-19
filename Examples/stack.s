# Test program to test new stack instructions
#

#define CALL(x) SAS .+7; DS2; JMP x;
#define RET     IS2; JSP;
#define INIT_SP LCA $FE; STO A $FFFF
#define PUSHA   PUA; DS1;
#define POPA    IS1; PLA;

start:
    INIT_SP

    LCA '1'
    PUSHA
    LCA '2'
    PUSHA
    CALL(print)
    POPA
    OUT A
    POPA
    OUT A

    JMP $FFFF

print:
    OUT 'X'
    GSA @4
    OUT A
    LCB @10
    LDA A+B
    PSA @4
    RET

#include "monitor.h"