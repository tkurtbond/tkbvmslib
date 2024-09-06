$ verifying = 'f$verify(f$type(dircompare_verify) .nes. "")'
$ !> DIRCOMPARE.SDCL - Compare two directory trees.
$ wso := write sys$output
$ wse := write sys$error
$ TRUE = 1 .eq. 1
$ FALSE = .not. TRUE
$ if (.not.(p1 .eqs. "" .or. p2 .eqs. "")) then goto 23000
$ goto usage
$ 23000: 
$ dir1 = p1
$ dir2 = p2
$ stream1 = 1
$ stream2 = 2
$ start = -1
$ fs1 = ""
$ fs2 = ""
$ 23002: 
$ if (.not.(start .or. (fs1 .nes. ""))) then goto 23005
$ fs1 = f$search (dir1, stream1)
$ 23005: 
$ if (.not.(start .or. (fs2 .nes. ""))) then goto 23007
$ fs2 = f$search (dir2, stream2)
$ 23007: 
$ wso "fs1: ", fs1
$ wso "fs2: ", fs2
$ if (.not.(start)) then goto 23009
$ start = FALSE
$ 23009: 
$ 23003: if (.not.((fs1 .eqs. "") .and. (fs2 .eqs. "") )) then goto 23002
$ 23004: 
$ the_end:
$ exit (1 .or. (f$verify(verifying) .and. 0))
$ usage:
$ copy sys$input sys$error
 usage: dircompare dir1 dir2
$ exit (2 .or. (f$verify(verifying) .and. 0))
