$       verifying = 'f$verify(f$type(requeue_verify) .nes. "")'
$! REQUEUE.COM - Requeue a batch.
$!
$! usage: @requeue [options] command_proc.com 
$!
$! See the "usage:" subroutine below for details, or use -HELP.
$!-----------------------------------------------------------------------------
$! Vers  When        Who  What
$! 1.0   ????-??-??  tkb  Initial version
$!-----------------------------------------------------------------------------
$       start_time = f$time()
$       requeue_proc = f$environment ("procedure")
$       requeue_name = f$parse (requeue_proc,,,"NAME")
$
$       TRUE = 1 .eq. 1
$       FALSE = 1 .eq. 2
$       quiet = %x10000000
$       wso :== write sys$output
$       wse :== write sys$error
$       
$       opt_list = "/CHECK/DAILY/DEBUG/DELTA/HELP/HOURLY/NOREQUEUE/NORUN" + -
            "/QUEUE/REMOVE/REQUEUE/RUN/START/USER/VERBOSE/"
$       opt_list_len = f$length (opt_list)
$       operation = "NORMAL" ! requeue and run
$       method = "UNSPECIFIED"
$       verbose_flag = FALSE
$       debug_flag = FALSE
$       delta = ""
$       batch_queue = "FST$BATCH"
$       username = f$edit (f$getjpi ("", "USERNAME"), "TRIM")
$
$       i = 1
$ 10:   if i .gt. 8 then goto usage
$       opt = p'i'
$       if opt .eqs. "" then goto usage
$       if f$extract (0, 1, opt) .nes. "-" then goto 19
$       which = f$extract (1, 4, opt)
$       ok = f$locate ("/" + which, opt_list) .ne. opt_list_len
$       if .not. ok then goto usage
$       gosub OPT$'which'
$       i = i + 1
$       goto 10
$ 19:
$       command_proc = f$parse (opt,,f$environment ("DEFAULT"))
$       if debug_flag then wse "command_proc: ", command_proc
$       version = f$parse (command_proc,,, "VERSION")
$       if debug_flag then wse "version: ", version
$       command_proc = command_proc - version
$       if debug_flag then wse "command_proc: ", command_proc
$       job_name = f$edit (requeue_name + "_" + -
                           f$parse (command_proc,,,"NAME"), -
                           "COLLAPSE,UPCASE")
$       if operation .eqs. "RUN" then goto execute
$       if method .eqs. "UNSPECIFIED"
$       then
$           opt = "-DAILY"
$           gosub OPT$dail
$       endif
$
$       pid = f$integer ("%x" + f$getjpi ("", "PID"))
$       temp = f$getqui ("") ! clear getqui context
$ queue_loop:
$       qname = f$getqui("DISPLAY_QUEUE","QUEUE_NAME",batch_queue, "WILDCARD")
$       if qname .eqs. "" then goto end_queue_loop
$     job_loop:
$           noaccess = f$getqui("DISPLAY_JOB","JOB_INACCESSIBLE",,"ALL_JOBS")
$           if noaccess .eqs. "TRUE" then goto job_loop
$           if noaccess .eqs. "" then goto queue_loop
$           jname = f$getqui("DISPLAY_JOB","JOB_NAME",,"FREEZE_CONTEXT")
$           jentry = f$getqui("DISPLAY_JOB","ENTRY_NUMBER",,"FREEZE_CONTEXT")
$           jpid = f$integer ("%x" + f$getqui ("DISPLAY_JOB", "JOB_PID",, -
                              "FREEZE_CONTEXT"))
$           if (jname .eqs. job_name) .and. (jpid .ne. pid) 
$           then
$               ! We found the job
$               if operation .eqs. "REMOVE" then goto remove_job
$               !else
                goto job_waiting
