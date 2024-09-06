.IFDEF DBG
XCFLAGS=/DEBUG/NOOPT
XLINKFLAGS=/DEBUG/MAP
.ENDIF


.SUFFIXES : .icn .icx .u1 .u2

all : miscutils.olb first3.icx uniq.icx echo.exe sizes.exe lltoa_test.exe strtoll_test.exe percent.exe scream.exe lc.exe dclsubstitute.exe -
	uptime.exe tovar.exe lc.exe betags.icx datediff.exe ll.icx

install : exe_lib:scream.exe exe_lib:lc.exe exe_lib:tovar.exe exe_lib:uptime.exe exe_lib:betags.icx exe_lib:datediff.exe exe_lib:ll.icx
public : ml:percent.exe 

CC=GCC

!.C$(OBJ) :
!    $(CC)$(CFLAGS)$(XCFLAGS) $(MMS$SOURCE)


lltoa_test.obj : lltoa.c
    $(CC)/define="TEST"/noopt/debugnolist/object=$(MMS$TARGET) $(MMS$SOURCE)

lltoa.obj : lltoa.c
    $(CC)/noopt/debug/nolist/object=$(MMS$TARGET) $(MMS$SOURCE)

lltoa_test.exe : lltoa_test.obj
    $(LINK)/EXE=$(MMS$TARGET) $(MMS$SOURCE), gnu_cc:[000000]gcclib.olb/lib, gnu_cc:[000000]liberty.olb/lib, sys$library:vaxcrtl.olb/lib

strtoll_test.obj : strtoll.c
    $(CC)/define="TEST"/nolist/noopt/debug/object=$(MMS$TARGET) $(MMS$SOURCE)

strtoll_test.exe : strtoll_test.obj, lltoa.obj
    $(LINK)/EXE=$(MMS$TARGET)/debug $(MMS$SOURCE_LIST), gnu_cc:[000000]gcclib.olb/lib, gnu_cc:[000000]liberty.olb/lib, sys$library:vaxcrtl.olb/lib

datediff.exe : datediff.obj, datediff_cli.obj
    $(LINK)/EXE=$(MMS$TARGET) $(MMS$SOURCE_LIST)

!------------------------------------------------------------------------------
! Install targets
!------------------------------------------------------------------------------

ml:percent.exe : percent.exe
    copy/log $(MMS$SOURCE) $(MMS$TARGET)

exe_lib:scream.exe : scream.exe
    copy/log $(MMS$SOURCE) $(MMS$TARGET)

exe_lib:tovar.exe : tovar.exe
    copy/log $< $@

exe_lib:uptime.exe : uptime.exe
    copy/log $< $@

exe_lib:betags.icx : betags.icx
    copy/log $< $@

exe_lib:ll.icx : ll.icx
    copy/log $< $@

exe_lib:datediff.exe : datediff.exe
    copy/log $< $@

miscutils.olb : miscutils(getopt), miscutils(ioinit)
        library/list $(MMS$TARGET)

!------------------------------------------------------------------------------
! Rules
!------------------------------------------------------------------------------

.c.exe :
    $(CC)$(CFLAGS)$(XCFLAGS) $(MMS$SOURCE)
    $(LINK)/EXE=$(MMS$TARGET)$(XLINKFLAGS) $(MMS$SOURCE:.C=.OBJ), lib_src:miscutils.olb/lib, gnu_cc:[000000]gcclib.olb/lib, gnu_cc:[000000]liberty.olb/lib, sys$library:vaxcrtl.olb/lib

.bas.exe :
    $(BASIC)$(BASFLAGS)$(XBASFLAGS) $(MMS$SOURCE)
    $(LINK)$(XLINKFLAGS)/EXE=$(MMS$TARGET) $(MMS$SOURCE:.BAS=.OBJ)

.mar.exe :
    $(MACRO)$(MFLAGS)$(XMFLAGS) $(MMS$SOURCE)
    $(LINK)$(XLINKFLAGS)/EXE=$(MMS$TARGET) $(MMS$SOURCE:.MAR=.OBJ)

.icn.icx :
    icont $<

cleanl :
        delete lc.exe.*, lc.obj.*/log

exe_lib:lc.exe : lc.exe
        copy/log $(MMS$SOURCE) $(MMS$TARGET)

clean :
        - delete/log  *.exe.*, *.obj.*, *.map.*, *.lis.*, *.icx.*, *.u1.*, *.u2.*
