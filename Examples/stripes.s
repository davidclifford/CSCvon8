start:
    JIU .
    INA
    STO 0 plot+1
1:
    LCB $00
2:
    LDA plot+1
    LDA A+B
plot:
    STO A $0000,B
    LDB B+1
    LCA @160
    JNE 2b
    LDA plot+1
    STO A+1 plot+1
    LCB @120
    JNE 1b
    JIU .
    INA
    STO 0 plot1+1
1:
    LCB $00
2:
    LDA plot1+1
    LDA A-B
plot1:
    STO A $0000,B
    LDB B+1
    LCA @160
    JNE 2b
    LDA plot1+1
    STO A+1 plot1+1
    LCB @120
    JNE 1b

    JIU .
    INA
    STO 0 plot2+1
1:
    LCB $00
2:
    LDA B
plot2:
    STO A $0000,B
    LDB B+1
    LCA @160
    JNE 2b
    LDA plot2+1
    STO A+1 plot2+1
    LCB @120
    JNE 1b

    JIU .
    INA
    STO 0 plot3+1
1:
    LCB $00
2:
    LDA plot3+1
plot3:
    STO A $0000,B
    LDB B+1
    LCA @160
    JNE 2b
    LDA plot3+1
    STO A+1 plot3+1
    LCB @120
    JNE 1b

    JMP start
