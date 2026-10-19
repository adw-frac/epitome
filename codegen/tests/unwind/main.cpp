// Built by clang++: throws from a callback that our code calls, and must
// catch it in main.
#include <cstdio>
#include <stdexcept>
#include <string>
extern "C" long through(long (*f)(long), long n, long depth);
extern "C" long with_vla(long (*f)(long), int n);
extern "C" long work(long x) { return x * 2; }
static long boom(long x) {
    if (x >= 5) throw std::runtime_error("boom " + std::to_string(x));
    return x;
}
int main() {
    try {
        printf("%ld\n", through(boom, 1, 2));
        printf("%ld\n", through(boom, 1, 6));
    } catch (const std::exception &e) {
        printf("caught %s\n", e.what());
    }
    try {
        printf("%ld\n", with_vla(boom, 9));
    } catch (const std::exception &e) {
        printf("caught %s\n", e.what());
    }
    return 0;
}
