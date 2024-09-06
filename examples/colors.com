$       esc[0,8] = %x1B ! String now contains an ESC.
$       csi = esc + "["
$       red = csi + "1;31m"
$       normal = csi + "0m"
$       long = red + "////////////////////////////////////////////////////////////////////////////////" + normal
$       write sys$output "long's length: ", f$length (long)
$       write sys$output red, "This is red.", normal, " and this is normal"
$       write sys$output long
$       write sys$output long
$       write sys$output "goodbye"
