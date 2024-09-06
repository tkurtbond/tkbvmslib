$ !> ARUNCOVERED.SDCL - Check for files in current directory not in a archive.
$ TRUE = 1 .eq. 1
$ FALSE = 1 .ne. 1
$ wso := write sys$output
$ wse := write sys$output
$ dbg = "!"
$ debugging = f$type (aruncovered_debugging) .nes. ""
$ if (.not.(debugging)) then goto 23000
$ dbg := write sys$error
$ 23000: 
$ opt_list = "/HELP/IGNORED/"
$ opt_list_len = f$length(opt_list)
$ default_ignored_list = "OBJ,OLB,HLB,EXE,DIR,TMP"
$ ignored_list = default_ignored_list
$ param_idx = 1
$ 23002: if (.not.(f$extract (0, 1, p'param_idx') .eqs. "-")) then goto 23003
$ opt = p'param_idx'
$ opt_len = f$length (opt)
$ if (.not.((opt .eqs. "-?") .or. (opt .eqs. "-H"))) then goto 23004
$ opt = "-HELP"
$ 23004: 
$ which = f$extract(1, 3, opt)
$ ok = (f$locate("/" + which, opt_list) .ne. opt_list_len) .and. (which .nes. -
  "")
$ if (.not.(ok)) then goto 23006
$ gosub OPT$'which'
$ goto 23007
$ 23006: 
$ write sys$output "Invalid Option: ''opt'"
$ 23007: 
$ param_idx = param_idx + 1
$ goto 23002
$ 23003: 
$ arfile = p'param_idx'
$ if (.not.(arfile .eqs. "")) then goto 23008
$ wse "aruncovered: You must specify an archive file!"
$ goto error_end
$ 23008: 
$ pid = f$getjpi ("", "PID")
$ artmpfile = "ARUNCOVERED_AR-" + pid + ".TMP"
$ ar t1 'arfile' >'artmpfile'
$ if (.not.($status .ne. 1)) then goto 23010
$ wse "aruncovered: Unable to list the archive, exiting."
$ goto error_end
$ 23010: 
$ arsorttmpfile = "ARUNCOVERED_ARSORT-" + pid + ".TMP"
$ stsort 'artmpfile' >'arsorttmpfile'
$ if (.not.($status .ne. 1)) then goto 23012
$ wse "aruncovered: Unablle to sort the archive listing, exiting."
$ goto_error_end
$ 23012: 
$ listing_spec = "lr"
$ i = 0
$ 23014: if (.not.(f$element (i, ",", ignored_list) .nes. ",")) then goto 23016
$ file_type = f$edit (f$element (i, ",", ignored_list), "LOWERCASE")
$ listing_spec = listing_spec + " | find -x ." + file_type
$ 23015: i = i + 1
$ goto 23014
$ 23016: 
$ listing_spec = listing_spec + " | find -x " + f$edit (arfile, "LOWERCASE") -
  + " | sort "
$ shtmpfile = "ARUNCOVERED_SH-" + pid + ".TMP"
$ lrtmpfile = "ARUNCOVERED_LR-" + pid + ".TMP"
$ listing_spec = listing_spec + " >" + lrtmpfile
$ dbg "ignored_list: ", ignored_list
$ dbg "listing_spec: ", listing_spec
$ open/write shtmp 'shtmpfile'
$ write shtmp listing_spec
$ close shtmp
$ sh 'shtmpfile'
$ if (.not.($status .ne. 1)) then goto 23017
$ wse "aruncovered: Unable to produce and sort the directory listing, exiting."
$ goto error_end
$ 23017: 
$ wso "Only in the archive"
$ wso "               Only in the directory"
$ wso "                         In both the archive and the directory"
$ wso "=============================================================="
$ comm 'arsorttmpfile' 'lrtmpfile'
$ gosub delete_tmpfiles
$ exit
$ delete_tmpfiles:
$ if (.not.(debugging)) then goto 23019
$ wse "aruncovered: Debugging, not deleting temmpoary files."
$ return
$ 23019: 
$ if (.not.(f$search (artmpfile + ";0") .nes. "")) then goto 23021
$ delete/log 'artmpfile';0
$ 23021: 
$ if (.not.(f$search (arsorttmpfile + ";0") .nes. "")) then goto 23023
$ delete/log 'arsorttmpfile';0
$ 23023: 
$ if (.not.(f$search (shtmpfile + ";0") .nes. "")) then goto 23025
$ delete/log 'shtmpfile';0
$ 23025: 
$ if (.not.(f$search (lrtmpfile + ";0") .nes. "")) then goto 23027
$ delete/log 'lrtmpfile';0
$ 23027: 
$ return ! delete_tmpfiles
$ error_end:
$ gosub delete_tmpfiles
$ exit 2
$ OPT$hel:
$ copy sys$input sys$output
Check for files in current directory not in a archive.

usage: aruncovered [-HELP|-?|-H] [-ignored=IGNOREDLIST] 

Options:

    -ignored=IGNOREDLIST
        IGNOREDLIST is a list of file types to be ignored, seperated by
        commas.

    -help, -? -h
        Display this message and exit

Default IGNOREDLIST:
$ write sys$output "    ", default_ignored_list
$ exit
$ OPT$ign:
$ p = f$locate("=", opt)
$ l = f$length(opt)
$ if (.not.(p .ne. l)) then goto 23029
$ ignored_list = ignored_list + "," + f$extract(p+1, l, opt)
$ 23029: 
$ return ! -IGNORED
