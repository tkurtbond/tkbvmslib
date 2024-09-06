#include <fab.h>
	
#define RME$C_SETRFM 1
	 
struct FAB * fab;
	
main(int argc, char * argv[]){
  int i, status;
  fab = (struct FAB*) malloc(sizeof(struct FAB));
  *fab = cc$rms_fab;	/* initialize FAB*/
  fab->fab$b_fac = FAB$M_PUT;
  fab->fab$l_fop |= FAB$M_ESC;
  fab->fab$l_ctx = RME$C_SETRFM;
  fab->fab$w_ifi = 0;
  for(i=1;i<argc;i++){
    printf("Setting %s to variable length records.\n",argv[i]);
    fab->fab$l_fna = argv[i];
    fab->fab$b_fns = strlen(argv[i]);
    status = sys$open(fab,0,0);
    if((status & 7) != 1) lib$signal(status);
    fab->fab$b_rfm = FAB$C_VAR;
    status = sys$modify(fab,0,0);
    if((status & 7) != 1) lib$signal(status);
    status = sys$close(fab,0,0);
    if((status & 7) != 1) lib$signal(status);
  };
}
