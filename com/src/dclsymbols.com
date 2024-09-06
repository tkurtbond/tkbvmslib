$ !> DCLSYMBOLS.COM -- Define symbols for account, mostly dcl abrieviations.
$ !a--------------------------------------------------------------------------!
$ !b
$ !c             Symbols for login, mostly dcl abrieviations
$ !d
$ !e--------------------------------------------------------------------------!
$ ans*wer       :== phone/switch_hook="~" answer
$ bash*elp      :== help/library=basichelp
$ bell[0,8]      == 7                   ! define bell
$ ! I keep mistyping cd on VMS and sd on Unix, might as well always use cd.
$ ! Now I'm using the LBL SWTOOLS VOS, and that has a cd command, so this cd
$ ! went away.
$ conswide      :== set term/page=50/width=132
$ d             :== dir
$ dd            :== dir .dir
$ dbghelp       :== HELP/LIBRARY=SYS$HELP:DBG$HELP DEBUG
$ defroot       :== define/exec/trans=conc ! define rooted directory
$ delp*rot      :== set prot=(o:rwed)/log
$ undelp*rot    :== set prot=(o:rwe)/log
$ rwep*rot      :== set prot=(o:rwe)/log 
$ do            :== spawn/output=spawn.t/nowait/notify
$ dp            :== dir/prot
$ ds            :== dir/size=all/width=(filename=40)
$ dsm           :== dir/size=all/width=(filename=40)/date=mod
$ esc[0,8]       == 27                  ! define escape
$ eterm         :== set term/passall/pasthru/nottsync ! Set term for emacs
$ rterm         :== set term/nopassall/nopasthru/ttsync ! Reset term for emacs
$ exec          :== submit/noprint/nodelete/notify
$ h*elp         :== help/noinstructions
$! Not less, but it will work as the end of a pipe.
$ less          :== type sys$input
$! ls            :== dir ! 2022-07-05: not any more.  
$ mail          :== mail/edit=(send,reply,forward)
$ mcp           :== $mx_exe:mcp
$ mmkd          :== $mmk_dir:mmk.exe/macro=(dbg)
$ mmkv1         :== $mmk_dir:mmk.exe/macro=(var=1)
$ mmkv1d        :== $mmk_dir:mmk.exe/macro=(var=1,dbg)
$ mmkv1dl       == "$mmk_dir:mmk.exe/macro=(var=1,dbg,XBASFLAGS=""/LIST"")"
$! me           :== $sys$library:meshr.exe
$ montopc       :== mon proc/topc/int=60
$ monsys        :== mon sys/int=60
$ p             :== show queue/dev/all
$ pbas*ic       :== basic/real=double/flag=nodecl
$ phone         :== phone/switch_hook="~" 
$! pr*int        :== print/notify ! classhs with SWTOOLS
$ pwd           :== show default
$ re*call       :== recall
$ rejman        :== $mx_exe:rejman
$ resetmodem    :== deallocate ker$comm
$ rewind        :== set magtape/rewind
$ rnd           :== run/nodebug
$ sethost       :== set host/dte ker$comm
$ setmes*sage   :== set message/facility/identification/severity/text
$ setmodem      :== allocate ker$comm
$ setnomes*sage :== set message/nofacility/noidentification/noseverity/text
$ setport       :== define ker$comm
$! setterm       :== set term/line/insert/inquire
$ setbigterm    :== set term/line/insert/vt100/page=60/width=150
$ setterm       :== set term/line/insert/vt100
$ set30term     :== set term/line/insert/vt100/page=30
$ setwideterm   :== set term/line/insert/vt100/page=30/width=132
$ settallterm   :== set term/line/insert/vt100/page=60/width=80
$ si            :== show user/interactive/full
$ sub           :== show proc/sub
$ t             :== type 
$ tex_setup     :== @tex_root:[exe]login.com
$ topc*pu       :== mon proc/topcpu
$ tp            :== type/page
$ uumon         :== show user/full uu*
$! well_setup   :== @sbi$data:[sbi.well]well_assigns.com
$ wse           :== write sys$error
$ wso           :== write sys$output
$ exit ! DCLSYMBOLS.COM
