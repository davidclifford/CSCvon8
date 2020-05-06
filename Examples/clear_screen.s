# To test clearing the screen fast
loop:
    LCA $30
    STO A forg
    LCA $3f
    STO A bakg
    LCA @8
    STO A xpos
    LCA @14
    STO A ypos
    STO 0 x
1:
    LDB x
    LDA mess,B
    JAZ 2f
    STO A char
    JSR pchar pchar_ret
    LDB x
    STO B+1 x
    JMP 1b
2:
    LCA $0c
    STO A forg
    LCA $03
    STO A bakg
    LCA @8
    STO A xpos
    LCA @0
    STO A ypos
    STO 0 x
1:
    LDB x
    LDA mess,B
    JAZ 2f
    STO A char
    JSR pchar pchar_ret
    LDB x
    STO B+1 x
    JMP 1b
2:
    JIU .
    INA
clear:
    LDA 0
1:
    LDB 0
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    LDA A+1
    JAN 2f
    JMP 1b
2:
    JMP loop
    JIU .
    INA
    JMP monitor

yu:    BYTE
yd:    BYTE
x:    BYTE
pix:  BYTE
PAG
mess: STR "Hello, World"

# System variables
monitor: EQU $0006
pchar: EQU $02d3
pchar_ret: EQU $fff4
char: EQU $fd11
xpos: EQU $fd10
ypos: EQU $fd0f
bakg: EQU $fd12
forg: EQU $fd13