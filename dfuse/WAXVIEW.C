#define WAXANIM_VERSION "v 1.20"
#define DFUSE_INI      "DFUSE.INI"

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <io.h>
#include <conio.h>
#include <fcntl.h>
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
void draw_current_fme(void);

void prepare_WAX_Header1(long n);
void prepare_WAX_Header2(long n);
void prepare_FME_Header1(long n);

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
char          outt[127];

int           get_out = 0;
int           show_info = 0;
int           ccc;
long          realsize;
long          wax1,wax2,fme1,fme2;

long  N_WAX_Header1 = 0;
long  N_WAX_Header2 = 0;
long  N_FME_Header1 = 0;
long  N_FME_Header2 = 0;

struct WAX_header0
{
 long  WAX_MAGIC;   /* ??? */
 long  N_WAX_Header2;
 long  N_FME_Header1;
 long  N_FME_Header2;
 char  unknown0[16];
 long  P_WAX_Header1[32];
}  WAX0;

struct WAX_header1
{
 long  u1;
 long  u2;
 long  u3;
 char  unknown0[16];
 long  P_WAX_Header2[32];
}  WAX1;

struct WAX_header2
{
 char  unknown0[16];
 long  P_FME_Header1[32];
}  WAX2;

struct FME_header1
{
 long  u1;
 long  u2;
 long  u3;
 long  P_FME_Header2;
 char  unknown0[16];
}  FME1;

struct FME_header2
{
 int   SizeX;
 int   u3;
 int   SizeY;
 int   u4;
 int   Compressed;
 int   u5;
 long  DataSize;
 char  fil[8];
}  FME2;


