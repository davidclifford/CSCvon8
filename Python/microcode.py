import struct
# Control Signals

ZERO       = 0x0000
A          = 0x0001
B          = 0x0002
mA         = 0x0003
mB         = 0x0004
Ainc       = 0x0005
Binc       = 0x0006
Adec       = 0x0007
Bdec       = 0x0008
ApB        = 0x0009
ApBp1      = 0x000A
AmB        = 0x000B
AmBsp      = 0x000C
BmA        = 0x000D
AmBm1      = 0x000E
BmAm1      = 0x000F
AxBLO      = 0x0010
AxBHI      = 0x0011
AdivB      = 0x0012
AmodB      = 0x0013
AsllB      = 0x0014
AsrlB      = 0x0015
AsraB      = 0x0016
AROLB      = 0x0017
ARORB      = 0x0018
AandB      = 0x0019
AorB       = 0x001A
AxorB      = 0x001B
notA       = 0x001C
notB       = 0x001D
Adiv10B    = 0x001E
Arem10B    = 0x001F

# Loads from the data bus
IRload	   = 0x0020
Aload	   = 0x0040
Bload	   = 0x0060
MEMload	   = 0x0080
AHload	   = 0x00A0
ALload	   = 0x00C0
IOload	   = 0x00E0

# Writers on the data bus
MEMresult  = 0x0000
ALUresult  = 0x0100
UARTresult = 0x0200
VIDresult  = 0x0300

# Jump operations
NoJump     = 0x0000
JumpCarry  = 0x0400
JumpOflow  = 0x0800
JumpZero   = 0x0C00
JumpNeg    = 0x1000
JumpDivZero= 0x1400
JumpNoTx   = 0x1800
JumpNoRx   = 0x1C00

# Address bus writers: if no ARena then PC is implied
ARena	   = 0x2000

# Other control lines, increment the PC and reset the microsequencer
PCincr     = 0x4000
uSreset    = 0x8000

# This line, if given, is placed at position zero for each microinstruction.
# The purpose is to load the IR with the instruction and increment the PC.
#
START = MEMresult | IRload | PCincr
control = [0 for _ in range(256 * 16 * 16)]


