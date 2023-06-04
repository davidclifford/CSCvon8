# Test extended instructions that use Flags Register

STO 0 count
STO 0 count+1

loop:
    LDA count
    STO A __number
    LDA count+1
    STO A __number+1
    JSR sys_num_str_16 sys_num_str_16_ret
    LHA     __num_str
    LDB     __num_ptr
    STO     A __string
    STO     B __string+1
    JSR puts
    JOU .
    OUT '\n'
    LDA count+1
    STO A+1 count+1

# Carry
    LDA count
    STO A+C count
# End carry

    JMP loop
    #JMP sys_cli


puts:
2:
    LIA __string
    JAZ 1f
    JOU .
    OUT A
    LDB __string+1
    STO B+1 __string+1
    LDB __string
    STO B+C __string
    JMP 2b
1:
    RTS puts
PAG
count:  HEX "00 00"
pad:    BYTE @253
strptr: BYTE @20

#include "../Examples/monitor.h"

