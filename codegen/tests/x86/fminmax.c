// IEEE 754's maximum and minimum of vectors of floats (gen_sel.py's
// float_minmax): a NaN if either is one, +0 the greater of the zeros.
typedef float f32 __attribute__((ext_vector_type(4)));
typedef double f64 __attribute__((ext_vector_type(2)));
typedef float f32x8 __attribute__((ext_vector_type(8)));
typedef double f64x4 __attribute__((ext_vector_type(4)));
#define MINMAX(T) \
    void minmax_##T(T *o, const T *a, const T *b) { \
        o[0] = __builtin_elementwise_maximum(*a, *b); \
        o[1] = __builtin_elementwise_minimum(*a, *b); \
    }
MINMAX(f32)
MINMAX(f64)
MINMAX(f32x8)
MINMAX(f64x4)