def do_instruction(opcode, carry, zero, neg, over):
    # NOP

    # LDA
    if opcode == 0x01:
        return [ALUresult | ZERO | Aload]
    if opcode == 0x02:
        return [ALUresult | B | Aload]
    if opcode == 0x03:
        return [ALUresult | mA | Aload]
    if opcode == 0x04:
        return [ALUresult | mB | Aload]
    if opcode == 0x05:
        return [ALUresult | Ainc | Aload]
    if opcode == 0x06:
        return [ALUresult | Binc | Aload]
    if opcode == 0x07:
        return [ALUresult | Adec | Aload]
    if opcode == 0x08:
        return [ALUresult | Bdec | Aload]
    if opcode == 0x09:
        return [ALUresult | ApB | Aload]
    if opcode == 0x0a:
        return [ALUresult | ApBp1 | Aload]
    if opcode == 0x0b:
        return [ALUresult | AmB | Aload]
        # No 0xc
        #
    if opcode == 0x0d:
        return [ALUresult | BmA | Aload]
    if opcode == 0x0e:
        return [ALUresult | AmBm1 | Aload]
    if opcode == 0x0f:
        return [ALUresult | BmAm1 | Aload]
    if opcode == 0x10:
        return [ALUresult | AxBHI | Aload]
    if opcode == 0x11:
        return [ALUresult | AxBLO | Aload]
    if opcode == 0x12:
        return [ALUresult | AdivB | Aload]
    if opcode == 0x13:
        return [ALUresult | AmodB | Aload]
    if opcode == 0x14:
        return [ALUresult | AsllB | Aload]
    if opcode == 0x15:
        return [ALUresult | AsrlB | Aload]
    if opcode == 0x16:
        return [ALUresult | AsraB | Aload]
    if opcode == 0x17:
        return [ALUresult | AROLB | Aload]
    if opcode == 0x18:
        return [ALUresult | ARORB | Aload]
    if opcode == 0x19:
        return [ALUresult | AandB | Aload]
    if opcode == 0x1a:
        return [ALUresult | AorB | Aload]
    if opcode == 0x1b:
        return [ALUresult | AxorB | Aload]
    if opcode == 0x1c:
        return [ALUresult | notA | Aload]
    if opcode == 0x1d:
        return [ALUresult | notB | Aload]
    if opcode == 0x1e:
        return [ALUresult | Adiv10B | Aload]
    if opcode == 0x1f:
        return [ALUresult | Arem10B | Aload]

    # LDB
    # 0x20 not used
    if opcode == 0x21:
        return [ALUresult | ZERO | Bload]
    if opcode == 0x22:
        return [ALUresult | A | Bload]
    if opcode == 0x23:
        return [ALUresult | mA | Bload]
    if opcode == 0x24:
        return [ALUresult | mB | Bload]
    if opcode == 0x25:
        return [ALUresult | Ainc | Bload]
    if opcode == 0x26:
        return [ALUresult | Binc | Bload]
    if opcode == 0x27:
        return [ALUresult | Adec | Bload]
    if opcode == 0x28:
        return [ALUresult | Bdec | Bload]
    if opcode == 0x29:
        return [ALUresult | ApB | Bload]
    if opcode == 0x2a:
        return [ALUresult | ApBp1 | Bload]
    if opcode == 0x2b:
        return [ALUresult | AmB | Bload]
    # No 0x2c
    #
    if opcode == 0x2d:
        return [ALUresult | BmA | Bload]
    if opcode == 0x2e:
        return [ALUresult | AmBm1 | Bload]
    if opcode == 0x2f:
        return [ALUresult | BmAm1 | Bload]
    if opcode == 0x30:
        return [ALUresult | AxBHI | Bload]
    if opcode == 0x31:
        return [ALUresult | AxBLO | Bload]
    if opcode == 0x32:
        return [ALUresult | AdivB | Bload]
    if opcode == 0x33:
        return [ALUresult | AmodB | Bload]
    if opcode == 0x34:
        return [ALUresult | AsllB | Bload]
    if opcode == 0x35:
        return [ALUresult | AsrlB | Bload]
    if opcode == 0x36:
        return [ALUresult | AsraB | Bload]
    if opcode == 0x37:
        return [ALUresult | AROLB | Bload]
    if opcode == 0x38:
        return [ALUresult | ARORB | Bload]
    if opcode == 0x39:
        return [ALUresult | AandB | Bload]
    if opcode == 0x3a:
        return [ALUresult | AorB | Bload]
    if opcode == 0x3b:
        return [ALUresult | AxorB | Bload]
    if opcode == 0x3c:
        return [ALUresult | notA | Bload]
    if opcode == 0x3d:
        return [ALUresult | notB | Bload]
    if opcode == 0x3e:
        return [ALUresult | Adiv10B | Bload]
    if opcode == 0x3f:
        return [ALUresult | Arem10B | Bload]

    # ALU Operations stored into memory
    if opcode == 0x40:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | ZERO | ARena | MEMload]
    if opcode == 0x41:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | A | ARena | MEMload]
    if opcode == 0x42:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | B | ARena | MEMload]
    if opcode == 0x43:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | mA | ARena | MEMload]
    if opcode == 0x44:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | mB | ARena | MEMload]
    if opcode == 0x45:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | Ainc | ARena | MEMload]
    if opcode == 0x46:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | Binc | ARena | MEMload]
    if opcode == 0x47:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | Adec | ARena | MEMload]
    if opcode == 0x48:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | Bdec | ARena | MEMload]
    if opcode == 0x49:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | ApB | ARena | MEMload]
    if opcode == 0x4a:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | ApBp1 | ARena | MEMload]
    if opcode == 0x4b:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | AmB | ARena | MEMload]
    # No 0x4c
    if opcode == 0x4d:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | BmA | ARena | MEMload]
    if opcode == 0x4e:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | AmBm1 | ARena | MEMload]
    if opcode == 0x4f:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | BmAm1 | ARena | MEMload]
    if opcode == 0x50:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | AxBHI | ARena | MEMload]
    if opcode == 0x51:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | AxBLO | ARena | MEMload]
    if opcode == 0x52:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | AdivB | ARena | MEMload]
    if opcode == 0x53:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | AmodB | ARena | MEMload]
    if opcode == 0x54:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | AsllB | ARena | MEMload]
    if opcode == 0x55:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | AsrlB | ARena | MEMload]
    if opcode == 0x56:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | AsraB | ARena | MEMload]
    if opcode == 0x57:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | AROLB | ARena | MEMload]
    if opcode == 0x58:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | ARORB | ARena | MEMload]
    if opcode == 0x59:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | AandB | ARena | MEMload]
    if opcode == 0x5a:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | AorB | ARena | MEMload]
    if opcode == 0x5b:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | AxorB | ARena | MEMload]
    if opcode == 0x5c:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | notA | ARena | MEMload]
    if opcode == 0x5d:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | notB | ARena | MEMload]
    if opcode == 0x5e:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | Adiv10B | ARena | MEMload]
    if opcode == 0x5f:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | Arem10B | ARena | MEMload]

    # Load constant
    if opcode == 0x60:
        return [MEMresult | Aload | PCincr]
    if opcode == 0x61:
        return [MEMresult | Bload | PCincr]
    # Load from $HHLL
    if opcode == 0x62:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ARena | MEMresult | Aload]
    if opcode == 0x63:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ARena | MEMresult | Bload]
    # Out
    if opcode == 0x64:
        return [ALUresult | A, ALUresult | A | IOload]
    if opcode == 0x65:
        return [ALUresult | B, ALUresult | B | IOload]
    if opcode == 0x68:
        return [MEMresult | IOload | PCincr]
    # In
    if opcode == 0x66:
        return [UARTresult, UARTresult, UARTresult | Aload]
    if opcode == 0x67:
        return [UARTresult, UARTresult, UARTresult | Bload]

    # Load into Video memory
    if opcode == 0x69:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ARena | VIDresult | Aload]
    if opcode == 0x6a:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ARena | VIDresult | Bload]