$           endif
$           goto job_loop
$     end_job_loop:
$ end_queue_loop:
$       if operation .eqs. "REMOVE" then goto no_job_to_remove
$       wse "We need to requeue ", job_name
$       rqtime = f$cvtime (requeue_time, "COMPARISON")
$       curtime = f$cvtime ("", "COMPARISON")
$       if verbose_flag then wso "rqtime: ", rqtime
$       if verbose_flag then wso "curtime: ", curtime 
$       if rqtime .gts. curtime then goto time_ok
$       wse "Requeue time ", rqtime
$       wse "    is earlier than current time ", curtime
$       wse "Exiting..."
$       exit 2 .or. quiet .or. (f$verify(verifying) .and. 0)
$ time_ok: 
$       if debug_flag then wso "method: ", method
$       if operation .eqs. "CHECK" then goto the_end
$
$       if username .eqs. f$edit (f$getjpi ("", "USERNAME"), "TRIM")
$       then
$           useropt = ""
$       else
$           useropt = "/USER=" + username
$       endif
$
$       wse "Requeueing ", job_name
$       submit/noprint/nodelete -
            /que='batch_queue' 'useropt' /name='job_name' -
            /after="''requeue_time'" -
            !/hold -
            /parameters=("''method'", -
                         "-QUEUE=''batch_queue'", -
                         "-USER=''username'", -
                         'command_proc') -
            'requeue_proc'
$
$       if operation .eqs. "REQUEUE" then goto the_end
$
$ execute:
$       wse "Executing ", command_proc
$       @'command_proc'
$
$ the_end:
$       exit (1 .or. (f$verify(verifying) .and. 0))
$       
$ job_waiting: 
$       wse "There's already a ", job_name, " waiting, entry number ", jentry
$       exit (1 .or. (f$verify(verifying) .and. 0))
$
$ remove_job:
$       show entry 'jentry'
$       delete/entry='jentry'/log
$       exit (1 .or. (f$verify(verifying) .and. 0))
$
$ no_job_to_remove:
$       wse "There is no ", job_name, " waiting to remove"
$       exit (1 .or. (f$verify(verifying) .and. 0))
$! 
$ usage:
$       copy sys$input sys$error
usage: @requeue [options] command_proc.com

WARNING: If you PURGE the versions of this command procedure that existing
batch queue entries are using they fill fail and not requeue.

-CHECK
        check the requeueing time, but do not run or requeue.
-DAILY[=delta]
        requeue daily, optionally at the specified delta from start of day.
-DEBUG
        Display debugging messages.
-DELTA=delta
        requeue after the amount of time specified by "delta" passes.
-HELP
        This message.
-HOURLY[=delta]
        requeue hourly at current time, or optionally at the specified delta 
        from the start of the hour.  Note that specifing a delta of 0 (zero)
        means the start of the hour.
-NOREQUEUE
        Run the command procedure, but do not requeue it.
-QUEUE=batch_queue
        Specify the batch queue.
-REMOVE
        Remove the requeueing batch for the specified command procedure.
-REQUEUE
        Requeue only, do not run the command procedure.
-RUN
        Run the command procedure, but do not requeue it.
-START=start-time
        Start time to use instead of the current time.
-USER=username
        User to submit the batch as.
-VERBOSE
        Display more messages.

The normal mode of operation is to requeue and run the command procedure. 
$       exit (1 .or. (f$verify(verifying) .and. 0))
$
$! Parse options
$ OPT$chec:
$       operation = "CHECK"
$       return
$
$ OPT$dail:
$       method = "-DAILY"
$       len = f$length (opt)
$       pos = f$locate ("=", opt)
$       requeue_time = "TODAY"
$       if pos .ne. len 
$       then
$           delta = f$extract (pos+1, len, opt)
$       else
$           delta = f$cvtime (start_time, "COMPARISON", "HOUR") + ":" + -
                    f$cvtime (start_time, "COMPARISON", "MINUTE")
$       endif
$       requeue_time = requeue_time + "+" + delta
$       if debug_flag then wso "requeue_time: ", requeue_time
$       test_time = f$cvtime (requeue_time , "ABSOLUTE")
$       if debug_flag then wso "test_time: ", requeue_time
$ daily_test_time: 
$       cur_time = f$cvtime (start_time, "COMPARISON")
$       rqtime = f$cvtime (requeue_time, "COMPARISON")
$       if debug_flag then wso "cur_time: ", cur_time
$       if debug_flag then wso "rqtime:   ", rqtime
$       if cur_time  .gts. rqtime
$       then
$           requeue_time = "TOMORROW+" + delta
$           goto daily_test_time
$       endif
$       method = method + "=" + delta
$       if debug_flag then wso "requeue_time: ", requeue_time
$       if debug_flag then wso "method: ", method       
$       return
$
$ OPT$debu:
$       debug_flag = TRUE
$       return
$
$ OPT$help:
$       goto usage
$       exit (1 .or. (f$verify(verifying) .and. 0))
$
$ OPT$hour:
$       method = "-HOURLY"
$       len = f$length (opt)
$       pos = f$locate ("=", opt)
$       if pos .ne. len 
$       then 
$           delta = f$extract (pos+1, len, opt)
$       else
$           delta = f$cvtime (start_time, "COMPARISON", "MINUTE")
$       endif
$       if debug_flag then wso "start_time: ", start_time
$       if debug_flag then wso "delta: ", delta
$       method = method + "=" + delta
$       time = f$cvtime(start_time, "ABSOLUTE")
$       hour = f$extract (12, 2, time)
$       if debug_flag then wso "hour: ", hour
$!       new_hour = hour + 1
$       new_hour = f$integer (hour)
$       date = "TODAY"
$ hourly_test_time: 
$       if new_hour .gt. 23
$       then
$         new_hour = 0
$         date = "TOMORROW"
$       endif
$       if debug_flag then wso "new_hour: ", new_hour
$       new_hour = f$fao ("!2ZL", new_hour)
$       if debug_flag then wso "new_hour: ", new_hour
$       requeue_time = date + "+" + new_hour
$       if delta .nes. "" then requeue_time = requeue_time + ":" + delta
$       if debug_flag then wso "requeue_time: ", requeue_time 
$       cur_time = f$cvtime (start_time, "COMPARISON")
$       rqtime = f$cvtime (requeue_time, "COMPARISON")
$       if debug_flag then wso "cur_time: ", cur_time
$       if debug_flag then wso "rqtime:   ", rqtime
$       if rqtime .lts. cur_time 
$       then 
$           new_hour = new_hour + 1
$           goto hourly_test_time
$       endif
$       if debug_flag then wso "method: ", method
$       return
$
$ OPT$delt:
$       method = "-DELTA"
$       len = f$length (opt)
$       pos = f$locate ("=", opt)
$       if pos .ne. len
$       then
$           delta = f$extract (pos+1, len, opt)
$       else
$           wse "-DELTA requires a delta time"
$           goto usage
$       endif
$       if debug_flag then wso "start_time: ", start_time
$       if debug_flag then wso "delta: ", delta
$       method = method + "=" + delta
$       requeue_time = f$cvtime (start_time + "+" + delta, "ABSOLUTE")
$       if debug_flag then wso "requeue_time: ", requeue_time
$       rqtime = f$cvtime (requeue_time, "COMPARISON")
$       if debug_flag then wso "rqtime: ", rqtime
$       return
$
$ OPT$nore:
$ OPT$run:
$       operation = "RUN"
$       return
$
$ OPT$noru:
$       operation = "REQUEUE"
$       return
$
$ OPT$queu:
$       len = f$length (opt)
$       pos = f$locate ("=", opt)
$       if pos .ne. len
$       then
$           batch_queue = f$extract (pos+1, len, opt)
$       else
$           wse "-QUEUE requires a batch queue name"
$           goto usage
$       endif
$       return
$
$ OPT$remo: 
$       operation = "REMOVE"
$       return
$
$ OPT$requ:
$       operation = "REQUEUE"
$       return
$
$ OPT$star: 
$       len = f$length (opt)
$       pos = f$locate ("=", opt)
$       if pos .ne. len
$       then
$           start_time = f$cvtime (f$extract (pos+1, len, opt), "ABSOLUTE")
$       else
$           wse "-START requires a start time"
$           goto usage
$       endif
$       return
$
$ OPT$user:
$       len = f$length (opt)
$       pos = f$locate ("=", opt)
$       if pos .ne. len
$       then
$           username = f$extract (pos+1, len, opt)
$       else
$           wse "-USER requires a username"
$           goto usage
$       endif
$       return
$
$ OPT$vers: 
$       verbose_flag = TRUE
$       return
$
$! end of REQUEUE.COM
