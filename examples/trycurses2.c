#include <stdlib.h>
#include <curses.h>

int
main (int argc, char **argv)
{
  initscr ();
  clear ();
  while (1)
    {
      int ch = mvgetch (10, 10);
      move (20, 10);
      printw ("%d", ch);
      clrtoeol ();
    }
  endwin ();
  exit (EXIT_SUCCESS);
}
