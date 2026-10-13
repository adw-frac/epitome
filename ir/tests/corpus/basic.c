#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <stdlib.h>
struct point { int x; double y; char name[8]; };
static int counter = 3;
const char *msg = "hello \"world\"\n";
int table[4] = {1, 2, 3, 4};
float ftab[3] = {0.1f, 1.5f, -2.0f};
double dvals[2] = {3.14159, 1e300};
long double ld = 1.25L;
__thread int tls_var;
extern int ext_var;
int sum(int n, ...) { va_list ap; va_start(ap, n); int s = 0; for (int i = 0; i < n; i++) s += va_arg(ap, int); va_end(ap); return s; }
int classify(int x) { switch (x) { case 0: return 10; case 1: return 20; case 5: return 7; default: return -1; } }
double dot(struct point *a, struct point *b) { return a->x * b->x + a->y * b->y; }
unsigned long long mix(unsigned long long a, unsigned b, short c, unsigned char d) { return (a >> 3) ^ (b << 2) ^ (unsigned long long)c * d % 7 + a / (b|1); }
int (*fp)(int) = classify;
float fmaths(float a, float b) { return a / b - (a * 2.5f) + (float)(int)b; }
void copy(struct point *dst, const struct point *src) { *dst = *src; memset(dst->name, 0, 8); }
int loop(int *a, int n) { int m = 0; for (int i = 0; i < n; ++i) if (a[i] > m) m = a[i]; else if (a[i] < -m) m = -a[i]; return m ? m : ext_var + tls_var; }
int main(int argc, char **argv) { struct point p = {1, 2.0, "pt"}; printf("%d %f %s\n", sum(3, 1, 2, 3), dot(&p, &p), msg); return classify(argc) + counter + fp(1); }
