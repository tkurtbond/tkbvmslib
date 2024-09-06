$ !> APPLY_TO.SDCL -- run command in P2&P3 on EACH file matching filespec in P1
$ wso = "write sys$output"
$ wse = "write sys$error"
$ inq = "inquire/nopun"
$ true = (1 .eq 1)
$ false = .not. true
$ quiet = %x10000000
$ debugging = false
$ strip = false
$ verbose = false
$ i = 1 
$ 23000: if (.not.(f$extract(0, 1, p'i') .eqs. "-")) then goto 23001
$ opt = f$extract(1, 1, p'i')
$ if (.not.(opt .eqs. "D")) then goto 23002
$ debugging = true
$ goto 23003
$ 23002: 
$ if (.not.((opt .eqs. "V"))) then goto 23004
$ verbose = true
$ goto 23005
$ 23004: 
$ if (.not.((opt .eqs. "S"))) then goto 23006
$ strip = true
$ goto 23007
$ 23006: 
$ if (.not.((opt .eqs. "H") .or. (opt .eqs. "?"))) then goto 23008
$ goto usage
$ goto 23009
$ 23008: 
$ wse "apply_to: Unrecognized option: ", p'i'
$ goto usage
$ 23009: 
$ 23007: 
$ 23005: 
$ 23003: 
$ i = i + 1
$ goto 23000
$ 23001: 
$ iplus1 = i + 1
$ iplus2 = i + 2
$ filename = p'i'
$ command_head = p'iplus1'
$ command_tail = p'iplus2'
$ if (.not.(filename .eqs. "")) then goto 23010
$ goto usage
$ 23010: 
$ strip_version = f$locate(";", filename) .eq. f$length(filename)
$ i = 0
$ f = f$search(filename)
$ 23012: if (.not.(f .nes. "")) then goto 23013
$ define/user sys$input sys$command
$ if (.not.(strip_version)) then goto 23014
$ f = f - f$parse(f,,,"VERSION")
$ 23014: 
$ if (.not.(strip)) then goto 23016
$ f = f - f$parse (f,,, "DEVICE") - f$parse (f,,, "DIRECTORY")
$ 23016: 
$ if (.not.(debugging)) then goto 23018
$ wse "f: ", f
$ 23018: 
$ if (.not.(verbose)) then goto 23020
$ wse command_head, " ", f, " ", command_tail
$ 23020: 
$ 'command_head' 'f' 'command_tail'
$ i = i + 1
$ f = f$search(filename)
$ goto 23012
$ 23013: 
$ wse "''i' files processed"
$ The_End:
$ exit
$ usage:
$ type sys$input
 usage: apply_to [OPTION ...] FILESPEC COMMANDHEAD [COMMANDTAIL]
 where:
 FILESPEC       - Is the VMS file specification matching the files you 
                  want to apply COMMANDHEAD to.  Wildcards are allowed.
 COMMANDHEAD    - Is the command you want to apply to each matching 
                  filename.
 COMMANDTAIL    - Is the optional tail end of the command you want to 
                  appply to each matching filename.

 The command as a whole is applied to EACH of the matching files in turn.

 Options:
 -d             - Turn on debugging.
 -h, -?         - Display this message.
 -s             - Strip device and directory from the resulting filenames.
 -v             - Turn on verbose messages.
$ exit 2 .or. quiet
