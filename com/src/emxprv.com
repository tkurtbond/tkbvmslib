$ 	set proc/priv=bypass
$	args		= p1 + " " p2 + " " + p3 + " " + p4 + " " + p5 + " " -
			+ p6 + " " + p7 + " " + p8
$ 	runemacs 'args'
