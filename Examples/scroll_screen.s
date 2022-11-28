# Scroll screen using indirect indexed instructions
    STO 0 last
1:
    INA
    JAZ 8f
    STO A last
8:
    LDA last
    LCB 'q'
    JEQ sys_cli
    LCB 'a'
    JEQ scroll_left
    LCB 'w'
    JEQ scroll_up
    LCB 'd'
    JEQ scroll_right
    LCB 's'
    JEQ scroll_down
    JMP 1b

scroll_up:
2:
    LCA @120
    STO A to
    STO 0 from
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
    JMP 1b
6:
    STO 0 to
    JMP 7b

scroll_down:
2:
    LCA @119
    STO A from
    STO A+1 to
3:
    LDB 0
4:
    VAI from,B
    STI A to,B
    LDB B+1
    LCA @160
    JNE 4b

    LDA from
    JAZ 6f
    LCB @120
    JEQ 1b

    LDA from
    STO A to
    STO A-1 from

    JMP 3b
6:
    LCA @120
    STO A from
    LDA to
    STO A-1 to
    JMP 3b

scroll_left:
    LDA 0
    STO A line
2:
    LDB 0
    VAI line,B
    STO A far
    LCB @1
4:
    VAI line,B
    LDB B-1
    STI A line,B
    LDB B+1
    LDB B+1
    LCA @161
    JNE 4b
    LCB @159
    LDA far
    STI A line,B
    LDA line
    STO A+1 line
    LCB @120
    JNE 2b
    JMP 1b

scroll_right:
    LDA 0
    STO A line
2:
    LCB @159
    VAI line,B
    STO A far
    LCB @158
4:
    VAI line,B
    LDB B+1
    STI A line,B
    LDB B-1
    LDB B-1
    LDA $FF
    JNE 4b
    LDB 0
    LDA far
    STI A line,B
    LDA line
    STO A+1 line
    LCB @120
    JNE 2b
    JMP 1b

PAG
to:    BYTE
from:  BYTE
last:  BYTE
line:  BYTE
far:   BYTE

# System variables
#include "monitor.h"
