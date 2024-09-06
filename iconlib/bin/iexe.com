! define as a command the icon program named as a parameter
!
$ If "''p1'" .Eqs. "" Then $ Inquire p1 "Image name"
$ If "''p1'" .Eqs. "" Then $ Exit 1
$ name = F$Parse("''p1'",".ICX",,,"SYNTAX_ONLY")
$ file = F$Search("''name'")
$ name = F$Parse("''file'",,,"NAME")
$ file = F$Parse("''file'",,,"DEVICE") + F$Parse("''file'",,,"DIRECTORY") + -
    F$Parse("''file'",,,"NAME") + ".ICX"
$ 'name' == "$SYS$Icon:iconx ''file'"
$ Exit 1
