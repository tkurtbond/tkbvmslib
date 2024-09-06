$	Verify = 'F$Verify(0)
$!-----------------------------------------------------------------------------
$!> EMACS.COM -- Manage a Kept Emacs. Based on MG.COM, from MicroGnuEmacs.
$!
$! Usage:
$! @EMACS [file1 [file2 [...]]]		! To start up EMACS
$! @EMACS 				! To reattach to EMACS after ^Z
$!
$! EMACS.COM implements a "kept-fork" capability for EMACS, allowing you to pop
$! in and out of the editor without reloading it all the time.  If a
$! process called user_EMACS (where user is your username) exists, this
$! command file attempts to attach to it.  If not, it silently spawns a
$! subjob to run Emacs for you. 
$!
$! To `keep' EMACS around once you get into it, use "attach-owner" (bound
$! to C-z by default) to suspend EMACS and attach back to the process
$! pointed to by EMACS$AttachTo. 
$!
$! To get back into EMACS from DCL enter @EMACS again.  
$!-----------------------------------------------------------------------------
$!
$! Set things up.  Change the definition of EMACS_Name to whatever you like.
$! You'll *have* to redefine EMACS_PROG, of course...
$!
$	EMACS_Name = F$Edit(F$Getjpi("","USERNAME"),"TRIM") + "_EMACS"
$	EMACS_Prog = "DRA0:[GNUEMACS.BIN]EMACS.EXE"
$	EMACS_Base = EMACS_Name			! Used for additions
$	If F$Length(EMACS_Base) .GT. 13 Then -	! Truncate base for _1,_2...
$		EMACS_Base = F$Extract(0,13,EMACS_Base)
$	Proc = F$GetJpi("","PRCNAM")
$	Master_Pid = F$Getjpi("","MASTER_PID")
$!
$! Define logical names used for communicating with EMACS
$!
$	Define/Nolog/Job EMACS$AttachTo	"''Proc'"
$	Define/Nolog/Job EMACS$File	" "	! No file by default
$	If P1 .Nes. "" Then -
		Define/Nolog/Job EMACS$File "''P1'"
$!
$! Attempt to find EMACS subprocess in current tree.  If found, attach
$! to it, else spawn a new EMACS process
$!
$	Save_Priv = F$SetPrv("NOWORLD,NOGROUP")	! Only look in job tree
$	Try_Count = 1
$Search:
$	Context = ""			! Set up process search context
$ProcLoop:
$	Pid = F$Pid(Context)		! Get next PID
$	If Pid .Eqs. "" Then -
		 Goto Spawn		! No EMACS_Name found; spawn a process
$	If F$GetJpi(Pid,"PRCNAM") .Nes. EMACS_Name Then -
		Goto Procloop		! Try next process
$! Process name matches; see if it's in our job
$	If F$GetJpi(Pid,"MASTER_PID") .Eqs. Master_Pid Then -
		Goto Attach		! Found process in our job!
$! Process name matches, but isn't in our job.  Re-start search
$	EMACS_Name = EMACS_Base + "_" + F$String(Try_Count)
$	Try_Count = Try_Count + 1
$	Goto Search
$!
$! Here to attach to a process in our tree. Set message to
$! turn off the "Attaching to..." message
$!
$Attach:
$	Message = F$Environment("MESSAGE")
$	Set Proc/Priv=('Save_Priv')		! Restore privileges
$	Set Message/NoFacility/NoIdentification/NoSeverity/NoText
$	Attach "''EMACS_Name'"
$	Set Message/Facility/Identification/Severity/Text
$	Goto Done
$!
$! Here if can't attach.  Spawn a new EMACS process
$!
$Spawn:
$	Set Process/Priv=('Save_Priv')		! Restore privileges
$	EMACS$EMACS :== $'EMACS_Prog'			! Avoid recursion
$	Spawn/NoLog/Proc="''EMACS_Name'" EMACS$EMACS 'P1' 'P2' 'P3' 'P4' 'P5' 'P6' 'P7' 'P8'
$	Delete/Symbol/Global EMACS$EMACS		! Get rid of it 
$Done:
$!
$! Here once we reconnect from EMACS, whether we detached or exited.
$!
$	Deassign/Job EMACS$File
$	Deassign/Job EMACS$AttachTo
$	If Verify Then Set Verify
