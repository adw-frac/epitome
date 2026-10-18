// Recursive functions of many shapes. main prints results that the test
// compares before and after the passes.
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Two recursive calls; the first result is live across the second.
static int fib(int n) { return n < 2 ? n : fib(n - 1) + fib(n - 2); }

// A recursive call whose argument is another recursive call.
static int ackermann(int m, int n) {
    if (m == 0) return n + 1;
    if (n == 0) return ackermann(m - 1, 1);
    return ackermann(m - 1, ackermann(m, n - 1));
}

// Tail recursion with an accumulator.
static long fact_acc(int n, long acc) { return n <= 1 ? acc : fact_acc(n - 1, acc * n); }

// Plain tail recursion.
static unsigned gcd(unsigned a, unsigned b) { return b == 0 ? a : gcd(b, a % b); }

// Not a tail call: work after the call.
static long sum_to(long n) { return n == 0 ? 0 : n + sum_to(n - 1); }

// Floating point, with a value live across the call.
static double power(double x, int n) {
    if (n == 0) return 1.0;
    double half = power(x, n / 2);
    return (n % 2) ? half * half * x : half * half;
}

// A binary tree built and walked recursively.
struct node { int value; struct node *left, *right; };

static struct node *insert(struct node *t, int v) {
    if (!t) {
        t = calloc(1, sizeof *t);
        t->value = v;
        return t;
    }
    if (v < t->value) t->left = insert(t->left, v);
    else t->right = insert(t->right, v);
    return t;
}

static int depth(struct node *t) {
    if (!t) return 0;
    int l = depth(t->left), r = depth(t->right);
    return 1 + (l > r ? l : r);
}

static long tree_sum(struct node *t) { return t ? t->value + tree_sum(t->left) + tree_sum(t->right) : 0; }

// Void recursion whose side effects must stay in order.
static void in_order(struct node *t, char *out, int *len) {
    if (!t) return;
    in_order(t->left, out, len);
    *len += sprintf(out + *len, "%d ", t->value);
    in_order(t->right, out, len);
}

static void free_tree(struct node *t) {
    if (!t) return;
    free_tree(t->left);
    free_tree(t->right);
    free(t);
}

// Recursion inside a loop, with a local array live across the calls.
static int queens(int n, int row, int *cols) {
    if (row == n) return 1;
    int count = 0;
    for (int c = 0; c < n; c++) {
        int ok = 1;
        for (int r = 0; r < row; r++)
            if (cols[r] == c || abs(cols[r] - c) == row - r) ok = 0;
        if (!ok) continue;
        cols[row] = c;
        count += queens(n, row + 1, cols);
    }
    return count;
}

// A local array per activation, whose address is used after the call.
static int permutations(int n, int k, int used_mask, char *prefix, char *out) {
    char local[16];
    if (k == n) {
        strcat(out, prefix);
        strcat(out, ",");
        return 1;
    }
    int total = 0;
    for (int i = 0; i < n; i++) {
        if (used_mask & (1 << i)) continue;
        memcpy(local, prefix, k);
        local[k] = (char)('a' + i);
        local[k + 1] = 0;
        total += permutations(n, k + 1, used_mask | (1 << i), local, out);
        local[0] = local[0]; // keep `local` live after the call
    }
    return total;
}

// Quicksort: two recursive calls, pointer arguments.
static void quicksort(int *a, int lo, int hi) {
    if (lo >= hi) return;
    int p = a[(lo + hi) / 2], i = lo, j = hi;
    while (i <= j) {
        while (a[i] < p) i++;
        while (a[j] > p) j--;
        if (i <= j) {
            int t = a[i];
            a[i] = a[j];
            a[j] = t;
            i++;
            j--;
        }
    }
    quicksort(a, lo, j);
    quicksort(a, i, hi);
}

// Towers of Hanoi, counting moves through a pointer.
static void hanoi(int n, int from, int to, int via, long *moves, long *check) {
    if (n == 0) return;
    hanoi(n - 1, from, via, to, moves, check);
    ++*moves;
    *check = *check * 31 + from * 3 + to;
    hanoi(n - 1, via, to, from, moves, check);
}