void handle_ini()
{
 if(fexists(DFUSE_INI))
  {
   ReadIniString("WAXVIEW-BGI", ".BGI", "", BGIdriver, 10, DFUSE_INI);
   BGImode = ReadIniInt("WAXVIEW-BGI", "MODE", 30000, DFUSE_INI);

   /* [DEFAULT-BGI] handling */
   if((strcmp(BGIdriver,"")==0) || (BGImode == 30000))
    {
     ReadIniString("DEFAULT-BGI", ".BGI", "", BGIdriver, 10, DFUSE_INI);
     BGImode = ReadIniInt("DEFAULT-BGI", "MODE", 30000, DFUSE_INI);
     if((strcmp(BGIdriver,""))==0 || (BGImode == 30000))
      {
       printf("WAXANIM can't find coherent values for .BGI and MODE !\n");
       printf("Please reconfigure the [DEFAULT-BGI] or [WAXVIEW-BGI] sections of DFUSE.INI .\n\n");
       exit(ERR_GRAPHIC);
      }
    }

   if(_argc != 3)
    {
     ReadIniString("WAXVIEW-PAL", ".PAL",  "",  PALfile, 100, DFUSE_INI);
     if(strcmp(PALfile,"")==0)
      {
       ReadIniString("DEFAULT-PAL", ".PAL",  "",  PALfile, 100, DFUSE_INI);
       if(strcmp(PALfile,"")==0)
        {
         printf("WAXANIM can't find coherent values for .PAL !\n");
         printf("Please reconfigure the [DEFAULT-PAL] or [WAXVIEW-PAL] sections of DFUSE.INI .\n\n");
         exit(ERR_GRAPHIC);
        }
      }
     strcat(PALfile, ".pal");
    }
  }
 else
  {
   printf("WAXVIEW can't find "DFUSE_INI"\n");
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

 printf("\n\nWAXANIM "WAXANIM_VERSION" (c) Yves BORCKMANS 1995.\n\n");
 /* Check number of arguments */
 if((_argc != 2) && (_argc != 3))
  {
   printf("Usage is  WAXANIM waxfile [palfile]\n");
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

 /* sets the correct palette */
 read(f1, &DACbuffer, 768);
 close(f1);
 regs.x.ax = 0x1012;
 regs.x.bx = 0;
 regs.x.cx = 256;
 sregs.es  = FP_SEG(DACbuffer);
 regs.x.dx = FP_OFF(DACbuffer);
 int86x( 0x10, &regs, &regs, &sregs );

 strcpy(fname1, _argv[1]);
 f1 = open(fname1 , O_BINARY | O_RDONLY);

 read(f1, &WAX0, sizeof(WAX0));

 N_WAX_Header1 = 0;
 for(wax1=0;wax1<32;wax1++)
  {
   if(WAX0.P_WAX_Header1[wax1] != 0)
    N_WAX_Header1++;
   else
    break;
  }
 wax1 = 0;

 prepare_WAX_Header1(0);

 while(get_out == 0)
  {
   cleardevice();
   draw_current_fme();
   if(show_info)
    {
     outtextxy(10,5, _argv[1]);
     sprintf(outt, "ACTION    : WAX1  = %2.2ld at %ld", wax1, WAX0.P_WAX_Header1[wax1]);
     outtextxy(10,25, outt);
     sprintf(outt, "ROTATION  : WAX2  = %2.2ld at %ld", wax2, WAX1.P_WAX_Header2[wax2]);
     outtextxy(10,35, outt);
     sprintf(outt, "ANIMATION : FME1  = %2.2ld at %ld", fme1, WAX2.P_FME_Header1[fme1]);
     outtextxy(10,45, outt);
     sprintf(outt, "FRAME     : %ld   Len = %ld", FME1.P_FME_Header2, realsize);
     outtextxy(10,55, outt);
    }

   ccc = getVK();
   switch(ccc)
    {
     case VK_UP    : wax1++;
                     if(wax1 >= N_WAX_Header1) wax1 = 0;
                     prepare_WAX_Header1(wax1);
                     break;
     case VK_DOWN  : wax1--;
                     if(wax1 < 0) wax1 = N_WAX_Header1 - 1;
                     if(wax1 < 0) wax1 = 0;
                     prepare_WAX_Header1(wax1);
                     break;
     case VK_RIGHT : wax2++;
                     if(wax2 >= N_WAX_Header2) wax2 = 0;
                     prepare_WAX_Header2(wax2);
                     break;
     case VK_LEFT  : wax2--;
                     if(wax2 < 0) wax2 = N_WAX_Header2 - 1;
                     if(wax2 < 0) wax2 = 0;
                     prepare_WAX_Header2(wax2);
                     break;
     case VK_SPACE : fme1++;
                     if(fme1 >= N_FME_Header1) fme1 = 0;
                     prepare_FME_Header1(fme1);
                     break;
     case 'B'      :
     case 'b'      : fme1--;
                     if(fme1 < 0 ) fme1 = N_FME_Header1 - 1;
                     if(fme1 < 0 ) fme1 = 0;
                     prepare_FME_Header1(fme1);
                     break;
     case VK_TAB   : show_info = !show_info;
                     break;
     case VK_F1    :
                      outtextxy(10,75,  "ACTION    : ,");
                      outtextxy(10,85,  "ROTATION  : ,");
                      outtextxy(10,95,  "ANIMATION : Spc, B");
                      outtextxy(10,105, "INFO.     : Tab");
                      outtextxy(10,115, "QUIT      : Esc");
                      getVK();
                     break;
     case VK_ESC   : get_out = 1;
                     break;
    }
  }

 close(f1);
 closegraph();
 restorecrtmode();
 return(0);
}


void prepare_WAX_Header1(long n)
{
  lseek(f1, WAX0.P_WAX_Header1[n], SEEK_SET);
  read(f1, &WAX1, sizeof(WAX1));

  N_WAX_Header2 = 0;
  for(wax2=0;wax2<32;wax2++)
   {
    if(WAX1.P_WAX_Header2[wax2] != 0)
     N_WAX_Header2++;
    else
     break;
   }
  prepare_WAX_Header2(0);
  wax2 = 0;
}

void prepare_WAX_Header2(long n)
{
 lseek(f1, WAX1.P_WAX_Header2[n], SEEK_SET);
 read(f1, &WAX2, sizeof(WAX2));

 N_FME_Header1 = 0;
 for(fme1=0;fme1<32;fme1++)
  {
   if(WAX2.P_FME_Header1[fme1] != 0)
    N_FME_Header1++;
   else
    break;
  }
  prepare_FME_Header1(0);
  fme1 = 0;
}

void prepare_FME_Header1(long n)
{
  lseek(f1, WAX2.P_FME_Header1[n], SEEK_SET);
  read(f1, &FME1, sizeof(FME1));
}

void draw_current_fme(void)
{
 lseek(f1, FME1.P_FME_Header2, SEEK_SET);
 read(f1, &FME2, 24);

 centerX = (getmaxx()-FME2.SizeX)/2;
 centerY = (getmaxy()+FME2.SizeY)/2;

 /* Read the DATA */
 if(!FME2.Compressed)
   realsize = (long)FME2.SizeX * (long)FME2.SizeY;
 else
   realsize = FME2.DataSize-24;
 if (realsize > 40000)
  {
   read(f1, buffer, 40000);
   if (realsize > 80000)
    {
     read(f1, &(buffer[40000]), 40000);
     if (realsize > 120000)
      {
       read(f1, &(buffer[80000]), 40000);
       read(f1, &(buffer[120000]), realsize-120000);
      }
     else
      read(f1, &(buffer[80000]), realsize-80000);
    }
   else
    read(f1, &(buffer[40000]), realsize-40000);
  }
 else
  read(f1, buffer, realsize);

 if(!FME2.Compressed)
  {
   for(i=0;i<FME2.SizeX;i++)
    for(j=0;j<FME2.SizeY;j++)
     putpixel(centerX+i, centerY-j, buffer[(long)i*FME2.SizeY+j]);
  }
 else
  {
   for(i=0;i<FME2.SizeX;i++)
    {
     col_start = *(long *)&(buffer[(long)i*4]) - 24;
     col_end   = i < FME2.SizeX-1 ? *(long *)&(buffer[(long)(i+1)*4]) - 24 : FME2.DataSize-24;
     j         = 0;
     k         = 0;
     while((col_start+j < col_end) && (buffer[col_start+j] != 0))
      {
       if(buffer[col_start+j] < 128)
         flipflop = 1;
       else
         flipflop = 0;
       if(flipflop == 0)
        {
         rle = buffer[col_start+j] - 128;
         for(m=0; m<rle; m++)
          {
           putpixel(centerX+i,centerY-k,0);
           k++;
          }
         j++;
        }
       else
        {
         n = buffer[col_start+j];
         j++;
         for(m=0; m<n; m++)
          {
           putpixel(centerX+i,centerY-k,buffer[col_start+j]);
           k++;
           j++;
          }
        }
      };
   } /* for */
  }; /* BM type */
}
