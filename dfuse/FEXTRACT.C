#define FEXTRACT_VERSION "v 1.07"

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

#define  TOOLKIT_NO_GRAPHICS
#include "toolkit.c"

#define BUF_SIZE       50000

#define ERR_NOERROR       00
#define ERR_CMDLINE       10
#define ERR_WRONGFILE     20
#define ERR_NOTPWAD       30
#define ERR_TOOLONG       40

char            fname1[80]     ;
char            fname2[80]     ;
unsigned char   buf1[BUF_SIZE] ;
int             f1             ;
int             f2             ;

long            i;
long            start;
long            len;
long            lof;


main()
{
printf("\n\nFEXTRACT "FEXTRACT_VERSION" (c) Yves BORCKMANS 1994.\n\n");
/* Check number of arguments */
if(_argc != 5)
  {
   printf("Usage is FEXTRACT -S:start [-E:end | -L:len] filein fileout\n");
   printf("  where start and end/len are decimal values starting at 0.\n");
   return(ERR_CMDLINE);
  }

strcpy(fname1  , _argv[3]);
strcpy(fname2  , _argv[4]);

/* Check existence of the first file */
if(fexists(fname1) == FALSE)
  {
   printf("%s doesn't exist! \n",fname1);
   return(ERR_WRONGFILE);
  };

f1 = open(fname1 , O_BINARY | O_RDONLY);

if(fexists(fname2) == FALSE)
  f2 = open(fname2 , O_BINARY | O_CREAT | O_WRONLY, S_IWRITE);
else
  f2 = open(fname2 , O_BINARY | O_TRUNC | O_WRONLY, S_IWRITE);

start = atol(&(_argv[1][3]));
if(_argv[2][1] == 'L')
 {
  len = atol(&(_argv[2][3]));
 }
else
 {
  len = atol(&(_argv[2][3])) - start + 1;
 }

lof = lseek(f1,0,SEEK_END);

if(start > lof)
 {
  printf("start is > length of file. Aborted!\n");
  return(ERR_TOOLONG);
 }

if(start+len > lof) len = lof - start + 1;

 printf("start = %-8.8ld , len = %-8.8ld" , start, len);

lseek(f1 , start , SEEK_SET);

while(len >= BUF_SIZE)
{
 read(f1  , &buf1 , BUF_SIZE);
 write(f2 , &buf1 , BUF_SIZE);
 len -= BUF_SIZE;
}
 read(f1  , &buf1 , len);
 write(f2 , &buf1 , len);

close(f2);
close(f1);
return(ERR_NOERROR);
}
