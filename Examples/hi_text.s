# Print in hires text mode to VGA

# Init coord, colour and string count
    STO 0 x
    STO 0 y
    STO 0 pos
    LCA $d0 # 1 101 0000
    STO A colour

puts:
    # Get Next character
    LDB pos
    LDA mess,B
    JAZ end

    # Control or character?
    LCB $20
    JLT control # is control character
    LDA A-B

    # Calculate position in ascii table and store address in 'pix'
    LCB @12
    STO A*B pix+1
    LDA A*BHI
    LHB ascii
    STO A+B pix

# change colour
    LDA x
    LDB y
    LDA A+B
    LCB @3
    LDA A/B
    LCB @7
    LDA A&B
    JAZ 1f
    JMP 2f
1:
    LCA @4
2:
    LCB @4
    LDA A<<B
    LCB $80
    LDA A|B
    STO A colour

    # Init drawing of character
    LCA @2
    STO A xc
    LCA @3
    STO A yc

    # Output pixel data onto screen
next_pix:
    LIA pix
    LDB colour
    LDA A|B
1:
    SIA y
    LDA pix+1
    TST A+1 JC 2f
    STO A+1 pix+1
    JMP 3f
2:
    STO 0 pix+1
    LDA pix
    STO A+1 pix
3:
    LDA x
    STO A+1 x
    LDA xc
    STO A-1 xc
    JAZ next_line
    JMP next_pix
next_line:
    LCB @3
    LDA x
    STO A-B x
    LCA @2
    STO A xc
    LDA y
    STO A+1 y
    LDA yc
    STO A-1 yc
    JAZ fin_char
    JMP next_pix
fin_char:
    LDA x
    LCB @3
    STO A+B x
    LDA y
    LCB @4
    STO A-B y
#    JMP monitor
    JMP next_char
control:
    # Do \n or \r (as same thing)
    LCB $0A
    JEQ 1f
    LCB $0D
    JEQ 1f
    JMP next_char
1:
    STO 0 x
    LDA y
    LCB @4
    STO A+B y

next_char:
    LDA pos
    STO A+1 pos
    JMP puts

end:
    JMP monitor

monitor: EQU $00bb

PAG
pos: BYTE
s_ptr: WORD
y: BYTE
x: BYTE
pix: WORD
colour: BYTE
xc: BYTE
yc: BYTE

PAG
mess: STR "THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG!\nthe quick brown fox jumps over the lazy dog?\n01234567890~\nTHE QUICK BROWN FOX JUMPS OVER THE LAZY DOG!\nthe quick brown fox jumps over the lazy dog?\n01234567890~\nTHE QUICK BROWN FOX JUMPS OVER THE LAZY DOG!"

PAG
ascii:
	HEX "00 00 00 00 00 00 00 00 00 00 00 00" #
	HEX "00 0d 08 00 07 02 00 01 00 00 01 00" #  !
	HEX "05 0a 0f 01 00 02 00 00 00 00 00 00" #  "
	HEX "00 08 08 01 0b 0b 04 0e 0e 00 02 02" #  #
	HEX "00 0e 08 01 0c 00 04 0c 02 00 01 00" #  $
	HEX "05 0a 05 00 04 02 04 02 0c 01 00 03" #  %
	HEX "04 06 00 01 09 00 05 01 09 00 03 01" #  &
	HEX "00 0f 00 00 02 00 00 00 00 00 00 00" #  '
	HEX "00 09 00 00 0a 00 00 0a 00 00 01 00" #  (
	HEX "00 06 00 00 05 00 00 05 00 00 02 00" #  )
	HEX "00 08 08 04 0f 0e 00 0b 0a 00 00 00" #  *
	HEX "00 04 00 04 0d 0c 00 05 00 00 00 00" #  +
	HEX "00 00 00 00 00 00 00 0c 00 00 0b 00" #  ,
	HEX "00 00 00 04 0c 0c 00 00 00 00 00 00" #  -
	HEX "00 00 00 00 00 00 00 0c 00 00 03 00" #  .
	HEX "00 00 04 00 04 02 04 02 00 00 00 00" #  /
	HEX "04 03 06 05 04 07 05 02 05 00 03 02" #  0
	HEX "00 0d 00 00 05 00 00 05 00 00 03 02" #  1
	HEX "04 03 06 00 04 09 04 02 00 01 03 03" #  2
	HEX "04 03 06 00 0c 09 04 00 05 00 03 02" #  3
	HEX "00 04 0a 04 02 0a 01 03 0b 00 00 02" #  4
	HEX "05 03 03 05 0c 08 04 00 05 00 03 02" #  5
	HEX "00 09 02 05 0c 08 05 00 05 00 03 02" #  6
	HEX "01 03 07 00 04 02 00 0a 00 00 02 00" #  7
	HEX "04 03 06 01 0c 09 05 00 05 00 03 02" #  8
	HEX "04 03 06 01 0c 0d 00 00 09 00 03 00" #  9
	HEX "00 00 00 00 0f 00 00 0c 00 00 03 00" #  :
	HEX "00 00 00 00 0f 00 00 0c 00 00 0b 00" #  ;
	HEX "00 04 02 04 02 00 00 06 00 00 00 02" #  <
	HEX "00 00 00 01 03 03 04 0c 0c 00 00 00" #  =
	HEX "00 06 00 00 00 06 00 04 02 00 02 00" #  >
	HEX "04 03 06 00 04 09 00 01 00 00 01 00" #  ?
	HEX "04 03 06 05 05 07 05 01 03 00 03 02" #  @
	HEX "04 03 06 05 00 05 05 03 07 01 00 01" #  A
	HEX "05 03 06 05 0c 09 05 00 05 01 03 02" #  B
	HEX "04 03 06 05 00 00 05 00 04 00 03 02" #  C
	HEX "05 03 06 05 00 05 05 00 05 01 03 02" #  D
	HEX "05 03 03 05 0c 08 05 00 00 01 03 03" #  E
	HEX "05 03 03 05 0c 08 05 00 00 01 00 00" #  F
	HEX "04 03 06 05 04 0c 05 00 05 00 03 03" #  G
	HEX "05 00 05 05 0c 0d 05 00 05 01 00 01" #  H
	HEX "00 07 02 00 05 00 00 05 00 00 03 02" #  I
	HEX "00 00 05 00 00 05 05 00 05 00 03 02" #  J
	HEX "05 00 09 05 09 00 05 01 08 01 00 01" #  K
	HEX "05 00 00 05 00 00 05 00 00 01 03 03" #  L
	HEX "05 08 0d 05 01 05 05 00 05 01 00 01" #  M
	HEX "05 08 05 05 01 0d 05 00 05 01 00 01" #  N
	HEX "04 03 06 05 00 05 05 00 05 00 03 02" #  O
	HEX "05 03 06 05 0c 09 05 00 00 01 00 00" #  P
	HEX "04 03 06 05 00 05 05 01 09 00 03 01" #  Q
	HEX "05 03 06 05 0c 09 05 00 06 01 00 01" #  R
	HEX "04 03 06 01 0c 08 04 00 05 00 03 02" #  S
	HEX "01 07 03 00 05 00 00 05 00 00 01 00" #  T
	HEX "05 00 05 05 00 05 05 00 05 00 03 02" #  U
	HEX "05 00 05 05 00 05 01 08 09 00 01 00" #  V
	HEX "05 00 05 05 05 05 05 05 05 00 02 02" #  W
	HEX "05 00 05 00 06 02 04 02 06 01 00 01" #  X
	HEX "05 00 05 01 08 09 00 05 00 00 01 00" #  Y
	HEX "01 03 0a 00 09 00 05 00 00 01 03 02" #  Z
	HEX "00 0b 02 00 0a 00 00 0a 00 00 03 02" #  [
	HEX "04 00 00 00 06 00 00 00 06 00 00 00" #  \
