# Scroll screen up 4 pixels using indirect indexed instructions
# Blank last 4 lines
#
1:
    INA
    LCB 'q'
    JEQ sys_cli
2:
    LCA @0
    STO A to
    LCB @4
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
    STO A+1 to
    LDA from
    STO A+1 from
    LCB @119
    JNE 3b
5:
    LDB 0
6:
    STI 0 to,B
    LDB B+1
    LCA @160
    JNE 6b
    LDA to
    STO A+1 to
    LCB @120
    JNE 5b
    JMP 1b

to:    BYTE
from:  BYTE

# System variables
#include "monitor.h"

