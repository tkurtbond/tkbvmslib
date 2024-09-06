MFLAGS=/DEBUG/LIST/CROSS/OBJECT=$(MMS$TARGET_NAME)$(OBJ)

all :	gcc_double_slash.exe cpr.exe cpr2.exe trycurses.exe cpr3.exe trycurses2.exe read_key.exe try_lib_io.exe negnum.exe bell.exe -
        fabnam_ex.exe cargs.exe iconargs.icx iconenv.icx messages.exe lists.mem c_overflow.exe trysaytime.icx vax_redim.exe vax_redim_best.exe -
        echo.icx

doesnotcompile : mixed_decls_stmts.exe try_rem.exe

.SUFFIXES : .icn .icx .u1 .u2 .rno

CC=GCC


cpr.exe : cpr.obj
    $(LINK)/EXE=$(MMS$TARGET) $(MMS$SOURCE), gnu_cc:[000000]gcclib.olb/lib, gnu_cc:[000000]liberty.olb/lib, sys$library:vaxcrtl.olb/lib

cpr2.exe : cpr2.obj
    $(LINK)/EXE=$(MMS$TARGET) $(MMS$SOURCE), gnu_cc:[000000]gcclib.olb/lib, gnu_cc:[000000]liberty.olb/lib, sys$library:vaxcrtl.olb/lib

trycurses.exe : trycurses.obj
    $(LINK)/EXE=$(MMS$TARGET) $(MMS$SOURCE), gnu_cc:[000000]gcclib.olb/lib, gnu_cc:[000000]liberty.olb/lib, sys$library:vaxccurse.olb/lib, sys$library:vaxcrtl.olb/lib

cpr3.exe : cpr3.obj
    $(LINK)/EXE=$(MMS$TARGET) $(MMS$SOURCE), gnu_cc:[000000]gcclib.olb/lib, gnu_cc:[000000]liberty.olb/lib, sys$library:vaxccurse.olb/lib, sys$library:vaxcrtl.olb/lib


trycurses2.exe : trycurses2.obj
    $(LINK)/EXE=$(MMS$TARGET) $(MMS$SOURCE), gnu_cc:[000000]gcclib.olb/lib, gnu_cc:[000000]liberty.olb/lib, sys$library:vaxccurse.olb/lib, sys$library:vaxcrtl.olb/lib

!------------------------------------------------------------------------------
! Rules
!------------------------------------------------------------------------------

.c.exe :
    $(CC)$(CFLAGS)$(XCFLAGS) $(MMS$SOURCE)
    $(LINK)/EXE=$(MMS$TARGET)$(XLINKFLAGS) $(MMS$SOURCE:.C=.OBJ), gnu_cc:[000000]gcclib.olb/lib, gnu_cc:[000000]liberty.olb/lib, sys$library:vaxcrtl.olb/lib

.bas.exe :
    $(BASIC)$(BASFLAGS)$(XBASFLAGS) $(MMS$SOURCE)
    $(LINK)$(XLINKFLAGS)/EXE=$(MMS$TARGET) $(MMS$SOURCE:.BAS=.OBJ)

.mar.exe :
    $(MACRO)$(MFLAGS)$(XMFLAGS) $(MMS$SOURCE)
    $(LINK)$(XLINKFLAGS)/EXE=$(MMS$TARGET) $(MMS$SOURCE:.MAR=.OBJ)


.rno.mem :
    runoff $(RNOFLAGS) $<

.icn.icx :
    icont $<

clean :
        - delete/log *.obj.*, *.exe.*, *.lis.*, *.map.*, *.mem.*, *.icx.*, *.u1.*, *.u2.*
