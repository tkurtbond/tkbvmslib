! DESCRIP_S2.MMS - second stage DESCRIP.MMS for building .COMs from .SDCLs.

.include programs.genmms


BROKEN_PROGRAMS=

!NOINSTALL_PROGRAMS=x-dirsize.com

! Don't install DIRSIZE.COM until you are sure the new version
! (see x-dirsize.sdcl) works.

UNSURE_PROGRAMS=DISKRESTORE.COM FLATTEN.COM GETSYI.COM -
	LISTDIR.COM XARGS.COM  

HYSTERICAL_RAISINS=ADA.COM NOTES.COM OSDCL.COM STOP.COM -
	TIME_DIFF.COM

all : $(PROGRAMS) $(NOINSTALL_PROGRAMS)

.include install.genmms

!{COM_LIB:}.COM{COM_SRC:}.COM :
!    copy /log $(MMS$SOURCE) $(MMS$TARGET)

.include rules.genmms

SDCL=rawsdcl ! use the executable directly.
.SUFFIXES : .SDCL .COM .GENMMS

.SDCL.COM : 
        $(SDCL) -o $(MMS$TARGET) $(MMS$SOURCE)

programs.genmms install.genmms rules.genmms : programs.dat
        @tolist

install : install-programs

raisins : $(HYSTERICAL_RAISINS)

clean : clean-programs
        - delete/log *.genmms.*


.include clean.genmms
