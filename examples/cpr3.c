#include <stdlib.h>
#include <curses.h>

int
main (int argc, char **argv)
{
  char request[] =
    "\033[999;999H"             /* Go to row 999, column 999. */
    "\033[6n"                   /* Request cursor position. */
    ;
  int request_size = sizeof (request);
  int ret;
  char ch1, ch2, ch3, ch4, ch5, ch6, ch7, ch8, ch9;

  initscr ();

  write (0, &request, request_size);

  read (1, &ch1, 1);;             /* Escape */
  read (1, &ch2, 1);;             /* [ */
  read (1, &ch3, 1);;             /* row digit 1*/
  read (1, &ch4, 1);;             /* row digit 2*/
  read (1, &ch5, 1);;             /* ; */
  read (1, &ch6, 1);;             /* column digit 1 */
  read (1, &ch7, 1);;             /* column digit 2 */
  read (1, &ch8, 1);;             /* R */

  endwin ();

  printf ("%3d, %3d, %3d, %3d, %3d, %3d\n", ch3, ch4, ch5, ch6, ch7, ch8);
  printf ("%3c, %3c, %3c, %3c, %3c, %3c\n", ch3, ch4, ch5, ch6, ch7, ch8);

  exit (EXIT_SUCCESS);
}
