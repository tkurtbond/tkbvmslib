$!	A subprocedure for the ROU application
$
$	status = rou__success
$	on control_y then goto control_y
$	on warning then goto error
$
$!	initialization
$
$!	body of subprocedure
$
$	goto exit
$
$control_y:
$	status = rou__ctrly
$	goto exit
$
$error:
$	status = $status
$	goto exit
$
$ exit:
$	set noon
$
$!	cleanupcode
$
$	exit status .or. %x10000000
