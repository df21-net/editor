/* ========================================================================== */
/* LEVBM.C    : BM PICKER                                                     */
/*              BM viewer                                                     */
/* ========================================================================== */
#include "levmap.h"
#include "levext.h"
#include "dark.h"
#include "dark.c"

/* ************************************************************************** */
/* BM VIEWER                                                                  */
/* ************************************************************************** */

int bmpicker(char *title, char *filename, char *returned,
             int color_fore, int color_back, int color_border, int color_hilite)
{
 char  *buffer;
 int   nbitems  = 0;
 int   selected = 0;
 int   wi;
 int   he;
 FILE  *pf;
 int   i;
 int   top = 0;
 int   oldtop = 0;
 int   topchanged = 0;
 char  buf[255];
 int   ccc;
 int   startpos=0;

 union  REGS   regs;
 struct SREGS  sregs;

 /* save the palette */
 regs.x.ax = 0x1017;
 regs.x.bx = 0;
 regs.x.cx = 256;
 sregs.es  = FP_SEG(DACbuffer2);
 regs.x.dx = FP_OFF(DACbuffer2);
 int86x( 0x10, &regs, &regs, &sregs );

 setviewport(0, TITLE_BOX_Y+1, 15 * 8 + 2, TITLE_BOX_Y+1 + 32 * 11 + 3 , 1);
 clearviewport();
 setcolor(color_border);
 rectangle(0, 0, 15 * 8, 32 * 11 + 1);
 setfillstyle(SOLID_FILL, color_back);
 floodfill(2, 2, color_border);
 rectangle(0, 0, 15*8, 24);
 setcolor(color_fore);
 outtextxy(8,8, title);

 wi = 16;
 he = 29;
 /* count the items */
 pf = fopen(filename , "rt");
 while(fgets(buf, wi, pf) != NULL)
  {
   nbitems++;
  }
 fclose(pf);

 if(nbitems == 0)
  {
   setviewport(0, 0, getmaxx(), getmaxy(), 1);
   strcpy(returned, "");
   return(-1);
  }

 if((buffer = (char *) farcalloc( (long) ((long)(wi+1)*(long)nbitems) ,1)) == NULL)
  {
   setviewport(0, 0, getmaxx(), getmaxy(), 1);
   strcpy(returned, "");
   return(-1);
  };

 i=0;
 pf = fopen(filename , "rt");
 while(fgets(buf, 255, pf) != NULL)
  {
   buf[wi] = '\0';
   buf[strlen(buf)-1] = '\0';
   if(strlen(buf) > 0)
    {
     strcpy(&(buffer[i*(wi+1)]), buf);
     if(strcmp(returned, buf) == 0) startpos = i;
     i++;
    }
  }
 fclose(pf);
 nbitems = i;

 if(startpos != 0)
  {
   selected = startpos % he;
   top      = startpos - selected;

   if(top + he >= nbitems)
    {
     top      = nbitems - he ;
     selected = startpos - top;
    }

   if(he > nbitems)
    {
     top      = 0;
     selected = startpos;
    }
  }

 ccc = 0;
 do
  {
   oldtop = top;
   switch(ccc)
    {
     case VK_DOWN : selected++;
                    if(selected > nbitems-1) selected--;
                    if(selected > he-1)
                      {
                       topchanged = 1;
                       selected--;
                       if(top + he < nbitems) top++;
                      }
                    break;
     case VK_UP   : selected--;
                    if(selected < 0)
                      {
                       topchanged = 1;
                       selected++;
                       if(top > 0) top--;
                      }
                    break;
     case VK_PGDN : top += he;
                    if(top + he >= nbitems) top = nbitems - he ;
                    if(top < 0) top = 0;
                    topchanged = 1;
                    break;
     case VK_PGUP : top -= he;
                    if(top < 0) top = 0;
                    topchanged = 1;
                    break;
     case VK_END  : top = nbitems - he;
                    if(top < 0) top = 0;
                    topchanged = 1;
                    break;
     case VK_HOME : top = 0;
                    topchanged = 1;
                    break;
    }
   /* hide previous only if necessary to avoid flicker */
   if(topchanged)
    {
     setcolor(color_back);
     for(i=0; i<he; i++)
     if(oldtop+i < nbitems)
     outtextxy(12, 30+11*i, &(buffer[(oldtop+i)*(wi+1)]));
     topchanged = 0;
    }
   for(i = 0; i < he; i++)
    if(top + i < nbitems)
     {
      if(i==selected)
       setcolor(color_hilite);
      else
       setcolor(color_fore);
      outtextxy(12, 30+11*i, &(buffer[(top+i)*(wi+1)]));
     }

    show_bm(&(buffer[(top+selected)*(wi+1)]), PAL_NAME);

  } while(((ccc=getVK()) != VK_ESC) && (ccc != VK_ENTER));

 if(ccc == VK_ESC)
   strcpy(returned, "");
 else
   strcpy(returned, &(buffer[(top+selected)*(wi+1)]));

 farfree(buffer);
 setviewport(0, 0, getmaxx(), getmaxy(), 1);

 /* restore the palette */
 regs.x.ax = 0x1012;
 regs.x.bx = 0;
 regs.x.cx = 256;
 sregs.es  = FP_SEG(DACbuffer2);
 regs.x.dx = FP_OFF(DACbuffer2);
 int86x( 0x10, &regs, &regs, &sregs );

 if(ccc == VK_ESC)
   return(-1);
 else
   return(top+selected);
}

