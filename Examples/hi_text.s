# Print in text mode to VGA
#
    STO 0 x
    STO 0 y
    STO 0 pos

    LHA mess
    STO A ptr
    LLA mess
    STO A ptr+1
1:
    LIA ptr
    LCB $d0
    LDA A|B
    SIA y
    LDA x
    STO A+1 x
    LDA ptr+1
    STO A+1 ptr+1

    LDA pos
    LDA A+1
    STO A pos
    LCB @6
    JNE 1b
###
    STO 0 x
    STO 0 pos
    LDA y
    STO A+1 y
    LCB @3
    JNE 1b

    JMP monitor

PAG
pos: BYTE
ptr: WORD
y: BYTE
x: BYTE

#          ################# ################# ################# #################
mess: HEX "05 03 08 04 03 08 05 00 0a 05 00 00 05 00 0a 05 00 08 01 03 00 00 03 00"

monitor: EQU $00bb
