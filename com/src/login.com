$ verifying = 'f$verify(f$type(login_verify) .nes. "")'
$ if f$trnlnm ("TKB_SKIP_LOGIN") .nes. ""
$ then 
$     write sys$output "Skipping login.com"
$     exit (1 .or. (f$verify(verifying) .and. 0))
$ endif     
$ write sys$output "login.com: begin: ", f$getjpi("", "CPUTIM")
$!
$!----------------------------------------------------------------------------!
$! 
$! program:   	L O G I N . C O M
$! written by:	Thomas Kurt Bond
$! version:	1.00a
$! date:	??-???-????
$!
$! description:
$!     normal login procedure.  Executes each file of the login subsystem.
$! The login subsystem is broken up into files to allow easy modification.
$!
$! history:
$! ver     when    who  what
$! 1.00a   ??????  tkb  Login command procedure.  Execute all login files.
$!----------------------------------------------------------------------------!
$!> LOGIN.COM -- login command file. Execute the pieces of the login subsystem
$!
$ exec: subroutine	! executate a command file if found, notify otherwise
$     if f$search(p1) .eqs. "" then goto not_found
$     @'p1' 'p2' 'p3'   ! p2 is filler, p3 is options for logical defines
$     exit
$   not_found:
$     write sys$output "error: cannot find ''p1'"
$     exit
$ endsubroutine
$!
$ on error then goto the_end
$ on control_y then goto the_end
$ if p1 then set verify
$!
$ !root == f$trnlnm("SYS$LOGIN") - "]"
$ proc = f$environment ("PROCEDURE")
$ root == f$parse (proc,,,"DEVICE") + f$parse (proc,,,"DIRECTORY") - "]"
$ write sys$error "root: ", root
$ libroot == root
$
$ call exec 'libroot'.tkbvmslib.com]acclogicals.com ! filler /job
$ call exec 'libroot'.tkbvmslib.com]liblogicals.com ! filler /job
$ call exec 'libroot'.tkbvmslib.com]dclsymbols.com
$ call exec 'libroot'.tkbvmslib.com]libsymbols.com
$ call exec 'libroot'.tkbvmslib.com]dms_symbols.com
$ call exec 'libroot'.tkbvmslib.com]setup.com
$!
$! Temporary Section
$!
$! define testcert mpl$share:[test_cert]
$! define cert  	  mpl$share:[test_cert]
$! define deep  	  mpl$share:[test_cert] 
$! define admin 	  mpl$share:[test_cert]
$!
$! fake cert_print file while new CERT_PRINT file is being built.
$! @mpl$share:[test_cert.term_src.test]setup.com
$! my notes are in 
$! define mhst mpl$data:[mpl.tkb.mpl.mhst]
$!
$ !@mpl$data:[mpl.tkb.wrk.dclcomplete]dclcomplete_setup.com
$ !@mpl$data:[mpl.tkb.wrk.mgsd]sd_setup.com
$!
$ if f$search ("sys$login:setup.com") .nes. "" then -
      call exec sys$login:setup.com
$ if f$search ("st_bin:tooldef.com") .nes. "" then -
      @st_bin:tooldef.com
$!
$ scm_setup = root + ".SCM]SCM_SETUP.COM"
$ if f$search (scm_setup) .nes. "" then -
      @'scm_setup'
$ slib_setup = root + ".SLIB]SLIB_SETUP.COM"
$ if f$search (slib_setup) .nes. "" then -
      @'slib_setup'
$!
$the_end:
$ write sys$output "login.com: end: ", f$getjpi("", "CPUTIM")
$ exit (1 .or. (f$verify(verifying) .and. 0))
