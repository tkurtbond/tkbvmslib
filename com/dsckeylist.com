$! DSCKEYLIST.COM -- List a .DSC file or files, showing the key information.
$
$	verifying = 'f$verify(f$type(dsckeylist_verify) .nes. "")'
$
$	if (p1 .eqs. "?") .or. (p1 .eqs. "") then goto usage
$ 	context = ""
$ 	pid = f$pid (context)
$	i = 1
$ 	filespec = p'i'
$	filespec = f$parse (filespec, ".DSC",,, "SYNTAX_ONLY")
$ 	outfilename = f$parse ("dsckeylist" + pid + ".tmp", "SYS$SCRATCH")
$	!+
$	! If the user doesn't include a wildcard in the filespec,
$	! f$search will always return the filename as many times as called
$	! and never the empty string, so check for that.
$	!-
$	old_filename = ""
$	num_files = 0
$ 10$:	
$	filename = f$search (filespec)
$	if (num_files .eq. 0) .and. (filename .eqs. "") then goto no_match
$	num_files = num_files + 1
$	if (filename .eqs. "") .or. (old_filename .eqs. filename) then goto 19$
$	old_filename = filename
$	name = f$parse (filename,,, "NAME")
$	!+
$	! Oddly enough, apparently specifying the extension in the argument
$	! to describe below only works with the /LIST option; if not using
$	! the /LIST option, DESCRIBE dies complaining about not supporting 
$	! SQL tables.
$	! 
$	! So, for what we what to do we have to get rid of the .extension.
$	!-
$	newname = f$parse (filename,,, "DEVICE") -
		+ f$parse (filename,,, "DIRECTORY") -
		+ f$parse (filename,,, "NAME")
$	!
$ 	dclsub/input=sys$input/output='outfilename'
$ DECK
$ ! start of ~outfilename~ for ~filename~
$ delete 'f$environment ("PROCEDURE")'	! get rid of temporary file
$ define/user sys$output ~name~.kdsc
$ run dms:describe
$ DECK/DOLLARS="$ENDDECK"
~newname~
key list

$ENDDECK
$ deassign sys$output
$ ! end of ~outfilename~ for ~filename~
$ EOD
$ 	@'outfilename'
$	goto 10$
$ 19$:
$ 	exit (1 .or. (f$verify(verifying) .and. 0))
$ usage:
$	write sys$output "usage: dsckeylist <filespec>"
$	write sys$output "where <filespec> resolves to a POISE .DSC file."
$ no_match:
$	write sys$output "unable to find description file ", filespec
$	exit (2 .or. (f$verify(verifying) .and. 0))
