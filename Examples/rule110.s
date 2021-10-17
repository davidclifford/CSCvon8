#
# RULE 110 to show turing completeness
# David Clifford 10/10/2021
#

# BOARD_CAP = 122
# board = [0 for _ in range(BOARD_CAP)]
#
# board[BOARD_CAP - 2] = 1
# for i in range(BOARD_CAP-2):
#
#     for j in range(BOARD_CAP):
#         print(" *"[board[j]], end='');
#     print()
#
#     pattern = (board[0] << 1) | board[1]
#     for j in range(1, BOARD_CAP-1):
#         pattern = ((pattern << 1) & 7) | board[j + 1]
#         board[j] = (110 >> pattern) & 1

#define BOARD_CAP @122
#define BOARD_CAP1 @121
#define BOARD_CAP2 @120

# Initilise board to all zeros
    LDB 0
    LCA BOARD_CAP
1:
    STO 0 board,B
    LDB B+1
    JEQ 2f
    JMP 1b
2:
# board[BOARD_CAP-2] = 1
    LCB BOARD_CAP2
    LCA @1
    STO A board,B
# for i = 0 to BOARD_CAP-2
    STO 0 i
next_i:
# for j = 1 to BOARD_CAP
    LCA @1
    STO A j
next_j:
    LDB j
    LDA board,B
    JAZ 1f
    LCA $3C
    STI A i,B
    JMP 2f
1:
    LCA $03
    STI A i,B
2:
    LDA j
    LDA A+1
    STO A j
    LCB BOARD_CAP1
    JEQ 1f
    JMP next_j
1:
#     pattern = (board[0] << 1) | board[1]
    LDA board
    LDB A
    LDA A+B
    LDB board+1
    STO A|B pattern
#     for j in range(1, BOARD_CAP-1):
    LCA @1
    STO A j
next_j1:
#         pattern = ((pattern << 1) & 7) | board[j + 1]
    LDA pattern
    LDB A
    LDA A+B
    LCB $07
    STO A&B pattern
    LDB j
    LDB B+1
    LDA board,B
    LDB pattern
    STO A|B pattern
#         board[j] = (110 >> pattern) & 1
    LDB pattern
    LCA @110
    LDA A>>B
    LCB @1
    LDA A&B
    LDB j
    STO A board,B
# next j
    LDB B+1
    LCA BOARD_CAP1
    JEQ 1f
    STO B j
    JMP next_j1
1:
    LDA i
    LDA A+1
    STO A i
    LCB BOARD_CAP2
    JEQ 1f
    JMP next_i
# Exit
1:
    JMP sys_cli

PAG
board: BYTE
PAG
i: BYTE
j: BYTE
pattern: BYTE

#include "monitor.h"