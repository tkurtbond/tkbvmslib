100	!
	!----------------------------------------------------------------------!
	!
	!	Program				edit.bas
	!	By				C. Paul Bond
	!	Date				2-28-85
	!
	!   This program is a startup for the system editor edit/edt.
	! This program alows the user to edit the last file he edited
	! without typing the file name.  It also has a /list qualifier
	! that edit/edt dose not have.  This switch alows the user to
	! include a listing (.lis file) into the editor at startup.
	! the listing file has the same name as the current file execpt
	! that the ending is now .lis.  The maner in which the program
	! keeps track of of this is through logicals.  The first logical
	! needed just the make the program run is EDT_COM.  This logical
	! is used to find the exe file and the two edit command files used
	! by this program.  The logical EDIT_FILE keeps track of the last
	! file edited and if the logical is not found then the program
	! prompts for a new file name.
	!----------------------------------------------------------------------!
	! ver    who    date	comment
	! 1.0	 cpb   2-28-85	first wrighting
	! 1.1    cpb  11-04-85	Change so that only on command file is needed.
	!			Test for EDIT_FILE as a file name.
	! 1.2	 cpb   5-20-86	changed directory specification
	! 1.3    tkb   9-13-88  Changed logical names...
	!----------------------------------------------------------------------!

	%page

200	external integer function &
		cli$present(string)

	external sub &
		cli$get_value(string, string), &
		lib$sys_trnlog(string, , string), &
		lib$set_logical(string, string), &
		lib$do_command(string), &
		lib$find_file(string, string, integer)

	declare integer constant &
		true = (1=1), false = not true, debug_ = false

	declare string constant &
		edit_file = "EDIT_FILE" ! logical for remembered file name

	declare string &                          
		command, in_file, out_file, list_file, location, lis_file, &
		temp, id_value

	%page

300	command = "EDIT/EDT"

 !	if cli$present("ID") and 1% then
 !	    call cli$get_value("ID", id_value)
 !	else
 !	    id_value = ""
 !	end if


	!
	!----------------------------------------------------------------------!
	! Get the file name
	!----------------------------------------------------------------------!
	if cli$present("INFILE") and 1% then
	    call cli$get_value("INFILE", in_file)
	    call lib$set_logical("ED_FILE", in_file)
	else
	    call lib$sys_trnlog(EDIT_FILE, , in_file)
	    in_file = edit$(in_file, -1%)
	    if (in_file = "") or (in_file = EDIT_FILE) then 
	        input "File name"; in_file
	        call lib$set_logical(EDIT_FILE, in_file)
	    end if
	end if


	!
	!----------------------------------------------------------------------!
	! Get the output file if needed 
	!----------------------------------------------------------------------!
	if cli$present("OUTPUT") and 1% then
	    call cli$get_value("OUTPUT", out_file)
	    command = command + "/OUTPUT=" + out_file
	end if


	!
	!----------------------------------------------------------------------!
	! Add the recover switch if needed 
	!----------------------------------------------------------------------!
	if cli$present("RECOVER") and 1% then
	    command = command + "/RECOVER"
	end if


	!
	!----------------------------------------------------------------------!
	! If a list option the select correct file 
	!----------------------------------------------------------------------!
	command = command + "/COMMAND=EXE_LIB:ED.EDT"
	if cli$present("LIST") and 1% then
	    call lib$find_file(in_file, temp, 0)
	    if debug_ then print "Temp is "; temp end if
	    lis_file = right$(temp, instr(1%, temp , "]") + 1%)
	    lis_file = left$(lis_file, instr(1%, lis_file, ".")) + "lis"
	    call lib$set_logical("ED_LIST", lis_file)
	    if debug_ then print "List file is "; Lis_file end if
	else
	    call lib$set_logical("ED_LIST", "EXE_LIB:ED.LIST")
	end if



	if in_file = "" then goto the_end end if	! exit if no file

	command = command + " " + in_file	! finish command line

	if debug_ then print command end if

	print "Editing file "; in_file		! tell what we are doing
	call lib$do_command(command)		! do it.

999	the_end:
	end

                                                 
