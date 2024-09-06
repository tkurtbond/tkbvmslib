$       verifying = 'f$verify(f$type(newver_verify) .nes. "")'
$	quiet = %x10000000
$       wso := write sys$output
$       wse := write sys$error
$
$       dbg = "!"
$!      dbg := write sys$error
$
$       filespec = p1
$       filespec = f$parse (filespec)
$       'dbg' "filespec: ", filespec
$       foundspec = f$search (filespec)
$       if foundspec .eqs. ""
$       then
$           wse "error: filespec ", filespec, ", not found, exiting..."
$           exit (2 .or. quiet)
$       endif
$       'dbg' "f$search: ", foundspec
$       timestamp = f$extract (0, 10, f$cvtime ())
$       i = 0
$ 10$:
$       version = f$parse (foundspec,,, "VERSION")
$       name = f$parse (foundspec,,,"NAME") + "_" + timestamp
$       if i .ge. 1 then name = name + "_" + f$string (i)
$       newname = f$parse (name, foundspec) - version
$       newfound = f$search (newname)
$       if newfound .eqs. "" then goto 19$
$       i = i + 1
$       goto 10$
$ 19$:
$
$       'dbg' "Newname: ", newname
$       copy/log 'foundspec' 'newname'
$       exit (1 .or. quiet .or. (f$verify(verifying) .and. 0))
