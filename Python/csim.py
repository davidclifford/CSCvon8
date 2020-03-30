# CSCVon8 Simulator written in Python
#  based on csim by Warren Toomey, GPL3 2019
# Added VGA graphics window

import sys
import time
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

PC = 0x0000
A = 0
B = 0
AH = 0
AL = 0
IR = 0
phase = 0

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

Ram = [0]*0x0000

file = open('alu.bin', 'rb')
ALURom = list(file.read())
file.close()

file = open('27Cucode.bin', 'rb')
DecodeRom = list(file.read())
file.close()

file = open('../Examples/wktlife_vid.bin', 'rb')
Ram = list(file.read())
Ram = Ram + [0 for _ in range(0x8000 - len(Ram))]
file.close()

file = open('../instr.bin', 'rb')
Rom = list(file.read())
file.close()

debug = False
input_string = ''
inchar = None
elapsed = 0

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
        databus = Ram[address-0x8000] if address >= 0x8000 else Rom[address]

    # Read UART
    if dbusop == UARTRESULT:
        if len(input_string) > 0:
            databus = ord(input_string[0])
            if loadop:
                input_string = input_string[1:]
        else:
            databus = 0

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
        if address >= 0x8000:
            Ram[address-0x8000] = databus
            if debug:
                print("->RAM %04x %02x" % (address-0x8000, Ram[address-0x8000]))
        else:
            x = address & 0x00FF
            y = (address >> 8) & 0xFF
            plot(x, y, databus)
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

    if jumpop == 7 and len(input_string) == 0:
        PC = address
        if debug:
            print("JI ")

    # Exit if PC goes to $FFFF
    if PC == 0xffff:
        if debug:
            print("\n")
        break

    if time.time() - elapsed > 0.25:
        pygame.display.flip()
        elapsed = time.time()

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            sys.exit()

        if event.type == pygame.KEYDOWN:
            input_string = input_string + chr(event.key)
