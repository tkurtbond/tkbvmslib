$ !> AUTHORIZE.COM -- run authorize then restore directory and privs
$	authorize = "$authorize"
$	directory = f$parse("",,,"device") + f$directory() ! current location
$	old_priv = f$setprv("sysprv")			   ! set syspriv
$	set def sys$system				   ! files location
$	assign/usermode sys$command sys$input		   ! keep this proc
$	authorize 'p1 'p2 'p3 'p4 'p5 'p6 'p7 'p8 	   ! do the work
$	new_priv = f$setprv(old_priv)			   ! restore prev priv
$	set def 'directory'				   ! restore prev loc
$	exit
