#define print(str) LHA str; STO A string; LCA str; STO A string+1; JSR pstring

    print(hello)
    print(bye)

    JMP sys_cli

pstring:
    LDB string+1
2:
    LAI string,B
    JAZ 1f
    OUT A
    LDB B+1
    JMP 2b
1:
    RTS pstring

hello: STR "Hello, World!\n"
bye:   STR "Bye, I'm going now\n"
string: WORD
end:
#include "monitor.h"

EXPORT end
