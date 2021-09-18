primes = [i for i in range(0, 256)]
primes[0] = primes[1] = 0

for i in range(2, 14):
    p = primes[i]
    if p > 0:
        for q in range(p*p, len(primes), p):
            primes[q] = 0

prime = [i for i in primes if i > 0]
for p in prime:
    print(p, end=' ')

for i in range(256, 65536, 256):
    # print('From {} to {}'.format(i, i+256))
    print()
    primes = [0] * 256
    a = i
    b = i+256
    for p in prime:
        j = p*p
        if j < a:
            j = int((a+p-1)/p)*p
            print('Calculate J =', j, p)

        while j < b:
            primes[j-a] = 1
            j += p

    for j in range(a, b):
        if primes[j - a] == 0:
            print(j, end=' ')



