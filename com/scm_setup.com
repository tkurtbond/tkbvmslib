$ scm :==  $MPL$DATA:[MPL.TKB.SCM]SCM.EXE
$ vmsscm :== $MPL$DATA:[MPL.TKB.SCM]VMSSCM.EXE
$ smgscm :== $MPL$DATA:[MPL.TKB.SCM]SMGSCM.EXE
$ define lib$scheme MPL$DATA:[MPL.TKB.SLIB]
