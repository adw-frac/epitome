// Drives number_minmax.ll on numbers, zeros of each sign, and NaNs.
#include <stdio.h>
#include <string.h>
unsigned min32(unsigned, unsigned), max32(unsigned, unsigned);
unsigned long min64(unsigned long, unsigned long);
unsigned short max16(unsigned short, unsigned short);
void max4(unsigned *, const unsigned *, const unsigned *);
int main(void) {
  unsigned f[] = {0x3f800000, 0xbf800000, 0x00000000, 0x80000000, 0x7fc00000, 0x7f800001, 0xffc00001, 0x7f800000};
  for (int i = 0; i < 8; i++) for (int j = 0; j < 8; j++) printf("%08x %08x\n", min32(f[i], f[j]), max32(f[i], f[j]));
  unsigned long d[] = {0x3ff0000000000000, 0x8000000000000000, 0, 0x7ff8000000000000, 0x7ff0000000000001};
  for (int i = 0; i < 5; i++) for (int j = 0; j < 5; j++) printf("%016lx\n", min64(d[i], d[j]));
  unsigned short h[] = {0x3c00, 0xbc00, 0x0000, 0x8000, 0x7e00, 0x7c01};
  for (int i = 0; i < 6; i++) for (int j = 0; j < 6; j++) printf("%04x\n", max16(h[i], h[j]));
  unsigned o[4], a[4] = {0x3f800000, 0x7f800001, 0x80000000, 0x7fc00000}, b[4] = {0x7fc00000, 0x40000000, 0x00000000, 0x7f800001};
  max4(o, a, b);
  printf("%08x %08x %08x %08x\n", o[0], o[1], o[2], o[3]);
  return 0;
}
