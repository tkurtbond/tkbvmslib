program scream
    option type = explicit, constant type = integer, &
        size = integer long, size = real double

    declare integer delay, times, i, ctrl_c


    times = 0
    delay = 1

	when error use exit_verbosely
	ctrl_c = ctrlc

	i = 0
	while -1
	      print BEL;
	      i = i + 1
	      sleep delay
	next

    end when

    handler exit_verbosely
      if err = 28 then
         print "Interrupted by CTRL/C after"; i; " iterations"
      end if
    end handler
end program ! scream 
