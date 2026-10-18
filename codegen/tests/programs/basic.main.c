// Calls the functions in basic.c and prints what they return.
#include <stdio.h>

int add3(int, int, int);
long fact(long);
int fib(int);
int gcd(int, int);
unsigned popcount(unsigned);
long sum_array(const int *, int);
void reverse(int *, int);
int max_of(const int *, int);
int classify(int);
int string_length(const char *);
unsigned hash(const char *);
long mix(long, int, short, signed char, unsigned char);
extern int global_counter;
int bump(int);
int lookup(int);
struct point { int x, y; long z; };
long dot(const struct point *, const struct point *);
int many(int, int, int, int, int, int, int, int);
int call_many(int);
long div_mod(long, long);
unsigned udiv_mod(unsigned, unsigned);
int shifts(int, unsigned, int);
int select_max(int, int);
long select_ptr(long *, long *, int);
int bools(int, int);
void fill(char *, int, char);
long big_const(long);
int odd_consts(int);
long ptr_diff(const int *, const int *);
int local_array(int);
int sum_squares(int);
int pressure(int, int);
int across_calls(int);
unsigned short narrow(unsigned short, short);
_Bool is_odd(int);
int count_odd(const int *, int);

int main(void) {
  int vals[] = {0, 1, -1, 7, -13, 100, 255, -256, 65536, 2147483647, -2147483647 - 1};
  int n = sizeof vals / sizeof vals[0];
  for (int i = 0; i < n; i++) {
    int a = vals[i], b = vals[(i * 7 + 3) % n];
    printf("%d %d: %d %d %d %d %u %d %d %d %d %d %d %u\n", a, b, add3(a, b, 3), gcd(a == -2147483647 - 1 ? 5 : a, b == -2147483647 - 1 ? 7 : b),
           classify(a), select_max(a, b), popcount((unsigned)a), lookup(a), bools(a, b), shifts(a, (unsigned)b, i % 31),
           odd_consts(a), pressure(a, b), call_many(a), udiv_mod((unsigned)a, (unsigned)b | 1u));
    printf("  %ld %ld %ld %d %d %u %d\n", mix(a, b, (short)a, (signed char)b, (unsigned char)a), big_const(a),
           div_mod(a, b == 0 ? 3 : b), local_array(a), is_odd(a), (unsigned)narrow((unsigned short)a, (short)b), classify(b));
  }
  printf("fact %ld fib %d squares %d across %d\n", fact(15), fib(20), sum_squares(100), across_calls(9));
  int arr[] = {5, -3, 9, 12, -40, 7, 7, 1};
  printf("sum %ld max %d odd %d\n", sum_array(arr, 8), max_of(arr, 8), count_odd(arr, 8));
  reverse(arr, 8);
  for (int i = 0; i < 8; i++) printf("%d ", arr[i]);
  printf("\nlen %d hash %u\n", string_length("hello, world"), hash("hello, world"));
  char buf[16];
  fill(buf, 15, 'x');
  buf[15] = 0;
  printf("%s\n", buf);
  struct point p = {3, -4, 1000000000000L}, q = {7, 8, -3};
  printf("dot %ld diff %ld\n", dot(&p, &q), ptr_diff(arr, arr + 6));
  long l1 = 11, l2 = 22;
  printf("sel %ld %ld\n", select_ptr(&l1, &l2, 1), select_ptr(&l1, &l2, 0));
  printf("bump %d %d %d\n", bump(5), bump(-2), global_counter);
  return 0;
}
