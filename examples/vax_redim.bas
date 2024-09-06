!> VAX_REDIM.BAS - Example of redimensioning an array in a subroutine.
! See: https://tkurtbond.github.io/posts/2003/05/08/vms-code-from-the-past/
! AKA: https://web.archive.org/web/20231205060239/https://tkurtbond.github.io/posts/2003/05/08/vms-code-from-the-past/
! See: https://groups.google.com/g/comp.os.vms/c/mVWznNVN17U/m/yuOAmQtQBAAJ
program redim
    option type = explicit, constant type = integer, &
        size = integer long, size = real double
    declare long i
    external sub try_redim (string dim())

    i = 10
    dim string s(i)			!i can't be relaced by a constant, or boom!
    i = 20
    dim string s(i)
    call try_redim (s())
    print ubound (s)
    for i = 1 to 35
        s(i) = "after redim " + num1$(i)
    next i

    for i = 1 to 35
       print num1$(i); ": "; s(i)
    next i

end program ! redim

sub try_redim (long s)
    option type = explicit, constant type = integer, &
        size = integer long, size = real double
    external long function my_redim (long, long)

    call my_redim (loc(s), 35)
end sub ! try_redim


function long my_redim (long s, long n)
    option type = explicit, constant type = integer, &
        size = integer long, size = real double
    external long function bas$rt_dim (long by value, long by value)
    declare long r
    r = bas$rt_dim (s, n)
end function r ! my_redim
