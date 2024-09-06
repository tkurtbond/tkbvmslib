#include <stdlib.h>
#include <curses.h>

int
main (int argc, char **argv)
{
  initscr ();
  endwin ();
  exit (EXIT_SUCCESS);
}
