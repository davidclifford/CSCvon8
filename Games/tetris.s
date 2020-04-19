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

    LCA $34
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
    LCB @100
1:
    LCA $2A
border_plot1:
    STO A $0000,B
    LDB B+1
    LCA @104
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
    LCA @101
    STO A border_plot3+1
2:
    LCB @60
1:
    LCA $2A # Grey
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

# Wait for key released & pressed, update random
2:
    LDA rand
    STO A+1 rand
    JIU 3f
    INA
    JMP 2b
3:
    LDA rand
    STO A+1 rand
    JIU 3b
    INA

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

# Initialise board with 52 FFs and 200 zeros (ie 252 initialised bytes)
    # pyc = 20
    LCA @20
    STO A pyc
    # B = 0
    LDB 0
    ## Do loop of 20 lines
1:
    ## Put in FF at start
    # pxc = 10
    LCA @10
    STO A pxc
    # board[B] = $FF
    LCA $FF
    STO A board,B
2:
    ## Fill 10 zeros
    ## Do loop of 10 zeros in line
    # B += 1
    LDB B+1
    # board[B] = 0
    STO 0 board,B
    # pxc -= 1
    LDA pxc
    LDA A-1
    STO A pxc
    ## loop until 10 zeros filled in line
    # when pcx>0 loop 2:
    JAZ 3f
    JMP 2b
3:
    ## Add FF at end of line
    # B += 1
    LDB B+1
    # board[B] = $FF
    LCA $FF
    STO A board,B
    # B += 1
    LDB B+1
    ## Next line
    # pyc -= 1
    LDA pyc
    LDA A-1
    STO A pyc
    ## Loop until 20 lines filled
    # when pyc>0 loop 1:
    JAZ 4f
    JMP 1b
4:
    ## Fill in last line with 12 FFs
    # pxc = 12
    LCA @12
    STO A pxc
    ## Do loop
5:
    # board[B] = FF
    LCA $FF
    STO A board,B
    # B += 1
    LDB B+1
    # pxc -= 1
    LDA pxc
    LDA A-1
    STO A pxc
    ## Loop until 12 FFs in last line
    # when pxc>0 loop 5:
    JAZ 6f
    JMP 5b
6:
next_piece:
# Choose random next piece
# Set rotation
    LDA rand
    LCB $03
    STO A&B rota
# set piece
    LDA rand
    LCB @2
    LDA A>>B
    LCB @7
    LDA A%B
    STO A piece
# set x
    LDA rand
    LCB @5
    LDA A>>B
    LCB @6
    LDA A%B
    LDA A+1

    STO A tile_x
    # tile_y = 0
    LCB @0
    STO B tile_y

    # gravity = 0
    STO 0 gravity+1
    LCA @60
    STO A gravity

    # do loop 1:
1:
    # display piece
    LCA $FF
    STO A erase
    JSR disp_piece
8:
    # next_tile_x = tile_x
    LDA tile_x
    STO A next_tile_x
    # next_tile_y = tile_y
    LDA tile_y
    STO A next_tile_y
    # next_rota = rota
    LDA rota
    STO A next_rota
    # down = 0
    STO 0 down

    # WAIT
wait_key:
    LDA rand
    STO A+1 rand
    JIU 16f
    INA
    STO A keypress
    JMP 11f
16:
    INA
    STO 0 keypress
11:
    LDA gravity+1
    LDA A-1
    STO A gravity+1
    JAZ 12f
    LDA keypress
    JAZ wait_key
    JMP 10f
12:
    LDA rand
    STO A+1 rand
    LDA gravity
    LDA A-1
    STO A gravity
    JAZ 13f
    LDA keypress
    JAZ wait_key
    JMP 10f
13:
    LDA tile_y
    STO A+1 next_tile_y
    LDA 0
    STO A+1 down
    # gravity = 0
    STO 0 gravity+1
    LCA @60
    STO A gravity
    JMP 9f
10:
    # A pressed (move left)
    LCB 'a'
    JNE 2f
    LDA tile_x
    STO A-1 next_tile_x
    JMP 9f
