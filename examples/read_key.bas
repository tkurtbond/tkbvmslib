1       OPTION TYPE=EXPLICIT
        ! from: https://docs.vmssoftware.com/vsi-openvms-rtl-screen-management-smg-manual/#smg_examples_section

        !+
        ! This routine demonstrates the use of SMG$READ_KEYSTROKE to read
        ! a keystroke from the terminal.
        !
        ! Build this program using the following commands.
        !
        !$ BASIC READ_KEY
        !$ CREATE SMGDEF.MAR
        !       .TITLE  SMGDEF - Define SMG$ constants
        !       .Ident  /1-000/
        !
        !       $SMGDEF GLOBAL
        !
        !       .END
        !$ MACRO SMGDEF
        !$ LINK READ_KEY,SMGDEF
        !
        !-

        DECLARE LONG KB_ID, RET_STATUS, TERM_CODE, I, TIMER
        EXTERNAL SUB LIB$SIGNAL( LONG BY VALUE )
        EXTERNAL SUB LIB$STOP( LONG BY VALUE )
        EXTERNAL LONG CONSTANT SS$_TIMEOUT
        EXTERNAL LONG CONSTANT SMG$K_TRM_PF1
        EXTERNAL LONG CONSTANT SMG$K_TRM_PERIOD
        EXTERNAL LONG CONSTANT SMG$K_TRM_UP
        EXTERNAL LONG CONSTANT SMG$K_TRM_RIGHT
        EXTERNAL LONG CONSTANT SMG$K_TRM_F6
        EXTERNAL LONG CONSTANT SMG$K_TRM_F20
        EXTERNAL LONG CONSTANT SMG$K_TRM_FIND
        EXTERNAL LONG CONSTANT SMG$K_TRM_NEXT_SCREEN
        EXTERNAL LONG CONSTANT SMG$K_TRM_TIMEOUT
        EXTERNAL LONG FUNCTION SMG$CREATE_VIRTUAL_KEYBOARD( LONG, STRING )
        EXTERNAL LONG FUNCTION SMG$DELETE_VIRTUAL_KEYBOARD( LONG )
        EXTERNAL LONG FUNCTION SMG$READ_KEYSTROKE( LONG, LONG, STRING, &
            LONG, LONG )

        !+
        ! Prompt the user for the timer value.  A value of 0 will cause
        ! the type-ahead buffer to be read.
        !-

        INPUT "Enter timer value (0 to read type-ahead buffer):  ";TIMER

        !+
        ! Establish a SMG connection to SYS$INPUT.  Signal any unexpected
        ! errors.
        !-

        RET_STATUS = SMG$CREATE_VIRTUAL_KEYBOARD( KB_ID, "SYS$INPUT:" )
        IF (RET_STATUS AND 1%) = 0% THEN
            CALL LIB$SIGNAL( RET_STATUS )
        END IF

        !+
        !   Read a keystroke, tell the user what we found.
        !-

        RET_STATUS = SMG$READ_KEYSTROKE( KB_ID, TERM_CODE, , TIMER, )
        IF (RET_STATUS <> SS$_TIMEOUT) AND ((RET_STATUS AND 1%) = 0%) THEN
            CALL LIB$SIGNAL( RET_STATUS )
        END IF

        PRINT "term_code = ";TERM_CODE

        SELECT TERM_CODE

            CASE 0 TO 31
                PRINT "You typed a control character"

            CASE 32 TO 127
                PRINT "You typed: ";CHR$(TERM_CODE)

            CASE SMG$K_TRM_PF1 TO SMG$K_TRM_PERIOD
                PRINT "You typed one of the keypad keys"

            CASE SMG$K_TRM_UP TO SMG$K_TRM_RIGHT
                PRINT "You typed one of the cursor positioning keys"

            CASE SMG$K_TRM_F6 TO SMG$K_TRM_F20
                PRINT "You typed one of the function keys"

            CASE SMG$K_TRM_FIND TO SMG$K_TRM_NEXT_SCREEN
                PRINT "You typed one of the editing keys"

            CASE SMG$K_TRM_TIMEOUT
                PRINT "You did not type a key fast enough"

            CASE ELSE
                PRINT "I'm not sure what key you typed"

        END SELECT

        !+
        ! Close the connection to SYS$INPUT, and signal any errors.
        !-

        RET_STATUS = SMG$DELETE_VIRTUAL_KEYBOARD( KB_ID )
        IF (RET_STATUS AND 1%) = 0% THEN
            CALL LIB$SIGNAL( RET_STATUS )
        END IF

        END
