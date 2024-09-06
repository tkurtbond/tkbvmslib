$ !> TCS.SDCL -- TCS frontend for working w/source files w/TCS files in [.TCS].
$ SS$_BADPARAM = %x0014
$ wso :== write sys$output
$ wse :== write sys$error
$ TRUE = 1 .eq. 1
$ FALSE = 1 .ne. 1
$ QUIET = %x10000000
$ months_jan = "01"
$ months_feb = "02"
$ months_mar = "03"
$ months_apr = "04"
$ months_may = "05"
$ months_jun = "06"
$ months_jul = "07"
$ months_aug = "08"
$ months_sep = "09"
$ months_oct = "10"
$ months_nov = "11"
$ months_dec = "12"
$ debugging = f$type (tcs_debugging) .nes. ""
$ verbose = FALSE
$ nodelete = FALSE
$ diffcmd = "diff" 
$ revision = ""
$ ignoredtypes = ""
$ command = p1
$ if (.not.(command .eqs. "HELP" .or. command .eqs. "-H" .or. command .eqs. -
  "-HELP" .or. command .eqs. "-?")) then goto 23000
$ goto usage
$ 23000: 
$ if (.not.((command .eqs. "") .or. .not. (command .eqs. "ADMIN" .or. command -
  .eqs. "DELTA" .or. command .eqs. "DIFF" .or.  command .eqs. "GET" .or. command -
  .eqs. "INIT" .or. command .eqs. "MV" .or. command .eqs. "OUTDATED" .or. command -
  .eqs. "UNCOVERED"))) then goto 23002
