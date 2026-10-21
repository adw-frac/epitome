// Thread-local variables: defined here and in main's file, initialised
// and zero, of several sizes, an array and a struct, their addresses
// taken and kept, read and written in loops.

struct pair {
    int a;
    long long b;
};

__thread long long counter = 40;
__thread int zeroed;
__thread unsigned char bytes[5] = {1, 2, 3, 4, 5};
__thread struct pair pt = {7, -9};
static __thread short hidden = -3;
extern __thread int shared;

long long bump(long long by) {
    counter += by;
    return counter;
}

int count_up(int n) {
    for (int k = 0; k < n; k++) zeroed += k;
    return zeroed;
}

int sum_bytes(void) {
    int s = 0;
    for (int k = 0; k < 5; k++) s += bytes[k] * (k + 1);
    bytes[2] = 30;
    return s;
}

long long pair_sum(void) {
    pt.a *= 3;
    pt.b -= pt.a;
    return pt.a + pt.b;
}

short *hidden_at(void) { return &hidden; }

int add_shared(int v) {
    shared += v;
    return shared;
}
