#define DARKHACK_VERSION "v 1.0"

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

#define  TOOLKIT_NO_GRAPHICS
#include "toolkit.c"

#define ERR_NOERROR       00
#define ERR_CMDLINE       10
#define ERR_WRONGFILE     20
#define ERR_CANTOPEN      30

void fpokeb(long address, unsigned char value);
void fpokel(long address, long value);

int              i,j;
long             adr;

char             fname1[80];
int              f1;
unsigned char    buf[80];


void fpokeb(long address, unsigned char value)
{
  lseek(f1, adr+address, SEEK_SET);
  write(f1, &value, 1);
}

void fpokel(long address, long value)
{
  lseek(f1, adr+address, SEEK_SET);
  write(f1, &value, 4);
}


/* ************************************************************************** */
/* MAIN MAIN MAIN MAIN MAIN MAIN MAIN MAIN MAIN MAIN MAIN MAIN MAIN MAIN MAIN */
/* ************************************************************************** */
/* MAIN MAIN MAIN MAIN MAIN MAIN MAIN MAIN MAIN MAIN MAIN MAIN MAIN MAIN MAIN */
/* ************************************************************************** */
/* MAIN MAIN MAIN MAIN MAIN MAIN MAIN MAIN MAIN MAIN MAIN MAIN MAIN MAIN MAIN */
/* ************************************************************************** */

main()
{
 /* Check number of arguments */
 if(_argc != 2)
  {
   printf("\n\nDARKHACK "DARKHACK_VERSION" (c) Yves BORCKMANS 1995.");
   printf("\n\nUsage is DARKHACK darkpilo.cfg\n");
   return(ERR_CMDLINE);
  }

 strcpy(fname1  , _argv[1]);

 /* Check existence of the first file */
 if(fexists(fname1) == FALSE)
   {
    printf("%s doesn't exist! \n",fname1);
    return(ERR_WRONGFILE);
   };

 if((f1 = open(fname1 , O_BINARY | O_RDWR)) == -1)
  {
   printf("DARKHACK can't open %s\n", fname1);
   return(ERR_CANTOPEN);
  }

  adr = 0;                    /* for choosing which pilot later */

  fpokeb(37,14);              /* levels */
  fpokeb(41,14);

  for(i=0;i<14;i++)           
   {
    fpokeb(46+i, 0);          /* levels not yet done */

    fpokeb(60+i*32, 255);     /* pistol (not necessary)  */
    fpokeb(61+i*32, 255);     /* rifle                   */
    fpokeb(62+i*32, 255);     /* thermal (not necessary) */
    fpokeb(63+i*32, 255);     /* repeating               */
    fpokeb(64+i*32, 255);     /* mortar                  */
    fpokeb(65+i*32, 255);     /* fusion cutter           */
    fpokeb(66+i*32, 255);     /* mines (not necessary)   */
    fpokeb(67+i*32, 255);     /* concussion              */
    fpokeb(68+i*32, 255);     /* assault cannon          */

    fpokeb(72+i*32, 255);     /* IR Goggles              */
    fpokeb(73+i*32, 255);     /* Ice Cleats              */
    fpokeb(74+i*32, 255);     /* Gas Mask                */

    fpokeb(91+i*32, 9);       /* Lives                   */

    fpokel(508+i*40, 500);    /* Energy                  */
    fpokel(512+i*40, 500);    /* Power cells             */
    fpokel(516+i*40, 400);    /* PL                      */
    fpokel(520+i*40, 50 );    /* detonators              */
    fpokel(524+i*40, 50 );    /* mortar shells           */
    fpokel(528+i*40, 30 );    /* mines                   */
    fpokel(532+i*40, 20 );    /* missiles                */
    fpokel(536+i*40, 200);    /* shields                 */
   }


  close(f1);
  printf("DARKHACK finished!\n");
  return(ERR_NOERROR);
}

