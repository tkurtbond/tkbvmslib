From:	MPL::RICK         "Rick DiClemente - Adminisoft - 291-2146" 15-FEB-1990 22:52:13.66
To:	TOM,KURT,PEGGY,RIGO
CC:	
Subj:	FASTER VERSION

$!
$! MONTHLY_BY_PROJECT.COM
$!
$	TEMP_NAME = "MBP_" + F$GETJPI("", "PID") + ".TMP"
$	TIME = P1
$	MONTH = F$CVTIME(TIME, , "MONTH")
$	IF F$EXTRACT(0, 1, MONTH) .EQS. "0" THEN MONTH = MONTH  - "0"
$	YEAR = F$EXTRACT(2, 2, F$CVTIME(TIME, , "YEAR"))
$!-----------------------------------------------------------------------------
$!	CREATE THE SORT IN A TEMP FILE
$!-----------------------------------------------------------------------------
$ !
$ 	OPEN/WRITE OUTF 'TEMP_NAME'
$ 	WRITE OUTF "$ RUN DMS:SORT"
$ 	WRITE OUTF "PRE_PTMS_DETAIL/START=10000"
$ 	WRITE OUTF ".PROJECT"
$ 	WRITE OUTF ""
$ 	WRITE OUTF "YES"
$	WRITE OUTF ".DATE_WORKED/EXTRACT=""1-2,5-6"""
$	WRITE OUTF MONTH, YEAR, "/ONLY"
$ 	WRITE OUTF ".USER_NAME"
$!
$ CUR_USER = F$EDIT(F$GETJPI("","USERNAME"),"COLLAPSE")
$ INQUIRE/NOPUN TEMP$ "Username to use? <''CUR_USER'> "
$ IF TEMP$ .NES. "" THEN CUR_USER = TEMP$
$!
$ 	WRITE OUTF "''CUR_USER'/ONLY"
$       WRITE OUTF ".REC_TYPE"
$       WRITE OUTF "B/ONLY"
$ 	WRITE OUTF ""
$ 	WRITE OUTF "(A AND B) AND (NOT C)"
$ 	CLOSE OUTF
$ 	@'TEMP_NAME'
$	DELETE 'TEMP_NAME';*
$!-----------------------------------------------------------------------------
$!	PRINT THE INFORMATION
$!-----------------------------------------------------------------------------
$ 	RUN DMS:PRINT
PRE_PTMS_DETAIL/SUMMARY/NH
0
1
.PROJECT/NODETAIL
.TOTAL_D_HRS/NODETAIL/TOTAL
5
@@@.@@

55
1/NOLINES/GT=Grand Total For All Projects:
.PROJECT/NOLINES/SKIP=0/TEXT=   Subtotal for Project <.PROJECT>:

Hours worked per project for the Month

1
TT
$ BYE:
$ EXIT
