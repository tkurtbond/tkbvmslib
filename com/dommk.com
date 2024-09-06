$!> DOMMK.COM -- Direct MMK commands to a command procedure and execute it.
$! MMK and some of the SWTOOLS VOS programs don't get along.
$ uniqifier = f$time() - "-" - "-" - " " - ":" - ":" - "."
$ outfile = "domake_" + f$getjpi ("","PID") + "_" + uniqifier + ".tmp"
$ mmk/noact/out='outfile' 'p1' 'p2' 'p3' 'p4' 'p5' 'p6' 'p7' 'p8'
$ @'outfile'
$ delete/log 'outfile';0
