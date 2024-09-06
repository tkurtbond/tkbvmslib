$ quebatch = "$dms:quebatch"
$ define/user sys$input sys$command
$ quebatch 'p1'/replace/output/noprint/nodelete
