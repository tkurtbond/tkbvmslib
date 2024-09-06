all : mxrejsum.icx err.exe

! mxrejsum.icx : mxrejsum.icn
!	icont mxrejsum.icn

err.exe : err.obj
	link err.obj, gnu_cc:[000000]gcclib/lib, sys$library:vaxcrtl/lib

err.obj : err.c
	gcc err.c

.SUFFIXES : .icn .icx

.icn.icx : 
	icont $(MMS$SOURCE)


TESTFLAGS=-a -n20 -v
short_test.lis : mxrejsum.icx short_test.dat
	iconx -e short_test.err mxrejsum $(TESTFLAGS) -o short_test.lis -
		short_test.dat

long_test.lis : mxrejsum.icx long_test.dat
	iconx -e long_test.err mxrejsum $(TESTFLAGS) -o long_test.lis -
		long_test.dat


clean : 
	- delete /log 	*.exe.*, *.obj.*, *.err.*, *.lis.*, -
			*.icx.*, *.u1.*, *.u2.*

	
