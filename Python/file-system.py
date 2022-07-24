#
# File system simulator
# 3/7/2022
import random

fs = [0xff for i in range(32768)]
mem = [random.randint(33, 96) for i in range(65536)]
BLOCK_SIZE = 0x40


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
                ptrA += 1
                fn_ptr += 1
            fs[ptrA] = 0

            fs[ptrB] = address // 256
            fs[ptrB+1] = address % 256
            fs[ptrB+2] = length // 256
            fs[ptrB+3] = length % 256
            ptrB += 4
            for i in range(address, address+length):
                fs[ptrB] = mem[i]
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
    addr = BLOCK_SIZE*(address//BLOCK_SIZE)
    # print('ERASING', addr, addr+BLOCK_SIZE)
    for i in range(addr, addr+BLOCK_SIZE):
        fs[i] = 0xff


def print_fs():
    for i in range(0x1000):
        if i > 0 and i % BLOCK_SIZE == 0:
            print('| |', end='')
        if fs[i] >= 0x80 or fs[i] < 0x20:
            print('.', end='')
        else:
            print(chr(fs[i]), end='')
    print()


def delete(filename):
    # start, end, very_end, block
    print_fs()
    start = find_file(filename)
    if fs[start] == 0xff:
        print(filename, 'not found!')
        return
    end = find_next_file(start)
    very_end = end
    while True:
        if fs[very_end] == 0xFF:
            break
        very_end = find_next_file(very_end)
    # print('Start', start, 'End', end, 'Very End', very_end)

    memPtr = BLOCK_SIZE*(start//BLOCK_SIZE)  # start of 4k block (in bytes)
    # print('Block address (start)', memPtr)
    block = 0xe000
    # copy to mem data before start
    for p in range(memPtr, start):
        mem[block] = fs[p]
        block += 1

    # copy block to RAM
    while True:
        if block >= 0xe000 + BLOCK_SIZE:
            break
        mem[block] = fs[end]
        block += 1
        end += 1

    # Erase the 4k block in FS
    erase(start)

    # copy buffer back to FS from start
    block = 0xe000
    start = BLOCK_SIZE*(start//BLOCK_SIZE)
    while block < 0xe000 + BLOCK_SIZE:
        fs[start] = mem[block]
        # print_fs()
        block += 1
        start += 1
    # print('S', hex(s), 'End', hex(end), 'Very End', hex(very_end))
    while True:
        # copy next block to RAM
        block = 0xe000
        while True:
            mem[block] = fs[end]
            block += 1
            if block > 0xe000 + BLOCK_SIZE:
                break
            end += 1
        # Erase block
        erase(start)
        for a in range(BLOCK_SIZE):
            fs[start] = mem[a+0xe000]
            # print_fs()
            start += 1
        if end > very_end:
            break

    while True:
        erase(start)
        start += BLOCK_SIZE
        if start > very_end:
            break
    print_fs()
    print(filename, 'deleted')


directory()
save("fred.txt", 0x8000, 208)
save("alice.txt", 0x8100, 12)
save("jake.txt", 0x8200, 13)
save("josh.txt", 0x8300, 14)
save("alex.txt", 0x8400, 15)
save('jen.txt', 0x8500, 16)
save("dave.txt", 0x8600, 17)
directory()
delete('fred.txt')
directory()
delete('alice.txt')
directory()
delete('jake.txt')
directory()
delete('josh.txt')
directory()
delete('alex.txt')
directory()
delete('jen.txt')
directory()
delete('dave.txt')
directory()
