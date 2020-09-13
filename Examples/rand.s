#
# Output random number
#
#define OUT(x)	     JOU .; OUT x
#define KEY

start:
    STO 0 seed
loop:
#    JSR random
#    LDA seed
#    STO A num
#    JSR print_num
#    OUT('\n')

    LDA seed
    LCB @120
    STO A%B y
    JSR random
    LDA seed
    LDB seed+1
    LDA A-B
    LCB @160
    STO A%B x
    JSR random
    LDA seed
    LCB $3F
    LDA A&B
    SIA y

1:
#    JIU .
#    INA
#    JAZ 1b
    JMP loop

#############################

random:
    LDA seed
    LDA A+1             # seed+1
    LCB @33
    STO A*BHI seed2    # (seed+1)*33
    LDA A*B
    LDB seed2
    TST A-B JC 1f
    STO A-B-1 seed
    JMP 2f
1:
    LDA A-B
    STO A seed
    LCB $ff
    JNE 2f
    LCA @223 # Hack
    STO A seed
2:
    RTS random

#################################

print_num:
    STO i 0
    LCA '0'
    STO str A
    LCB @1
    LDA num
    JAZ 2f
1:
    LDA num
    JAZ 4f
    LCB $0a
    STO num A/B
    LDA A%B
    LCB '0'
    LDA A+B
    LDB i
    STO A str,B
    STO i B+1
    JMP 1b
4:
    LDB i
2:
    LDB B-1
    LDA str,B
    OUT(A)
    JBZ 3f
    JMP 2b
3:
    RTS print_num

seed: EQU $F100
seed2: EQU $F102

str:    EQU $F000
count:  EQU $F006
num:    EQU $F008
i:      EQU $F00A

y:  BYTE
x:  BYTE