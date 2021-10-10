import os
import sys
import argparse
import re

debug = False
listing = False
ramimage = True
linenum = 0
start_pc = 0x8000
show_listing = False
next_return_addr = 0xFE00
line = []
line_num = []
MEM = [i for i in range(65536)]
label = {}
export = {}
numlabel = []
run = False
inst = {}
keyword = {}
return_addr = {}

low_mem_used = 0x10000
hi_mem_used = -1


def get_command_arguments():
    global show_listing, debug, next_return_addr, start_pc
    parser = argparse.ArgumentParser(description='Assemble CSCvon8 source code.')
    parser.add_argument('filename', metavar='filename', type=str, help='Filename of source code to assemble')
    parser.add_argument('-d', action='store_true', help='show debug info')
    parser.add_argument('-l', action='store_true', help='list source code')
    parser.add_argument('-m', action='store_true', help='assemble from $0000 instead of $8000 (for ROM)')
    args = parser.parse_args()
    show_listing = args.l
    if args.m:
        start_pc = 0x0000
        next_return_addr = 0xFEFE
    return args


def load_source_code(args):
    command = """cpp -nostdinc {} | grep -v -E '^# [0-9]+ "(.+)"'"""
    output = os.popen(command.format(args.filename))
    _lines = output.read().split('\n')
    output.close()

    processed_lines = []
    line_numbers = []
    count = 1
    for line in _lines:
        line = re.sub(r'^\s+', '', line)
        line = re.sub(r'\s+$', '', line)
        line = re.sub(r'#.*', '', line)
        if len(line) == 0:
            continue
        if show_listing:
            print("[{}] {}".format(count, line))
        line_numbers.append(count)
        processed_lines.append(line)
        count += 1
    return processed_lines, line_numbers


args = get_command_arguments()
lines, line_numbers = load_source_code(args)

