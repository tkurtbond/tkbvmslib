$! betags :== @dir:make_basic_etags.com $$$
$ proc = f$environment("PROCEDURE")
$ where = f$parse(proc,,, "DEVICE") + f$parse(proc,,, "DIRECTORY")
$ name = f$parse(proc,,, "NAME")
$ edit/tpu/nosection/noini/nodisplay/command='where''name'.tpu -
	'p2 'p3 'p4 'p5 'p6 'p7 'p8
