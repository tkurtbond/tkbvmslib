$!> SEARCHDEVICE.COM - Search for a string in filespec on every mounted disk.
$! Usage: searchdevice filespec searchstring
$	filespec = p1
$       searchstring = p2
$       if (filespec .eqs. "") .or. (searchstring .eqs. "") then goto usage
$       set proc/priv=readall
$       ! search returns an error when it doesn't find any files to search.
$ 10$:
$	device_name = f$device (, "DISK")
$	if device_name .eqs. "" then goto 19$
$	if .not. f$getdvi (device_name, "MNT")
$       then 
$           write sys$output "Device ", device_name, " is NOT mounted, skipping"
$           goto 10$
$       endif
$	write sys$output "Searching device ", device_name
$	dirspec = f$parse ("[000000...]"  + filespec, device_name,,, "SYNTAX_ONLY")
$       on error then continue 
$	search 'dirspec' "''searchstring'"
$	goto 10$
$ 19$:
$       exit
$ usage:
$       copy sys$input sys$error
usage: searchdevice FILESPEC SEARCHSTRING
where
FILESPEC        Is a VMS filespec of the files to search through.  Only name
                and type are allowed.  The "*" and "%" wildcards are allowed.
SEARCHSTRING    Is the string for which to search.
$       exit
