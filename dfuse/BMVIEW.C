#define BMVIEW_VERSION "v 3.04"
#define DFUSE_INI      "DFUSE.INI"

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <fcntl.h>
#include <io.h>
#include <conio.h>
#include <dos.h>
#include <dir.h>
#include <sys\types.h>
#include <sys\stat.h>
#include <alloc.h>

#include <graphics.h>
#include "toolkit.c"

#define ERR_NOERROR       00
#define ERR_INIFILE       10
#define ERR_CMDLINE       20
#define ERR_WRONGFILE     30
#define ERR_NOTBM         40
#define ERR_TOOLONG       50
#define ERR_DYNALLOC      60
#define ERR_GRAPHIC       70

void handle_ini(void);

char          BGIdriver[10];
char          PALfile[101];
int           BGImode;
int           gdriver;
int           gmode;
int           errorcode = grNoInitGraph;
int           centerX, centerY;
int           i,j,k,n,m, rle;
int           flipflop = 0;
long          col_start;
long          col_end;
char          DACbuffer[768];
unsigned char huge *buffer;
int           f1;
char          fname1[127];
char          str[80];
int           ccc;
int           nbbm;
char          bmt[100];
int           mlen;

struct BM_header
{
 char  MAGIC[4];
 int   SizeX;
 int   SizeY;
 int   idemX;
 int   idemY;
 int   unknown1;
 int   Compressed;
 long  DataSize;
 char  fil[12];
}             BMH;


void handle_ini()
{
 if(fexists(DFUSE_INI))
  {
   ReadIniString("BMVIEW-BGI", ".BGI", "", BGIdriver, 10, DFUSE_INI);
   BGImode = ReadIniInt("BMVIEW-BGI", "MODE", 30000, DFUSE_INI);

   /* [DEFAULT-BGI] handling */
   if((strcmp(BGIdriver,"")==0) || (BGImode == 30000))
    {
     ReadIniString("DEFAULT-BGI", ".BGI", "", BGIdriver, 10, DFUSE_INI);
     BGImode = ReadIniInt("DEFAULT-BGI", "MODE", 30000, DFUSE_INI);
     if((strcmp(BGIdriver,""))==0 || (BGImode == 30000))
      {
       printf("BMVIEW can't find coherent values for .BGI and MODE !\n");
       printf("Please reconfigure the [DEFAULT-BGI] or [BMVIEW-BGI] sections of DFUSE.INI .\n\n");
       exit(ERR_GRAPHIC);
      }
    }

   if(_argc != 3)
    {
     ReadIniString("BMVIEW-PAL", ".PAL",  "",  PALfile, 100, DFUSE_INI);
     if(strcmp(PALfile,"")==0)
      {
       ReadIniString("DEFAULT-PAL", ".PAL",  "",  PALfile, 100, DFUSE_INI);
       if(strcmp(PALfile,"")==0)
        {
         printf("BMVIEW can't find coherent values for .PAL !\n");
         printf("Please reconfigure the [DEFAULT-PAL] or [BMVIEW-PAL] sections of DFUSE.INI .\n\n");
         exit(ERR_GRAPHIC);
        }
      }
     strcat(PALfile, ".pal");
    }
  }
 else
  {
   printf("BMVIEW can't find "DFUSE_INI"\n");
   printf("Please restore and reconfigure it.\n\n");
   exit(ERR_INIFILE);
  }
}

/* ************************************************************************** */
/* MAIN ********************************************************************* */
/* ************************************************************************** */