int show_bm(char *bm, char *pal)
{
 int           i,j,k,n,m, rle;
 int           centerX, centerY;
 long          col_start;
 long          col_end;
 unsigned char huge *buffer;
 int           f1;
 char          fname1[80];
 char          str[80];
 int           ccc;
 int           nbbm;
 char          bmt[80];

 struct GOB_INDEX_ENTRY is;
 long          master_entries ;
 long          counter;

 union  REGS   regs;
 struct SREGS  sregs;

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

 setviewport(15 * 8 + 3, TITLE_BOX_Y+1, 15 * 8 + 3 + 512, TITLE_BOX_Y+1 + 300, 1);
 clearviewport();

/* PALETTE HANDLING */
 if(strcmp(pal, "") != 0)
  {
   strcpy(fname1, "dark\\");
   strcat(fname1, pal);

   if((f1=open(fname1 , O_BINARY | O_RDONLY)) == -1)
    {
     outtextxy(108,8,".PAL not found in SHOW_BM...");
     return(999);
    }
   read(f1, &DACbuffer, 768);
   close(f1);

   regs.x.ax = 0x1012;
   regs.x.bx = 0;
   regs.x.cx = 256;
   sregs.es  = FP_SEG(DACbuffer);
   regs.x.dx = FP_OFF(DACbuffer);
   int86x( 0x10, &regs, &regs, &sregs );
  }

/* BUFFER HANDLING */
 if((buffer = (unsigned char huge *) farcalloc((long)((long)BM_MEMORY * (long)1000),1)) == NULL)
  {
   outtextxy(108,8,"Cannot allocate buffer in SHOW_BM...");
   setviewport(0, TITLE_BOX_Y+1, 15 * 8 + 2, TITLE_BOX_Y+1 + 32 * 11 + 3 , 1);
   return(999);
  };

 switch(BM_MEMORY)
  {
   case 140 : memset(&(buffer[120000]), '\0', 20000);
   case 120 : memset(&(buffer[100000]), '\0', 20000);
   case 100 : memset(&(buffer[ 80000]), '\0', 20000);
   case  80 : memset(&(buffer[ 60000]), '\0', 20000);
   case  60 : memset(&(buffer[ 40000]), '\0', 20000);
   case  40 : memset(buffer           , '\0', 40000);
  }

/* BM file HANDLING */

 strcpy(fname1, "textures\\");
 strcat(fname1, bm);

 if(fexists(fname1) == FALSE)
  {
   /* get start address */
   f1 = open(textures_gob , O_BINARY | O_RDONLY);
   master_entries = get_master_entries(f1);
   seek_master_index(f1);
   counter = 0;
   while(counter < master_entries)
    {
     read(f1 , &is , sizeof(is));
     if(strcmp(is.NAME, bm) == 0) break;
     counter++;
    }

   if(counter < master_entries)  /* we did find it */
    {
     lseek(f1, is.IX , SEEK_SET);
    }
   else
    {
     close(f1);
     outtextxy(8,8,".BM not found in SHOW_BM...");
     setviewport(0, TITLE_BOX_Y+1, 15 * 8 + 2, TITLE_BOX_Y+1 + 32 * 11 + 3 , 1);
     farfree(buffer);   /* don't forget this in the other viewers ! */
     return(999);
    }
  }
 else
  {
   /* found in addon textures */
   f1 = open(fname1 , O_BINARY | O_RDONLY);
  }


 /* 1st read the header of 32 bytes */
 read(f1, &BMH, 32);

 /* if(BMH.SizeX != 1) */
 if((BMH.SizeX != 1) || ( (BMH.SizeX == 1) && (BMH.SizeY == 1) ) )
  /* simple : one bitmap */
  {
   switch(BM_MEMORY)
    {
     case  40 : read(f1, buffer,            40000);
                break;
     case  60 : read(f1, buffer,            60000);
                break;
     case  80 : read(f1, buffer,            60000);
                read(f1, &(buffer[60000]),  20000);
                break;
     case 100 : read(f1, buffer,            60000);
                read(f1, &(buffer[60000]),  40000);
                break;
     case 120 : read(f1, buffer,            60000);
                read(f1, &(buffer[60000]),  60000);
                break;
     case 140 : read(f1, buffer,            60000);
                read(f1, &(buffer[60000]),  60000);
                read(f1, &(buffer[120000]), 20000);
                break;
    }
   centerX = (512-BMH.SizeX)/2;
   centerY = (280+BMH.SizeY)/2;
   for(i=0;i<BMH.SizeX;i++)
    {
     for(j=0;j<BMH.SizeY;j++)
      putpixel(centerX+i, centerY-j, buffer[(long)i*BMH.SizeY+j]);
     if(kbhit()) break; /* get out quickly if user hit a key */
    }
   setcolor(255);
   rectangle( (512-BMH.SizeX)/2 -1,
              (280-BMH.SizeY)/2 -1,
              (512+BMH.SizeX)/2 +1,
              (280+BMH.SizeY)/2 +1  );
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
     centerX = (512-BMH.SizeX)/2;
     centerY = (280+BMH.SizeY)/2;
     centerX = centerX + (k-nbbm/2-1) * (BMH.SizeX +10);
     for(i=0;i<BMH.SizeX;i++)
      for(j=0;j<BMH.SizeY;j++)
       putpixel(centerX+i, centerY-j, buffer[(long)i*BMH.SizeY+j]);
     setcolor(255);
     rectangle( (512-BMH.SizeX)/2 -1+ (k-nbbm/2-1) * (BMH.SizeX +10),
                (280-BMH.SizeY)/2 -1,
                (512+BMH.SizeX)/2 +1+ (k-nbbm/2-1) * (BMH.SizeX +10),
                (280+BMH.SizeY)/2 +1  );
    }
  };

 close(f1);

 setcolor(255);
 sprintf(str , "%d x %d (%s)", BMH.SizeX / 8, BMH.SizeY / 8, bmt);
 outtextxy(8, 292, str);
 farfree(buffer);

 while(!VKhit()) ; 
 setviewport(0, TITLE_BOX_Y+1, 15 * 8 + 2, TITLE_BOX_Y+1 + 32 * 11 + 3 , 1);
 return(0);
}

