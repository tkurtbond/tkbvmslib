TKB's VMS Library
@@@@@@@@@@@@@@@@@

This is a collection of TKB's library of programs, command procedures,
and various other files.  It originates on an emulated VAX/VMS machine
running VMS 5.5-2.

* lib/com - Commmand procedures run out of this directory.
* lib/com/src - DCL source for command procedures in lib/com.
* lib/com/sdcl - SDCL source for command procedures in lib/com.
* lib/doc - Random documents;  **NOT** documentation, generally.
* lib/emacs - Emacs lisp source files.
* lib/eve - Files I use with the EVE editor.
* lib/examples - Example programs kept for reference; not all compile.
* lib/iconlib - Procedures and programs written in the Icon computer language.
* lib/src - Source code to various procedures and programs.

Some of the files are under version control on the VAX, using the
Software Tools Virtual Operating System (SWTOOLS VOS) from the
`Software Tools User Group
<https://en.wikipedia.org/wiki/Software_Tools_Users_Group>`_) tools
``admin``, ``delta``, and ``get``.  Generally, that means that that
for directories that have a ``tcs`` directory (``[.TCS]`` under VMS),
then the files in the directory that are under version control have a
matching file in the ``tcs`` direcctory that have matching filenames
with ``-tcs`` on the end of the file type.  So, for instance,
``lib/com/sdcl/tcs.sdcl`` has a TCS version control file
``lib/com/sdcl/tcs.sdcl/tcs/tcs.sdcl-tcs``.  TCS version control files
are purely textual files, which is why they are in this repository.

I've written several command procedures for working with TCS files in
various ways.

First, for working with files in version control in the `same way
<https://tkurtbond.github.io/posts/2024/07/03/how-the-lbl-software-tools-system-organized-its-source-files/>`_
the SWTOOLS VOS uses to store its source files, with all the source
files in an archive file, which is then checked into a TCS file:

* `ardiff.sdcl
  <https://github.com/tkurtbond/tkbvmslib/blob/main/com/sdcl/ardiff.sdcl>`_.
  Compare archive file to the version in a SWTOOLS VOS archive.
* `aroutdated <https://github.com/tkurtbond/tkbvmslib/blob/main/com/sdcl/aroutdated.sdcl>`_.  Find if sources of SWTOOLS archive entries are newer.
* `aruncovered.sdcl <https://github.com/tkurtbond/tkbvmslib/blob/main/com/sdcl/aruncovered.sdcl>`_.  Check for files in current directory not in a archive.
* `tcsdiff.sdcl <https://github.com/tkurtbond/tkbvmslib/blob/main/com/sdcl/tcsdiff.sdcl>`_.  Compare a source file to a version in a TCS version control file.

Second, for working with files in version control where a file named
``FILE.TYPE`` has a machine TCS version control file names
``[.TCS]FILE.TYPE-TCS``:

* `tcs.sdcl <https://github.com/tkurtbond/tkbvmslib/blob/main/com/sdcl/tcs.sdcl>`_.  This provides the subcommands:

  - ``help``.  Display a usage message.

  - ``admin``.  Add a new file to TCS version control.

  - ``delta``.  Add a new version of a file to TCS version control.

  - ``diff``.  Compare a file to a version in TCS version control.

  - ``get``.  Get a version of a file from TCS version control.

  - ``init``.  Put all the files in the current directory under TCS
    version control.

  - ``mv``.  Move (rename) a file and its corresponding TCS version
    control file. to a new name.

  - ``outdated``.  List all the source files that are newer than their
    corresponding TCS version control files.

  - ``uncovered``.  List all the files in the current directory that
    do not have corresponding TCS version control files.

There are several ``descrip.mms`` and related ``.mms`` files in this
repository.  These are the control files for the VMS Module Management
System (MMMS), the VMS equivalent of ``make``.  I actually use MMK,
the MadGoat Make Utility, which is compatible with MMS, but is free.
