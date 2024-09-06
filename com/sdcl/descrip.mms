! DESCRIP.MMS - first stage DESCRIP.MMS for building .COMs from .SDCLs.
!
! Edit PROGRAMS.DAT to add finished programs to be installed.

.SUFFIXES .GENMMS
GENMMS=programs.genmms install.genmms rules.genmms clean.genmms

all : $(GENMMS)
        $(MMS)/desc=descrip_s2 all

install : $(GENMMS)
        $(MMS)/desc=descrip_s2 install

clean : $(GENMMS)
        $(MMS)/desc=descrip_s2 clean


programs.genmms include.genmms rules.genmms clean.genmms : programs.dat
        @tolist



