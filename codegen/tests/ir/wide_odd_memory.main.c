// Drives wide_odd_memory.ll: values stored at odd offsets in a buffer of
// 0xee guard bytes, printed with the bytes around them; and loads.
#include <stdio.h>
#include <string.h>
void st104(unsigned char *, unsigned long, unsigned long);
void st104c(unsigned char *);
void st88(unsigned char *, unsigned long, unsigned long);
void st100(unsigned char *, unsigned long, unsigned long);
unsigned long ld104(const unsigned char *);
unsigned long ld88(const unsigned char *);
static void show(const unsigned char *b) {
  for (int i = 0; i < 24; i++) printf("%02x", b[i]);
  printf("\n");
}
int main(void) {
  unsigned char b[24];
  memset(b, 0xee, sizeof b); st104(b + 3, 0x0706050403020100ul, 0xffffffffff0c0b0aul); show(b);
  memset(b, 0xee, sizeof b); st104c(b + 1); show(b);
  memset(b, 0xee, sizeof b); st88(b + 5, 0x1111111111111111ul, 0xffffffffff332211ul); show(b);
  memset(b, 0xee, sizeof b); st100(b + 2, 0x2222222222222222ul, 0xfffffff765432199ul); show(b);
  for (int i = 0; i < 24; i++) b[i] = (unsigned char)(i * 17 + 3);
  printf("%016lx %016lx\n", ld104(b + 3), ld88(b + 7));
  return 0;
}
