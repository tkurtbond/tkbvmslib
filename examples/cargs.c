#include <stdio.h>
#include <stdlib.h>


int
main (int argc, char **argv)
{
  int i;

  printf ("Note that the VAX C RTL downcases all the arguments to C programs.\n");
  for (i = 0; i < argc; i++)
    printf ("%s\n", argv[i]);

  exit (EXIT_SUCCESS);
}
