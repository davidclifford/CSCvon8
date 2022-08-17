#
# File system
#
# filename address  length  data
# <- 20 -> <-  2 -> <- 2 -> <- data x length ->|<-- next file -->|<-- FF FF FF ... -->|
#
# David Clifford 09 Aug 2022
#

#define print(str) LHA str; STO A string; LCA str; STO A string+1; JSR pstring
    ORG $d000

sys_file_system:
    print(prompt)
99:
    print(prompt2)
    LHA command
    STO A com_ptr
    LDA command
    STO A com_ptr+1
1:
    JIU .
    INA
    LDB com_ptr+1
    STI A com_ptr,B
    OUT A
    LCB '\n'
    JNE 3f
    LDB com_ptr+1
    STI 0 com_ptr,B
    JMP 4f
3:
    LDA com_ptr+1
    STO A+1 com_ptr+1
    JMP 1b

# Scan command and do whatev's
4:
    LDA command
    STO A com_ptr+1
1:
    LDB com_ptr+1
    LAI com_ptr,B
# d - directory
    LCB 'd'
    JNE 2f
    JSR dir
    JMP 99b
2:
# f - format
    LCB 'f'
    JNE 2f
    JSR file_format
    JMP 99b
2:
# ? - help
    LCB '?'
    JNE 2f
    JMP sys_file_system
2:
# \n
    LDB 0
    JNE 2f
    JMP 99b
2:
# s - save
    LCB 's'
    JNE 2f
    JMP save_file
2:
# l - load
    LCB 'l'
    JNE 2f
    JMP load_command
2:
# e - erase
    LCB 'e'
    JNE 2f
    JMP erase_command
2:
# MUST BE LAST
# x - eXit file system
    LCB 'x'
    JNE 3f
    print(bye)
    JMP sys_cli
3:
    print(cnr)
    JMP sys_file_system

#####################
# Load file command
#####################
load_command:
1:
    LDB com_ptr+1
    LDB B+1
    STO B com_ptr+1
    LDA command,B
    JAZ 4f
    LCB ' '
    JEQ 1b
# copy to filename variable
1:
    LCA filename
    STO A fn_ptr+1
2:
    LDB com_ptr+1
    STO B+1 com_ptr+1
    LDA command,B
    JAZ 3f
    LDB fn_ptr+1
    STO B+1 fn_ptr+1
    STO A filename,B
    JMP 2b
3:
    LDB fn_ptr+1
    STO 0 filename,B
# Filename known
    JSR load_file
    JMP 5f
4:
    print(abort)
5:
    JMP 99b

#####################
# Erase file command
#####################
erase_command:
1:
    print(sure)
    JIU .
    INA
    LCB 'Y'
    JEQ 2f
    LCB 'y'
    JEQ 2f
    JMP 4f
2:
    LDB com_ptr+1
    LDB B+1
    STO B com_ptr+1
    LDA command,B
    JAZ 4f
    LCB ' '
    JEQ 1b
# copy to filename variable
1:
    LCA filename
    STO A fn_ptr+1
2:
    LDB com_ptr+1
    STO B+1 com_ptr+1
    LDA command,B
    JAZ 3f
    LDB fn_ptr+1
    STO B+1 fn_ptr+1
    STO A filename,B
    JMP 2b
3:
    LDB fn_ptr+1
    STO 0 filename,B
# Filename known
    JSR erase_file
    JMP 5f
4:
    print(abort)
5:
    JMP 99b

#####################
# Save file command
#####################
# TODO: Check duplicate filename & if enough space in SSD before writing file
save_file:
1:
    LDB com_ptr+1
    LDB B+1
    STO B com_ptr+1
    LDA command,B
    JAZ 4f
    LCB ' '
    JEQ 1b
# copy to filename variable
1:
    LCA filename
    STO A fn_ptr+1
2:
    LDB com_ptr+1
    STO B+1 com_ptr+1
    LDA command,B
    LCB ' '
    JEQ 3f
    JAZ 4f
    LDB fn_ptr+1
    STO B+1 fn_ptr+1
    STO A filename,B
    JMP 2b
3:
    LDB fn_ptr+1
    STO 0 filename,B
# start of address
    LDB com_ptr+1
    LDA command,B
    JAZ 4f
    STO A __hex
    LDB B+1
    LDA command,B
    JAZ 4f
    STO A __hex+1
    LDB B+1
    LDA command,B
    JAZ 4f
    STO A __hex+2
    LDB B+1
    LDA command,B
    JAZ 4f
    STO A __hex+3
    STO B+1 com_ptr+1
    JSR hexcvt
    LDA num16
    STO A addr
    LDA num16+1
    STO A addr+1
1:
    LDB com_ptr+1
    LDA command,B
    JAZ 4f
    LCB ' '
    JNE 2f
    LDB com_ptr+1
    STO B+1 com_ptr+1
    JMP 1b

# start of size
2:
    LDB com_ptr+1
    LDA command,B
    JAZ 4f
    STO A __hex
    LDB B+1
    LDA command,B
    JAZ 4f
    STO A __hex+1
    LDB B+1
    LDA command,B
    JAZ 4f
    STO A __hex+2
    LDB B+1
    LDA command,B
    JAZ 4f
    STO A __hex+3
    LDB B+1
    LDA command,B
# If not \0 ABORT!
    JAZ 3f
    JMP 4f
3:
    JSR hexcvt
    LDA num16
    STO A size
    LDA num16+1
    STO A size+1
# Write the flipping file NOW!
    JSR write_file
    JMP 99b
4:
    print(abort)
    JMP 99b

#####################
# Format file system
#####################
file_format:
    print(sure)
    JIU .
    INA
    LCB 'Y'
    JEQ 2f
    LCB 'y'
    JEQ 2f
    JMP 3f
2:
    STO 0 dest
    STO 0 dest+1
1:
    JSR erase_sector
    LDA dest
    LCB $10
    LDA A+B
    STO A dest
    LCB $80
    JNE 1b
    print(formatted)
4:
    RTS file_format
3:
    print(abort)
    JMP 4b

#####################
# Find next file
# input: ptrA
#####################
file_find_next:
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
# ptrA++
    LDB B+1
    STO B ptrA+1
    JBZ 1f
    JMP 2f
1:
    LDA ptrA
    STO A+1 ptrA
2:
    LDB ptrA+1
    VAI ptrA,B
    STO A length+1
# ptrA++
    LDB ptrA+1
    LDB B+1
    STO B ptrA+1
    JBZ 1f
    JMP 2f
1:
    LDA ptrA
    STO A+1 ptrA
2:
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
    LDA ptrA
    LDB length
    STO A+B ptrA

    RTS file_find_next
###############################

#################
# Find File
# input: filename
# output: ptrA - points to found file or 0xFF
#################
find_file:
    STO 0 ptrA
    STO 0 ptrA+1
1:
# detect end of file system
    LDB ptrA+1
    VAI ptrA,B
    LCB $FF
    JEQ 4f
# copy ptrA to ptrB
    LDA ptrA
    STO A ptrB
    LDA ptrA+1
    STO A ptrB+1
# compare filename to file-system
    LCA filename
    STO A fn_ptr+1
3:
    LDB ptrB+1
    VAI ptrB,B
    STO A char

    LDB fn_ptr+1
    LDA filename,B
    LDB char
    JEQ 2f
# Filenames don't match
    JSR file_find_next
    JMP 1b
2:
    JAZ 4f
    LDA fn_ptr+1
    STO A+1 fn_ptr+1
    LDA ptrB+1
    LDA A+1
    STO A ptrB+1
    JAZ 1f
    JMP 2f
1:
    LDA ptrB
    STO A+1 ptrB
2:
    JMP 3b
4:
    RTS find_file

######################################
# Load file
# input: filename
# output: 'not found' or 'file loaded'
######################################
load_file:
    JSR find_file
    LDB ptrA+1
    VAI ptrA,B
    LCB $FF
    JEQ 5f
