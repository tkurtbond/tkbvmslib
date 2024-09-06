$ verifying = 'f$verify(f$type(compiler_verify) .nes. "")'
$ !> COMPILER.SDCL -- compile and link at terminal or batch.
$ inhibit_message = %x10000000
$ if (.not.(p1 .eqs. "INITIALIZE")) then goto 23000
$ goto comp_file_setup 
$ 23000: 
$ TRUE = (1 .eq. 1)
$ FALSE = .not. TRUE
$ wso := write sys$output 
$ inq := inquire/nopun
$ debug = FALSE
$ opt_list = "/ARGS/BATCH/CCLINK/CHECK/CMP/COM/DEBUG/HELP/" + "LINK/LIST/LNK/MAP/OBJECT/QUEUE/RND/RUN/SETDEBUG/" -
  + "SHOW/SKIP/TESTING/"
$ opt_list_len = f$length(opt_list)
$ batch_mode = FALSE
$ batch_opt = "" 
$ do_run = FALSE
$ run_args = ""
$ do_run_debug = ""
$ queue_opt = "" 
$ del_com = TRUE
$ del_obj = FALSE
$ do_link = TRUE
$ comp_opt = ""
$ link_opt = "/nomap"
$ link_file2 = ""
$ compiler = p1
$ skip_compile = FALSE
$ setdebug_opt = FALSE
$ check_age = FALSE
$ sdcl_compile = FALSE
$ queue_name = f$trnlnm("DMS$DEF_BATCH")
$ if (.not.(queue_name .nes. "")) then goto 23002
$ queue_opt = "/queue=" + queue_name
$ 23002: 
$ if (.not.(compiler .eqs. "CC")) then goto 23004
$ c_compile = TRUE
$ gcc_compile = FALSE
$ goto 23005
$ 23004: 
$ if (.not.(compiler .eqs. "GCC")) then goto 23006
$ gcc_compile = TRUE
$ c_compile = FALSE 
$ goto 23007
$ 23006: 
$ c_compile = FALSE
$ gcc_compile = FALSE
$ if (.not.(compiler .eqs. "SDCL")) then goto 23008
$ sdcl_compile = TRUE
$ do_link = FALSE
$ del_obj = FALSE
$ 23008: 
$ 23007: 
$ 23005: 
$ i = 2
$ 23010: if (.not.(f$extract(0, 1, p'i') .eqs. "-")) then goto 23011
$ opt = p'i'
$ if (.not.((opt .eqs. "-?") .or. (opt .eqs. "-H"))) then goto 23012
$ opt = "-HELP"
$ 23012: 
$ which = f$extract(1, 3, opt)
$ ok = (f$locate("/" + which, opt_list) .ne. opt_list_len) .and. (which .nes. -
  "")
$ if (.not.(ok)) then goto 23014
$ gosub OPT$'which'
$ goto 23015
$ 23014: 
$ write sys$output "Invalid Option: ''opt'"
$ 23015: 
$ i = i + 1
$ goto 23010
$ 23011: 
$ comp_file = p'i'
$ if (.not.(comp_file .eqs. "")) then goto 23016
$ comp_file = f$trnlnm("EDIT_FILE")
$ 23016: 
$ if (.not.(comp_file .eqs. "")) then goto 23018
$ inq comp_file "_File: "
$ 23018: 
$ if (.not.(comp_file .eqs. "")) then goto 23020
$ exit (1 .or. (f$verify(verifying) .and. 0))
$ 23020: 
$ if (.not.(debug)) then goto 23022
$ wso f$fao("Compiler: !AS!/Comp_file: !AS!/Comp_opt:  !AS!/Link_opt:  !AS",compiler, -
  comp_file, comp_opt, link_opt)
