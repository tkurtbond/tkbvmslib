$ !> LISTPRIV.COM -- list the privs in the priv stack.
$
$ 	inhibit_message = %x10000000
$ 	error_exit = 2 .or. inhibit_message
$
$ 	cur_privs = f$getjpi (0, "CURPRIV")
$ 	msg = "Current: "
$ 	write/sym sys$output msg, cur_privs
$ 	if (f$type (tkb_priv_depth) .nes. "INTEGER")
$ 	then 
$	    write sys$error "No privs in stack!"
$	    exit error_exit
$ 	endif
$ 	if (tkb_priv_depth .le. 0)
$ 	then 
$	    write sys$error "No privs in stack!"
$	    exit error_exit
$ 	endif
$ 	write sys$output "Stack Depth: ", tkb_priv_depth
$ 	i = tkb_priv_depth
$ top:
$	s = f$string (i) +  ": " + tkb_priv_stack_'i'
$	write/sym sys$output s
$	i = i - 1
$ 	if i .gt. 0 then goto top
$ end:
