#include <stdio.h>
#include <stdlib.h>

int 
main (int argc, char **argv)
{
  size_t n = 0;
  long i = 0;
  char *p = malloc (0);
  if (! p) 
    {
      printf ("p is NULL!\n");
      exit (EXIT_FAILURE);
    }
  for (i = 1, n = 1024, p = malloc (n); p; i++, n *= 2, p = malloc (n)) 
    {
      printf ("n: %ld\n", n);
      free (p);
    }

  printf ("exited when n = %ld\n", n);
  exit (EXIT_SUCCESS);
}
