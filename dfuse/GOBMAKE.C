#define GOBMAKE_VERSION "v 1.01"

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

#define BUF_SIZE       20480     /* 20k buffer for file transfer */

#define ERR_NOERROR       00
#define ERR_CMDLINE       10
#define ERR_WRONGFILE     20
#define ERR_NOTGOB        30
#define ERR_TOOLONG       40

char            fnamegom[80]   ;  /* gom file                      */
char            fnamegob[80]   ;  /* gob file                      */
char            gox[80]        ;  /* gob directory                 */
char            fnamef[80]     ;  /* each file in the MAKE process */
char            where[10]      ;
unsigned char   buf1[BUF_SIZE] ;
FILE            *fgom          ;
int             fgob           ;
int             ff             ;
int             fmix           ;

long            master_index   ;
long            counter        ;
long            len            ;
char            buf[255];

struct GOB_BEGIN gb;
struct GOB_INDEX_ENTRY is;

main()
{
printf("GOBMAKE "GOBMAKE_VERSION" (c) Yves BORCKMANS 1995\n\n");

/* Check number of arguments */
if(_argc != 2)
  {
   printf("Usage is GOBMAKE gomfile\n");
   return(ERR_CMDLINE);
  }

strcpy(fnamegom  , _argv[1]);

/* Check existence of the files */
if(fexists(fnamegom) == FALSE)
  {
   printf("%s doesn't exist! \n",fnamegom);
   return(ERR_WRONGFILE);
  };


/* opens the gom file */
fgom = fopen(fnamegom , "rt");

strcpy(gox, fnamegom);
gox[strlen(fnamegom)-1] = 'X';
strcat(gox, "\\");

/* opens the gob file */
strcpy(fnamegob, fnamegom);
fnamegob[strlen(fnamegom)-1] = 'B';
if(fexists(fnamegob) == FALSE)
 fgob = open(fnamegob , O_BINARY | O_CREAT | O_WRONLY, S_IWRITE);
else
 fgob = open(fnamegob , O_BINARY | O_TRUNC | O_WRONLY, S_IWRITE);

gb.GOB_MAGIC[0] = 'G';
gb.GOB_MAGIC[1] = 'O';
gb.GOB_MAGIC[2] = 'B';
gb.GOB_MAGIC[3] = 0x0A;
gb.MASTERX      = 0;    /* to be updated later */
write(fgob , &gb , sizeof(gb));

/* opens the temporary master index file */
if(fexists("gm_mix.$$$") == FALSE)
 fmix = open("gm_mix.$$$" , O_BINARY | O_CREAT | O_WRONLY, S_IWRITE);
else
 fmix = open("gm_mix.$$$" , O_BINARY | O_TRUNC | O_WRONLY, S_IWRITE);


counter = 0;
while(fgets(buf, 255, fgom) != NULL)
 {
  buf[13] = '\0';
  buf[strlen(buf)-1] = '\0';
  if(strlen(buf) > 0)
   {
    strcpy(fnamef, gox);
    strcat(fnamef, buf);
    if((ff=open(fnamef , O_BINARY | O_RDONLY)) != -1)
     {
      counter++;
      strcpy(is.NAME, buf);
      is.IX  = tell(fgob);
      is.LEN = lseek(ff, 0, SEEK_END);
      write(fmix , &is , sizeof(is));
      len = is.LEN;

      lseek(ff , 0 , SEEK_SET);
      while(len >= BUF_SIZE)
       {
        read(ff,    &buf1 , BUF_SIZE);
        write(fgob, &buf1 , BUF_SIZE);
        len -= BUF_SIZE;
       }
      read(ff,    &buf1 , len);
      write(fgob, &buf1 , len);

      close(ff);
      printf("%-12.12s : IX = 0x%8.8lX  (%8.8ldd)   LEN = 0x%6.6lX  (%6.6ldd)  \n",
        is.NAME, is.IX, is.IX, is.LEN, is.LEN);
     }
    else
     {
      printf("!!! NOT FOUND !!! %s\n", fnamef);
     }
   }
}

fclose(fgom);
close(fmix);

master_index = tell(fgob);
/* write master entries */
write(fgob , &counter , sizeof(counter));

/* reopen the temporary index file, and concatenate it to the gob file */
fmix = open("gm_mix.$$$" , O_BINARY | O_RDONLY);
len = lseek(fmix, 0, SEEK_END);
lseek(fmix , 0 , SEEK_SET);
while(len >= BUF_SIZE)
 {
  read(fmix,  &buf1 , BUF_SIZE);
  write(fgob, &buf1 , BUF_SIZE);
  len -= BUF_SIZE;
 }
read(fmix,  &buf1 , len);
write(fgob, &buf1 , len);

close(fmix);

/* update the master index adress */
set_master_index(fgob, master_index);
close(fgob);

printf("\nMaster Index is at 0x%8.8lX (%8.8ldd). It has %ld entries.\n",
                         master_index, master_index, counter);
system("del gm_mix.$$$ > NUL");
return(ERR_NOERROR);
}
