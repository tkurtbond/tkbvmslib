! DESCRIP.MMS - first stage DESCRIP.MMS for building .COMs from .SDCLs.
!
! Edit PROGRAMS.DAT to add finished programs to be installed.

.SUFFIXES .GENMMS
GENMMS=programs.genmms install.genmms rules.genmms

all : $(GENMMS)
        $(MMS)/desc=descrip_s2 all

install : $(GENMMS) install-login
        $(MMS)/desc=descrip_s2 install

install-login : sys$login:login.com

sys$login:login.com : login.com
        copy/log $< $@

clean : $(GENMMS)
        $(MMS)/desc=descrip_s2 clean


programs.genmms include.genmms rules.genmms : programs.dat
        @tolist




