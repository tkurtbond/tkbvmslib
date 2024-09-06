$ !> TCSDIFF.SDCL -- Compare FILE vs. a revision in TCSFILE
$ SS$_BADPARAM = %x0014
$ TRUE = 1 .eq. 1
$ FALSE = 1 .ne. 1
$ opt_list = "/HELP/NODELETE/REVISION/STDIFF"
$ opt_list_len = f$length (opt_list)
$ revision = ""
$ nodelete = FALSE
$ diffcmd = "diff"
$ i = 1
$ 23000: if (.not.(f$extract (0, 1, p'i') .eqs. "-")) then goto 23001
$ opt = p'i'
$ if (.not.((opt .eqs. "-?") .or (opt .eqs. "-H"))) then goto 23002
$ opt = "-HELP"
$ 23002: 
$ which = f$extract(1, 3, opt)
$ write sys$output "which: ", which
$ ok = (which .nes. "") .and. f$locate ("/" + which, opt_list) .ne. opt_list_len
$ if (.not.(ok)) then goto 23004
$ gosub OPT$'which'
$ goto 23005
$ 23004: 
$ write sys$output "tcsdiff: Invalid option: ''opt'"
$ exit SS$_BADPARAM
$ 23005: 
$ i = i + 1
$ goto 23000
$ 23001: 
$ filespec = p'i'
$ if (.not.(filespec .eqs. "")) then goto 23006
$ write sys$output "tcsdiff: no filespec specified"
$ exit SS$_BADPARAM
$ 23006: 
$ i = i + 1
$ tcsfile = p'i'
$ if (.not.(tcsfile .eqs. "")) then goto 23008
$ write sys$output "tcsdiff: no tcsfile specified"
$ exit SS$_BADPARAM
$ 23008: 
$ filespec = f$parse (filespec)
$ filename = f$parse (filespec,,, "NAME")
$ filetype = f$parse (filespec,,, "TYPE")
$ revfile = "SYS$SCRATCH:" + filename + filetype + "-TMP"
$ write sys$output "tcsfile: ", tcsfile, " revfile: ", revfile
$ if (.not.(revision .nes. "")) then goto 23010
$ write sys$output "revision: ", revision
$ 23010: 
$ get 'revision' 'tcsfile' >'revfile'
$ 'diffcmd' 'revfile' 'filespec'
$ if (.not.(.not. nodelete)) then goto 23012
$ delete/log 'revfile';0
$ goto 23013
$ 23012: 
$ write sys$error "stcsdiff: temporary file ", revfile, " left behind."
$ 23013: 
$ exit
$ OPT$hel:
$ copy sys$input sys$error
 tcsdiff.sdcl -- Compare FILE vs. a revision in TCSFILE

 Usage:

         tcsdiff [-h|-?|-help] [-history=M.N] [-stdiff] FILE TCSFILE

 where FILE is the source file you want to compare and TCSFILE is a
 SWTOOLS VOS TCS revision file.
 
 The selected revision will be extracted from SOURCEFILE-SOURCETYPE.TCS
 into a temporaty file and compared to the version in the working directory.
 The temporary file will be deleted.
 
 Options:
        -? -h -help	 Display help message and exit.
	  -stdiff        Use the SWTOOLS diff instead of VMS diff.
        -revision=M.N  Compare working source against revision M.N.
$ exit
$ OPT$nod:
$ nodelete = TRUE
$ return
$ OPT$rev:
$ p = f$locate ("=", opt)
$ l = f$length (opt)
$ if (.not.(p .ne. l)) then goto 23014
$ revision = "-r" + f$extract (p+1, l, opt)
$ 23014: 
$ return
$ OPT$std:
$ diffcmd = "stdiff"
$ return 
