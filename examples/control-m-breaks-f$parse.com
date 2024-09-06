$! The following f$parse returns a empty string.  Notice the Control-M?
$ x = f$parse ("TON$DATA:[MINES.TON]ST2022.DTA",,, "DEVICE", "NO_CONCEAL")
$ write sys$output "length of x: ", f$length (x)
$ write sys$output "x: ", x
