#include <stdio.h>

extern int the_int;
extern char *the_string;

int
main (int argc, char **argv)
{
  printf ("the_int: %d\n", the_int);
  printf ("the_string: %s\n", the_string);
}
