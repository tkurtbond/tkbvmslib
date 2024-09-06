$! QSTOP.COM - Queue Stopper
$! This command procedure shows batch queues, or all queues if p1 .nes. ""
$! and does a stop/queue/next on them if p2 .eqs. ""
$! FIXME: ought to ask?  
$! FIXME: better option handling?
$	fz = "" !"FREEZE_CONTEXT"
$	if p1 .nes. ""
$	then 
$	    queue_type = ""
$	else
$	    queue_type = "BATCH"
$	endif
$	if p2 .nes. ""
$	then 
$	    DOIT = "!"
$	else
$	    DOIT = ""
$	endif
$	nqueues = 0
$  	temp = f$getqui ("")
$  qloop:
$  	qname = f$getqui ("DISPLAY_QUEUE","QUEUE_NAME","*", queue_type)
$  	if qname .eqs. "" then goto end_qloop
$	nqueues = nqueues + 1
$	qname'nqueues' = qname
$! &qname'nqueues'
$  	goto qloop
$ end_qloop:
$	if nqueues .le. 0 then goto the_end
$	i = 0
$	temp = f$getqui ("")
$ stop_loop:
$	i = i + 1
$	if i .gt. nqueues then goto end_stop_loop
$     	IF       f$getqui ("DISPLAY_QUEUE", "QUEUE_CLOSED",	  qname'i') -
	    .or. f$getqui ("DISPLAY_QUEUE", "QUEUE_PAUSED",	  qname'i') -
	    .or. f$getqui ("DISPLAY_QUEUE", "QUEUE_PAUSING",	  qname'i') -
	    .or. f$getqui ("DISPLAY_QUEUE", "QUEUE_RESETTING",	  qname'i') -
	    .or. f$getqui ("DISPLAY_QUEUE", "QUEUE_STALLED",	  qname'i') -
	    .or. f$getqui ("DISPLAY_QUEUE", "QUEUE_STOP_PENDING", qname'i') -
	    .or. f$getqui ("DISPLAY_QUEUE", "QUEUE_STOPPED",	  qname'i') -
	    .or. f$getqui ("DISPLAY_QUEUE", "QUEUE_STOPPING",	  qname'i') -
	    .or. f$getqui ("DISPLAY_QUEUE", "QUEUE_UNAVAILABLE",  qname'i')
$       then
$           qstatus = "offline"
$	    write sys$output "QUEUE: ", qname'i', " is ", qstatus
$	else
$           qstatus = "online"
$	    write sys$output "QUEUE: ", qname'i', " is ", qstatus, -
		", but we'll stop/queue/next it"
$ 'DOIT	    stop/queue/next &qname'i'
$       endif
$	goto stop_loop
$ end_stop_loop:
$ the_end:
$	exit
