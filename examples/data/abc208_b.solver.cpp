#include <algorithm>
#include <cstdint>
#include <iostream>
#include <vector>
#define REP(i, n) for (int i = 0; (i) < (int)(n); ++(i))
#define REP3(i, m, n) for (int i = (m); (i) < (int)(n); ++(i))
#define REP_R(i, n) for (int i = (int)(n)-1; (i) >= 0; --(i))
#define REP3R(i, m, n) for (int i = (int)(n)-1; (i) >= (int)(m); --(i))
#define ALL(x) ::std::begin(x), ::std::end(x)
using namespace std;

int64_t solve(int64_t P) {
  vector<int64_t> cs;
  int64_t e = 1;
  int64_t ans = 0;
  for (int i = 1; i <= 10; ++i) {
    e *= i;
    cs.push_back(e);
  }
  reverse(cs.begin(), cs.end());
  for (const auto &c : cs) {
    ans += P / c;
    P -= P / c * c;
  }
  return ans;
}

// generated by oj-template v4.8.1
// (https://github.com/online-judge-tools/template-generator)
int main() {
  std::ios::sync_with_stdio(false);
  std::cin.tie(nullptr);
  int64_t P;
  std::cin >> P;
  auto ans = solve(P);
  std::cout << ans << '\n';
  return 0;
}
