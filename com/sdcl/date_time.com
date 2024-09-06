$ verifying = 'f$verify(f$type(date_time_verify) .nes. "")'
$ !> DATE_TIME.SDCL -- Date and time pretty printer.
$ true = (1 .eq. 1)
$ false = .not. true
$ wso := write sys$output
$ inq := inquire/nopun
$ on warning then exit (1 .or. (f$verify(verifying) .and. 0))
$ debug = true
$ format = "The date is !AS, !AS !AS!AS, !AS. The time is !AS !AS."
$ months = "January-February-March-April-May-June-" + "July-August-September-October-November-December"
$ if (.not.(p1 .eqs. "")) then goto 23000
$ work_time = f$cvtime(,"ABSOLUTE")
$ goto 23001
$ 23000: 
$ work_time = p1
$ 23001: 
$ month_day = f$cvtime(work_time, "absolute", "day")
$ week_day = f$cvtime(work_time, "absolute", "weekday")
$ month = f$cvtime(work_time, "comparison", "month")
$ year = f$cvtime(work_time, "absolute", "year")
$ hour = f$cvtime(work_time, "absolute", "hour")
$ minute = f$cvtime(work_time, "absolute", "minute")
$ second = f$cvtime(work_time, "absolute", "second")
$ hundredth = f$cvtime(work_time, "absolute", "hundredth")
$ day = f$integer(month_day)
$ day_tag = "th"
$ if (.not.(day .eq. 1 .or. day .eq. 21 .or. day .eq. 31)) then goto 23002
$ day_tag = "st"
$ 23002: 
$ if (.not.(day .eq. 2 .or. day .eq. 22)) then goto 23004
$ day_tag = "nd"
$ 23004: 
$ if (.not.(day .eq. 3 .or. day .eq. 23)) then goto 23006
$ day_tag = "rd"
$ 23006: 
$ hour_int = f$integer(hour)
$ if (.not.(hour_int .gt. 12)) then goto 23008
$ hour = f$string(hour_int - 12)
$ am_pm = "pm"
$ goto 23009
$ 23008: 
$ hour = f$string(hour_int) 
$ am_pm = "am"
$ 23009: 
$ wso f$fao(format, week_day, f$element(f$integer(month) - 1, "-", months),month_day, -
  day_tag, year, hour+":"+minute, am_pm)
$ The_End:
$ exit (1 .or. (f$verify(verifying) .and. 0))