# Jump instructions
    if opcode == 0x70:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | ZERO | ARena | JumpZero]
    if opcode == 0x71:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | AmB | ARena | JumpZero]
    if opcode == 0x72:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | AmBsp | ARena | JumpZero]
    if opcode == 0x73:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | BmA | ARena | JumpNeg]
    if opcode == 0x74:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | AmB | ARena | JumpNeg]
    if opcode == 0x75:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | BmAm1 | ARena | JumpNeg]
    if opcode == 0x76:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | AmBm1 | ARena | JumpNeg]
    if opcode == 0x77:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ARena | JumpNoTx]
    if opcode == 0x78:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ARena | JumpNoRx]

    # Jump if zero or negative
    if opcode == 0x79:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | A | ARena | JumpZero]
    if opcode == 0x7a:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | B | ARena | JumpZero]
    if opcode == 0x7b:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | A | ARena | JumpNeg]
    if opcode == 0x7c:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | B | ARena | JumpNeg]

    # Test and jump
    if opcode == 0x80:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | ApB | ARena | JumpCarry]
    if opcode == 0x81:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | AmB | ARena | JumpCarry]
    if opcode == 0x82:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | BmA | ARena | JumpCarry]
    if opcode == 0x83:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | Ainc | ARena | JumpCarry]
    if opcode == 0x84:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | Binc | ARena | JumpCarry]

    # Indexed instructions
    if opcode == 0x90:
        return [MEMresult | AHload | PCincr,
                ALUresult | B | ALload | ARena,
                ARena | MEMresult | Aload]
    if opcode == 0x91:
        return [MEMresult | AHload | PCincr,
                ALUresult | B | ALload | ARena,
                ARena | MEMresult | Bload]
    if opcode == 0x92:
        return [MEMresult | AHload | PCincr,
                ALUresult | B | ALload | ARena,
                ALUresult | A | ARena | MEMload]
    if opcode == 0x93:
        return [MEMresult | AHload | PCincr,
                ALUresult | B | ALload | ARena,
                ALUresult | B | ARena | MEMload]
    if opcode == 0x94:
        return [MEMresult | AHload | PCincr,
                ALUresult | B | ALload | ARena,
                ALUresult | ZERO | ARena | MEMload]
    if opcode == 0x95:
        return [MEMresult | AHload | PCincr,
                ALUresult | B | ALload | ARena,
                ARena | VIDresult | Aload]
    if opcode == 0x96:
        return [MEMresult | AHload | PCincr,
                ALUresult | B | ALload | ARena,
                ARena | VIDresult | Bload]

    # Load Indirect
    if opcode == 0x98:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                MEMresult | ARena | AHload,
                ALUresult | B | ALload | ARena,
                MEMresult | ARena | Aload]
    if opcode == 0x99:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                MEMresult | ARena | AHload,
                ALUresult | B | ALload | ARena,
                MEMresult | ARena | Bload]

    # Store Indirect
    if opcode == 0x9a:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                MEMresult | ARena | AHload,
                ALUresult | B | ARena | ALload,
                ALUresult | A | ARena | MEMload]
    if opcode == 0x9b:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                MEMresult | ARena | AHload,
                ALUresult | B | ARena | ALload,
                ALUresult | B | ARena | MEMload]
    if opcode == 0x9c:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                MEMresult | ARena | AHload,
                ALUresult | B | ARena | ALload,
                ALUresult | ZERO | ARena | MEMload]

    # Load Indirect Vid
    if opcode == 0x9d:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                MEMresult | ARena | AHload,
                ALUresult | B | ALload | ARena,
                VIDresult | ARena | Aload]
    if opcode == 0x9e:
        return [MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                MEMresult | ARena | AHload,
                ALUresult | B | ALload | ARena,
                VIDresult | ARena | Bload]

# EXTENDED INSTRUCTIONS
    # A0 - LDA A+C
    if opcode == 0xa0:
        if carry:
            return [ALUresult | Ainc | Aload]
        else:
            return [ALUresult | A | Aload]
        # A1 - LDA A+B+C
    if opcode == 0xa1:
        if carry:
            return [ALUresult | ApBp1 | Aload]
        else:
            return [ALUresult | ApB | Aload]

        # A2 - LDA A-B-C
    if opcode == 0xa2:
        if carry:
            return [ALUresult | AmBm1 | Aload]
        else:
            return [ALUresult | AmB | Aload]

        # A3 - LDA B-A-C
    if opcode == 0xa3:
        if carry:
            return [ALUresult | BmAm1 | Aload]
        else:
            return [ALUresult | BmA | Aload]

        # A4 - LDA B+C
    if opcode == 0xa4:
        if carry:
            return [ALUresult | Binc | Aload]
        else:
            return [ALUresult | B | Aload]

        # A5 - LDA B-C
    if opcode == 0xa5:
        if carry:
            return [ALUresult | Bdec | Aload]
        else:
            return [ALUresult | B | Aload]

    # A6 - LDB A+C
    if opcode == 0xa6:
        if carry:
            return [ALUresult | Ainc | Bload]
        else:
            return [ALUresult | A | Bload]

    # A7 - LDB A+B+C
    if opcode == 0xa7:
        if carry:
            return [ALUresult | ApBp1 | Bload]
        else:
            return [ALUresult | ApB | Bload]

    # A8 - LDB A-B-C
    if opcode == 0xa8:
        if carry:
            return [ALUresult | AmBm1 | Bload]
        else:
            return [ALUresult | AmB | Bload]

    # A9 - LDB B-A-C
    if opcode == 0xa9:
        if carry:
            return [ALUresult | BmAm1 | Bload]
        else:
            return [ALUresult | BmA | Bload]

    # AA - LDB B+C
    if opcode == 0xaa:
        if carry:
            return [ALUresult | Binc | Bload]
        else:
            return [ALUresult | B | Bload]

    # A5 - LDB B-C
    if opcode == 0xab:
        if carry:
            return [ALUresult | Bdec | Aload]
        else:
            return [ALUresult | B | Aload]

    # EXTENDED - Conditional Jumps
    if opcode == 0xb0:
        if carry:
            return [MEMresult | AHload | PCincr,
                    MEMresult | ALload | PCincr,
                    ALUresult | ZERO | ARena | JumpZero]
        else:
            return [PCincr, PCincr]
    if opcode == 0xb1:
        if carry == 0:
            return [MEMresult | AHload | PCincr,
                    MEMresult | ALload | PCincr,
                    ALUresult | ZERO | ARena | JumpZero]
        else:
            return [PCincr, PCincr]

    if opcode == 0xb2:
        if zero:
            return [MEMresult | AHload | PCincr,
                    MEMresult | ALload | PCincr,
                    ALUresult | ZERO | ARena | JumpZero]
        else:
            return [PCincr, PCincr]
    if opcode == 0xb3:
        if zero == 0:
            return [MEMresult | AHload | PCincr,
                    MEMresult | ALload | PCincr,
                    ALUresult | ZERO | ARena | JumpZero]
        else:
            return [PCincr, PCincr]

    if opcode == 0xb4:
        if neg:
            return [MEMresult | AHload | PCincr,
                    MEMresult | ALload | PCincr,
                    ALUresult | ZERO | ARena | JumpZero]
        else:
            return [PCincr, PCincr]
    if opcode == 0xb5:
        if neg == 0:
            return [MEMresult | AHload | PCincr,
                    MEMresult | ALload | PCincr,
                    ALUresult | ZERO | ARena | JumpZero]
        else:
            return [PCincr, PCincr]

    if opcode == 0xb6:
        if over:
            return [MEMresult | AHload | PCincr,
                    MEMresult | ALload | PCincr,
                    ALUresult | ZERO | ARena | JumpZero]
        else:
            return [PCincr, PCincr]
    if opcode == 0xb7:
        if over == 0:
            return [MEMresult | AHload | PCincr,
                    MEMresult | ALload | PCincr,
                    ALUresult | ZERO | ARena | JumpZero]
        else:
            return [PCincr, PCincr]

    # Stack based instructions
    # Stack pointer is fixed at address $FFFF
    # Stack grow upwards from $FF00 to $FFFE - This is to preserve the big-endian address order on the stack
    # i.e. the high byte first and the low byte after in the address space.
    if opcode == 0xe0:
        return [ALUresult | ZERO | Bload,
                ALUresult | notB | AHload,
                ALUresult | notB | ALload,
                ARena | MEMresult | Bload,
                ALUresult | Binc | Bload,
                ALUresult | Binc | ARena | MEMload]
    if opcode == 0xe1:
        return [ALUresult | ZERO | Bload,
                ALUresult | notB | AHload,
                ALUresult | notB | ALload,
                ARena | MEMresult | Bload,
                ALUresult | Bdec | Bload,
                ALUresult | Bdec | ARena | MEMload]
    if opcode == 0xe2:
        return [ALUresult | ZERO | Bload,
                ALUresult | notB | AHload,
                ALUresult | notB | ALload,
                ARena | MEMresult | Bload,
                ALUresult | B | ALload,
                MEMresult | Aload | PCincr,
                ALUresult | A | ARena | MEMload,
                ALUresult | Binc | ALload,
                MEMresult | Aload | PCincr,
                ALUresult | A | ARena | MEMload]
    if opcode == 0xe3:
        return [ALUresult | ZERO | Bload,
                ALUresult | notB | AHload,
                ALUresult | notB | ALload,  # AR = $FFFF
                ARena | MEMresult | Bload,  # B = ($FFFF)
                ALUresult | B | ALload,     # AR = $FF:B
                ARena | MEMresult | Aload,  # A = (AR)
                ALUresult | Binc | ALload,  # AR = $FF:(B+1)
                ARena | MEMresult | Bload,  # B = (AR)
                ALUresult | A | AHload,
                ALUresult | B | ALload,  # AR = A:B
                ALUresult | ZERO | ARena | JumpZero]

    if opcode == 0xe4:
        return [ALUresult | 0 | Bload,
                ALUresult | Bdec | AHload,
                ALUresult | Bdec | ALload,  # AR = $FFFF
                ARena | MEMresult | Bload,  # B = ($FFFF)
                ALUresult | B | ALload ,  # AR = $FF:B
                ALUresult | A | ARena | MEMload] # (AR) = A

