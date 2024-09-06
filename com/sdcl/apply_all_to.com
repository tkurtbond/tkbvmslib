$ !> APPLY_ALL_TO.SDCL -- run command in P2&P3 on ALL files from filespec in P1
$ wso = "write sys$output"
$ wse = "write sys$error"
$ inq = "inquire/nopun"
$ true = (1 .eq 1)
$ false = .not. true
$ quiet = %x10000000
$ sep = " " 
$ strip = false
$ verbose = false
$ opt_list = "/COMMA/STRIP/VERBOSE/"
$ opt_list_len = f$length (opt_list)
$ i = 1
$ 23000: if (.not.(f$extract (0, 1, p'i') .eqs. "-")) then goto 23001
$ opt = p'i'
$ if (.not.((opt .eqs. "-H") .or. (opt .eqs. "-?") .or. (opt .eqs. "-HELP"))) then goto 23002
$ goto usage
$ 23002: 
$ which = f$extract (1, 3, opt)
$ ok = f$locate ("/" + which, opt_list) .ne. opt_list_len .and. (which .nes. -
  "")
$ if (.not.(ok)) then goto 23004
$ gosub OPT$'which'
$ goto 23005
$ 23004: 
$ write sys$output "Invalid option: ''opt'"
$ goto usage
$ 23005: 
$ i = i + 1
$ goto 23000
$ 23001: 
$ filename = p'i'
$ i = i + 1
$ command_head = p'i'
$ i = i + 1
$ command_tail = p'i'
$ if (.not.(filename .eqs. "")) then goto 23006
$ inq filename "_Filespec: "
$ 23006: 
$ if (.not.(filename .eqs. "")) then goto 23008
$ exit
$ 23008: 
$ if (.not.(command_head .eqs. "")) then goto 23010
$ inq command_head "_Command: "
$ 23010: 
$ if (.not.(command_head .eqs. "")) then goto 23012
$ exit
$ 23012: 
$ if (.not.(command_tail .eqs. "")) then goto 23014
$ inq command_tail "_Tail: "
$ 23014: 
$ strip_version = f$locate(";", filename) .eq. f$length(filename)
$ i = 0
$ filenames = ""
$ f = f$search(filename)
$ 23016: if (.not.(f .nes. "")) then goto 23017
$ define/user sys$input sys$command
$ if (.not.(strip_version)) then goto 23018
$ f = f - f$parse(f,,,"VERSION")
$ 23018: 
$ if (.not.(strip)) then goto 23020
$ f = f - f$parse (f,,, "DEVICE") - f$parse (f,,, "DIRECTORY")
$ 23020: 
$ if (.not.(filenames .nes. "")) then goto 23022
$ filenames = filenames + sep + f
$ goto 23023
$ 23022: 
$ filenames = f
$ 23023: 
$ i = i + 1
$ f = f$search(filename)
$ goto 23016
$ 23017: 
$ wse "''i' files found"
$ if (.not.(verbose)) then goto 23024
$ write sys$output "''command_head' ''filenames' ''command_tail'"
$ 23024: 
$ 'command_head' 'filenames' 'command_tail'
$ The_End:
$ exit
$ OPT$com:
$ sep = ","
$ return
$ OPT$str:
$ strip = true
$ return ! strip option
$ OPT$ver:
$ verbose = true
$ return ! verbose option
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
 -comma         - Use a comma as the separator between filenames when
                  building the list.
 -h, -?, -help  - Display this message.
 -strip         - Strip the device and the directory from the resulting
                  filenames.
 -verbose       - Turn on verbose messages.
$ exit 2 .or. quiet
