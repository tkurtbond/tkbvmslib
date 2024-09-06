$!> LISTSRC.COM - List Webmail Communicator source files.
$       l :== $mpl$data:[mpl.tkb.tkbvmslib.exe]l.exe ! I don't think this is there...
$       l -o st_tmp:mwmc_src.lis *.txt *.text *.bas *.inc *.com *.dis *.fdl *.mms *.msg 
$! -u doesn't work
$       stsort <~tmp/mwmc_src.lis >~tmp/mwmc_src_sorted.lis
$       uniq <~tmp/mwmc_src_sorted.lis >~tmp/mwmc_src_uniq.lis
$       sed -e "s/^/ar uv mwmc.w /" <st_tmp:mwmc_src_uniq.lis >st_tmp:mwmc_to_w.sh
