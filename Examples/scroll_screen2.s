# Scroll screen using indirect indexed instructions
    ORG $9000
1:
    INA
    LCB 'q'
    JEQ sys_cli
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

line:    BYTE
far:  BYTE

# System variables
#include "monitor.h"