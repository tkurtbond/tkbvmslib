$ set def mpl$data:[mpl.tkb]
$ dir/nohead/notrail/by_owner=tkb dra0:[*...] /out=dra0.files
$ dir/nohead/notrail/by_owner=tkb dra1:[*...] /out=dra1.files
$ dir/nohead/notrail/by_owner=tkb dra2:[*...] /out=dra2.files
$ dir/nohead/notrail/by_owner=tkb dra3:[*...] /out=dra3.files
$ dir/nohead/notrail/by_owner=tkb dra4:[*...] /out=dra4.files
$ dir/nohead/notrail/by_owner=tkb dra5:[*...] /out=dra5.files
$ dir/nohead/notrail/by_owner=tkb dra6:[*...] /out=dra6.files
$ dir/nohead/notrail/by_owner=tkb dra7:[*...] /out=dra7.files
$ dir/nohead/notrail/by_owner=tkb dua0:[*...] /out=dua0.files