### FILE FOUND ###
# print out 'file found'
    LHA fld
    STO A string
    LCA fld
    STO A string+1
    JSR pstring
# ptrA += 20
    LDA ptrA+1
    LCB @20
    STO A+B ptrA+1
    TST A+B JC 1f
    JMP 2f
1:
    LDA ptrA
    STO A+1 ptrA
2:
# Get address MSB
    LDB ptrA+1
    VAI ptrA,B
    STO A addr
# incr ptrA
    LDA ptrA+1
    LDA A+1
    STO A ptrA+1
    JAZ 1f
    JMP 2f
1:
    LDA ptrA
    STO A+1 ptrA
2:
# Get address LSB
    LDB ptrA+1
    VAI ptrA,B
    STO A addr+1
# incr ptrA
    LDA ptrA+1
    LDA A+1
    STO A ptrA+1
    JAZ 1f
    JMP 2f
1:
    LDA ptrA
    STO A+1 ptrA
2:
# Get length MSB
    LDB ptrA+1
    VAI ptrA,B
    STO A length
# incr ptrA
    LDA ptrA+1
    LDA A+1
    STO A ptrA+1
    JAZ 1f
    JMP 2f
1:
    LDA ptrA
    STO A+1 ptrA
2:
# Get length LSB
    LDB ptrA+1
    VAI ptrA,B
    STO A length+1
# incr ptrA
    LDA ptrA+1
    LDA A+1
    STO A ptrA+1
    JAZ 1f
    JMP 2f
1:
    LDA ptrA
    STO A+1 ptrA
2:
# Copy from ptrA to addr
9:
    LDB ptrA+1
    VAI ptrA,B
#    OUT A
    LDB addr+1
    STI A addr,B
# incr addr
    LDA addr+1
    LDA A+1
    STO A addr+1
    JAZ 1f
    JMP 2f
1:
    LDA addr
    STO A+1 addr
2:
# incr ptrA
    LDA ptrA+1
    LDA A+1
    STO A ptrA+1
    JAZ 1f
    JMP 2f
1:
    LDA ptrA
    STO A+1 ptrA
2:
# decr length
    LDA length+1
    LDA A-1
    STO A length+1
    JAZ 1f
    JMP 9b
1:
    LDA length
    JAZ 6f
    STO A-1 length
    JMP 9b
5:
# print out 'file not found'
    LHA fnf
    STO A string
    LCA fnf
    STO A string+1
    JSR pstring
6:
    RTS load_file

###############################
# Write file
# input: filename, size, addr
###############################
write_file:
# find end of file system
    STO 0 ptrA
    STO 0 ptrA+1
write_find_next:
    LDB ptrA+1
    VAI ptrA,B
    LCB $FF
    JEQ write_start
    JSR file_find_next
    JMP write_find_next
write_start:
### FOUND END OF FS ###
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
    LDA addr
    STO A source
    LDA addr+1
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
    STO A ptrA+1
    JAZ 2f
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
    LHA used
    STO A string
    LCA used
    STO A string+1
    JSR pstring

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
    LHA bytes
    STO A string
    LCA bytes
    STO A string+1
    JSR pstring
    RTS dir

##################
# Erase File
# input: filename
# output: 'file not found' or 'file deleted'
##################
erase_file:
    JSR find_file
# was it found?
    LDB ptrA+1
    VAI ptrA,B
    LCB $FF
# NOT found so abort
    JEQ 9f
# FILE FOUND
# Save start of found file
    LDA ptrA
    STO A start
    LDA ptrA+1
    STO A start+1
# Save start of next file in source (i.e. start of next file)
    JSR file_find_next
    LDA ptrA
    STO A source
    LDA ptrA+1
    STO A source+1
1:
    LDB ptrA+1
    VAI ptrA,B
    LCB $FF
    JEQ 2f
# next file
    JSR file_find_next
    JMP 1b
