#define BM2BMP_VERSION "v 2.50"

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
long          col_start;
long          col_end;
long          bmp_counter;
int           bmp_align;
char          str[80];
int           ccc;
int           nbbm;
char          nbbms[3];

/* ************************************************************************** */
/* BM elements ************************************************************** */
/* ************************************************************************** */

int           f1;
int           fp;
char          fname1[80];
char          fnamep[80];

char          DACbuffer[768];
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
}             BMH;

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
char              fname2[80];

BITMAPFILEHEADER  BMP_FH;
BITMAPINFOHEADER  BMP_IH;
unsigned char     COLtable[1024];
unsigned char huge *buffer2;

/* ************************************************************************** */
/* MAIN ********************************************************************* */
/* ************************************************************************** */

main()
{
 printf("\n\nBM2BMP "BM2BMP_VERSION" (c) Yves BORCKMANS 1995.\n");
 /* Check number of arguments */
 if(_argc != 4)
  {
   printf("Usage is  BM2BMP bmfile.BM palfile.PAL bmpfile.BMP\n");
   return(ERR_CMDLINE);
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
 if((buffer = (unsigned char huge *) farcalloc(140000,1)) == NULL)
  {
   printf("Cannot allocate 140000 bytes buffer for BM image data. Aborting...\n");
   printf("Press Any Key To Continue.\n");
   getVK();
   return(ERR_DYNALLOC);
  };

 if((buffer2 = (unsigned char huge *) farcalloc(140000,1)) == NULL)
  {
   printf("Cannot allocate 140000 bytes buffer for BMP image data. Aborting...\n");
   printf("Press Any Key To Continue.\n");
   getVK();
   return(ERR_DYNALLOC);
  };

 /* read the palette */
 fp=open(fnamep , O_BINARY | O_RDONLY);
 read(fp, &DACbuffer, 768);
 close(fp);

 /* makes the RGBQUADs */
 memset(COLtable, '\0', 1024);
 for(i=0; i<256; i++)
  {
   COLtable[4*i+2] = 4 * DACbuffer[3*i];
   COLtable[4*i+1] = 4 * DACbuffer[3*i+1];
   COLtable[4*i  ] = 4 * DACbuffer[3*i+2];
  };

 memset(buffer,           '\0', 60000);
 memset(&(buffer[60000] ), '\0', 60000);
 memset(&(buffer[120000]), '\0', 20000);

 f1 = open(fname1 , O_BINARY | O_RDONLY);
 /* 1st read the header of 32 bytes */
 read(f1, &BMH, 32);

 if(!BMH.Compressed)
  /* BM coded directly */
  if(BMH.SizeX != 1)
  /* simple */
   {
    printf("BM is UNCOMPRESSED SIMPLE\n");
    read(f1, buffer, 60000);
    read(f1, &(buffer[60000] ), 60000);
    read(f1, &(buffer[120000]), 20000);
    close(f1);

    bmp_counter = 0;
    /* !! BMPS lines must be aligned on 4 bytes boundaries !! */
    bmp_align = 4 - BMH.SizeX % 4;
    if(bmp_align == 4) bmp_align = 0;

#ifdef DEBUG
    printf("X : %d\n",BMH.SizeX);
    printf("Y : %d\n",BMH.SizeY);
    printf("a : %d\n", bmp_align);
#endif

    for(j=0;j<BMH.SizeY;j++)
     {
      for(i=0;i<BMH.SizeX;i++)
       {
        buffer2[bmp_counter] = buffer[(long)i*BMH.SizeY+j];
        bmp_counter++;
       };
      for(i = 1; i <= bmp_align; i++)
       {
        buffer2[bmp_counter] = 0;
        bmp_counter++;
       }
     }

    BMP_FH.bfType           = 19778;
    BMP_FH.bfSize           = sizeof(BMP_FH) + sizeof(BMP_IH) + 1024 + bmp_counter;
    BMP_FH.bfReserved1      = 0;
    BMP_FH.bfReserved2      = 0;
    BMP_FH.bfOffBits        = sizeof(BMP_FH) + sizeof(BMP_IH) + 1024;

    BMP_IH.biSize           = 40;
    BMP_IH.biWidth          = BMH.SizeX;
    BMP_IH.biHeight         = BMH.SizeY;
    BMP_IH.biPlanes         = 1;
    BMP_IH.biBitCount       = 8;
    BMP_IH.biCompression    = BI_RGB;
    BMP_IH.biSizeImage      = bmp_counter;
    BMP_IH.biXPelsPerMeter  = 0;
    BMP_IH.biYPelsPerMeter  = 0;
    BMP_IH.biClrUsed        = 256;
    BMP_IH.biClrImportant   = 256;

    printf("Writing %s \n", fname2);
    if(fexists(fname2) == FALSE)
     f2 = open(fname2 , O_BINARY | O_CREAT | O_WRONLY, S_IWRITE);
    else
     f2 = open(fname2 , O_BINARY | O_TRUNC | O_WRONLY, S_IWRITE);
    write(f2, &BMP_FH,     14);
    write(f2, &BMP_IH,     40);
    write(f2, &COLtable, 1024);

    if(bmp_counter > 120000)
     {
      write(f2, buffer2,             60000);
      write(f2, &(buffer2[60000]),   60000);
      write(f2, &(buffer2[120000]),  (unsigned)(bmp_counter-120000));
     }
    else
     if(bmp_counter > 60000)
      {
       write(f2, buffer2,             60000);
       write(f2, &(buffer2[60000]),   (unsigned)(bmp_counter-60000));
      }
     else
       write(f2, buffer2, (unsigned)bmp_counter);
    close(f2);
   }
  else
   /* multiple */
   {
    printf("BM is UNCOMPRESSED MULTIPLE\n");
    nbbm = BMH.idemY;
    read(f1, buffer, 10);
    for(k=1;k<=nbbm;k++)
     {
      read(f1, &(BMH.SizeX), 28);
      read(f1, buffer, BMH.SizeX*BMH.SizeY);
      bmp_counter = 0;
      /* !! BMPS lines must be aligned on 4 bytes boundaries !! */
      bmp_align = 4 - BMH.SizeX % 4;
      if(bmp_align == 4) bmp_align = 0;

      for(j=0;j<BMH.SizeY;j++)
       {
        for(i=0;i<BMH.SizeX;i++)
         {
          buffer2[bmp_counter] = buffer[(long)i*BMH.SizeY+j];
          bmp_counter++;
         };
        for(i = 1; i <= bmp_align; i++)
         {
          buffer2[bmp_counter] = 0;
          bmp_counter++;
         }
       }
      BMP_FH.bfType           = 19778;
      BMP_FH.bfSize           = sizeof(BMP_FH) + sizeof(BMP_IH) + 1024 + bmp_counter;
      BMP_FH.bfReserved1      = 0;
      BMP_FH.bfReserved2      = 0;
      BMP_FH.bfOffBits        = sizeof(BMP_FH) + sizeof(BMP_IH) + 1024;

      BMP_IH.biSize           = 40;
      BMP_IH.biWidth          = BMH.SizeX;
      BMP_IH.biHeight         = BMH.SizeY;
      BMP_IH.biPlanes         = 1;
      BMP_IH.biBitCount       = 8;
      BMP_IH.biCompression    = BI_RGB;
      BMP_IH.biSizeImage      = bmp_counter;
      BMP_IH.biXPelsPerMeter  = 0;
      BMP_IH.biYPelsPerMeter  = 0;
      BMP_IH.biClrUsed        = 256;
      BMP_IH.biClrImportant   = 256;

      sprintf(nbbms, "%2.2d", k);
      fname2[strlen(fname2)-2] = nbbms[0];
      fname2[strlen(fname2)-1] = nbbms[1];
      printf("Writing %s \n", fname2);

      if(fexists(fname2) == FALSE)
       f2 = open(fname2 , O_BINARY | O_CREAT | O_WRONLY, S_IWRITE);
      else
       f2 = open(fname2 , O_BINARY | O_TRUNC | O_WRONLY, S_IWRITE);
      write(f2, &BMP_FH,     14);
      write(f2, &BMP_IH,     40);
      write(f2, &COLtable, 1024);
      if(bmp_counter > 120000)
       {
        write(f2, buffer2,             60000);
        write(f2, &(buffer2[60000]),   60000);
        write(f2, &(buffer2[120000]),  (unsigned)(bmp_counter-120000));
       }
      else
      if(bmp_counter > 60000)
       {
        write(f2, buffer2,             60000);
        write(f2, &(buffer2[60000]),   (unsigned)(bmp_counter-60000));
       }
      else
        write(f2, buffer2, (unsigned)bmp_counter);
      close(f2);
     } /* for(k) */
    close(f1);
   } /* else of if(BMH.SizeX != 1) */
 else
  /* BM with columns data (Compressed == 1) */
  /* BM with columns data (Compressed == 2) */
  {
   printf("BM is COMPRESSED nothing done SORRY\n");
   close(f1);
  }; /* BM type */

 return(0);
}
