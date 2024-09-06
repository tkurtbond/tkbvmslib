$ verifying = 'f$verify(f$type(diskspace_verify) .nes. "")'
$!> DISKSPACE.COM -- Report current diskspace usage.
$!
$!	DISKSPACE.COM
$!	C. Paul Bond		1-2-85		ver 2.0
$!
$!	This command file reports the current disk space usage.
$!	P1 the drive or drives to be listed. Use an * for all
$!	known drives.  P2 is the output file.  By default it
$!	is SYS$OUTPUT.
$!
$!
$	blank_line = "                    "		! 20
$	blank_line = blank_line + blank_line + blank_line + blank_line
$	device_list = p1
$	output_file = p2
$	grand_total_blocks = 0
$	grand_total_free = 0
$	device_count = 0
$	version = f$getsyi("version")
$	date = f$extract(0, 11, f$time())
$	time = f$extract(12,f$locate(".",f$time())-12,f$time())
$! all the disk drives
$	all_devices = "DUA0:,DUA1:,DUA2:,DUA100:,DUA200:,DUA300:,DUA301,DUA302:,DUA303:,DUA400:,DUA401:,$1$DIA0:,$1$DIA1:,$1$DIA2:,$1$DIA3:,$1$DIA4:,$1$DIA5:,ZRA02:,ZRA03:,ZRA04:,ZRA06:,ZRA07:,ZRA08:,ZRA09:"
$	if device_list .eqs. "" then device_list = all_devices
$	if device_list .eqs. "*" then device_list = all_devices
$	if output_file .eqs. "" then output_file = "SYS$OUTPUT"
$!
$	open/write f 'output_file'
$	write f ""
$	write f "      VAX/VMS ''version' Disk usage summary on ''date' at ''time'"
$	write f "Device   Volume Label       Used Blocks       Free Blocks       Total Blocks"
$!
$ get_new_device:
$	if device_list .eqs. "" then goto exit_loop
$!
$	device_count = device_count + 1
$	loc = f$locate(",", device_list)
$	device = f$extract(0, loc, device_list)
$	device_list = f$extract(loc+1, f$length(device_list), device_list)
$!
$	total_blocks = f$getdvi(device, "maxblock")
$	free_blocks = f$getdvi(device, "freeblocks")
$	volume_label = f$getdvi(device, "volnam")
$	used_blocks = total_blocks - free_blocks
$!
$	grand_total_blocks = grand_total_blocks + total_blocks
$	grand_total_free = grand_total_free + free_blocks
$!
$	percent_free = free_blocks * 100 / total_blocks
$	percent_used = 100 - percent_free
$!
$	free = "''free_blocks'(''percent_free'%)"
$	used = "''used_blocks'(''percent_used'%)"
$	total = "''total_blocks'"
$!
$	line = blank_line
$	line[0,f$length(device)] := "''device'"
$	line[9,f$length(volume_label)] := "''volume_label'"
$	line[28,f$length(used)] := "''used'"
$	line[46,f$length(free)] := "''free'"
$	line[66,f$length(total)] := "''total'"
$!
$	write f line
$!
$	goto get_new_device
$!
$ exit_loop:
$!
$	if device_count .lt. 2 then goto the_end
$!
$	percent_used = 100 - (grand_total_free * 100 / grand_total_blocks)
$!
$	write f ""
$	write f "There are ''grand_total_free' free blocks on ''device_count' structures."
$	write f "Total disk space is ''percent_used' percent used."
$	write f ""
$!
$ the_end:
$	close f
$ 	exit (1 .or. (f$verify(verifying) .and. 0))
