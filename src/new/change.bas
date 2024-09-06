!------------------------------------------------------------------------------
!> CHANGE.BAS -- Change case of file to upper or lower, ignoring quoted areas 
!
! Quotes are ', ", and exclamation and a quoted area
! extends from a quote to a matching quote (the same character as
! started the quote) or to the end of a line.
!
! By default, this program changes unquoted areas to upper case.  If the user
! specifies the qualifier `/LOWER' it changes unquoted areas to lower case.
!
! This program used the CLI Definitions in CHANGE_CLI.CLD.  The object file 
! created from that file should be linked with the object file from this 
! file to create an executable.
!
! Format:
! 	CHANGE [/qualifier] [input-file] [output-file]
! Parameters:
! 	input-file	file to take input from; SYS$INPUT if not specified
!	output-file	file to write output to; SYS$OUTPUT if not specified
! Qualifiers:
! 	/LOWER		change unquoted areas to lower case
!	/UPPER		change unquoted areas to upper case (default)
!------------------------------------------------------------------------------
program change_case
    option type = explicit, constant type = integer

    external string function ChangeCaseWithQuotes(string, string, string)

    external long function &
        cli$present(string), &
        cli$get_value(string, string), &
        cli$dcl_parse, &
	lib$get_foreign (string), & 
	lib$get_input
    
    external long constant change_cli

    declare integer constant TRUE = -1, FALSE = not TRUE
    declare integer constant ENDFILEDEV = 11

    declare integer &
        InF, OutF
    declare string &
        command_line
    declare string &
        InFName, OutFName, InLine, OutLine
    declare string &
        ToString, FromString
    declare long status_code

    call lib$get_foreign (command_line)
    status_code = cli$dcl_parse ("CHANGE " + COMMAND_LINE, &
                                 change_cli by value, &
				 loc (lib$get_input) by value, &
				 loc (lib$get_input) by value, &
				 "Change> ")

    if (status_code and 1) = 0 then
        print "Unparsed command line, exiting."
	exit program status_code
    end if

    !Set up input and output files
    InF = 0
    InFName = "(standard input)"
    OutF = 0
    OutFName = "(standard output)"
    if cli$present("INPUT") and 1 then
        call cli$get_value("INPUT", InFName)
	InF = 1
	when error in 
	    open InFName for input as #InF, access read 
	use
	    print "change: unable to open file for input: "; InFName
	    continue Error_End
	end when
    end if
    nomargin #InF
    if cli$present("OUTPUT") and 1 then
        call cli$get_value("OUTPUT", OutFName)
	OutF = 2
	when error in 
	    open OutFName for output as #OutF
	use
	    print "change: unable to open file for output: "; OutFName
	    continue Error_End
	end when
    end if
    nomargin #OutF

    !Set up case change
    if cli$present("LOWER") and 1 then	!/LOWER only if specified
        FromString = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	ToString   = "abcdefghijklmnopqrstuvwxyz"
    else				!/UPPER is default
        FromString = "abcdefghijklmnopqrstuvwxyz"
	ToString   = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    end if

Read_Loop:
    while TRUE				!exit only on end of file
        when error in 
            linput #InF, InLine
	use
	    if err = ENDFILEDEV then
	        continue End_Read_Loop
	    else
	        exit handler		!Ooops, use default handling
	    end if
	end when
	OutLine = ChangeCaseWithQuotes(InLine, FromString, ToString)
	print #OutF, OutLine
    next
End_Read_Loop:
    exit program 1

Error_End:				!here for error exit
    exit program 2
    
end program ! change_case 



!> ChangeCaseWithQuotes -- Change case, ignoring quoted areas
! actually more general than name implies, as it maps characters in `s' that
! are in `FromString' to the character in the same position in `ToString'.
function string ChangeCaseWithQuotes(string s, FromString, ToString)
    option type = explicit, constant type = integer
    external integer function XPos(string, string, integer)
    external string function str$translate(string, string, string)
    declare string res, quote
    declare integer start, p ,p2, slen

    res = ""
    start = 1
    slen = len(s)
    p = min(xpos(s, "'", start), min(xpos(s, '"', start), xpos(s, "!", start)))
    res = res + str$translate(seg$(s, start, p - 1), ToString, FromString)
    while p < slen + 1
        quote = mid(s, p, 1)
	p2 = xpos(s, quote, p + 1)	!find end of quoted section
	res = res + seg$(s, p, p2)	!copy it unchanged
	start = p2 + 1
	p = min(xpos(s, "'", start), min(xpos(s, '"', start), &
	    xpos(s, "!", start)))
	res = res + str$translate(seg$(s, start, p - 1), ToString, FromString)
    next
    exit function res
end function !ChangeCaseWithQuotes


!> XPos -- like basic built-in POS, but returns string length + 1 if not found.
! makes algorithm in ChangeCaseWithQuotes much easier.
function integer XPos(string s, t, integer start)
    option type = explicit, constant type = integer
    declare integer res

    res = pos(s, t, start)
    if res = 0 then
        res = len(s) + 1
    end if

    exit function res
end function



