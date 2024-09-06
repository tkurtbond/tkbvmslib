$!> TOBACKUP.com -- p1 = in, p2 = out
$ define infile 'p1
$ define outfile 'p2
$ run exe_lib:tobackup
