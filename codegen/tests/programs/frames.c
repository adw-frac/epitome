// Frames bigger than an instruction's offsets reach: arrays of 40KB and
// 100KB, with values kept across calls, so that saves, locals and the
// stack pointer's adjustment are all far apart.

void touch(char *p, int n);
long mix(long a, long b);

long big_frame(int n) {
    char buf[100000];
    touch(buf, (int)sizeof buf);
    long a = n * 3, b = n * 5, c = n * 7, d = n * 11;
    long s = mix(a, b) + mix(c, d);
    return s + buf[0] + buf[n] + buf[sizeof buf - 1] + a + b + c + d;
}

long medium_frame(int n) {
    long buf[5000];
    for (int i = 0; i < 5000; i++) buf[i] = (long)i * n;
    long k = mix(n, buf[4999]);
    return k + buf[n % 5000] + buf[0];
}
