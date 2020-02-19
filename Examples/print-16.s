#
# Print a 16-bit unsigned number in base 10
#

#define OUT(x)	     JOU .; OUT x

    LCA     $d4
    LCB     $31
    STO     A num1 # MSD
    STO     B num0 # LSD

# Divide 16 bit number by 10 (33 clock cycles)
divide:
    LDB     0           # 3
    LDA     num1        # 5
    # high byte
    STO     ADIVB num1  # 5
    LDB     AREMB       # 5
    # low byte
    LDA     num0        # 5
    STO     ADIVB num0  # 5
    STO     AREMB rem   # 5
    LDA     rem
    LCB     '0'
    LDA     A+B
    OUT     A

    LDB     0           # 3
    LDA     num1        # 5
    # high byte
    STO     ADIVB num1  # 5
    LDB     AREMB       # 5
    # low byte
    LDA     num0        # 5
    STO     ADIVB num0  # 5
    STO     AREMB rem   # 5
    LDA     rem
    LCB     '0'
    LDA     A+B
    OUT     A

    LDB     0           # 3
    LDA     num1        # 5
    # high byte
    STO     ADIVB num1  # 5
    LDB     AREMB       # 5
    # low byte
    LDA     num0        # 5
    STO     ADIVB num0  # 5
    STO     AREMB rem   # 5
    LDA     rem
    LCB     '0'
    LDA     A+B
    OUT     A

    LDB     0           # 3
    LDA     num1        # 5
    # high byte
    STO     ADIVB num1  # 5
    LDB     AREMB       # 5
    # low byte
    LDA     num0        # 5
    STO     ADIVB num0  # 5
    STO     AREMB rem   # 5
    LDA     rem
    LCB     '0'
    LDA     A+B
    OUT     A

    LDB     0           # 3
    LDA     num1        # 5
    # high byte
    STO     ADIVB num1  # 5
    LDB     AREMB       # 5
    # low byte
    LDA     num0        # 5
    STO     ADIVB num0  # 5
    STO     AREMB rem   # 5
    LDA     rem
    LCB     '0'
    LDA     A+B
    OUT     A

    OUT     ('\n')
# Back to command prompt

    JMP     prompt

num0:   HEX "FF"
num1:   HEX "FF"
rem:    HEX "00"
cnt:    HEX "05"
PAG
out:    STR "65536\n"

hexchar: EQU $FD00
prhex:   EQU $0279
prhex_ret:EQU $FFF8
prompt:  EQU $001f