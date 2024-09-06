$	sublib__status = %x10000000
$	sublib__success = sublib__status + %x0001
$	on control_y then exit sublib__status + %x0004
$	on warning then exit $status .or. %x100000000
$
$	display = "write sys$output"
$	goto 'p1

$! Title:	Title
$! 
$! Synopsis:	Synopsis
$!
$! Parameters:	P2: 
$!
$! Result:	
