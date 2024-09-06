/* lltoa.c -- https://stackoverflow.com/a/18858248 */
#include <limits.h>

#ifdef __VMS__
#include <ll_limits.h>
#endif                          /* defined(__VMS__) */


char* lltoa(long long val, int base){

  static char buf[64] = {0};

  int i = 62;
  int sign = (val < 0);
  if(sign) val = -val;

  if(val == 0) return "0";

  for(; val && i ; --i, val /= base) {
    buf[i] = "0123456789abcdef"[val % base];
  }

  if(sign) {
    buf[i--] = '-';
  }
  return &buf[i+1];

}


#ifdef TEST
#include <stdio.h>

int main() {
  long long a = LLONG_MAX;
  long long b = LLONG_MIN;
  long long c = LLONG_MIN + 1;
  long long d = 23;
#if 0
  /* gcc 2.7.1 Warns that this causes an integer overflow in expression. */
  long long 3 = LLONG_MAX + 1;
#endif

  printf("%ld\n", sizeof(a));
  printf("max   '%s'\n", lltoa(a, 10));
  printf("min   '%s'\n", lltoa(b, 10));
  printf("min+1 '%s'\n", lltoa(c, 10));
  printf("-1    '%s'\n", lltoa((long long)-1, 10));
#if 1
  printf("23    '%s'\n", lltoa(d, 10));
#endif 
}
#endif                          /* defined (TEST) */
