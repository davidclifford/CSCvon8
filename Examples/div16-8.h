#
# Divide 16 bit number by 8 bit number
#
# Input
#   num        16-bit uint
#   div         8-bit uint
# Output
#   quotient   16-bit uint
#   remainder   8-bit uint

div_16_8:
# High byte
    LDB div
    JBZ 3f
    LDA num
    STO A%B remainder
    LDA A/B
    STO A quotient

# Low byte
    LDA num+1
    STO A numerator
# for iter=8
    LCA @8
    STO A iter
# quotient = 0
    STO 0 quotient+1
1:
# numerator << 1, temp = carry
    LCB @2
    LDA numerator
    STO A*B numerator
    STO A*BHI temp

# remainder << 1 + temp, temp2 = carry
    LDA remainder
    STO A*BHI temp2
    LDA A*B
    LDB temp
    STO A+B remainder

# quotient << 1
    LDA quotient+1
    LDB A
    STO A+B quotient+1
# when remainder>=div or temp2==1
    LDA remainder
    LDB div
    JLO 4f
    JMP 5f
4:
    LDA temp2
    JAZ 2f
5:
# remainder -= div
    LDA remainder
    STO A-B remainder
# quotient++
    LDA quotient+1
    STO A+1 quotient+1
# next iter
2:
    LDA iter
    LDA A-1
    STO A iter
    JAZ 3f
    JMP 1b
3:
    RTS div_16_8

numerator:    BYTE
remainder:    BYTE
quotient:     WORD
temp:         BYTE
temp2:        BYTE
iter:         BYTE
