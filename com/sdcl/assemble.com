$ verifying = 'f$verify(f$type(assemble_verify) .nes. "")'
$ !> ASSEMBLE.SDCL -- Easy assembly and linking of MACRO programs.
$ inqn := inquire/nopun 
$ wso := write sys$output
$ true = (1 .eq. 1) 
$ false = (1 .eq. 2)
$ testing = false 
$ if (.not.(f$locate("/",p2) .eq. 0 )) then goto 23000
$ asm_type = p1 + p2
$ asm_file = p3
$ goto 23001
$ 23000: 
$ asm_type = p1
$ asm_file = p2
$ 23001: 
$ if (.not.(testing)) then goto 23002
$ wso "Original Asm_type ''asm_type'"
$ wso "Original Asm_file ''asm_file'"
$ 23002: 
$ asm_lib = ""
$ link_lib = ""
$ plus_pos = f$locate("+",asm_file)
$ 23004: if (.not.(plus_pos .ne. f$length(asm_file))) then goto 23005
$ lib_pos = f$locate("/LIB", asm_file)
$ temp = f$extract(plus_pos, lib_pos - plus_pos + 4, asm_file)
$ asm_lib = asm_lib + temp
$ asm_file = asm_file - temp
$ plus_pos = f$locate("+", asm_file)
$ goto 23004
$ 23005: 
$ if (.not.(testing)) then goto 23006
$ wso "Original Asm_lib ''asm_lib'"
$ 23006: 
$ angle_o = f$locate(">", asm_file)
$ if (.not.(angle_o .ne. f$length(asm_file))) then goto 23008
$ angle_e = f$locate("<", asm_file)
$ temp = f$extract(angle_o,angle_e - angle_o + 1, asm_file)
$ asm_file = asm_file - temp
$ link_lib = link_lib + "," + temp - ">" - "<"
$ 23008: 
$ if (.not.(testing)) then goto 23010
$ wso "Original Link_lib ''link_lib'"
$ 23010: 
$ 23012: 
$ pos = f$locate("/", asm_file)
$ length = f$length(asm_file)
$ if (.not.(pos .ne. length)) then goto 23015
$ asm_type = asm_type + f$extract(pos, length, asm_file)
$ asm_file = f$extract(0, pos, asm_file)
$ 23015: 
$ if (.not.(asm_file .eqs. "")) then goto 23017
$ asm_file = f$trnlnm("EDIT_FILE")
$ 23017: 
$ if (.not.(asm_file .eqs. "")) then goto 23019
$ inqn asm_file "File to Assemble > "
$ 23019: 
$ if (.not.(asm_file .eqs. "")) then goto 23021
$ exit (1 .or. (f$verify(verifying) .and. 0))
$ 23021: 
$ 23013: if (f$locate("/", asm_file) .ne. f$length(asm_file)) then goto 23012
$ 23014: 
$ cur_dir = f$directory()
$ name = f$parse(asm_file,,,"NAME")
$ log_file = cur_dir + name + ".log"
$ out_file = name + ".com"
$ asm_opt = ""
$ link_opt = ""
$ length = f$length(asm_type)
$ if (.not.(length .ne. f$locate("/LIS", asm_type))) then goto 23023
$ asm_opt = asm_opt + "/LIST"
$ 23023: 
$ if (.not.(length .ne. f$locate("/DEB", asm_type))) then goto 23025
$ asm_opt = asm_opt + "/DEBUG"
$ link_opt = link_opt + "/DEBUG"
$ 23025: 
$ link_opt = link_opt + "/NOMAP"
$ batch_mode = (length .ne. f$locate("/BAT", asm_type))
$ if (.not.(.not. f$locate("ASM", asm_type) .ne. length)) then goto 23027
$ asm_lib = asm_lib + "+''f$trnlnm("lib_dir")'iomac/lib"
$ link_lib = link_lib + ",''f$trnlnm("lib_dir")'iomod"
$ 23027: 
$ open/write f 'out_file'
$ write f "$! Batch Assemble by T.K. Bond"
$ write f "$! ''f$time()'"
$ write f "$ on control_y then goto the_end"
$ write f "$ on error then goto the_end"
$ write f "$ set def ''cur_dir'"
$ write f "$ write sys$output ""Assembling ''asm_file'"" "
$ write f "$ macro''asm_opt' ''asm_file'.mar''asm_lib'"
$ write f "$ if f$search(""''asm_file.OBJ"") .eqs. """" then goto the_end"
$ write f "$ write sys$output ""Linking ''asm_file'"" "
$ write f "$ link''link_opt' ''asm_file'.OBJ''link_lib'"
$ write f "$ delete/nolog ''asm_file'.OBJ;*"
$ write f "$!"
$ write f "$ the_end:"
$ write f "$ delete/nolog ''out_file';*"
$ write f "$!"
$ close f
$ if (.not.(.not. batch_mode)) then goto 23029
$ asm_line = "@" + out_file
$ goto 23030
$ 23029: 
$ asm_line = "submit/noprint/notify/log=" + log_file + " " + out_file
$ 23030: 
$ if (.not.(.not. testing)) then goto 23031
$ 'asm_line'
$ goto 23032
$ 23031: 
$ wso "Asm_file ''asm_file'"
$ wso "Asm_opt  ''asm_opt'"
$ wso "Asm_lib  ''asm_lib'"
$ wso "Link_opt ''link_opt'"
$ wso "Link_lib ''link_lib'"
$ wso "Asm_line ''asm_line'"
$ 23032: 
$ the_end:
$ exit (1 .or. (f$verify(verifying) .and. 0))
