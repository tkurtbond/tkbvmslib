!++++
! whackterm.bas -- Fill screen with asterisks when term emulator is confused.
!----
program whackterm
    option type = explicit, constant type = integer, &
        size = integer long, size = real double

    declare integer constant NUM_LINES = 50
    declare integer constant NUM_COLUMNS = 80
    
    declare integer i
    declare string s

    s = string$ (NUM_COLUMNS, A"*")

    for i = 1 to 50
        print s
    next i
end program ! whackterm
