$ v = 'f$verify(f$trnlnm("SHARE_VERIFY"))'
$! Purpose:
$!	Package a series of files into a format that can be mailed across
$!      most networks without damage.
$!
$! Parameters:
$!	P1 = a comma separated list of file specifications which are to be
$!	     packaged together.  Only files in or below the current 
$!	     subdirectory are permitted.
$!
$!	P2 = The name of an output share file. Any version number specified
$!	     here is ignored and the next highest version created. The file
$!	     may not appear in the input list.
$!
$! Privileges:
$!	None required
$!
$! Environment:
$!	Requires at least VMS 4.4 in order to use GOSUB
$!
$! Revision History:
$!	7.0	Andy Harper	9-May-1989	Complete rewrite
$!	7.1	Andy Harper	15-Jun-1989	Add file exclusion
$!	7.2	Andy Harper	20-FEB-1990	Various bug fixes
$!	7.2-001	Andy Harper	20-FEB-1990	Version check fix.
$!	7.2-002	Andy Harper	20-FEB-1990	Remove /nolog from sharefile.
$!	7.2-003	Andy Harper	20-FEB-1990	Rename 'buff' to 'b' in 
$!						  share file to save space.
$!	7.2-004	Andy Harper	20-FEB-1990	Properly check part separator
$!						  to stop spurious matches.
$!	7.2-005	Andy Harper	21-FEB-1990	Use Hex encoding
$!	7.2-006	Andy Harper	21-FEB-1990	Replace EXIT by QUIT
$!	7.2-007	Andy Harper	21-FEB-1990	Divert tpu o/p to NL: if not 
$!						  verifying when share file
$!						  unpacked.
$!
$!
$! Comments:
$!	We use a little known feature of f$parse to translate the
$!	brackets in directory names from <..> to [...]
$!	The format  f$parse(xx,"[]")  forces the brackets to [..]
$!	The format  f$parse(xx,"<>")  forces the brackets to <..>
$
$
$
$! INSULATE USER FROM EXTERNAL SYMBOL DEFINITIONS
$ set = "set"
$ set symbol/scope=(nolocal,noglobal)
$
$
$! DEFINE ESSENTIAL SYMBOLS
$ em="write sys$error ""%"+f$parse(f$environment("PROCEDURE"),,,"NAME")+ ""","
$ temp = f$parse("SHARE_TEMP","SYS$SCRATCH:SHARE_TEMP.TMP_"+f$getjpi("","PID"))
$ temp = f$parse(temp-f$parse(temp,,,"VERSION"),"[]") - ";"
$ default = f$parse("","[]") - ".;"
$
$ set noon
$ on control_y then $ goto abort
$
$
$! MAKE SURE WE CAN RUN ON THIS VERSION OF VMS
$ vers=f$getsyi("VERSION")
$ if vers - f$extract(0,1,vers) .lts. "4.4" then $ goto ancient_VMS
$
$
$! GET LIST OF FILES TO BE PACKAGED
$get_filespec:
$ if P1 .nes. "" then $ goto end_get_filespec
$ read/prompt="Filespec : " sys$command P1
$ goto get_filespec
$end_get_filespec:
$
$
$! GET NAME OF OUTPUT FILE
$sharespec:
$ if P2 .nes. "" then $ goto end_sharespec
$ read/prompt="Share file : " sys$command P2
$ goto sharespec
$end_sharespec:
$
$
$! MASSAGE FILE NAME TO FORCE SQUARE BRACKETS AROUND DIRECTORY NAME
$ P2 = f$parse(P2-f$parse(P2,,,"VERSION"),"[]") - ";"
$ if P2 .eqs. "" then $ goto nooutputdir
$ if f$parse(P2,,,"TYPE") .nes. "." then $ P2 = P2 + "_"
$
$
$! PICK UP PARAMETERS FROM USER, VIA LOGICALS. SET NECESSARY DEFAULTS
$ Real_Name = f$trnlnm("SHARE_REAL_NAME")
$ if Real_Name .nes. "" then $ Real_Name = "(" + Real_Name + ")"
$
$ Max_Part_Size = f$integer(f$trnlnm("SHARE_PART_SIZE"))
$ if Max_Part_Size .eq. 0 then $ Max_Part_Size = 30
$ if Max_Part_Size .lt. 6 then $ Max_Part_Size = 6
$
$ 
$ X_dir  = f$edit(f$trnlnm("SHARE_EXCLUDE_DIRS"), "UPCASE") + ","
$ X_name = f$edit(f$trnlnm("SHARE_EXCLUDE_NAMES"),"UPCASE") + ","
$ X_type = f$edit(f$trnlnm("SHARE_EXCLUDE_TYPES"),"UPCASE") + ",.DIR,"
$
$
$! OPEN A FILE FOR PASSING PARAMETERS TO THE TPU CODE
$ open/write/error=cantopen xx_share_params 'temp'
$ write xx_share_params f$edit(f$getjpi("","USERNAME"),"TRIM")," ", Real_Name
$ write xx_share_params Max_Part_Size
$ write xx_share_params P2
$
$
$! INITIALIZE FOR SCANNING THE FILENAMES
$ file_count = 0
$ file_element = -1
$
$! GET NEXT ELEMENT FROM COMMA SEPARATED LIST OF WILDCARDED FILESPEC ELEMENTS
$next_file_element:
$ file_element = file_element + 1
$ file = f$element(file_element,",",P1)
$ if file .eqs. "," then $ goto no_more_files
$
$! MASSAGE FILE NAME/PATTERN TO FORCE SQUARE BRACKETS AROUND DIRECTORY NAME
$ v = f$parse(file,,,"VERSION")
$ file = f$parse(file-v,"[]") - ";" + v
$
$
$! DO WE HAVE A FILE THAT MATCHES THIS SPECIFICATION???
$ file_name = f$search(file)
$ if file_name .eqs. "" then $ em "-W-FNF, ''file' not found. Ignored."
$ if file_name .eqs. "" then $ goto next_file_element
$
$ 
$! WE HAVE A VALID FILE SPEC SO GO DO SOME WORK ON IT.
$fname:
$ F_dir = f$parse(file_name,,,"DIRECTORY") +","
$ F_name= f$parse(file_name,,,"NAME") + ","
$ F_type= f$parse(file_name,,,"TYPE") + ","
$ if file_name-f$parse(file_name,,,"VERSION") .nes. temp then $ -
    if f$locate(F_dir,X_dir) .eq. f$length(X_dir) then $ -
        if f$locate(F_name,X_name) .eq. f$length(X_name) then $ -
            if f$locate(F_type,X_type) .eq. f$length(X_type) then $ -
                gosub process_file
$
$
$! LOCATE THE NEXT MATCHING FILENAME
$ previous_file = file_name
$ file_name = f$search(file)
$ if file_name .nes. "" .and. file_name .nes. previous_file then $ goto fname
$ goto next_file_element
$
$
$! NO MORE FILES, PROCESS THE LIST WE HAVE OBTAINED.
$no_more_files:
$ close xx_share_params
$ if file_count .ne. 0 then $ goto dopacking
$ em "-E-NOFILES, No files found."
$ goto cleanup
$
$
$
$Process_File: ! file_name, P2 (sharefile), file_count, default
$
$! CHECK FILE IS WITHIN OR BELOW CURRENT SUBDIRECTORY, REMOVE LEADING STUFF
$  x = file_name
$  check = x - f$parse(x,,,"VERSION") - P2
$  if f$type(check) .eqs. "INTEGER" then $ if check .gt. 0 then goto igsh
$  x = x - (default-"]")
$  c = f$extract(0,1,x)
$  if c .nes. "]" .and. c .nes. "." then $ goto cantarchive
$  x = "[" + x - "[]"
$
$  file_count = file_count + 1
$  em "-I-SELECTED, Selected file ''file_count' - ''x'"
$  checksum 'x'
$  write xx_share_params x, " ", checksum$checksum
$  return
$
$igsh:
$  em "-W-SHRNOTPACK, Share file part ''file_name' discovered. Not packaged!"
$  return
$
$cantarchive:
$ em "-E-NOTINTREE, ''file_name' not within/below current dir."
$ goto cleanup
$
$ancient_VMS:
$ em "-E-OLDVMS, Cannot run on VMS ",f$getsyi("VERSION")," need 4.4 at least"
$ goto cleanup
$
$cantopen:
$ em "-E-NOPARFIL, Unable to open temporary parameter file ''temp'"
$ goto reset_environment
$
$nooutputdir:
$ em "-E-NOOUTDIR, Directory for output file ''P2' not found."
$ goto cleanup
$
$abort:
$ em "-F-ABORT, Abort detected. Packing abandoned."
$cleanup:
$ if f$trnlnm("xx_share_params") .nes. "" then $ close xx_share_params
$ if f$search(temp) .nes. "" then $ delete /nolog /noconfirm 'temp';*
$reset_environment:
$ v = f$verify(v)
$ exit 44
$
$
$! WEVE GOT A LIST OF FILES TO PACK SO LETS DO IT NOW!
$dopacking:
$ edit/tpu/nosec/nodis/com=sys$input 'temp'
! +--------------------------------------------------------------------+
! + FACILITY:                                                          +
! +         VMS_SHARE                                                  +
! +                                                                    +
! + PURPOSE:                                                           +
! +         To package a series of plain text files into a format that +
! +         can be successfully mailed through most networks without   +
! +         damage:                                                    +
! +                                                                    +
! +         Characters prone to translation by mailers/networks are    +
! +         encoded into a form that will (hopefully) not be altered   +
! +         but we cannot recover if they ARE altered despite the      +
! +         encoding. A checksum is included so we can at least detect +
! +         corruption.                                                +
! +                                                                    +
! + RESTRICTIONS:                                                      +
! +         Text files only, NOT binary or executables                 +
! +                                                                    +
! +         No retransmit protocol with mailers, so cannot recover     +
! +         from mangled mail files such as missing lines, character   +
! +         translations etc.                                          +
! +                                                                    +
! + VERSION:                                                           +
! +         7.0-001   Pack multiple files into single part             +
! +         7.0-002   Produce multiple parts < Some maximum size       +
! +         7.0-003   Deal with subdirectories on output               +
! +         7.0-004   Output packed TPU code to unpack files           +
! +         7.0-005   Quote troublesome characters & trailing blanks   +
! +         7.0-006   Wrap long lines                                  +
! +                                                                    +
! +         7.1-001   Various bug fixes for release                    +
! +         7.1-002   Further minor bug fixes                          +
! +         7.1-003   Fix position of CUT HERE line in share file      +
! +         7.1-004   Support <> in directories and fix VMS version chk+
! +                                                                    +
! +         7.2       Various bug fixes                                +
! +                                                                    +
! +  AUTHOR:                                                           +
! +         (C) ANDY HARPER, KINGS COLLEGE LONDON, UK     1990         +
! +                                                                    +
! +  CREDITS:                                                          +
! +         James Gray for the first version of VMS_SHARE              +
! +         Michael Bednarek for the original idea and prototype       +
! +                                                                    +
! +--------------------------------------------------------------------+
!
!

! +--------------------------------------------------------------------+
! + Initialisation routine to set up global constant values            +
! +--------------------------------------------------------------------+

PROCEDURE Init_Constants;

   FAC_name       := "VMS_SHARE";	! Facility name/version
   FAC_vers       := "7.2-007  22-FEB-1990";
   FAC_unpack     := "UNPACK";		! Facility name of unpack code

   TPU_Max_Record_Length := 960;	! Max record length TPU supports
   TPU_separators := "&(),=;>@";	! Split packed TPU code on these

   Quote_Flag := "`";			! Flag for escaping troublesome chars

   DEBUG_state    := 0;			! Turn debugging ON/OFF
   Max_Line_Length:= 77;		! Maximum length of coded/packed lines
   Max_Parts      := 999;		! Maximum number of parts supported

   SPLIT_disallowed   := 0;		! Flags for dealing with part breaks
   SPLIT_permit_goto  := 1;
   SPLIT_inhibit_goto := 2;


!
! The following define strings used to separate out the parts. They are 
! defined like this to make it easier to refer to substrings later in the code
!
   FAO_Flag_Start := "-+-+-+-+-+-+-+-+";
   FAO_Flag_End   := "+-+-+-+-+-+-+-+-";
   FAO_Start_Part := FAO_Flag_Start + " START OF PART !UL " + FAO_Flag_Start;
   FAO_End_Part   := FAO_Flag_End   + "  END  OF PART !UL " + FAO_Flag_End;
   FAO_Flag_Length:= LENGTH(FAO_Flag_Start);


!
! These define special part separators where the split point falls on DCL code
! in the packed output file. These strings are used instead of the special
! ones immediately above in this case.
!
   FAO_start_label:= "$PART!UL:";
   FAO_end_goto   := "$ GOTO PART!UL";	! Format strings for DCL part separators


!
! The following define special characters/strings which appear at the start
! of key lines within user data in the packed output file.
!
   Flag_Initial_Line      := "X";	! Flag first line of a long line
   Flag_Continuation_Line := "V";	! Flag continuation lines.
   Flag_Start             := SUBSTR(FAO_Flag_Start,1,1);
   Flag_End               := SUBSTR(FAO_Flag_End,  1,1);
   Flag_Start_Rest        := SUBSTR(FAO_Flag_Start,2,FAO_Flag_Length-1);

ENDPROCEDURE;

! +--------------------------------------------------------------------+
! + Initialisation routine to set up tables                            +
! +                                                                    +
! + This routine sets up global tables that are used to perform various+
! + conversions on the characters in the files:                        +
! +                                                                    +
! +    ASCII_CHARS:     A table of ascii characters, used for mapping  +
! +                     characters into their 'escaped' form.          +
! +                                                                    +
! +    NON_PRINTABLES:  A table of characters which have no visible    +
! +                     representation. Used for determining which     +
! +                     characters to 'escape'.                        +
! +                                                                    +
! +    TROUBLE_CHARS:   Characters which may get randomly converted on +
! +                     passing thru the network and which therefore   +
! +                     will need 'escaping'.                          +
! +                                                                    +
! +--------------------------------------------------------------------+

PROCEDURE Init_Tables
LOCAL c;

  c := 0;
  ascii_chars    := "";			! Table of ASCII characters
  Non_Printables := "";			! Table of non-printing chars

  LOOP
    EXITIF C > 255;
    ascii_chars := ascii_chars + ASCII(c);

    IF (c < 32) OR (c > 126)
      THEN
         Non_Printables := Non_Printables + ASCII(c);
    ENDIF;
    c:=c+1;
  ENDLOOP;
    
  Trouble_chars :=			! Troublesome characters
                   ASCII(91)		! Left square bracket
                 + ASCII(93)		! Right square bracket
                 + ASCII(94)		! Caret
                 + ASCII(123)		! Left curly bracket
                 + ASCII(124)		! Vertical bar
                 + ASCII(125)		! Right curly bracket
                 + ASCII(126)		! Tilde
                ;

  Funny_Chars := Non_Printables + Trouble_Chars + Quote_Flag;

ENDPROCEDURE;

! +--------------------------------------------------------------------+
! +                                                                    +
! +  GENERAL UTILITY ROUTINES:                                         +
! +                                                                    +
! +     Inform(Xsev,Xident,Xtext);                                     +
! +        Output error message in usual VMS format                    +
! +                                                                    +
! +     Size_Buffer(Xbuffer);                                          +
! +        Returns the size in bytes of an arbitrary buffer. The       +
! +        routine estimates the amount of disk space the buffer       +
! +        would occupy if written to a file.  Ends of lines count as  +
! +        three characters here. This is a slight overestimate in     +
! +        practice but suffices.                                      +
! +                                                                    +
! +     Write_Part(Xbuffer,Part);                                      +
! +        Writes an arbitrary buffer to a file. The current share file+
! +        name is selected and the current 'part' number appended to  +
! +        the filename (eg. X.SHARn)                                  +
! +                                                                    +
! +     Move_Info(FromBuf,ToBuf);                                      +
! +        Shorthand for moving all info from one buffer to another    +
! +                                                                    +
! +     Copy_Line(Xstring);                                            +
! +        Adds a string to the current buffer and follows it with a   +
! +        new line character.                                         +
! +                                                                    +
! +     Reuse_Buffer(Xbuffer)                                          +
! +        Erase buffer contents and position to it.                   +
! +                                                                    +
! +                                                                    +
! +--------------------------------------------------------------------+



PROCEDURE Inform(Xsev,xident,Xtext)
LOCAL prefix;

  prefix := "%" + FAC_name + "-" + Xsev + "-" + Xident;
  MESSAGE( prefix + ", " + Xtext);

ENDPROCEDURE;


  
PROCEDURE Size_Buffer(Xbuffer)
LOCAL Size_Chars, Size_Lines;

   Size_Chars := LENGTH(CREATE_RANGE(BEGINNING_OF(Xbuffer),END_OF(Xbuffer),NONE));
   Size_Lines := GET_INFO(Xbuffer,"RECORD_COUNT");
   RETURN( Size_Chars + 3 * Size_Lines );

ENDPROCEDURE;



PROCEDURE Write_Part(Xbuffer,Part)
LOCAL f,r;

ON_ERROR
  Inform("E","FILWRERR", "Error writing part to file " + f);
ENDON_ERROR;

   f := Share_File+STR(Part);
   WRITE_FILE(Xbuffer,f);

   IF DEBUG_state
      THEN
        r := GET_INFO(Xbuffer,"RECORD_COUNT");
        Inform("I","DBGWRFIL",FAO("!UL line!%S written to !AS.",r,f));
   ENDIF;

ENDPROCEDURE;



PROCEDURE Move_Info(FromBuf, ToBuf)

   POSITION(ToBuf);   MOVE_TEXT(FromBuf);

ENDPROCEDURE;



PROCEDURE Copy_Line(Xstring)

   COPY_TEXT(Xstring); SPLIT_LINE;

ENDPROCEDURE;



PROCEDURE Reuse_Buffer(Xbuffer);

   ERASE(Xbuffer);
   POSITION(Xbuffer);

ENDPROCEDURE;

! +--------------------------------------------------------------------+
! + TPU CODE COMPRESSION ROUTINES                                      +
! +                                                                    +
! +    Pack_TPU(Xstring);                                              +
! +       This routine takes a line of TPU code as a parameter and     +
! +       adds it to the current buffer in a way that minimises        +
! +       as much redundant information as possible to produce as few  +
! +       lines as possible.  The compressed code will be added to the +
! +       output file to perform file decoding/unpacking.              +
! +                                                                    +
! +--------------------------------------------------------------------+


PROCEDURE Pack_TPU(Xstring)
LOCAL s,c;

  POSITION(END_OF(CURRENT_BUFFER));
  MOVE_HORIZONTAL(-1);

  s := Xstring;
  EDIT(s,TRIM);
  COPY_TEXT(s);

  c := SUBSTR(s,LENGTH(s),1);
  IF INDEX(TPU_separators,c) = 0
    THEN
      COPY_TEXT(" ");
  ENDIF;

  LOOP
    EXITIF CURRENT_OFFSET < Max_Line_Length;
    MOVE_HORIZONTAL(-1);
    POSITION( SEARCH( ANY(TPU_separators),REVERSE) );
  ENDLOOP;
                        
  IF LENGTH(CURRENT_LINE) > Max_Line_Length
    THEN
      MOVE_HORIZONTAL(1);	! Split just past the separator character
      SPLIT_LINE;
  ENDIF;

  IF DEBUG_state
    THEN
      Inform("I","DBGPCKTPUCUR","Current line is """ + CURRENT_LINE + """");
      Inform("I","DBGPCKTPUNEW","New string is   """ + s + """");
      Inform("I","DBGPCKTPULST","Last char is    """ + c + """");
  ENDIF;

ENDPROCEDURE;

! +--------------------------------------------------------------------+
! + BUFFER ENCODING ROUTINES                                           +
! +                                                                    +
! +    Quote_Character;                                                +
! +        Replaces the current character by an 'escape sequence'      +
! +        consisting of a flag character followed by exactly 2 digits +
! +        where the digits are the hexadecimal value of the ASCII code+
! +        of the character being replaced.                            +
! +                                                                    +
! +        The intention is to change characters which may get altered +
! +        in transit into something that is likely to pass thru       +
! +        unchanged. Restoration is effected at the receiving end.    +
! +                                                                    +
! +    Quote_Buffer(Xbuffer,p);                                        +
! +        This routine searches a buffer for a particular pattern     +
! +        (Usually one of a series of specific characters) and        +
! +        replaces the first character of that pattern by the 'escape'+
! +        sequence. This is performed at each occurence of that       +
! +        pattern in the buffer.                                      +
! +                                                                    +
! +    Wrap_Lines(Xbuffer, Max_Length);                                +
! +        This routine wraps lines longer than a fixed size so that   +
! +        all lines are less/equal to this size.  To allow rejoining  +
! +        All lines are prefixed with a flag to indicate an initial   +
! +        line or a continuation line.                                +
! +                                                                    +
! +        The intention here is to anticipate the actions of mailers  +
! +        which have line limits and preempt their wrapping attempts  +
! +        which would corrupt the data being transmitted. Doing it    +
! +        this way, we have control over rejoining them.              +
! +                                                                    +
! +--------------------------------------------------------------------+



PROCEDURE Quote_Character

  COPY_TEXT(Quote_Flag+FAO("!2XL",INDEX(ascii_chars,ERASE_CHARACTER(1))-1));

ENDPROCEDURE;

PROCEDURE Quote_Buffer(Xbuffer, p)
LOCAL r;

ON_ERROR
  IF ERROR = TPU$_STRNOTFOUND THEN RETURN; ENDIF;
ENDON_ERROR;

  POSITION( BEGINNING_OF(Xbuffer) );

  LOOP
    r := SEARCH(p, FORWARD, EXACT);
    EXITIF r=0;
    POSITION(r);

    IF DEBUG_state
      THEN
        Inform("I","DBGQUOBEFORE", "Current_Line_before="""+CURRENT_LINE+"""");
    ENDIF;

    IF LENGTH(CURRENT_LINE)+2 > TPU_Max_Record_Length
      THEN
        Inform("W","TPULONGREC", "Line overlong, Quoting suppressed");
        Inform("W","CURLINEIS",  """" + CURRENT_LINE + """");
        MOVE_HORIZONTAL(-CURRENT_OFFSET);
        MOVE_VERTICAL(1);
      ELSE
        Quote_Character;
    ENDIF;

    IF DEBUG_state
      THEN
        Inform("I","DBGQUOAFTER", "Current_Line_after ="""+CURRENT_LINE+"""");
    ENDIF;

  ENDLOOP;

ENDPROCEDURE;

PROCEDURE Wrap_Lines(Xbuffer, Max_Length)

  POSITION( BEGINNING_OF( Xbuffer ) );
  LOOP
    EXITIF MARK(NONE) = END_OF( CURRENT_BUFFER );

    COPY_TEXT( Flag_Initial_Line );
    LOOP
      EXITIF LENGTH(CURRENT_LINE) <= Max_Length;
  
      ! Find Last non-blank char on line
      MOVE_HORIZONTAL(Max_Length-1); 
      LOOP
        MOVE_HORIZONTAL(-1);
        EXITIF (CURRENT_CHARACTER <> " ") OR (CURRENT_OFFSET < 2);
      ENDLOOP;

      IF DEBUG_state
        THEN
          Inform("I","DBGWRPSPLIT","Splitting Line """+CURRENT_LINE+"""");
          Inform("I","DBGWRPCHAR", "Split char = """+CURRENT_CHARACTER+"""");
          Inform("I","DBGWRPOFF",  "Offset = " + STR(CURRENT_OFFSET));
      ENDIF;

      IF CURRENT_OFFSET < 2
        THEN
          MOVE_HORIZONTAL(Max_Length-4);
          Quote_Character;
        ELSE
          MOVE_HORIZONTAL(1);
      ENDIF;

      ! Split line at last non-blank char or at max line length
      SPLIT_LINE;
      COPY_TEXT(Flag_Continuation_Line);
    ENDLOOP;
 
    ! Move to start of next genuine line
    MOVE_HORIZONTAL(-1);
    MOVE_VERTICAL(1);

  ENDLOOP;

ENDPROCEDURE;

! +--------------------------------------------------------------------+
! + Routines to create headers and trailers for insertion in share file+
! +--------------------------------------------------------------------+

                                                  
PROCEDURE Create_Prologue_Head(Xbuffer, Creator, Blocks, Start_File_List)
LOCAL filecount,file,nextfile;

  Reuse_Buffer(Xbuffer);

  Copy_Line( "$! ------------------ CUT HERE -----------------------");
  Copy_Line( "$ v='f$verify(f$trnlnm(""SHARE_VERIFY""))'");
  Copy_Line( "$!" );
  Copy_Line( "$! This archive created by " + FAC_name + " Version " + FAC_vers);
  Copy_Line( FAO("$!!   On !%D   By user !AS", 0, Creator) );
  Copy_Line( "$!" );
  Copy_Line( "$! This " + FAC_name + " Written by:");
  Copy_Line( "$!    Andy Harper, Kings College London UK");
  Copy_Line( "$!" );
  Copy_Line( "$! Acknowledgements to:");
  Copy_Line( "$!    James Gray       - Original VMS_SHARE");
  Copy_Line( "$!    Michael Bednarek - Original Concept and implementation");
  Copy_Line( "$!");
  Copy_Line( "$!+ THIS PACKAGE DISTRIBUTED IN 999 PARTS, TO KEEP EACH PART");
  Copy_Line( "$!  BELOW " + STR(Blocks) + " BLOCKS");
  Copy_Line( "$!");
  Copy_Line( "$! TO UNPACK THIS SHARE FILE, CONCATENATE ALL PARTS IN ORDER");
  Copy_Line( "$! AND EXECUTE AS A COMMAND PROCEDURE  (  @name  )");
  Copy_Line( "$!");
  Copy_Line( "$! THE FOLLOWING FILE(S) WILL BE CREATED AFTER UNPACKING:");

  filecount := 0;
  nextfile := Start_File_List;
  LOOP
     POSITION(nextfile);
     EXITIF MARK(NONE) = END_OF(CURRENT_BUFFER);

     file := SUBSTR(CURRENT_LINE,1,INDEX(CURRENT_LINE," ")-1);
     MOVE_VERTICAL(1);
     nextfile := MARK(NONE);

     POSITION(Xbuffer);
     filecount := filecount + 1;
     Copy_Line( FAO("$!!     !3UL. !AS", filecount, file));

     IF DEBUG_state
        THEN
          Inform("I","DBGPROADFIL","Adding name """ + file + """ to prologue");
     ENDIF;

  ENDLOOP;
  POSITION(Xbuffer);

  Copy_Line( "$!");
  Copy_Line( "$set=""set""");
  Copy_Line( "$set symbol/scope=(nolocal,noglobal)");
  Copy_Line( "$f=f$parse(""SHARE_TEMP"",""SYS$SCRATCH:.TMP_""+f$getjpi("""",""PID""))");
  Copy_Line( "$e=""write sys$error  """"%"+FAC_unpack+""""", """);
  Copy_Line( "$w=""write sys$output """"%"+FAC_unpack+""""", """);
  Copy_Line( "$ if f$trnlnm(""SHARE_LOG"") then $ w = ""!""");
  Copy_Line( "$ ve=f$getsyi(""version"")");
  Copy_Line( "$ if ve-f$extract(0,1,ve) .ges. ""4.4"" then $ goto START");
  Copy_Line( "$ e ""-E-OLDVER, Must run at least VMS 4.4""");
  Copy_Line( "$ v=f$verify(v)");
  Copy_Line( "$ exit 44");
  Copy_Line( "$UNPACK: SUBROUTINE ! P1=filename, P2=checksum");
  Copy_Line( "$ if f$search(P1) .eqs. """" then $ goto file_absent");
  Copy_Line( "$ e ""-W-EXISTS, File ''P1' exists. Skipped.""");
  Copy_Line( "$ delete 'f'*");
  Copy_Line( "$ exit");
  Copy_Line( "$file_absent:");
  Copy_Line( "$ if f$parse(P1) .nes. """" then $ goto dirok");
  Copy_Line( "$ dn=f$parse(P1,,,""DIRECTORY"")");
  Copy_Line( "$ w ""-I-CREDIR, Creating directory ''dn'.""");
  Copy_Line( "$ create/dir 'dn'");
  Copy_Line( "$ if $status then $ goto dirok");
  Copy_Line( "$ e ""-E-CREDIRFAIL, Unable to create ''dn'. File skipped.""");
  Copy_Line( "$ delete 'f'*");
  Copy_Line( "$ exit");
  Copy_Line( "$dirok:");
  Copy_Line( "$ w ""-I-PROCESS, Processing file ''P1'.""");
  COPY_TEXT( "$ if .not. f$verify() then $ define/user sys$output nl:");

