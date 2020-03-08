# CSCVon8 Simulator written in Python
#  based on csim by Warren Toomey, GPL3 2019
# Added VGA graphics window

import sys
import pygame
from pygame import gfxdraw


def plot(x, y, colour):
    psize = 8
    col = (((colour >> 4) & 0x3) << 6, ((colour >> 2) & 0x3) << 6, (colour & 0x3) << 6)
    for yy in range(psize):
        for xx in range(psize):
            gfxdraw.pixel(screen, x * psize + xx, y * psize + yy, col)


pygame.init()
screen = pygame.display.set_mode((1280, 960))

debug = 0
PC = 0
A = 0
B = 0
AH = 0
AL = 0
IR = 0
phase = 0

# The 1-char buffer from the keyboard. undefined means no character.
inchar = 0

ALUOP    = 0x001f
LOADOP   = 0x0007
LOADSHIFT = 5
DBUSOP   = 0x0003
DBUSSHIFT = 8
JUMPOP   = 0x0007
JUMPSHIFT = 10
ARENA    = 0x0001
ARSHIFT = 13		# Active low
PCINCR   = 0x0001
PCSHIFT = 14
USRESET  = 0x0001
USSHIFT = 15		# Active low
IRSHIFT  = 4
CSHIFT = 8
VSHIFT = 9
ZSHIFT = 10
NSHIFT = 11
DSHIFT = 12
MEMRESULT = 0
ALURESULT = 1
UARTRESULT = 2

ALUop = [
    "0",
    "A",
    "B",
    "-A",
    "-B",
    "A+1",
    "B+1",
    "A-1",
    "B-1",
    "A+B",
    "A+B+1",
    "A-B",
    "A-Bspecial",
    "B-A",
    "A-B-1",
    "B-A-1",
    "A*BHI",
    "A*BLO",
    "A/B",
    "A%B",
    "A<<B",
    "A>>BL",
    "A>>BA",
    "AROLB",
    "ARORB",
    "A&B",
    "A|B",
    "A^B",
    "!A",
    "!B",
    "ADIVB",
    "AREMB"
]

Ram = [0]*0x8000

file = open('alu.bin', 'rb')
ALURom = list(file.read())
file.close()

file = open('27Cucode.bin', 'rb')
DecodeRom = list(file.read())
file.close()

file = open('../instr.bin', 'rb')
Rom = list(file.read())
file.close()

debug = False