2:
    # D pressed (move right)
    LCB 'd'
    JNE 3f
    LDA tile_x
    STO A+1 next_tile_x
    JMP 9f
3:
    # W pressed (rotate)
    LCB 'w'
    JNE 4f
    # rota = (rota + 1) & 03h
    LDA rota
    LDA A+1
    LCB $03
    STO A&B next_rota
    JMP 9f
4:
    # S pressed (down)
    # next_tile_y = tile_y + 1
    LCB 's'
    JNE 5f
    LDA tile_y
    STO A+1 next_tile_y
    LDA 0
    STO A+1 down
    JMP 9f
5:
    # Nothing happened - loop back to 8
    JMP 8b
9:
    # Can it fit in new position/orientation? 0=false 1=true
    JSR can_it_fit
    # when fits == 0 loop back wait_key
    LDA fits
    JAZ 7f
    JMP 6f
7:
    # when down == 0 (false) loop back 8
    LDA down
    JAZ 8b

    # Are we still at the top?
    # Yes: so restart game
    LDA tile_y
    JAZ game_over

    # add piece to board
    JSR add_piece_to_board

    # check lines full
    LCA @19
    STO A tile_y
14:
    # do loop
    # check line is full
    JSR is_line_full
    LDA full
    JAZ 15f
    # Remove line and re-display board
    JSR remove_line
    JSR re_display_board
    JMP 14b
15:
    # tile_y -= 1
    LDA tile_y
    LDA A-1
    STO A tile_y
    # loop if tile_y > 0 else get next piece
    JAZ next_piece
    JMP 14b
6:
    # erase piece
    STO 0 erase
    JSR disp_piece

    # rota = next_rota
    LDA next_rota
    STO A rota
    # tile_x = next_tile_x
    LDA next_tile_x
    STO A tile_x
    # tile_y = next_tile_y
    LDA next_tile_y
    STO A tile_y
    # Loop next move
    JMP 1b

# Restart Game
game_over:
# Print GAME OVER message
    LCA $33
    STO A forg
    STO 0 bakg
    LCA @4
    STO A xpos
    LCA @14
    STO A ypos
    LDB 0
1:
    STO B char_indx
    LDA game_over_mess,B
    JAZ 2f
    STO A char
    JSR pchar pchar_ret
    LDB char_indx
    LDB B+1
    JMP 1b

# Wait for key released & pressed, update random
2:
    LDA rand
    STO A+1 rand
    JIU 3f
    INA
    JMP 2b
3:
    LDA rand
    STO A+1 rand
    JIU 3b
    INA

# Erase start message
    STO 0 forg
    STO 0 bakg
    LCA @4
    STO A xpos
    LCA @14
    STO A ypos
    LDB 0
1:
    STO B char_indx
    LDA game_over_mess,B
    JAZ 2f
    STO A char
    JSR pchar pchar_ret
    LDB char_indx
    LDB B+1
    JMP 1b
2:
    JMP tetris

    # Exit game
    JMP exit_game

# SUBROUTINE: Display piece on screen
# input: piece, tile_x, tile_y, erase (0 do, $FF don't)
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
    STO B tx
    LDB erase
    LDA pix
    LDA A&B
    LDB tx
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
    # not plotting pixel
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


# SUBROUTINE: can_it_fit
can_it_fit:
    # tx = ty = 0
    STO 0 tx
    STO 0 ty

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
    LDA next_rota
    LCB @16
    LDA A*B
    LDB tile+1
    STO A+B tile+1

    # fits = 0 (false)
    STO 0 fits
1:
    # when (tile) == blank skip
    LIA tile
    JAZ 2f

    ## has board got part there already?
    # B = next_tile_x + tx + (next_tile_y + ty)*12 + 1  [index into board]
    # A = next_tile_y+ty
    LDA next_tile_y
    LDB ty
    LDA A+B
    # A *= 12
    LCB @12
    LDA A*B
    # A += tile_x
    LDB next_tile_x
    LDA A+B
    # A += tx
    LDB tx
    LDA A+B
    # B = A+1
    LDB A+1
    # A = board[B]
    LDA board,B
    # when A != 0 return false
    JAZ 2f
    JMP 9f
2:
    # tile += 1
    LDA tile+1
    STO A+1 tile+1
    # tx +=1
    LDA tx
    STO A+1 tx
    # when tx>3 next ty
    LCB @3
    JNE 1b
    # tx = 0
    STO 0 tx
    # ty += 1
    LDA ty
    STO A+1 ty
    # when ty!=4 next ty
    LCB @3
    JNE 1b
    # It can fit - return 1 (true)
    LDA 0
    STO A+1 fits
9:
    RTS can_it_fit

# END SUBROUTINE can_it_fit

# SUBROUTINE add_piece_to_board
# Add the piece to the board (as it has collided with the other pieces or got to the bottom)
# Calculate address of piece
add_piece_to_board:
    # tx = ty = 0
    STO 0 tx
    STO 0 ty

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
1:
    # when (tile) == blank skip
    LIA tile
    STO A pix
    JAZ 2f

    # B = tile_x + tx + (tile_y + ty)*12 + 1  [index into board]
    # A = tile_y + ty
    LDA tile_y
    LDB ty
    LDA A+B
    # A *= 12
    LCB @12
    LDA A*B
    # A += tile_x
    LDB tile_x
    LDA A+B
    # A += tx
    LDB tx
    LDA A+B
    # B = A+1
    LDB A+1
    # board[B] = (tile)
    LDA pix
    STO A board,B
2:
    # tile += 1
    LDA tile+1
    STO A+1 tile+1
    # tx +=1
    LDA tx
    STO A+1 tx
    # when tx>3 next ty
    LCB @3
    JNE 1b
    # tx = 0
    STO 0 tx
    # ty += 1
    LDA ty
    STO A+1 ty
    # when ty!=4 next ty
    LCB @3
    JNE 1b
    # return
    RTS add_piece_to_board
# END SUBROUTINE add_piece_to_board

# SUBROUTINE is_line_full
# Check to see if a line is full i.e. all 10 squares across are not blank
# Input: tile_y
# Output: full 0 (not full) 1 (is full)
# Calculate address on board
is_line_full:
    STO 0 full
    LCA @10
    STO A txc
    LDA tile_y
    LCB @12
    LDA A*B
    LDB A+1
1:
    LDA board,B
    JAZ 3f
    LDB B+1
    LDA txc
    LDA A-1
    STO A txc
    JAZ 2f
    JMP 1b
2:
    LDA 0
    STO A+1 full
3:
    RTS is_line_full

# END SUBROUTINE is_line_full


# SUBROUTINE remove_line
remove_line:
    # Move 'board' down one square from top to tile_y
    STO 0 tx
    LDA tile_y
    STO A ty
1:
    # B = (ty-1)*12 + tx + 1
    LDA ty
    LDA A-1
    LCB @12
    LDA A*B
    LDB tx
    LDA A+B
    LDB A+1
    # pix = board[B]
    LDA board,B
    STO A pix
    # B += 12
    LCA @12
    LDB A+B
    # board[B] = pix
    LDA pix
    STO A board,B
    # tx += 1
    LDA tx
    LDA A+1
    STO A tx
    LCB @10
    JNE 1b
    # tx = 0
    STO 0 tx
    # ty -=1
    LDA ty
    LDA A-1
    STO A ty
    JAZ 2f
    JMP 1b
2:
    RTS remove_line
# END SUBROUTINE remove_line


# SUBROUTINE re_display_board
re_display_board:
    # px = py = 0
    STO 0 px
    STO 0 py
1:
    # B = px/4 + py/4*12 + 1
    # A = board[B]
    LDA px
    LCB @4
    LDA A/B
    STO A tx
    LDA py
    LCB @4
    LDA A/B
    LCB @12
    LDA A*B
    LDB tx
    LDB A+B
    LDB B+1
    LDA board,B
    STO A pix

    LDB py
    LCA @21
    STO A+B redisplay_plot+1
    LDB px
    LCA @60
    LDB A+B
    LDA pix
