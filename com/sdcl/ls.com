$ !> ls.sdcl -- crude approximation for simple ls.
$ verifying = 'f$verify(f$type(ls_verify) .nes. "")'
$ i = 1
$ 23000: if (.not.(p'i' .nes. "")) then goto 23002
$ filespec = p'i'
$ call do_dir "''filespec'"
$ 23001: i = i + 1
$ goto 23000
$ 23002: 
$ if (.not.(i .eq. 1)) then goto 23003
$ call do_dir "*.*;0"
$ 23003: 
$ exit (1 .or. (f$verify(verifying) .and. 0))
$ do_dir:
$ subroutine
$ filespec = p1
$ old_pathname = ""
$ 23005: 
$ pathname = f$search (filespec)
$ if (.not.(pathname .eqs. "")) then goto 23008
$ goto 23007
$ 23008: 
$ if (.not.(old_pathname .eqs. pathname)) then goto 23010
$ goto 23007
$ 23010: 
$ filename = f$edit (f$parse (pathname,,, "NAME") + f$parse (pathname,,, "TYPE"), -
  "LOWERCASE") 
$ write sys$output filename
$ 23006: goto 23005
$ 23007: 
$ endsubroutine 
