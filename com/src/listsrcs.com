$!> LISTSRCS.COM - List source files.
$!-----------------------------------------------------------------------------
$! This is here as example of using lc, stsort, uniq, and sed to make a shell
$! script that puts all the listed files into an archive.
$!----------------------------------------------------------------------------
$       lc :== $mpl$data:[mpl.tkb.tkbvmslib.exe]lc.exe ! uses the C version of the lister.
$       lc -o st_tmp:src.lis *.txt *.text *.bas *.inc *.com *.dis *.fdl *.mms *.msg 
$! -u doesn't work
$       stsort <~tmp/src.lis >~tmp/src_sorted.lis
$       uniq <~tmp/src_sorted.lis >~tmp/src_uniq.lis
$       sedit "s/%/ar uv mwmc.w /" <st_tmp:src_uniq.lis >st_tmp:src_to_w.sh
