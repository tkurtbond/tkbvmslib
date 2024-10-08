/* cpr.c -- character position report */
#include <stdlib.h>
#include <stdio.h>

int
main (int argc, char **argv)
{
  char response[256];
  int ret;
  int ch1, ch2, ch3, ch4, ch5, ch6, ch7, ch8, ch9;
  printf ("\033[999;999H"       /* Go to row 999, column 999. */
          "\033[6n"             /* Request cursor position. */
          );
  ch1 = getchar ();             /* Escape */
  ch2 = getchar ();             /* [ */
  ch3 = getchar ();             /* row digit 1*/
  ch4 = getchar ();             /* row digit 2*/
  ch5 = getchar ();             /* ; */
  ch6 = getchar ();             /* column digit 1 */
  ch7 = getchar ();             /* column digit 2 */
  ch8 = getchar ();             /* R */

  printf ("%3d, %3d, %3d, %3d, %3d, %3d\n", ch3, ch4, ch5, ch6, ch7, ch8);
  printf ("%3c, %3c, %3c, %3c, %3c, %3c\n", ch3, ch4, ch5, ch6, ch7, ch8);
  
          
  exit (EXIT_SUCCESS);
}
                                                                                                                            