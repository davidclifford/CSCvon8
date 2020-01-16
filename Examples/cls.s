    STO 0 plot+1
1:
    LCB $00
2:
    LDA 0
plot:
    STO A $0000,B
    LDB B+1
    LCA @160
    JNE 2b
    LDA plot+1
    STO A+1 plot+1
    LCB @120
    JNE 1b
    JMP $001c # return to the Monitor
