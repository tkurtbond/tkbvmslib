#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int 
main (int argc, char **argv)
{
  if (argc > 1)
    {
      if (!strcmp (argv[1], "err"))
	fprintf (stderr, "This is an error\n");
      else if (!strcmp (argv[1], "out"))
	fprintf (stdout, "This is an output\n");
    }
  exit (0);
}
  
