########################################
# Output count to BANK register at $F000
# David Clifford 21/08/2022
########################################

2:
    LCA @1
    STO A count
1:
    STO A $F000
    LCB @2
    LDA A*B
    STO A count
    JSR wait
    LDA count
    JAZ 3f
    JMP 1b
3:
    LCA $40
    STO A count
1:
    STO A $F000
    LCB @2
    LDA A/B
    STO A count
    JSR wait
    LDA count
    JAZ 2b
    JMP 1b

wait:
    LCB $40
3:
    LDA 0
1:
    LDA A+1
    JAZ 2f
    JMP 1b
2:
    LDB B-1
    JBZ 4f
    JMP 3b
4:
    RTS wait

count: BYTE

#include "monitor.h"
