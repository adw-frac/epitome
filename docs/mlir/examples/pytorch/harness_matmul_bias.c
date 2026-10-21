/* Call the compiled matmul_bias through its C interface wrapper.
 *
 *   clang -c -x ir matmul_bias.ll -o matmul_bias.o
 *   clang harness_matmul_bias.c matmul_bias.o -o matmul_bias && ./matmul_bias
 *
 * Expected (same as torch): 11 22 33 46 / 14 25 36 55
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

/* MLIR's ranked memref descriptor for rank N. */
typedef struct { float *allocated, *aligned; int64_t offset, sizes[1], strides[1]; } MemRef1;
typedef struct { float *allocated, *aligned; int64_t offset, sizes[2], strides[2]; } MemRef2;

/* Result first (returned through a pointer), then one pointer per argument. */
extern void _mlir_ciface_matmul_bias(MemRef2 *result, MemRef2 *a, MemRef2 *b, MemRef1 *bias);

int main(void) {
  float a[6] = {1, 2, 3, 4, 5, 6};
  float b[12] = {1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 1};
  float bias[4] = {10, 20, 30, 40};
  MemRef2 ma = {a, a, 0, {2, 3}, {3, 1}};
  MemRef2 mb = {b, b, 0, {3, 4}, {4, 1}};
  MemRef1 mbias = {bias, bias, 0, {4}, {1}};
  MemRef2 r;
  _mlir_ciface_matmul_bias(&r, &ma, &mb, &mbias);
  printf("sizes %lld %lld strides %lld %lld\n", (long long)r.sizes[0],
         (long long)r.sizes[1], (long long)r.strides[0], (long long)r.strides[1]);
  for (int i = 0; i < 2; i++) {
    for (int j = 0; j < 4; j++)
      printf("%g ", r.aligned[r.offset + i * r.strides[0] + j * r.strides[1]]);
    printf("\n");
  }
  free(r.allocated);
  return 0;
}
