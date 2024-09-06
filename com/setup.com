$!> SETUP.COM -- Setup all special options of a login session
$	where = "WVWC"
$	login_directory = f$trnlnm("sys$login")
$	if f$locate ("MPL$DATA:[MPL.TKB", login_directory) .ne. -
	    f$length (login_directory)
$	then 
$	    where = "MPL"
$	endif
$!
$!----------------------------------------------------------------------------!
$! Modem line setups
$!----------------------------------------------------------------------------!
$ 	if .not. f$getdvi("tt", "tt_modem") then goto Skip_Modem
$ 	answer :== phone/noscroll/switch_hook="~" answer
$ 	phone :== phone/noscroll/switch_hook="~"
$ Skip_Modem:
$!
$!----------------------------------------------------------------------------!
$! All modes of operation
$!----------------------------------------------------------------------------!
$ if where .eqs. "MPL"
$ then 
$!	@ml:setup_lisp
$	@com_lib:if_exists soft$disk:[MPLLIB.MGBOOK]MGBOOK_SETUP.COM
$	@com_lib:if_exists soft$disk:[MPLLIB.MMK]MMK_SETUP.COM
$!	@com_lib:if_exists as$share:[library.icon]deficon.com
$       @com_lib:if_exists mpl$data4:[mpl.tkb.icon.v9.bin]icon_setup.com
$!	define/job IPATH "[] icn_lib: mpl$data:[mpl.tkb.icon.ipl.ucode]"
$!	@com_lib:if_exists dra5:[mpl.tkb.icon]icon_setup
$!
$	@com_lib:if_exists mpl$data:[mpl.tkb.frg_devel.exe]frg_assigns	    !FRG logical names
$!	if f$type (map) .nes. "" then map cas_table in back
$!	@com_lib:if_exists cas_exe:cas_assigns
$!	@com_lib:if_exists uucp_bin:usercmds.com
$!
$! GNU stuff
$	if f$type(emacs_setup) .nes. "" then emacs_setup
$	define user "tkb"
$	define fullname "T. Kurt Bond"
$! 	@com_lib:if_exists gnu$data:[gnu.gccdist.gcc]gcc_install_2.com
$!	set command gnu$data:[gnu.gccdist.gcc]gcc.cld
$!	cc == "$gnu_cc:[000000]gcc_driver"
$!	@com_lib:if_exists gnu$data:[gnu.gccdist.bison]install_bison_2.com
$!	if f$search("GNU_BISON:[000000]BISON.CLD") .nes. "" then -
$!	    set command gnu_bison:[000000]bison.cld
$! 	gxx:==gcc/plus
$! 	genclass:==@gnu_cc:[000000]genclass
$! 	cxlink:==@gnu_cc:[000000]cxlink	!only if using non-shared libraries.
$! 	cxlink:==@gnu_cc:[000000]cxshare	!only if using shared libraries
$! 	cxshare:==@gnu_cc:[000000]cxshare
$! 	define/trans=conc gnu_cc_include zra6:[gcc.new_incl.],-
$!				 	 zra6:[gcc.new_incl.vms.]
$! 	cc :== gcc
$
$	@com_lib:if_exists soft$disk:[mpllib.make]make_setup.com
$!	@com_lib:if_exists mpl$data:[mpl.tkb.mmk]mmk_setup.com
$	@com_lib:add_help_lib mmk_dir:mmk.hlb
$	@com_lib:add_help_lib multinet:multinet.hlb
$	@com_lib:add_help_lib multinet:multinet_tcpview.hlb
$
$!
$! Scheme stuff
$!	@com_lib:if_exists dra4:[mpl.tkb.xs]xscheme_login.com
$!	@com_lib:if_exists dra4:[mpl.tkb.umb]umbscheme_login.com
$!	@com_lib:if_exists mpl$data:[mpl.tkb.scheme.scm]scm_setup.com
$!	@com_lib:if_exists mpl$data:[mpl.tkb.scheme.slib]slib_setup.com
$ endif
$!
$!                                                  
$!----------------------------------------------------------------------------!
$! Interactive only option
$!----------------------------------------------------------------------------!
$	! 2012-05-14: temporarily always skip interactive.
$	goto Skip_Interactive
$	if f$mode() .nes. "INTERACTIVE" then goto Skip_Interactive
$
$!	reply/enable
$	on error then goto noen ! no entry
$	show entry
$ noen: on error then exit
$!
$!----------------------------------------------------------------------------!
$!	Reset proc name to my name, if need add an _'cnt'.
$!----------------------------------------------------------------------------!
$	set message/noid/nofac/nosev/notext
$	cnt = 1
$	username = f$edit (f$getjpi (0,"USERNAME"), "LOWERCASE,TRIM")
$ name:	on error then goto err
$ 	name = username
$ 	if cnt .gt. 1 then name = username + "_" + f$string(cnt)
$ 	set proc/name="''name'"
$ 	goto cont
$ err:	cnt = cnt + 1
$ 	goto name
$ cont: on error then exit
$!
$!----------------------------------------------------------------------------!
$!	set up environment.
$!----------------------------------------------------------------------------!
$	set control=t
$	set term /inquire /line_edit /insert 
$	set broadcast=all
$	set message /id /fac /sev /text ! should this at end  of prev section?
$!
$!----------------------------------------------------------------------------!
$!	set up compiler commands.
$!----------------------------------------------------------------------------!
$	@compiler_file initialize -obj~ ! don't delete object files
$!
$!----------------------------------------------------------------------------!
$!	define all temp files!
$!----------------------------------------------------------------------------!
$	if where .nes. "mpl" then goto skip_temp_files
$ 	max_temp_files == 10
$	cnt = 0
$ 1:	if cnt .gt. max_temp_files then goto 2
$	define t'cnt' scr:t'cnt'.t
$	cnt = cnt + 1
$	goto 1
$ 2:	z$ = "dms$scratch:%%%" + f$getjpi("", "pid")+ ".tmp;*"
$ 	define temporary_files 'z$'
$ skip_temp_files:
$!
$!----------------------------------------------------------------------------!
$!	check with time lord
$!----------------------------------------------------------------------------!
$! 	if where .eqs. "mpl" then write sys$output "timelord exit/list"
$!	if f$trnlnm ("sys$node") .eqs. "tvnode::" 
$!	then 
$!	    set prompt="mploak $ "
$!	else
$!	    if where .eqs. "mpl" then set prompt="mplash $ "
$!	endif
$!
$!----------------------------------------------------------------------------!
$!	message to user
$!----------------------------------------------------------------------------!
$ if f$search("login$message") .nes. "" then type login$message
$ 	write sys$output ""
$ 	sho quota
$!
$ Skip_Interactive:
$!
$!----------------------------------------------------------------------------!
$! Batch only option
$!----------------------------------------------------------------------------!
$	if f$mode() .nes. "BATCH" then goto Skip_Batch
$!	set verify
$ Skip_Batch:
$	exit
$!
$!----------------------------------------------------------------------------!
$!
$!	Program:	S E T U P . C O M
$!	By:		C. Paul Bond
$!	Version:	1.00a
$!	Date:		6-19-86
$!	Description:
$!	    SetUp defines all the special options of a process.  The
$!	options might differ from an interactive process to a batch process.
$!	The SetUp command file is called from as the last step in the
$!	normal login procedure.
$!
$!
$!	History:
$!  Date   Who  What
$! 061986  CPB  Initial version.
$! 082286  tkb  Change to fit my account at mpl.
$! 100186  tkb  Clean up and standardize some things
$! 072288  tkb  Add emacs_setup and check for modem...
$! 921229  tkb  Change to for move to 3600.  (Many other changes before)
$!
$!----------------------------------------------------------------------------!
