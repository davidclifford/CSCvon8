#    xs ^= xs << 7;
#    xs ^= xs >> 9;
#    xs ^= xs << 8;

# 6502 code
# rng_zp_low = $02
# rng_zp_high = $03
#         ; seeding
#         LDA #1 ; seed, can be anything except 0
#         STA rng_zp_low
#         LDA #0
#         STA rng_zp_high
#         ...
#         ; the RNG. You can get 8-bit random numbers in A or 16-bit numbers
#         ; from the zero page addresses. Leaves X/Y unchanged.
# random LDA rng_zp_high
#        LSR
#        LDA rng_zp_low
#        ROR
#        EOR rng_zp_high
#        STA rng_zp_high ; high part of x ^= x << 7 done
#        ROR             ; A has now x >> 9 and high bit comes from low byte
#        EOR rng_zp_low
#        STA rng_zp_low  ; x ^= x >> 9 and the low part of x ^= x << 7 done
#        EOR rng_zp_high
#        STA rng_zp_high ; x ^= x << 8 done
#        RTS

    LCA @1
    STO A seed+1
    STO 0 seed

2:
    STO 0 x
    STO 0 y
1:
    JSR rand

    LDA seed
    LCB $3f
    LDA A&B
    LDB x
    STI A y,B

    LDA x
    STO A+1 x
    LCB @159
    JLO 1b

    STO 0 x
    LDA y
    STO A+1 y
    LCB @119
    JLO 1b
    JMP 2b

rand:
# seed ^= seed << 7
    LDA seed+1
    LCB @7
    STO A<<B temp+1
    LCB @1
    STO A>>B temp
    LDA seed
    LCB @7
    LDA A<<B
    LDB temp
    STO A|B temp
    LDA seed
    LDB temp
    STO A^B seed
    LDA seed+1
    LDB temp+1
    STO A^B seed+1
# seed ^= seed >> 9
    LDA seed
    LCB @1
    LDB A>>B
    LDA seed+1
    STO A^B seed+1
# seed ^= seed << 8
    LDA seed+1
    LDB seed
    STO A^B seed
    RTS rand

seed: WORD
temp: WORD

x: BYTE
y: BYTE

#include "monitor.h"
