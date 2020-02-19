#
# Divide a 16-bit unsigned number by 10
#

#define OUT(x)	     JOU .; OUT x

    LCA     $02
    LCB     $01
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

# Print out num1 num0 rem
    LDA     num1
    STO     A hexchar
    JSR     prhex prhex_ret
    OUT     (' ')
    LDA     num0
    STO     A hexchar
    JSR     prhex prhex_ret
    OUT     (' ')
    LDA     rem
    STO     A hexchar
    JSR     prhex prhex_ret
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