$	Verify = 'F$Verify(0)
$!
$!> EVE.COM -- Make eve a kept process (based on MG.COM)
$!
$! This command file has been modified from the MG.COM in the MicroGnuEmacs
$! distribution on one of the 87 (I think) tapes.
$!
$! Usage:
$! @EVE [file1 [file2 [...]]]		! To start up EVE
$! @EVE [file]				! To reattach to EVE after <DO> ATTACH
$!
$! EVE.COM implements a "kept-fork" capability for EVE, allowing you to pop
$! in and out of the editor without reloading it all the time.  If a
$! process called user_EVE (where user is your username) exists, this
$! command file attempts to attach to it.  If not, it silently spawns a
$! subjob to run Emacs for you. 
$!
$! To `keep' EVE around once you get into it, use "<DO> ATTACH" 
$! to suspend EVE and attach back to the original process.
$!
$! To get back into EVE from DCL enter @EVE again.  

$!----------------------------------------------------------------
$!
$! Set things up.  Change the definition of EVE_Name to whatever you like.
$! You'll *have* to redefine EVE_PROG, of course...
$!
$	EVE_Name = F$Edit(F$Getjpi("","USERNAME"),"TRIM") + "_EVE"
$!	EVE_Prog = "eve_dir:EVE.Exe"
$	EVE_Base = EVE_Name			! Used for additions
$	If F$Length(EVE_Base) .GT. 12 Then -	! Truncate base for _1,_2...
$		EVE_Base = F$Extract(0,12,EVE_Base)
$	Proc = F$GetJpi("","PRCNAM")
$	Master_Pid = F$Getjpi("","MASTER_PID")
$!
$! Define logical names used for communicating with EVE
$!
$	Define/Nolog/Job EVE$AttachTo	"''Proc'"
$	Define/Nolog/Job EVE$File	" "	! No file by default
$	If P1 .Nes. "" Then -
		Define/Nolog/Job EVE$File "''P1'"
$!
$! Attempt to find EVE subprocess in current tree.  If found, attach
$! to it, else spawn a new EVE process
$!
$	Save_Priv = F$SetPrv("NOWORLD,NOGROUP")	! Only look in job tree
$	Try_Count = 1
$Search:
$	Context = ""			! Set up process search context
$ProcLoop:
$	Pid = F$Pid(Context)		! Get next PID
$	If Pid .Eqs. "" Then -
		 Goto Spawn		! No EVE_Name found; spawn a process
$	If F$GetJpi(Pid,"PRCNAM") .Nes. EVE_Name Then -
		Goto Procloop		! Try next process
$! Process name matches; see if it's in our job
$	If F$GetJpi(Pid,"MASTER_PID") .Eqs. Master_Pid Then -
		Goto Attach		! Found process in our job!
$! Process name matches, but isn't in our job.  Re-start search
$	EVE_Name = EVE_Base + "_" + F$String(Try_Count)
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
$	Attach "''EVE_Name'"
$	Set Message/Facility/Identification/Severity/Text
$	Goto Done
$!
$! Here if can't attach.  Spawn a new EVE process
$!
$Spawn:
$	Set Process/Priv=('Save_Priv')		! Restore privileges
$	Spawn/NoLog/Proc="''EVE_Name'" eve 'P2' 'P3' 'P4' 'P5' 'P6' 'P7' 'P8'
$Done:
$!
$! Here once we reconnect from EVE, whether we detached or exited.
$!
$	Deassign/Job EVE$File
$	Deassign/Job EVE$AttachTo
$	If Verify Then -
		Set Verify
