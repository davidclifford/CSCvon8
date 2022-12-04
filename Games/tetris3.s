# Tetris 3 for the CSCvon8
# By David Clifford Sept 2020
#
    NAME "tetres"
start:
    LCA @1
    STO A restart
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

    STO 0 __paper
    LCA @1
    STO A __ypos
    LCA @10
    STO A __xpos

    LCA $30
    STO A __ink
    LCA 'T'
    STO A __char
    JSR sys_pchar sys_pchar_ret

    LCA $3C
    STO A __ink
    LCA 'E'
    STO A __char
    JSR sys_pchar sys_pchar_ret

    LCA $0C
    STO A __ink
    LCA 'T'
    STO A __char
    JSR sys_pchar sys_pchar_ret

    LCA $33
    STO A __ink
    LCA 'R'
    STO A __char
    JSR sys_pchar sys_pchar_ret

    LCA $0F
    STO A __ink
    LCA 'E'
    STO A __char
    JSR sys_pchar sys_pchar_ret

    LCA $34
    STO A __ink
    LCA 'S'
    STO A __char
    JSR sys_pchar sys_pchar_ret

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

# Print label "Next Piece"
    LCA @4
    STO A __sypos
    LCA @36
    STO A __sxpos
    LCA $04
    STO A __sink
    LCB label_next_piece
1:
    STO B char_indx
    LDA label_next_piece,B
    JAZ 2f
    STO A __schar
    JSR sys_spchar sys_spchar_ret
    LDB char_indx
    LDB B+1
    JMP 1b
2:

# Print label "Score"
    LCA @9
    STO A __sypos
    LCA @36
    STO A __sxpos
    LCA $03
    STO A __sink
    LCB label_score
1:
    STO B char_indx
    LDA label_score,B
    JAZ 2f
    STO A __schar
    JSR sys_spchar sys_spchar_ret
    LDB char_indx
    LDB B+1
    JMP 1b
2:

# Print Instructions
    LCA @4
    STO A __sypos
    LCA @0
    STO A __sxpos
    LCA $06
    STO A __sink
    LCB label_instr1
1:
    STO B char_indx
    LDA label_instr1,B
    JAZ 2f
    STO A __schar
    JSR sys_spchar sys_spchar_ret
    LDB char_indx
    LDB B+1
    JMP 1b
2:
# Skip message if restarting
    LDA restart
    JAZ skip

# Print start message
#    LCA $04
    STO 0 __sink # 0 = Orange
    LCA @17
    STO A __sxpos
    LCA @0
    STO A __sypos
    LCB start_mess
1:
    STO B char_indx
    LDA start_mess,B
    JAZ 2f
    STO A __schar
    JSR sys_spchar sys_spchar_ret
    LDB char_indx
    LDB B+1
    JMP 1b

# Wait for Enter or Q to be pressed, update random
2:
    LDA rand+1
    LDA A+1
    STO A rand+1
    JAZ 4f
    JMP 5f
4:
    LDA rand
    STO A+1 rand
5:
    JIU 2b
    INA
    LCB '\r'
    JEQ 3f
    LCB '\n'
    JEQ 3f
    LCB 'q'
    JNE 2b
    JMP exit_game
3:
# Store seed
    LDA rand
    STO A __rand_seed
    LDA rand+1
    STO A __rand_seed+1
# Erase start message
    STO 0 __sink
    LCA @17
    STO A __sxpos
    LCA @0
    STO A __sypos
    LCB start_mess
1:
    STO B char_indx
    LDA start_mess,B
    JAZ skip
    LCA ' '
    STO A __schar
    JSR sys_spchar sys_spchar_ret
    LDB char_indx
    LDB B+1
    JMP 1b
skip:
    STO 0 restart
# random piece (next)
    JSR sys_rand sys_rand_ret
    LDA __rand_seed
    LCB @7
    STO A%B next

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
    JAZ 2f
    JMP 5b
2:
# Set score to 0000
    STO 0 score0
    STO 0 score1
    STO 0 score2
    STO 0 score3
    STO 0 score4
    STO 0 score5
    JSR disp_score

next_piece:
# Erase last next piece
    LDA next
    STO A piece
    STO 0 erase
    LCA @12
    LDB 0
    STO A tile_x
    STO B tile_y
    STO 0 rota
    JSR disp_piece
# Copy next piece to piece
    LDA piece
    STO A temp
    LDA next
    STO A piece
# Choose random next piece
# set piece
31:
    JSR sys_rand sys_rand_ret
    LDA __rand_seed
    LCB @7
    LDA A%B
    LDB temp
    JEQ 31b
30:
    STO A next
# Show next piece
    LCA $FF
    STO A erase
    LDA piece
    STO A temp
    LDA next
    STO A piece
    LCA @12
    LDB 0
    STO A tile_x
    STO B tile_y
    STO 0 rota
    JSR disp_piece
    LDA temp
    STO A piece
# Set rotation
    LDA __rand_seed
    LCB $03
    STO A&B rota
# set x
    LDA __rand_seed
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
    LCA @200
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
    JIU 16f
    INA
    STO A keypress
    JMP 11f
16:
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
    LCA @200
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
    # Q quit
    LCB 'q'
    JEQ game_over

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

    # Update BCD score
    LCA @5
    STO A _score0
    STO 0 _score1
    STO 0 _score2
    STO 0 _score3
    JSR add_score
    JSR disp_score

    STO 0 lines
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
    # Update lines erased
    LDA lines
    STO A+1 lines
    # loop back to 14
    JMP 14b
15:
    # tile_y -= 1
    LDA tile_y
    LDA A-1
    STO A tile_y
    # loop if tile_y > 0 else get next piece
    JAZ 17f
    JMP 14b
17:
    # Update score
    STO 0 _score0
    STO 0 _score1
    STO 0 _score2
    STO 0 _score3
    LDA lines
    # 0 lines
    JAZ 18f
    # 1 line
    LDA A-1
    JAZ 20f
    # 2 lines
    LDA A-1
    JAZ 21f
    # 3 lines
    LDA A-1
    JAZ 22f
    # 4 lines - Add 1200
    LCA @1
    STO A _score3
    LCA @2
    STO A _score2
    JMP 23f
20: # 1 line - add 40
    LCA @4
    STO A _score1
    JMP 23f
21: # 2 lines - add 100
    LCA @1
    STO A _score2
    JMP 23f
22: # 3 lines - add 300
    LCA @3
    STO A _score2
23:
    JSR add_score
    JSR disp_score
18:
    JMP next_piece
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
    LCA $05
    STO A __sink
    LCA @19
    STO A __sxpos
    LCA @0
    STO A __sypos
    LCB game_over_mess
1:
    STO B char_indx
    LDA game_over_mess,B
    JAZ 2f
    STO A __schar
    JSR sys_spchar sys_spchar_ret
    LDB char_indx
    LDB B+1
    JMP 1b

# Wait for Enter or Q to be pressed
2:
    JIU 2b
    INA
    LCB '\r'
    JEQ 3f
    LCB '\n'
    JEQ 3f
    LCB 'q'
    JNE 2b
    JMP exit_game
3:
# Erase start message
    STO 0 __ink
    STO 0 __paper
    LCA @4
    STO A __xpos
    LCA @14
    STO A __ypos
    LCB game_over_mess
1:
    STO B char_indx
    LDA game_over_mess,B
    JAZ 2f
    STO A __char
    JSR sys_pchar sys_pchar_ret
    LDB char_indx
    LDB B+1
    JMP 1b
2:
# Clear play area
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

# SUBROUTINE add_score
# Add _score to score
add_score:
    LDA _score0
    LDB score0
    LDA A+B
    STO A score0
    LCB @10
    JLT 1f
    STO A-B score0
    LDA score1
    STO A+1 score1
1:
    LDA _score1
    LDB score1
    LDA A+B
    STO A score1
    LCB @10
    JLT 2f
    STO A-B score1
    LDA score2
    STO A+1 score2
2:
    LDA _score2
    LDB score2
    LDA A+B
    STO A score2
    LCB @10
    JLT 3f
    STO A-B score2
    LDA score3
    STO A+1 score3
3:
    LDA _score3
    LDB score3
    LDA A+B
    STO A score3
    LCB @10
    JLT 6f
    STO A-B score3
4:
    LDA score4
    LDA A+1
    STO A score4
    LCB @10
    JLT 6f
    STO A-B score4
5:
    LDA score5
    LDA A+1
    STO A score5
    LCB @10
    JLT 6f
    STO A-B score5
6:
    RTS add_score
# END SUBROUTINE add_score

# SUBROUTINE disp_score
disp_score:

    LCA @11
    STO A __sypos
    LCA @36
    STO A __sxpos

    LCA $03
    STO A __sink

    LCB $30
    LDA score5
    LDA A+B
    STO A __schar
    JSR sys_spchar sys_spchar_ret

    LCB $30
    LDA score4
    LDA A+B
    STO A __schar
    JSR sys_spchar sys_spchar_ret

    LCB $30
    LDA score3
    LDA A+B
    STO A __schar
    JSR sys_spchar sys_spchar_ret

    LCB $30
    LDA score2
    LDA A+B
    STO A __schar
    JSR sys_spchar sys_spchar_ret

    LCB $30
    LDA score1
    LDA A+B
    STO A __schar
    JSR sys_spchar sys_spchar_ret

    LCB $30
    LDA score0
    LDA A+B
    STO A __schar
    JSR sys_spchar sys_spchar_ret

    RTS disp_score


# Exit to monitor
exit_game:
    JMP sys_cli

PAG
# System variables
#include "../Examples/monitor.h"

# Tetris variables
char_indx: BYTE
rand: WORD
tile: WORD
rota: BYTE
next_rota: BYTE
tx: BYTE
ty: BYTE
tile_x: BYTE
tile_y: BYTE
next_tile_x: BYTE
next_tile_y: BYTE
txc: BYTE
tyc: BYTE
piece: BYTE
next: BYTE
temp: BYTE
pxc: BYTE
pyc: BYTE
pix: BYTE
px: BYTE
py: BYTE
erase: BYTE
fits: BYTE
down: BYTE
full: BYTE
gravity: WORD
keypress: BYTE
score0: BYTE
score1: BYTE
score2: BYTE
score3: BYTE
score4: BYTE
score5: BYTE
_score0: BYTE
_score1: BYTE
_score2: BYTE
_score3: BYTE
lines: BYTE
restart: BYTE

PAG
start_mess: STR "Press Enter to Start"
game_over_mess: STR "Game over, Man!"
label_score: STR "Score"
label_instr1: STR " A Left, D Right\n W Turn, S Down\n Q Quit\n Enter Start"
label_next_piece: STR "Next Piece"
PAG
board: BYTE @200
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
