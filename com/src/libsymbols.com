$ !> LIBSYMBOLS.COM -- Define symbols for library programs.
$ !a--------------------------------------------------------------------------!
$ !b
$ !c    Define Library and Utility program symbols
$ !d
$ !e--------------------------------------------------------------------------!
$ apply_to      :== @com_lib:apply_to
$ arc		:== $exe_lib:arc
$ ardiff        :== @com_lib:ardiff
$ aroutdated    :== @com_lib:aroutdated
$ aruncovered   :== @com_lib:aruncovered
$ auth*orize    :== @com_lib:authorize
$ betags        :== $icon_bin:iconx exe_lib:betags.icx
$ bqinfo        :== @com_lib:bqinfo.com
$ cd            :== $exe_lib:sd
$ compiler	:== @com_lib:compiler initialize
$ datetime      :== @com_lib:date_time
$ dclsub*stitute:== $exe_lib:dclsubstitute
$ deldir        :== @com_lib:deldir
$ dirdevice 	:== @com_lib:dirdevice
$ dirsize       :== @com_lib:dirsize
$ dirtree	:== @com_lib:dirtree
$ disks*pace    :== @com_lib:diskspace
$ disku*sage    :== @com_lib:diskusage
$ dmsfields	:== $exe_lib:dmsfields.exe
$ dsclist 	:== @com_lib:dsclist
$ dsckeylist	:== @com_lib:dsckeylist
$ edt		:== edit/edt/command
$ eoj		:== @com_lib:eoj.com		! Catch subprocesses before eoj
$ four		:== $swim_location:swim com_lib:four
$ gcc_setup     :== @com:gcc_setup
$ gnu_symbols   :== @com:gnu_symbols
$ keve		:== @com_lib:kept_editor.com eve ! Kept Eve
$ kill          :== @com_lib:kill
$ l             :== $exe_lib:l.exe
$ mll           :== $icon_bin:iconx exe_lib:ll.icx
$ lex           :== $exe_lib:lex.exe
$ lister	:== $exe_lib:lister
$ listp*rivs	:== @com_lib:listpriv
$ lo*gout	:== @com_lib:eoj.com		! Catch subprocesses before eoj
$ loop          :== @com_lib:loop
$ lr            :== $st_usr:lr.exe
$ ls            :== @com_lib:ls.com
$ makecom*mand  :== @com_lib:makecommand
$ mark          :== @com_lib:mark
$ mk            :== @com:mk
$ most		:== $exe_lib:most.exe
$ msgtxt        :== @com_lib:msgtxt.com
$ newver        :== @com:newver.com
$ notes         :== @com_lib:notes filler
$! nxl		:== $exe_lib:xlisp !lsp_lib:xlispinit
$! nxlisp	:== $exe_lib:xlisp !lsp_lib:xlispinit
$ pakmail	:== @com_lib:pakmail
$ percent       :== $exe_lib:percent
$ pipes         :== @com_lib:pipes
$ pm		:== @ml:phone_message
$! pnxl		:== $exe_lib:xlisp
$ popp*rivs	:== @com_lib:poppriv
$ pushp*rivs	:== @com_lib:pushpriv
$ qbat		:== @com_lib:qbat.com
$ req*ueue      :== @com_lib:requeue.com
$ reset         :== set def sys$login
$ rawsdcl       :== $exe_lib:sdcl.exe 		!new version of SDCL
$ sdcl          :== @com_lib:sdcl.com 		!new version of SDCL
$ ruler         :== $exe_lib:ruler.exe
$ setdebug	:== $exe_lib:setdebug
$ scm_setup     :== @mpl$data:[mpl.tkb.scm]SCM_SETUP.COM
$ smgscm_setup  :== @mpl$data:[mpl.tkb.scm]SMGSCM_SETUP.COM
$ sc*ream       :== $exe_lib:scream
$ screamon	:== @com_lib:screamon
$ sd		:== $exe_lib:sd                 ! Joe Meadows's SD Utility 
$ sis_setup     :== @com:mines_setup.com
$ mines_setup   :== @com:mines_setup.com	! AKA
$ su		:== set host 'f$trnlnm("SYS$NODE")'
$ sweep		:== $exe_lib:vmssweep
$ swim		:== $swim_location:swim
$ tcsdiff       :== @com_lib:tcsdiff.com
$ tcs           :== @com_lib:tcs.com
$ timelord      :== $timelord$:timelord
$ touch         :== @com:touch
$ tr		:== $exe_lib:tr
$ two		:== $swim_location:swim com_lib:two
$ unzip		:== $exe_lib:unzip
$ up            :== set def [-]
$ uptime        :== $exe_lib:uptime.exe
$ usort         :== $exe_lib:sort.exe
$ vms_share	:== @com_lib:vms_share
$ wc		:== $exe_lib:wc
$ owc		:== $exe_lib:wc         	! Save for when st_bin:tooldef.com overwrites it.
$! xl		:== @com_lib:kept xl nxlisp
$ yacc          :== $exe_lib:yacc.exe
$ zip		:== $exe_lib:zip
$ zoo		:== $exe_lib:zoo
$ exit ! LIBSYMBOLS.COM 
