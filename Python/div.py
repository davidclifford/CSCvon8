from numpy import uint16, uint8

a = 0xffff
b = 0xfd


def div8(numerator, denominator, remainder):
    quotient = uint8(0)
    i = 0
    while i < 8:
        bit = (numerator & (1 << 7)) >> 7
        numerator = (numerator << 1) & 0xff
        rem_bit = (remainder & (1 << 7)) >> 7
        remainder = ((remainder << 1) & 0xff) | bit
        quotient = quotient << 1

        # print('I, NUM, QUO, REM, BIT, REM_BIT', i, hex(numerator), hex(quotient), hex(remainder), bit, rem_bit)
        if remainder >= denominator or rem_bit == 1:
            quotient += 1
            remainder = (remainder - denominator) & 0xff
        i += 1
    # print('I, NUM, QUO, REM, BIT, REM_BIT', i, hex(numerator), hex(quotient), hex(remainder))
    return quotient, remainder


for b in range(0xff, 0, -1):
    num = a >> 8
    den = b
    rem = 0

    quo, rem = div8(num, den, rem)
    # print('{} / {} = {} r {} == {}'.format(hex(num), hex(den), hex(quo), hex(rem), hex(quo*den+rem)))

    num = a & 0xff

    quo2, rem = div8(num, den, rem)
    # print('{} / {} = {} r {} == {}'.format(hex(num), hex(den), hex(quo), hex(rem), hex(quo*den+rem)))
    print(hex((quo << 8) + quo2), hex(rem), hex(int(a/b)), hex(int(a%b)))
