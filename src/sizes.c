// sizes.c -- find sizes of various data types
#include <stdio.h>
int main (int argc, char **argv)
{
  printf ("sizeof (char)               = %d\n", sizeof (char));
  printf ("sizeof (unsigned char)      = %d\n", sizeof (unsigned char));
  printf ("sizeof (short)              = %d\n", sizeof (short));
  printf ("sizeof (unsigned short)     = %d\n", sizeof (unsigned short));
  printf ("sizeof (int)                = %d\n", sizeof (int));
  printf ("sizeof (unsigned int)       = %d\n", sizeof (unsigned int));
  printf ("sizeof (long)               = %d\n", sizeof (long));
  printf ("sizeof (unsigned long)      = %d\n", sizeof (unsigned long));
  printf ("sizeof (long long)          = %d\n", sizeof (long long));
  printf ("sizeof (unsigned long long) = %d\n", sizeof (unsigned long long));
  printf ("sizeof (float)              = %d\n", sizeof (float));
  printf ("sizeof (double)             = %d\n", sizeof (double));
  printf ("sizeof (char *)             = %d\n", sizeof (char *));
  printf ("sizeof (void *)             = %d\n", sizeof (void *));
  printf ("sizeof (int (*)())          = %d\n", sizeof (int (*)()));

  return 0;
}

/*
  Local Variables:
  compile-command: "gcc -o sizes sizes.c"
  End:
*/
