#define GOBINFO_VERSION "v 1.1"

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <math.h>
#include <time.h>
#include <errno.h>
#include <fcntl.h>
#include <io.h>
#include <dos.h>
#include <sys\types.h>
#include <sys\stat.h>

#define TOOLKIT_NO_GRAPHICS
#include "toolkit.c"

#include "dark.h"
#include "dark.c"

#define BUF_SIZE        4096

#define ERR_NOERROR       00
#define ERR_CMDLINE       10
#define ERR_WRONGFILE     20
#define ERR_NOTGOB        30
#define ERR_TOOLONG       40

char            fname1[80]     ;
char            where[10]      ;
unsigned char   buf1[BUF_SIZE] ;
int             f1             ;

long            master_index   ;
long            master_entries ;
long            counter;


struct GOB_BEGIN ws;
struct GOB_INDEX_ENTRY is;

main()
{
if(strcmp(_argv[2], "/x") != 0)
 if(strcmp(_argv[2], "/r") != 0)
  if(strcmp(_argv[2], "/s") != 0)
  printf("\nGOBINFO "GOBINFO_VERSION" (c) Yves BORCKMANS 1995.\n\n");

/* Check number of arguments */
if(!(     (_argc == 2)
      || ((_argc == 3) && (strcmp(_argv[2],"/x") == 0))
      || ((_argc == 3) && (strcmp(_argv[2],"/r") == 0))
      || ((_argc == 3) && (strcmp(_argv[2],"/s") == 0))
    )
  )
  {
   printf("Usage is GOBINFO gobfile\n");
   printf("OR       GOBINFO gobfile /x  (to generate an extract file)\n");
   printf("OR       GOBINFO gobfile /s  (ultra silent extract file)\n");
   printf("OR       GOBINFO gobfile /r  (to generate an name only file)\n");
   return(ERR_CMDLINE);
  }

strcpy(fname1  , _argv[1]);

/* Check existence of the files */
if(fexists(fname1) == FALSE)
  {
   printf("%s doesn't exist! \n",fname1);
   return(ERR_WRONGFILE);
  };

if(is_gob(fname1) == FALSE)
 {
  printf("%s isn't a GOB file! \n",fname1);
  return(ERR_NOTGOB);
 }

f1 = open(fname1 , O_BINARY | O_RDONLY);

master_index   = get_master_index(f1);
master_entries = get_master_entries(f1);
if(strcmp(_argv[2], "/x") != 0)
 if(strcmp(_argv[2], "/r") != 0)
  if(strcmp(_argv[2], "/s") != 0)
   printf("Master Index is at 0x%8.8lX (%8.8ldd). It has %ld entries.\n\n",
                          master_index, master_index, master_entries);
seek_master_index(f1);
counter = 0;
/* while(counter < master_entries) */
while(!eof(f1))
{
 read(f1 , &is , sizeof(is));
 if(strcmp(_argv[2], "/x") != 0)
  if(strcmp(_argv[2], "/s") != 0)
   if(strcmp(_argv[2], "/r") != 0)
    printf("%-12.12s : IX = 0x%8.8lX  (%8.8ldd)   LEN = 0x%6.6lX  (%6.6ldd)  \n",
         is.NAME, is.IX, is.IX, is.LEN, is.LEN);
   else
     printf("%s\n", is.NAME);
  else
    printf("@FEXTRACT -S:%8.8ld -L:%6.6ld %s %s > NUL\n", is.IX, is.LEN, fname1, is.NAME);
 else
   printf("FEXTRACT -S:%8.8ld -L:%6.6ld %s %s\n", is.IX, is.LEN, fname1, is.NAME);

 counter++;
}

close(f1);
return(ERR_NOERROR);
}
