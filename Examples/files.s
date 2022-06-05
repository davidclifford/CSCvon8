#
# File system
#
# filename address  length  data
# <- 20 -> <-  2 -> <- 2 -> <- data x length ->|<-- next file -->|<-- FF FF FF ... -->|
#
# David Clifford 29 May 2022
#

# Show directory
    JSR dir
    JMP sys_cli

# Erase 4k block
    LCA $2f
    STO A dest
    LCA $ff
    STO A dest+1
    JSR erase_sector

# source = d1
    LHA d1
    STO A source
    LCA d1
    STO A source+1
# set address of data
    LCA $80
    STO A addr
    STO 0 addr+1
# set length of data
    STO 0 length
    LCA @38
    STO A length+1
# set destination address (in SD Drive)
    LCA $00
    STO A dest
    LCA $00
    STO A dest+1
    JSR write_data

    JMP sys_cli

# Write file
# in: filename, size, source address
write_file:
# TODO
    RTS write_file

# Dir - Output directory of contents of SSD
dir:
    STO 0 ptrB
    STO 0 ptrB+1

dir_next_filename:
    LDA ptrB
    STO A ptrA
    LDA ptrB+1
    STO A ptrA+1

# While (ptrA) != FF
    LDB ptrA+1
    VAI ptrA,B
    LCB $FF
    JEQ dir_finish

# While (ptrA) != 0
1:
    LDB ptrA+1
    VAI ptrA,B
    JAZ dir_filename_done
    OUT A
    LDA ptrA+1
    LDA A+1
    JAZ 2f
    STO A ptrA+1
    JMP 1b
2:
    LDA ptrA
    STO A+1 ptrA
    JMP 1b
dir_filename_done:
    OUT ' '
    OUT '$'
# Skip over filename to get address
    LCB @20
    LDA ptrB+1
    TST A+B JC 1f
    STO A+B ptrB+1
    JMP 2f
1:
    STO A+B ptrB+1
    LDA ptrB
    STO A+1 ptrB
2:
# Find address
    LDB ptrB+1
    VAI ptrB,B
    STO A addr
# increment ptrB
    LDA ptrB+1
    LDA A+1
    STO A ptrB+1
    JAZ 1f
    JMP 2f
1:
    LDA ptrB
    STO A+1 ptrB
2:
    LDB ptrB+1
    VAI ptrB,B
    STO A addr+1
# Got address, output as HEX
    LDA addr
    STO A __hex
    JSR sys_phex sys_phex_ret
    LDA addr+1
    STO A __hex
    JSR sys_phex sys_phex_ret
    OUT ' '
# Find length ...
# increment ptrB
    LDA ptrB+1
    LDA A+1
    STO A ptrB+1
    JAZ 1f
    JMP 2f
1:
    LDA ptrB
    STO A+1 ptrB
2:
    LDB ptrB+1
    VAI ptrB,B
    STO A length
# increment ptrB
    LDA ptrB+1
    LDA A+1
    STO A ptrB+1
    JAZ 1f
    JMP 2f
1:
    LDA ptrB
    STO A+1 ptrB
2:
    LDB ptrB+1
    VAI ptrB,B
    STO A length+1
# Got length, convert to decimal
    LDA length
    STO A __number
    LDA length+1
    STO A __number+1
    JSR sys_num_str_16 sys_num_str_16_ret
# Printout ___num_str
    LDB __num_ptr
1:
    LDA __num_str,B
    JAZ 2f
    OUT A
    LDB B+1
    JMP 1b
2:
    OUT '\n'
# add length+1 to ptrB
# increment ptrB
    LDA ptrB+1
    LDA A+1
    STO A ptrB+1
    JAZ 1f
    JMP 2f
1:
    LDA ptrB
    STO A+1 ptrB
2:
    LDA length+1
    LDB ptrB+1
    TST A+B JC 1f
    STO A+B ptrB+1
    JMP 2f
1:
    STO A+B ptrB+1
    LDA ptrB
    STO A+1 ptrB
2:
    LDA length
    LDB ptrB
    STO A+B ptrB
    JMP dir_next_filename
dir_finish:
    OUT '\n'
    OUT 'U'
    OUT 's'
    OUT 'e'
    OUT 'd'
    OUT ' '
    LDA ptrB
    STO A __number
    LDA ptrB+1
    STO A __number+1
    JSR sys_num_str_16 sys_num_str_16_ret
# Printout ___num_str
    LDB __num_ptr
1:
    LDA __num_str,B
    JAZ 2f
    OUT A
    LDB B+1
    JMP 1b
2:
    OUT ' '
    OUT 'B'
    OUT 'y'
    OUT 't'
    OUT 'e'
    OUT 's'
    OUT '\n'
    RTS dir

# Erase sector
# Input: dest - address in SSD of block to erase
erase_sector:
    LCA $AA
    STO A $5555
    LCA $55
    STO A $2AAA
    LCA $80
    STO A $5555
    LCA $AA
    STO A $5555
    LCA $55
    STO A $2AAA
    LCA $30
    LDB dest+1
    STI A dest,B
1:
    LDB dest+1
    VAI dest,B
    JAN 2f
    JMP 1b
2:
    RTS erase_sector

# Write data from source to destination
# in: source, dest, length
write_data:
1:
    LCA $AA
    STO A $5555
    LCA $55
    STO A $2AAA
    LCA $A0
    STO A $5555
# (source) -> (dest)
    LIA source
    STO A char
    SIA dest

# Wait for write to complete
10:
    LDB dest+1
    VAI dest,B
    LDB char
    OUT B
    JNE 10b

# inc source
11:
    LDA source+1
    LDA A+1
    STO A source+1
    JAZ 3f
    JMP 4f
3:
    LDA source
    STO A+1 source
4:
# inc dest
    LDA dest+1
    LDA A+1
    STO A dest+1
    JAZ 5f
    JMP 6f
5:
    LDA dest
    STO A+1 dest
6:
# decrement length
    LDA length+1
    LDA A-1
    STO A length+1
    JAZ 7f
    JMP 1b
7:
    LDA length
    JAZ 2f
    STO A-1 length
# loop
    JMP 1b
2:
    RTS write_data

dest:   WORD
source: WORD
addr:   WORD
length: WORD
size:   WORD
char:   BYTE
filename: BYTE @20
fn_ptr: WORD
ptrA:   WORD
ptrB:   WORD

ORG $8200
f1:  STR "fred.txt"
d1:  STR "This is some text for the file called fred"

#include "monitor.h"

    ORG $E000
# Temp store 4k of data when erasing blocks
data_buffer:
