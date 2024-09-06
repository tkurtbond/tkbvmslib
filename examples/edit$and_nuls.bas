program edit$and_nuls
    option type = explicit, constant type = integer, &
        size = integer long, size = real double 

    external long function fio_create_text (long, string, string)

    declare string nuls, edited_nuls, long stat

    nuls = chr$(0) + chr$(0) + chr$(0) + chr$(0) + chr$(0) + "trailing"

    stat = fio_create_text (1, 'mpl$data:[mpl.tkb.examples]edit$and_nuls.lis', )
    print #1; 'nuls: "'; nuls; '"'
    print #1; 'edit$ (nuls, 4+8+128): "'; edit$ (nuls, 4+8+128); '"'

    edited_nuls = edit$ (nuls, 4+8+128)
    if edited_nuls <> "trailing" then
        print #1, "not = trailing"
    else
        print #1, "is = trailing"
    end if
end program ! edit$and_nuls
