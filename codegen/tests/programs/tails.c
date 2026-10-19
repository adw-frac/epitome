// Tail calls: these recurse, through functions in tails.main.c, far deeper
// than any stack holds, so every call must be a tail call (a jump, after
// the frame is gone). Built only with optimisation, which marks them.
// needs-tail-calls

long even_steps(long n, long acc);
long down_by(long n, long k, long acc);

long odd_steps(long n, long acc) {
    if (n == 0) return acc;
    return even_steps(n - 1, acc + 3);
}

// Arguments that move between registers on the way.
long twist(long a, long b, long c, long n) {
    if (n <= 0) return a + 2 * b + 3 * c;
    return down_by(c, a, b + n) + 0 * twist(0, 0, 0, 0);
}

// A frame of its own (a call that is not a tail call first), torn down
// before the tail call.
long counted(long n);
long with_frame(long n) {
    long seen = counted(n);
    if (n == 0) return seen;
    return counted(n - 1) + seen;
}
