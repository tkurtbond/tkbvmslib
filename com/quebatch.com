$ verifying = 'f$verify(f$type(quebatch_verify) .nes. "")'
$ inq := inquire/nopun
$ wso := write sys$output
$ true = (1 .eq. 1)
$ false = .not. true
$ debug = false
$ perform_quebatch := $dms:quebatch 
$ if (.not.(debug)) then goto 23000
$ wso f$fao("p1: !AS!/p2: !AS!/p3: !AS!/p4: !AS", p1, p2, p3, p4)
$ 23000: 
$ if (.not.(f$extract(0, 1, p2) .eqs. "/")) then goto 23002
$ file = p3 + p2
$ goto 23003
$ 23002: 
$ file = p2 + p3
$ 23003: 
$ if (.not.(file .eqs. "")) then goto 23004
$ inq file "_File to QueBatch: "
$ 23004: 
$ if (.not.(file .eqs. "")) then goto 23006
$ exit (1 .or. (f$verify(verifying) .and. 0))
$ 23006: 
$ location = f$locate("/", file)
$ if (.not.(location .eq. f$length(file))) then goto 23008
$ options = ""
$ goto 23009
$ 23008: 
$ options = f$extract(location, f$length(file), file)
$ file = f$extract(0, location, file)
$ 23009: 
$ file_type = f$parse(file, , , "type")
$ if (.not.(file_type .eqs. ".")) then goto 23010
$ file = file + ".bcf"
$ 23010: 
$ if (.not.(debug)) then goto 23012
$ wso f$fao("File:    !AS!/Options: !AS", file, options)
$ 23012: 
$ if (.not.(f$locate("/NOS", options) .ne. f$length(options))) then goto 23014
$ submit_option = "/nosubmit"
$ goto 23015
$ 23014: 
$ submit_option = "/submit"
$ 23015: 
$ command = file + "/delete/output/noprinter/replace/queue" + submit_option -
  
$ if (.not.(debug)) then goto 23016
$ wso f$fao("Command: !AS !AS", perform_quebatch, command)
$ goto 23017
$ 23016: 
$ define/user sys$input sys$command 
$ perform_quebatch 'command'
$ 23017: 
$ The_End:
$ exit (1 .or. (f$verify(verifying) .and. 0))
