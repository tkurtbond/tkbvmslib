$ !
$ ! MAP.COM --	procedure to add a logical name table to the process
$ !		logical name table list
$ !
$ !	PARAMETER LIST
$ !
$ !		P1	Name of the table to be mapped into the process
$ !			table list
$ !
$ !		P2	Either IN, BEFORE, or AFTER
$ !
$ !		P3	If P2 is the keyword IN: either FRONT or BACK
$ !
$ !			Otherwise, the name of the already-mapped table
$ !			relative to which the new table is to be mapped
$ !
$ !	Examples:
$ !			$ @MAP MY_TABLE IN FRONT
$ !
$ !		This command puts MY_TABLE at the top of the list.
$ !
$ !
$ !			$ @MAP MY_OTHER_TABLE AFTER MY_TABLE
$ !
$ !		This command puts MY_OTHER_TABLE second on the list.
$ !
$ GOSUB INIT
$ GOSUB GET_COMMAND_LINE
$ GOSUB GET_TABLE_LIST
$ IF P2 .EQS. "IN"
$ THEN
$    IF P3 .EQS. "FRONT"
$    THEN
$       DEFINE/TABLE=LNM$PROCESS_DIRECTORY LNM$PROCESS 'NEW_TABLE', 'TABLE_LIST
$    ELSE
$       ! P3 must equal "BACK"
$       DEFINE/TABLE=LNM$PROCESS_DIRECTORY LNM$PROCESS 'TABLE_LIST', 'NEW_TABLE
$    ENDIF
$ ELSE
$    ! This is a "BEFORE" or "AFTER" entry.
$    GOSUB BUILD_NEW_LIST
$    Say "New List: ", New_list
$    DEFINE/TABLE=LNM$PROCESS_DIRECTORY LNM$PROCESS 'NEW_LIST
$ ENDIF
$ EXIT
$ !============================================================================
$
$ INIT:
$ 
$ BADPARAM	= %X00030010
$ IVCHAR	= %X000020C8
$ IVLOGTAB	= %X00000158
$ RETURN
$ !============================================================================
$ 
$ GET_COMMAND_LINE:
$ 
$ IF P1 .EQS. "" THEN INQUIRE P1 "Table"
$ IF P1 .EQS. "" THEN EXIT
$ IF .NOT. F$TRNLNM( P1, "LNM$DIRECTORIES",,,, "TABLE") THEN -
     EXIT IVLOGTAB
$ IF P2 .NES. ""
$ THEN
$    IF ( P2 .NES. "IN") .AND. -
        ( P2 .NES. "BEFORE") .AND. -
        ( P2 .NES. "AFTER") -
     THEN EXIT BADPARAM
$ ELSE
$    !
$    ! P2 was not specified.
$    !
$    TYPE SYS$INPUT

	(1)	Place the new table in the front of the list

	(2)	Place the new table in the back of the list

	(3)	Place the new table before a specific table

	(4)	Place the new table after a specific table


$    INQUIRE OPTION "Option"
$    IF OPTION .EQS. "" THEN EXIT
$    OPTION = F$EDIT( OPTION, "COLLAPSE")
$    IF ( F$LENGTH( OPTION) .GT. 1) .OR. -
	( F$LOCATE( OPTION, "1234") .GE. 4) THEN EXIT IVCHAR
$    OPTION = F$INTEGER( OPTION)	! make it numeric, hopefully.
$    IF OPTION .LE. 2
$    THEN
$       P2 = "IN"
$       P3 = F$ELEMENT( OPTION, "`", "`FRONT`BACK")
$    ELSE
$       P2 = F$ELEMENT( OPTION - 2, "`", "`BEFORE`AFTER")
$    ENDIF
$ ENDIF
$ IF P2 .EQS. "IN"
$ THEN
$    IF (P3 .NES. "FRONT") .AND. (P3 .NES. "BACK") THEN EXIT BADPARAM
$    GUIDE_TABLE = ""
$ ELSE
$    IF P3 .EQS. "" THEN INQUIRE/NOPUNC P3 "Put it ''P2' what table? "
$    IF P3 .EQS. "" THEN EXIT
$    IF .NOT. F$TRNLNM( P3, "LNM$PROCESS_DIRECTORY",,,, "TABLE") THEN -
        EXIT IVLOGTAB
$    GUIDE_TABLE = P3
$ ENDIF
$ NEW_TABLE = P1
$ RETURN
$ !============================================================================
$
$ GET_TABLE_LIST:
$
$ I = 0
$ MAX = F$TRNLNM( "LNM$PROCESS", "LNM$PROCESS_DIRECTORY",,,, "MAX_INDEX")
$ PRE_GUIDE_TABLE = "TRUE"
$ TABLE_LIST = ""
$ PRE_LIST = ""
$ POST_LIST = ""
$
$ GTL_10:
$ THIS_TRANS = F$TRNLNM( "LNM$PROCESS", "LNM$PROCESS_DIRECTORY", I)
$ IF THIS_TRANS .NES. NEW_TABLE		! Don't double enter 'NEW_TABLE
$ THEN
$    IF GUIDE_TABLE .EQS. ""
$    THEN
$       IF TABLE_LIST .NES. "" THEN TABLE_LIST = TABLE_LIST + ","
$       TABLE_LIST = TABLE_LIST + THIS_TRANS
$    ELSE
$       IF PRE_GUIDE_TABLE
$       THEN
$          IF THIS_TRANS .NES. GUIDE_TABLE
$          THEN
$             IF PRE_LIST .NES. "" THEN PRE_LIST = PRE_LIST + ","
$             PRE_LIST = PRE_LIST + THIS_TRANS
$          ELSE
$             PRE_GUIDE_TABLE = "FALSE"
$          ENDIF
$       ELSE
$          IF POST_LIST .NES. "" THEN POST_LIST = POST_LIST + ","
$          POST_LIST = POST_LIST + THIS_TRANS
$       ENDIF
$    ENDIF
$ ENDIF
$ IF I .LT. MAX
$ THEN
$    I = I + 1
$    GOTO GTL_10
$ ENDIF
$ RETURN
$ !============================================================================
$
$ BUILD_NEW_LIST:
$
$ IF P2 .EQS. "BEFORE"
$ THEN
$    IF PRE_LIST .NES. ""
$    THEN
$       NEW_LIST = PRE_LIST + "," + NEW_TABLE + "," + GUIDE_TABLE
$    ELSE
$       NEW_LIST = NEW_TABLE + "," + GUIDE_TABLE
$    ENDIF
$ ELSE
$    IF PRE_LIST .NES. ""
$    THEN
$       NEW_LIST = PRE_LIST + "," + GUIDE_TABLE + "," + NEW_TABLE
$    ELSE
$       NEW_LIST = GUIDE_TABLE + "," + NEW_TABLE
$    ENDIF
$ ENDIF
$ IF POST_LIST .NES. "" THEN NEW_LIST = NEW_LIST + "," + POST_LIST
$ RETURN
