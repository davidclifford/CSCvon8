# To test new indirect indexed instructions

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
    JIU .
    INA
scroll:
    LDA 0
    STO A yu
    LCB @1
    STO B yd
3:
    LDB 0
4:
    VAI yd,B
    STI A yu,B
    LDB B+1
    LCA @160
    JNE 4b
    LDA yu
    STO A+1 yu
    LDA yd
    STO A+1 yd
    LDB yd
    LCA @120
    JNE 3b

    JMP scroll

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