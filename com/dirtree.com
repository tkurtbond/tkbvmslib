$ verify_on = f$verify(0)
$ !
$ !----------------------------------------------------------------------!
$ !
$ !	Program:			D I R T R E E . C O M
$ !	By:				C. Paul Bond
$ !	Version:			3.00a
$ !	Date:				2-7-1988
$ !
$ !	Description:
$ !	      The DirTree command file produces a listing of
$ !	the subdirectory structure.  As a directory is found it
$ !	is listed and searched for subsirectorys.  Each subdirectory
$ !	found at this level is indented 'IndentSize', and in turn each 
$ !     subdirectory found is listed and searched for subdirectories.  
$ !     When the process is finished a listing of all directories and there
$ !	related structure is produced.
$ !
$ !     StartDir (p1) - Directory to start from
$ !     Options  (p2) - Options to control display
$ !                     U - Include the uic
$ !			D - Include the full directory spec
$ !
$ !
$ !	History:
$ !   Ver     When    Who  What
$ !  1.01a  03-10-87  cpb  changed format to use calls
$ !  2.00a  03-12-87  cpb  rewrite to use a stack to hold context info
$ !  2.00b  03-20-87  cpb  remove problem with zero level dir names ("000000")
$ !  3.00a  01-07-88  cpb  Converted to DCL from sDCL.
$ !
$ !----------------------------------------------------------------------!
$ !> DIRTREE.COM -- Create a listing of all directories
$ !
$ on control_y then goto exit_loop
$ StartDir = p1
$ Options = f$edit(p2, "upcase,trim")
$ Display_UIC = f$locate("U", Options) .ne. f$length(Options)
$ FullDirSpec = f$locate("D", Options) .ne. f$length(Options)
$ if p1 .eqs. "" then inquire StartDir "_Starting directory"
$ if StartDir .eqs. "" then exit
$ !
$ IndentSize = 4
$ Tab = f$fao("!4* ")
$ Level = f$fao("|!#* ", IndentSize - 1)
$ Indent = Level + Level + Level + Level + Level + Level + Level + Level
$ !
$ DevSpec = f$parse(p1,,,"device")
$ DirSpec = f$parse(p1,,,"directory") - "[" - "]"
$ write sys$output "Structure of Directory ", DevSpec, "[", DirSpec, "]"
$ !
$ !
$ Top = 0
$LOOP:
$SKIP_ZERO_LOOP:
$ FileSpec = f$search(DevSpec + "[" + DirSpec + "]*.dir;1", Top)
$ FileSpec = f$parse(FileSpec,,,"name")
$ if FileSpec .eqs. "000000" then goto skip_zero_loop
$ !
$ if FileSpec .nes. "" then goto push_level
$ if Top .eq. 0 then goto exit_loop
$ !
$ ! Pop a level off the stack
$ !
$ if Top .gt. 0 then goto pop_level
$ write sys$output "DirSpec Stack underflow!"
$ goto exit_loop
$POP_LEVEL:
$ DirSpec = DirSpec_'Top'
$ Top = Top - 1
$ goto loop
$ !
$ !         
$PUSH_LEVEL:
$ !
$ ! Push a level onto the stack
$ !
$ Top = Top + 1
$ DirSpec_'Top' = DirSpec
$ !show sym top
$ !show sym dirspec
$ !
$ ! Display the current directory
$ !
$ Offset = Tab + f$extract(0, (Top - 1) * IndentSize, Indent)
$ Line = OffSet + FileSpec
$ if FullDirSpec then Line = "[" + DirSpec + "." + FileSpec + "]"
$ UIC = ""
$ if Display_UIC then UIC = f$file(DevSpec + "[" + DirSpec + "]" + FileSpec + ".dir;1", "UIC")
$ LineWidth = 40
$ if FullDirSpec then LineWidth = 65
$ if f$length(Line) .le. LineWidth then goto display
$ write sys$output line
$ line = ""
$DISPLAY:
$ if Display_UIC then Line = f$fao("!#AS !AS", LineWidth, Line, UIC)
$ write sys$output Line
$ DirSpec = DirSpec + "." + FileSpec
$ goto Loop
$ !
$ !
$EXIT_LOOP:
$ exit $status + 0 * f$verify(verify_on)
