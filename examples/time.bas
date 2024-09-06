program time.bas
    option type = explicit, constant type = integer, &
        size = integer long, size = real double

    external long function sys$asctim, sys$bintim
    record quadword
        long q1
        long q2
    end record

    ! "dd-mmm-yyyy hh:mm:ss.cc" 23 characters
    ! "dddd hh:mm:ss.cc" 16 characters
    map (dt) &
        string datetime = 23, &
        string deltatime = 16

    declare long result, datetime_len, deltatime_len
    declare quadword quadword

    print "get current time from sys$asctim: "
    result = sys$asctim (datetime_len, datetime)
    print "result: "; result; " datetime: "; datetime; " datetime_len: "; datetime_len

    quadword::q1 = 0 \ quadword::q2 = 0
    print "get sys$bintim from 14-AUG-2024 15:45:50.58"
    datetime = "14-AUG-2024 15:45:50.58"
    result = sys$bintim (datetime, quadword)
    print "result: "; result; " q1: "; quadword::q1; " q2: "; quadword::q2

    print "get sys$asctim from sys$bintim result"
    result = sys$asctim (datetime_len, datetime, quadword, 0)
    print "result: "; result; " datetime: "; datetime; " datetime_len: "; datetime_len

    print "get sys$bintim from 10:20:30"
    datetime = "10:20:30"
    result = sys$bintim (datetime, quadword)
    print "result: "; result; " q1: "; quadword::q1; " q2: "; quadword::q2

    deltatime = ""
    print "get sys$asctim from sys$bintim result"
    result = sys$asctim (deltatime_len, deltatime, quadword, 1)
    print "result: "; result; " deltatime: "; deltatime; " datetime_len: "; deltatime_len

end program ! time
