#define JINA	     JIU .; INA
#define JOUA	     JOU .; OUT A

#
# Move char around screen
#
    LCA $02
    STO A bakg
    JSR cls cls_ret

# Set up X & Y position, background and foreground colour
    LCA @10 # x = 0
    STO A xpos
    LCB @10 # y = 0
    STO B ypos
    LCA $30 # RED
    STO A forg
    LCB $0C # GREEN
    STO B bakg

next_input:
    LCA '*'
    STO A char

    JSR pchar pchar_ret
    LDA xpos
    STO A-1 xpos

    JINA
    JOUA

    LCB 'd'
    JEQ right
    LCB 'a'
    JEQ left
    LCB 'w'
    JEQ up
    LCB 's'
    JEQ down
    LCB @27
    JEQ monitor # return to the Monitor
    JMP next_input

left:
    LDA xpos
    STO A-1 xpos
    JMP next_input
right:
    LDA xpos
    STO A+1 xpos
    JMP next_input
up:
    LDA ypos
    STO A-1 ypos
    JMP next_input
down:
    LDA ypos
    STO A+1 ypos
    JMP next_input

monitor: EQU $001c
pchar: EQU $02d3
pchar_ret: EQU $fff4
cls: EQU $02aa
cls_ret: EQU $fffe
char: EQU $fd11
xpos: EQU $fd10
ypos: EQU $fd0f
bakg: EQU $fd12
forg: EQU $fd13