### LOOP
while True:

    # Work out the decode ROM index
    decodeidx = (IR << IRSHIFT) | phase
    # Get the microinstruction
    uinst = (DecodeRom[decodeidx*2+1] << 8) | DecodeRom[decodeidx*2]

    carry = 0
    overflow = 0
    zero = 0
    negative = 0
    divbyzero = 0

    # Decode the microinstruction
    aluop = uinst & ALUOP
    loadop = (uinst >> LOADSHIFT) & LOADOP
    dbusop = (uinst >> DBUSSHIFT) & DBUSOP
    jumpop = (uinst >> JUMPSHIFT) & JUMPOP
    arena = (uinst >> ARSHIFT) & ARENA
    pcincr = (uinst >> PCSHIFT) & PCINCR
    usreset = (uinst >> USSHIFT) & USRESET
    if debug:
        print("PC %04x IR %02x p %01x ui %04x upa %d%d%d "
              % (PC, IR, phase, uinst, usreset, pcincr, arena))

    # Do the ALU operation.
    databus = 0
    if dbusop == ALURESULT:
        alu_addr = ((aluop << 16) | (A << 8) | B)*2
        aluresult= (ALURom[alu_addr+1] << 8) | (ALURom[alu_addr])
        if debug:
            print("AB %02x %02x %s %04x " % (A, B, ALUop[aluop], aluresult))

        # Extract the flags from the result, and remove from the result
        carry = (aluresult >> CSHIFT) & 1
        overflow = (aluresult >> VSHIFT) & 1
        zero = (aluresult >> ZSHIFT) & 1
        negative = (aluresult >> NSHIFT) & 1
        divbyzero = (aluresult >> DSHIFT) & 1
        if debug:
            print("FL %d%d%d%d%d" % (carry, overflow, zero, negative, divbyzero))
        databus = aluresult & 0xff

    # Determine the address on the address bus: AR or PC
    address = 0
    if arena == 0:
        address = (AH << 8) | AL
        if debug:
            print("AR %02x%02x " % (AH, AL))
    else:
        address = PC
        if debug:
            print("PC %04x " % PC)

    # Get the memory value
    if dbusop == MEMRESULT:
        databus = Ram[address-0x8000] if address & 0x8000 else Rom[address]

    # Read UART
    # TODO

    if debug:
        print("dop %x dbus %02x " % (dbusop, databus))

    # Load from the data bus
    if loadop == 1:
        IR = databus
        if debug:
            print("->IR %02x" % IR)
    if loadop == 2:
        A = databus
        if debug:
            print("->A %02x" % A)
    if loadop == 3:
        B = databus
        if debug:
            print("->B %02x" % B)
    if loadop == 4:
        if address & 0x8000:
            Ram[address-0x8000] = databus
            if debug:
                print("->RAM %04x %02x" % (address-0x8000, Ram[address-0x8000]))
    if loadop == 5:
        AH = databus
        if debug:
            print("->AH %02x" % AH)
    if loadop == 6:
        AL = databus
        if debug:
            print("->AL %02x" % AL)
    if loadop == 7:
        print(chr(databus), end='')  # Flush the output
        if debug:
            print("->IO %s" % chr(databus))

    # Increment the PC and the phase
    if pcincr == 1:
        PC = PC + 1
    phase = 0 if usreset == 0 else (phase+1) & 0xf

    # Do any jumps
    if jumpop == 1 and carry:
        PC = address
        if debug:
            print("JC ")

    if jumpop == 2 and overflow:
        PC = address
        if debug:
            print("JO ")

    if jumpop == 3 and zero:
        PC = address
        if debug:
            print("JZ ")

    if jumpop == 4 and negative:
        PC = address
        if debug:
            print("JN ")

    if jumpop == 5 and divbyzero:
        PC = address
        if debug:
            print("JD ")

    # Exit if PC goes to $FFFF
    if PC == 0xffff:
        if debug:
            print("\n")
        break
    ####################################################

    pygame.display.flip()

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            sys.exit()
### LOOP


