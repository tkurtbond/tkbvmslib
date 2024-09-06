CFLAGS    = /NOLIST/OBJECT=$(MMS$TARGET_NAME)$(OBJ)${ICFLAGS}${XCFLAGS}
LINKFLAGS = /EXEC=$(MMS$TARGET) ${ILINKFLAGS}${XLINKFLAGS}

.IFDEF DBG
ICFLAGS=$(ICFLAGS)/DEBUG/NOOPT
ILINKFLAGS=$(ILINKFLAGS)/DEBUG
.ENDIF

.IFDEF VAR
ICFLAGS=$(ICFLAGS)/VAR=$(VAR)
.ENDIF

CC=GCC

bas$edit.exe : bas$edit.obj bas$edit.h
    $(LINK) $(LINKFLAGS) $(MMS$SOURCE), bas$edit/opt

clean :
    - del/log *.obj.*, *.lis.*, *.dep.*, *.tmp.*, *.exe.*