# Pulls A from stack - Destroys B
    if opcode == 0xe5:
        return [ALUresult | 0 | Bload,
                ALUresult | Bdec | AHload,
                ALUresult | Bdec | ALload,  # AR = $FFFF
                ARena | MEMresult | Bload,  # B = ($FFFF)
                ALUresult | B | ALload,  # AR = $FF:B
                ARena | MEMresult | Aload]   # A = (AR)

# Increment stack pointer by 1 - Destroys B
    if opcode == 0xe6:
        return [ALUresult | 0 | Bload,
                ALUresult | Bdec | AHload,
                ALUresult | Bdec | ALload,
                ARena | MEMresult | Bload,
                ALUresult | Binc | ARena | MEMload]


# Decrement stack pointer by 1 - Destroys B
    if opcode == 0xe7:
        return [ALUresult | 0 | Bload,
                ALUresult | Bdec | AHload,
                ALUresult | Bdec | ALload,
                ARena | MEMresult | Bload,
                ALUresult | Bdec | ARena | MEMload]

# Get SP+x into A (9 steps) - Destroys B
    if opcode == 0xe8:
        return [ALUresult | 0 | Bload,
                ALUresult | Bdec | AHload,
                ALUresult | Bdec | ALload,
                ARena | MEMresult | Bload,
                MEMresult | Aload | PCincr,
                ALUresult | AmB | ALload,
                ARena | MEMresult | Aload]

