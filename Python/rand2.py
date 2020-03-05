# seed = (((seed+1)*75)%65537)-1

seed = 0

for x in range(256):
    seed_1 = ((((seed+1)*33)%257)-1)&255
    s = (((seed+1)&255)*33)
    a = s&255
    b = (s>>8)&255
    c = (a-b-1)
    c = (c + 1)&255 if c<0 else c&255
    print(x, seed, s, a, b, c, '===', seed_1, ' ')
    seed = seed_1
