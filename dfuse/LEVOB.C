/* ========================================================================== */
/* LEVOB.C    : OBJECT PICKER                                                 */
/*              FME viewer                                                    */
/*              WAX viewer (static)                                           */
/* ========================================================================== */
#include "levmap.h"
#include "levext.h"
#include "dark.h"

/* ************************************************************************** */
/* LIST PICKER for PODS, FRAMES, SPRITES and SOUNDS                           */
/* ************************************************************************** */

int obpicker(char *title, char *filename, char *returned,
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

    if(strcmp(title,"  FRAMES  ") == 0)
      show_fme(&(buffer[(top+selected)*(wi+1)]), PAL_NAME);
    if(strcmp(title,"  SPRITES ") == 0)
      show_wax(&(buffer[(top+selected)*(wi+1)]), PAL_NAME);

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

int show_fme(char *fme, char *pal)
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
 int           flipflop;
 int           nbbm;
 char          bmt[20];

 struct GOB_INDEX_ENTRY is;
 long          master_entries ;
 long          counter;

 union  REGS   regs;
 struct SREGS  sregs;

struct FME_header1
{
 long  u1;
 long  u2;
 long  u3;
 long  header2;
 char  unknown0[16];
}             FME1;

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
     outtextxy(108,8,".PAL not found in SHOW_FME...");
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
   outtextxy(108,8,"Cannot allocate buffer in SHOW_FME...");
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

/* FME file HANDLING */

 strcpy(fname1, "sprites\\");
 strcat(fname1, fme);

 if(fexists(fname1) == FALSE)
  {
   /* get start address */
   f1 = open(sprites_gob , O_BINARY | O_RDONLY);
   master_entries = get_master_entries(f1);
   seek_master_index(f1);
   counter = 0;
   while(counter < master_entries)
    {
     read(f1 , &is , sizeof(is));
     if(strcmp(is.NAME, fme) == 0) break;
     counter++;
    }

   if(counter < master_entries)  /* we did find it */
    {
     lseek(f1, is.IX , SEEK_SET);
    }
   else
    {
     close(f1);
     outtextxy(8,8,".FME not found in SHOW_FME...");
     setviewport(0, TITLE_BOX_Y+1, 15 * 8 + 2, TITLE_BOX_Y+1 + 32 * 11 + 3 , 1);
     farfree(buffer);   /* don't forget this in the other viewers ! */
     return(999);
    }
  }
 else
  {
   /* found in addon sprites */
   f1 = open(fname1 , O_BINARY | O_RDONLY);
   is.IX = 0;
  }

/* READ HANDLING */
 /* 1st read the header of 32 bytes to get the address of the real header */
 read(f1, &FME1, 32);

 lseek(f1, is.IX + FME1.header2, SEEK_SET);
 read(f1, &BMH, 24);

 /* read all I can in one go ! */
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

 centerX = (512-2*BMH.SizeX)/2;
 centerY = (280+2*BMH.SizeY)/2;

 if(!BMH.Compressed)
  {
   for(i=0;i<BMH.SizeX;i++)
    {
     for(j=0;j<BMH.SizeY;j++)
      {
        putpixel(centerX+2*i  , centerY-2*j  , buffer[(long)i*BMH.SizeY+j]);
        putpixel(centerX+2*i+1, centerY-2*j  , buffer[(long)i*BMH.SizeY+j]);
        putpixel(centerX+2*i  , centerY-2*j-1, buffer[(long)i*BMH.SizeY+j]);
        putpixel(centerX+2*i+1, centerY-2*j-1, buffer[(long)i*BMH.SizeY+j]);
      }
     if(kbhit()) break; /* get out quickly if user hit a key */
    }
   strcpy(bmt,"Simple");
  }
 else
  /* compressed */
  {
   for(i=0;i<BMH.SizeX;i++)
    {
     col_start = *(long *)&(buffer[(long)i*4]) - 24;
     col_end   = i < BMH.SizeX-1 ? *(long *)&(buffer[(long)(i+1)*4]) - 24 : BMH.DataSize-24;
     j         = 0;
     k         = 0;
     while(col_start+j < col_end)
      {
       if(buffer[col_start+j] < 128)
         flipflop = 1;
       else
         flipflop = 0;
       if(flipflop == 0)
        {
         if(buffer[col_start+j] != 255) flipflop = 1;
         rle = buffer[col_start+j] - 128;
         /* j++; contrary to BMs, where the next byte is the color */
         for(m=0; m<rle; m++)
          {
           putpixel(centerX+2*i  , centerY-2*k  , 0);
           putpixel(centerX+2*i+1, centerY-2*k  , 0);
           putpixel(centerX+2*i  , centerY-2*k-1, 0);
           putpixel(centerX+2*i+1, centerY-2*k-1, 0);
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
           putpixel(centerX+2*i  , centerY-2*k  , buffer[col_start+j]);
           putpixel(centerX+2*i+1, centerY-2*k  , buffer[col_start+j]);
           putpixel(centerX+2*i  , centerY-2*k-1, buffer[col_start+j]);
           putpixel(centerX+2*i+1, centerY-2*k-1, buffer[col_start+j]);
           k++;
           j++;
          }
         flipflop = 0;
        }
       if(kbhit()) break; /* get out quickly if user hit a key */
      };
   } /* for */
   strcpy(bmt,"Compr");
  };

 close(f1);
 setcolor(255);
 rectangle( (512-2*BMH.SizeX)/2 -1,
            (280-2*BMH.SizeY)/2 -1,
            (512+2*BMH.SizeX)/2 +1,
            (280+2*BMH.SizeY)/2 +1  );

 sprintf(str , "%d x %d (%s) Z", BMH.SizeX, BMH.SizeY, bmt);
 outtextxy(8, 292, str);
 farfree(buffer);

 while(!VKhit()) ; 
 setviewport(0, TITLE_BOX_Y+1, 15 * 8 + 2, TITLE_BOX_Y+1 + 32 * 11 + 3 , 1);
 return(0);
}



