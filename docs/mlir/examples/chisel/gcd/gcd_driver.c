/* Drives the arcilator GCD model through its eval function.
   Offsets come from GCD.state.json. */
#include <stdint.h>
#include <stdio.h>
#include <string.h>
void GCD_eval(uint8_t *state);
/* Stubs for the runtime calls referenced by GCD_main (never called here). */
void *arcRuntimeIR_allocInstance(void *m, void *a) { return 0; }
void arcRuntimeIR_deleteInstance(void *p) {}
void arcRuntimeIR_onEval(void *p) {}
void arcRuntimeIR_onInitialized(void *p) {}
static _Alignas(16) uint8_t s[48];
static void set16(int off, uint16_t v) { memcpy(s + off, &v, 2); }
static uint16_t get16(int off) { uint16_t v; memcpy(&v, s + off, 2); return v; }
static void tick(void) { s[24] = 0; GCD_eval(s); s[24] = 1; GCD_eval(s); }
int main(void) {
  uint16_t a = 1071, b = 462; /* gcd = 21 */
  set16(26, a); set16(28, b); s[30] = 1; tick(); s[30] = 0;
  int cycles = 0;
  while (!s[40] && cycles < 10000) { tick(); cycles++; }
  printf("gcd(%u, %u) = %u after %d cycles\n", a, b, get16(38), cycles);
  return 0;
}
