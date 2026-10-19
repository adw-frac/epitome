/* The C library's declarations the test programs use (see tests/riscv.rs). */
double fabs(double);
double sqrt(double);
float fabsf(float);
float sqrtf(float);
#define INFINITY __builtin_inff()
#define NAN __builtin_nanf("")
#define isfinite(x) __builtin_isfinite(x)
#define isnan(x) __builtin_isnan(x)
#define isinf(x) __builtin_isinf(x)
