// Drives ctors.ll: what ran before main, and in what order.
#include <stdio.h>
int logged(int), count(void), table_entry(int);
int main(void) { int n = count(); printf("%d:", n); for (int i = 0; i < n; i++) printf(" %d", logged(i)); printf(" table %d %d\n", table_entry(0), table_entry(1)); return 0; }
