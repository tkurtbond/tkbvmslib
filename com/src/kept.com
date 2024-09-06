$!> KEPT.COM -- Attach to a kept process
$!-----------------------------------------------------------------------------
$! Parameters:
$!
$!	P1 -- Name of facility to be kept
$!	P2 -- Command to execute to create
$!-----------------------------------------------------------------------------
$	name = p1 + " " + f$trnlnm("TT") - ":"
$	old_message = f$environment("message")
$	on control_y then goto The_End
$	set message /nofacility /noident /noseverity /notext
$ 	on error then goto create_proc
$ 	on warning then goto create_proc
$ 	attach "''name'"
$ 	goto The_End
$ create_proc:
$	write sys$error "[Spawning a new Kept ''P1']"
$ 	spawn /nolog /process="''name'" 'p2' 'p3' 'p4' 'p5' 'p6' 'p7' 'p8'
$ The_End:
$	set message 'old_message'
$	write sys$error -
"[Attached to DCL in directory ''f$environment("default")']"
$ 	exit 
$!
