! DESCRIP_S2.MMS - second stage DESCRIP.MMS for building .COMs from .SDCLs.

all :
        @ write sys$output "There is no all; use mmk install"

.include programs.genmms


install : ml:diskusage.com ml:requeue.com ml:check_freespace.com install-programs

ml:diskusage.com : diskusage.com
        copy/log $(MMS$SOURCE_LIST) ML:
ml:requeue.com : requeue.com
        copy/log $(MMS$SOURCE_LIST) ML:
ml:check_freespace.com : check_freespace.com
        copy/log $(MMS$SOURCE_LIST) ML:


clean :
        - delete/log *.genmms.*

.include install.genmms

.include rules.genmms

.SUFFIXES : .COM .GENMMS
