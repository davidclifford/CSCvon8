def div10(num):
    div = int(num*6554)
    res = div >> 16
    rem = num - res*10
    rem = rem + 10 if rem < 0 else rem
    print(num, res, rem)
    return res, rem


for num in range(65500, 65536):
    n = num
    res = 1
    while res != 0:
        res, rem = div10(n)
        n = res

    print()
