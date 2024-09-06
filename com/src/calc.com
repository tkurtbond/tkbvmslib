$!> CALC.COM -- Calculator program. Written by CPB.
$	frmt = "Decimal = !SL      Hex = !XL     Octal = !OL"
$ start:
$ 	on warning then goto start
$	inquire string "Calc"
$	if string .eqs. "" then goto clean_up
$	equal_sign = f$locate("=", string)
$	if equal_sign .eq. f$length(string) then goto expression
$ statement:
$	'string'
$	symbol = f$extract(0, equal_sign, string)
$	q = 'symbol'
$	write sys$output "''f$fao(frmt, q, q, q)'"
$	goto start
$ expression:
$	q = f$integer('string')
$	write sys$output "''f$fao(frmt, q, q, q)'"
$	goto start
$ clean_up:
$	exit