$ wso f$fao("Link_file2: !AS", link_file2)
$ if (.not.(batch_mode)) then goto 23024
$ wso "Batch Mode"
$ goto 23025
$ 23024: 
$ wso "Interactive"
$ 23025: 
$ 23022: 
$ comma_pos = f$locate(",", comp_file)
$ plus_pos = f$locate("+", comp_file)
$ len = f$length(comp_file)
$ both = (comma_pos .ne. len) .and. (plus_pos .ne. len)
$ if (.not.(both)) then goto 23026
$ wso "%COMPILE-F-BADCONCAT, can't use plus and comma file concatenators together"
$ exit (1 .or. (f$verify(verifying) .and. 0))
$ 23026: 
$ cur_dir = f$environment("default")
$ call parse_file_list $$$ 'comp_file' ".obj"
$ link_file = return$value
$ call parse_file_list $$$ 'comp_file' ".obj;*"
$ delete_file = return$value
$ file_name = f$parse(f$element(0, ",", link_file),,, "name")
$ out_file = file_name + ".tmp"
$ log_file = cur_dir + file_name + ".log"
$ if (.not.(f$locate("+", comp_file) .ne. f$length(comp_file))) then goto 23028
$ link_file = f$element(0, ",", link_file)
$ delete_file = f$element(0, ",", delete_file)
$ 23028: 
$ dq[0,8] = 34 
$ ddq = f$extract(0,1,dq)
$ dq = ddq + ddq
$ open/write f 'out_file' 
$ write f "$ ! Batch compile by C. Paul Bond, modified by TKB"
$ write f "$ ! Time: ''f$time()'"
$ write f "$ on control_y then goto the_end"
$ write f "$ on error then goto the_end"
$ write f "$ set def ''cur_dir'" 
$ write f "$ write sys$output ''dq'Compiling ''comp_file' ''dq'"
$ if (.not.(.not. skip_compile)) then goto 23030
$ write f "$ ''compiler'''comp_opt' ''comp_file'"
$ 23030: 
$ if (.not.(.not. do_link)) then goto 23032
$ goto skip_link 
$ 23032: 
$ write f "$ write sys$output ''dq'Linking   ''link_file' ''dq'"
$ if (.not.(c_compile)) then goto 23034
$ write f "$ link ''link_file'''link_opt'''link_file2',sys$input/opt"
$ write f "sys$share:vaxcrtl.exe/share"
$ write f "$! Link with vaxc lib to reduce exe size"
$ goto 23035
$ 23034: 
$ if (.not.(gcc_compile)) then goto 23036
$ write f "$ link ''link_file'''link_opt'''link_file2',sys$input/opt"
$ write f "gnu_cc:[000000]gcclib.olb/lib"
$ write f "gnu_cc:[000000]liberty.olb/lib"
$ write f "sys$share:vaxcrtl.exe/share"
$ write f "$! Link with vaxc lib to reduce exe size"
$ goto 23037
$ 23036: 
$ write f "$ link ''link_file'''link_opt'''link_file2'"
$ 23037: 
$ 23035: 
$ exe_file = f$parse (".exe", link_file,,, "SYNTAX_ONLY")
$ if (.not.(setdebug_opt)) then goto 23038
$ write f "$ setdebug ", exe_file, " 0"
$ 23038: 
$ if (.not.(do_run)) then goto 23040
$ if (.not.(run_args .eqs. "")) then goto 23042
$ write f "$ run ", do_run_debug, " ", exe_file
$ goto 23043
$ 23042: 
$ write f "$ cmd :== $", exe_file
$ write f "$ cmd ", run_args
$ 23043: 
$ 23040: 
$ if (.not.(del_obj)) then goto 23044
$ write f "$ delete/nolog ''delete_file'"
$ 23044: 
$ skip_link:
$ write f "$ !"
$ write f "$ the_end:"
$ if (.not.(del_com)) then goto 23046
$ write f "$ delete/nolog ''out_file';*"
$ goto 23047
$ 23046: 
$ write sys$error "Temporary command ", out_file, " not deleted"
$ 23047: 
$ write f "$ !"
$ close f
$ if (.not.(batch_mode)) then goto 23048
$ com_line = "submit/noprint/notify/log=" + log_file + queue_opt + batch_opt -
  + " " + out_file
$ goto 23049
$ 23048: 
$ com_line = "@" + out_file
$ 23049: 
$ if (.not.(.not. debug)) then goto 23050
$ 'com_line' ! 'f$verify(verifying)'
$ verifying = 'f$verify(f$type(compiler_verify) .nes. "")'
$ goto 23051
$ 23050: 
$ wso "com_line: ", com_line
$ 23051: 
$ The_End:
$ exit (1 .or. (f$verify(verifying) .and. 0))
$ OPT$arg:
$ goto usage
$ p = f$locate("=", opt)
$ l = f$length(opt)
$ if (.not.(p .ne. l)) then goto 23052
$ args = f$extract(p+1, l, opt)
$ 23052: 
$ return
$ OPT$bat:
$ batch_mode = TRUE
$ p = f$locate("=", opt)
$ l = f$length(opt)
$ if (.not.(p .ne. l)) then goto 23054
$ batch_opt = batch_opt + f$extract(p+1, l, opt)
$ 23054: 
$ return
$ OPT$ccl:
$ if (.not.(f$locate("~", opt) .ne. f$length(opt))) then goto 23056
$ c_compile = FALSE
$ 23056: 
$ gcc_compile = FALSE 
$ return
$ check_age = TRUE
$ return
$ OPT$com:
$ del_com = FALSE
$ return
$ OPT$cmp:
$ p = f$locate("=", opt)
$ l = f$length(opt)
$ if (.not.(p .ne. l)) then goto 23058
$ comp_opt = comp_opt + f$extract (p + 1, l, opt)
$ 23058: 
$ return
$ OPT$deb:
$ comp_opt = comp_opt + "/debug"
$ if (.not.(gcc_compile)) then goto 23060
$ comp_opt = comp_opt + "/noopt"
$ 23060: 
$ link_opt = link_opt + "/debug"
$ return
$ OPT$rnd:
$ do_run = TRUE
$ do_run_debug = "/nodebug"
$ return
$ OPT$run:
$ do_run = TRUE
$ p = f$locate ("=", opt)
$ l = f$length (opt)
$ if (.not.(p .ne. l)) then goto 23062
$ run_args = f$extract (p + 1, l, opt)
$ 23062: 
$ if (.not.(f$extract (0, 1, run_args) .eqs. """")) then goto 23064
$ run_args = f$extract (1, -1, run_args)
$ 23064: 
$ p = f$length (run_args)
$ if (.not.(f$extract (p - 1, 1, run_args) .eqs. """")) then goto 23066
$ run_args = f$extract (0, p - 1, run_args)
$ 23066: 
$ return 
$ OPT$hel:
$ goto usage
$ OPT$lin:
$ if (.not.(f$locate("~", opt) .ne. f$length(opt))) then goto 23068
$ do_link = FALSE
$ return
$ 23068: 
$ p = f$locate("=", opt)
$ l = f$length(opt)
$ if (.not.(p .ne. l)) then goto 23070
$ link_file2 = link_file2 + "," + f$extract(p + 1, l, opt)
$ 23070: 
$ return
$ OPT$lis:
$ comp_opt = comp_opt + "/list"
$ p = f$locate("=", opt)
$ l = f$length(opt)
$ if (.not.(p .ne. l)) then goto 23072
$ comp_opt = comp_opt + f$extract(p, l, opt)
$ 23072: 
$ return
$ OPT$map:
$ link_opt = link_opt - "/nomap" + "/map"
$ return
$ OPT$lnk:
$ p = f$locate("=", opt)
$ l = f$length(opt)
$ if (.not.(p .ne. l)) then goto 23074
$ link_opt = link_opt + f$extract (p + 1, l, opt)
$ 23074: 
$ return
$ OPT$obj:
$ if (.not.(f$locate("~", opt) .ne. f$length(opt))) then goto 23076
$ del_obj = TRUE
$ goto 23077
$ 23076: 
$ del_obj = FALSE
$ 23077: 
$ return
$ OPT$que:
$ p = f$locate("=", opt)
$ l = f$length(opt)
$ if (.not.(p .ne. l)) then goto 23078
$ queue_opt = "/queue=" + f$extract(p + 1, l, opt)
$ 23078: 
$ return 
$ OPT$set:
$ if (.not.(f$locate("~",opt) .ne. f$length(opt))) then goto 23080
$ setdebug_opt = FALSE
$ goto 23081
$ 23080: 
$ setdebug_opt = TRUE
$ 23081: 
$ return
$ OPT$sho:
$ gosub define_compilers
$ i = 0
$ max_len = 0
$ 23082: 
$ element = f$element (i, "/", compiler_defs)
$ if (.not.(element .eqs. "/")) then goto 23085
$ goto 23084
$ 23085: 
$ compiler = f$element (0, "~", element)
$ interactive = f$element (1, "~", element) - "*"
$ batch = f$element (2, "~", element) - "*"
$ if (.not.(f$length (interactive) .gt. max_length)) then goto 23087
$ max_length = f$length (interactive)
$ 23087: 
$ if (.not.(f$length (batch) .gt. max_length)) then goto 23089
$ max_length = f$length (batch)
$ 23089: 
$ 23083: goto 23082
$ 23084: 
$ i = 0
$ 23091: 
$ element = f$element (i, "/", compiler_defs)
$ if (.not.(element .eqs. "/")) then goto 23094
$ goto 23093
$ 23094: 
$ compiler = f$element (0, "~", element)
$ interactive = f$element (1, "~", element) - "*"
$ batch = f$element (2, "~", element) - "*"
$ if (.not.(f$type ('interactive') .nes. "")) then goto 23096
$ show sym 'interactive'
$ 23096: 
$ if (.not.(f$type ('batch') .nes. "")) then goto 23098
$ show sym 'batch'
$ 23098: 
$ i = i + 1
$ 23092: goto 23091
$ 23093: 
$ exit (1 .or. (f$verify(verifying) .and. 0))
$ OPT$ski:
$ skip_compile = TRUE
$ return
$ OPT$tes:
$ if (.not.(f$locate("~", opt) .ne. f$length(opt))) then goto 23100
$ debug = FALSE
$ goto 23101
$ 23100: 
$ debug = TRUE
$ 23101: 
$ return
$ define_compilers:
$ compiler_defs = "basic~cb*asic~bb*asic/cc~ccc~bcc/gcc~ccg~bcg/" + "cobol~cco*bol~bco*bol/fortran~cf*ortran~bf*ortran/" -
  + "macro~cm*acro~bm*acro/pascal~cp*ascal~bp*ascal/" + "sdcl~cs*dcl~bs*dcl"
$ return 
$ comp_file_setup:
$ if (.not.(f$trnlnm ("COMPILER_FILE") .eqs. "")) then goto 23102
$ proc = f$environment ("PROCEDURE")
$ proc = f$parse (";", proc,,) 
$ define compiler_file 'proc'
$ 23102: 
$ if (.not.(p2 .eqs. "-OBJ~")) then goto 23104
$ del_obj_opt = " -obj~ "
$ goto 23105
$ 23104: 
$ del_obj_opt = ""
$ 23105: 
$ gosub define_compilers
$ i = 0
$ 23106: 
$ element = f$element (i, "/", compiler_defs)
$ if (.not.(element .eqs. "/")) then goto 23109
$ goto 23108
$ 23109: 
$ compiler = f$element (0, "~", element)
$ interactive = f$element (1, "~", element)
$ batch = f$element (2, "~", element)
$ 'interactive :== @compiler_file 'compiler 'del_obj_opt
$ 'batch :== @compiler_file 'compiler 'del_obj_opt -batch
$ i = i + 1
$ 23107: goto 23106
$ 23108: 
$ exit (1 .or. (f$verify(verifying) .and. 0))
$ !@> parse_file_list - given list of files, returns file NAMES.
$ parse_file_list:
$ subroutine
$ ignore = p1 
$ file_list = p2
$ file_type = p3
$ name_list = ""
$ 23111: 
$ comma_pos = f$locate(",", file_list)
$ plus_pos = f$locate("+", file_list)
$ len = f$length(file_list)
$ if (.not.(comma_pos .lt. plus_pos)) then goto 23114
$ p = comma_pos
$ goto 23115
$ 23114: 
$ p = plus_pos
$ 23115: 
$ done = (p .eq. len)
$ name_list = name_list + f$parse( f$extract( 0, p, file_list), , , "name") -
  + file_type + "," 
$ file_list = f$extract(p + 1, len, file_list)
$ 23112: if (.not. done) then goto 23111
$ 23113: 
$ return$value == f$extract(0, f$length(name_list) - 1, name_list)
$ endsubroutine 
$ usage:
$ copy sys$input sys$error
 usage: command [-option...] [filespec]

 Where command is the command used to invoke the command procedure,
 [] indicates an optional item, and ... indicates a repeatable item.
 See the initialization section at the end of this com file for a list
 of the commands and what they do.

 Parameters:
    filespec => one or more file specifications, seperated by commas
                or plus signs.  DO NOT include the file type in these
                file specifications.  If you concate files using commas,
                you CANNOT use plus signs to concate, and vice versa.

 Valid Options:       
    -batch[=options]         Submit to batch
    -cclink[~]               Prevents linking with the c sharable library
    -cmp="options"           Add compiler options
    -com                     Keep the temporary command file
    -debug                   Compile and link with debug switch
    -h, -?, or -help         Display this message.
    -link[~][=filespec,...]  Link with these object files 
         [~]                 Don't link
    -list[=filespec]         Make listing (doesn't work with gcc)
    -lnk="options"           Add linker options
    -map                     Produce a map on link step
    -object[~]               Don't delete the object files
                             [delete object files]
    -queue=batchqueue        Submit on this batch queue
    -rnd                     Run the resulting executable with /NODEBUG
    -run[=args]              Run the resulting executable, optional with
                             arguments  (Quote multiple args: ="a b c")
    -setdebug                Turn off debug flag of executable
    -show                    Show the define DCL symbols for invoking
                             this program
    -skip                    Skip compiling, just link
    -test[~]                 turns on/off debug output for this program.

$ write sys$error "Set this up by doing @", f$env ("PROCEDURE"), " INITIALIZE"
$ exit (2 .or. inhibit_message .or. (f$verify(verifying) .and. 0))
