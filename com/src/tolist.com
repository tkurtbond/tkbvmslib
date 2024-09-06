$!> TOLIST.COM - Generate files with the PROGRAMS variable and the install target.
$! Output goes to PROGRAMS.GENMMS, INSTALL.GENMMS, and RULES.GENMMS.
$       num_filenames = 0
$       open /read f programs.dat
$ 10$:
$       read/end_of_file=19$ f filename
$       filename = f$edit (filename, "COLLAPSE,UNCOMMENT")
$       if filename .eqs. "" then goto 10$
$       num_filenames = num_filenames + 1
$       fn_list_'num_filenames' = filename
$       goto 10$
$ 19$:
$       close f
$       open /write prog programs.genmms
$       write prog "PROGRAMS= -"
$       open /write inst install.genmms
$       write inst "install-programs : -"
$       open/write rule rules.genmms
$       i = 1
$ 20$:
$       if i .gt. num_filenames then goto 29$
$       write prog  "    ", fn_list_'i', " -"
$       write inst  "    [-]", fn_list_'i', " -"
$       write rule  "[-]", fn_list_'i', " : ", fn_list_'i'
$       write rule  "    copy /log $(MMS$SOURCE) $(MMS$TARGET)"
$       i = i + 1
$       goto 20$
$ 29$:
$       write prog  "    ", "! end of programs"
$       write inst  "    ", "! end of install
$       close prog
$       close inst
$       close rule
