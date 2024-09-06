$ !> PUSHPRIV.COM -- push old privs onto stack and set new privs.
$
$ 	old_privs = f$getjpi (0, "CURPRIV")
$ 	s = "Old Privs: " + old_privs
$ 	write/sym sys$output s
$
$ 	if (f$type (tkb_priv_depth) .nes. "INTEGER")
$ 	then 
$	    tkb_priv_depth == 0
$ 	endif
$ 	add_privs = p1
$ 	if f$length (add_privs) .eq. 0 
$ 	then
$	    write sys$output "usage: pushpriv add_privs"
$	    exit 2
$ 	endif
$ 	tkb_priv_depth == tkb_priv_depth + 1
$ 	tkb_priv_stack_'tkb_priv_depth' == old_privs
$ 	t = "Add Privs: " + add_privs
$ 	write/sym sys$output t
$ 	set proc/priv=(noall, 'old_privs', 'add_privs')
$	new_privs = f$getjpi (0, "CURPRIV")
$	u = "New privs: " + new_privs
$	write/sym sys$output u
