ICONT=icont
ICONX=iconx

.SUFFIXES : .icn .icx .u1 .u2

.icn.icx : 
	$(ICONT) $(ICONTFLAGS) $(MMS$SOURCE)