main()
{
 union  REGS   regs;
 struct SREGS  sregs;

 printf("\n\nBMVIEW "BMVIEW_VERSION" (c) Yves BORCKMANS 1995.\n\n");
 /* Check number of arguments */
 if((_argc != 2) && (_argc != 3))
  {
   printf("Usage is  BMVIEW bmfile [palfile]\n");
   printf("See DFUSE.INI for more settings.\n");
   return(ERR_CMDLINE);
  }

 strcpy(fname1, _argv[1]);

 /* Check existence of the file */
 if(fexists(_argv[1]) == FALSE)
  {
   printf("%s doesn't exist! \n", fname1);
   printf("Press Any Key To Continue.\n");
   getVK();
   return(ERR_WRONGFILE);
  };

 if(_argc == 3) strcpy(PALfile, _argv[2]);

 handle_ini();

 /* ALL SYSTEMS GO ! */

 /* allocate far mem buffer : saves a lot of problems */
 if((buffer = (unsigned char huge *) farcalloc(140000,1)) == NULL)
  {
   printf("Cannot allocate 140000 bytes buffer for image data. Aborting...\n");
   printf("Press Any Key To Continue.\n");
   getVK();
   return(ERR_DYNALLOC);
  };


 /* redefine the palette */
 strcpy(fname1, PALfile);
 if((f1=open(fname1 , O_BINARY | O_RDONLY)) == -1)
  {
   printf("%s doesn't exist! \n",fname1);
   printf("Press Any Key To Continue.\n");
   getVK();
   return(ERR_WRONGFILE);
  }

 /* init graphics system */
 gdriver = installuserdriver(BGIdriver, NULL);
 gmode   = BGImode;
 initgraph(&gdriver, &gmode, NULL);
 errorcode = graphresult();
 if (errorcode != grOk)
   {
    printf("\n\n\n\nGraphic Error : %d\n", errorcode);
    printf("Press Any Key To Continue.\n");
    getVK();
    return(ERR_GRAPHIC);
   }
 cleardevice();

 /* redefine the palette (split because error is to be reported in text mode) */
 read(f1, &DACbuffer, 768);
 close(f1);

 /* this is a speed demon compared to setallpalette ! */
 regs.x.ax = 0x1012;
 regs.x.bx = 0;
 regs.x.cx = 256;
 sregs.es  = FP_SEG(DACbuffer);
 regs.x.dx = FP_OFF(DACbuffer);
 int86x( 0x10, &regs, &regs, &sregs );

 memset(buffer,           '\0', 40000);
 memset(&(buffer[40000]), '\0', 40000);
 memset(&(buffer[80000]), '\0', 40000);
 memset(&(buffer[120000]), '\0', 20000);

 strcpy(fname1, _argv[1]);
 f1 = open(fname1 , O_BINARY | O_RDONLY);
 /* 1st read the header of 32 bytes */
 read(f1, &BMH, 32);

 if(!BMH.Compressed)
  /* BM coded directly */
  if((BMH.SizeX != 1) || ( (BMH.SizeX == 1) && (BMH.SizeY == 1) ) )
  /* simple : one bitmap */
  {
   /* 140000 bytes of data even past EOF (who cares ?) */
   read(f1, buffer, 40000);
   read(f1, &(buffer[40000]), 40000);
   read(f1, &(buffer[80000]), 40000);
   read(f1, &(buffer[120000]), 20000);
   close(f1);
   centerX = (getmaxx()-BMH.SizeX)/2;
   centerY = (getmaxy()+BMH.SizeY)/2;
   for(i=0;i<BMH.SizeX;i++)
    for(j=0;j<BMH.SizeY;j++)
     putpixel(centerX+i, centerY-j, buffer[(long)i*BMH.SizeY+j]);
   setcolor(255);
   rectangle( (getmaxx()-BMH.SizeX)/2 -1,
              (getmaxy()-BMH.SizeY)/2 -1,
              (getmaxx()+BMH.SizeX)/2 +1,
              (getmaxy()+BMH.SizeY)/2 +1  );
   strcpy(bmt,"Simple");
  }
  else
  /* multiple bitmaps eg. switches and animated textures */
  {
   nbbm = BMH.idemY;
   read(f1, buffer, 1);   /* 0 for a dual BM, more for an animated BM */
   if(buffer[0] == 0x00)
   {
    strcpy(bmt,"Multiple");
    read(f1, buffer, 1+2*4);
   }
   else
   {
    strcpy(bmt,"Animated");
    read(f1, buffer, 1+nbbm*4);
   }

   for(k=1;k<=nbbm;k++)
    {
     read(f1, &(BMH.SizeX), 28);
     read(f1, buffer, BMH.SizeX*BMH.SizeY);
     centerX = (getmaxx()-BMH.SizeX)/2;
     centerY = (getmaxy()+BMH.SizeY)/2;
     centerX = centerX + (k-nbbm/2-1) * (BMH.SizeX +10);
     for(i=0;i<BMH.SizeX;i++)
      for(j=0;j<BMH.SizeY;j++)
       putpixel(centerX+i, centerY-j, buffer[(long)i*BMH.SizeY+j]);
     setcolor(255);
     rectangle( (getmaxx()-BMH.SizeX)/2 -1+ (k-nbbm/2-1) * (BMH.SizeX +10),
                (getmaxy()-BMH.SizeY)/2 -1,
                (getmaxx()+BMH.SizeX)/2 +1+ (k-nbbm/2-1) * (BMH.SizeX +10),
                (getmaxy()+BMH.SizeY)/2 +1  );
    };
   close(f1);
   }
 else
  /* BM Compressed == 1 RLE encoding (used only in demo ???) */
  {
   if(BMH.Compressed == 1)
    {
     read(f1, buffer, 40000);
     read(f1, &(buffer[40000]), 40000);
     close(f1);
     for(i=0;i<BMH.SizeX;i++)
      {
       col_start = *(long *)&(buffer[BMH.DataSize+i*4]);
       col_end   = i < BMH.SizeX-1 ? *(long *)&(buffer[BMH.DataSize+(i+1)*4]) : BMH.DataSize;
       if(buffer[col_start] < 128)
        flipflop = 1;
       else
        flipflop = 0;
       j         = 0;
       k         = 0;
       while(col_start+j < col_end)
        {
         if(flipflop == 0)
          {
           /* rle coding */
           if(buffer[col_start+j] != 255) flipflop = 1;
           rle = buffer[col_start+j] - 128;
           j++;
           for(m=0; m<rle; m++)
            {
             putpixel(i,199-k,buffer[col_start+j]);
             k++;
            }
           j++;
          }
         else
          {
           /* direct byte coding of n values */
           n = buffer[col_start+j];
           j++;
           for(m=0; m<n; m++)
            {
             putpixel(i,199-k,buffer[col_start+j]);
             k++;
             j++;
            }
           flipflop = 0;
          }
        }; /* while */
      } /* for */
     strcpy(bmt,"RLE 1");
    }
   else
    {
     read(f1, buffer, 40000);
     read(f1, &(buffer[40000]), 40000);
     close(f1);
     for(i=0;i<BMH.SizeX;i++)
      {
       col_start = *(long *)&(buffer[BMH.DataSize+i*4]);
       col_end   = i < BMH.SizeX-1 ? *(long *)&(buffer[BMH.DataSize+(i+1)*4]) : BMH.DataSize;
       if(buffer[col_start] < 128)
        flipflop = 1;
       else
        flipflop = 0;
       j         = 0;
       k         = 0;
       while(col_start+j < col_end)
        {
         if(flipflop == 0)
          {
           /* rle coding */
           rle = buffer[col_start+j] - 128;
           if(buffer[col_start+j] != 255) flipflop = 1;
           j++;
           for(m=0; m<rle; m++)
            {
             putpixel(i,199-k,buffer[col_start+j]);
             k++;
            }
           j++;
          }
         else
          {
           /* direct byte coding of n values */
           n = buffer[col_start+j];
           j++;
           for(m=0; m<n; m++)
            {
             putpixel(i,199-k,buffer[col_start+j]);
             k++;
             j++;
            }
           flipflop = 0;
          }
        }; /* while */
      } /* for */
     strcpy(bmt,"RLE 2 Not Implemented Yet!");
    };
  }; /* BM type */

 ccc = getVK();
 if(ccc != VK_ESC)
  {
   sprintf(str , "%s" , fname1);
   outtextxy(4,4, str);
   sprintf(str , "W = %d  H = %d  T = %s", BMH.SizeX, BMH.SizeY, bmt);
   outtextxy(4,13, str);
   getVK();
  }
 closegraph();
 restorecrtmode();
 return(0);
}
