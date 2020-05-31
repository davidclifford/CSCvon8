# Print char to VGA
#
    LCA $02
    STO A bakg
#    JSR cls cls_ret

# Set up X & Y position, background and foreground colour
    LCA $00 # x = 0
    STO A xpos
    LCB $00 # y = 0
    STO B ypos
    LCA $3C # YELLOW
    STO A forg
    LCB $03 # BLUE
    STO B bakg
    LCA $00
    STO A pos

# Iterate through the string
1:
    LDB pos
    LDA message,B
    JAZ 2f
    STO A char
    JSR pchar pchar_ret # pchar
    LDB pos
    STO B+1 pos
    JMP 1b
2:
    JMP monitor # return to the Monitor

monitor: EQU $00bb
pchar: EQU $02d3
pchar_ret: EQU $fff4
cls: EQU $02aa
cls_ret: EQU $fffe
char: EQU $fd11
xpos: EQU $fd10
ypos: EQU $fd0f
bakg: EQU $fd12
forg: EQU $fd13

pos: HEX "00"

    PAG
message: STR "CSCvon8 Monitor\nRevision: 2.01\ntype ? for help"

