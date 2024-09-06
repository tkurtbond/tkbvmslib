$!	A subprocedure for the ROU application
$
$	on control_y then exit rou__ctrly
$	on warning then exit $status .or. %x10000000
$
$!	Initialization
$
$!	Body of subprocedure
$
$	exit rou__success
$
$! Module:	What This Module Does
$!
$! Synopsis:	A multi-line description of what this function does.
$!
$! Format:	VERB keyword,...
$!
$! Parameters:	keyword:	What the keyword means.
$!
$! Notes:
