$       verifying = 'f$verify(f$type(diskusage_verify) .nes. "")'
$!> DISKUSAGE.COM -- Show disk space free, used, max for mounted disk drives.
$!                   Sets the symbol DISKUSAGE_LOW_PERCENT to percentage that
$!                   is considered too low and  DISKUSAGE_LOW_DISKS to a list 
$!                   of the disks that are too low on disk space.
$!
$!                   This procedure ignores drives whose names start with ZRA,
$!                   because those are comperssed drives that don't change.
$!-----------------------------------------------------------------------------
$! Vers  When        Who  What
$! 1.0   ????-??-??  tkb  Initial version
$! 2.0   2022-03-30  tkb  Added percent free and used and unit suffixes.
$! 2.1   2023-09-22  tkb  Added color and warning of disks low on free space.
$! 2.2   2023-09-25  tkb  Lots of bug fixes and redo parameter parseing.
$!-----------------------------------------------------------------------------
$       dbg = "!"
$!       dbg := write sys$error
$
$       procedure = f$env ("PROCEDURE")
$       'dbg' "Procedure: ", procedure
$       'dbg' "Version: 2.2"
$
$       procedure_directory = f$parse(f$env ("PROCEDURE"),,,"DIRECTORY")
$       if f$locate ("[MPLLIB", procedure_directory) .ne. f$length (procedure_directory)
$       then
$           percent := $ml:percent.exe
$       else
$           percent := $exe:percent.exe
$       endif
$
$       quiet = %x10000000
$       exit_status = 1
$       default_disusage_low_percent = 10 	! Set the default low diskspace precentage
$       diskusage_low_percent == default_disusage_low_percent ! set global symbol for callers to use
$       diskusage_low_disks == ""       ! set global symbol for callers to use
$       use_colors = -1
$       force_colors = 0
$       outfilelnm := sys$output
$       outfilename = ""
$
$       if (p1 .eqs. "-HELP") .or. (p1 .eqs. "-H") then goto usage
$
$       opt_list = "/COLOR/HELP/NOCOLOR/OUTPUT/PERCENT/"
$       opt_list_len = f$length (opt_list)
$
$       i = 1
$ 10$:  if i .gt. 8 then goto 19$       ! Command procedures can only have 8 parameters
$       opt = p'i'
$       i = i + 1
$       if opt .eqs. "" then goto 19$
$       if f$extract (0, 1, opt) .nes. "-" then goto 19$
$       which = f$extract(1, 3, opt)
$       ok = f$locate ("/" + which, opt_list) .ne. opt_list_len
$       if .not. ok
$       then
$           write sys$error "error: unknown option ", opt
$           exit_status = 2
$           goto usage
$       endif
$       gosub OPT$'which'
$       goto 10$
$ 19$:
$
$!      'dbg' "mode: ", f$mode()
$!      'dbg' "sys$input: ", f$trnlnm ("SYS$INPUT")
$!      'dbg' "sys$command: ", f$trnlnm ("SYS$COMMAND")
$!      'dbg' "sys$output: ", f$trnlnm ("SYS$OUTPUT")
$
$       if (f$mode () .eqs. "BATCH") .or. (outfilename .nes. "") then if .not. force_colors then use_colors = 0
$
$
$!      if diskusage_low_percent .le. 0 then diskusage_low_percent == default_disusage_low_percent
$       esc[0,8] = %x1B ! String now contains an ESC.
$       csi = esc + "["
$       red = csi + "1;31m"
$       normal = csi + "0m"
$
$       'dbg' "SYS$NODE: ", f$trnlnm ("SYS$NODE")
$
$       write 'outfilelnm' ""
$       write 'outfilelnm' "Disk Usage on ", f$trnlnm ("SYS$NODE"), " at ", f$cvtime ()
$       write 'outfilelnm' ""
$
$! Some of the columns need two spaces after them so the units can stick into them.
$       write 'outfilelnm' f$fao ("!15AS !15AS !11AS  !11AS  !3AS !11AS  !3AS", -
                                  "Device", "Volume label", "Max blocks", -
                                  "Free blocks", "%fr", "Used blocks", "%us")
$       write 'outfilelnm' f$fao ("!15*- !15*- !11*-  !11*-  !3*- !11*-  !3*-")
$
$       total_maxblocks = 0 
$       total_freeblocks = 0
$       total_usedblocks = 0
$ 20$:
$       device_name = f$device (, "DISK")
$       if device_name .eqs. "" then goto 29$
$       if .not. f$getdvi (device_name, "MNT") then goto 20$
$       volume_label = f$getdvi(device_name, "VOLNAM")
$       maxblocks = f$getdvi (device_name, "MAXBLOCK")
$       total_maxblocks = total_maxblocks + maxblocks
$       freeblocks = f$getdvi (device_name, "FREEBLOCKS")
$       percent_free = freeblocks * 100 / maxblocks
$       percent_used = 100 - percent_free
$
$       prefix = ""
$       suffix = ""
$       if (percent_free .le. diskusage_low_percent) .and. (f$locate ("ZRA", -
            device_name) .eq. f$length (device_name))
