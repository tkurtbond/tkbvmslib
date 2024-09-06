$!> POPD.COM -- pop directories from stack
$	if (f$type (tkb_dirstack_depth) .nes. "INTEGER")
$	then 
$	    tkb_dirstack_depth == 0
$	endif
$	if tkb_dirstack_depth .le. 0
$	then 
$	    write sys$output "popd: depth is .le. 0!"
$	    exit 2
$	endif
$	olddir = tkb_dirstack_'tkb_dirstack_depth'
$	tkb_dirstack_depth == tkb_dirstack_depth - 1
$	set def 'olddir'
$	show def
