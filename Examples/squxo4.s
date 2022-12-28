##########################
# Test ROM bank 10-18
# Returns n*n/4 at addresses n*4, n*4+1, n*4+2, n*4+3 giving 32-bit unsigned result, bank = n<<2 | $10
###########################

#define JOUT(x)	     JOU .; OUT x

    LDA num
    LCB @8
    LDA A*BHI
    LCB $18 # Square
    # LCB $10 # Square/4
    STO A|B bank

    LDA num
    LCB @4
    LDA A*B
    LCB $7F
    LDA A&B
    STO A addr

    LDA num+1
    LCB @4
    LDA A*BHI
    LDB addr
    STO A|B addr

    LDA num+1
    LCB @4
    STO addr+1 A*B

    LDA bank
    STO A $F000

    LDB addr+1
    VAI addr,B
    STO A ans
    LDB B+1
    VAI addr,B
    STO A ans+1
    LDB B+1
    VAI addr,B
    STO A ans+2
    LDB B+1
    VAI addr,B
    STO A ans+3

# ans should now have 32-bit answer of num*num/4

    JOUT('\n')
    LDA bank
    STO A __hex
    JSR sys_phex sys_phex_ret
    JOUT('\n')
    LDA addr
    STO A __hex
    JSR sys_phex sys_phex_ret
    LDA addr+1
    STO A __hex
    JSR sys_phex sys_phex_ret
    JOUT('\n')
    LDA ans
    STO A __hex
    JSR sys_phex sys_phex_ret
    LDA ans+1
    STO A __hex
    JSR sys_phex sys_phex_ret
    LDA ans+2
    STO A __hex
    JSR sys_phex sys_phex_ret
    LDA ans+3
    STO A __hex
    JSR sys_phex sys_phex_ret
    JOUT('\n')

    STO 0 $F000
    JMP sys_cli

num:  HEX "FF FF"
addr: WORD
bank: BYTE
ans:  BYTE @4


#include "monitor.h"