// Deep recursion that is not an accumulator, so clang leaves it recursive.
// Thousands of frames: the frame pool must grow and shrink.
static unsigned deep_mix(unsigned n) { return n == 0 ? 7 : (deep_mix(n - 1) ^ (n * 2654435761u)) + n; }

// Mutual recursion with a single way in: a recursive-descent parser.
static const char *src;
static long expr(void);

static long factor(void) {
    if (*src == '(') {
        src++;
        long v = expr();
        src++; // ')'
        return v;
    }
    if (*src == '-') {
        src++;
        return -factor();
    }
    long v = 0;
    while (*src >= '0' && *src <= '9') v = v * 10 + (*src++ - '0');
    return v;
}

static long term(void) {
    long v = factor();
    while (*src == '*' || *src == '/') {
        char op = *src++;
        long r = factor();
        v = op == '*' ? v * r : v / r;
    }
    return v;
}

static long expr(void) {
    long v = term();
    while (*src == '+' || *src == '-') {
        char op = *src++;
        long r = term();
        v = op == '+' ? v + r : v - r;
    }
    return v;
}

static long eval(const char *s) {
    src = s;
    return expr();
}

// Mutual recursion between two functions.
static int is_odd(unsigned n);
static int is_even(unsigned n) { return n == 0 ? 1 : is_odd(n - 1); }
static int is_odd(unsigned n) { return n == 0 ? 0 : is_even(n - 1); }

int main(int argc, char **argv) {
    (void)argv;
    int k = argc + 19; // 20, unknown to the compiler
    printf("fib %d\n", fib(k));
    printf("ackermann %d\n", ackermann(2, k / 2));
    printf("fact %ld\n", fact_acc(k, 1));
    printf("gcd %u\n", gcd(1071u * (unsigned)k, 462u * (unsigned)k));
    printf("sum_to %ld\n", sum_to(k * 1000));
    printf("power %.6f\n", power(1.0 + k / 1000.0, k * 7));

    struct node *t = 0;
    unsigned seed = (unsigned)k;
    for (int i = 0; i < 200; i++) {
        seed = seed * 1103515245u + 12345u;
        t = insert(t, (int)((seed >> 8) % 1000));
    }
    printf("depth %d sum %ld\n", depth(t), tree_sum(t));
    char buf[8192];
    int len = 0;
    buf[0] = 0;
    in_order(t, buf, &len);
    printf("in_order %.60s... (%d chars)\n", buf, len);
    free_tree(t);

    printf("deep_mix %u\n", deep_mix((unsigned)k * 500));

    // A tree shaped like a list, 1000 deep: walking it pushes and pops
    // across chunk boundaries over and over.
    struct node *chain = 0;
    for (int i = 0; i < 1000; i++) chain = insert(chain, i);
    printf("chain depth %d sum %ld\n", depth(chain), tree_sum(chain));
    free_tree(chain);

    int cols[16];
    printf("queens(8) %d\n", queens(k - 12, 0, cols));

    char out[4096] = "", prefix[16] = "";
    printf("permutations %d %s\n", permutations(k / 5, 0, 0, prefix, out), out);

    int a[100];
    for (int i = 0; i < 100; i++) a[i] = (i * 37 + k) % 101;
    quicksort(a, 0, 99);
    long h = 0;
    for (int i = 0; i < 100; i++) h = h * 7 + a[i];
    printf("quicksort %d %d %ld\n", a[0], a[99], h);

    long moves = 0, check = 0;
    hanoi(k / 2, 1, 3, 2, &moves, &check);
    printf("hanoi %ld %ld\n", moves, check);

    printf("eval %ld %ld\n", eval("2*(3+4)*-(5-7)+100/(2+3)"), eval("((((1+2)*3)+4)*5)-6"));
    printf("even/odd %d %d\n", is_even((unsigned)k * 11), is_odd((unsigned)k * 11));
    return 0;
}
