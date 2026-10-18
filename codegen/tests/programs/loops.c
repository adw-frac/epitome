// Array loops, for loop strength reduction and post-increment addressing.
// Nothing here overflows, so it is built without -fwrapv: the optimiser
// may then assume counters do not wrap.
// no-fwrapv

long sum_ints(const int *a, int n) {
  long s = 0;
  for (int i = 0; i < n; i++) s += a[i];
  return s;
}

long sum_longs(const long *a, long n) {
  long s = 0;
  for (long i = 0; i < n; i++) s += a[i];
  return s;
}

void copy_ints(int *dst, const int *src, int n) {
  for (int i = 0; i < n; i++) dst[i] = src[i];
}

long dot(const int *a, const int *b, int n) {
  long s = 0;
  for (int i = 0; i < n; i++) s += (long)a[i] * b[i];
  return s;
}

void axpy(int *y, const int *x, int k, int n) {
  for (int i = 0; i < n; i++) y[i] += k * x[i];
}

int count_char(const char *s, int n, char c) {
  int k = 0;
  for (int i = 0; i < n; i++) k += s[i] == c;
  return k;
}

void fill_shorts(short *a, int n, short v) {
  for (int i = 0; i < n; i++) a[i] = v;
}

unsigned sum_bytes(const unsigned char *a, int n) {
  unsigned s = 0;
  for (int i = 0; i < n; i++) s += a[i];
  return s;
}

long sum_from(const long *a, int from, int to) {
  long s = 0;
  for (int i = from; i < to; i++) s += a[i];
  return s;
}