redisplay_plot:
    STO A $0000,B

    # px += 1
    LDA px
    LDA A+1
    STO A px
    LCB @40
    JNE 1b

    # px = 0
    # py += 1
    STO 0 px
    LDA py
    LDA A+1
    STO A py
    LCB @80
    JNE 1b

    RTS re_display_board
# END SUBROUTINE re_display_board

# Exit to monitor
exit_game:
    JMP monitor

# System variables
monitor: EQU $0015
pchar: EQU $02d3
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
next_rota: HEX "00"
tx: HEX "00"
ty: HEX "00"
tile_x: HEX "00"
tile_y: HEX "00"
next_tile_x: HEX "00"
next_tile_y: HEX "00"
txc: HEX "00"
tyc: HEX "00"
piece: HEX "00"
pxc: HEX "00"
pyc: HEX "00"
pix: HEX "00"
px: HEX "00"
py: HEX "00"
erase: HEX "00"
fits: HEX "00"
down: HEX "00"
full: HEX "00"
gravity: HEX "00 00"
keypress: HEX "00"

PAG
start_mess: STR "Press any key to Start"
PAG
game_over_mess: STR "Game over, Man!"
PAG
board: HEX "00"
PAG
shapes:
#I
    HEX "0F 0F 0F 0F 00 00 00 00 00 00 00 00 00 00 00 00"
    HEX "00 0F 00 00 00 0F 00 00 00 0F 00 00 00 0F 00 00"
    HEX "0F 0F 0F 0F 00 00 00 00 00 00 00 00 00 00 00 00"
    HEX "00 00 0F 00 00 00 0F 00 00 00 0F 00 00 00 0F 00"
#O
    HEX "3C 3C 00 00 3C 3C 00 00 00 00 00 00 00 00 00 00"
    HEX "3C 3C 00 00 3C 3C 00 00 00 00 00 00 00 00 00 00"
    HEX "3C 3C 00 00 3C 3C 00 00 00 00 00 00 00 00 00 00"
    HEX "3C 3C 00 00 3C 3C 00 00 00 00 00 00 00 00 00 00"
#T
    HEX "33 33 33 00 00 33 00 00 00 00 00 00 00 00 00 00"
    HEX "00 33 00 00 33 33 00 00 00 33 00 00 00 00 00 00"
    HEX "00 33 00 00 33 33 33 00 00 00 00 00 00 00 00 00"
    HEX "33 00 00 00 33 33 00 00 33 00 00 00 00 00 00 00"
#S
    HEX "00 0C 0C 00 0C 0C 00 00 00 00 00 00 00 00 00 00"
    HEX "0C 00 00 00 0C 0C 00 00 00 0C 00 00 00 00 00 00"
    HEX "00 0C 0C 00 0C 0C 00 00 00 00 00 00 00 00 00 00"
    HEX "0C 00 00 00 0C 0C 00 00 00 0C 00 00 00 00 00 00"
#J
    HEX "00 03 00 00 00 03 00 00 03 03 00 00 00 00 00 00"
    HEX "03 00 00 00 03 03 03 00 00 00 00 00 00 00 00 00"
    HEX "03 03 00 00 03 00 00 00 03 00 00 00 00 00 00 00"
    HEX "03 03 03 00 00 00 03 00 00 00 00 00 00 00 00 00"
#Z
    HEX "30 30 00 00 00 30 30 00 00 00 00 00 00 00 00 00"
    HEX "00 30 00 00 30 30 00 00 30 00 00 00 00 00 00 00"
    HEX "30 30 00 00 00 30 30 00 00 00 00 00 00 00 00 00"
    HEX "00 30 00 00 30 30 00 00 30 00 00 00 00 00 00 00"
#L
    HEX "34 00 00 00 34 00 00 00 34 34 00 00 00 00 00 00"
    HEX "34 34 34 00 34 00 00 00 00 00 00 00 00 00 00 00"
    HEX "34 34 00 00 00 34 00 00 00 34 00 00 00 00 00 00"
    HEX "00 00 34 00 34 34 34 00 00 00 00 00 00 00 00 00"
