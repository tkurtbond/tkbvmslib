!
! define the directory containing this procedure as SYS$ICON;
! define the commands ICONT, ICONX, and IEXE;
! and add the Icon help library to the search path.
!
$ PROC = f$environment("procedure")
$ DEV = f$parse(PROC,,,"device")
$ DIR = f$parse(PROC,,,"directory")
$ Assign/NoLog 'DEV''DIR' SYS$ICON
$ Icont == "$SYS$ICON:icont "
$ Iconx == "$SYS$ICON:iconx "
$ Mmps  == "$SYS$ICON:mmps "
$ Iexe  == "@SYS$ICON:iexe "
$!
$ HELPLIB = "SYS$ICON:ICON.HLB"		! value must be upper case
$ LOGNAME = "HLP$LIBRARY"
$ N = 0
$loop:
$ NAMEVAL = F$TRNLNM("''LOGNAME'","LNM$PROCESS_TABLE")
$ If NAMEVAL .Eqs. ""			Then $ GoTo assign
$ If NAMEVAL .Eqs. "''HELPLIB'"		Then $ GoTo done
$ N = N + 1
$ LOGNAME = "HLP$LIBRARY_''N'"
$ If N .Lt. 1000			Then $ GoTo loop
$ Write SYS$OUTPUT "Can't add Icon help library; too many names."
$ GoTo done
$!
$assign:
$ Assign 'HELPLIB' 'LOGNAME'
$done:
$ Exit 1