ENDPROCEDURE;



PROCEDURE Create_Prologue_Unpacker(Xbuffer)

  Reuse_Buffer(Xbuffer);

  Copy_Line("$ EDIT/TPU/NOSEC/NODIS/COM=SYS$INPUT 'f'/OUT='P1'");

  Pack_TPU( "PROCEDURE Unpacker" );
  Pack_TPU( "ON_ERROR" );				! Trap SEARCH error
  Pack_TPU( "ENDON_ERROR;" );

  Pack_TPU( "SET(FACILITY_NAME,"""+FAC_unpack+""");" );	! SETUP
  Pack_TPU( "SET(SUCCESS,OFF);" );
  Pack_TPU( "SET(INFORMATIONAL,OFF);" );
  Pack_TPU( "f:=GET_INFO(COMMAND_LINE,""file_name"");" );
  Pack_TPU( "b:=CREATE_BUFFER(f,f);" );
  
  Pack_TPU( "p:=SPAN("" "")@r&LINE_END;" );
  Pack_TPU( "POSITION(BEGINNING_OF(b));" );
  Pack_TPU( "LOOP" );					! Trailing blank removal
  Pack_TPU( "   EXITIF SEARCH(p,FORWARD)=0;" );
  Pack_TPU( "   POSITION(r);" );
  Pack_TPU( "   ERASE(r);" );
  Pack_TPU( "ENDLOOP;" );

  Pack_TPU( "POSITION(BEGINNING_OF(b));" );
  Pack_TPU( "g:=0;" );
  Pack_TPU( "LOOP" );					! Unwrap lines
  Pack_TPU( "  EXITIF MARK(NONE)=END_OF(b);" );
  Pack_TPU( "  x:=ERASE_CHARACTER(1);" );
  Pack_TPU( "  IF g=0 THEN" );
  Pack_TPU( "    IF x=""" + Flag_Initial_Line      + """ THEN");
  Pack_Tpu( "      MOVE_VERTICAL(1);ENDIF;" );
  Pack_TPU( "    IF x=""" + Flag_Continuation_Line + """ THEN APPEND_LINE;");
  Pack_TPU( "      MOVE_HORIZONTAL(-CURRENT_OFFSET);MOVE_VERTICAL(1);ENDIF;" );
  Pack_TPU( "    IF x=""" + Flag_End   + """ THEN g:=1;ERASE_LINE;ENDIF;" );
  Pack_TPU( "  ELSE" );
  Pack_TPU( "    IF x=""" + Flag_Start + """ THEN" );
  Pack_TPU( "      IF INDEX(CURRENT_LINE,"""+Flag_Start_Rest+""")=1 THEN");
  Pack_TPU( "         g:=0;ENDIF;" );
  Pack_TPU( "    ENDIF;" );
  Pack_TPU( "    ERASE_LINE;" );
  Pack_TPU( "  ENDIF;" );
  Pack_TPU( "ENDLOOP;" );

  Pack_TPU( "t:=""0123456789ABCDEF"";" );
  Pack_TPU( "POSITION(BEGINNING_OF(b));" );
  Pack_TPU( "LOOP" );					! Restore escaped chars
  Pack_TPU( "  r:=SEARCH(""" + Quote_Flag + """,FORWARD);" );
  Pack_TPU( "  EXITIF r=0;" );
  Pack_TPU( "  POSITION(r);" );
  Pack_TPU( "  ERASE(r);" );
  Pack_TPU( "  x1:=INDEX(t,ERASE_CHARACTER(1))-1;" );
  Pack_TPU( "  x2:=INDEX(t,ERASE_CHARACTER(1))-1;" );
  Pack_TPU( "  COPY_TEXT(ASCII(16*x1+x2));" );
  Pack_TPU( "ENDLOOP;" );

  Pack_TPU( "WRITE_FILE(b,GET_INFO(COMMAND_LINE,""output_file""));" );
  Pack_TPU( "ENDPROCEDURE;" );

  Pack_TPU( "Unpacker;");				! procedure call
  Pack_TPU( "QUIT;" );    SPLIT_LINE;			! EXIT code

  COPY_TEXT("$ delete/nolog 'f'*");

ENDPROCEDURE;

PROCEDURE Create_Prologue_Trail(Xbuffer)

  Reuse_Buffer(Xbuffer);

  Copy_Line( "$ CHECKSUM 'P1'");
  Copy_Line( "$ IF CHECKSUM$CHECKSUM .eqs. P2 THEN $ EXIT");
  Copy_Line( "$ e ""-E-CHKSMFAIL, Checksum of ''P1' failed.""");
  Copy_Line( "$ ENDSUBROUTINE");
  COPY_TEXT( "$START:");

