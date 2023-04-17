# Clear screen as quickly as possible
    NAME "cls"

    LCA @0
    LCB @119
    STO B plot
1:
    LCB @160
2:
    LDB B-1
    STI 0 plot,B
    JNE 2b
    LDB plot
    STO B-1 plot
    JNE 1b

    JMP sys_cli

plot:   BYTE

#include "monitor.h"
