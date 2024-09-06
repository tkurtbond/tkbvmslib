/* lc.c - List files with VMS wildcards, print only filename & filetype. */
/* Using Parse and Search Services */
#include <stdio.h>
#include <ssdef.h>
#include <stsdef.h>
#include <string.h>
#include <rms.h>
#include <rmsdef.h>
#include <starlet.h>
#include <vms/ssdef.h>
#define MAXFILENAMELEN (NAM$C_MAXRSS+1)
static int rms_status, rms_status2; /* RMS status variables */
static char
  fbuf[MAXFILENAMELEN],         /* filename buffer */
  xbuf[MAXFILENAMELEN],         /* expanded filename buffer */
  pfbuf[MAXFILENAMELEN],
  pxbuf[MAXFILENAMELEN],
  odev[MAXFILENAMELEN],         /* output device name */
  odir[MAXFILENAMELEN],         /* output directory name */
  oname[MAXFILENAMELEN],        /* output file name */
  otype[MAXFILENAMELEN];        /* output file type */

  

struct FAB filfab, resfab;      /* FAB for $PARSE and $SEARCH */
struct NAM filnam, resnam;      /* NAM for $PARSE and $SEARCH */


void
strtolower (char *s, int n)
{
  int i;
  for (i = 0; i < n; i++)
    s[i] = tolower (s[i]);
}


extern int getopt(int, char **, char *);
extern char *optarg;
extern int optind;

extern char **ioinit();

FILE *outfile;


void
list_files (char *pattern)
{
  char obuf[MAXFILENAMELEN];

  filfab = cc$rms_fab;          /* Get a FAB */
  filfab.fab$l_fna = pattern;      /* Parse filename from PATTERN */
  filfab.fab$b_fac = FAB$M_GET; /* Only allow $GETs */
  filfab.fab$l_fop = FAB$M_NAM; /* Use the NAM block for filename */
  filfab.fab$l_nam = &filnam;   /* -> NAM block */

  filnam = cc$rms_nam;          /* Get a NAM block */
  filnam.nam$l_esa = xbuf;      /* -> Expanded filespec buffer */
  filnam.nam$b_ess = NAM$C_MAXRSS; /* Expanded filespec buffer length */
  filnam.nam$l_rsa = fbuf;      /* -> Resultant filespec buffer */
  filnam.nam$b_rss = NAM$C_MAXRSS; /* Resultant filespec buffer length */


  /* Initialize RMS structures */
  /* Get filespec to search */
  /* Validate filespec */
  filfab.fab$b_fns = strlen(pattern);
  if (((rms_status = sys$parse(&filfab)) & STS$M_SUCCESS) == 0)
    sys$exit (rms_status);

  /* Loop for all files matching filespec */
  for (;;)
    {
      rms_status = sys$search(&filfab);
      
      if (! (rms_status & STS$M_SUCCESS)) break;

      resfab = cc$rms_fab;      /* Get a FAB */
      resfab.fab$l_fna = filnam.nam$l_rsa; /* Parse file name from result buffer */
      resfab.fab$b_fns = filnam.nam$b_rsl;
      resfab.fab$b_fac = FAB$M_GET; /* Only allow $GETs */
      resfab.fab$l_fop = FAB$M_NAM; /* Use the NAM block for file name */
      resfab.fab$l_nam = &resnam; /* -> NAM block */

      resnam = cc$rms_nam;      /* Get a NAM block */
      resnam.nam$l_esa = pxbuf; /* -> Expanded file spec buffer */
      resnam.nam$b_ess = NAM$C_MAXRSS; /* Expanded file spec buffer length */
      resnam.nam$l_rsa = pfbuf; /* -> Resultant file spec buffer */
      resnam.nam$b_rss = NAM$C_MAXRSS; /* Resultant file spec buffer length */
      resnam.nam$b_nop = NAM$V_SYNCHK;

      rms_status2 = sys$parse(&resfab);
      if ((rms_status2 & STS$M_SUCCESS) == 0)
        {
          sys$exit (rms_status2);
        }

      strncpy (obuf, (char *)resnam.nam$l_name, resnam.nam$b_name);
      obuf[resnam.nam$b_name] = '\0';
      strtolower (obuf, resnam.nam$b_name);
      fprintf (outfile, "%s", obuf);

      strncpy (obuf, (char *)resnam.nam$l_type, resnam.nam$b_type);
      obuf[resnam.nam$b_type] = '\0';
      strtolower (obuf, resnam.nam$b_type);
      fprintf (outfile, "%s\n", obuf);
    }
}

int
main(int argc, char **argv)
{
  char *ibuf = "*.*";
  auto FILE *fil; /* File pointer for file functions */
  auto int i; /* Generic loop variable */
  int opt_errors = 0;
  int ch;
  char *outfilename = NULL;

#if 0
  argv = ioinit(&argc, argv);
#endif

  outfile = stdout;

  optind = 0;			/* init for getopt */
  while ((ch = getopt(argc, argv, "o:")) != EOF) {
    switch (ch) {
    case 'o':
      outfilename = optarg;
      break;
    default:
      opt_errors++;
      break;
    }
  }

  if (opt_errors)
    {
      fprintf (stderr, "usage: %s [-o outfile]\n", argv[0]);
      exit (SS$_BADPARAM);
    }

  if (outfilename)
    {
      outfile = fopen (outfilename, "w");
      if (! outfile)
        {
          fprintf (stderr, "%s: unable to open \"%s\"\n", argv[0], outfilename);
          exit (RMS$_FNF);
        }
    }

  if ((argc - optind) == 0)
      list_files (ibuf);
  else
    {
      for (i = optind; i < argc; i++)
        {
          ibuf = argv[i];
          list_files (ibuf);
        }
    }

  if (outfilename) fclose (outfile);

  if ((rms_status == RMS$_FNF) || (rms_status == RMS$_NMF))
    rms_status = SS$_NORMAL; /* Handle expected errors */
  return(rms_status);
}
