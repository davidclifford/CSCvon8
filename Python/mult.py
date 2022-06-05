# a*b = f(a+b) - f(a-b)
# f = x*x/4


def mult(a, b):
    r1 = f(a+b)
    r2 = f(a-b)
    return r1 - r2


def f(x):
    return int((x*x) >> 2)


for i in range(256):
    for j in range(256):
        q = int(i*j) - mult(i, j)
        if q == 0:
            print(i, j, int(i*j), mult(i, j))
        else:
            print('ERROR', i, j, int(i*j), mult(i, j))
            exit()

a = 5
b = 20

if b > a:
    t = b
    b = a
    a = t

print(a, b, int(a*b), mult(a, b))

for i in range(2**17):
    x = int(i*i) >> 2
    print(i, bin(i), x, bin(x))

print(((2**16)-1) + ((2**16)-1))
