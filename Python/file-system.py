#
# File system simulator
# 3/7/2022
import random
import time

fs = [0xff for i in range(32768)]
mem = [random.randint(33, 96) for i in range(65536)]
BLOCK_SIZE = 0x100
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
                sleep(WRITE_WAIT)
                ptrA += 1
                fn_ptr += 1
            fs[ptrA] = 0

            fs[ptrB] = address // 256
            fs[ptrB+1] = address % 256
            fs[ptrB+2] = length // 256
            fs[ptrB+3] = length % 256
            sleep(WRITE_WAIT*5)
            ptrB += 4
            for i in range(address, address+length):
                fs[ptrB] = mem[i]
                sleep(WRITE_WAIT)
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


def sleep(ms):
    time.sleep(ms)


def erase_block(address):
    print('ERASE', hex(address))
    addr = BLOCK_SIZE*(address//BLOCK_SIZE)
    print('ERASING', addr, '-', addr+BLOCK_SIZE-1)
    for i in range(addr, addr+BLOCK_SIZE):
        fs[i] = 0xff
    sleep(ERASE_WAIT)


def print_fs():
    for i in range(0x8000):
        if i > 0 and i % BLOCK_SIZE == 0:
            print('|')
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
    sleep(WRITE_WAIT)


def erase(filename):
    # start, source, very_end, ptrA
    print_fs()
    ssd_start = find_file(filename)
    if fs[ssd_start] == 0xff:
        print(filename, 'not found!')
        return
    ssd_source = find_next_file(ssd_start)
    ssd_very_end = ssd_source
    while True:
        if fs[ssd_very_end] == 0xFF:
            break
        ssd_very_end = find_next_file(ssd_very_end)
    # print('Start', start, 'End', source, 'Very End', very_end)

    ssd_dest = BLOCK_SIZE * (ssd_start // BLOCK_SIZE)  # start of 4k sector
    ssd_save = ssd_dest

    mem_buffer = 0xe000
    # copy to mem data before start
    while True:
        if ssd_save == ssd_start:
            break
        mem[mem_buffer] = fs[ssd_save]
        mem_buffer += 1
        ssd_save += 1

    # copy rest of fs to RAM to fill 4k of ram buffer
    while True:
        mem[mem_buffer] = 0xff
        if ssd_source < 0x8000:
            mem[mem_buffer] = fs[ssd_source]
        ssd_source += 1
        mem_buffer += 1
        if mem_buffer == 0xe000 + BLOCK_SIZE:
            break

    # copy rest of file system down
    while True:
        # Erase sector
        erase_block(ssd_dest)

        # copy RAM to fs
        mem_buffer = 0xe000
        while True:
            set_fs(ssd_dest, mem[mem_buffer])
            ssd_dest += 1
            mem_buffer += 1
            if mem_buffer == 0xe000 + BLOCK_SIZE:
                break

        if ssd_source > ssd_very_end:
            break

        # copy next 4k to RAM
        mem_buffer = 0xe000
        while True:
            mem[mem_buffer] = fs[ssd_source]
            ssd_source += 1
            mem_buffer += 1
            if mem_buffer == 0xe000 + BLOCK_SIZE:
                break
            if ssd_source > 0x7fff:
                break

    while True:
        if ssd_dest > ssd_very_end:
            break
        erase_block(ssd_dest)
        ssd_dest += BLOCK_SIZE

    print_fs()
    print(filename, 'deleted')


directory()
save("1", 0x8000, BLOCK_SIZE-23)
directory()
save("2", 0x8000, (BLOCK_SIZE-23)*4)
directory()
save("3", 0x8000, BLOCK_SIZE-23)
directory()
save("4", 0x8000, BLOCK_SIZE-23)
directory()
erase('2')
directory()
