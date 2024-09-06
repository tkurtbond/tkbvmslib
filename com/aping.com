$       sleep = "0:0:5"
$       if p2 .nes. "" then sleep = p2
$       bell[0,8] = 7
$ 10$:  on error then goto 14$
$       mu ping 'p1'/number=1
$ 14$:  status = $status
$       if status .eq. 1 then write sys$output bell
$       wait 'sleep'
$       goto 10$
$ 19$: exit
