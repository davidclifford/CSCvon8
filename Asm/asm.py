#  Python Assembler Started 26/06/2021
with open('monitor.s') as f:
    lines = f.readlines()

for l in lines:
    l = l.rstrip().lstrip().lower().replace('\t', '')
    # convert strings to HEX
    m = l.split('"')
    if len(m) > 1:
        l = m[0]
        n = m[1].replace("\\n", "\n").replace("\\r", "\r").replace("\\t", "\t")
        for c in n:
            l = l + hex(ord(c)).replace("0x", "$") + " "
    # remove comments
    l = l.split("#")[0]
    for c in l:
        print(c, end='')
    if len(l) != 0: print()
