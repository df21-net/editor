#define BMP2BM_VERSION "v 1.00"
#define DFUSE_INI      "DFUSE.INI"

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
#define ERR_INIFILE       70

int           i,j,k;
long          col_start;
long          col_end;
long          bmp_counter;
int           bmp_align;
char          str[80];
int           ccc;
int           nbbm;
char          nbbms[3];

int           mod_r, mod_g, mod_b;

unsigned char palette[768];
unsigned char DARKpalette[768];
unsigned char CONVtable[256];
long          minsq;
long          minfound;


/* ************************************************************************** */
/* BM elements ************************************************************** */
/* ************************************************************************** */

int           f1;
int           fp;
char          fname1[127];
char          fnamep[127];

unsigned char huge *buffer;

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
} BMH;



/* ************************************************************************** */
/* BMP elements ************************************************************* */
/* ************************************************************************** */

/* Extract from BC++ 4.0 windows.h */
typedef struct tagBITMAPINFOHEADER
{
    DWORD   biSize;
    LONG    biWidth;
    LONG    biHeight;
    WORD    biPlanes;
    WORD    biBitCount;
    DWORD   biCompression;
    DWORD   biSizeImage;
    LONG    biXPelsPerMeter;
    LONG    biYPelsPerMeter;
    DWORD   biClrUsed;
    DWORD   biClrImportant;
} BITMAPINFOHEADER;

/* constants for the biCompression field */
#define BI_RGB      0L
#define BI_RLE8     1L
#define BI_RLE4     2L

typedef struct tagBITMAPFILEHEADER
{
    UINT    bfType;
    DWORD   bfSize;
    UINT    bfReserved1;
    UINT    bfReserved2;
    DWORD   bfOffBits;
} BITMAPFILEHEADER;

int               f2;
char              fname2[127];

BITMAPFILEHEADER  BMP_FH;
BITMAPINFOHEADER  BMP_IH;
unsigned char     COLtable[1024];
unsigned char huge *buffer2;

/* ************************************************************************** */
/* MAIN ********************************************************************* */
/* ************************************************************************** */

