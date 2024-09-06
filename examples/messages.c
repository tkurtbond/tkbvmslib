#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <stdarg.h>

char *prog_name = NULL;
FILE *error_file = NULL;        /* Due to VMS oddities we have to set this in main. */
int verbose = 0;

int 
die (int status, char *fmt, ...)
{
  va_list a;
  va_start (a, fmt);
  fprintf (error_file, "%s: fatal error: ", prog_name);
  vfprintf (error_file, fmt, a);
  va_end (a);
  fprintf (error_file, "\n");
  fflush (error_file);
  exit (status);
}


void
error (char *fmt, ...)
{
  va_list a;
  va_start (a, fmt);
  fprintf (error_file, "%s: error: ", prog_name);
  vfprintf (error_file, fmt, a);
  fprintf (error_file, "\n");
  fflush (error_file);
  va_end (a);
}

void
warning (char *fmt, ...)
{
  va_list a;
  va_start (a, fmt);
  fprintf (error_file, "%s: warning: ", prog_name);
  vfprintf (error_file, fmt, a);
  fprintf (error_file, "\n");
  fflush (error_file);
  va_end (a);
}


void
verbose_msg (int level, char *fmt, ...)
{
  va_list a;
  if (verbose >= level)
    {
      va_start (a, fmt);
      fprintf (error_file, "%s: ", prog_name);
      vfprintf (error_file, fmt, a);
      fprintf (error_file, "\n");
      fflush (error_file);
      va_end (a);
    }
}



int
main (int argc, char **argv)
{
  FILE *outfile;
  int error_number = 0;
  prog_name = argv[0];
  error_file = stderr;
  warning ("This is a warning: %s", "BEGONE");
  error ("This is an error: %s", "YOU AGAIN!?!?!?!?");
  outfile = fopen ("][", "r");
  error_number = errno;
  /* This bombs.  STRERROR is in GNU_CC:[000000]LIBERTY.OLB.  Don't know why it doesn't work. */
  printf ("errno: %d; strerror(errno): %s\n", error_number, strerror (error_number));
  die (EXIT_FAILURE, "This is to die for: %s: %s", "BWAHAHAHAHAHAHA!!!!", strerror (error_number));
  exit (EXIT_SUCCESS);
}
