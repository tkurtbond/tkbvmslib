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
Software Tools Virtual Operating System from the `Software Tools User
Group <https://en.wikipedia.org/wiki/Software_Tools_Users_Group>`_)
tools ``admin``, ``delta``, and ``get``.  Generally, that means that
that for directories that have a ``tcs`` directory (``[.TCS]`` under
VMS), then the files in the directory that are under version control
have a matching file in the ``tcs`` direcctory that have matching
filenames with ``-tcs`` on the end of the file type.  So, for
instance, ``lib/com/sdcl/tcs.sdcl`` has a TCS version control file
``lib/com/sdcl/tcs.sdcl/tcs/tcs.sdcl-tcs``.  TCS version control files
are purely textual files, which is why they are in this repository.

There are several ``descrip.mms`` and related ``.mms`` files in this
repository.  These are the control files for the VMS Module Management
System (MMMS), the VMS equivalent of ``make``.  I actually use MMK,
the MadGoat Make Utility, which is compatible with MMS, but is free.
