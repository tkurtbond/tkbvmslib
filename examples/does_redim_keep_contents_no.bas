program does_redim_keep_contents
    option type = explicit, constant type = integer, &
        size = integer long, size = real double 

    external long function redim

    declare long n, i

    n = 5
    dim string s(1 to n)
    for i = 1 to n
        s(i) = str$(i)
    next i

    ! Does redim keep contents?  NO!
    call redim (s(), 1, 10)
    for i = 1 to 10
        print s(i)
    next i
end program ! does_redim_keep_contents
function long redim (long s, long low, high)
    option type = explicit, constant type = integer, &
        size = integer long, size = real double
    external long function bas$rt_dim_bounds (long by value, long by value, long by value)
    declare long r
    r = bas$rt_dim_bounds (loc (s), low, high)
end function r ! redim
