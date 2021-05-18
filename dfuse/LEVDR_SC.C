/* ========================================================================== */
/* LEVDR_SC.C : MAP DRAWING FUNCTIONS for SECTORS                             */
/* ========================================================================== */

#include "levmap.h"
#include "levext.h"
#include "math.h"   /* needed for sin, cos, sqrt */

void handle_title_sector(int color)
{
 setcolor(color);
 get_sector_info(SC_HILITE);
 if(MAP_SEC[SC_HILITE].del == 1)
  {
   outtextxy(10,21, "***** DELETED SECTOR *****");
  }
 sprintf(tmpstr, "SC  : %-4d", SC_HILITE);
 outtextxy(10,36, tmpstr);
 sprintf(tmpstr, "VX #: %-4d  WL #: %-4d",
         MAP_SEC[SC_HILITE].vno,
         MAP_SEC[SC_HILITE].wno);
 outtextxy(10,51, tmpstr);
 sprintf(tmpstr, "VX 0: %-4d  WL 0: %-4d",
         MAP_SEC[SC_HILITE].vrt0,
         MAP_SEC[SC_HILITE].wal0);
 outtextxy(10,66, tmpstr);
 if(MAP_SEC[SC_HILITE].trig != 0)
  {
   if(color != COLOR_ERASER) setcolor(LINE_AT_ALT);
   sprintf(tmpstr, "TRIG: client: %s", swpSEC.client_name);
   outtextxy(10,81, tmpstr);
  }
}

void draw_in_sc_mode(void)
{
  register s_ix;
  register i,j;

  if(SHADOW == 1) draw_shadow();
  draw_current_layer();
  draw_specials();
  draw_line_triggers();

  if(MULTISEL != 0)
  /* redraw multiple selection */
  for(s_ix=0; s_ix <= sector_max ; s_ix++)
   {
    if(MAP_SEC[s_ix].mark != 0)
      draw_a_sector(s_ix, COLOR_MULTISEL);
   };

  /* redraw hilited sector */
  if(MAP_SEC[SC_HILITE].mark != 0)
   {
    draw_a_sector(SC_HILITE, COLOR_MULTISEL);
    draw_a_bigger_vertex(MAP_SEC[SC_HILITE].vrt0, COLOR_MULTISEL);
   }
  else
   if(MAP_SEC[SC_HILITE].del == 0)
    {
     if(MAP_SEC[SC_HILITE].layer == LAYER)
      {
        draw_a_sector(SC_HILITE, HILI_AT_ALT);
        draw_a_bigger_vertex(MAP_SEC[SC_HILITE].vrt0, HILI_AT_ALT);
      }
     else
      {
        draw_a_sector(SC_HILITE, HILI_NOTALT);
        draw_a_bigger_vertex(MAP_SEC[SC_HILITE].vrt0, HILI_NOTALT);
      }
    }
   else
    {
     draw_a_sector(SC_HILITE, COLOR_DELETED);
     draw_a_bigger_vertex(MAP_SEC[SC_HILITE].vrt0, COLOR_DELETED);
    }
}

