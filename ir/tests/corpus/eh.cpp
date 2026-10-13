#include <stdexcept>
#include <string>
#include <vector>
struct Base { virtual ~Base() {} virtual int f(int x) { return x; } };
struct Derived : Base { int g; int f(int x) override { return x * g; } };
template <typename T> T maxof(const std::vector<T> &v) { T m = v[0]; for (auto &x : v) if (x > m) m = x; return m; }
int use(int n) { std::vector<int> v; for (int i = 0; i < n; i++) v.push_back(i * 3 % 7); return maxof(v); }
int thrower(int x) { if (x < 0) throw std::runtime_error("neg"); return x; }
int catcher(int x) { try { return thrower(x); } catch (const std::exception &e) { return -1; } catch (...) { return -2; } }
std::string join(const std::string &a, const std::string &b) { return a + "," + b; }
int virt(Base *b) { return b->f(3); }
static Derived global_d;
