$	write sys$output "====> Testing dirspec_to_dirfile.sdcl ========================================="
$       filespecs = "/foo.bar/foo.dir/[]/[foo]/[foo.bar]/[foo.bar.baz]/[.foo]/[.foo.bar]/[foo.bar]baz.dir"
$       i = 0
$ 10$:
$       filespec = f$element (i, "/", filespecs)
$       if filespec .eqs. "/" then goto 19$
$       write sys$output "Converting """, filespec, """"
$       @todirfile 'filespec'
$       show sym todirfile_*
$       write sys$output "Status: ", todirfile_status
$       write sys$output "Value: ", todirfile_value
$       i = i + 1
$       goto 10$
$ 19$:
