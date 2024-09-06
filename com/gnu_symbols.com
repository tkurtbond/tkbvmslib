$!> GNUSYMBOLS.COM - DCL Symbols for GNU programs
$ cat           :== $zra6:[gnu.bin]cat.exe
$ cmp           :== $zra6:[gnu.bin]cmp.exe
$ comm          :== $zra6:[gnu.bin]comm.exe
$ csplit        :== $zra6:[gnu.bin]csplit.exe
$ cut           :== $zra6:[gnu.bin]cut.exe
$ expand        :== $zra6:[gnu.bin]expand.exe
$ fold          :== $zra6:[gnu.bin]fold.exe
$ head          :== $zra6:[gnu.bin]head.exe
$ join          :== $zra6:[gnu.bin]join.exe
$ paste         :== $zra6:[gnu.bin]paste.exe
$ if f$type (print) .eqs. "STRING" then delete/symbol/global print
$ pr            :== $zra6:[gnu.bin]pr.exe
$ sort          :== $zra6:[gnu.bin]sort.exe
$ split         :== $zra6:[gnu.bin]split.exe
$ sum           :== $zra6:[gnu.bin]sum.exe
$ tac           :== $zra6:[gnu.bin]tac.exe
$ tail          :== $zra6:[gnu.bin]tail.exe
$ unexpand      :== $zra6:[gnu.bin]unexpand.exe
$ uniq          :== $zra6:[gnu.bin]uniq.exe
$ wc            :== $zra6:[gnu.bin]wc.exe
