// Homogeneous floating-point aggregates, as C passes and returns them:
// structs of up to four floats, doubles or vectors, complex numbers, in
// registers and (past them) on the stack; and vectors past the registers.

typedef float v4f __attribute__((vector_size(16)));
typedef float v2f __attribute__((vector_size(8)));
struct f3 { float x, y, z; };
struct d4 { double a, b, c, d; };
struct q2 { v4f a, b; };
struct h3 { v2f a, b, c; };

struct f3 mk3(float a, float b, float c) {
    struct f3 v = {a, b, c};
    return v;
}
float dot3(struct f3 a, struct f3 b) { return a.x * b.x + a.y * b.y + a.z * b.z; }
struct d4 rev4(struct d4 d) {
    struct d4 r = {d.d, d.c, d.b, d.a};
    return r;
}
double _Complex cmul(double _Complex a, double _Complex b) { return a * b; }
float _Complex cadd(float _Complex a, float _Complex b, float k) { return a + b * k; }
struct q2 qswap(struct q2 q, v4f k) {
    struct q2 r = {q.b + k, q.a};
    return r;
}
struct h3 hrot(struct h3 h) {
    struct h3 r = {h.b, h.c, h.a};
    return r;
}
float late(double a0, double a1, double a2, double a3, double a4, double a5, double a6, struct f3 v, float after,
           struct f3 w, int i, struct d4 d) {
    return v.x + v.y * 2 + v.z * 3 + after * 5 + w.z * 7 + i * 11 + (float)d.c * 13;
}
float many(v4f a0, v4f a1, v4f a2, v4f a3, v4f a4, v4f a5, v4f a6, v4f a7, v4f a8, v4f a9) {
    return a0[0] + a7[1] * 2 + a8[2] * 3 + a9[3] * 4;
}
// Calls of them from here too, the aggregates kept in memory between.
float chain(float k) {
    struct f3 a = mk3(k, k + 1, k + 2);
    struct d4 d = rev4((struct d4){k, 2 * k, 3 * k, 4 * k});
    struct q2 q = qswap((struct q2){{k, 1, 2, 3}, {4, 5, 6, k}}, (v4f){1, 1, 1, 1});
    return dot3(a, a) + (float)(d.a - d.d) + q.a[3] + q.b[0] + late(0, 0, 0, 0, 0, 0, 0, a, k, a, 2, d);
}