$       then
$           if diskusage_low_disks .eqs. ""
$           then
$               diskusage_low_disks == device_name
$           else
$               diskusage_low_disks == diskusage_low_disks + "," + device_name
$           endif
$           if use_colors
$           then
$               prefix = red
$               suffix = normal
$           else
$               suffix = "!"
$           endif
$       endif
$
$       total_freeblocks = total_freeblocks + freeblocks
$       usedblocks = maxblocks - freeblocks
$       total_usedblocks = total_usedblocks + usedblocks
$       msg =  prefix + f$fao ("!15AS !15AS !11SL  !11SL  !3SL !11SL  !3SL", -
                        device_name, volume_label, maxblocks, freeblocks,-
                        percent_free, usedblocks, percent_used) + suffix
$       length = f$len (msg)
$       !write 'outfilelnm' "Length: ", length
$       write 'outfilelnm' msg
$       goto 20$
$ 29$:
$       percent 'total_freeblocks' 'total_maxblocks'
$       total_percent_free = f$integer (percent_result)
$       total_percent_used = 100 - total_percent_free
$       write 'outfilelnm' f$fao ("!15*- !15*- !11*-  !11*-  !3*- !11*-  !3*-")
$       write 'outfilelnm' f$fao ("!15*  !15*  !11SL  !11SL  !3SL !11SL  !3SL", -
                total_maxblocks, total_freeblocks, total_percent_free, total_usedblocks, total_percent_used)
$       write 'outfilelnm' f$fao ("!15*  !15*  !11SLK !11SLK !3*  !11SLK !3* ", -
                total_maxblocks / 2, total_freeblocks / 2, total_usedblocks / 2)
$       write 'outfilelnm' f$fao ("!15*  !15*  !11SLM !11SLM !3*  !11SLM !3* ", -
                total_maxblocks / 2 / 1024, total_freeblocks / 2 / 1024, total_usedblocks / 2 / 1024)
$       if diskusage_low_disks .nes. ""
$       then
$           if use_colors
$           then
$               prefix = red
$               suffix = normal
$           endif
$           write 'outfilelnm' "The following disks are low on space:"
$           i = 0
$           disks = ""
$ 30$:      disk = f$element (i, ",", diskusage_low_disks)
$           if disk .eqs. "," then goto 39$
$           len = (f$length (disks) + f$length (disk))
$           if disks .nes. "" then len = len + 2 ! for the comma, space
$           if  len .gt. 76
$           then
$               write 'outfilelnm' "    ", prefix, disks, suffix
$               disks = ""
$           endif
$           if disks .nes. ""
$           then
$               disks = disks + ", " + disk
$           else
$               disks = disk
$           endif
$           i = i + 1
$           goto 30$
$           
$ 39$:
$           if disks .nes. "" then -
                write 'outfilelnm' "    ", prefix, disks, suffix
$           write 'outfilelnm' "They had ''diskusage_low_percent'% or less free space"
$       endif
$ the_end:
$       if outfilename .nes. "" then close 'outfilelnm'
$       exit (exit_status .or. quiet .or. (f$verify(verifying) .and. 0))
$ usage:
$       copy sys$input sys$error
usage: @diskusage [-NOCOLOR] [-OUTPUT=outfilename] [-PERCENT=PERCENT_TOO_LOW]

DISKUSAGE displays a list of disk devices with the device name, the
volume label, the maximum number of blocks the disk has, the number of
free blocks the disk has, the percentage of free blocks the disk has,
the used blocks the disk has, and the percentage of used blocks the
disk has.  It also returns the PERCENT_TO_LOW value in the DCL global
symbol DISKUSAGE_LOW_PERCENT and the list of disks that are low on
space in the DCL global symbol DISKUSAGE_LOW_DISKS.

-NOCOLOR
        Don't use color to emphasize the disks that are lon on disk space.
        Color is only used for interactive sessions.  When not using color
        disks that are low on disk space have an exclamation mark after
        the "%us" column.

-OUTPUT=outfilename
        Specify a filename to write output to.

-PERCENT=PERCENT_TOO_LOW
        Specify the percentage of disk space that results in a low disk space
        warning. If -PERCENT is not specified it defaults to 10%.

Examples:

    $! Does not use color output.
    $ @diskusage -nocolor
    $! Warn about all disks that have 50% or less free space.
    $ @diskusage -percent=50
$       goto the_end
$!
$! Process options
$ OPT$col:
$       force_colors = -1
$       return
$
$ OPT$hel:
$       goto usage
$
$ OPT$noc:
$       use_colors = 0
$       return
$
$ OPT$out:
$       len = f$length (opt)
$       pos = f$locate ("=", opt)
$       if pos .ne. len
$       then
$           outfilename = f$extract (pos+1, len, opt)
$           outfilelnm = "outf"
$           open/write/error=open_file_error 'outfilelnm' 'outfilename'
$       else
$           write sys$error "-output=F: Expected a filename, F."
$           exit_status = 2
$           goto usage
$       endif
$       return
$
$ open_file_error:
$       errstat = $status
$       write sys$error "$status: ", errstat
$       exit_status = errstat .and. (.not. quiet)
$       quiet = 0
$       write sys$error "error: unable to open file: ", outfilename
$       goto the_end
$
$ OPT$per:
$       len = f$length (opt)
$       pos = f$locate ("=", opt)
$       if pos .ne. len
$       then
$           diskusage_low_percent == f$integer (f$extract (pos+1, len, opt))
$       else
$           write sys$error "-percent=X: Expected an integer, X."
$           exit_status = 2
$           goto usage
$       endif
$       return
