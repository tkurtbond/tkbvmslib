$ verify = 'f$verify( f$type( logout_verify ) .nes. "")'
$!> EOJ.COM -- Log out if (subprocess or (master process and no subprocess))
$!-----------------------------------------------------------------------------
$! If not at top level process, goto logout 
$!-----------------------------------------------------------------------------
$    if f$getjpi("", "PID") .nes. f$getjpi("", "MASTER_PID") then -
	goto logout
$!-----------------------------------------------------------------------------
$! If no subprocesses exist, goto logout
$!-----------------------------------------------------------------------------
$    job_prc_cnt = f$getjpi("", "jobprccnt")
$    if job_prc_cnt .eq. 0 then goto logout
$!-----------------------------------------------------------------------------
$! A subprocess exists, tell use and don't log out
$!-----------------------------------------------------------------------------
$ subprocess_exists:
$    write sys$error -
	 f$fao("error: !5*this process has !SL subprocess!%S, not logging out", -
	     job_prc_cnt)
$    exit (1 .or. (f$verify(verify) .and. 0))
$!-----------------------------------------------------------------------------
$! Log out
$!-----------------------------------------------------------------------------
$ logout:
$    logout = "logout"			!probably redefined to this com file
$    logout
