$!> list_printers.com -- List the printers w/o blank lines and each on one line.
$ show que/dev=printer/out=sys$scratch:printers.lis
$ ed t:printers.lis
g/%[  ]*$/d
g/TCP/.-1,.j
w sys$login:printers_oneline.lis
$ delete t:printers.lis.*
$ exit
