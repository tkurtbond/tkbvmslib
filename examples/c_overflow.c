#include <limits.h>
#include <stdio.h>
#include <stdlib.h>

int
main (int argc, char **argv)
{
  long lmax = LONG_MAX;
  lmax ++;
  printf ("LONG_MAX: %+ld\n", LONG_MAX);
  printf ("lmax+1:   %ld\n", lmax);
  exit (EXIT_SUCCESS);
}
