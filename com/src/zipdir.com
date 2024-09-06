$       if f$type (zip) .eqs. "" then zip := $exe_lib:zip.exe
$       if (p1 .eqs. "-H") .or. (p1 .eqs. "-?") .or. (p1 .eqs. "?") then goto usage
$       indir = p1
$       outdir = p2
$       outzip = f$parse (indir,,, "NAME") + "_" + f$cvtime ("",,"YEAR") + "-" -
               + f$cvtime ("",,"MONTH") + "-" + f$cvtime ("",,"DAY") + ".zip"
$       outzip = f$parse (outzip, outdir)
$       if outzip .eqs. "" 
$       then 
$           write sys$output "Output directory ", outdir + f$parse ("",,, "DIRECTORY"), " does not exist."
$           exit
$       endif
$ 
$       ! Delete the old zip file if it exists.  It's not really correct if we don't.
$       if f$search (outzip) .nes. "" then delete/log 'f$parse(";*", outzip)'
$       zip -r 'outzip' 'indir'
$       exit
$ usage:
$       copy sys$input sys$error
usage: @com:zipdir INDIR [OUTDIR]
where INDIR is the directory file you want to zip, and OUTDIR is the directory
where you want the resulting zip file to be placed.  If outdir is omitted it 
defaults to the current directory.

For example: @com:zipdir sdcl.dir mplk$data3:[mpl.tkb]
$       exit 
