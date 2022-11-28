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

opcode = {}


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
    _lines = output.read()
    output.close()
    _lines = re.split(r'\n', _lines)
    lines = []
    for line in _lines:
        # Split lines by ; unless it is in a string
        if re.match(r'(?=(.*)("|\')(.*)("|\')(.*))', line):
            lines.append(line)
        else:
            lines.extend(line.split(';'))

    processed_lines = []
    line_numbers = []
    count = 1
    for line in lines:
        line = re.sub(r'^\s+', '', line)
        line = re.sub(r'\s+$', '', line)
        if re.match(r'(?!(.*)("|\')(.*)("|\')(.*))', line):
            line = re.sub(r'#.*', '', line)
            line = re.sub(r'//.*', '', line)
        if len(line) == 0:
            continue
        if show_listing:
            print(f'[{count}] {line}')
        line_numbers.append(count)
        processed_lines.append(line)
        count += 1
    return processed_lines, line_numbers


def load_opcodes():
    global opcode, op_len, op_name
    # Read all lines in opcode file
    with open('opcodes', 'r') as f:
        lines = f.readlines()
    # Go through all lines
    line_num = 0
    for line in lines:
        line_num += 1
        line = re.sub(r'^\s+', '', line)
        line = re.sub(r'\s+$', '', line)
        line = re.sub(r'#.*', '', line)
        line = re.sub(r'//.*', '', line)
        # Skip if line empty
        if len(line) == 0:
            continue
        op_code, op_len, op_name = line.split(' ')
        opcode[op_name] = {'code': op_code, 'len': op_len}
    # print(opcode)


args = get_command_arguments()
load_opcodes()
lines, line_numbers = load_source_code(args)

for pas in range(1):
    print(pas)
