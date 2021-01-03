# Sudoku solver
# David Clifford 03/01/2021
#
    LCA @17
    STO A debug
start:
    JSR init_board
    JSR disp_board

    LCB @5
    STO B pos
    LCA @7
    STO A n
    JSR valid_move
    JSR disp_board
    LDA result
    LCB '0'
    LDA A+B
    OUT A
    JMP sys_cli

# Initialise the board from the init string
init_board:
    STO 0 count
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

PAG
init: STR "210390405090007002003280010001002004040830027820040103000010738080063200304900050"
PAG
board:  BYTE
PAG
xs:     BYTE
PAG
ys:     BYTE
PAG
ns:     BYTE
PAG
sp:     BYTE
count:  BYTE
pos:    BYTE
p:      BYTE
n:      BYTE
result: BYTE
debug:  BYTE

#include "../Examples/monitor.h"