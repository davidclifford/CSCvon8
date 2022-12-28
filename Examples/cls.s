# Clear screen as quickly as possible
    NAME "cls"

    STO 0 plot
1:
    LDB 0
    LCA @160
2:
    STI 0 plot,B
    LDB B+1
    JNE 2b
    LDB plot
    STO B+1 plot
    LCA @119
    JNE 1b

    JMP sys_cli

plot:   BYTE

#include "monitor.h"
