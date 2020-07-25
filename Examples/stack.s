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

    LCA '1'
    PUSHA
    OUT A
    LCA '2'
    PUSHA
    OUT A
    CALL(print)
    POPA
    OUT A
    POPA
    OUT A

    JMP sys_cli

print:
    OUT '<'
    GSA @4
    OUT A
    LCB @2
    LDA A+B
    PSA @4
    OUT '>'
    RET

#include "monitor.h"