// The smoke program epitome-llc --check-target compiles for each calling
// convention of a description: a little of everything the code generator
// asks of a machine. smoke.ll is this, made by gen_smoke.sh. (Not
// variadic functions defined here: the IR's va_list is the machine's.)

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef unsigned long long u64;

int printf(const char *, ...);
void ext(int *);
extern int counter;

int table[16] = {1, 2, 3, 4};
const char *message = "hello";
static long long big_value = 0x123456789abcdefLL;

int narrow(signed char a, short b, u8 c, u16 d) { return a + b + c + d; }
u8 add8(u8 a, u8 b) { return a + b; }
short neg16(short a) { return -a; }
u32 arith32(u32 a, u32 b) { return (a * b + (a >> 3)) ^ (b << 5) | (a & ~b); }
u64 arith64(u64 a, u64 b) { return (a * b + (a >> 3)) ^ (b << 5) | (a & ~b); }
int sdiv(int a, int b) { return a / b + a % b; }
u64 udiv(u64 a, u64 b) { return a / b + a % b; }
int div_const(int a) { return a / 7 + a % 10; }
long long constants(void) { return 0x123456789abcdefLL + big_value; }
int min(int a, int b) { return a < b ? a : b; }
u32 umax(u32 a, u32 b) { return a > b ? a : b; }
int compare(long long a, long long b) { return (a < b) + (a == b) * 2 + ((u64)a > (u64)b) * 4; }
_Bool is_odd(int a) { return a & 1; }
int popcount(u32 a) { return __builtin_popcount(a); }
int clz(u64 a) { return a ? __builtin_clzll(a) : 64; }
u32 bswap(u32 a) { return __builtin_bswap32(a); }
u32 rotate(u32 a, int n) { return (a << (n & 31)) | (a >> (-n & 31)); }

int sum(const int *a, int n) {
    int s = 0;
    for (int i = 0; i < n; i++) s += a[i];
    return s;
}

void scale(int *a, int n, int k) {
    for (int i = 0; i < n; i++) a[i] *= k;
}

int classify(int x) {
    switch (x) {
    case 0: return 10;
    case 1: return 21;
    case 2: return 32;
    case 3: return 43;
    case 7: return 74;
    default: return -1;
    }
}

int globals(int i) {
    table[i & 15] += counter;
    return table[(i + 1) & 15] + message[0];
}

int many_args(int a, int b, int c, int d, int e, int f, int g, int h, int i, int j, long long k) {
    return a + b * c - d + e * f - g + h * i - j + (int)k;
}

int calls(int x) { return many_args(x, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10) + classify(x); }

int variadic_call(int x, double y) { return printf("%d %g %s\n", x, y, message); }

int big_frame(int i) {
    int a[3000];
    ext(a);
    a[i] = i;
    ext(a);
    return a[2999 - i];
}

int many_live(int *p) {
    int a = p[0], b = p[1], c = p[2], d = p[3], e = p[4], f = p[5], g = p[6], h = p[7];
    int i = p[8], j = p[9], k = p[10], l = p[11], m = p[12], n = p[13], o = p[14], q = p[15];
    ext(p);
    return a * b + c * d + e * f + g * h + i * j + k * l + m * n + o * q + a + q;
}

double fp(double a, float b, int c, long long d) {
    return a * b + c - d / a + (float)(a - b);
}
float ffp(float a, float b) { return a < b ? a * b : a / b + 1.5f; }
int fcmp(double a, double b) { return (a < b) + (a == b) * 2 + (a != a) * 4; }
long long to_int(double a) { return (long long)a + (unsigned)(float)a; }
double to_fp(u64 a, int b) { return (double)a + (float)b; }

void vec_add(int *restrict a, const int *restrict b, const int *restrict c, int n) {
    for (int i = 0; i < n; i++) a[i] = b[i] + c[i] * 3;
}

float vec_dot(const float *a, const float *b, int n) {
    float s = 0;
    for (int i = 0; i < n; i++) s += a[i] * b[i];
    return s;
}

void bytes(u8 *restrict a, const u8 *restrict b, int n) {
    for (int i = 0; i < n; i++) a[i] = b[i] > a[i] ? b[i] : a[i];
}

struct pair { long long a, b; };
struct pair make_pair(long long a, long long b) { struct pair p = {a + b, a - b}; return p; }
long long use_pair(struct pair p) { return p.a * p.b; }

void trap(int x) { if (x) __builtin_trap(); }
_Noreturn void never(void) { __builtin_unreachable(); }
