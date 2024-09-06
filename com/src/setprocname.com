$	set message/noid/nofac/nosev/notext
$	cnt = 1
$	username = f$edit (f$getjpi (0,"USERNAME"), "LOWERCASE,TRIM")
$ name:	on error then goto err
$ 	name = username
$ 	if cnt .gt. 1 then name = username + "_" + f$string(cnt)
$ 	set proc/name="''name'"
$ 	goto cont
$ err:	cnt = cnt + 1
$ 	goto name
$ cont: on error then exit
