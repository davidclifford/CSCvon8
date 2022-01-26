# Sudoku solver
# David Clifford 05/01/2021
# Update to interactive 26/01/2022
#
    STO 0 __paper
    LCA $3c
    STO A __ink
    JSR sys_cls sys_cls_ret

start:
    STO 0 __paper
    LCA $3c
    STO A __ink
    JSR init_board
    JSR disp_board
    STO 0 pos
    STO 0 fwd
1:
# Display cursor
    LCA $28
    STO A __paper
    LDA pos
    LCB @9
    STO A%B __xpos
    STO A/B __ypos
    LDB pos
    LDA board,B
    JAZ 2f
    LCB '0'
    LDA A+B
    JMP 3f
2:
    LCA ' '
3:
    STO A __char
    JSR sys_pchar sys_pchar_ret

# Wait for key press
    LDA fwd
    JAZ 4f
    JMP 5f
4:
    JIU .
5:
# Remove cursor
    LDB pos
    LDA back,B
    STO A __paper
    LDA pos
    LCB @9
    STO A%B __xpos
    STO A/B __ypos
    LDB pos
    LDA board,B
    JAZ 2f
    LCB '0'
    LDA A+B
    JMP 3f
2:
    LCA ' '
3:
    STO A __char
    JSR sys_pchar sys_pchar_ret

    LDA fwd
    JAZ 6f
    STO 0 fwd
    JMP right_cur
6:
    INA
    LCB 'g'
    JEQ go
    LCB 'x'
    JEQ exit
    LCB 'a'
    JEQ left_cur
    LCB 'd'
    JEQ right_cur
    LCB 'w'
    JEQ up_cur
    LCB 's'
    JEQ down_cur
    LCB '0'
    JLO 1b
    LCB '9'
    JHI 1b
# place number
    LCB '0'
    LDA A-B
    STO A n
    JAZ 7f
    JSR valid_move
    LDA result
# Not valid
    JAZ 1b
# Valid number (so far) or zero
7:
    LDA n
    LDB pos
    STO A board,B
    LCA @1
    STO A fwd
    JMP 1b
left_cur:
    LDA pos
    JAZ 1b
    STO A-1 pos
    JMP 1b
right_cur:
    LDA pos
    LCB @80
    JEQ 1b
    STO A+1 pos
    JMP 1b
up_cur:
    LDA pos
    LCB @9
    JLT 1b
    STO A-B pos
    JMP 1b
down_cur:
    LDA pos
    LCB @71
    JGT 1b
    LCB @9
    STO A+B pos
    JMP 1b
go:
    LCA $30
    STO A __ink
    JSR solve
    LCA $0c
    STO A __ink
    JSR disp_board
end:
    JIU .
    JMP start
exit:
    JMP sys_cli
failed:
    LCA $30
    STO A __ink
    JSR disp_board
    JMP end

# Initialise the board from the init string
init_board:
    STO 0 count
    STO 0 sp
1:
    JSR set_background
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

# Display the board on the terminal
disp_board_term:
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

set_background:
# Set background colour in 'back' array
    LDA count
    LCB @3
    LDA A/B
    LDA A%B
    LCB @2
    STO A%B backgr
    LDA count
    LCB @27
    LDA A/B
    LDB backgr
    LDA A+B
    LCB @2
    LDA A%B
    LCB @4
    STO A*B backgr
    LDA count
    LCB @2
    LDA A%B
    LDA A+1
    LDB backgr
    LDA A+B
    LDB count
    STO A back,B
    RTS set_background

# Display the board on the screen
disp_board:
    STO 0 __xpos
    STO 0 __ypos
    STO 0 count
4:
    LDB count
    LDA back,B
    STO A __paper
    LDA board,B
    JAZ 1f
    LCB '0'
    LDA A+B
    STO A __char
    JSR sys_pchar sys_pchar_ret
    JMP 2f
1:
    LCA ' '
    STO A __char
    JSR sys_pchar sys_pchar_ret
2:
    LDA count
    STO count A+1
    LCB @81
    JLO 3f
    RTS disp_board
3:
    LDA count
    LCB @9
    LDA A%B
    JAZ 1f
    JMP 4b
1:
    LCA '\n'
    STO A __char
    JSR sys_pchar sys_pchar_ret
    JMP 4b

# Display backtrack
# pos is the position
disp_backtrack:
    LDB pos
    LDA back,B
    STO A __paper
    LDA pos
    LCB @9
    STO A%B __xpos
    STO A/B __ypos
    LCA ' '
    STO A __char
    JSR sys_pchar sys_pchar_ret
    RTS disp_backtrack

# Display guess
# pos is the position
# try is the guess
disp_guess:
    LDB pos
    LDA back,B
    STO A __paper
    LDA pos
    LCB @9
    STO A%B __xpos
    STO A/B __ypos
    LDA try
    LCB '0'
    STO A+B __char
    JSR sys_pchar sys_pchar_ret
    RTS disp_guess

# Verify valid move
# input pos, n
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

# Solve the puzzle - using a stack
solve:
    STO 0 pos
    LCA @1
    STO A try
1:
    INA
    LCB 'x'
    JEQ end
    LCB 'q'
    JEQ start

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
    JSR disp_guess
    JMP 4f
3:
# Doesnt fit
    LDA try
    STO A+1 try
    JMP 1b

# Backtrack
5:
    LDB sp
    LDB B-1
#Underflow
    LCA $FF
    JEQ failed
    STO B sp
    LDA ns,B
    STO A+1 try
    LDB ps,B
    STO 0 board,B
    STO B pos
    JSR disp_backtrack
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
#init: STR "210390405090007002003280010001002004040830027820040103000010738080063200304900050" # <1 sec
#init: STR "070250400800000903000003070700004020100000007040500008090600000401000005007082030" # ~80 secs
#init: STR "513400026004752010070316095069038001201500063735091000006070000000004000300000209" # Easy
#init: STR "513490026004752010070316095069038001201500063735091000006070000000004000300000209" # Broken
#init: STR "840060501000003040006900007020710006000630000900000050000040060200000180005000300" # Easy
#init: STR "085319000000052600403000900009000800000027000034108000806004030000200008090835700" # Medium
init: STR "002090600000040003100008000730000002080000400000000008900000005050034020000620001" # Expert
#init: STR "000000000000000000000000000000000000000000000000000000000000000000000000000000000" #


PAG
board:  BYTE
PAG
ps:     BYTE
PAG
ns:     BYTE
PAG
back:   BYTE
PAG
sp:     BYTE
count:  BYTE
pos:    BYTE
p:      BYTE
n:      BYTE
result: BYTE
try:    BYTE
backgr: BYTE
fwd:    BYTE

#include "../Examples/monitor.h"