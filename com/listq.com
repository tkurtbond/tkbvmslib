$	debug_flag = (1 .eq. 1)
$
$	batch_queue = "*"
$ 	pid = f$integer ("%x" + f$getjpi ("", "PID"))
$	temp = f$getqui ("") ! clear getqui context
$ queue_loop:
$   	qname = f$getqui("DISPLAY_QUEUE","QUEUE_NAME",batch_queue, "WILDCARD")
$	if debug_flag then wso "qname: ", qname
$   	if qname .eqs. "" then goto end_queue_loop
$     job_loop:
$     	    noaccess = f$getqui("DISPLAY_JOB","JOB_INACCESSIBLE",,"ALL_JOBS")
$!     	    if noaccess .eqs. "TRUE" then goto job_loop
$     	    if noaccess .eqs. "" then goto queue_loop
$     	    jname = f$getqui("DISPLAY_JOB","JOB_NAME",,"FREEZE_CONTEXT")
$     	    jentry = f$getqui("DISPLAY_JOB","ENTRY_NUMBER",,"FREEZE_CONTEXT")
$     	    jpid = f$integer ("%x" + f$getqui ("DISPLAY_JOB", "JOB_PID",, -
                              "FREEZE_CONTEXT"))
$	    if debug_flag then -
	        wso "jname: ", jname, " jentry: ", jentry, " jpid: ", jpid
$           goto job_loop
$     end_job_loop:
$ end_queue_loop:
