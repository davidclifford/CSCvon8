def main():
    BOARD_CAP = 122
    board = [0 for _ in range(BOARD_CAP)]

    board[BOARD_CAP - 2] = 1
    for i in range(BOARD_CAP-2):

        for j in range(BOARD_CAP):
            print(" *"[board[j]], end='');
        print()

        pattern = (board[0] << 1) | board[1]
        for j in range(1, BOARD_CAP-1):
            pattern = ((pattern << 1) & 7) | board[j + 1]
            board[j] = (110 >> pattern) & 1


if __name__ == '__main__':
    main()
