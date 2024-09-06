$ !> TIME_DIFF.SDCL -- Find difference in hours and minutes of two times
$ TRUE = (1 .eq. 1)
$ FALSE = .not. TRUE
$ wso = "write sys$output"
$ get = "read sys$command"
$ last_end_time = "" 
$ last_description = ""
$ get start_time /prompt="Start Time:  "
$ 23000: if (.not.(start_time .nes. "")) then goto 23002
$ start_time = f$edit(start_time, "compress")
$ if (.not.(start_time .eqs. "=")) then goto 23003
$ start_time = last_end_time
$ wso "        Start Time is: ", start_time
$ 23003: 
$ get end_time /prompt="End Time:    "
$ end_time = f$edit(end_time, "compress")
$ last_end_time = end_time
$ st_len = f$length(start_time)
$ et_len = f$length(end_time)
$ i = f$locate(".", start_time)
$ if (.not.(i .ne. st_len)) then goto 23005
$ start_time[i*8, 8] = 58 
$ 23005: 
$ j = f$locate(".", end_time)
$ if (.not.(j .ne. et_len)) then goto 23007
$ end_time[j*8, 8] = 58 
$ 23007: 
$ i = f$locate(":", start_time)
$ j = f$locate(":", end_time)
$ st_hours = f$integer(f$extract(0, i, start_time))
$ st_minutes = f$integer(f$extract(i+1, st_len, start_time))
$ et_hours = f$integer(f$extract(0, j, end_time))
$ if (.not.(et_hours .lt. st_hours)) then goto 23009
$ et_hours = et_hours + 12 
$ 23009: 
$ et_minutes = f$integer(f$extract(j+1, et_len, end_time))
$ temp_dur = ((et_hours * 60) + et_minutes) - ((st_hours * 60) + st_minutes)
$ duration = f$fao("!ZL:!2ZL", temp_dur / 60, temp_dur - ((temp_dur / 60) -
  * 60))
$ write sys$output f$fao("Duration:    !AS", duration)
$ 23001: get start_time /prompt="Start Time:  "
$ goto 23000
$ 23002: 
$ The_End:
$ exit
