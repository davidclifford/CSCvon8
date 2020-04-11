# Tetris for the CSCvon8
# By David Clifford April 2020
#

tetris:
# Clear screen
    STO 0 cls_plot+1
1:
    LDB 0
2:
    LDA 0
cls_plot:
    STO 0 $0000,B
    LDB B+1
    LCA @160
    JNE 2b
    LDA cls_plot+1
    STO A+1 cls_plot+1
    LCB @120
    JNE 1b

# Initialise screen
# Print TETRIS at the top of the screen

    STO 0 bakg
    LCA @1
    STO A ypos
    LCA @10
    STO A xpos

    LCA $30
    STO A forg
    LCA 'T'
    STO A char
    JSR pchar pchar_ret

    LCA $3C
    STO A forg
    LCA 'E'
    STO A char
    JSR pchar pchar_ret

    LCA $0C
    STO A forg
    LCA 'T'
    STO A char
    JSR pchar pchar_ret

    LCA $33
    STO A forg
    LCA 'R'
    STO A char
    JSR pchar pchar_ret

    LCA $0F
    STO A forg
    LCA 'I'
    STO A char
    JSR pchar pchar_ret

    LCA $3F
    STO A forg
    LCA 'S'
    STO A char
    JSR pchar pchar_ret

# Draw border
# Left side
    LCA @16
    STO A border_plot+1
2:
    LCB @56
1:
    LCA $2A
border_plot:
    STO A $0000,B
    LDB B+1
    LCA @60
    JNE 1b
    LDA border_plot+1
    STO A+1 border_plot+1
    LCB @104
    JNE 2b

# Right side
    LCA @16
    STO A border_plot1+1
2:
    LCB @104
1:
    LCA $2A
border_plot1:
    STO A $0000,B
    LDB B+1
    LCA @108
    JNE 1b
    LDA border_plot1+1
    STO A+1 border_plot1+1
    LCB @104
    JNE 2b

# Top
    LCA @16
    STO A border_plot2+1
2:
    LCB @60
1:
    LCA $2A
border_plot2:
    STO A $0000,B
    LDB B+1
    LCA @104
    JNE 1b
    LDA border_plot2+1
    STO A+1 border_plot2+1
    LCB @20
    JNE 2b

# Bottom
    LCA @100
    STO A border_plot3+1
2:
    LCB @60
1:
    LCA $2A
border_plot3:
    STO A $0000,B
    LDB B+1
    LCA @104
    JNE 1b
    LDA border_plot3+1
    STO A+1 border_plot3+1
    LCB @104
    JNE 2b

# Print start message
    LCA $30
    STO A forg
    STO 0 bakg
    LCA @2
    STO A xpos
    LCA @14
    STO A ypos
    LDB 0
1:
    STO B char_indx
    LDA start_mess,B
    JAZ 2f
    STO A char
    JSR pchar pchar_ret
    LDB char_indx
    LDB B+1
    JMP 1b

# Wait for key release & press, update random
2:
    LDA rand
    STO A+1 rand
    INA
    JAZ 3f
    JMP 2b
3:
    LDA rand
    STO A+1 rand
    INA
    JAZ 3b

# Erase start message
    STO 0 forg
    STO 0 bakg
    LCA @2
    STO A xpos
    LCA @14
    STO A ypos
    LDB 0
1:
    STO B char_indx
    LDA start_mess,B
    JAZ 2f
    STO A char
    JSR pchar pchar_ret
    LDB char_indx
    LDB B+1
    JMP 1b
2:

# Initialise board with 200 zeros
    LDB 0
1:
    STO 0 board,B
    LDB B+1
    LDA @200
    JNE 1b

# Choose next piece
# Set rotation
#    LDA rand
    LCA @3 # !!! replace with above
    LCB $03
    STO A&B rota
# set piece
    LDA rand
    LCB @4
    LDA A/B
    LCB @7
    LDA A%B
    LCA @2 # REMOVE
    STO A piece

    LCA @0
    STO A tile_x
1:
    LCB @0
    STO B tile_y

    JSR disp_piece

    JMP exit_game

# SUBROUTINE: Display piece on screen
# input: piece, tile_x, tile_y
# output: None

# Calculate address of piece
disp_piece:
    # tile = shapes + piece*64
    LDA piece
    LCB @64 # address
    STO A*BHI tile
    STO A*B tile+1
    LDA tile
    LHB shapes
    STO A+B tile
# Add rotation factor
    # tile += rota*16
    LDA rota
    LCB @16
    LDA A*B
    LDB tile+1
    STO A+B tile+1
# plot on screen, convert tile_x & tile_y to (tx, ty) absolute coords
    # tx = tile_x*4 + 60
    LDA tile_x
    LCB @4
    LDA A*B
    LCB @60
    STO A+B tx

    # ty = tile_y*4 + 21
    LDA tile_y
    LCB @4
    LDA A*B
    LCB @21
    STO A+B ty

# Set pixel counts to 4 (giving 4x4 blocks)
    # tyc = txc = pyc = 4
    LCA @4
    STO A tyc
    STO A txc
    STO A pyc

# Start of loop to plot pixels
1:
    # do loop 1:
    # tile_plot = ty
    LDA ty
    STO A tile_plot+1
    # A = (tile)
    LIA tile
    # B = tx
    LDB tx
    # when A==0 skip to 4: (no pixel to plot)
    JAZ 4f
    # pix = A (tile)
    STO A pix
    # pxc  = 4
    LCA @4
    STO A pxc
# plot
    # Do loop 3:
3:
    # tile_plot[B] = pix
    LDA pix
tile_plot:
    STO A $0000,B
    # B += 1
    LDB B+1
    # pxc -= 1
    LDA pxc
    LDA A-1
    STO A pxc
    # when A == 0 skip 2:
    JAZ 2f
    # loop back to 3:
    JMP 3b
4:
    # don't plot pixel
    # B += 4
    LCA @4
    LDB A+B
# next tile point
2:
    # tile += 1
    LDA tile+1
    STO A+1 tile+1
# next x coord
    # tx = B
    STO B tx
    # txc -= 1
    LDB txc
    LDB B-1
    STO B txc
    # when txc !=0 loop back 1:
    LDA 0
    JNE 1b
# next y coord
    # txc = 4
    LCB @4
    STO B txc
    # tx -= 16
    LDA tx
    LCB @16
    STO A-B tx
    # ty += 1
    LDB ty
    STO B+1 ty
    # tile -= 4
    LDA tile+1
    LCB @4
    STO A-B tile+1
    # pyc -= 1
    LDB pyc
    LDB B-1
    STO B pyc
    # when pyc != 0 loop back 1:
    LDA 0
    JNE 1b
    # tile += 4
    LDA tile+1
    LCB @4
    STO A+B tile+1
    # pyc = 4
    LCA @4
    STO A pyc
    # tyc -= 1
    LDB tyc
    LDB B-1
    STO B tyc
    # when tyc !=0 loop back 1:
    LDA 0
    JNE 1b

    RTS disp_piece
# END SUBROUTINE disp_piece

# Exit to monitor
exit_game:
    JMP monitor

# System variables
monitor: EQU $0015
pchar: EQU $02c9
pchar_ret: EQU $fff4
char: EQU $fd11
xpos: EQU $fd10
ypos: EQU $fd0f
bakg: EQU $fd12
forg: EQU $fd13

# Tetris variables
char_indx: HEX "00"
rand: HEX "00"
tile: HEX "00 00"
rota: HEX "00"
tx: HEX "00"
ty: HEX "00"
tile_x: HEX "00"
tile_y: HEX "00"
txc: HEX "00"
tyc: HEX "00"
piece: HEX "00"
pxc: HEX "00"
pyc: HEX "00"
pix: HEX "00"

PAG
start_mess: STR "Press any key to Start"
PAG
board: HEX "00"
PAG
shapes:
#shape_I:
    HEX "0F 0F 0F 0F 00 00 00 00 00 00 00 00 00 00 00 00"
#    HEX "0F 30 0F 30 3C 0C 3C 0C 03 2A 03 2A 3F 00 3F 00"
    HEX "00 0F 00 00 00 0F 00 00 00 0F 00 00 00 0F 00 00"
    HEX "0F 0F 0F 0F 00 00 00 00 00 00 00 00 00 00 00 00"
    HEX "00 00 0F 00 00 00 0F 00 00 00 0F 00 00 00 0F 00"
shape_O:
    HEX "3C 3C 00 00 3C 3C 00 00 00 00 00 00 00 00 00 00"
    HEX "3C 3C 00 00 3C 3C 00 00 00 00 00 00 00 00 00 00"
    HEX "3C 3C 00 00 3C 3C 00 00 00 00 00 00 00 00 00 00"
    HEX "3C 3C 00 00 3C 3C 00 00 00 00 00 00 00 00 00 00"
shape_T:
    HEX "33 33 33 00 00 33 00 00 00 00 00 00 00 00 00 00"
    HEX "00 33 00 00 33 33 00 00 00 33 00 00 00 00 00 00"
    HEX "00 33 00 00 33 33 33 00 00 00 00 00 00 00 00 00"
    HEX "33 00 00 00 33 33 00 00 33 00 00 00 00 00 00 00"
shape_S:
    HEX "00 0C 0C 00 0C 0C 00 00 00 00 00 00 00 00 00 00"
    HEX "0C 00 00 00 0C 0C 00 00 00 0C 00 00 00 00 00 00"
    HEX "00 0C 0C 00 0C 0C 00 00 00 00 00 00 00 00 00 00"
    HEX "0C 00 00 00 0C 0C 00 00 00 0C 00 00 00 00 00 00"
shape_J:
    HEX "00 03 00 00 00 03 00 00 03 03 00 00 00 00 00 00"
    HEX "03 00 00 00 03 03 03 00 00 00 00 00 00 00 00 00"
    HEX "03 03 00 00 03 00 00 00 03 00 00 00 00 00 00 00"
    HEX "03 03 03 00 00 00 03 00 00 00 00 00 00 00 00 00"
shape_Z:
    HEX "30 30 00 00 00 30 30 00 00 00 00 00 00 00 00 00"
    HEX "00 30 00 00 30 30 00 00 30 00 00 00 00 00 00 00"
    HEX "30 30 00 00 00 30 30 00 00 00 00 00 00 00 00 00"
    HEX "00 30 00 00 30 30 00 00 30 00 00 00 00 00 00 00"
shape_L:
    HEX "34 00 00 00 34 00 00 00 34 34 00 00 00 00 00 00"
    HEX "34 34 34 00 34 00 00 00 00 00 00 00 00 00 00 00"
    HEX "34 34 00 00 00 34 00 00 00 34 00 00 00 00 00 00"
    HEX "00 00 34 00 34 34 34 00 00 00 00 00 00 00 00 00"
