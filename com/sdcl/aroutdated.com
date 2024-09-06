$ !> AROUTDATED.SDCL -- Find if sources of SWTOOLS archive entries are newer.
$ TRUE = 1 .eq. 1
$ FALSE = 1 .ne. 1
$ wso := write sys$output
$ wse := write sys$output
$ debugging = f$type (aroutdated_debugging) .nes. ""
$ months_jan = "01"
$ months_feb = "02"
$ months_mar = "03"
$ months_apr = "04"
$ months_may = "05"
$ months_jun = "06"
$ months_jul = "07"
$ months_aug = "08"
$ months_sep = "09"
$ months_oct = "10"
$ months_nov = "11"
$ months_dec = "12"
$ set_rdt = FALSE
$ param_idx = 1
$ 23000: if (.not.(f$extract (0, 1, p'param_idx') .eqs. "-")) then goto 23001
$ opt = p'param_idx'
$ opt_len = f$length (opt)
$ if (.not.(opt .eqs. "-SETRDT")) then goto 23002
$ set_rdt = TRUE
$ if (.not.(f$type (file) .eqs. "")) then goto 23004
$ wse "aroutdated: FILE is not defined; you need a symbol for the FILE program."
$ exit 2
$ 23004: 
$ goto 23003
$ 23002: 
$ wse "aroutdated: unknown option: ", opt
$ exit 2
$ 23003: 
$ param_idx = param_idx + 1
$ goto 23000
$ 23001: 
$ arfile = p'param_idx'
$ if (.not.(arfile .eqs. "")) then goto 23006
$ wse "aroutdated: You must specify an archive file!"
$ exit 2
$ 23006: 
$ pid = f$getjpi ("", "PID")
$ tmpfile = "AROUTDATED-" + pid + ".TMP"
$ ar tv 'arfile' >'tmpfile'
$ open/read inf 'tmpfile'
$ n = 0
$ 23008: 
$ read /end_of_file=end_read_loop inf line
$ n = n + 1
$ line = f$edit (line, "COMPRESS")
$ if (.not.(debugging)) then goto 23011
$ wse n, ": """, line, """"
$ 23011: 
$ entry_name = f$element (0, " ", line)
$ entry_date = f$element (3, " ", line)
$ entry_time = f$element (4, " ", line)
$ entry_day = f$extract (0, 2, entry_date)
$ entry_monname = f$extract (3, 3, entry_date)
$ entry_monnum = months_'entry_monname'
$ entry_year = f$extract (7, 2, entry_date)
$ entry_cmpdate = "20" + entry_year + "-" + entry_monnum + "-" + entry_day -
  + " " + entry_time + ".00"
$ if (.not.(debugging)) then goto 23013
$ wse "entry_year: ", entry_year, " entry_monname: ", entry_monname, " entry_day: ", -
  entry_day
$ wse "entry_cmpdate: ", entry_cmpdate
$ 23013: 
$ src_rdt = f$file_attibutes (entry_name, "RDT")
$ src_day = f$extract (00, 02, src_rdt)
$ src_monname = f$extract (03, 03, src_rdt)
$ src_year = f$extract (07, 04, src_rdt)
$ src_rest = f$extract (11, 12, src_rdt)
$ src_monnum = months_'src_monname'
$ src_cmpdate = src_year + "-" + src_monnum + "-" + f$fao ("!2ZL", f$integer -
  (src_day)) + src_rest
$ if (.not.(debugging)) then goto 23015
$ wse "src_cmpdate: ", src_cmpdate
$ 23015: 
$ if (.not.(src_cmpdate .gts. entry_cmpdate)) then goto 23017
$ wso entry_name, " is newer than ", arfile, "(", entry_name, ")"
$ wso "    ", src_cmpdate, " > ", entry_cmpdate
$ if (.not.(set_rdt)) then goto 23019
$ inquire/nopun doit "Set date? "
$ doit = f$extract (0, 1, f$edit (doit, "COLLAPSE,UPCASE"))
$ if (.not.(doit .eqs. "Q")) then goto 23021
$ goto end_read_loop
$ 23021: 
$ if (.not.(doit .eqs. "Y")) then goto 23023
$ vms_date = entry_day + "-" + entry_monname + "-" + "20" + entry_year + " " -
  + entry_time + ".00"
$ wso vms_date, ": ", vms_date
$ file /revision_date="''vms_date'" 'entry_name'
$ 23023: 
$ 23019: 
$ 23017: 
$ 23009: goto 23008
$ 23010: 
$ end_read_loop:
$ close inf
$ delete 'tmpfile';0
$ exit
$ error:
$ if (.not.(f$trnlm ("INF") .nes. "")) then goto 23025
$ close inf
$ delete 'tmpfile';0
$ 23025: 
$ exit 2
