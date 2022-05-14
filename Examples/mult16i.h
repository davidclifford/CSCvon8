#
# Multiply 2 signed 16 bit numbers normalised to fixed point numbers (1.0 = 256)
# INLINE version
# 14/05/2022
#
# i.e. 1.0 is represented as 256, 0.5 as 128, 2.0 as 512 etc...
#
# Input: num1, num2 (16 bit each)
# Output: answ+1,+2 (16 bit)
#
mult16i:
    STO     0 sign1
    STO     0 sign2
    STO     0 signA

# multiply answ = num1 * num2
# Is num1 negative?
    LDA     num1
    JAN     1f
    JMP     4f
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
    LCA     @1
    STO     A sign1
    STO     A signA
4:
# Is num2 negative?
    LDA     num2
    JAN     1f
    JMP     4f
# Num2 is negative
1:
    STO     !A num2
    LDA     num2+1
    LDA     !A
    STO     A+1 num2+1
    TST     A+1 JC 2f
    JMP     3f
2:
    LDA     num2
    STO     A+1 num2
3:
    LCA     @1
    STO     A sign2
    LDB     signA
    STO     A^B signA
4:
# Multiply num1 * num2
    LDA     num1+1
    LDB     num2+1
    STO     A*BHI answ+2

    LDA     num1+1
    LDB     num2
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
    LDB     num2+1
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
    LDB     num2
    STO     A*B temp

    LDA     answ+1
    LDB     temp
    STO     A+B answ+1

# 2s complement negative answers
    LDA     signA
    JAZ     1f
    LDA     answ+1
    STO     !A answ+1
    LDA     answ+2
    LDA     !A
    STO     A+1 answ+2
    TST     A+1 JC 2f
    JMP     1f
2:
    LDA     answ+1
    STO     A+1 answ+1
1:
