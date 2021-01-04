# Sudoku solver
# David Clifford 03/01/2021
#
    LCA @17
    STO A debug
start:
    JSR init_board
    JSR disp_board
    OUT '\n'

    JSR solve
    OUT '\n'
    JSR disp_board

    JMP sys_cli

# Initialise the board from the init string
init_board:
    STO 0 count
    STO 0 sp
1:
    LDB count
    LDA init,B
    LCB '0'
    LDA A-B
    LDB count
    STO A board,B
    LDA count
    LCB @81
    STO A+1 count
    JLO 1b
    RTS init_board

# Display the board on the screen
disp_board:
    STO 0 count
3:
    LDA count
    LCB @9
    LDA A%B
    JAZ 1f
    JMP 2f
1:
    OUT '\n'
2:
    LDB count
    LDA board,B
    JAZ 1f
    LCB '0'
    LDA A+B
    OUT A
    JMP 2f
1:
    OUT '.'
2:
    LDA count
    STO count A+1
    LCB @81
    JLO 3b
    RTS disp_board

# Verify valid move
# input x, y, n
# result 0 no, 1 yes
valid_move:
    STO 0 result # 0 = false
# X, look vertically
    LDA pos
    LCB @9
    STO B count
    STO A%B p
1:
    LDB p
    LDA board,B
    LDB n
    JEQ 2f
    LDB p
    LCA @9
    STO A+B p
    LDA count
    LDA A-1
    JAZ 3f
    STO A count
    JMP 1b
2:
    RTS valid_move
3:
# Y, look horizontally
    LDA pos
    LCB @9
    LDA A/B
    STO A*B p
    STO B count
1:
    LDB p
    LDA board,B
    LDB n
    JEQ 2b
    LDA p
    STO A+1 p
    LDA count
    LDA A-1
    JAZ 3f
    STO A count
    JMP 1b
3:
# Q, look in square
    LCB @9
    LDA pos
    LDA A/B

    LCB @3
    LDA A/B
    LDA A*B
    LCB @9
    STO A*B p

    LDA pos
    LDA A%B
    LCB @3
    LDA A/B
    LDA A*B
    LDB p
    STO A+B p

    STO 0 count
1:
    LDB p
    LDA board,B
    LDB n
    JEQ 2b

    LDA p
    STO A+1 p
    LDA count
    LDA A+1
    STO A count
    LCB @3
    LDA A%B
    JAZ 3f
    JMP 2f
3:
    LDA p
    LCB @6
    STO A+B p
2:
    LDA count
    LCB @9
    JLO 1b

    LDA result
    STO A+1 result
    RTS valid_move

# Solve the puzzle - using stack
solve:
    STO 0 pos
    LCA @1
    STO A try
1:
    LDB pos
    LDA board,B
    JAZ 2f
    JMP 4f
# Empty place
2:
    LDA try
    LCB @9
    JGT 5f

    STO A n
    LDB pos
    STO B p
    JSR valid_move
    LDA result
    JAZ 3f

# Found posible
    OUT '.'
    LDB pos
    LDA try
    STO A board,B

# Put position and guess on stack
    LDB sp
    LDA try
    STO A ns,B
    LDA pos
    STO A ps,B
    STO B+1 sp

    JMP 4f
3:
# Doesnt fit
    LDA try
    STO A+1 try
    JMP 1b

# Backtrack
5:
    OUT '<'
    LDB sp
    LDB B-1
    STO B sp
    LDA ns,B
    STO A+1 try
    LDB ps,B
    STO 0 board,B
    STO B pos
    JMP 1b
4:
# Next pos
    LCA @1
    STO A try
    LDA pos
    LDA A+1
    STO A pos
    LCB @81
    JLT 1b

    RTS solve

PAG
init: STR "210390405090007002003280010001002004040830027820040103000010738080063200304900050"
#init: STR "070250400800000903000003070700004020100000007040500008090600000401000005007082030"
PAG
board:  BYTE
PAG
ps:     BYTE
PAG
ns:     BYTE
PAG
sp:     BYTE
count:  BYTE
pos:    BYTE
p:      BYTE
n:      BYTE
result: BYTE
try:    BYTE
debug:  BYTE

#include "../Examples/monitor.h"