int show_wax(char *wax, char *pal)
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
 int           flipflop;
 int           nbbm;
 char          bmt[20];
 long          firstframe;

 struct GOB_INDEX_ENTRY is;
 long          master_entries ;
 long          counter;

 union  REGS   regs;
 struct SREGS  sregs;

struct FME_header1
{
 long  u1;
 long  u2;
 long  u3;
 long  header2;
 char  unknown0[16];
}             FME1;

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
     outtextxy(108,8,".PAL not found in SHOW_FME...");
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

/* WAX file HANDLING */

 strcpy(fname1, "sprites\\");
 strcat(fname1, wax);

 if(fexists(fname1) == FALSE)
  {
   /* get start address */
   f1 = open(sprites_gob , O_BINARY | O_RDONLY);
   master_entries = get_master_entries(f1);
   seek_master_index(f1);
   counter = 0;
   while(counter < master_entries)
    {
     read(f1 , &is , sizeof(is));
     if(strcmp(is.NAME, wax) == 0) break;
     counter++;
    }

   if(counter < master_entries)  /* we did find it */
    {
     lseek(f1, is.IX , SEEK_SET);
    }
   else
    {
     close(f1);
     outtextxy(8,8,".WAX not found in SHOW_WAX...");
     setviewport(0, TITLE_BOX_Y+1, 15 * 8 + 2, TITLE_BOX_Y+1 + 32 * 11 + 3 , 1);
     farfree(buffer);   /* don't forget this in the other viewers ! */
     return(999);
    }
  }
 else
  {
   /* found in addon sprites */
   f1 = open(fname1 , O_BINARY | O_RDONLY);
   is.IX = 0;
  }

/* READ HANDLING */

 /* start of 'position' table */
 lseek(f1, is.IX + 0x000000BC, SEEK_SET);
 read(f1, &firstframe, 4);
 firstframe += 16;
 lseek(f1, is.IX + firstframe, SEEK_SET);
 read(f1, &firstframe, 4);
 lseek(f1, is.IX + firstframe, SEEK_SET);

 /* read the first 'time' header of 32 bytes to get the address */
 /* of the real header */
 read(f1, &FME1, 32);
 lseek(f1, is.IX + FME1.header2, SEEK_SET);
 read(f1, &BMH, 24);

 /* read all I can in one go ! */
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
 close(f1);

 centerX = (512-2*BMH.SizeX)/2;
 centerY = (280+2*BMH.SizeY)/2;

 if(!BMH.Compressed)
  {
   for(i=0;i<BMH.SizeX;i++)
    {
     for(j=0;j<BMH.SizeY;j++)
      {
        putpixel(centerX+2*i  , centerY-2*j  , buffer[(long)i*BMH.SizeY+j]);
        putpixel(centerX+2*i+1, centerY-2*j  , buffer[(long)i*BMH.SizeY+j]);
        putpixel(centerX+2*i  , centerY-2*j-1, buffer[(long)i*BMH.SizeY+j]);
        putpixel(centerX+2*i+1, centerY-2*j-1, buffer[(long)i*BMH.SizeY+j]);
      }
     if(kbhit()) break; /* get out quickly if user hit a key */
    }
   strcpy(bmt,"Simple");
  }
 else
  /* compressed */
  {
   for(i=0;i<BMH.SizeX;i++)
    {
     col_start = *(long *)&(buffer[(long)i*4]) - 24;
     col_end   = i < BMH.SizeX-1 ? *(long *)&(buffer[(long)(i+1)*4]) - 24 : BMH.DataSize-24;
     j         = 0;
     k         = 0;
     while(col_start+j < col_end)
      {
       if(buffer[col_start+j] < 128)
         flipflop = 1;
       else
         flipflop = 0;
       if(flipflop == 0)
        {
         if(buffer[col_start+j] != 255) flipflop = 1;
         rle = buffer[col_start+j] - 128;
         /* j++; contrary to BMs, where the next byte is the color */
         for(m=0; m<rle; m++)
          {
           putpixel(centerX+2*i  , centerY-2*k  , 0);
           putpixel(centerX+2*i+1, centerY-2*k  , 0);
           putpixel(centerX+2*i  , centerY-2*k-1, 0);
           putpixel(centerX+2*i+1, centerY-2*k-1, 0);
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
           putpixel(centerX+2*i  , centerY-2*k  , buffer[col_start+j]);
           putpixel(centerX+2*i+1, centerY-2*k  , buffer[col_start+j]);
           putpixel(centerX+2*i  , centerY-2*k-1, buffer[col_start+j]);
           putpixel(centerX+2*i+1, centerY-2*k-1, buffer[col_start+j]);
           k++;
           j++;
          }
         flipflop = 0;
        }
       if(kbhit()) break; /* get out quickly if user hit a key */
      };
   } /* for */
   strcpy(bmt,"Compr");
  };

 close(f1);
 setcolor(255);
 rectangle( (512-2*BMH.SizeX)/2 -1,
            (280-2*BMH.SizeY)/2 -1,
            (512+2*BMH.SizeX)/2 +1,
            (280+2*BMH.SizeY)/2 +1  );

 sprintf(str , "%d x %d (%s) Z", BMH.SizeX, BMH.SizeY, bmt);
 outtextxy(8, 292, str);
 farfree(buffer);

 while(!VKhit()) ; 
 setviewport(0, TITLE_BOX_Y+1, 15 * 8 + 2, TITLE_BOX_Y+1 + 32 * 11 + 3 , 1);
 return(0);
}

