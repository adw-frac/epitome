// Variadic functions: va_start, va_arg, va_copy, and passing a va_list on
// to the C library. Only Apple's convention is supported for these so far.
// darwin-only
#include <stdarg.h>

typedef unsigned long size_t;
int vsnprintf(char *, size_t, const char *, va_list);

long vsum(int n, ...) {
  va_list ap;
  va_start(ap, n);
  long s = 0;
  for (int i = 0; i < n; i++) s += va_arg(ap, long);
  va_end(ap);
  return s;
}

// Mixed types, read twice through a copy.
long vmixed(const char *kinds, ...) {
  va_list ap, again;
  va_start(ap, kinds);
  va_copy(again, ap);
  long s = 0;
  for (const char *k = kinds; *k; k++) {
    if (*k == 'i') s = s * 3 + va_arg(ap, int);
    else if (*k == 'l') s = s * 5 + va_arg(ap, long);
    else s = s * 7 + (long)*va_arg(ap, const char *);
  }
  for (const char *k = kinds; *k; k++) {
    if (*k == 'i') s -= va_arg(again, int);
    else if (*k == 'l') s -= va_arg(again, long);
    else s -= (long)*va_arg(again, const char *);
  }
  va_end(again);
  va_end(ap);
  return s;
}

// More named arguments than registers, then variable ones.
long vlate(int a, int b, int c, int d, int e, int f, int g, int h, int i, ...) {
  va_list ap;
  va_start(ap, i);
  long s = a + b + c + d + e + f + g + h + i;
  s = s * 100 + va_arg(ap, int);
  s = s * 100 + va_arg(ap, long);
  va_end(ap);
  return s;
}

int format(char *buf, size_t n, const char *fmt, ...) {
  va_list ap;
  va_start(ap, fmt);
  int r = vsnprintf(buf, n, fmt, ap);
  va_end(ap);
  return r;
}
