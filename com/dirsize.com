$ verifying = 'f$verify(f$type(dirsize_verify) .nes. "")'
$ !> DIRSIZE.SDCL -- Show total size of directory and all subdirectories.
$ TRUE = (1 .eq. 1)
$ FALSE = .not. TRUE
$ debug = TRUE
$ format_string_1 = "!44<[!AS]!> !10SL !10SL !10SL"
$ format_string_2 = "!44<!AS!> !10AS !10AS !10AS"
$ opt_list = "/HEADING/HELP/OUTPUT/SORT/"
$ opt_list_len = f$length(opt_list)
$ do_heading = FALSE
$ do_output = FALSE
$ do_sort = FALSE
$ i = 1
$ 23000: if (.not.(f$extract(0, 1, p'i') .eqs. "-")) then goto 23001
$ opt = p'i'
$ if (.not.((opt .eqs. "-H") .or. (opt .eqs. "-?"))) then goto 23002
$ gosub OPT$hel 
$ 23002: 
$ which = f$extract(1, 3, opt)
$ ok = (f$locate("/" + which, opt_list) .ne. opt_list_len) .and. (which .nes. -
  "")
$ if (.not.(ok)) then goto 23004
$ gosub OPT$'which'
$ goto 23005
$ 23004: 
$ write sys$error "Invalid Option: ''opt'"
$ 23005: 
$ i = i + 1
$ goto 23000
$ 23001: 
$ if (.not.(do_sort .and. .not. do_output)) then goto 23006
$ do_output = TRUE 
$ output_file = "sys$output:"
$ 23006: 
$ if (.not.(.not. do_output)) then goto 23008
$ outf = "sys$output"
$ goto 23009
$ 23008: 
$ outf = "outf_logname"
$ if (.not.(do_sort)) then goto 23010
$ temp_file = "sys$scratch:_dirsize_" + f$getjpi("", "PID") + ".TMP"
$ open 'outf' 'temp_file' /write/error=Cannot_Open_File
$ goto 23011
$ 23010: 
$ open 'outf' 'output_file' /write/error=Cannot_Open_File
$ 23011: 
$ 23009: 
$ if (.not.(do_heading)) then goto 23012
$ write 'outf' f$fao(format_string_2, " Directory", "Total Size","Dir Size", -
  "Sub Size")
$ write 'outf' f$fao(format_string_2,"============================================","==========", -
  "==========", "==========")
$ 23012: 
$ StartDir = p'i' 
$ if (.not.(StartDir .eqs. "")) then goto 23014
$ inquire StartDir "_Starting Directory"
$ 23014: 
$ if (.not.(StartDir .eqs. "")) then goto 23016
$ exit (1 .or. (f$verify(verifying) .and. 0))
$ 23016: 
$ DevSpec = f$parse(StartDir,,,"device")
$ DirSpec = f$parse(StartDir,,,"directory") - "[" - "]"
$ Top = 1 
$ DirSpec_'Top' = DirSpec 
$ TotalSize_'Top' = 0 
$ 23018: 
$ FileSpec = f$search(DevSpec + "[" + DirSpec + "]*.dir;1", Top)
$ FileSpec = f$parse(FileSpec,,,"name")
$ if (.not.(FileSpec .eqs. "000000")) then goto 23021
$ goto 23019
$ 23021: 
$ if (.not.(FileSpec .nes. "")) then goto 23023
$ Top = Top + 1 
$ DirSpec_'Top' = DirSpec 
$ DirSpec = DirSpec + "." + FileSpec 
$ if (.not.(f$type(TotalSize_'Top') .eqs. "")) then goto 23025
$ TotalSize_'Top' = 0
$ 23025: 
$ goto 23019
$ 23023: 
$ if (.not.(Top .eq. 1)) then goto 23027
$ goto 23020
$ 23027: 
$ if (.not.(Top .ge. 0)) then goto 23029
$ gosub DoCurrentLevel 
$ DirSpec = DirSpec_'Top' 
$ Top = Top - 1 
$ goto 23019
$ 23029: 
$ write sys$error "dirsize: Stack Underflow!"
$ goto Close_Files
$ 23019: goto 23018
$ 23020: 
$ gosub DoCurrentLevel 
$ Close_Files:
$ if (.not.(do_output)) then goto 23031
$ close 'outf'
$ if (.not.(do_sort)) then goto 23033
$ sort 'temp_file' 'output_file'/spec=sys$input
/collating=(seq=ascii,mod=("["="!", "."="!", "]"="!", "="="!"))
/field=(name:total_size,position:45,size:10)
/key=(total_size,descending)
$ delete 'temp_file'.0
$ 23033: 
$ 23031: 
$ The_End:
$ exit (1 .or. (f$verify(verifying) .and. 0)) 
$ Cannot_Open_File:
$ write sys$error "dirsize: cannot open output file"
$ exit (1 .or. (f$verify(verifying) .and. 0))
$ DoCurrentLevel:
$ Spec = DevSpec + "[" + DirSpec + "]"
$ DirSize_'Top' = 0 
$ FileName = f$search(Spec + "*.*;*")
$ 23035: if (.not.(FileName .nes. "")) then goto 23036
$ DirSize_'Top' = DirSize_'Top' + f$file(FileName, "ALQ") 
$ FileName = f$search(Spec + "*.*;*")
$ goto 23035
$ 23036: 
$ TopPlus1 = Top + 1 
$ if (.not.(f$type(TotalSize_'TopPlus1') .eqs. "")) then goto 23037
$ write 'outf' f$fao(format_string_1, DirSpec, DirSize_'Top', DirSize_'Top', -
  0)
$ TotalSize_'Top' = TotalSize_'Top' + DirSize_'Top'
$ goto 23038
$ 23037: 
$ Dir_and_SubDir_Size = DirSize_'Top' + TotalSize_'TopPlus1'
$ write 'outf' f$fao(format_string_1, DirSpec, Dir_and_SubDir_Size, DirSize_'Top', -
  TotalSize_'TopPlus1')
$ TotalSize_'Top' = TotalSize_'Top' + Dir_and_SubDir_Size
$ delete/symbol TotalSize_'TopPlus1' 
$ 23038: 
$ return 
$ OPT$hea:
$ do_heading = TRUE
$ return 
$ OPT$hel:
$ copy sys$input sys$error
 Usage:
        @dirsize [-h] [-?] [-heading] [-help] [-sort] [-output=file] directory

 where directory is the directory in the form [dir.subdir].
 Options:
        -heading      Output an explanitory heading at beginning.
        -?, -h, -help Display help message and exit.
        -sort         sort the output so top directory is first.
        -output=file  Place the output in a file.
$ exit (2 .or. (f$verify(verifying) .and. 0))
$ OPT$out:
$ do_output = TRUE
$ p = f$locate("=", opt)
$ l = f$length(opt)
$ if (.not.(p .ne. l)) then goto 23039
$ output_file = f$extract(p+1, l, opt)
$ goto 23040
$ 23039: 
$ write sys$error "dirsize: filename not specified in -output"
$ exit (1 .or. (f$verify(verifying) .and. 0))
$ 23040: 
$ return 
$ OPT$sor:
$ do_sort = TRUE
$ return 
