first : ziptxt

zipvms :
        @ write sys$output "ZipVMSing!"
	today = f$cvtime (,, "DATE")
        set def [-]
	zipfile = "tkbvmslib_" + today + ".zip"
	! It's not really accurate unless we start from scratch.
	if f$search (zipfile) .nes. "" then delete 'zipfile';*/log
	zip "-V" -r 'zipfile' tkbvmslib.dir -x *.map *.log
        @ write sys$output "Done ZipVMSing!"



ziptxt :
        @ write sys$output "ZipTXTing!"
	today = f$cvtime (,, "DATE")
        set def [-]
	zipfile = "tkbvmslib_txt_" + today + ".zip"
	! It's not really accurate unless we start from scratch.
	if f$search (zipfile) .nes. "" then delete 'zipfile';*/log
	zip -r 'zipfile' tkbvmslib.dir -x *.dsc *.key *.obj *.exe *.hlb *.lis *.map *.log *.zip *.zoo *.tmp *.icx *.u1 *.u2 lib/exe/* lib/mdist/*
        @ write sys$output "Done ZipTXTing!"

