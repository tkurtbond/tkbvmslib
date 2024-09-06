$!> SCREAM.COM -- Scream and stop.
$! Unfortunately outputs a bunch of new lines.
$	bell[0,8]      = 7                   ! define bell
$       i = 0 
$ 10$:
$       i = i + 1
$	write sys$output bell
$	wait 00:00:01
$	if i .lt. 5 then goto 10$
$ 19$:
