$ verifying = 'f$verify(f$type(makecommand_verify) .nes. "")'
$ !> MAKECOMMAND.SDCL -- Make foreign command symbol for a program.
$ i = 1 
$ 23000: if (.not.(f$extract(0, 1, p'i') .eqs. "-")) then goto 23001
$ opt = f$extract(1, 1, p'i')
$ if (.not.(opt .eqs. "C")) then goto 23002
$ command_ext = ".com"
$ command_type = "@"
$ goto 23003
$ 23002: 
$ if (.not.(opt .eqs. "F")) then goto 23004
$ command_ext = ".exe"
$ command_type = "$"
$ goto 23005
$ 23004: 
$ if (.not.((opt .eqs. "H") .or. (opt .eqs. "?"))) then goto 23006
$ goto usage
$ goto 23007
$ 23006: 
$ if (.not.(opt .eqs. "I")) then goto 23008
$ command_ext = ".icx"
$ command_type = "''iconx' "
$ goto 23009
$ 23008: 
$ write sys$error p'i', ": incorrect option"
$ exit (1 .or. (f$verify(verifying) .and. 0))
$ 23009: 
$ 23007: 
$ 23005: 
$ 23003: 
$ i = i + 1
$ goto 23000
$ 23001: 
$ iplus = i + 1
$ program = p'i'
$ command = p'iplus'
$ if (.not.(f$type(command_ext) .eqs. "")) then goto 23010
$ filetype = f$parse (program,,, "TYPE")
$ if (.not.(filetype .eqs. ".COM")) then goto 23012
$ command_ext = ".com"
$ command_type = "@"
$ goto 23013
$ 23012: 
$ if (.not.(filetype .eqs. ".EXE")) then goto 23014
$ command_ext = ".exe"
$ command_type = "$"
$ goto 23015
$ 23014: 
$ if (.not.(filetype .eqs. ".ICX")) then goto 23016
$ command_ext = ".icx"
$ command_type = "''iconx' "
$ goto 23017
$ 23016: 
$ command_ext = ".exe"
$ command_type = "$"
$ 23017: 
$ 23015: 
$ 23013: 
$ 23010: 
$ if (.not.(program .eqs. "")) then goto 23018
$ inquire/nopun program "Program: "
$ 23018: 
$ if (.not.(program .eqs. "")) then goto 23020
$ exit (1 .or. (f$verify(verifying) .and. 0))
$ 23020: 
$ if (.not.(command .eqs. "")) then goto 23022
$ command = f$parse(program, , , "name")
$ 23022: 
$ 23024: 
$ pos = f$locate ("-", command)
$ if (.not.(pos .ge. f$length (command))) then goto 23027
$ goto 23026
$ 23027: 
$ command = f$extract (0, pos, command) + "_" + f$extract (pos + 1, -1, command)
$ 23025: goto 23024
$ 23026: 
$ if (.not.(command .eqs. "")) then goto 23029
$ command = "try"
$ 23029: 
$ 'command' == command_type + f$parse(program, command_ext)
$ goto the_end
$ usage:
$ copy sys$input sys$output
 usage: makecommand [OPTION ...] COMMANDFILE [COMMANDNAME]

 where:
    COMMANDFILE is the file to define as a command.
    COMMANDNAME is the DCL symbol to define as the command.  If not
                specified, it defaults to the same as COMMANDFILE,
                with dashes switched to underscores if present.
    -c          Force the command to execute a DCL command procedure.
    -f          Force the command to be a foreign command (execute
                an executable).
    -h, -?      Display this message and exit.
    -i          Force the command to execute an Icon program (execute
                iconx on an .icx file).
$ the_end:
$ exit (1 .or. (f$verify(verifying) .and. 0))
