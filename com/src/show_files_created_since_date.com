$! I should generalize this to parameterize the disks and the date.
$ dir $1$dia1:[*...]/since=10-oct-2023/create/out=sys$scratch:dia1_size.size/size=all/width=filename=50/date=create
$ dir $1$dia5:[*...]/since=10-oct-2023/create/out=sys$scratch:dia5_size.size/size=all/width=filename=50/date=create
