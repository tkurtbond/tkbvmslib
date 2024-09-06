$!> FILE2DIR.COM - Convert [A]B.DIR to [A.B]
$	filespec = p1
$	filetype = f$parse (filespec,,,"TYPE")
$	if filetype .nes. ".DIR"
$	then
$	    write sys$output "file2dir: error: filespec ", filespec, " is not a directory."
$	    exit %X000380E2
$	endif
$	name = f$parse (filespec,,, "NAME")
$	as_dir = f$parse (filespec,,, "DEVICE") + -
		 f$parse (filespec,,, "DIRECTORY") - "]" + "." + name + "]"
$	write sys$output as_dir
