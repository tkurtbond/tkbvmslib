$ path = p1
$ if path .eqs. "" then path = "sys$examples:"
$ build :== edit/tpu/nodisplay/section=eve$section-
	/command='path'eve$build/noinit/output=tkb_eve
$ exit
