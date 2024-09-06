program uptime
    option type = explicit, constant type = integer, &
        size = integer long, size = real double 

    %include "starlet"         %from %library "sys$library:basic$starlet"
    %include "$syidef"         %from %library "sys$library:basic$starlet"
    %include "lib$routines"    %from %library "sys$library:basic$starlet"

    record quadword
        long a
        long b
    end record

    declare long result, item
    declare word length
    declare string boot_time$, current_time$, result_delta$
    declare basic$quadword boot_time, current_time, result_delta
    item = SYI$_BOOTTIME
    declare string constant blanks = "                         "
    boot_time$ = blanks
    current_time$ = blanks
    result_delta$ = blanks

    result = lib$getsyi (item, boot_time,,,,)
    !print "lib$getsyi result: "; result
    result = sys$gettim (current_time)
    !print "sys$gettim result: "; result
    result = lib$sub_times (current_time, boot_time, result_delta)
    !print "lib$sub_times result: "; result
    result = sys$asctim (, boot_time$, boot_time, )
    !print "sys$asctim of boot_time result: ", result
    result = sys$asctim (, current_time$, current_time, )
    !print "sys$asctime of current_time result: ", result
    result = sys$asctim (, result_delta$, result_delta, )
    !print "sys$asctim of result_delta result: ", result
    !print result, ">"; edit$ (result_delta$, 8+128); "<"
    print edit$ (current_time$, 8+128); &
          ' - '; edit$ (boot_time$, 8+128); ' = '; &
          edit$ (result_delta$, 8+128)
end program ! uptime
