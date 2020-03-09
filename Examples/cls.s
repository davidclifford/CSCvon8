# Clear screen as quickly as possible
    STO 0 plot+1
1:
    LCB $00
plot:
    STO 0 $0000,B
    LDB B+1
    LCA @160
    JNE plot
    LDA plot+1
    STO A+1 plot+1
    LCB @120
    JNE 1b

    JMP $001f # return to the Monitor
