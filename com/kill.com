$ verifying = 'f$verify(f$type(kill_verify) .nes. "")'
$ !> KILL.SDCL -- Removes all files with the same ending
$ wso = "write sys$output"
$ wse = "write sys$error"
$ inq = "inquire/nopun"
$ true = (1 .eq. 1)
$ false = .not. true
$ testing = false
$ bad_ext = "\\*\ada\bas\c\cld\cob\com\dsc\dta\for\h\icn\mar\pas\rno\sdcl\tex\"
$ bad_ext_len = f$length(bad_ext)
$ list = p1 + p2 + p3 + p4 + p5 + p6 + p7 + p8
$ if (.not.(list .eqs. "")) then goto 23000
$ inq list "List of file extensions to delete: "
$ if (.not.(list .eqs. "")) then goto 23002
$ goto The_End
$ 23002: 
$ 23000: 
$ list = "," + f$edit(list, "lowercase,collapse") 
$ p = f$locate("+", list) 
$ length = f$length(list) 
$ 23004: if (.not.(p .ne. length)) then goto 23005
$ list[p * 8, 8] = 44 
$ p = f$locate("+", list) 
$ goto 23004
$ 23005: 
$ n = 1 
$ element = f$element(n, ",", list)
$ delete_list = ""
$ 23006: if (.not.(element .nes. ",")) then goto 23007
$ if (.not.(element .eqs. ".")) then goto 23008
$ element = "" 
$ 23008: 
$ if (.not.(f$locate("\" + element + "\", bad_ext) .ne. bad_ext_len)) then goto 23010
$ inq sure "Are you sure you want to delete *.''element';* <n>: "
$ if (.not.(sure .eqs. "")) then goto 23012
$ sure = "n"
$ 23012: 
$ if (.not.(sure)) then goto 23014
$ delete_list = delete_list + ", *." + element + ";*"
$ 23014: 
$ goto 23011
$ 23010: 
$ delete_list = delete_list + ", *." + element + ";*"
$ 23011: 
$ n = n + 1 
$ element = f$element(n, ",", list)
$ goto 23006
$ 23007: 
$ delete_list = f$extract(1, f$length(delete_list), delete_list)
$ if (.not.(testing)) then goto 23016
$ wse "Delete_List: ", delete_list
$ goto 23017
$ 23016: 
$ if (.not.(f$edit(delete_list, "collapse") .eqs. "")) then goto 23018
$ wse "kill: nothing to delete"
$ goto 23019
$ 23018: 
$ delete /log 'delete_list'
$ 23019: 
$ 23017: 
$ The_End:
$ exit (1 .or. (f$verify(verifying) .and. 0))
