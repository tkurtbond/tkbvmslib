!----------------------------------------------------------------------
! 
! Program:   	DCLSUBSTITUE.BAS
! Written By:	Thomas Kurt Bond
! Version:	1.0
! Date:		19 Jan 1990
!
! Description:	
!
!     This program reads a text file and copies it to an output file.  If it 
! finds a pair of tildes, it tries to translate the text between them as a 
! DCL symbol; if it can, it substitutes the value of the symbol in the output
! instead of the ~<symbol>~; if it can't, it substitutes the null string.
! By default, it takes its input from the terminal and writes its output to the
! terminal.  You can specify input and output files with the /INPUT and /OUTPUT
! qualifiers.  This program must be set up as foreign command symbol:
!         $ DCLSUB == "$DEV:[DIR]DCLSUBSTITUTE"
!
! History:
! Ver     When    Who  What
! 1.0     011990  tkb  Initial Version
!----------------------------------------------------------------------
!> DCLSUBSTITUTE.BAS - Substitute values for DCL symbols in text
program dclsubstitue
    option type = explicit, constant type = integer, size = integer long 

    external string function SubstituteDclSymbols(string)

    external integer function cli$present(string)
    external sub cli$get_value(string, string)
    external string function utl_switch(string, string, long, string dim())

    declare integer constant TRUE = -1, FALSE = not TRUE
    declare integer constant ENDFILEDEV = 11

    declare integer &
        InF, OutF
    declare string &
        InFName, OutFName, InLine, OutLine
    declare string &
        CommandLine, Switches, SwitchesResults(2), junk
    declare long &
        SwitchesBits

    set no prompt
    !	       0        1
    Switches = "I\NPUT=,O\UTPUT="
    SwitchesBits = 0
    
    !Set up input and output files
    InF = 0
    InFName = "(standard input)"
    OutF = 0
    OutFName = "(standard output)"

    call lib$get_foreign(CommandLine)
    if len(CommandLine) then
        junk = utl_switch(CommandLine, Switches, &
	    SwitchesBits, SwitchesResults())
	if SwitchesBits < 0 then
	    print "?DCLSUBS: invalid command qualifier"; BEL
	    goto error_end
	end if
	if SwitchesBits and 1 then
	    InFName = SwitchesResults(1)
	    InF = 1
	    when error in 
		open InFName for input as #InF, access read 
	    use
		print "?DCLSUB: unable to open file for input: "; &
		    InFName; BEL
		continue Error_End
	    end when
	end if
	nomargin #InF
	if SwitchesBits and 2 then
	    OutFName = SwitchesResults(2)
	    OutF = 2
	    when error in 
		open OutFName for output as #OutF
	    use
		print "?DCLSUB: unable to open file for output: "; &
		    OutFName; BEL
		continue Error_End
	    end when
	end if
	nomargin #OutF
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
	OutLine = SubstituteDclSymbols(InLine)
	print #OutF, OutLine
    next
End_Read_Loop:
    exit program 1

Error_End:				!here for error exit
    exit program 2
    
end program ! dclsubstitue



function string SubstituteDclSymbols(string s)
    option type = explicit, constant type = integer, size = integer long 
    external integer function XPos(string, string, integer)
    external long function lib$get_symbol(string, string)
    declare string res, sym, trans
    declare integer start, p ,p2, slen

    res = ""
    start = 1
    slen = len(s)
    p = xpos(s, "~", start)
    res = res + seg$(s, start, p - 1)
    while p < slen + 1
	p2 = xpos(s, "~", p + 1)	!find end of quoted section
	sym = seg$(s, p+1, p2-1)
	if lib$get_symbol(sym, trans) and 1 then
	    res = res + trans		!substitute translation of symbol
	end if
	start = p2 + 1
	p = xpos(s, "~", start)
	res = res + seg$(s, start, p - 1)
    next
    exit function res
end function ! SubstituteDclSymbols


!> XPos -- like basic built-in POS, but returns string length + 1 if not found.
function integer XPos(string s, t, integer start)
    option type = explicit, constant type = integer
    declare integer res

    res = pos(s, t, start)
    if res = 0 then
        res = len(s) + 1
    end if

    exit function res
end function



