CFLAGS    = /NOLIST/OBJECT=$(MMS$TARGET_NAME)$(OBJ)${ICFLAGS}${XCFLAGS}
LINKFLAGS   = /EXEC=$(MMS$TARGET) ${ILINKFLAGS}${XLINKFLAGS}
ICFLAGS=$(ICFLAGS)/DEBUG/NOOPT
ILINKFLAGS=$(ILINKFLAGS)/DEBUG
CC=GCC

PROGRAMS=-
    tryext.exe, -
    ! end of PROGRAMS

all : $(PROGRAMS)

tryext.exe : tryext.obj, extdef.obj, c.opt
    $(LINK)$(LINKFLAGS) $(MMS$SOURCE_LIST)/opt

