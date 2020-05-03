# To test new indirect indexed instructions

    LLB mem
    LHA mem
    STO A ptr
1:
    LAI ptr,B
    JAZ 2f
    JOU .
    OUT A
    LDB B+1
    JMP 1b
2:
    LDB 0
    STO B pix
3:
    LCA $3C
    STI A pix,B
    LDA pix
    STO A+1 pix
    LDB B+1
    JMP 3b

ptr:    BYTE @2
pix:    BYTE @240
mem:    STR "Dave"
