num = 0xff01
hi = int(num >> 8)
low = int(num & 0xFF)
print(num, hi, low)

b = hi*25
s = int(hi*6/10)

print(b, s, b+s+int(low/10))