ENDPROCEDURE;



PROCEDURE Create_File_Header(Xbuffer);

  Reuse_Buffer(Xbuffer);
  COPY_TEXT("$ create 'f'");

ENDPROCEDURE;



PROCEDURE Create_File(Xbuffer, Filename)
LOCAL r;

ON_ERROR
  Inform("E","FILRDERR", "Error reading from file " + FileName);
ENDON_ERROR;

  Reuse_Buffer(Xbuffer);
  READ_FILE(FileName);

  IF DEBUG_state
    THEN
      r := GET_INFO(Xbuffer,"RECORD_COUNT");
      Inform("I","DBGRDFIL",FAO("!UL line!%S read from file !AS",r,FileName));
  ENDIF;

ENDPROCEDURE;


PROCEDURE Create_File_Trailer(Xbuffer, Filename, Checksum);

  Reuse_Buffer(Xbuffer);
  COPY_TEXT("$ CALL UNPACK " + Filename + " " + Checksum);

ENDPROCEDURE;


PROCEDURE Create_Epilogue(Xbuffer);

  Reuse_Buffer(Xbuffer);
  Copy_Line("$ v=f$verify(v)");
  COPY_TEXT("$ EXIT");

ENDPROCEDURE;

! +--------------------------------------------------------------------+
! + PART SPLITTING ROUTINES                                            +
! +                                                                    +
! +    Find_Break(Xbuffer,Max_Size)                                    +
! +       This routine uses a fast binary search algorithm to find the +
! +       first line in the given buffer which straddles a given break +
! +       point - I.E. where the size of the buffer up to and including+
! +       that line would just go over the 'Max_Size' value (bytes).   +
! +       This allows us to quickly determine where a buffer should be +
! +       split when chopping up the info into several small parts.    +
! +                                                                    +
! +    Insert_Part_Separator(Part,Xendbuf,Xstartbuf,Split_status)      +
! +       This routine is responsible for choosing the correct part    +
! +       separator flag to insert at the beginning and end of parts.  +
! +       Determination is controlled by two factors:-                 +
! +                                                                    +
! +         First by the 'split-status' parameter, which determines if +
! +         a part break is permitted at this time (its not if, for    +
! +         example, we are currently in the middle of the TPU code    +
! +         which does the unpacking!) and, if it is, whether DCL      +
! +         $GOTO's and labels are useable at the breaks.              +
! +                                                                    +
! +         Second, the type of part separator is determined by looking+
! +         at the data in the buffer immediately following the break  +
! +         point. If it starts with '$' then we are splitting the     +
! +         buffer at the DCL code which is part of the unpacking      +
! +         control thus we can use $GOTO and a label.  If not, then   +
! +         we are in the midst of user data and should use the        +
! +         special flag lines                                         +
! +                                                                    +
! +    Add_to_part(Xbuffer,split-status)                               +
! +       This takes a buffer of information and adds as much of it    +
! +       as possible into the current part buffer, in order to fill   +
! +       it to its maximum size.  The remainder of the buffer is      +
! +       then copied into the part buffer in similar fashion, and     +
! +       we repeat until the supply of information is exhausted. Each +
! +       time the part buffer fills up it is flushed out to disk.     +
! +       Part 1 is treated separately as the attention message at the +
! +       head of the part needs to be updated later with the actual   +
! +       number of parts created. We therefore keep it around until   +
! +       the end in a separate buffer and flush it to disk at the end.+
! +                                                                    +
! +    Flush_buffer(Xbuffer,Part)                                      +
! +       Flushes the specified buffer to disk if not empty. The name  +
! +       of the file used is constructed from the original share      +
! +       file template and the current part number.                   +
! +                                                                    +
! +--------------------------------------------------------------------+
                                               
