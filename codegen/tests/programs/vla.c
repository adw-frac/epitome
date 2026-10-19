// Variable-length arrays: dynamic allocas, in loops (stacksave and
// stackrestore), with calls that pass arguments on the stack after them.

void fill(char *p, int n);
long many(long a, long b, long c, long d, long e, long f, long g, long h, long i, long j);

long squares(int n) {
    long a[n];
    for (int i = 0; i < n; i++) a[i] = (long)i * i;
    long s = 0;
    for (int i = 0; i < n; i++) s += a[i];
    return s;
}

long in_loop(int n) {
    long keep = 7, total = 0;
    for (int k = 1; k <= n; k++) {
        char buf[k * 3];
        fill(buf, k * 3);
        total += buf[k * 3 - 1] + many(1, 2, 3, 4, 5, 6, 7, 8, k, keep);
    }
    return total + keep;
}

double matrix(int n) {
    double m[n][n];
    for (int i = 0; i < n; i++)
        for (int j = 0; j < n; j++) m[i][j] = i * 0.5 + j;
    double t = 0;
    for (int i = 0; i < n; i++) t += m[i][n - 1 - i];
    return t;
}
