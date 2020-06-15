# To test new indirect indexed instructions
    LCA $00
    STO A bakg
1:
#    JIU .
    INA
    LCB 'q'
    JEQ monitor
2:
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

    LDB 0
5:
    LDA bakg
    STO A $7700,B
    LDB B+1
    LCA @160
    JNE 5b

    JMP 1b

yu:    BYTE
yd:    BYTE

# System variables
monitor: EQU $00bb
bakg: EQU $fd12
