$	userfilespec = p1
$ 10$:
$	device_name = f$device (, "DISK")
$	if device_name .eqs. "" then goto 19$
$	if .not. f$getdvi (device_name, "MNT") then goto 10$
$	diskfilespec = f$parse (userfilespec, device_name,"[*...]",, "SYNTAX_ONLY")
$	write sys$output "For disk ", device_name, " using filespec ", diskfilespec
$	directory 'diskfilespec'
$	goto 10$
$ 19$:
