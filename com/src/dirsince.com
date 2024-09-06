$!> DIRSINCE.COM -- Do a DIR of files modified since file's modification date.
$	QUIET = %x10000000
$       if (p1 .eqs. "-H") .or. (p1 .eqs. "-HELP") .or. (p1 .eqs. "-?") then goto usage
$       filename = p1
$       dirname = p2
$       fspec = f$search (filename)
$       if fspec .eqs. "" then goto file_not_found
$
$       modification = f$file_attributes (filename, "RDT")
$       write sys$output "Modification date time: ", modification
$       directory/since="''modification'" 'dirname'
$       exit
$ usage:
$       copy sys$input sys$output
Usage: @dirsince FILENAME [ DIRECTORY ]

DIRSINCE does a DIRECTORY listing of files modified since FILENAME's
modification date.  If DIRECTORY is specified it is used as the
directory which is listed.

$	exit 2 .or. QUiET
$!
$ file_not_found:
$       write sys$error "dirsince: The file ", filename, " was not found.  Exiting."
$       exit 2 .or. QUIET
