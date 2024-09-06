$ x =   f$parse("sys$disk:[]",,, "DEVICE") + -
	f$parse("sys$disk:[]",,, "DIRECTORY")
$ write sys$output "here: ", x
$ define here 'x'
