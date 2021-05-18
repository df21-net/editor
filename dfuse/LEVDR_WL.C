/* ========================================================================== */
/* LEVDR_WL.C : MAP DRAWING FUNCTIONS for WALLS                               */
/* ========================================================================== */

#include "levmap.h"
#include "levext.h"
#include "math.h"   /* needed for sin, cos, sqrt */

void handle_title_wall(int color)
{
 int  tSC_HILITE;
 int  relative;

 setcolor(color);
 tSC_HILITE = MAP_WAL[WL_HILITE].sec;
 get_sector_info(tSC_HILITE);
 get_wall_info(WL_HILITE);
 if(MAP_SEC[tSC_HILITE].del == 1)
  sprintf(tmpstr, "SEC : %-4d **DEL** %s", tSC_HILITE, swpSEC.name);
 else
  sprintf(tmpstr, "SEC : %-4d   Nam : %s", tSC_HILITE, swpSEC.name);
 outtextxy(10,21, tmpstr);
 relative = GetRelativeWLfromAbsoluteWL(WL_HILITE);
 sprintf(tmpstr, "WL  : %-4d   REL : %-4d of %-4d",
         WL_HILITE, relative, MAP_SEC[tSC_HILITE].wno);
 outtextxy(10,36, tmpstr);
 sprintf(tmpstr, "VXLr: %-4d   VXRr: %-4d",
         MAP_WAL[WL_HILITE].left_vx, MAP_WAL[WL_HILITE].right_vx);
 outtextxy(10,51, tmpstr);
 sprintf(tmpstr, "FAlt: %+6.2f Hei : %5.2f Len : %5.2f", -MAP_SEC[tSC_HILITE].floor_alt, GetWLhei(WL_HILITE), GetWLlen(WL_HILITE));
 outtextxy(10,66, tmpstr);

 if(MAP_WAL[WL_HILITE].trig != 0)
  {
   if(color != COLOR_ERASER) setcolor(LINE_AT_ALT);
   sprintf(tmpstr, "TRIG: %s client: %s", swpWAL.trigger_name, swpWAL.client_name);
   outtextxy(10,81, tmpstr);
  }
}

void draw_a_wall(int wall, int color)
{
 int VxF;
 int VxT;

 setcolor(color);
 VxF  = GetSectorVX(MAP_WAL[wall].sec, MAP_WAL[wall].left_vx);
 VxT  = GetSectorVX(MAP_WAL[wall].sec, MAP_WAL[wall].right_vx);
 moveto(M2SX(MAP_VRT[VxF].x), M2SY(MAP_VRT[VxF].z));
 lineto(M2SX(MAP_VRT[VxT].x), M2SY(MAP_VRT[VxT].z));
}

void draw_a_wall_side(int num, int color)
{
 int i;
 float x, z;
 float deltax, deltaz;
 float x2, z2;

 setcolor(color);
 x    = (MAP_VRT[GetSectorVX(MAP_WAL[num].sec,MAP_WAL[num].left_vx)].x
       + MAP_VRT[GetSectorVX(MAP_WAL[num].sec,MAP_WAL[num].right_vx)].x)
       / 2;
 z    = (MAP_VRT[GetSectorVX(MAP_WAL[num].sec,MAP_WAL[num].left_vx)].z
       + MAP_VRT[GetSectorVX(MAP_WAL[num].sec,MAP_WAL[num].right_vx)].z)
       / 2;

 deltax =   MAP_VRT[GetSectorVX(MAP_WAL[num].sec,MAP_WAL[num].left_vx)].x
          - MAP_VRT[GetSectorVX(MAP_WAL[num].sec,MAP_WAL[num].right_vx)].x;
 deltaz =   MAP_VRT[GetSectorVX(MAP_WAL[num].sec,MAP_WAL[num].left_vx)].z
          - MAP_VRT[GetSectorVX(MAP_WAL[num].sec,MAP_WAL[num].right_vx)].z;

 x2 = x - EXTRUDE_RATIO * deltaz;
 z2 = z + EXTRUDE_RATIO * deltax;

 moveto(M2SX(x), M2SY(z));
 lineto(M2SX(x2), M2SY(z2));
}

void draw_in_wl_mode(void)
{
  register s_ix;
  register i,j;

  if(SHADOW == 1) draw_shadow();
  draw_current_layer();
  draw_specials();
  draw_line_triggers();

  if(MULTISEL != 0)
  /* redraw multiple selection */
  for(s_ix=0; s_ix <= wall_max ; s_ix++)
   {
    if(MAP_WAL[s_ix].mark != 0)
      {
       draw_a_wall(s_ix, COLOR_MULTISEL);
       if(PERPS > 1) draw_a_wall_side(s_ix, COLOR_MULTISEL);
      }
   };

  /* redraw hilited WL */
  if(MAP_WAL[WL_HILITE].mark != 0)
   {
    draw_a_wall(WL_HILITE, COLOR_MULTISEL);
    draw_a_bigger_vertex(GetAbsoluteVXFfromWL(WL_HILITE), COLOR_MULTISEL);
    if(PERPS > 0) draw_a_wall_side(WL_HILITE, COLOR_MULTISEL);
   }
  else
   if(MAP_SEC[MAP_WAL[WL_HILITE].sec].layer == LAYER)
    {
      draw_a_wall(WL_HILITE, HILI_AT_ALT);
      draw_a_bigger_vertex(GetAbsoluteVXFfromWL(WL_HILITE), HILI_AT_ALT);
      if(PERPS > 0) draw_a_wall_side(WL_HILITE, HILI_AT_ALT);
    }
   else
    {
      draw_a_wall(WL_HILITE, HILI_NOTALT);
      draw_a_bigger_vertex(GetAbsoluteVXFfromWL(WL_HILITE), HILI_NOTALT);
      if(PERPS > 0) draw_a_wall_side(WL_HILITE, HILI_NOTALT);
    }
}

