#include "dfuse.h"
#include "dfuseext.h"

/* ************************************************************************** */
/* PALETTE FUNCTIONS                                                          */
/* ************************************************************************** */

void set_mode_pal()
{
 int fpal;
 union  REGS   regs;
 struct SREGS  sregs;

 cleardevice();
 /* redefine the palette */
 fpal = open(fname_pal , O_BINARY | O_RDONLY);
 read(fpal, &DACbuffer, 768);
 close(fpal);

 /* this is a speed demon compared to setallpalette ! */
 regs.x.ax = 0x1012;
 regs.x.bx = 0;
 regs.x.cx = 256;
 sregs.es  = FP_SEG(DACbuffer);
 regs.x.dx = FP_OFF(DACbuffer);
 int86x( 0x10, &regs, &regs, &sregs );

 show_palette();
 gr_shutdown();
 gr_startup();
}

void show_palette()
{
 int i,j,k;

 k = getmaxy() / 16 -1;

 for(i=0;i<16;i++)
  for(j=0;j<16;j++)
   {
    setcolor(i*16+j);
    setfillstyle(SOLID_FILL, i*16+j);
    rectangle(k*j, k*i, k*j+k-4, k*i+k-4);
    floodfill(k*j+1, k*i+1, i*16+j);
   };
 i = 0;
 do
  {
   setcolor(i++);
   if(i>255) i=0;
   outtextxy(20, getmaxy()-10, fname_pal);
   delay(30);
  } while(!VKhit());
 getVK();
}

