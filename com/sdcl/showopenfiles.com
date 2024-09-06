$ verifying = 'f$verify(f$type(showalldevfiles_verify) .nes. "")'
$ !> SHOWOPENFILES.SDCL -- Show open files on all devices or user specified devices
$ inhibit_message = %x10000000
$ opt_list = "/HELP/OUTPUT/"
$ opt_list_len = f$length (opt_list)
$ i = 1
$ 23000: if (.not.(f$extract(0, 1, p'i') .eqs. "-")) then goto 23002
$ opt = p'i'
$ if (.not.((opt .eqs. "-?") .or. (opt .eqs. "-H"))) then goto 23003
$ out = "-HELP"
$ 23003: 
$ which = f$extract(1, 3, opt)
$ ok = (f$locate("/" + which, opt_list) .ne. opt_list_len) .and. (which .nes. -
  "")
$ if (.not.(ok)) then goto 23005
$ gosub OPT$'which'
$ goto 23006
$ 23005: 
$ write sys$output "Invalid Option: ''opt'"
$ 23006: 
$ 23001: ; i = i + 1
$ goto 23000
$ 23002: 
$ if (.not.(p'i' .eqs. "")) then goto 23007
$ 23009: 
$ device_name = f$device (, "DISK")
$ if (.not.(device_name .eqs. "")) then goto 23012
$ goto 23011
$ 23012: 
$ if (.not.(.not. f$getdvi (device_name, "MNT"))) then goto 23014
$ goto 23010
$ 23014: 
$ show dev/files 'device_name'
$ 23010: goto 23009
$ 23011: 
$ goto 23008
$ 23007: 
$ 23016: if (.not.(p'i' .nes. "")) then goto 23018
$ len = f$length (p'i')
$ if (.not.(f$locate (",", p'i') .nes. len)) then goto 23019
$ wse "Found a comma-separated list"
$ j = 0
$ 23021: if (.not.(f$element (j, ",", p'i') .nes. ",")) then goto 23023
$ dev = f$element (j, ",", p'i') 
$ wse "Trying element ", j, " device ", dev
$ show dev/files 'dev'
$ 23022: j = j + 1
$ goto 23021
$ 23023: 
$ goto 23020
$ 23019: 
$ show dev/files &p'i'
$ 23020: 
$ 23017: i = i + 1
$ goto 23016
$ 23018: 
$ 23008: 
$ the_end:
$ exit (1 .or. (f$verify(verifying) .and. 0))
$ OPT$hel:
$ goto usage
$ OPT$out:
$ return
$ usage:
$ copy sys$input sys$error
 usage: showalldevfiles [-option...] [devspecs ...]

 Where [] indicates an optional item, and ... indicates a repeatable item.
 See the initialization section at the end of this com file for a list
 of the commands and what they do.

 Parameters:
    devspecs => one or more device specifications, seperated by commas.

 Valid Options:       
    -output=FILENAME         Write output to FILENAME
$ exit (2 .or. inhibit_message .or. (f$verify(verifying) .and. 0)) 
