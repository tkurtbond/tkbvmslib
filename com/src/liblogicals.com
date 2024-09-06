$ !> LIBLOGICALS.COM -- Define logical names for library programs. 
$ !a--------------------------------------------------------------------------!
$ !b
$ !c Logical name definitions for Library and utility programs
$ !d
$ !e	libroot is a directory spec without a closing `]', set in LOGIN.COM
$ !f	p1 is "FILLER"
$ !g	p2 is optionally "/job"
$ !h--------------------------------------------------------------------------!
$ define 'p2' com			com_lib
$ define 'p2' com_lib			'libroot'.tkbvmslib.com]
$ define 'p2  com_src			'libroot'.tkbvmslib.com.src]
$ define 'p2' com_sdcl                  'libroot'.tkbvmslib.com.sdcl]
$ define 'p2' compiler_file		com_lib:compiler.com
$ define 'p2' dis_lib			'libroot'.tkbvmslib.mdist]
$ define 'p2' doc_lib			'libroot'.tkbvmslib.doc]
$ define 'p2' edt_com			'libroot'.tkbvmslib.exe]
$ define 'p2' emx_lib			'libroot'.tkbvmslib.emacs]
$ define 'p2' eve_lib			'libroot'.tkbvmslib.eve]
$ define 'p2' exe			exe_lib			!,utl_lib
$ define 'p2' exe_lib			'libroot'.tkbvmslib.exe]
$ define 'p2' hea_lib			'libroot'.tkbvmslib.header]
$ define 'p2' here			"sys$disk:[]"
$ define 'p2' hg_sd_hlb			'libroot'.tkbvmslib.exe]sd.hlb
$ define 'p2' icn_lib			'libroot'.tkbvmslib.iconlib]
$ define 'p2' IPATH			'libroot'.tkbvmslib.iconlib.procs]
$ define 'p2' lib_dir			'libroot'.tkbvmslib]
$ define 'p2' lib_src			'libroot'.tkbvmslib.src]
$ define 'p2' login_message		'libroot'.tkbvmslib]login.message
$ define 'p2' lsp_lib			'libroot'.tkbvmslib.lisp]
$ define 'p2' most_help			'libroot'.tkbvmslib.exe]most.doc
$ define 'p2' scn_lib			'libroot'.tkbvmslib.sstg]
$ define 'p2' sdcl_dir			'libroot'.tkbvmslib.exe]
$ define 'p2' sdcl_lib			'libroot'.tkbvmslib.sdcllib]
$ define 'p2' src_lib			'libroot'.tkbvmslib.src]
$ define 'p2' time_lib			'libroot'.tkbvmslib.time]
$ define 'p2' tmp_dir			'libroot'.tmp]
$ define 'p2' tpu$section		eve_lib:tkb
$ define 'p2' mmk_personal_rules	com_lib:mmk_personal_rules.mms
$ exit ! liblogicals.com
$ sd		:== $exe_lib:sd

