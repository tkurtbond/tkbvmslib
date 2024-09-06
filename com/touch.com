$!> TOUCH.COM - If file exists, update modifiy time; else create empty file.
$       i = 1
$ 10$:  filename = p'i'
$       if filename .eqs. "" then goto 15$
$       foundfile = f$search (filename)
$       if foundfile .eqs. ""
$       then
$           create/file 'filename'
$       else
$           prot = f$file (filename, "PRO")
$           set file/prot=('prot') 'filename'
$       endif
$ 15$:  i = i + 1
$       if i .le. 8 then goto 19$
$ 19$:
