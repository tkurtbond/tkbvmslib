#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <math.h>
#include <lib$routines.h>
#include <descrip.h>

#define INHIBIT_MESSAGE  0x10000000


char *prog_name = NULL;

int 
die (int status, char *fmt, ...)
{
  va_list a;
  va_start (a, fmt);
  fprintf (stderr, "%s: fatal error: ", prog_name);
  vfprintf (stderr, fmt, a);
  va_end (a);
  fprintf (stderr, "\n");
  fflush (stderr);
  exit (status | INHIBIT_MESSAGE);
}

#define BUF_SIZ 512
int 
main (int argc, char **argv)
{
  char *end;
  double dividend, divisor;
  char buf[BUF_SIZ];
  struct dsc$descriptor_s sym_value;
  $DESCRIPTOR (sym_name, "PERCENT_RESULT");
  long table = 1;
  unsigned long ret;

  prog_name = argv[0];
  if (argc != 3) die (2, "must specify two arguments");

  dividend = strtod (argv[1], &end);
  if ((dividend == 0) && (end == argv[1]))
    die (2, "unable to parse dividend %s as double", argv[1]);

  divisor = strtod (argv[2], &end);
  if ((divisor == 0) && (end == argv[2]))
    die (2, "unable to parse divisor %s as double", argv[2]);

  sprintf (buf, "%d", (long) (dividend * 100.0 / divisor));

  sym_value.dsc$w_length = strlen (buf);
  sym_value.dsc$b_dtype = DSC$K_DTYPE_T, 
  sym_value.dsc$b_class = DSC$K_CLASS_S;
  sym_value.dsc$a_pointer = buf;

  ret = lib$set_symbol (&sym_name, &sym_value, &table);
  
  exit (0);
}
