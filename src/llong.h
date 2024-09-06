/* GCC for VMS v2.7.1 doesn't define LLONG_MIN, LLONG_MAX, or ULONG_MAX.  */

/* Minimum value for an object of type long long int -(2^63) or less* */
#define LLONG_MIN -9223372036854775807LL
/* Maximum value for an object of type long long int (2^63)-1 or greater* */
#define LLONG_MAX 9223372036854775807LL
/*  Maximum value for an object of type unsigned long long int (2^64)-1) or greater* */
#define ULLONG_MAX 18446744073709551615ULL
