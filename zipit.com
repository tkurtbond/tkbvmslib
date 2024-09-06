$ proc = f$env ("PROCEDURE")
$ proc_device = f$parse (proc,,, "DEVICE")
$ proc_directory = f$parse (proc,,, "DIRECTORY")
$ wso "device: ", proc_device
$ wso "directory: ", proc_directory
$ old_directory = proc_device + proc_directory
$ set def [-]
$ today = f$cvtime (,, "DATE")
$ zipfile = "MPL$DATA3:[MPL.TKB.PROJECT_BACKUPS]TKBLIB_" + today + ".ZIP"
$ zip -r 'zipfile' [.lib]com.dir [.lib]src.dir [.lib]examples.dir -x *.exe *.obj *.lis *.map
$ set def 'old_directory'