2:
# Save very end
    LDA ptrA
    STO A very_end
    LDA ptrA+1
    STO A very_end+1
# start, end and very_end have been found
# Set ptrA to buffer address (0xE000)
    LCA $E0
    STO A ptrA
    STO 0 ptrA+1
# find start of 4k block (12 LSBs set to 0) and set to dest and ptrB
    STO 0 dest+1
    STO 0 ptrB+1
    LDA start
    LCB $FC
    STO A&B dest
    STO A&B ptrB
# Start loop
7:
# exit early if ptrB == start
    LDA start
    LDB ptrB
    JNE 2f
    LDA ptrB+1
    LDB start+1
    JEQ 6f
# copy block from fs to mem ($e000) from start of 4k block to start of erased file
2:
    LDB ptrA+1
3:
    VAI ptrB,B
    STI A ptrA,B
# incr B
    LDB B+1
    STO B ptrA+1
    STO B ptrB+1
    JBZ 1f
    JMP 7b
# carry
1:
    LDA ptrA
    STO A+1 ptrA
    LDA ptrB
    STO A+1 ptrB
    JMP 7b
# End of loop
6:
# Copy rest to RAM
# Make sure to fill FF
    LDB ptrA+1
    LCA $FF
    STI A ptrA,B
# check to see not off end of FS
# TODO: change when FS > $8000 bytes (>32kb)
#
    LDA source
    LCB $80
    JEQ erase_file_loop
# copy FS to RAM
    LDB source+1
    VAI source,B
    LDB ptrA+1
    STI A ptrA,B
# incr source
    LDA source+1
    LDA A+1
    STO A source+1
    JAZ 3f
# incr ptrA
4:
    LDA ptrA+1
    LDA A+1
    STO A ptrA+1
    JAZ 5f
    JMP 6b
3:
# Carry source
    LDA source
    STO A+1 source
    JMP 4b
# Carry ptrA
5:
    LDA ptrA
    LDA A+1
    STO A ptrA
# Check end of RAM buffer (ptrA)
    LCB $F0
    JNE 6b
# Finish loop

# MAIN LOOP
erase_file_loop:

# 4k buffer filled - erase fs block
    JSR erase_sector
# Set ptrA to $E000
    LCA $E0
    STO A ptrA
    STO 0 ptrA+1

# Copy buffer back to fs
1:
    LCA $AA
    STO A $5555
    LCA $55
    STO A $2AAA
    LCA $A0
    STO A $5555
# (ptrA) -> (dest)
    LIA ptrA
    STO A char
    SIA dest

# Wait for write to complete
10:
    LDB dest+1
    VAI dest,B
    LDB char
    JNE 10b
# inc ptrA
11:
    LDA ptrA+1
    LDA A+1
    STO A ptrA+1
    JAZ 3f
    JMP 4f
3:
    LDA ptrA
    STO A+1 ptrA
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
    LDA ptrA
    LCB $F0
    JNE 1b

# Have we copied everything (source > very_end)?
    LDA source
    LDB very_end
    JEQ 1f
    JHI 10f
    JMP 7f
1:
    LDA source+1
    LDB very_end+1
    JHI 10f
7:
# Copy next 4k to RAM
    LCA $E0
    STO A ptrA
    STO 0 ptrA+1
2:
    LDB source+1
    VAI source,B
    LDB ptrA+1
    STI A ptrA,B
# incr source
    LDA source+1
    LDA A+1
    STO A source+1
    JAZ 3f
    JMP 4f
# source carry
3:
    LDA source
    LDA A+1
    STO A source
    LCB $80 # TODO Change if FS > $8000
    JEQ 10f
# incr ptrA
4:
    LDA ptrA+1
    LDA A+1
    STO A ptrA+1
    JAZ 5f
    JMP 2b
# ptrA carry
5:
    LDA ptrA
    LDA A+1
    STO A ptrA
    LCB $F0
    JEQ 10f
    JMP 2b
10:
# Erase any blocks not yet erased
    LDA dest
    LDB very_end
    JEQ 5f
    JHI 11f
    JMP 6f
