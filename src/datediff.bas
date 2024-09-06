!------------------------------------------------------------------------------
!> DATEDIFF.BAS -- Find the difference of two VMS absolute datetimes.
!------------------------------------------------------------------------------
program datediff
    option type = explicit, constant type = integer, &
        size = integer long, size = real double

    %include "starlet"         %from %library "sys$library:basic$starlet"
    %include "$syidef"         %from %library "sys$library:basic$starlet"
    %include "$ssdef"          %from %library "sys$library:basic$starlet"
    %include "lib$routines"    %from %library "sys$library:basic$starlet"

    external long function                                                    &
        cli$present(string),                                                  &
        cli$get_value(string, string),                                        &
        cli$dcl_parse

    external long constant datediff_cli


    ! "dd-mmm-yyyy hh:mm:ss.cc" 23 characters
    ! "dddd hh:mm:ss.cc" 16 characters
    map (dt) &
        string minuend$ = 23, &
        string subtrahend$ = 23, &
        string difference$ = 16

    !+++
    ! If not enclosed in double quotes, use a colon between the date
    ! and the time:
    !     datediff 22-AUG-2024:12:10:11.36 21-AUG-2024:12:01:30.02
    !
    ! The space between the date and time is fine if the datetime is
    ! enclosed in double quotes:
    !     datediff "22-AUG-2024 12:10:11.36" "21-AUG-2024 12:01:30.02"
    !
    ! And you can use any VMS datetime specification:
    !    datediff today "today-1-" 
    !---
    declare long result
    declare basic$quadword minuend, subtrahend, difference
    declare string command_line

    call lib$get_foreign (command_line)
    result = cli$dcl_parse ("DATEDIFF " + command_line,                       &
                            datediff_cli by value,                            &
                            loc (lib$get_input) by value, &
                            loc (lib$get_input) by value, &
                            "DATEDIFF> ")
    if (result and 1) = 0 then
        exit program result
    end if

    call cli$get_value ("MINUEND", minuend$)
    call cli$get_value ("SUBTRAHEND", subtrahend$)
    
    mid$ (minuend$, 12, 1) = " " if mid$ (minuend$, 12, 1) = ":"
    mid$ (subtrahend$, 12, 1) = " " if mid$ (subtrahend$, 12, 1) = ":"

    result = sys$bintim (minuend$, minuend)
    if (result and 1) = 0 then
        print 'datediff: unrecognized date minuend: "'; edit$ (minuend$, 8+128); '"'
        exit program SS$_BADPARAM
    end if  

    result = sys$bintim (subtrahend$, subtrahend)
    if (result and 1) = 0 then
        print 'datediff: unrecognized date subtrahend: "'; edit$ (subtrahend$, 8+128); '"'
        exit program SS$_BADPARAM
    end if  

    result = lib$sub_times (minuend, subtrahend, difference)
    if (result and 1) = 0 then
        print "datediff: unable to subtract times!"
        exit program result
    end if 
    
    result = sys$asctim (, difference$, difference, )
    if (result and 1) = 0 then
        print "datediff: unable to convert difference to text!"
        exit program result
    end if 

    print minuend$; " - "; subtrahend$; " = "; edit$(difference$, 8+128)

    exit program

end program ! datediff
