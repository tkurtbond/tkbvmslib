$! swim.com -- start swim with a defaults file.
$	swim := $swim_location:swim
$	swim_file = ''		! Start with nothing
$	if p1 .eqs. "" then goto start_swim
$
$	swim_file = f$parse (p1, "com_lib:.swm")
$	if swim_file .nes. "" then goto start_swim
$	
$
$ start_swim:
$	swim 'swim_file'
