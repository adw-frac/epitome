// Calls the functions in hfa.c and prints what they return.
#include <stdio.h>

typedef float v4f __attribute__((vector_size(16)));
typedef float v2f __attribute__((vector_size(8)));
struct f3 { float x, y, z; };
struct d4 { double a, b, c, d; };
struct q2 { v4f a, b; };
struct h3 { v2f a, b, c; };
struct f3 mk3(float, float, float);
float dot3(struct f3, struct f3);
struct d4 rev4(struct d4);
double _Complex cmul(double _Complex, double _Complex);
float _Complex cadd(float _Complex, float _Complex, float);
struct q2 qswap(struct q2, v4f);
struct h3 hrot(struct h3);
float late(double, double, double, double, double, double, double, struct f3, float, struct f3, int, struct d4);
float many(v4f, v4f, v4f, v4f, v4f, v4f, v4f, v4f, v4f, v4f);
float chain(float);

int main(void) {
    for (int t = 1; t < 4; t++) {
        float k = (float)t;
        struct f3 a = mk3(k, 2, 3), b = mk3(4, k, 6);
        printf("%g %g %g %g\n", a.x, a.y, a.z, dot3(a, b));
        struct d4 d = rev4((struct d4){k, 2, 3, 4});
        printf("%g %g %g %g\n", d.a, d.b, d.c, d.d);
        double _Complex z = cmul(k + 2.0i, 3 - 1.0i);
        float _Complex w = cadd(1 + 2.0fi, k - 1.0fi, 0.5f);
        printf("%g %g %g %g\n", __real__ z, __imag__ z, __real__ w, __imag__ w);
        struct q2 q = qswap((struct q2){{10, 20, 30, k}, {5, 6, 7, 8}}, (v4f){1, 2, 3, 4});
        printf("%g %g %g %g\n", q.a[0], q.a[3], q.b[0], q.b[3]);
        struct h3 h = hrot((struct h3){{1, 2}, {3, 4}, {5, k}});
        printf("%g %g %g\n", h.a[0], h.b[1], h.c[1]);
        printf("%g\n", late(1, 2, 3, 4, 5, 6, 7, mk3(1, 2, 3), k, mk3(5, 6, 7), 8, (struct d4){9, 10, 11, 12}));
        v4f v[10];
        for (int i = 0; i < 10; i++) v[i] = (v4f){i, i + 0.5f, i + 0.25f, i + k};
        printf("%g %g\n", many(v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9]), chain(k));
    }
    return 0;
}
