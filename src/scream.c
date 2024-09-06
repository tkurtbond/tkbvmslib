#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int
main (int argc, char **argv)
{
  int i;
  for (i = 0; i < 5; i++)
    {
      printf ("\a");
      sleep (1);
    }
  exit (EXIT_SUCCESS);
}
