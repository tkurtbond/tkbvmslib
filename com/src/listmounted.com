$ 10$:
$	device_name = f$device (, "DISK")
$	if device_name .eqs. "" then goto 19$
$	if .not. f$getdvi (device_name, "MNT") then goto 10$
$       write sys$output device_name
$	goto 10$
$ 19$:
$       exit
