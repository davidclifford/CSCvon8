#define JOUT(x)	     JOU .; OUT x
#define JINA	     JIU .; INA
start:
    LCA @4
    STO A cnt
    JOUT('\n')
    STO 0 num
    STO 0 num+1
1:
    JINA
    JOUT(A)
    LCB ' '
    JEQ 1b
    LCB '\n'
    JEQ 2f
    LCB '\r'
    JEQ 2f
    LCB '0'
    JLT 2f
    LCB ':'
    JLT 3f
    LCB 'A'
    JLT 2f
    LCB 'G'
    JLT 5f
    LCB 'a'
    JLT 2f
    LCB 'g'
    JLT 6f
    JMP 2f
3:
    LCB '0'
    LDA A-B
    JMP 4f
5:
    LCB 'A'
    LDA A-B
    LCB @10
    LDA A+B
    JMP 4f
6:
    LCB 'a'
    LDA A-B
    LCB @10
    LDA A+B
4:
    STO A digit
# Multiply num by 16 and add digit
    LCB @16
    LDA num
    STO A*B num
    LDA num+1
    STO A*B num+1
    LDA A*BHI
    LDB num
    STO A+B num
    LDA num+1
    LDB digit
    STO A+B num+1

#    LDA cnt
#    LDA A-1
#    STO A cnt
#    JAZ 2f0
    JMP 1b
2:
    JOUT('\n')
    LDA num
    STO A __hex
    JSR sys_phex sys_phex_ret
    LDA num+1
    STO A __hex
    JSR sys_phex sys_phex_ret
    JOUT('\n')
    JMP start

cnt:    BYTE
digit:  BYTE
num:    WORD

#include "monitor.h"
