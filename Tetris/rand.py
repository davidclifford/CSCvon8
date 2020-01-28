seed = 0

for x in range(256):
    # ld    a, (seed)
    # ld    b, a
    #
    # rrca
    # rrca
    # rrca
    # xor 0x1f
    #
    # add a, b
    # sbc a, 255
    #
    # ld(seed), a
    # ret
    a = (x*33)&0xff
    b = int(((x*33)/256))
    a = (a - b)
    if a<0:
        a = (a + 1)&0xff
    if a != (x*33) % 257:
        print(x, x*33, (x*33) % 257, a)
