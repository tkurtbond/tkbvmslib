$! The following annoyg abbreviated symbol defintion conflict warnings
$! because the Mines login reexecutes my login.  Sigh.
$ define TKB_SKIP_LOGIN TRUE 
$ @SIS$DATA:[MINES]LOGIN.COM
$ delete/symbol/global directory
$ deassign TKB_SKIP_LOGIN
