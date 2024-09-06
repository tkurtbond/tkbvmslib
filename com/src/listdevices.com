$ 10$:
$	device_name = f$device (, "DISK")
$	if device_name .eqs. "" then goto 19$
$	if .not. f$getdvi (device_name, "MNT") 
$       then 
$           write sys$output "Device ", device_name, " is NOT mounted"
$           goto 10$
$       endif
$       write sys$output "Device ", device_name, " is mounted"
$	goto 10$
$ 19$:
$       exit
