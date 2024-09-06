$!> NOTHING.COM -- Do nothing useful.
$       write sys$output ""
$       write sys$output "==============================================================================="
$       write sys$output "Wecome to nothing!"
$       write sys$output "==============================================================================="
$       write sys$output ""
$       proc = f$environment ("PROCEDURE")
$       write sys$output "Command Procedure: ", proc
$       write sys$output "Time: ", f$cvtime ()
$       write sys$output "Default Directory: "
$       show default
$       i = 0
$ 10$:
$       i = i + 1
$       if p'i' .eqs. "" then goto 19$
$       write sys$output "p",i, ": """, p'i', """"
$       goto 10$
$ 19$:
