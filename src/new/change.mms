change.exe : change.obj change_cli.obj
    $(LINK)$(LINKFLAGS) $(MMS$SOURCE_LIST)
