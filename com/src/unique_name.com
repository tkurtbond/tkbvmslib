$       sublib__status = %x10000000
$       sublib__success = sublib__status + %x0001
$       on control_y then exit sublib__status + %x0004
$       on warning then exit $status .or. %x10000000
$       display = "write sys$output"
$
$! Title:       Generate a Unique Name
$!
$! Synopsis:    This subroutine generates a unique name suitable for
$!              use in creating a temporary file.
$!
$! Parameters:  P2: The global symbol to receive the result.
$!              P3: The pattern specifying the format of the unique
$!                  name. It must contain a question mark (?), which
$!                  is replaced with a unique number.
$!
$! Result:      A unique name consisting of the pattern with the
$!              question mark replaced with a ten-digit number.
$!              The number is composed of eight digits of time and a
$!              two-digit counter.
$
$UNIQUE_NAME:
$
$       if f$type(sublib_counter) .eqs. "" then sublib_counter == 0
$       sublib_counter == (sublib_counter+1) - -
                          (sublib_counter+1)/100*100
$       'p2 == f$fao("!AS!8AS!2ZL!AS", f$element(0,"?",p3), -
                     f$extract(12, 11 ,f$time())-":"-":"-".", -
                     sublib_counter, f$element (1, "?",p3))
$       exit sublib__success
