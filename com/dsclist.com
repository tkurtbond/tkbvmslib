$ !> DSCLIST.COM -- List a .DSC file or files.
$ verifying = 'f$verify(f$type(dsclist_verify) .nes. "")'
$ wso :== write sys$output
$ wse :== write sys$error
$ false = (1 .eq. 0)
$ true = (1 .eq. 1)
$ format = "BRIEF"
$ outfile_specified = false
$ outfile = ""
$ verbose = false
$ debugging = false
$ i = 1
$ 23000: if (.not.(f$extract (0, 1, p'i') .eqs. "-")) then goto 23002
$ opt = p'i'
$ if (.not.(opt .eqs. "-DOUBLE")) then goto 23003
$ format = "DOUBLE"
$ goto 23004
$ 23003: 
$ if (.not.(opt .eqs. "-FULL")) then goto 23005
$ format = "FULL"
$ goto 23006
$ 23005: 
$ if (.not.(opt .eqs. "-BRIEF")) then goto 23007
$ format = "BRIEF"
$ goto 23008
$ 23007: 
$ if (.not.((opt .eqs. "-VERBOSE") .or. (opt .eqs. "-V"))) then goto 23009
$ verbose = true
$ goto 23010
$ 23009: 
$ if (.not.(opt .eqs. "-DEBUG")) then goto 23011
$ debugging = true
$ goto 23012
$ 23011: 
$ if (.not.(opt .eqs. "-O")) then goto 23013
$ outfile_specified = true
$ i = i + 1
$ outfile = p'i'
$ goto 23014
$ 23013: 
$ wse "dsclist: Unknown option: ", opt
$ goto usage
$ 23014: 
$ 23012: 
$ 23010: 
$ 23008: 
$ 23006: 
$ 23004: 
$ 23001: i = i + 1
$ goto 23000
$ 23002: 
$ fmt_type = f$extract (0,1,format)
$ filespec = p'i'
$ filespec = f$parse (filespec, ".DSC",,, "SYNTAX_ONLY")
$ if (.not.(verbose)) then goto 23015
$ wso "dsclist: original filespec: ", filespec
$ 23015: 
$ pid = f$getjpi ("", "PID")
$ old_filename = ""
$ i = 0
$ $:
$ 23017: 
$ filename = f$search (filespec)
$ if (.not.((i .eq. 0) .and. (filename .eqs. ""))) then goto 23020
$ wse "dsclist: Filespec ", filespec, " not matched, exiting."
$ goto 23019
$ 23020: 
$ if (.not.((old_filename .eqs. filename) .or. - ((i .gt. 0) .and. (filename -
  .eqs. "")))) then goto 23022
$ if (.not.(verbose)) then goto 23024
$ wso "dsclist: ", i, " files processed, exiting." 
$ 23024: 
$ goto 23019
$ 23022: 
$ i = i + 1
$ if (.not.(verbose)) then goto 23026
$ wso "dsclist: file ", i, ", name: ", filename
$ 23026: 
$ if (.not.(filename .eqs. "")) then goto 23028
$ goto 23019
$ 23028: 
$ old_filename = filename
$ if (.not.(.not. outfile_specified)) then goto 23030
$ name = f$parse (filename,,, "NAME") 
$ outfile = name + "." + fmt_type + "DSC"
$ goto 23031
$ 23030: 
$ if (.not.(outfile_specified .and. (i .gt. 1))) then goto 23032
$ wse "dsclist: -O specified, but multiple files matched, which was probably not intended!"
$ 23032: 
$ 23031: 
$ genprocname = "DSCLST" + f$string (pid) + "_" + f$string (i) + ".tmp"
$ dclsub/input=sys$input/output='genprocname'
$ DECK
$! start of ~genprocname~ for ~filename~
$ delete 'f$environment ("PROCEDURE")'      ! get rid this of temporary file
$ define/user sys$output nla0:
$ describe ~filename~/list

~format~
~outfile~
-1

~name~ ~format~ DSC LIST

$! end of ~genprocname~ for ~filename~
$ EOD
$ if (.not.(debugging)) then goto 23034
$ wse "dsclist: Debugging, so not executing ", genprocname
$ goto 23035
$ 23034: 
$ @'genprocname'
$ 23035: 
$ 23018: goto 23017
$ 23019: 
$ exit (1 .or. (f$verify(verifying) .and. 0))
$ usage:
$ wse "usage: dsclist [-full | -double] <filespec>"
$ wse "where <filespec> resolves to a POISE .DSC file; wildcards allowed."
$ exit (1 .or. (f$verify(verifying) .and. 0))
