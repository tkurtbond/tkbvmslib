function string to_binary (long n)
    option type = explicit, constant type = integer, &
        size = integer long, size = real double 

    external long function lib$extzv
    declare long i, string result

    result = result + str$(lib$extzv(i, 1, n)) for i = 31 to 0 step -1
end function result ! to_binary