PROCEDURE Find_Break(Xbuffer,Max_Size)
LOCAL Low, High, Size, Line_Size, mb, New_Line, Cur_Line;

  IF DEBUG_State
    THEN
      Inform("I","DBGFNDBRKMAX","Max free bytes =" + STR(Max_Size));
  ENDIF;

  Low      := 0;
  High     := GET_INFO(Xbuffer,"record_count") - 1;
  Cur_Line := 0;

  mb := BEGINNING_OF(Xbuffer);
  POSITION(mb);

  ! Special case of an empty buffer
  IF mb = END_OF(Xbuffer) THEN RETURN(0); ENDIF;

  ! Special case check to ensure at least one line fits in available space
  IF LENGTH(CURRENT_LINE)+3 > Max_Size THEN RETURN(0); ENDIF;


  LOOP

     New_Line := (Low+High) / 2;
     MOVE_VERTICAL(New_Line-Cur_Line);
     Cur_Line := New_Line;

     Size:=LENGTH(CREATE_RANGE(mb,MARK(NONE),NONE))+3*Cur_Line;
     Line_Size := LENGTH(CURRENT_LINE) + 3;

     IF DEBUG_state
       THEN
         Inform("I","DBGFNDBRKRNG",FAO("Search range = !UL-!UL",Low,High));
         Inform("I","DBGFNDBRKCURL",FAO("(!UL) ""!AS""",Cur_line,CURRENT_LINE));
         Inform("I","DBGFNDBRKSIZE",FAO("Size=!UL, line=!UL",Size,Line_Size));
     ENDIF;

     EXITIF (Size < Max_Size) AND (Size+Line_Size >= Max_Size);

     IF Size < Max_Size
       THEN
         Low := Cur_Line + 1;
       ELSE
         High := Cur_Line - 1;
     ENDIF;

  ENDLOOP;

  MOVE_HORIZONTAL(-1);
  RETURN( CREATE_RANGE( mb, MARK(NONE), NONE ) );

ENDPROCEDURE;

PROCEDURE Insert_Part_Separator(Part, Xendbuf, Xstartbuf, SPLIT_status)
LOCAL end_text,start_text;

   IF SPLIT_status = SPLIT_disallowed
     THEN
       Inform("F","CANTSPLIT","Part split tried where disallowed");
       EXIT;
   ENDIF;

   POSITION( BEGINNING_OF(Xstartbuf) );

   IF (CURRENT_CHARACTER = "$") AND (SPLIT_status = SPLIT_permit_goto)
      THEN			! Executable DCL code insert GOTO/label pair
         end_text  := FAO(FAO_end_goto, Part+1);
         start_text:= FAO(FAO_start_label, Part+1);
      ELSE			! User data, insert recognizable separators
         end_text  := FAO(FAO_end_part, Part);
         start_text:= FAO(FAO_start_part, Part+1);
   ENDIF;        

   Copy_Line(start_text);      MOVE_VERTICAL(-1);
   POSITION(END_OF(Xendbuf));  COPY_TEXT(end_text);

ENDPROCEDURE;

PROCEDURE Add_To_Part(Xbuffer, SPLIT_status)
LOCAL Size_Xbuffer, Size_part_buf;

  LOOP

    Size_Xbuffer  := Size_Buffer(Xbuffer);
    Size_part_buf := Size_Buffer(part_buf); 

    IF DEBUG_state THEN
       Inform( "I","DBGADPTMAX" ,FAO("     Max_bytes    = !UL",Max_Bytes));
       Inform( "I","DBGADPTXSIZ",FAO("     Size xbuffer = !UL",Size_Xbuffer));
       Inform( "I","DBGADPTPSIZ",FAO("     Size part_buf= !UL",Size_part_buf));
    ENDIF;

    EXITIF Size_Xbuffer <= Max_Bytes-Size_part_buf-Reserved;

    PartNo := PartNo + 1;
    xbuf_range := Find_Break(Xbuffer,Max_Bytes-Size_part_buf-Reserved);
    POSITION( END_OF(part_buf) );
    IF xbuf_range <> 0 
      THEN
        Move_Info(xbuf_range, part_buf);
    ENDIF;
    Insert_Part_Separator(PartNo, part_buf, Xbuffer, SPLIT_status);
          
    IF PartNo = 1
       THEN
          Move_Info(part_buf, pt1_buf);
       ELSE
          Write_Part(part_buf, PartNo);  ERASE(part_buf);
    ENDIF;

  ENDLOOP;

  Move_Info(Xbuffer, part_buf);

