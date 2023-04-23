# Test extended instructions that use Flags Register

LDB 0
LCA $ff
LDA A+1
LDB B+C

STO B __hex
JSR sys_phex sys_phex_ret
JMP sys_cli

#include "monitor.h"

