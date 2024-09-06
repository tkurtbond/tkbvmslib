program edit$and_ctrl_a.bas
    option type = explicit, constant type = integer, &
        size = integer long, size = real double 

    declare string a

    a = chr$(1) + chr$(1) + chr$(1) + chr$(1) + chr$(1) + " Preceeding has Ctrl-A characters"
    print 'a: "'; a; '"'
    print 'edit$ (a, 4+8+128): "'; edit$ (a, 4+8+128); '"'
end program ! edit$and_ctrl_a
