$! Purpose:
$!	To mail out a series of files produced by VMS_SHARE to a series
$!	of recipients.
$!
$! Parameters:
$!
$!	P1 = name (or list ) of recipient(s). Can be logical or distribution
$!           list.
$!
$!		If sending to a distribution list, it is necessary to define
$!		a logical pointing to the file and then give that logical as
$!		the recipient name.  This avoids problems with DCL's handling
$!		of quotes and '@' symbols.
$!
$!
$!	P2 = file spec of package - "[directory]file" without VMS_SHARE suffix!
$!
$!
$!	P3 = no of parts of the package
$!
$! 		This procedure adds the VMS_SHARE suffix and sends files
$!		called  "[directory]file''nn'"   nn from 1-> 'P3'
$!
$!	P4 = Comment to add to mail subject line
$!
$!
$! Privileges:
$!	Whatever is necessary to access e-mail and the relevant network.
$!
$!
$! Environment:
$!	Nothing special.  VMS_SHARE must exist of course in order to
$!	produce the software package.
$!
$! Revision History:
$!	1.0	Andy Harper	6-DEC-1988	Original version
$!	1.1	Andy Harper	19-DEC-1988	Allow P4 to be mail subject
$!	1.2	Andy Harper	5-JAN-1989	Return exit status
$!	1.3	Andy Harper	16-JUN-1989	Remove "OF_''mm'" extension
$!	1.4	Andy Harper	3-AUG-1989	use READ, check EOF status
$!
$!
$
$
$! SET UP STANDARD EXIT CODES
$ ss$_normal= 1
$ ss$_abort = 44
$
$
$! MAKE SURE WE HAVE ALL THE PARAMETERS
$get_recipient:
$ if P1 .nes. "" then $ goto end_get_recipient
$ read/prompt="_mail address of recipient "/end=exit sys$command P1
$ goto get_recipient
$end_get_recipient:
$
$package_location:
$ if P2 .nes. "" then $ goto end_package_location
$ read/prompt="_Enter package directory and base filename "/end=exit sys$command P2
$ goto package_location
$end_package_location:
$ P2 = f$parse(P2,,,,"SYNTAX_ONLY") - f$parse(P2,,,"VERSION")
$ if f$parse(P2,,,"TYPE") .nes. "." then $ P2 = P2 + "_"
$
$
$get_parts:
$ if P3 .nes. "" then $ goto end_get_parts
$ read/prompt="_Enter number of parts "/end=exit sys$command P3
$ goto get_parts
$end_get_parts:
$
$
$! SET UP USEFUL SYMBOLS
$ em="write sys$error ""%" +f$parse(f$environment("PROCEDURE"),,,"NAME")+""","
$ package = f$parse(P2,,,"NAME")
$ l = f$length(P3)
$
$
$! IS THERE A SET OF FILES THAT MATCHES THE SPECIFICATION??
$ if f$search("''P2'*") .eqs. "" then $ goto nopackage
$
$
$! DO A QUICK CHECK TO MAKE SURE ALL REQUIRED FILES ARE THERE!!!!!
$ part = 0
$ OK = "TRUE"
$check:
$   part = part+1
$   if part .gt. P3 then $ goto end_check
$   if f$search("''P2'''part'") .nes. "" then $ goto check
$   em "-E-NOPART, Part ''part' of ''package' is missing!"
$   OK = "FALSE"
$   goto check
$end_check:
$
$
$! WERE ALL THE PARTS FOUND? IF NOT, NOW'S THE TIME TO FIND OUT!
$ if .not. OK then $ goto abandon
$
$
$! LOOP AROUND EACH PART AND SEND
$ part = 0
$loop:
$   part = part+1
$   if part .gt. P3 then $ exit ss$_normal
$   n = f$fao("!#ZL",l,part)
$   em "-I-SENDPART, sending part ", part, " of ", package
$   mail/noedit/noself/subject="''package' ''P4' ''n'/''P3'" 'p2''part' 'P1'
$   if $status then $ goto loop
$   exit $status	! Return status from mail if it failed
$
$
$nopackage:
$  em "-E-NOPACKAGE, Cant find any files for ''package'."
$abandon:
$  em "-E-ABANDON, One or more missing parts. Send abandoned."
$exit:
$  exit ss$_abort
