// Built by us: calls back into C++, which throws; the exception must
// unwind through these frames, by our unwind tables.
long work(long x);
long through(long (*f)(long), long n, long depth) {
    long a = n * 3, b = n + 7, c = n ^ 0x55;
    long r = depth > 0 ? through(f, n + 1, depth - 1) : f(n);
    return r + a * b - c + work(a);
}
long with_vla(long (*f)(long), int n) {
    long buf[n];
    for (int i = 0; i < n; i++) buf[i] = i;
    return f(buf[n - 1]) + buf[0];
}
