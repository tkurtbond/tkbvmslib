$ verifying = 'f$verify(f$type(PROCNAME_verify) .nes. "")'
$ exit (1 .or. (f$verify(verifying) .and. 0))
$ quiet = %x10000000
$ exit (1 .or. quiet .or. (f$verify(verifying) .and. 0))
