# To test clearing the screen fast
loop:
    LCA $30
    STO A __ink
    LCA $3f
    STO A __paper
    LCA @8
    STO A __xpos
    LCA @14
    STO A __ypos
    STO 0 x
1:
    LDB x
    LDA mess,B
    JAZ 2f
    STO A __char
    JSR sys_pchar sys_pchar_ret
    LDB x
    STO B+1 x
    JMP 1b
2:
    LCA $0c
    STO A __ink
    LCA $03
    STO A __paper
    LCA @8
    STO A __xpos
    LCA @0
    STO A __ypos
    STO 0 x
1:
    LDB x
    LDA mess,B
    JAZ 2f
    STO A __char
    JSR sys_pchar sys_pchar_ret
    LDB x
    STO B+1 x
    JMP 1b
2:
    JIU .
    INA
clear:
    LDA 0
1:
    LDB 0
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    CL4 A,B
    LDA A+1
    JAN 2f
    JMP 1b
2:
    JMP loop
    JIU .
    INA
    JMP sys_cli

yu:    BYTE
yd:    BYTE
x:    BYTE
pix:  BYTE
PAG
mess: STR "Hello, World"

#include "monitor.h"
