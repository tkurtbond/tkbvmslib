$!> PUSHD.COM -- push directories onto stack
$	if (f$type (tkb_dirstack_depth) .nes. "INTEGER")
$	then 
$	    tkb_dirstack_depth == 0
$	endif
$	newdir == p1
$	if f$length (newdir) .eq. 0
$	then
$	    write sys$output "usage: pushd newdir"
$	    exit 2
$	endif
$	olddir = f$environment ("DEFAULT")
$	tkb_dirstack_depth == tkb_dirstack_depth + 1
$	tkb_dirstack_'tkb_dirstack_depth' == olddir
$	if f$type (sd) .nes. ""
$	then 
$	    sd 'newdir'
$	else
$	    set def 'newdir'
$	    show def
$	endif 
