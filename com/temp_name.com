$! Make a temp file name
$ time = f$cvtime("") - "-" - "-" - " " - ":" - ":" - "."
$ pid = f$getjpi("","PID")
$ tmp = "CHK" + time + "_" + pid + "." + "TMP"
