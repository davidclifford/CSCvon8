import time

board = [[0]*9 for i in range(9)]
tries = 0
backtrack = 0
max_depth = 0
xs = []
ys = []
ns = []
sp = 0


def valid(x, y, n):
    global board

    for i in range(9):
        if board[x][i] == n:
            return False
    for i in range(9):
        if board[i][y] == n:
            return False
    x0 = (x//3) * 3
    y0 = (y//3) * 3
    for i in range(3):
        for j in range(3):
            if board[x0+j][y0+i] == n:
                return False
    return True


def disp():
    for yy in range(9):
        for xx in range(9):
            aa = board[xx][yy]
            if aa == 0:
                aa = '.'
            print(aa, end='')
        print()
    print()


def init_board(givens):
    c = 0
    for y in range(9):
        for x in range(9):
            a = int(givens[c])
            board[x][y] = a
            c += 1


def solve(depth):
    global board, backtrack, tries, max_depth
    if depth > max_depth:
        max_depth = depth
    for y in range(9):
        for x in range(9):
            if board[x][y] == 0:
                for n in range(1, 10):
                    tries += 1
                    if valid(x, y, n):
                        board[x][y] = n
                        solve(depth+1)
                        backtrack += 1
                        board[x][y] = 0
                return
    disp()


def solve2(depth):
    global board, backtrack, tries, max_depth
    x = 0
    y = 0
    n = 1
    tries = 0
    backtrack = 0
    max_depth = 0
    while True:
        next_space = False
        if depth > max_depth:
            max_depth = depth
        if board[x][y] == 0:
            tries += 1
            if n > 9:
                depth -= 1
                backtrack += 1
                x = xs.pop()
                y = ys.pop()
                n = ns.pop() + 1
                board[x][y] = 0
            else:
                if valid(x, y, n):
                    board[x][y] = n
                    xs.append(x)
                    ys.append(y)
                    ns.append(n)
                    depth += 1
                    next_space = True
                else:
                    n += 1
        else:
            next_space = True

        if next_space:
            x += 1
            if x > 8:
                x = 0
                y += 1
                if y > 8:
                    disp()
                    return
            n = 1




#givens = '210390405090007002003280010001002004040830027820040103000010738080063200304900050'
#givens = '070250400800000903000003070700004020100000007040500008090600000401000005007082030'
givens = '002090600000040003100008000730000002080000400000000008900000005050034020000620001'
init_board(givens)
t = time.time()
solve2(0)
print(time.time() - t)

print('Tries', tries)
print('Backtrack', backtrack)
print('Max depth', max_depth)
print()

init_board(givens)
t = time.time()
solve(0)
print(time.time() - t)

print('Tries', tries)
print('Backtrack', backtrack)
print('Max depth', max_depth)