main()
{
 printf("\n\nBMP2BM "BMP2BM_VERSION" (c) Yves BORCKMANS 1995.\n");
 /* Check number of arguments */
 if(_argc != 4)
  {
   printf("Usage is  BM2BMP bmpfile.BMP palfile.PAL bmfile.BM\n");
   return(ERR_CMDLINE);
  }

 if(fexists(DFUSE_INI))
  {
   mod_r = ReadIniInt("BM2BMP-RGB", "R", 1, DFUSE_INI);
   mod_g = ReadIniInt("BM2BMP-RGB", "G", 1, DFUSE_INI);
   mod_b = ReadIniInt("BM2BMP-RGB", "B", 1, DFUSE_INI);
  }
 else
  {
   printf("BMP2BM can't find "DFUSE_INI"\n");
   printf("Please restore and reconfigure it.\n\n");
   exit(ERR_INIFILE);
  }

 strcpy(fname1, _argv[1]);
 strcpy(fnamep, _argv[2]);
 strcpy(fname2, _argv[3]);

 /* Check existence of the files */
 if(fexists(fname1) == FALSE)
  {
   printf("%s doesn't exist! \n", fname1);
   printf("Press Any Key To Continue.\n");
   getVK();
   return(ERR_WRONGFILE);
  };

 if(fexists(fnamep) == FALSE)
  {
   printf("%s doesn't exist! \n", fnamep);
   printf("Press Any Key To Continue.\n");
   getVK();
   return(ERR_WRONGFILE);
  };

 /* allocate huge far mem buffers : saves a lot of problems */
 if((buffer = (unsigned char huge *) farcalloc(150000,1)) == NULL)
  {
   printf("Cannot allocate 140000 bytes buffer for BMP image data. Aborting...\n");
   printf("Press Any Key To Continue.\n");
   getVK();
   return(ERR_DYNALLOC);
  };

 if((buffer2 = (unsigned char huge *) farcalloc(140000,1)) == NULL)
  {
   printf("Cannot allocate 140000 bytes buffer for BM image data. Aborting...\n");
   printf("Press Any Key To Continue.\n");
   getVK();
   return(ERR_DYNALLOC);
  };


 memset(buffer,            '\0', 60000);
 memset(&(buffer[60000] ), '\0', 60000);
 memset(&(buffer[120000]), '\0', 30000);

 f1 = open(fname1 , O_BINARY | O_RDONLY);
 read(f1, &BMP_FH,     14);
 read(f1, &BMP_IH,     40);
 read(f1, &COLtable, 1024);

 read(f1, buffer, 60000);
 read(f1, &(buffer[60000] ), 60000);
 read(f1, &(buffer[120000]), 20000);
 close(f1);

 /* read the palette */
 fp=open(fnamep , O_BINARY | O_RDONLY);
 read(fp, &DARKpalette, 768);
 close(fp);

 /* translate the 'BGR'QUADs from the bmp to real RGB (triples) */
 for(i=0; i<256; i++)
  {
   palette[3*i]   = COLtable[4*i+2];
   palette[3*i+1] = COLtable[4*i+1];
   palette[3*i+2] = COLtable[4*i  ];
  };

/* bring back bmp palette (0..255) to vga (0..63) */
 for(i=0; i<768; i++) palette[i] = (unsigned char)(palette[i] / 4);

#ifdef DEBUG
 for(i=0; i<256; i++)
  {
   printf("%3d : %3d %3d %3d   %3d %3d %3d\n",
           i,
                palette[3*i],
                palette[3*i+1],
                palette[3*i+2],
                DARKpalette[3*i],
                DARKpalette[3*i+1],
                DARKpalette[3*i+2]
                );
  }
#endif

 /* create conversion table from palette to a dark forces palette */
 /* minimize the squares of the differences between the RGB's     */

 for(i=0; i<256; i++)
  {
   minfound   = 999999999;
   for(j=0; j<256; j++)
    {
     minsq =
      (long)(
        mod_r * (long)(
         (long)(palette[3*i]  -DARKpalette[3*j]  )
        *(long)(palette[3*i]  -DARKpalette[3*j]  )
        )
      + mod_g * (long)(
         (long)(palette[3*i+1]-DARKpalette[3*j+1])
        *(long)(palette[3*i+1]-DARKpalette[3*j+1])
        )
      + mod_b * (long)(
         (long)(palette[3*i+2]-DARKpalette[3*j+2])
        *(long)(palette[3*i+2]-DARKpalette[3*j+2])
        )
     );
     if(i==j)
      {
       /* so if color i has multiple possible minseqs, it will take the
          one with the same index if possible. This will solve the
          0 20 0  <=> 20 0 0 problem when palettes are the same
       */
       if(minsq <= minfound)
        {
         minfound     = minsq;
         CONVtable[i] = (unsigned char)j;
        }
      }
     else
      {
       if(minsq < minfound)
        {
         minfound     = minsq;
         CONVtable[i] = (unsigned char)j;
        }
      }
    }
  }

#ifdef DEBUG
 for(i=0; i<256; i++) printf("COL# %3d => %3d\n", i, CONVtable[i]);
#endif

 /* compose the BM header */
 memset(&BMH, '\0', 32);
 BMH.MAGIC[0]   = 'B';
 BMH.MAGIC[1]   = 'M';
 BMH.MAGIC[2]   = ' ';
 BMH.MAGIC[3]   = 0x1E;
 BMH.SizeX      = (int)BMP_IH.biWidth ;
 BMH.SizeY      = (int)BMP_IH.biHeight;
 BMH.idemX      = (int)BMP_IH.biWidth ;
 BMH.idemY      = (int)BMP_IH.biHeight;

 switch(BMH.SizeY)
  {
   case    2 : BMH.unknown1 = 0x36 + 256 * 1;
               break;
   case    4 : BMH.unknown1 = 0x36 + 256 * 2;
               break;
   case    8 : BMH.unknown1 = 0x36 + 256 * 3;
               break;
   case   16 : BMH.unknown1 = 0x36 + 256 * 4;
               break;
   case   32 : BMH.unknown1 = 0x36 + 256 * 5;
               break;
   case   64 : BMH.unknown1 = 0x36 + 256 * 6;
               break;
   case  128 : BMH.unknown1 = 0x36 + 256 * 7;
               break;
   case  256 : BMH.unknown1 = 0x36 + 256 * 8;
               break;
   case  512 : BMH.unknown1 = 0x36 + 256 * 9;
               break;
   case 1024 : BMH.unknown1 = 0x36 + 256 * 10;
               break;
   default: BMH.unknown1   = 0;
  }
 BMH.Compressed = 0;
 BMH.DataSize   = (long)BMH.SizeX * BMH.SizeY;
 bmp_counter   = BMP_IH.biSizeImage;

 if(fexists(fname2) == FALSE)
  f2 = open(fname2 , O_BINARY | O_CREAT | O_WRONLY, S_IWRITE);
 else
  f2 = open(fname2 , O_BINARY | O_TRUNC | O_WRONLY, S_IWRITE);

 write(f2, &BMH, 32);

 memset(buffer2           , '\0', 60000);
 memset(&(buffer2[60000] ), '\0', 60000);
 memset(&(buffer2[120000]), '\0', 20000);

 bmp_align = 4 - BMH.SizeX % 4;
 if(bmp_align == 4) bmp_align = 0;

 for(j=0;j<BMH.SizeY;j++)
  {
   for(i=0;i<BMH.SizeX; i++)
    {
     /* buffer2[(long)i+j*BMH.SizeX] = CONVtable[buffer[(long)i*BMH.SizeY+j]]; */
     buffer2[(long)i*BMH.SizeY+j] = CONVtable[buffer[(long)j*(BMH.SizeX)+i]];
    };
  }

 if(BMH.DataSize > 120000)
  {
   write(f2, buffer2,             60000);
   write(f2, &(buffer2[60000]),   60000);
   write(f2, &(buffer2[120000]),  (unsigned)(BMH.DataSize-120000));
  }
 else
  if(BMH.DataSize > 60000)
   {
    write(f2, buffer2,             60000);
    write(f2, &(buffer2[60000]),   (unsigned)(BMH.DataSize-60000));
   }
  else
    write(f2, buffer2, (unsigned)BMH.DataSize);

 close(f2);

 farfree(buffer);
 farfree(buffer2);
 return(0);
}
