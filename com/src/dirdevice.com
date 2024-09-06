$!> DIRDEVICE.COM - Do a directory for filespec P1 on every mounted disk.
$! Usage: @dirdevice term_interface*.*
$	filespec = p1
$       set proc/priv=readall
$ 10$:
$	device_name = f$device (, "DISK")
$	if device_name .eqs. "" then goto 19$
$       if .not. f$getdvi (device_name, "MNT") then goto 10$
$	write sys$output "Searching device ", device_name
$	if .not. f$getdvi (device_name, "MNT") then goto 10$
$	!dirspec = f$parse ("[000000...]TERM_INTERFACE*.*", device_name,,, "SYNTAX_ONLY")
$	dirspec = f$parse ("[000000...]"  + filespec, device_name,,, "SYNTAX_ONLY")
$	directory/date=mod 'dirspec'
$	goto 10$
$ 19$:
