// For tests/chop.rs: several functions with work for every pass, one of
// which multiplies by 7, where the test plants a wrong rule.
#include <stdio.h>

struct pair { int a, b; };

static int add3(int x) { return x + 3; }
static int twice(int x) { return x * 2 + 1; }
static int fact(int n) { return n <= 1 ? 1 : n * fact(n - 1); }

static int pairs(int n) {
    struct pair p = {n, n + 1};
    int arr[8];
    for (int i = 0; i < 8; i++) arr[i] = p.a * i + p.b;
    int s = 0;
    for (int i = 0; i < 8; i++) s += arr[i] ^ (s >> 1);
    return s;
}

static int seven(int x) {
    int a = x * 5;
    int b = x * 7;
    return a + b;
}

static int mix(int x, int y) { return (x ^ y) - (x & y) + add3(x); }

int main(void) {
    int s = 0;
    for (int i = 0; i < 10; i++) s += twice(i) + pairs(i) + seven(i) + mix(i, s) + fact(i % 6);
    printf("%d\n", s);
    return 0;
}
