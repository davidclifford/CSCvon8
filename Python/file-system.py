#
# File system simulator
# 3/7/2022
import random
import time

fs = [0xff for i in range(32768)]
mem = [random.randint(33, 96) for i in range(65536)]
BLOCK_SIZE = 0x1000
WRITE_WAIT = 0
ERASE_WAIT = 0


def directory():
    ptrA = 0
    print()
    while fs[ptrA] != 0xff:
        filename = ''
        ptrB = ptrA
        while fs[ptrB] != 0:
            filename += chr(fs[ptrB])
            ptrB += 1
        print(filename, end=' ')
        ptrA += 20
        addr = fs[ptrA] * 256 + fs[ptrA + 1]
        print(hex(addr), end=' ')
        len = fs[ptrA+2] * 256 + fs[ptrA + 3]
        print(len)
        ptrA += (len + 4)
    print('Used: ', ptrA)


def find_next_file(ptrA):
    ptrA += 22
    length = fs[ptrA]*256 + fs[ptrA+1]
    ptrA += 2
    return ptrA + length


def save(filename, address, length):
    ptrA = 0
    while True:
        if fs[ptrA] == 0xff:
            # current end of file system
            ptrB = ptrA + 20
            fn_ptr = 0
            while fn_ptr < len(filename):
                fs[ptrA] = ord(filename[fn_ptr])
                time.sleep(WRITE_WAIT)
                ptrA += 1
                fn_ptr += 1
            fs[ptrA] = 0

            fs[ptrB] = address // 256
            fs[ptrB+1] = address % 256
            fs[ptrB+2] = length // 256
            fs[ptrB+3] = length % 256
            time.sleep(WRITE_WAIT*5)
            ptrB += 4
            for i in range(address, address+length):
                fs[ptrB] = mem[i]
                time.sleep(WRITE_WAIT)
                ptrB += 1
            return

        ptrA = find_next_file(ptrA)


def find_file(filename):
    ptrA = 0
    while True:
        fn_ptr = 0
        ptrB = ptrA
        while True:
            if fs[ptrA] == 0xff:
                return ptrB
            if ord(filename[fn_ptr]) != fs[ptrA]:
                ptrA = find_next_file(ptrB)
                break
            fn_ptr += 1
            ptrA += 1
            if fn_ptr >= len(filename):
                return ptrB


def load(filename):
    pass


def erase(address):
    print('ERASE', hex(address))
    addr = BLOCK_SIZE*(address//BLOCK_SIZE)
    # print('ERASING', addr, addr+BLOCK_SIZE)
    for i in range(addr, addr+BLOCK_SIZE):
        fs[i] = 0xff
    time.sleep(ERASE_WAIT)


def print_fs():
    for i in range(0x8000):
        if i > 0 and i % BLOCK_SIZE == 0:
            print('| |', end='')
        if fs[i] >= 0x80 or fs[i] < 0x20:
            print('.', end='')
        else:
            print(chr(fs[i]), end='')
    print()


def set_fs(addr, data):
    # print('SET', hex(addr))
    if fs[addr] != 0xff:
        raise RuntimeError
    fs[addr] = data
    time.sleep(WRITE_WAIT)


def delete(filename):
    # start, source, very_end, ptrA
    print_fs()
    start = find_file(filename)
    if fs[start] == 0xff:
        print(filename, 'not found!')
        return
    source = find_next_file(start)
    very_end = source
    while True:
        if fs[very_end] == 0xFF:
            break
        very_end = find_next_file(very_end)
    # print('Start', start, 'End', source, 'Very End', very_end)

    dest = BLOCK_SIZE * (start // BLOCK_SIZE)  # start of 4k sector
    ptrB = dest

    ptrA = 0xe000
    # copy to mem data before start
    while True:
        if ptrB == start:
            break
        mem[ptrA] = fs[ptrB]
        ptrA += 1
        ptrB += 1

    # copy rest of fs to RAM to fill 4k of ram buffer
    while True:
        mem[ptrA] = fs[source]
        source += 1
        ptrA += 1
        if ptrA == 0xe000 + BLOCK_SIZE:
            break

    # copy rest of file system down
    while True:
        # Erase sector
        erase(dest)

        # copy RAM to fs
        ptrA = 0xe000
        while True:
            # print('PTRA', hex(ptrA))
            set_fs(dest, mem[ptrA])
            # print_fs()
            dest += 1
            ptrA += 1
            if ptrA == 0xe000 + BLOCK_SIZE:
                break

        if source > very_end:
            break

        # copy next 4k to RAM
        ptrA = 0xe000
        while True:
            mem[ptrA] = fs[source]
            source += 1
            ptrA += 1
            if ptrA == 0xe000 + BLOCK_SIZE:
                break
            if source > 0x7fff:
                break

    while True:
        if dest > very_end:
            break
        erase(dest)
        dest += BLOCK_SIZE

    print_fs()
    print(filename, 'deleted')


directory()
save("fred.txt", 0x8000, 160)
directory()
save("alice.txt", 0x8100, 29000)
directory()
save("jake.txt", 0x8200, 160)
directory()
# save("josh.txt", 0x8300, 200)
# directory()
# save("alex.txt", 0x8400, 15)
# directory()
# save('jen.txt', 0x8500, 16)
# directory()
# save("dave.txt", 0x8600, 17)
# directory()
# delete('fred.txt')
# directory()
# delete('fred.txt')
# directory()
delete('alice.txt')
directory()
# delete('jake.txt')
# directory()
# delete('alex.txt')
# directory()
# delete('jen.txt')
# directory()
# delete('dave.txt')
# directory()
