# Sieve of Eratosthenes

start:
    LDB 0
1:
    STO B primes,B
    LDB B+1
    JBZ 2f
    JMP 1b
2:
    STO 0 primes
    STO 0 primes+1

# Init loop
    STO 0 count
    STO 0 line
# Find non-zero entry
1:
    LDB count
    LDA primes,B
    JAZ 2f
    JMP 3f
2:
    LDB count
    STO B+1 count
    JMP 1b
3:
# Next non-zero entry
    LDB count
4:
    LDA count
    TST A+B JC 5f
    LDB A+B
# Set entry to zero (not a prime)
    STO 0 primes,B
    JMP 4b
5:
# Have we finished?? (count > 14)
    LDA count
    LCB @14
    JGT 6f
    STO A+1 count
    JMP 1b
6:
# Clear screen, set ink WHITE
    STO     0 __sxpos
    STO     0 __sypos
    LCA     $3f
    STO     A __sink
    STO     0 __paper
    JSR     sys_cls sys_cls_ret

# Print out primes
    STO 0 count
1:
# Is it a prime?
    LDB count
    LDA     primes,B
    JAZ     5f

# Print number
    STO     A __number
    JSR     sys_num_str_8 sys_num_str_8_ret
    LHA     __num_str
    LDB     __num_ptr
    STO     A __string
    STO     B __string+1
    JSR     sys_spstring sys_spstring_ret

    LHA     is_a_prime
    LCB     is_a_prime
    STO     A __string
    STO     B __string+1
    JSR     sys_spstring sys_spstring_ret

# Print new line if 3 on line
    LDA line
    LCB @2
    JEQ 4f
    STO A+1 line
    JMP 5f
4:
    LCB '\n'
    STO B __schar
    JSR sys_spchar sys_spchar_ret
    STO 0 line
5:
    LDA count
    LDA A+1
    JAZ 3f
    STO A count
    JMP 1b
3:
    JMP sys_cli

PAG
count:  BYTE
line:   BYTE
is_a_prime: STR " is a prime, "

PAG
primes: BYTE

#include "monitor.h"
