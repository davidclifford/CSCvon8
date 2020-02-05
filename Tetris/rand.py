# seed = (((seed+1)*75)%65537)-1

seed = 0

for x in range(6):
    s = ((seed+1)*33)
    a = s % 257
    b = s % 256
    c = int(s/256)
    d = b-c
    if d<0:
        d = (d+1)&255
    e = d&255
    print(x, seed, s, a, b, c, d, e)
    seed = a
