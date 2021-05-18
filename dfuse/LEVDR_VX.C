/* ========================================================================== */
/* LEVDR_VX.C : MAP DRAWING FUNCTIONS for VERTICES                            */
/* ========================================================================== */

#include "levmap.h"
#include "levext.h"
#include "math.h"   /* needed for sin, cos, sqrt */

void handle_title_vertex(int color)
{
 int  tSC_HILITE;
 int  relative;
 int  l;
 int  r;
 int  lr;
 int  rr;

 setcolor(color);
 tSC_HILITE = MAP_VRT[VX_HILITE].sec;
 get_sector_info(tSC_HILITE);
 if(MAP_SEC[tSC_HILITE].del == 1)
  sprintf(tmpstr, "SEC : %-4d **DEL** %s", tSC_HILITE, swpSEC.name);
 else
  sprintf(tmpstr, "SEC : %-4d   Nam : %s", tSC_HILITE, swpSEC.name);
 outtextxy(10,21, tmpstr);
 relative = GetRelativeVXfromAbsoluteVX(VX_HILITE);
 sprintf(tmpstr, "VX  : %-4d   REL : %-4d of %-4d",
         VX_HILITE, relative, MAP_SEC[tSC_HILITE].vno);
 outtextxy(10,36, tmpstr);
 l = GetAbsoluteWLfromVXF(VX_HILITE);
 r = GetAbsoluteWLfromVXT(VX_HILITE);
 if(l != -1) lr = GetRelativeWLfromAbsoluteWL(l);
 else lr = -1;
 if(r != -1) rr = GetRelativeWLfromAbsoluteWL(r);
 else rr = -1;

 sprintf(tmpstr, "L of: %-4d   R of: %-4d (REL WL)", lr, rr);
 outtextxy(10,51, tmpstr);
 sprintf(tmpstr, "L of: %-4d   R of: %-4d (ABS WL)", l,r);
 outtextxy(10,66, tmpstr);
 sprintf(tmpstr, "FAlt: %+6.2f", -MAP_SEC[tSC_HILITE].floor_alt);
 outtextxy(10,81, tmpstr);
}

void draw_a_vertex(int vertex, int color)
{
 int dimension;

 setcolor(color);

 dimension = 0.5 * scale;
 if(dimension > 5) dimension = 5;

 circle(M2SX(MAP_VRT[vertex].x), M2SY(MAP_VRT[vertex].z), dimension);
}

void draw_a_bigger_vertex(int vertex, int color)
{
 float dimension;

 setcolor(color);
 dimension = 1.5 * scale;
 if(dimension > 10) dimension = 10;
 circle(M2SX(MAP_VRT[vertex].x), M2SY(MAP_VRT[vertex].z), (int)dimension);
 dimension /= 1.5;
 circle(M2SX(MAP_VRT[vertex].x), M2SY(MAP_VRT[vertex].z), (int)dimension);
 dimension /= 2;
 circle(M2SX(MAP_VRT[vertex].x), M2SY(MAP_VRT[vertex].z), (int)dimension);
}

void draw_sector_vertices(int sector, int color)
{
 int vx;
 int dimension;

 dimension = 0.5 * scale;
 if(dimension > 5) dimension = 5;

 setcolor(color);
 for(vx = MAP_SEC[sector].vrt0; vx < MAP_SEC[sector].vrt0+MAP_SEC[sector].vno; vx++)
  {
   circle(M2SX(MAP_VRT[vx].x), M2SY(MAP_VRT[vx].z), dimension);
  }
}

void draw_in_vx_mode(void)
{
  register s_ix;
  register i,j;

  /* draw map lines not at correct layer */
  if(SHADOW == 1) draw_shadow();

  /* redraw current layer -- also as shadow !! */
  for(s_ix=0; s_ix <= sector_max ; s_ix++)
   {
    if(MAP_SEC[s_ix].del == 0)
     if(MAP_SEC[s_ix].layer == LAYER)
      draw_a_sector(s_ix, LINE_NOTALT);
   };

  for(s_ix=0; s_ix <= sector_max ; s_ix++)
   {
    if(MAP_SEC[s_ix].del == 0)
     if(MAP_SEC[s_ix].layer == LAYER)
       draw_sector_vertices(s_ix, LINE_AT_ALT);
    if(kbhit()) break;
   };

  if(MULTISEL != 0)
  /* redraw multiple selection */
  for(s_ix=0; s_ix <= vertex_max ; s_ix++)
   {
    if(MAP_VRT[s_ix].mark != 0)
      draw_a_vertex(s_ix, COLOR_MULTISEL);
   };

  /* redraw hilited VX */
  if(MAP_VRT[VX_HILITE].mark != 0)
   draw_a_bigger_vertex(VX_HILITE, COLOR_MULTISEL);
  else
   if(MAP_SEC[MAP_VRT[VX_HILITE].sec].layer == LAYER)
    draw_a_bigger_vertex(VX_HILITE, HILI_AT_ALT);
   else
    draw_a_bigger_vertex(VX_HILITE, HILI_NOTALT);
}