PAG
	HEX "00 03 0a 00 00 0a 00 00 0a 00 03 02" #  ]
	HEX "00 09 08 01 00 01 00 00 00 00 00 00" #  ^
	HEX "00 00 00 00 00 00 00 00 00 0c 0c 0c" #  _
	HEX "00 0f 00 00 01 00 00 00 00 00 00 00" #  `
	HEX "00 00 00 00 03 06 04 03 07 00 03 03" #  a
	HEX "05 00 00 05 03 06 05 00 05 01 03 02" #  b
	HEX "00 00 00 04 03 06 05 00 04 00 03 02" #  c
	HEX "00 00 05 04 03 07 05 00 05 00 03 03" #  d
	HEX "00 00 00 04 03 06 05 03 02 00 03 02" #  e
	HEX "00 09 02 04 0e 08 00 0a 00 00 02 00" #  f
	HEX "00 00 00 04 03 07 01 0c 0d 00 0c 09" #  g
	HEX "05 00 00 05 03 08 05 00 0a 01 00 02" #  h
	HEX "00 01 00 00 05 00 00 05 00 00 01 02" #  i
	HEX "00 00 02 00 01 0a 00 00 0a 01 0c 02" #  j
	HEX "05 00 00 05 04 02 05 06 00 01 00 02" #  k
	HEX "00 05 00 00 05 00 00 05 00 00 01 02" #  l
	HEX "00 00 00 05 06 06 05 01 05 01 00 01" #  m
	HEX "00 00 00 05 03 08 05 00 0a 01 00 02" #  n
	HEX "00 00 00 04 03 06 05 00 05 00 03 02" #  o
	HEX "00 00 00 05 03 06 05 00 05 05 03 02" #  p
	HEX "00 00 00 04 03 07 05 00 05 00 03 07" #  q
	HEX "00 00 00 01 09 06 00 0a 00 01 03 00" #  r
	HEX "00 00 00 04 03 02 00 03 06 00 03 02" #  s
	HEX "00 08 00 01 0b 02 00 0a 08 00 01 00" #  t
	HEX "00 00 00 05 00 0a 05 04 0a 00 02 02" #  u
	HEX "00 00 00 05 00 05 01 08 09 00 01 00" #  v
	HEX "00 00 00 05 00 05 05 0d 0d 00 02 02" #  w
	HEX "00 00 00 05 00 0a 04 03 08 01 00 02" #  x
	HEX "00 00 00 05 00 0a 01 0c 0a 04 09 00" #  y
	HEX "00 00 00 01 03 0a 04 03 00 01 03 02" #  z
	HEX "00 09 02 04 0a 00 00 0a 00 00 01 02" #  {
	HEX "00 05 00 00 01 00 00 05 00 00 01 00" #  |
	HEX "00 03 08 00 00 0e 00 00 0a 00 03 00" #  }
	HEX "04 06 02 00 00 00 00 00 00 00 00 00" #  ~
	HEX "00 0d 08 05 02 07 05 0c 0d 00 00 00" #  