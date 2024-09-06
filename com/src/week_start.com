$ verifying = 'f$verify(f$type(week_start_verify) .nes. "")'
$!> WEEK_START.COM -- Find the date of Monday that started the week.
$! p1 = optional symbol to store the week start date.
$! p2 = optional symbol to store the week end date.
$!
$! If p1 is not supplied, the week start date and week end date will be 
$! displayed.
$!-----------------------------------------------------------------------------
$! The week names and trailing spaces and "/" are all 10 characters long,
$! except for Sunday, so position / 10 is in [0,6].
$	dow_list = "MONDAY   /TUESDAY  /WEDNESDAY/THURSDAY /" + -
		   "FRIDAY   /SATURDAY /SUNDAY"
$	dow_len = f$length (dow_list)
$
$	time = f$time ()
$	dow = f$cvtime (time,,"WEEKDAY")
$	dow = f$edit (dow, "UPCASE")
$	dow_pos = f$locate (dow, dow_list)
$	if dow_pos .eq. dow_len
$	then
$		write sys$error proc_name, -
		    " - fatal programmer error: unable to find """, dow, -
		    """ in """, dow_list, """"
$		exit (2 .or. (f$verify(verifying) .and. 0))
$	endif
$	! dow_num is zero-based, with Monday = 0 and Sunday = 6.
$	dow_num = dow_pos / 10
$	
$! Return the absolute date form, so it can be used as input to f$cvtime()
$! in the caller.
$	week_start = f$cvtime (time + "-''dow_num'-", "ABSOLUTE", "DATE")
$	week_end   = f$cvtime (week_start + "+6-",    "ABSOLUTE", "DATE")
$	if p1 .nes. ""
$	then ! symbol supplied, set it.
$	    'p1' == week_start
$	    if p2 .nes. "" then 'p2' == week_end
$	else ! symbol *not* supplied, display week start.
$	    write sys$output week_start, " ", week_end
$	endif
$
$	exit (1 .or. (f$verify(verifying) .and. 0))
