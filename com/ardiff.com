$ !> ARDIFF.SDCL -- Compare archive file to the version in a SWTOOLS VOS archive.
$ SS$_BADPARAM = %x0014
$ TRUE = 1 .eq. 1
$ FALSE = 1 .ne. 1
$ opt_list = "/HELP/NODELETE/STDIFF"
$ opt_list_len = f$length (opt_list)
$ nodelete = FALSE
$ diffcmd = "diff"
$ debugging = FALSE
$ i = 1
$ 23000: if (.not.(f$extract (0, 1, p'i') .eqs. "-")) then goto 23001
$ opt = p'i'
$ if (.not.((opt .eqs. "-?") .or (opt .eqs. "-H"))) then goto 23002
$ opt = "-HELP"
$ 23002: 
$ which = f$extract(1, 3, opt)
$ if (.not.(debugging)) then goto 23004
$ write sys$output "which: ", which
$ 23004: 
$ ok = (which .nes. "") .and. f$locate ("/" + which, opt_list) .ne. opt_list_len
$ if (.not.(ok)) then goto 23006
$ gosub OPT$'which'
$ goto 23007
$ 23006: 
$ write sys$output "ardiff: Invalid option: ''opt'"
$ exit SS$_BADPARAM
$ 23007: 
$ i = i + 1
$ goto 23000
$ 23001: 
$ filespec = p'i'
$ if (.not.(filespec .eqs. "")) then goto 23008
$ write sys$output "ardiff: no filespec specified"
$ exit SS$_BADPARAM
$ 23008: 
$ i = i + 1
$ arfile = p'i'
$ if (.not.(arfile .eqs. "")) then goto 23010
$ write sys$error "ardiff: no archive file specified"
$ exit SS$_BADPARAM
$ 23010: 
$ fullspec = f$parse (filespec)
$ filename = f$parse (filespec,,, "NAME")
$ filetype = f$parse (filespec,,, "TYPE")
$ tmpfile = "SYS$SCRATCH:" + filename + filetype + "-TMP"
$ write sys$output "arfile: ", arfile, " tmpfile: ", tmpfile
$ ar p 'arfile' 'filespec' >'tmpfile'
$ 'diffcmd' 'tmpfile' 'fullspec'
$ if (.not.(.not. nodelete)) then goto 23012
$ delete/log 'tmpfile';0
$ goto 23013
$ 23012: 
$ write sys$error "sardiff: temporary file ", tmpfile, " left behind."
$ 23013: 
$ exit
$ OPT$hel:
$ copy sys$input sys$error
 ardiff.sdcl -- Compare archive file to the version in a SWTOOLS VOS archive.
 Usage:
 
         ardiff [-h|-?|-help] [-stdiff] SRCFILE ARFILE
 
 where SRCFILE is the source file you want to compare and ARFILE
 contains the SWTOOLS VOS archive containing the version to compare
 to.  The version in the archive file will be extracted to a
 temporary file file and compared to the version in the working
 directory.  The temporary file will be deleted unless
 
 Options:
        -? -h -help	 Display help message and exit.
	  -stdiff        Use the SWTOOLS diff instead of VMS diff.
$ exit
$ OPT$nod:
$ nodelete = TRUE
$ return
$ OPT$std:
$ diffcmd = "stdiff"
$ return 
