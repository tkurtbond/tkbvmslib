$!> IF_EXISTS.COM -- Execute the command file in p1 if it exists
$ filename = f$parse(p1, ".com")
$ if f$search(filename) .nes. "" 
$ then
$     @'filename' 'p2' 'p3'   
$ else
$     write sys$error "error: cannot find ''p1'"
$     exit 1			! so won't insult/kill caller
$ endif
