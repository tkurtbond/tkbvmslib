#include <stdio.h>
#include <stdlib.h>

int
main (int argc, char **argv)
{
  int i;
  for (i = 1; i < argc; i++) {
    if (i > 1) printf (" ");
    printf ("%s", argv[i]);
  }
  printf ("\n");
  exit (EXIT_SUCCESS);
}
