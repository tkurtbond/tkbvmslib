$ ! See also: listq.com and bqinfo-orig.sdcl
$ wso :== write sys$output
$ temp = f$getqui ("") ! clear getqui context
$ queue = f$getqui ("DISPLAY_QUEUE", "QUEUE_NAME", "*", "BATCH,WILDCARD")
$ 23000: if (.not.(queue .nes. "")) then goto 23002
$ 23003: 
$ noaccess = f$getqui("DISPLAY_JOB","JOB_INACCESSIBLE",,"ALL_JOBS")
$ if (.not.(noaccess .eqs. "TRUE")) then goto 23006
$ goto 23004
$ 23006: 
$ if (.not.(noaccess .eqs. "")) then goto 23008
$ goto 23005
$ 23008: 
$ job_name = f$getqui ("DISPLAY_JOB", "JOB_NAME",, "FREEZE_CONTEXT")
$ job_entry = f$getqui ("DISPLAY_JOB", "ENTRY_NUMBER",, "FREEZE_CONTEXT")
$ job_user = f$getqui ("DISPLAY_JOB", "USERNAME",, "FREEZE_CONTEXT")
$ job_status = f$getqui ("DISPLAY_JOB", "JOB_STATUS",, "FREEZE_CONTEXT")
$ job_status_text = ""
$ job_aborting = f$getqui ("DISPLAY_JOB", "JOB_ABORTING",, "FREEZE_CONTEXT")
$ if (.not.(job_aborting)) then goto 23010
$ job_status_text = job_status_text + ",ABORTING"
$ 23010: 
$ job_executing = f$getqui ("DISPLAY_JOB", "JOB_EXECUTING",, "FREEZE_CONTEXT")
$ if (.not.(job_executing)) then goto 23012
$ job_status_text = job_status_text + ",EXECUTING"
$ 23012: 
$ job_holding = f$getqui ("DISPLAY_JOB", "JOB_HOLDING",, "FREEZE_CONTEXT")
$ if (.not.(job_holding)) then goto 23014
$ job_status_text = job_status_text + ",HOLDING"
$ 23014: 
$ job_inaccessible = f$getqui ("DISPLAY_JOB", "JOB_INACCESSIBLE",, "FREEZE_CONTEXT")
$ if (.not.(job_inaccessible)) then goto 23016
$ job_status_text = job_status_text + ",INACCESSIBLE")
$ 23016: 
$ job_pending = f$getqui ("DISPLAY_JOB", "JOB_PENDING",, "FREEZE_CONTEXT")
$ if (.not.(job_pending)) then goto 23018
$ job_status_text = job_status_text + ",PENDING"
$ 23018: 
$ job_refused = f$getqui ("DISPLAY_JOB", "JOB_REFUSED",, "FREEZE_CONTEXT")
$ if (.not.(job_refused)) then goto 23020
$ job_status_text = job_status_text + ",REFUSED"
$ 23020: 
$ job_retained = f$getqui ("DISPLAY_JOB", "JOB_RETAINED",, "FREEZE_CONTEXT")
$ if (.not.(job_retained)) then goto 23022
$ job_status_text = job_status_text + ",RETAINED"
$ 23022: 
$ job_starting = f$getqui ("DISPLAY_JOB", "JOB_STARTING",, "FREEZE_CONTEXT")
$ if (.not.(job_starting)) then goto 23024
$ job_status_text = job_status_text + ",STARTING"
$ 23024: 
$ job_suspended = f$getqui ("DISPLAY_JOB", "JOB_SUSPENDED",, "FREEZE_CONTEXT")
$ if (.not.(job_suspended)) then goto 23026
$ job_status_text = job_status_text + ",SUSPENDED"
$ 23026: 
$ job_timed_release = f$getqui ("DISPLAY_JOB", "JOB_TIMED_RELEASE",, "FREEZE_CONTEXT")
$ if (.not.(job_timed_release)) then goto 23028
$ job_status_text = job_status_text + ",TIMED_RELEASE"
$ 23028: 
$ if (.not.(job_timed_release)) then goto 23030
$ job_after_time = f$getqui ("DISPLAY_JOB", "AFTER_TIME",, "FREEZE_CONTEXT")
$ if (.not.(f$extract (0, 1, job_after_time) .eqs. " ")) then goto 23032
$ job_after_time = "0" + f$extract (1, f$length (job_after_time), job_after_time)
$ 23032: 
$ job_status_text = job_status_text + "=" + job_after_time
$ 23030: 
$ job_status_text_len = f$length (job_status_text)
$ if (.not.(f$extract (0, 1, job_status_text) .eqs. ",")) then goto 23034
$ job_status_text = f$extract (1, job_status_text_len, job_status_text)
$ 23034: 
$ wso queue, " ", job_entry, " ", job_user, " ", job_name, " ", job_status, -
  " ", job_status_text
$ 23004: goto 23003
$ 23005: 
$ 23001: queue = f$getqui ("DISPLAY_QUEUE", "QUEUE_NAME", "*", "BATCH")
$ goto 23000
$ 23002: 
