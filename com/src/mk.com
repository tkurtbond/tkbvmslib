$!> MK.COM -- Run MMK with a preceeding header to make it obvious where the mmk output starts.
$ header = "################################################################################"
$ write sys$output header
$ write sys$output header
$ write sys$output header
$ mmk 'p1 'p2 'p3 'p4 'p5 'p6 'p7 'p8
