// Built by clang for this machine: calls the entry points in caller.c,
// whose own arguments fit in registers in every convention.
#include <stdio.h>

long run_many(int);
long run_sum10(long);
long run_small(int);
long run_relay(int);
long run_wide(long);
long run_big(long);
long run_vmix(long);

int main(void) {
  for (int x = -20; x < 60; x += 7)
    printf("%d: %ld %ld %ld %ld %ld %ld %ld\n", x, run_many(x), run_sum10(x), run_small(x), run_relay(x), run_wide(x), run_big(x),
           run_vmix(x));
  return 0;
}
