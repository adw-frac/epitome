// Calls the loops in loops.c and prints what they compute.
#include <stdio.h>

long sum_ints(const int *, int);
long sum_longs(const long *, long);
void copy_ints(int *, const int *, int);
long dot(const int *, const int *, int);
void axpy(int *, const int *, int, int);
int count_char(const char *, int, char);
void fill_shorts(short *, int, short);
unsigned sum_bytes(const unsigned char *, int);
long sum_from(const long *, int, int);

int main(void) {
  int a[100], b[100], c[100];
  long l[100];
  short s[50];
  unsigned char u[64];
  char text[] = "the quick brown fox jumps over the lazy dog";
  for (int i = 0; i < 100; i++) {
    a[i] = i * 7 - 300;
    b[i] = 1000 - i * i;
    l[i] = (long)i * 1000003 - 50000000;
  }
  for (int i = 0; i < 64; i++) u[i] = (unsigned char)(i * 37);
  for (int n = 0; n <= 100; n += 9) {
    printf("%d: %ld %ld %ld %ld\n", n, sum_ints(a, n), sum_longs(l, n), dot(a, b, n), sum_from(l, n / 3, n));
  }
  copy_ints(c, a, 100);
  axpy(c, b, -3, 100);
  long check = 0;
  for (int i = 0; i < 100; i++) check = check * 31 + c[i];
  printf("axpy %ld\n", check);
  printf("chars %d %d %d\n", count_char(text, (int)sizeof text - 1, 'o'), count_char(text, 10, ' '), count_char(text, 0, 't'));
  fill_shorts(s, 50, -1234);
  long ss = 0;
  for (int i = 0; i < 50; i++) ss += s[i];
  printf("shorts %ld bytes %u %u\n", ss, sum_bytes(u, 64), sum_bytes(u, 0));
  return 0;
}
