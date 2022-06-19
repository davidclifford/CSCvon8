#
# File system
#
# filename address  length  data
# <- 20 -> <-  2 -> <- 2 -> <- data x length ->|<-- next file -->|<-- FF FF FF ... -->|
#
# David Clifford 29 May 2022
#

# Erase first 4k
    STO 0 dest
    STO 0 dest+1
    JSR erase_sector
# Show directory
    JSR dir

# Copy f1 to filename
    LHA f1
    STO A fn_ptr
    LCA f1
    STO A fn_ptr+1
    LCA filename
    STO A fs
1:
# Get char from filename pointer
    LDB fn_ptr+1
    LAI fn_ptr,B
# Put character in filename store
    LDB fs
    STO A filename,B
# finish on \0
    JAZ 2f
# fn_ptr++
    LDA fn_ptr+1
    STO A+1 fn_ptr+1
# fs++
    LDA fs
    STO A+1 fs
    JMP 1b
2:
# set address
    LDA a1
    STO A addr
    LDA a1+1
    STO A addr+1
# Set file size to 41
    LDA s1
    STO A size
    LDA s1+1
    STO A size+1
# source = d1
    LHA d1
    STO A data
    LCA d1
    STO A data+1
# write file
    JSR write_file
# show directory
    JSR dir

# Copy f2 to filename
    LHA f2
    STO A fn_ptr
    LCA f2
    STO A fn_ptr+1
    LCA filename
    STO A fs
1:
# Get char from filename pointer
    LDB fn_ptr+1
    LAI fn_ptr,B
# Put character in filename store
    LDB fs
    STO A filename,B
# finish on \0
    JAZ 2f
# fn_ptr++
    LDA fn_ptr+1
    STO A+1 fn_ptr+1
# fs++
    LDA fs
    STO A+1 fs
    JMP 1b
2:
# set address
    LDA a2
    STO A addr
    LDA a2+1
    STO A addr+1
# Set file size to size of d2
    LDA s2
    STO A size
    LDA s2+1
    STO A size+1
# source = d2
    LHA d2
    STO A data
    LCA d2
    STO A data+1
# write file
    JSR write_file
# show directory
    JSR dir

# exit
    JMP sys_cli

###############################
# Write file
# input: filename, size, addr
write_file:
# find end of file system
    STO 0 ptrA
    STO 0 ptrA+1
write_find_next:
    LDB ptrA+1
    VAI ptrA,B
    LCB $FF
    JEQ write_start
    LDA ptrA+1
    LCB @22
    STO A+B ptrA+1
    TST A+B JC 1f
    JMP 2f
1:
    LDA ptrA
    STO A+1 ptrA
2:
# Get size of next block
    LDB ptrA+1
    VAI ptrA,B
    STO A length
    LDA ptrA+1
    LDA A+1
    STO A ptrA+1
    JAZ 1f
    JMP 2f
1:
    LDA ptrA
    STO A+1 ptrA
2:
    LDB ptrA+1
    VAI ptrA,B
    STO A length+1
# Add length to pointer
    LDA ptrA+1
    LDB length+1
    STO A+B ptrA+1
    TST A+B JC 1f
    JMP 2f
1:
    LDA ptrA
    STO A+1 ptrA
2:
# ptrA++
    LDA ptrA+1
    STO A+1 ptrA+1
    JAZ 1f
    JMP 2f
1:
    LDA ptrA
    STO A+1 ptrA
2:
    LDA ptrA
    LDB length
    STO A+B ptrA
    JMP write_find_next

write_start:
# write filename
# ptrA points to EEPROM address to write to
    LDA ptrA
    STO A dest
    LDA ptrA+1
    STO A dest+1
    LHA filename
    STO A source
    LCA filename
    STO A source+1
    LCA @20
    STO 0 length
    STO A length+1
    JSR write_data
#  dest SHOULD still be the correct address (start+20)
# write address
    LHA addr
    STO A source
    LCA addr
    STO A source+1
    LCA @2
    STO 0 length
    STO A length+1
    JSR write_data
# write size
    LHA size
    STO A source
    LCA size
    STO A source+1
    LCA @2
    STO 0 length
    STO A length+1
    JSR write_data
# write data
    LDA data
    STO A source
    LDA data+1
    STO A source+1
    LDA size
    STO A length
    LDA size+1
    STO A length+1
    JSR write_data

    RTS write_file

###########################################
# Dir - Output directory of contents of SSD
dir:
    OUT '\n'
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
    STO A+B ptrB+1
    TST A+B JC 1f
    JMP 2f
1:
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
    STO A+B ptrB+1
    TST A+B JC 1f
    JMP 2f
1:
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
# input: source, dest, length
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
#    OUT B
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

PAG

source: WORD
addr:   WORD
length: WORD
size:   WORD
data:   WORD
char:   BYTE
filename: BYTE @20
fs:     BYTE
fn_ptr: WORD
ptrA:   WORD
ptrB:   WORD

f1:  STR "file1.txt"
a1:  HEX "A0 00"
s1:  HEX "00 2A" # 42 decimal
d1:  STR "This is some text for the file number one"

f2:  STR "file2.txt"
a2:  HEX "12 34"
s2:  HEX "00 1C" # 28 decimal
d2:  STR "For file two, some more text"

#include "monitor.h"

    ORG $E000
# Temp store 4k of data when erasing blocks
data_buffer:
