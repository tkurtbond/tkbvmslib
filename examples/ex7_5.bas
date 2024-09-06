program display_example
    option type = explicit, constant type = integer, &
        size = integer long, size = real double 
    
!+
! This routine creates a virtual display and writes it to the PASTEBOARD.
! Data is placed in the virtual display using the routine SMG$PUT_CHARS.
! Include the SMG definitions. In particular, we want SMG$M_BORDER.
!-
        %include '$SMGDEF' %from %library 'SYS$LIBRARY:BASIC$STARLET'
	%include 'SMG$ROUTINES' %from %library 'SYS$LIBRARY:BASIC$STARLET'
	%include 'OTS$ROUTINES' %from %library 'SYS$LIBRARY:BASIC$STARLET'
        declare long display1, paste1, keyboard1, rows, columns, term_char
        declare string text
        declare string text_output
	declare long istatus
!+
! Create the virtual display with a border.
!-
        ROWS = 7
        COLUMNS = 60

        ISTATUS = SMG$CREATE_VIRTUAL_DISPLAY &
	    (ROWS, COLUMNS, DISPLAY1, SMG$M_BORDER)
!+
! Create the pasteboard.
!-
        ISTATUS = SMG$CREATE_PASTEBOARD (PASTE1)
!+
! Create a virtual keyboard.
!-
        ISTATUS = SMG$CREATE_VIRTUAL_KEYBOARD (KEYBOARD1)
!+
! Paste the virtual display at row 3, column 9.
!-
        ISTATUS = SMG$PASTE_VIRTUAL_DISPLAY (DISPLAY1, PASTE1, 3, 9)

        ISTATUS = SMG$PUT_LINE (DISPLAY1, &
	    'Enter the character K after the >> prompt.')
        ISTATUS = SMG$PUT_LINE (DISPLAY1, &
 	    'This character will not be echoed as you type it.')
        ISTATUS = SMG$PUT_LINE (DISPLAY1, &
	    'The terminal character equivalent of K is displayed.')
        ISTATUS = SMG$PUT_LINE (DISPLAY1, ' ')
!+
! Read a keystroke from the virtual pasteboard.
!-
        ISTATUS = SMG$READ_KEYSTROKE (KEYBOARD1, TERM_CHAR, '>>', , DISPLAY1)

        ISTATUS = SMG$PUT_LINE (DISPLAY1, ' ')
!+
! Convert the decimal value of TERM_CHAR to a decimal ASCII text string.
!-
        ISTATUS = OTS$CVT_L_TI( TERM_CHAR, TEXT)

        TEXT_OUTPUT = ' TERMINAL CHARACTER IS: ' + TEXT
!+
! Print the decimal ASCII text string.
!-
        ISTATUS = SMG$PUT_LINE (DISPLAY1, TEXT_OUTPUT)
        ISTATUS = SMG$PUT_CHARS (DISPLAY1, TEXT, 7, 25)

END program ! display_example
