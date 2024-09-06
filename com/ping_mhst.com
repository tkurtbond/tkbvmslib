$!> ping_mhst.com -- Ping the remotme MHST printers to check connectivity.
$!-----------------------------------------------------------------------------
$! This does not include HST_LO$LASER and HST_LO$PRINT, since those may not
$! be in use.
$!-----------------------------------------------------------------------------
$       printers = "CELLAR$PRINT:10.5.41.7/CHS$PRINT:10.5.41.5/HST_ASSESS$PRINT:10.5.46.8" + -
                   "/HST_NO$LASER:10.5.47.6/HST_NO$PRINT:10.5.47.5/HST_OH$LASER:10.5.45.8" + -
                   "/HST_OH$PRINT:10.5.45.5/HST_WE$LASER:10.5.46.6/HST_WE$PRINT:10.5.46.5"
$       bad = ""
$       good = ""
$       i = 0
$       j = 0 
$ 10$:
$       on error then goto 15$
$       printer_info = f$element (i, "/", printers)
$       if printer_info .eqs. "/" then goto 19$
$       printer_name = f$element (0, ",", printer_info)
$       printer_ip = f$element (1, ":", printer_info)
$       write sys$error ""
$       write sys$error "=============================================================================="
$       write sys$error "Checking printer ", printer_name
$       mu ping 'printer_ip'/num=5
$ 15$:
$       status = $status
$       if status .and. 1
$       then
$           j = j + 1
$           if good .eqs. ""
$           then
$               good = printer_info
$           else
$               good = good + "," + printer_info
$           endif
$       else
$           if bad .eqs. ""
$           then
$               bad = printer_info
$           else
$               bad = bad + "," + printer_info
$           endif
$       endif
$       write sys$error printer_name + ":" + printer_ip, " result is ", status
$       i = i + 1
$       goto 10$
$ 19$:
$       write sys$error ""
$       write sys$error ""
$       write sys$error j, " of ", i, " printers were contacted"
$       write sys$error "Good printers: ", good
$       write sys$error "Bad printers: ", bad
