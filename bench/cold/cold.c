// Drives coldgen.py's functions: each called once per round, in order, so
// that with enough of them none is in the instruction cache when called.
// Prints a checksum (to compare builds) and the nanoseconds per call.
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>
typedef int64_t (*fn)(int64_t *);
extern fn funcs[];
extern int64_t nfuncs;
__attribute__((noinline)) int64_t helper2(int64_t a, int64_t b) { return a * 3 + (b >> 2); }
__attribute__((noinline)) int64_t helper4(int64_t a, int64_t b, int64_t c, int64_t d) { return (a ^ b) + (c | d); }
__attribute__((noinline)) void note(int64_t *s, int64_t x) { s[x & 15] += 1; }
static double now(void) { struct timespec t; clock_gettime(CLOCK_MONOTONIC, &t); return t.tv_sec * 1e9 + t.tv_nsec; }
int main(int argc, char **argv) {
  int rounds = argc > 1 ? atoi(argv[1]) : 5;
  int64_t s[16];
  for (int i = 0; i < 16; i++) s[i] = i * 7919 + 13;
  int64_t sum = 0;
  for (int64_t k = 0; k < nfuncs; k++) sum += funcs[k](s); // warm the page tables, check the sums
  double best = 1e30;
  for (int r = 0; r < rounds; r++) {
    double t0 = now();
    for (int64_t k = 0; k < nfuncs; k++) sum += funcs[k](s);
    double t = (now() - t0) / nfuncs;
    if (t < best) best = t;
  }
  printf("checksum %lld ns/call %.2f\n", (long long)sum, best);
  return 0;
}
