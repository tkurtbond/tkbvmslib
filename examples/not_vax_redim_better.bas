program x
    option type = explicit, constant type = integer, &
        size = integer long, size = real double 

    external long function &
        utl_parse_spec (string, string, string, long, string, long, string,   &
		        string, string, string, string, string)
    
    declare long stat, string inname, string outname

    inname = 'TON$DATA:[MINES.TON]DSUMCO2022.DSC'
    stat = utl_parse_spec (inname,,, 2^4 + 2^8 + 2^13, outname,,,,,,,)
    print "inname: "; inname
    print "outname: "; outname
    inname = 'TON:DSUMCO2022.DSC;0'
    stat = utl_parse_spec (inname,,, 2^4 + 2^8 + 2^13, outname,,,,,,,)
    print "inname: "; inname
    print "outname: "; outname
    inname = "CODES"
    stat = utl_parse_spec (inname,,, 2^4 + 2^8 + 2^13, outname,,,,,,,)
    print "stat: "; stat
    print "inname: "; inname
    print "outname: "; outname

    inname = "DEEP:DMINES"
    stat = utl_parse_spec (inname, ".DSC",, 2^4 + 2^8 + 2^13, outname,,,,,,,)
    print "stat: "; stat
    print "inname: "; inname
    print "outname: "; outname

end program ! x
