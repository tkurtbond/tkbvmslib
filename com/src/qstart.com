$! QSTART.COM - Queue Starter
$! This command procedure shows batch queues, or all queues if p1 .nes. ""
$! and does a start/queue on them if p2 .eqs. ""
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
$ start_loop:
$	i = i + 1
$	if i .gt. nqueues then goto end_start_loop
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
$	    write sys$output "QUEUE: ", qname'i', " is ", qstatus, -
		", but we'll start/queue it"
$ 'DOIT	    start/queue &qname'i'
$	else
$           qstatus = "online"
$	    write sys$output "QUEUE: ", qname'i', " is ", qstatus
$       endif
$	goto start_loop
$ end_start_loop:
$ the_end:
$	exit