# Put A into SP+x (13 steps) - Destroys B
    if opcode == 0xe9:
        return [ALUresult | 0 | Bload,
                ALUresult | Bdec | AHload,
                ALUresult | Bdec | ALload,
                ARena | MEMresult | Bload,
                ALUresult | B | ALload,
                ALUresult | A | ARena | MEMload,
                MEMresult | Aload | PCincr,
                ALUresult | AmB | Bload,
                ARena | MEMresult | Aload,
                ALUresult | B | ALload,
                ALUresult | A | ARena | MEMload]
# F0-FF: Nasty evil instructions

# JSR (7 bytes long!): Store at $XXXX the return address $CCCC.
# Then jump to subroutine at $SSSS. $XXXX then $CCCC then $SSSS.
# We will destroy A and B in the process.
#	Load AH and B with the $XXXX value.
#	Load A with the first $CC byte.
#	Store A to MEM[ AH,B ].
#	B++
#	Load A with the next $CC byte.
#	Store A to MEM[ AH,B ].
#	Load AH/AR with $SSSS and set PC to it.
    if opcode == 0xf0:
        return [MEMresult | AHload | PCincr,
                MEMresult | Bload | PCincr,
                MEMresult | Aload | PCincr,
                ALUresult | B | ALload,
                ALUresult | A | ARena | MEMload,
                ALUresult | Binc | Bload,
                MEMresult | Aload | PCincr,
                ALUresult | B | ALload,
                ALUresult | A | ARena | MEMload,
                MEMresult | AHload | PCincr,
                MEMresult | ALload | PCincr,
                ALUresult | ZERO | ARena,
                ALUresult | ZERO | ARena | JumpZero]

# RTS: Jump through the address stored at the given address $XXXX
# We will destroy A and B in the process.
# 	Load AH and B with the $XXXX value.
# 	Load A with MEM[ AH,B ].
#	B++
#	Load AL with MEM[ AH,B ].
#	Load AH with A
#	Load PC with AR
#
    if opcode == 0xf1:
        return [MEMresult | AHload | PCincr,
                MEMresult | Bload | PCincr,
                ALUresult | B | ALload,
                ARena | MEMresult | Aload,
                ALUresult | Binc | Bload,
                ALUresult | B | ALload,
                ARena | MEMresult | ALload,
                ALUresult | A | AHload | ARena,
                ALUresult | 0 | ARena,
                ALUresult | 0 | ARena | JumpZero]

