$ !> DIRCMP.SDCL -- Compare all files in one directory to those in another.
$ wso :== write sys$output
$ wse :== write sys$error
$ src_dir = p1
$ cmp_dir = p2
$ errors = 0
$ if (.not.(src_dir .eqs. "")) then goto 23000
$ wse "No source directory specified!"
$ errors = errors + 1
$ 23000: 
$ if (.not.(cmp_dir .eqs. "")) then goto 23002
$ wse "No comparison directory specified!"
$ errors = errors + 1
$ 23002: 
$ if (.not.(errors .gt. 0)) then goto 23004
$ wse "Not all required arguments were specified!  Exiting...."
$ exit 2
$ 23004: 
$ wso "src_dir: ", src_dir
$ wso "cmp_dir: ", cmp_dir
$ search_spec = f$parse (src_dir, "*.*")
$ if (.not.(search_spec .eqs. "")) then goto 23006
$ wse "dircmp: Nothing found for ", src_dir
$ exit 2
$ 23006: 
$ old_spec = search_spec
$ wso "search_spec: ", search_spec
$ wso "old_spec:    ", old_spec
$ 23008: 
$ f = f$search (search_spec)
$ if (.not.((f .eqs. "") .or. (f .eqs. old_spec))) then goto 23011
$ goto 23010
$ 23011: 
$ version = f$parse (f,,, "VERSION")
$ f = f - version
$ wso "diff ", f, " ", cmp_dir
$ on error then continue
$ diff 'f 'cmp_dir
$ 23009: goto 23008
$ 23010: 
