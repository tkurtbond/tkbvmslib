$ verifying = 'f$verify(f$type(loop_verify) .nes. "")'
$ !> LOOP.SDCL -- execute a command repeatedly
$ TRUE = (1 .eq. 1)
$ FALSE = .not. TRUE
$ if (.not.(p1 .eqs. "?")) then goto 23000
$ goto Usage
$ 23000: 
$ opt_list = "/LIM/WAI/" 
$ opt_list_len = f$length(opt_list)
$ islimit = FALSE
$ iswait = FALSE
$ i = 1
$ 23002: if (.not.(f$extract(0, 1, p'i') .eqs. "-")) then goto 23003
$ opt = p'i'
$ which = f$extract(1, 3, opt)
$ ok = (f$locate("/" + which, opt_list) .ne. opt_list_len) .and. (which .nes. -
  "")
$ if (.not.(ok)) then goto 23004
$ gosub OPT$'which'
$ goto 23005
$ 23004: 
$ write sys$output "Invalid Option: ''opt'"
$ 23005: 
$ i = i + 1
$ goto 23002
$ 23003: 
$ command = p'i'
$ if (.not.(command .eqs. "")) then goto 23006
$ inquire/nopun command "Command: "
$ if (.not.(command .eqs. "")) then goto 23008
$ goto The_End
$ 23008: 
$ 23006: 
$ 23010: 
$ 'command'
$ if (.not.(islimit)) then goto 23013
$ limit_counter = limit_counter + 1
$ if (.not.(limit_counter .ge. limit)) then goto 23015
$ goto 23012
$ 23015: 
$ 23013: 
$ if (.not.(iswait)) then goto 23017
$ wait 'delta_time'
$ 23017: 
$ 23011: goto 23010
$ 23012: 
$ The_End:
$ exit (1 .or. (f$verify(verifying) .and. 0))
$ Usage:
$ write sys$output "usage: loop [-wait[=delta-time]] [-limit[=repetitions]] dcl-command"
$ exit (1 .or. (f$verify(verifying) .and. 0))
$ OPT$lim:
$ islimit = true
$ limit_counter = 0
$ limit = 10 
$ p = f$locate("=", opt)
$ l = f$length(opt)
$ if (.not.(p .ne. l)) then goto 23019
$ limit = f$integer(f$extract(p+1, l, opt))
$ 23019: 
$ return
$ OPT$wai:
$ iswait = true
$ delta_time = "00:05:00.00" 
$ p = f$locate("=", opt)
$ l = f$length(opt)
$ if (.not.(p .ne. l)) then goto 23021
$ delta_time = f$extract(p+1, l, opt)
$ 23021: 
$ return
