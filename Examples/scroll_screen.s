# Scroll screen using indirect indexed instructions
1:
    INA
    LCB 'q'
    JEQ sys_cli
2:
    LCA @120
    STO A to
    LDB 0
    STO B from
3:
    LDB 0
4:
    VAI from,B
    STI A to,B
    LDB B+1
    LCA @160
    JNE 4b
    LDA to
    LCB @120
    JEQ 6f
    STO A+1 to
7:
    LDA from
    STO A+1 from
    LCB @120
    JNE 3b

    LDB 0
    JMP 1b
6:
    STO 0 to
    JMP 7b

to:    BYTE
from:  BYTE

# System variables
#include "monitor.h"

