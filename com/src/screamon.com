$!> SCREAMON.COM -- Scream On!
$	bell[0,8]      == 7                   ! define bell
$ 10$:
$	write sys$output bell, bell, bell, bell, bell
$	wait 00:00:02
$	goto 10$
$ 19$:	! You never get here.
