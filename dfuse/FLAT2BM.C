#define FLAT2BM_VERSION "v 1.0"

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <math.h>
#include <time.h>
#include <errno.h>
#include <fcntl.h>
#include <io.h>
#include <conio.h>
#include <dos.h>
#include <dir.h>
#include <sys\types.h>
#include <sys\stat.h>
#include <alloc.h>

#define TOOLKIT_NO_GRAPHICS
#include "toolkit.c"

#define ERR_NOERROR       00
#define ERR_CMDLINE       10
#define ERR_WRONGFILE     20
#define ERR_NOTBM         30
#define ERR_TOOLONG       40
#define ERR_DYNALLOC      50
#define ERR_GRAPHIC       60

int           i,j,k;
int           bm_counter;

/* ************************************************************************** */
/* BM elements ************************************************************** */
/* ************************************************************************** */

int           f1;
int           f2;
int           fDOOMpal;
int           fDARKpal;
char          fname1[127];
char          fname2[127];
char          fnameDOOMpal[127];
char          fnameDARKpal[127];

unsigned char DARKpalette[768];
unsigned char DOOMpalette[768];
unsigned char CONVtable[256];
long          minsq;
long          minfound;

unsigned char *buffer;
unsigned char *buffer2;

/* ************************************************************************** */
/* MAIN ********************************************************************* */
/* ************************************************************************** */

main()
{
 printf("\n\nFLAT2BM "FLAT2BM_VERSION" (c) Yves BORCKMANS 1995.\n");
 /* Check number of arguments */
 if(_argc != 4)
  {
   printf("Usage is  FLAT2BM doomflat doompalette darkpalette \n");
   printf("          where doomflat is without any extension\n");
   printf("            and the palettes are 768 bytes files.\n");
   return(ERR_CMDLINE);
  }

 strcpy(fname1,       _argv[1]);
 strcpy(fnameDOOMpal, _argv[2]);
 strcpy(fnameDARKpal, _argv[3]);

 /* Check existence of the files */
 if(fexists(fname1) == FALSE)
  {
   printf("%s doesn't exist! \n", fname1);
   return(ERR_WRONGFILE);
  };

 if(fexists(fnameDOOMpal) == FALSE)
  {
   printf("%s doesn't exist! \n", fnameDOOMpal);
   return(ERR_WRONGFILE);
  };

 if(fexists(fnameDARKpal) == FALSE)
  {
   printf("%s doesn't exist! \n", fnameDARKpal);
   return(ERR_WRONGFILE);
  };

 /* allocate far mem buffers : saves a lot of problems */
 if((buffer2 = (unsigned char *) farcalloc(8000,1)) == NULL)
  {
   printf("Cannot allocate 8000 bytes buffer for DOOM FLAT image data. Aborting...\n");
   return(ERR_DYNALLOC);
  };

 if((buffer = (unsigned char *) farcalloc(8000,1)) == NULL)
  {
   printf("Cannot allocate 8000 bytes buffer for BM image data. Aborting...\n");
   return(ERR_DYNALLOC);
  };

 /* initialize buffers */

 memset(DOOMpalette, '\0', 768);
 memset(DARKpalette, '\0', 768);
 memset(CONVtable,   '\0', 256);
 memset(buffer, '\0', 8000);
 memset(buffer2, '\0', 8000);

 /* read the palettes */

 fDOOMpal = open(fnameDOOMpal , O_BINARY | O_RDONLY);
  read(fDOOMpal, DOOMpalette, 4096);
 close(fDOOMpal);

 fDARKpal = open(fnameDARKpal , O_BINARY | O_RDONLY);
  read(fDARKpal, DARKpalette, 4096);
 close(fDARKpal);

 /* create conversion table from doom palette to dark forces palette */

 for(i=0; i<256; i++)
  {
   minfound   = 99999;
   for(j=0; j<256; j++)
    {
     minsq =
      (
       ((long)(DOOMpalette[3*i]  /4-DARKpalette[3*j]  )*(DOOMpalette[3*i]  /4-DARKpalette[3*j]  ))
      +((long)(DOOMpalette[3*i+1]/4-DARKpalette[3*j+1])*(DOOMpalette[3*i+1]/4-DARKpalette[3*j+1]))
      +((long)(DOOMpalette[3*i+2]/4-DARKpalette[3*j+2])*(DOOMpalette[3*i+2]/4-DARKpalette[3*j+2]))
      );
     if(minsq < minfound)
      {
       minfound     = minsq;
       CONVtable[i] = (unsigned char)j;
      }
    }
  }

 /* read the flat */

 f1 = open(fname1 , O_BINARY | O_RDONLY);
  read(f1, buffer2, 4096);
 close(f1);

 /* 1st compose the header of 32 bytes */

 buffer[ 0] = 0x42;
 buffer[ 1] = 0x4D;
 buffer[ 2] = 0x20;
 buffer[ 3] = 0x1E;
 buffer[ 4] = 0x40;
 buffer[ 6] = 0x40;
 buffer[ 8] = 0x40;
 buffer[10] = 0x40;
 buffer[12] = 0x36;
 buffer[13] = 0x06;
 buffer[17] = 0x10;

 /* flip the flat converting the palette in the process */

 for(i=0;i<64;i++)
  for(j=0;j<64;j++)
   buffer[64-i+64*j + 32] = CONVtable[buffer2[j+64*i]];


 strcpy(fname2, fname1);
 strcat(fname2, ".bm");

 printf("Writing %s \n", fname2);
 if(fexists(fname2) == FALSE)
  f2 = open(fname2 , O_BINARY | O_CREAT | O_WRONLY, S_IWRITE);
 else
  f2 = open(fname2 , O_BINARY | O_TRUNC | O_WRONLY, S_IWRITE);
 write(f2, buffer, 4128);
 close(f2);

 return(0);
}
