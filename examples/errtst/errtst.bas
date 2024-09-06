program errtst
    option type = explicit, constant type = integer, &
        size = integer long, size = real double

    external long function lib$signal

    external long constant ERRTST_INFO, ERRTST_ERROR, ERRTST_NORMAL

    declare long exit_status

    exit_status = ERRTST_NORMAL

    print "Before lib$signal ERRTST_INFO"
    call lib$signal (ERRTST_INFO by value, 0 by value)
    print "After lib$signal ERRTST_INFO"

    print "Before lib$signal ERRTST_ERROR"
    call lib$signal (ERRTST_ERROR by value, 0 by value)
    print "After lib$signal ERRTST_ERROR"

end program exit_status ! errtst
