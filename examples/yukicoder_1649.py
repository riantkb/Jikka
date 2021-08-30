# https://yukicoder.me/problems/no/1649
from typing import *

MOD = 998244353


def solve(N: int, x: List[int], y: List[int]) -> int:
    ans = 0
    for i in range(N - 1):
        for j in range(i + 1, N):
            ans += (abs(x[i] - x[j]) + abs(y[i] - y[j])) ** 2
    return ans % MOD


# generated by oj-template v4.8.0 (https://github.com/online-judge-tools/template-generator)
def main():
    N = int(input())
    x = list(range(N))
    y = list(range(N))
    for i in range(N):
        x[i], y[i] = map(int, input().split())
    ans = solve(N, x, y)
    print(ans)


if __name__ == '__main__':
    main()