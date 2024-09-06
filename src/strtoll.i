# 1 "strtoll.c"
 
 

 




























 




# 1 "GNU_CC_INCLUDE:[000000]ll_limits.h" 1

 
 




# 38 "strtoll.c" 2



# 1 "GNU_CC_INCLUDE:[000000]ctype.h" 1
 









extern __const char _ctype_[];
 



extern int __ctype_init__ __asm("_$$PsectAttributes_GLOBALVALUE$$c$v_ctypedefs");
static __const void *__ctype_hack__[] = {_ctype_,&__ctype_init__,&__ctype_hack__};

 









int toupper(int), tolower(int);    
int _toupper(int), _tolower(int);  

 



















 





# 41 "strtoll.c" 2

# 1 "GNU_CC_INCLUDE:[000000]errno.h" 1
 










































 



 

 




 

	 













	 













	 



 




 

 




 



 



 




 


 


 


 
extern __volatile int errno	__asm("_$$PsectAttributes_NOSHR$$errno");
 

extern __volatile int __gnuc_errno  __asm("_$$PsectAttributes_NOSHR$$vaxc$errno");








 
 

char	*strerror(int __err, ...);	 









# 42 "strtoll.c" 2



 





long long int
strtoll(const char *nptr, char **endptr, int base)
{
  const char *s;
   
  long long acc, cutoff;
  int c;
  int neg, any, cutlim;

   


   
  (void) &acc; (void) &cutoff;


   




  s = nptr;
  do {
    c = (unsigned char) *s++;
  } while ((_ctype_[( c )&0177] & 0010 ) );
  if (c == '-') {
    neg = 1;
    c = *s++;
  } else {
    neg = 0;
    if (c == '+')
      c = *s++;
  }
  if ((base == 0 || base == 16) &&
      c == '0' && (*s == 'x' || *s == 'X')) {
    c = s[1];
    s += 2;
    base = 16;
  }
  if (base == 0)
    base = c == '0' ? 8 : 10;

   

















  cutoff = neg ? (- (9223372036854775807LL)  - 1LL)  : (9223372036854775807LL) ;
  cutlim = (int)(cutoff % base);
  cutoff /= base;
  if (neg) {
    if (cutlim > 0) {
      cutlim -= base;
      cutoff += 1;
    }
    cutlim = -cutlim;
  }
  for (acc = 0, any = 0;; c = (unsigned char) *s++) {
    if ((_ctype_[( c )&0177] & 0004 ) )
      c -= '0';
    else if ((_ctype_[( c )&0177] & (0001 | 0002 )) )
      c -= (_ctype_[( c )&0177] & 0001 )  ? 'A' - 10 : 'a' - 10;
    else
      break;
    if (c >= base)
      break;
    if (any < 0)
      continue;
    if (neg) {
      if (acc < cutoff || (acc == cutoff && c > cutlim)) {
        any = -1;
        acc = (- (9223372036854775807LL)  - 1LL) ;
        errno = 34 ;
      } else {
        any = 1;
        acc *= base;
        acc -= c;
      }
    } else {
      if (acc > cutoff || (acc == cutoff && c > cutlim)) {
        any = -1;
        acc = (9223372036854775807LL) ;
        errno = 34 ;
      } else {
        any = 1;
        acc *= base;
        acc += c;
      }
    }
  }
  if (endptr != 0)
     
    *endptr = (char *)(any ? s - 1 : nptr);
  return (acc);
}



# 1 "GNU_CC_INCLUDE:[000000]stdio.h" 1
 










# 1 "GNU_CC_INCLUDE:[000000]stddef.h" 1
 





 




 

typedef int ptrdiff_t;




 

typedef unsigned size_t;




 




typedef unsigned int wchar_t;




 





 


 









# 12 "GNU_CC_INCLUDE:[000000]stdio.h" 2



 





 








 




 	 

 


struct	_iobuf	{
	int	_cnt;			 
	char	*_ptr;			 
	char	*_base;			 
	char	_flag;			 








	char	_file;			 
};

 



typedef struct _iobuf *FILE;

 



typedef struct _FPOS_T { unsigned : 32, : 32; } fpos_t;

 




extern FILE *stdin	__asm("_$$PsectAttributes_NOSHR$$stdin");
extern FILE *stdout	__asm("_$$PsectAttributes_NOSHR$$stdout");
extern FILE *stderr	__asm("_$$PsectAttributes_NOSHR$$stderr");

 

















 








 



int	getchar(void);
int	putchar(int);










 



 










 




 
FILE	*fopen(const char *,const char *,...);
FILE	*fdopen(int,const char *);
FILE	*freopen(const char *,const char *,FILE *,...);
int	 fflush(FILE *);
int	 fclose(FILE *);

 
int	 fgetc(FILE *file_ptr);
int	 ungetc(int,FILE *);
int	 fputc(int,FILE *);
int	 getw(FILE *file_ptr);
int	 putw(int,FILE *);
char	*gets(char *);
int	 puts(const char *);
char	*fgets(char *,int,FILE *);
int	 fputs(const char *,FILE *);
size_t	 fread(void *,size_t,size_t,FILE *);
size_t	 fwrite(const void *,size_t,size_t,FILE *);

 

int   scanf   	(const char *,...)  ;
int   printf   	(const char *,...)  ;
int   vprintf   	(const char *,char * )  ;
int   fscanf   	(FILE *,const char *,...)  ;
int   fprintf   	(FILE *,const char *,...)  ;
int   vfprintf    (FILE *,const char *,char * )  ;
int   sscanf   	(const char *,const char *,...)  ;
int   sprintf   	(char *,const char *,...)  ;
int   vsprintf    (char *,const char *,char * )  ;


 
int	 fseek(FILE *,long,int);
long	 ftell(FILE *);
int	 fsetpos(FILE *,const fpos_t *);
int	 fgetpos(FILE *,fpos_t *);
int	 rewind(FILE *);

 
void	 perror(const char *);
int	 remove(const char *);
void	 setbuf(FILE *,char *);
int	 setvbuf(FILE *,char *,int,size_t);
char	*fgetname(FILE *,char *,...);  
char	*tmpnam(char *);
FILE	*tmpfile(void);

# 213 "GNU_CC_INCLUDE:[000000]stdio.h"








# 162 "strtoll.c" 2


extern char* lltoa(long long val, int base);


int
main (int argc, char **argv)
{
  long long llmin = (- (9223372036854775807LL)  - 1LL) ;
  long long llmax = (9223372036854775807LL) ;
  unsigned long long ullmax = (18446744073709551615ULL) ;

  printf ("min:  %s\n", lltoa(llmin, 10));
  printf ("max:  %s\n", lltoa(llmax, 10));





}

