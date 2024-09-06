.bas.obj :
        basic $(MMS$SOURCE)

.obj.exe :
        link/exe=$(MMS$TARGET) $(MMS$SOURCE)

all : ex1.exe