# #!/usr/bin/perl
# use strict;
# use warnings;
# use Data::Dumper;
# use Term::ReadKey;
# use IO::Pty;
# use Storable;
# use GD::Simple
#
# # CSCVon8 Simulator, (C) 2019 Warren Toomey, GPL3
#
# my @RAM= (0) x 32768;
# my @ROM;
# my $ALUROM;
# my @DecodeROM;
# my $debug=0;
# my $PC=0;
# my $A=0;
# my $B=0;
# my $AH=0;
# my $AL=0;
# my $IR=0;
# my $phase=0;
#
# my $aluop;
# my $loadop;
# my $dbusop;
# my $jumpop;
# my $arena;
# my $pcincr;
# my $usreset;
#
# # The 1-char buffer from the keyboard. undefined means no character.
# my $inchar;
#
# # By default, UART I/O goes to STDIN/OUT
# my $IN=   *STDIN;
# my $OUT= *STDOUT;
#
# # List of control line masks and shifts.
# use constant {
#   ALUOP    => 0x001f,
#   LOADOP   => 0x0007, LOADSHIFT => 5,
#   DBUSOP   => 0x0003, DBUSSHIFT => 8,
#   JUMPOP   => 0x0007, JUMPSHIFT => 10,
#   ARENA    => 0x0001, ARSHIFT => 13,		# Active low
#   PCINCR   => 0x0001, PCSHIFT => 14,
#   USRESET  => 0x0001, USSHIFT => 15,		# Active low
#   IRSHIFT  => 4,
#   CSHIFT => 8,
#   VSHIFT => 9,
#   ZSHIFT => 10,
#   NSHIFT => 11,
#   DSHIFT => 12,
#   MEMRESULT => 0,
#   ALURESULT => 1,
#   UARTRESULT => 2,
# };
#
# # List of ALUop names
# my @ALUop = (
#     "0",
#     "A",
#     "B",
#     "-A",
#     "-B",
#     "A+1",
#     "B+1",
#     "A-1",
#     "B-1",
#     "A+B",
#     "A+B+1",
#     "A-B",
#     "A-Bspecial",
#     "B-A",
#     "A-B-1",
#     "B-A-1",
#     "A*BHI",
#     "A*BLO",
#     "A/B",
#     "A%B",
#     "A<<B",
#     "A>>BL",
#     "A>>BA",
#     "AROLB",
#     "ARORB",
#     "A&B",
#     "A|B",
#     "A^B",
#     "!A",
#     "!B",
#     "A+BCD",
#     "A-BCD"
# );
#
# # Enable debugging, pty I/O and randomised memory
# while (@ARGV > 0) {
#   # Set debug mode
#   if ($ARGV[0] eq "-d") { $debug++; shift(@ARGV); next; }
#
#   # Open up a pty
#   if ($ARGV[0] eq "-p") {
#     $OUT = new IO::Pty; $IN= $OUT;
#     print("pty is ", $OUT->ttyname(), "\n");
#     shift(@ARGV); next;
#   }
#
#   # Randomise the RAM
#   if ($ARGV[0] eq "-r") {
#     foreach my $i (0 .. 32767) {
#       $RAM[$i]= int(rand(256));
#     }
#     shift(@ARGV); next;
#   }
#   die("Usage: $0 [-d] [-p] [-r]\n-d: debug, -r: randomise RAM, -p: open pty\n");
# }
#
# # Set the UART up to read one char at a time
# ReadMode('cbreak', $IN);
#
# # Load the ALU ROM
# my $ROMIN;
# if (-f "alu.hex") {
#   $ALUROM = retrieve("alu.hex");
# } else {
#   # Load the ROM file and store a cached version
#   open( $ROMIN, "<", "alu.rom" ) || die("Can't open alu.rom: $!\n");
#   while (<$ROMIN>) {
#     chomp; push( @{ $ALUROM }, map( { hex($_) } split( /\s/, $_ ) ) );
#   }
#   close($ROMIN);
#   store($ALUROM, "alu.hex");
# }
#
# # Load the Decode ROM
# open( $ROMIN, "<", "ucode.rom" ) || die("Can't open ucode.rom: $!\n");
# while (<$ROMIN>) {
#     chomp; push( @DecodeROM, map( { hex($_) } split( /\s+/, $_ ) ) );
# }
# close($ROMIN);
#
# # Load the instruction ROM
# open( $ROMIN, "<", "instr.rom" ) || die("Can't open instr.rom: $!\n");
# while (<$ROMIN>) {
#     chomp; push( @ROM, map( { hex($_) } split( /\s+/, $_ ) ) );
# }
# close($ROMIN);
#
# # Start the simulation
# while (1) {
#   # Work out the decode ROM index
#   my $decodeidx= ($IR << IRSHIFT) | $phase;
#
#   # Get the microinstruction
#   my $uinst= $DecodeROM[ $decodeidx ];
#
#   # Decode the microinstruction
#   $aluop= $uinst & ALUOP;
#   $loadop= ($uinst>>LOADSHIFT) & LOADOP;
#   $dbusop= ($uinst>>DBUSSHIFT) & DBUSOP;
#   $jumpop= ($uinst>>JUMPSHIFT) & JUMPOP;
#   $arena=  ($uinst>>ARSHIFT)   & ARENA;
#   $pcincr= ($uinst>>PCSHIFT)   & PCINCR;
#   $usreset= ($uinst>>USSHIFT)  & USRESET;
#   printf("PC %04x IR %02x p %01x ui %04x upa %d%d%d ", $PC,
# 		$IR, $phase, $uinst, $usreset, $pcincr, $arena) if ($debug);
#
#   # Do the ALU operation.
#   my $databus=0;
#   my ($carry, $overflow, $zero, $negative, $divbyzero);
#   if ($dbusop== ALURESULT) {
#     my $aluresult= $ALUROM->[ ($aluop<<16) | ($A<<8) | $B ];
#     printf("AB %02x %02x %s %04x ", $A, $B, $ALUop[$aluop], $aluresult)
# 								if ($debug);
#
#     # Extract the flags from the result, and remove from the result
#     $carry= ($aluresult>>CSHIFT) & 1;
#     $overflow= ($aluresult>>VSHIFT) & 1;
#     $zero= ($aluresult>>ZSHIFT) & 1;
#     $negative= ($aluresult>>NSHIFT) & 1;
#     $divbyzero= ($aluresult>>DSHIFT) & 1;
#     $databus = $aluresult & 0xff;
#   }
#
#   # Determine the address on the address bus: AR or PC
#   my $address;
#   if ($arena==0) {
#     $address= ($AH<<8) | $AL;
#     printf("AR %02x%02x ", $AH, $AL) if ($debug);
#   } else {
#     $address= $PC;
#     printf("PC %04x ", $PC) if ($debug);
#   }
#
#   # Get the memory value
#   if ($dbusop== MEMRESULT) {
#     $databus= ($address & 0x8000) ? $RAM[$address-0x8000] : $ROM[$address];
#   }
#
#   # Read from UART. Wait up to 0.5 seconds,
#   # and if no character, "read" a NUL character.
#   if ($dbusop== UARTRESULT) {
#     # Return 0 if they were silly enough to read when nothing is there.
#     # Empty the buffer regardless.
#     $databus = defined($inchar) ? ord($inchar) : 0;
#
#     # Only reset $inchar if there is a reader on the data bus. This
#     # allows UARTRESULT to be asserted for several microinstructions
#     # before the actual read is done.
#     $inchar= undef if ($loadop);
#   }
#   printf("dop %x dbus %02x ", $dbusop, $databus) if ($debug);
#
#   # Load from the data bus
#   if ($loadop==1) { $IR= $databus; print("->IR ") if ($debug); }
#   if ($loadop==2) { $A= $databus; print("->A ") if ($debug); }
#   if ($loadop==3) { $B= $databus; print("->B ") if ($debug); }
#   if ($loadop==4) {
#     if ($address & 0x8000) { $RAM[$address-0x8000]= $databus; }
#     print("->RAM ") if ($debug);
#   }
#   if ($loadop==5) { $AH= $databus; print("->AH ") if ($debug); }
#   if ($loadop==6) { $AL= $databus; print("->AL ") if ($debug); }
#   if ($loadop==7) {
#     print($OUT chr($databus)); $|=1;		# Flush the output
#     print("->IO ") if ($debug);
#   }
#
#   # Increment the PC and the phase
#   $PC++ if ($pcincr==1);
#   $phase= ($usreset==0) ? 0 : ($phase+1) & 0xf;
#
#   # Do any jumps
#   printf("j%d ", $jumpop) if ($jumpop && $debug);
#   if ($jumpop==1 && $carry) {
#     $PC= $address;
#     print("JC ") if ($debug);
#   }
#   if ($jumpop==2 && $overflow) {
#     $PC= $address;
#     print("JO ") if ($debug);
#   }
#   if ($jumpop==3 && $zero) {
#     $PC= $address;
#     print("JZ ") if ($debug);
#   }
#   if ($jumpop==4 && $negative) {
#     $PC= $address;
#     print("JN ") if ($debug);
#   }
#   if ($jumpop==5 && $divbyzero) {
#     $PC= $address;
#     print("JD ") if ($debug);
#   }
#
#   # If the instruction is testing for an available UART character to
#   # read and we have one, don't jump. If not, try to read one and
#   # jump if that fails. If we read one, put it in the $inchar buffer.
#   if ($jumpop==7 && !defined($inchar)) {
#
#     # This code if we are reading from a terminal
#     if (-t $IN) {
#       $inchar= ReadKey(0.5, $IN);
#     } else {
#       # This code for files and pipes
#       $inchar= getc($IN);
#       printf("File/pipe read %02x ", (defined($inchar) ? ord($inchar) : 0xff)) if ($debug);
#     }
#
#     # There was no character to read
#     if (!defined($inchar)) {
#       $PC= $address; print("JI ") if ($debug);
#     }
#   }
#
#   # Exit if PC goes to $FFFF
#   last if ($PC==0xffff);
#   print("\n") if ($debug);
# }
#
# # Clean up and exit
# ReadMode('normal', $IN);
# exit(0);
