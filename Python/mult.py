# a*b = f(a+b) - f(a-b)
# f = x*x/4

# make lookup table
X2D4 = [0 for i in range(2**16)]

for x in range(2**16):
    y = x
    if x >= 2**15:
        y = (2**16) - x + 1
    X2D4[x] = int((y*y) >> 2)

print(X2D4[0])
print(X2D4[1])
print(X2D4[2])
print(X2D4[3])
print(X2D4[4])
print(hex(X2D4[2**15]))
print(hex(X2D4[2**15+1]))
print(X2D4[2**16-4])
print(X2D4[2**16-3])
print(X2D4[2**16-2])
print(X2D4[2**16-1])


def mult(a, b):
    r1 = f(a+b)
    r2 = f(a-b)
    return r1 - r2


def f(x):
    return int((x*x) >> 2)


for i in range(2**16):
    if i%256 == 0: print('.', end='')
    for j in range(2**16):
        q = int(i*j) - mult(i, j)
        if q == 0:
#            print(i, j, int(i*j), mult(i, j))
            pass
        else:
            print('ERROR', i, j, int(i*j), mult(i, j))
            exit()

# a = 5
# b = 20
#
# if b > a:
#     t = b
#     b = a
#     a = t
#
# print(a, b, int(a*b), mult(a, b))
#
# for i in range(2**17):
#     x = int(i*i) >> 2
#     print(i, bin(i), x, bin(x))
#
# print(((2**16)-1) + ((2**16)-1))
