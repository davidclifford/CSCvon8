#
# Print a 16-bit unsigned number in base 10
#

#define OUT(x)	     JOU .; OUT x

loop:
    LDA     number
    LDB     number+1
    STO     A num1 # MSD
    STO     B num0 # LSD

# Divide 16 bit number by 10 (33 clock cycles)
    STO     0 cnt
    STO     0 out
1:  LDB     0
    LDA     num1
    # high byte
    STO     ADIVB num1
    LDB     AREMB
    # low byte
    LDA     num0
    STO     ADIVB num0
    STO     AREMB rem
    LDA     rem
    LCB     '0'
    LDA     A+B
    LDB     cnt
    STO     A out,B
    STO     B+1 cnt
    LDA     num0
    JAZ     2f
    JMP     1b
2:  LDA     num1
    JAZ     out_number
    JMP     1b

# print out number
out_number:
    LDB     cnt
    LDB     B-1
1:  LDA     out,B
    OUT(A)
    LDB     B-1
    JAZ     next_number
    JMP     1b

# Increment number
next_number:
    OUT('\n')
    LDA     number
    LDB     number+1
    TST     B+1 JC carry
    STO     B+1 number+1
    JMP     loop
carry:
    STO     0 number+1
    STO     A+1 number
    JMP loop

# Back to command prompt
    JMP     prompt

number: HEX "00 00"
num0:   HEX "FF"
num1:   HEX "FF"
rem:    HEX "00"
cnt:    HEX "05"
PAG
out:    STR "12345"

hexchar: EQU $FD00
prhex:   EQU $026F
prhex_ret:EQU $FFFA
prompt:  EQU $0015