5:
    LDA dest+1
    LDB very_end+1
    JHI 11f
6:
    JSR erase_sector
# Add $1000 (4k) to dest
    LDA dest
    LCB $10
    STO A+B dest
    JMP 10b
11:
# print out 'file deleted'
    LHA fdel
    STO A string
    LCA fdel
    STO A string+1
    JSR pstring

    RTS erase_file
9:
# print out 'file not found'
    LHA fnf
    STO A string
    LCA fnf
    STO A string+1
    JSR pstring
    RTS erase_file

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
# Exit when length is $0000
    LDA length+1
    JAZ 8f
    JMP 9f
8:
    LDA length
    JAZ 2f
9:
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
    STO A-1 length+1
    JAZ 7f
    JMP 1b
7:
    LDA length
    STO A-1 length
# loop
    JMP 1b
2:
    RTS write_data

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

## hexcvt subroutine. Given four hex digits stored in the __hex
#	buffer, convert them into a 16-bit big endian address
#	stored in addr.
hexcvt:
    LDB __hex		# Get the first character
	LCA $3F			# Add on $3F
	LDA A+B
	JAN 1f			# If -ve, was A-F
	LDA B
	JMP 2f			# Otherwise, was a 0-9 char
1:	LCB $0A			# Add on $0A to convert char to nibble
	LDA A+B
2:	LCB $04
	STO num16 A<<B		# Save top nibble into addr

	LDB __hex+1		# Repeat the process on the 2nd char
	LCA $3F			# Add on $3F
	LDA A+B
	JAN 3f			# If -ve, was A-F
	LDA B
	JMP 4f			# Otherwise, was a 0-9 char
3:	LCB $0A			# Add on $0A to convert char to nibble
	LDA A+B
4:	LCB $0F			# Get the low nibble
	LDB A&B
	LDA num16
	STO num16 A|B		# Combine both nibbles and store

	LDB __hex+2		# Repeat the process on the 3rd char
	LCA $3F			# Add on $3F
	LDA A+B
	JAN 5f			# If -ve, was A-F
	LDA B
	JMP 6f			# Otherwise, was a 0-9 char
5:	LCB $0A			# Add on $0A to convert char to nibble
	LDA A+B
6:	LCB $04
	STO num16+1 A<<B		# Save top nibble into addr

	LDB __hex+3		# Repeat the process on the 4th char
	LCA $3F			# Add on $3F
	LDA A+B
	JAN 7f			# If -ve, was A-F
	LDA B
	JMP 8f			# Otherwise, was a 0-9 char
7:	LCB $0A			# Add on $0A to convert char to nibble
	LDA A+B
8:	LCB $0F			# Get the low nibble
	LDB A&B
	LDA num16+1
	STO num16+1 A|B		# Combine both nibbles and store
	RTS hexcvt


PAG
prompt: STR "FILE SYSTEM - Load, Save, Dir, Erase, Format, eXit, ? - Help \n"
prompt2:STR ">> "
cnr:    STR "Command not recognised\n"
bye:    STR "File system exited\n"
fnf:    STR "File not found\n"
fld:    STR "File loaded\n"
fdel:   STR "File deleted\n\n"
used:   STR "Used "
bytes:  STR " Bytes\n\n"
sure:   STR "Are you sure? Y/N\n"
formatted: STR "SSD formatted\n"
abort: STR "Command aborted\n"

end_of_program:

PAG
dest:   WORD
source: WORD
addr:   WORD
length: WORD
num16:  WORD
ptrA:   WORD
ptrB:   WORD
size:   WORD
data:   WORD
char:   BYTE
filename: BYTE @20
fs:     BYTE
fn_ptr: WORD
string: WORD

start:  WORD
end:    WORD
very_end: WORD
block:  WORD

command: BYTE @48
com_ptr: WORD


#include "monitor.h"


    ORG $E000
# Temp store 4k of data when erasing blocks
data_buffer:

EXPORT end_of_program
