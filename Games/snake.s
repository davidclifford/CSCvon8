# Snake for the CSCvon8
# By David Clifford Oct 2020
#
# Start
start:
    STO 0 __paper
    JSR sys_cls sys_cls_ret

# Draw Arena
    LDB 0
1:
    LCA $03
    STO A $0800,B
    STO A $5800,B
    LDB B+1
    LCA @80
    JNE 1b

    LCA $03
    LCB $08
    STO B line
1:
    LCA $03
    LDB 0
    STI A line,B
    LCB @79
    STI A line,B
    LDB line
    STO B+1 line
    LCA $58
    JNE 1b

# Draw Text
# Display 'Snake' multi-coloured
    LCA $30
    STO A __ink
    LCA @6
    STO A __xpos
    STO 0 __ypos
    LCA 'S'
    STO A __char
    JSR sys_pchar sys_pchar_ret
    LCA $0C
    STO A __ink
    LCA 'n'
    STO A __char
    JSR sys_pchar sys_pchar_ret
    LCA $0F
    STO A __ink
    LCA 'a'
    STO A __char
    JSR sys_pchar sys_pchar_ret
    LCA $3C
    STO A __ink
    LCA 'k'
    STO A __char
    JSR sys_pchar sys_pchar_ret
    LCA $33
    STO A __ink
    LCA 'e'
    STO A __char
    JSR sys_pchar sys_pchar_ret

# Display text 'Score'
    STO 0 __sink
    LCA @1
    STO A __sxpos
    STO A __sypos
    LHA score_text
    LCB score_text
    STO A __string
    STO B __string+1
    JSR sys_spstring sys_spstring_ret
    STO 0 score0
    STO 0 score1
    STO 0 score2

# Init snake
    LCA @42
    STO A y
    LCB @42
1:
    LCA $0C
    STI A y,B
    LDB B+1
    LCA @47
    JNE 1b

    LCA @42
    STO A tail
    LCA @42
    STO A tail+1
    LCA @46
    STO A head
    LCA @42
    STO A head+1
    STO 0 dir
    LCA @5
    STO A food_flag

# Play loop
# Random food
new_food:
    LDA food_flag
    JAZ loop
    JSR sys_rand sys_rand_ret
    LDA __rand_seed
    LCB @80
    LDB A%B
    LCA @8
    STO A+B pixel

    LDA __rand_seed+1
    LCB @80
    LDB A%B
    STO B x
    VAI pixel,B
    JAZ 1f
    JMP new_food
1:
    LDB x
    LCA $30
    STI A pixel,B
    LDA food_flag
    STO A-1 food_flag
    JMP new_food

# DIR 0=right 1=down 2=left 3=up
loop:
    JIU wait
    INA
    LCB 's'
    JEQ 1f
    LCB 'a'
    JEQ 2f
    LCB 'w'
    JEQ 3f
    LCB 'd'
    JEQ 4f
    LCB 'q'
    JEQ 5f
wait:
    LDA delay
    STO A-1 delay
    JAZ 6f
    JMP loop
6:
    LDA delay+1
    STO A-1 delay+1
    JAZ 7f
    JMP loop
7:
    LCA @60
    STO A delay+1
    JMP move_snake
1:
    LCA @1
    STO A dir
    JMP wait
2:
    LCA @2
    STO A dir
    JMP wait
3:
    LCA @3
    STO A dir
    JMP wait
4:
    STO 0 dir
    JMP wait
5:
    JMP start

# Move snake
move_snake:
    STO 0 u
    STO 0 v
    LDA dir
    LCB @1
    JEQ 1f
    LCB @2
    JEQ 2f
    LCB @3
    JEQ 3f
# Right
    LCA @1
    STO A u
    JMP 4f
# Down
1:
    LCA @1
    STO A v
    JMP 4f
# Left
2:
    LCA $FF
    STO A u
    JMP 4f
# Up
3:
    LCA $FF
    STO A v
4:
# Collision
    LDA head+1
    LDB v
    STO A+B y
    LDA head
    LDB u
    STO A+B x
    LDB x
    VAI y,B
    JAZ empty_space
    LCB $30
    JEQ eat_apple
    JMP dead

# Eat apple
eat_apple:
    JSR display_score
    LCA @1
    STO A food_flag
    JMP move_head

empty_space:
# Update tail
    LDA tail+1
    STO A ty
    LDB tail
    VAI ty,B
    STO A d
    LCA $00
    STI A ty,B
    LDA d
    LCB $0C
    JEQ 1f
    LCB $3c
    JEQ 2f
    LCB $33
    JEQ 3f
    LCB $0f
    JEQ 4f
# up
4:
    LDA tail+1
    STO A-1 tail+1
    JMP move_head
# right
1:
    LDA tail
    STO A+1 tail
    JMP move_head
# down
2:
    LDA tail+1
    STO A+1 tail+1
    JMP move_head
# left
3:
    LDA tail
    STO A-1 tail

# Update head
move_head:
    LDA dir
    LCB @1
    JEQ 1f
    LCB @2
    JEQ 2f
    LCB @3
    JEQ 3f

    LCA $0c
    JMP 4f
1:
    LCA $3c
    JMP 4f
2:
    LCA $33
    JMP 4f
3:
    LCA $0f
4:
    LDB head
    STI A head+1,B

    LDB x
    STI A y,B

    LDA x
    STO A head
    LDA y
    STO A head+1

    LDA food_flag
    JAZ loop
    JMP new_food

dead:

# Display
    LCA $05
    STO A __sink
    LCA @8
    STO A __sxpos
    LCA @10
    STO A __sypos
    LHA game_over_text
    LCB game_over_text
    STO A __string
    STO B __string+1
    JSR sys_spstring sys_spstring_ret
1:
    JIU 1b
    INA
    LCB '\n'
    JEQ 2f
    LCB '\r'
    JEQ 2f
    LCB 'q'
    JEQ exit_game
    JMP 1b
2:
    JMP start

display_score:
    LCB @9
    LDA score0
    STO A+1 score0
    JNE 1f
    STO 0 score0
    LDA score1
    STO A+1 score1
    JNE 1f
    STO 0 score1
    LDA score2
    STO A+1 score2
    JNE 1f
    STO 0 score2
1:
    STO 0 __ink
    LCB @1
    STO B __sypos
    LCB @7
    STO B __sxpos
    LDA score2
    LCB '0'
    STO A+B __schar
    JSR sys_spchar sys_spchar_ret
    LDA score1
    LCB '0'
    STO A+B __schar
    JSR sys_spchar sys_spchar_ret
    LDA score0
    LCB '0'
    STO A+B __schar
    JSR sys_spchar sys_spchar_ret
    RTS display_score

# Exit to monitor
exit_game:
    JMP sys_cli

# PAG
score_text: STR "Score 000"
game_over_text: STR "Game Over!"
line:   BYTE
length: BYTE
head:   WORD
tail:   WORD
pixel:  BYTE
x:      BYTE
y:      BYTE
u:      BYTE
v:      BYTE
dir:    BYTE
tx:     BYTE
ty:     BYTE
d:      BYTE
count:  BYTE
score0:  BYTE
score1:  BYTE
score2:  BYTE
delay:  WORD
food_flag:  BYTE

# System variables
#include "../Examples/monitor.h"