# LIA: Load into A through an indirect address. Will destroy B also.
    if opcode == 0xf2:
        return [MEMresult | AHload | PCincr,		# Load top of indirect addr into AH
                MEMresult | Bload,			# Load bot of indirect addr into B & AL
                MEMresult | ALload | PCincr,
                ARena | MEMresult | Aload,		# Load A with top byte thru pointer
                ALUresult | ALload | Binc | ARena,	# Move pointer up
                ARena | MEMresult | ALload,		# Load AL with bot byte thru pointer
                ALUresult | AHload | A | ARena,	# Copy A into AH.
                ARena | MEMresult | Aload]		# Finally load A with byte

# LIB: Load into B through an indirect address. Will destroy A also.
    if opcode == 0xf3:
        return [MEMresult | AHload | PCincr,		# Load top of indirect addr into AH
                MEMresult | Bload,			# Load bot of indirect addr into B & AL
                MEMresult | ALload | PCincr,
                ARena | MEMresult | Aload,		# Load A with top byte thru pointer
                ALUresult | ALload | Binc | ARena, 	# Move pointer up
                ARena | MEMresult | ALload,		# Load AL with bot byte thru pointer
                ALUresult | AHload | A | ARena,	# Copy A into AH.
                ARena | MEMresult | Bload]		# Finally load B with byte

# SIA: Store A through an indirect address. Will destroy B also.
    if opcode == 0xf4:
        return [MEMresult | AHload | PCincr,		# Load top of indirect addr into AH
                MEMresult | ALload | PCincr,	# Load bot of indirect addr into AL
                ARena | MEMresult | Bload,		# Get high real addr byte into B
                MEMresult | ALload | PCincr,		# Move up to addr of low real addr
                ARena | MEMresult | ALload,		# and load it into AL
                ALUresult | AHload | B |ARena,	# Copy the high real addr byte into AH
                ALUresult | A | ARena | MEMload]	# Now store A into the real location

# SIB: Store B through an indirect address. Will destroy A also.
    if opcode == 0xf5:
        return [MEMresult | AHload | PCincr,		# Load top of indirect addr into AH
                MEMresult | ALload | PCincr, 	# Load bot of indirect addr into AL
                ARena | MEMresult | Aload,		# Get high real addr byte into A
                MEMresult | ALload | PCincr,		# Move up to addr of low real addr
                ARena | MEMresult | ALload,		# and load it into AL
                ALUresult | AHload | A | ARena,	# Copy the high real addr byte into AH
                ALUresult | B | ARena | MEMload]	# Now store B into the real location

# PPR: Put pointer: overwrite a pointer at location $XXXX with new value $CCCC.
# $XXXX then $CCCC.
# We will destroy A and B in the process.
#	Load AH and B with the $XXXX value.
#	Load A with the first $CC byte.
#	Store A to MEM[ AH,B ].
#	B++
#	Load A with the next $CC byte.
#	Store A to MEM[ AH,B ].
    if opcode == 0xf6:
        return [MEMresult | AHload | PCincr,
                MEMresult | Bload | PCincr,
                MEMresult | Aload | PCincr,
                ALUresult | B | ALload,
                ALUresult | A | ARena | MEMload,
                ALUresult | Binc | Bload,
                MEMresult | Aload | PCincr,
                ALUresult | B | ALload,
                ALUresult | A | ARena | MEMload]

    # default - return NOP
    return []


for over in range(2):
    for neg in range(2):
        for zero in range(2):
            for carry in range(2):
                for opcode in range(256):
                    flags = carry | (zero << 1) | (neg << 2) | (over << 3)
                    control_list = do_instruction(opcode, carry, zero, neg, over)
                    print(hex(opcode))
                    stop = False
                    for step in range(16):
                        addr = (opcode << 4) | step | (flags << 12)
                        if step == 0:
                            cntrl = START
                        else:
                            try:
                                cntrl = control_list[step-1]
                            except IndexError:
                                cntrl = uSreset
                                stop = True
                        # Flip active low control signals
                        cntrl ^= ARena ^ uSreset
                        print(hex(cntrl))
                        control[addr] = cntrl
                        if stop: break
                    print()
rom = bytearray()
for w in control:
    rom.append(w & 0xff)
    rom.append((w >> 8) & 0xff)
rom_file = open("../27Cucode2.rom", "wb")
rom_file.write(rom)
rom_file.close()
