$!> QSTAT.COM - Queue Status
$! This program displays the status of the queue named in P1.
$	if p1 .eqs. "" 
$	then 
$	    write sys$error "usage: qs queue_name"
$	    exit 2
$	endif
$ 	status_flags = -
	  "ALIGNING,CLOSED,IDLE,LOWERCASE,PAUSED,PAUSING,REMOTE," + -
	  "RESETTING,RESUMING,SERVER,STALLED,STOP_PENDING,STARTING," + -
	  "STOPPING,UNAVAILABLE"
$	temp = f$getqui ("")
$	qname = f$getqui ("DISPLAY_QUEUE", "QUEUE_NAME", p1)
$	if qname .eqs. "" 
$	then 
$	    write sys$error "No such queue: ", p1
$	    exit 2
$	endif
$	write sys$output "QUEUE: ", p1, ": NAME: ", qname
$	i = 0
$ 10$:	e = f$element (i, ",", status_flags)
$	if e .eqs. "," then goto 19$
$	flag = "QUEUE_" + e
$	status = f$getqui ("DISPLAY_QUEUE", flag, p1)
$	write sys$output "QUEUE: ", p1, ": ", flag, ": ", status
$	i = i + 1
$	goto 10$
$ 19$:
$	status = f$getqui ("DISPLAY_QUEUE", "QUEUE_STATUS", p1)
$	write sys$output "QUEUE: ", p1, ": status: ", f$fao ("!XL", status)
