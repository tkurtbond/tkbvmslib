$ if p1 .eqs. "" then p1 = "mailfolders.lis"
$ define/user sys$output 'p1
$ mail
dir/fo
$ exit
