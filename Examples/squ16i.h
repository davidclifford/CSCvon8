#
# Square a signed 16 bit number normalised to fixed point numbers (1.0 = 256)
# INLINE version
# 14/05/2022
#
# i.e. 1.0 is represented as 256, 0.5 as 128, 2.0 as 512 etc...
#
# Input: num1 (16 bit)
# Output: answ+1,+2 (16 bit)
#
squ16i:
# multiply answ = num1 * num1
# Is num1 negative?
    LDA     num1
    JAN     1f
    JMP     3f
# Num1 is negative
1:
    STO     !A num1
    LDA     num1+1
    LDA     !A
    STO     A+1 num1+1
    TST     A+1 JC 2f
    JMP     3f
2:
    LDA     num1
    STO     A+1 num1
3:
# Multiply num1 * num1
    LDA     num1+1
    LDB     A
    STO     A*BHI answ+2

    LDA     num1+1
    LDB     num1
    STO     A*B temp
    STO     A*BHI answ+1

    LDA     answ+2
    LDB     temp
    STO     A+B answ+2
    TST     A+B JC 1f
    JMP 2f
1:
    LDA     answ+1
    STO     A+1 answ+1
2:
    LDA     num1
    LDB     num1+1
    STO     A*B temp
    STO     A*BHI temp2

    LDA     answ+2
    LDB     temp
    STO     A+B answ+2
    TST     A+B JC 1f
    JMP 2f
1:
    LDA     answ+1
    STO     A+1 answ+1
2:
    LDA     answ+1
    LDB     temp2
    STO     A+B answ+1
    LDA     num1
    LDB     A
    STO     A*B temp

    LDA     answ+1
    LDB     temp
    STO     A+B answ+1