ENDPROCEDURE;



PROCEDURE Flush_Buffer(Xbuffer,Part)

  IF Size_Buffer(Xbuffer) > 0
     THEN
        Write_Part(Xbuffer,Part);
  ENDIF;

ENDPROCEDURE;

! +--------------------------------------------------------------------+
! +   MAIN PROGRAM                                                     +
! +                                                                    +
! +   This is the main control loop of the program, responsible for    +
! +   picking up the parameters, creating the prologue and epilogue of +
! +   the share file, setting up global constants and variables etc.   +
! +                                                                    +
! +   It also contains the main loop which goes around each of the     +
! +   specified files to be packed into the share file.                +
! +                                                                    +
! +--------------------------------------------------------------------+



Init_Constants;
Init_Tables;

SET(SUCCESS,OFF);		! Suppress non-error messages
SET(FACILITY_NAME, FAC_name);	! identify ourself in errors

info_buf  := CREATE_BUFFER("{info}", GET_INFO(COMMAND_LINE, "FILE_NAME"));
part_buf  := CREATE_BUFFER("{part}");
pt1_buf   := CREATE_BUFFER("{part_1}");
work_buf  := CREATE_BUFFER("{work}");


! PICK UP PARAMETERS FROM THE OUTSIDE WORLD
POSITION( info_buf);
Username   := CURRENT_LINE;      MOVE_VERTICAL(1);
IF DEBUG_state
  THEN
    Inform("I","DBGPAR", "Params: Creator = """ + Username + """");
ENDIF;

Max_Blocks:= INT(CURRENT_LINE); MOVE_VERTICAL(1);
IF DEBUG_state
  THEN
    Inform("I","DBGPAR", "Params: Max_Blocks = " + STR(Max_Blocks));
ENDIF;


Share_File:= CURRENT_LINE;      MOVE_VERTICAL(1);
IF DEBUG_state
  THEN
    Inform("I","DBGPAR", "Params: Share_File = """ + Share_File + """");
ENDIF;

! INITIALIZE STUFF TO GO THROUGH FILES
Start_Of_Filenames := MARK(NONE);
PartNo := 0;
Max_Bytes := 512 * Max_Blocks;

! Reserve space in the part buffers for 1 start and 1 end part + CR/LF chars
! + a bit spare! They may not always be used but this is the worst case!
Reserved  := LENGTH(FAO(FAO_start_part,Max_Parts))
           + LENGTH(FAO(FAO_end_part,  Max_Parts))
           + 6;


! CREATE THE INITIAL SHARE FILE HEADER
Create_Prologue_Head(work_buf, Username, Max_Blocks, Start_Of_Filenames);
Add_To_Part(work_buf,SPLIT_permit_goto);

Create_Prologue_Unpacker(work_buf);
Add_To_Part(work_buf,SPLIT_disallowed);

Create_Prologue_Trail(work_buf);
Add_To_Part(work_buf,SPLIT_permit_goto);

POSITION(Start_Of_Filenames);

! LOOP AROUND, FILLING THE PART BUFFER WITH DATA FROM FILES
LOOP
   POSITION(info_buf);
   EXITIF MARK(NONE) = END_OF(info_buf);

   file_info := CURRENT_LINE;   MOVE_VERTICAL(1);
   separator := INDEX(file_info,' ');
   fname     := SUBSTR(file_info,1,separator-1);
   chksum    := SUBSTR(file_info,separator+1,LENGTH(file_info)-separator);

   IF DEBUG_state THEN
      Inform("I","DBGPAR", "Params: filename = """ + fname + """");
   ENDIF;

   Create_File_Header(work_buf);
   Add_To_Part(work_buf,SPLIT_permit_goto);

   Create_File(work_buf,fname);
   Quote_Buffer(work_buf, ANY(Funny_Chars));
   Quote_Buffer(work_buf, " "&LINE_END);
   Wrap_Lines(work_buf,Max_Line_Length);
   Add_To_Part(work_buf,SPLIT_inhibit_goto);

   Create_File_Trailer(work_buf,fname,chksum);
   Add_To_Part(work_buf,SPLIT_permit_goto);

ENDLOOP;

Create_Epilogue(work_buf);
Add_To_Part(work_buf,SPLIT_permit_goto);


PartNo := PartNo + 1;
POSITION(BEGINNING_OF(pt1_buf));


IF PartNo > 1
  THEN	! Modify the inital message to state exact number of parts
     POSITION(SEARCH( "$!+", FORWARD) );
     POSITION( SEARCH( STR(Max_Parts), FORWARD) );
     ERASE_CHARACTER(3);
     COPY_TEXT( STR(PartNo) );

  ELSE	! Erase initial attention message as there's only 1 part!
     MOVE_TEXT(part_buf);
     POSITION(BEGINNING_OF(pt1_buf));
     POSITION(SEARCH( "$!+", FORWARD) );
     ERASE_LINE; ERASE_LINE; ERASE_LINE;
ENDIF;

Flush_Buffer(part_buf, PartNo);
Flush_Buffer(pt1_buf,  1);

Inform("I","NOOFPTS",FAO("Share file written in !UL part!%S",PartNo));

quit;
$ delete /nolog /noconfirm 'temp';*
$ v=f$verify(v)
