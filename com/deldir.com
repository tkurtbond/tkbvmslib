$ verifying = 'f$verify(f$type(deldir_verify) .nes. "")'
$ !> DELDIR.SDCL -- Delete a directory and all files in it.
$ wso = "write sys$output"
$ inq = "inquire/nopun"
$ true = (1 .eq. 1)
$ false = .not. true
$ debug = false
$ verbose_flag = FALSE
$ opt_list = "/HELP/LOG/CONFIRM/EXCLUDE/VERBOSE/"
$ opt_list_len = f$length( opt_list )
$ del_opt = ""
$ i = 1
$ 23000: if (.not.(f$extract( 0, 1, p'i' ) .eqs. "-")) then goto 23001
$ opt = p'i'
$ which = f$extract( 1, 3, opt )
$ ok = (f$locate( "/" + which, opt_list ) .ne. opt_list_len) .and. (which -
  .nes. "")
$ if (.not.(ok)) then goto 23002
$ gosub OPT$'which'
$ goto 23003
$ 23002: 
$ write sys$output "Invalid Option: ''opt'"
$ 23003: 
$ i = i + 1
$ goto 23000
$ 23001: 
$ list = p'i'
$ if (.not.(list .eqs. "")) then goto 23004
$ inq list "_Directory File: "
$ 23004: 
$ if (.not.(list .eqs. "")) then goto 23006
$ exit
$ 23006: 
$ list = "," + f$edit( list, "lowercase,collapse" ) 
$ p = f$locate( "+", list ) 
$ length = f$length( list ) 
$ 23008: if (.not.(p .ne. length)) then goto 23009
$ list[p * 8, 8] = 44 
$ p = f$locate( "+", list ) 
$ goto 23008
$ 23009: 
$ n = 1 
$ dir_name = f$element( n, ",", list )
$ 23010: if (.not.(dir_name .nes. ",")) then goto 23011
$ call delete_dir 'dir_name'
$ n = n + 1 
$ dir_name = f$element( n, ",", list )
$ goto 23010
$ 23011: 
$ The_End:
$ exit (1 .or. (f$verify(verifying) .and. 0))
$ delete_dir:
$ subroutine
$ if (.not.(debug)) then goto 23012
$ wso "Entering Delete_Dir: ''p1'"
$ 23012: 
$ rawname = p1
$ rawname = f$parse( rawname )
$ rawname = f$search( rawname )
$ if (.not.(rawname .eqs. "")) then goto 23014
$ wso f$fao("deldir: Directory not found, !AS", p1)
$ goto 23015
$ 23014: 
$ disk = f$parse( rawname, , , "device" )
$ dirspec = f$parse( rawname, , , "directory" )
$ name = f$parse( rawname, , , "name" )
$ current_dir = disk + dirspec - "]" + "." + name + "]"
$ dirfile = f$search( current_dir + "*.dir;*" ) 
$ if (.not.(debug .or. verbose_flag)) then goto 23016
$ wso "Current_dir: ", current_dir
$ 23016: 
$ 23018: if (.not.(dirfile .nes. "")) then goto 23019
$ call delete_dir 'dirfile'
$ dirfile = f$search( current_dir + "*.dir;*" )
$ goto 23018
$ 23019: 
$ if (.not.(f$search(current_dir + "*.*") .nes. "")) then goto 23020
$ if (.not.(debug .or. verbose_flag)) then goto 23022
$ wso "Deleting files: ", current_dir + "*.*;*"
$ 23022: 
$ if (.not.(.not. debug)) then goto 23024
$ delete'del_opt' 'current_dir'*.*;*
$ 23024: 
$ 23020: 
$ if (.not.(debug .or. verbose_flag)) then goto 23026
$ wso "Deleting root dir: ", rawname
$ 23026: 
$ if (.not.(.not. debug)) then goto 23028
$ set file/prot=(o:rwed) 'rawname'
$ delete'del_opt' 'rawname' 
$ 23028: 
$ 23015: 
$ endsubroutine 
$ OPT$h:
$ OPT$hel:
$ copy sys$input sys$error
 usage: deldir [-option ...] DIRSPEC

 Delete the directory specified in DIRSPEC.

 Options:
    -h, -help            This message.
	  -log		       Log files deleted.
	  -confirm	       Confirm deletions.
	  -exclude=FILESPEC    Exclude files from deletion.
	  -verbose	       Display verbose messages.
$ OPT$log:
$ del_opt = del_opt + "/log"
$ return
$ OPT$con:
$ del_opt = del_opt + "/confirm"
$ return
$ OPT$exc:
$ p = f$locate("=", opt)
$ l = f$length(opt)
$ if (.not.(p .ne. l)) then goto 23030
$ del_opt = del_opt + "/exclude" + f$extract(p, l, opt)
$ 23030: 
$ return
$ OPT$ver:
$ verbose_flag = TRUE
$ return