$ wse "tcs: unrecognized TCS command: """, command, """"
$ exit 2
$ 23002: 
$ param_idx = 2
$ num_options = 0
$ outfile = ""
$ 23004: if (.not.(f$extract (0, 1, p'param_idx') .eqs. "-")) then goto 23005
$ opt = p'param_idx'
$ opt_len = f$length (opt)
$ if (.not.(f$extract (0, 2, opt) .eqs. "-O")) then goto 23006
$ outfile = f$extract (2, opt_len, opt)
$ goto 23007
$ 23006: 
$ if (.not.(f$extract (0, 2, opt) .eqs. "-R")) then goto 23008
$ revision = "-r" + f$extract (2, opt_len, opt)
$ goto 23009
$ 23008: 
$ if (.not.(opt .eqs. "-NODELETE")) then goto 23010
$ nodelete = TRUE
$ goto 23011
$ 23010: 
$ if (.not.(opt .eqs. "-STDIFF")) then goto 23012
$ diffcmd = "stdiff"
$ goto 23013
$ 23012: 
$ if (.not.(f$locate ("-IGNORE", opt) .nes. opt_len)) then goto 23014
$ pos = f$locate ("=", opt)
$ if (.not.(pos .nes. opt_len)) then goto 23016
$ ignoredtypes = f$extract (pos + 1, opt_len, opt)
$ goto 23017
$ 23016: 
$ wse "tcs diff: ill formed -IGNORE: ", opt
$ exit SS$_BADPARAM
$ 23017: 
$ goto 23015
$ 23014: 
$ num_options = num_options + 1
$ options_'num_options' = opt
$ 23015: 
$ 23013: 
$ 23011: 
$ 23009: 
$ 23007: 
$ param_idx = param_idx + 1
$ goto 23004
$ 23005: 
$ file1 = p'param_idx' 
$ dirname = f$search ("TCS.DIR")
$ if (.not.(dirname .eqs. "")) then goto 23018
$ create/dir [.TCS]
$ 23018: 
$ tcsfile = "[.tcs]" + file1 + "-TCS" 
$ if (.not.(debugging)) then goto 23020
$ wso "command: ", command, " file1: ", file1, " tcsfile: ", tcsfile
$ wso "outfile: """, outfile, """"
$ 23020: 
$ goto do_'command'
$ wso "tcs: This should be impossible, so somebody screwed up.  Exiting."
$ exit 2 .or. QUIET
$ do_admin:
$ result = f$search (tcsfile)
$ if (.not.(result .nes. "")) then goto 23022
$ wse "tcs: TCS file ", tcsfile, " already exists, exiting."
$ exit 2
$ 23022: 
$ file1 = f$edit (file1, "LOWERCASE")
$ dclcmd = "admin ""-i''file1'"" ''tcsfile'"
$ wso "Executing ", dclcmd
$ define/user sys$input sys$command
$ 'dclcmd'
$ exit
$ do_delta:
$ result = f$search (tcsfile)
$ if (.not.(result .eqs. "")) then goto 23024
$ wse "tcs: TCS file ", tcsfile, " does not exist, exiting."
$ exit 2
$ 23024: 
$ define/user sys$input sys$command
$ delta 'file1' 'tcsfile'
$ exit
$ do_diff:
$ filespec = f$parse (file1) 
$ filename = f$parse (filespec,,, "NAME")
$ filetype = f$parse (filespec,,, "TYPE")
$ histfile = "[.TCS]" + filename + filetype + "-TCS"
$ revfile = "SYS$SCRATCH:" + filename + filetype + "-TMP"
$ write sys$output "histfile: ", histfile, " revfile: ", revfile
$ if (.not.(revision .nes. "")) then goto 23026
$ write sys$output "revision: ", revision
$ 23026: 
$ get 'revision' 'histfile' >'revfile'
$ 'diffcmd' 'revfile' 'filespec'
$ if (.not.(.not. nodelete)) then goto 23028
$ delete/log 'revfile';0
$ goto 23029
$ 23028: 
$ write sys$error "stcsdiff: temporary file ", revfile, " left behind."
$ 23029: 
$ exit
$ do_get:
$ if (.not.(outfile .eqs. "")) then goto 23030
$ get 'revision' 'options_1' 'options_2' 'options_3' 'options_4' 'tcsfile'
$ goto 23031
$ 23030: 
$ get 'revision' 'options_1' 'options_2' 'options_3' 'options_4' 'tcsfile' -
  >'outfile'
$ 23031: 
$ exit
$ do_init:
$ if (.not.(ignoredtypes .nes. "")) then goto 23032
$ ignoredtypes = "," + ignoredtypes
$ 23032: 
$ ignoredtypes_len = f$length (ignoredtypes)
$ tmpfile = "SYS$SCRATCH:INITCHECKIN-" + f$getjpi ("", "PID") + ".TMP"
$ copy sys$input 'tmpfile'
Initial checkin.
.
$ filespec = file1
$ if (.not.(filespec .eqs. "")) then goto 23034
$ filespec = "*.*"
$ 23034: 
$ filespec = f$parse (";0", filespec)
$ 23036: 
$ file = f$search (filespec, 1)
$ if (.not.(verbose)) then goto 23039
$ wse "file: ", file
$ 23039: 
$ if (.not.(file .eqs. filespec)) then goto 23041
$ goto 23038
$ 23041: 
$ if (.not.(file .eqs. "")) then goto 23043
$ goto 23038
$ 23043: 
$ name = f$parse (file,,, "NAME")
$ type = f$parse (file,,, "TYPE")
$ workfile = name + type
$ wse "workfile: ", workfile
$ if (.not.((type .eqs. ".DIR") .or.  (type .eqs. ".EXE") .or. (type .eqs. -
  ".LIS") .or. (type .eqs. ".MAP") .or. (type .eqs. ".OBJ") .or. (type .eqs. -
  ".OLB"))) then goto 23045
$ wse "Skipping ", workfile
$ goto 23037
$ 23045: 
$ skip = "," + (type - ".")
$ if (.not.(debugging)) then goto 23047
$ wse "skip: ", skip, " ignoredtypes: ", ignoredtypes
$ 23047: 
$ if (.not.(f$locate (skip, ignoredtypes) .ne. ignoredtypes_len)) then goto 23049
$ wse "Skipping user specified extension for ", workfile
$ goto 23037
$ 23049: 
$ define/user sys$command 'tmpfile'
$ tcs admin 'workfile'
$ wso "Entered ", workfile
$ 23037: goto 23036
$ 23038: 
$ delete/log 'tmpfile';0
$ exit
$ do_mv:
$ i = param_idx + 1
$ to_file = p'i'
$ from_file = f$parse (";*", file1)
$ to_file = f$parse (";*", to_file)
$ if (.not.(debugging)) then goto 23051
$ wse "from_file: ", from_file, " to_file: ", to_file
$ 23051: 
$ from_tcs_device = f$parse (from_file,,, "DEVICE")
$ from_tcs_directory = f$parse (from_file,,, "DIRECTORY")
$ from_tcs_name = f$parse (from_file,,, "NAME")
$ from_tcs_type = f$parse (from_file,,, "TYPE") + "-TCS"
$ from_tcs_file = from_tcs_device + (from_tcs_directory - "]") + ".TCS]" + -
  from_tcs_name + from_tcs_type + ";*"
$ to_tcs_device = f$parse (to_file,,, "DEVICE")
$ to_tcs_directory = f$parse (to_file,,, "DIRECTORY")
$ to_tcs_name = f$parse (to_file,,, "NAME")
$ to_tcs_type = f$parse (to_file,,, "TYPE") + "-TCS"
$ to_tcs_file = to_tcs_device + (to_tcs_directory - "]") + ".TCS]" + to_tcs_name -
  + to_tcs_type + ";*"
$ if (.not.(debugging)) then goto 23053
$ wse "from_tcs_file: ", from_tcs_file, " to_tcs_file: ", to_tcs_file
$ 23053: 
$ rename 'from_file' 'to_file'/log
$ rename 'from_tcs_file' 'to_tcs_file/log
$ exit
$ do_outdated:
$ filespec = "[.tcs]*.*-tcs"
$ 23055: 
$ tcsfile = f$search (filespec)
$ if (.not.(tcsfile .eqs. "")) then goto 23058
$ goto 23057
$ 23058: 
$ tcsrdt = f$file (tcsfile, "RDT")
$ tcs_day = f$extract (00, 02, tcsrdt)
$ tcs_monname = f$extract (03, 03, tcsrdt)
$ tcs_year = f$extract (07, 04, tcsrdt)
$ tcs_rest = f$extract (11, 12, tcsrdt)
$ tcs_monnum = months_'tcs_monname'
$ tcs_cmpdate = tcs_year + tcs_monnum + tcs_day + tcs_rest
$ if (.not.(debugging .and. verbose)) then goto 23060
$ wso "tcs_cmpdate: ", tcs_cmpdate
$ 23060: 
$ dirname = f$parse (tcsfile,,, "DIRECTORY") - ".TCS]" + "]"
$ filename = f$parse (tcsfile,,, "NAME")
$ filetype = f$parse (tcsfile,,, "TYPE") - "-TCS"
$ srcfile = filename + filetype
$ srcrdt = f$file (srcfile, "RDT")
$ src_day = f$extract (00, 02, srcrdt)
$ src_monname = f$extract (03, 03, srcrdt)
$ src_year = f$extract (07, 04, srcrdt)
$ src_rest = f$extract (11, 12, srcrdt)
$ src_monnum = months_'src_monname'
$ src_cmpdate = src_year + src_monnum + src_day + src_rest
$ if (.not.(debugging .and. verbose)) then goto 23062
$ wso "src_cmpdate: ", src_cmpdate
$ 23062: 
$ if (.not.(src_cmpdate .gts. tcs_cmpdate)) then goto 23064
$ wso srcfile, " is newer than ", tcsfile
$ 23064: 
$ 23056: goto 23055
$ 23057: 
$ exit
$ do_uncovered:
$ i = param_idx + 1
$ if (.not.(ignoredtypes .nes. "")) then goto 23066
$ ignoredtypes = "," + ignoredtypes
$ 23066: 
$ if (.not.(debugging)) then goto 23068
$ wse "ignoredtypes: ", ignoredtypes
$ 23068: 
$ ignoredtypes_len = f$length (ignoredtypes)
$ if (.not.(file1 .eqs. "")) then goto 23070
$ filespec = "*.*"
$ goto 23071
$ 23070: 
$ filespec = file1
$ 23071: 
$ if (.not.(debugging)) then goto 23072
$ wse "filespec: ", filespec
$ 23072: 
$ old_result = ""
$ 23074: 
$ result = f$search (filespec, 1)
$ if (.not.(debugging)) then goto 23077
$ wso "result: ", result
$ 23077: 
$ if (.not.(result .eqs. "")) then goto 23079
$ goto 23076
$ 23079: 
$ if (.not.(result .eqs. old_result)) then goto 23081
$ goto 23076
$ 23081: 
$ old_result = result
$ filename = f$parse (result,,, "NAME")
$ filetype = f$parse (result,,, "TYPE")
$ file = filename + filetype 
$ if (.not.(filetype .eqs. ".DIR")) then goto 23083
$ goto 23075
$ 23083: 
$ skip = "," + (filetype - ".")
$ if (.not.(debugging)) then goto 23085
$ wse "skip: ", skip, " ignoredtypes: ", ignoredtypes
$ 23085: 
$ if (.not.(f$locate (skip, ignoredtypes) .ne. ignoredtypes_len)) then goto 23087
$ if (.not.(debugging)) then goto 23089
$ wse "Skipping ", file
$ 23089: 
$ goto 23075
$ 23087: 
$ tcsfile = "[.TCS]" + file + "-TCS"
$ if (.not.(f$search (tcsfile) .eqs. "")) then goto 23091
$ if (.not.(verbose)) then goto 23093
$ wso file, " does not have a ", tcsfile
$ goto 23094
$ 23093: 
$ wso file
$ 23094: 
$ 23091: 
$ 23075: goto 23074
$ 23076: 
$ exit
$ usage:
$ copy sys$input sys$output
TCS frontend for working with source files with associated TCS files in
a [.TCS] directory.

usage:
tcs [ help | -h | -help | -? ]
      Output this help message.

tcs admin FILE

      Initialize TCS file [.TCS]FILE-TCS from FILE.

tcs delta FILE

      Add a new version to TCS file [.TCS]FILE from FILE.

tcs diff [-nodelete] [-rM.N] [-stdiff] FILE

      Compare FILE to a revision from corresponding TCS file, defaulting
      to the most recent.

      -nodelete      Don't delete the temporary file extracted from the
                     TCS file.

      -rM.M          Compare to revision M.N instead of the most recent.

      -stdiff        Use SWTOOLS VOS diff instead of VMS diff.

tcs get [-oOUTFILE] [-h] [-rM.N] FILE

      Get a revision of FILE from TCS file [.TCS]FILE-TCS

          -oOUTFILE  writes the output to OUTFILE.
                     If -o is not specifed the output goes to standard output.

          -h         Output history information instead of a revision.

          -rM.N      Output revision M.N.

tcs init -ignored=IGNOREDTYPES [FILESPEC]
 
      Put files in the current directory under TCS revision control.  If
      FILESPEC is specified it should be a wildcard and only files
      matching the wildard will be put in TCS revision control

      If IGNOREDTYPES is specified it should be a single file type
      (without the ".") or a comma separated list of file types
      to be ignored.

      Note that .DIR, .EXE, .LIS, .MAP, .OBJ, and .OLB files are
      always skipped.

tcs mv FILE NEWFILE

      Move (rename) FILE to NEWFILE and rename its .TCS file as well.

tcs outdated

      List all the source files that are newer than their corresponding
      TCS file in [.TCS].

tcs uncovered [-ignore=IGNOREDTYPES] [FILESPEC]

      List all the files in the current directory that do not have
      corresponding files in [.TCS].

      If FILEPSEC is specified it should be a VMS wildcard that
      will be applied to the current directory for matching.

      If IGNOREDTYPES is specified it should be a single file type
      (without the ".") or a comma separated list of file types
      to be ignored.
$ exit 2 .or. QUIET
