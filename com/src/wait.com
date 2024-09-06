$ write sys$output "Start: ", f$cvtime ()
$ wait 'p1
$ write sys$output "Wake:  ", f$cvtime ()
$ loop -wait=0:0:15 scream
