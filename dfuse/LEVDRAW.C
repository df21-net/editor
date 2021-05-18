/* ========================================================================== */
/* LEVDRAW.C  : MAP DRAWING FUNCTIONS                                         */
/*              including refresh while editing                               */
/*              GetWLlen    (because of math.h)                               */
/*              GetWLhei                                                      */
/* ========================================================================== */

#include "levmap.h"
#include "levext.h"
#include "math.h"   /* needed for sin, cos, sqrt */

/* ************************************************************************** */
/* DRAWING FUNCTIONS                                                          */
/* ************************************************************************** */

void draw_the_map(void)
{
  register s_ix;
  register i,j;

  if(GRID == 1)
   {
    for (i = ((int)S2MXF(0)/grid)*grid-grid; i <= ((int)S2MXF(getmaxx())/grid*grid)+grid; i += grid)
     for (j = ((int)S2MYF(getmaxy())/grid)*grid-grid; j <= ((int)S2MYF(0)/grid*grid)+grid; j += grid)
     {
      putpixel(M2SX(i), M2SY(j), COLOR_GRID);
      if(kbhit()) break;
     }
   }

  switch(MAP_MODE)
   {
    case 0 :
             draw_in_sc_mode();
             break;
    case 1 :
             draw_in_wl_mode();
             break;
    case 2 :
             draw_in_vx_mode();
              break;
    case 3 :
             draw_in_ob_mode();
             break;
   }
}

void handle_title(int color)
{
 int  tSC_HILITE;
 int  relative;
 char tmp[127];

 setviewport(0, 0, getmaxx(), getmaxy(), 1);

 /* will write first line in hilite if there is a multiselection */
 if((color == HEAD_FORE) && (MULTISEL != 0))
   setcolor(HILI_AT_ALT);
 else
   setcolor(color);

 if(GRID == 0)
  sprintf(tmpstr, "%-8s %-8s L:%+2d G:OFF S:%4.4g",
                  MAP_NAME,  MAP_MODE_NAMEL, LAYER, scale);
 else
  sprintf(tmpstr, "%-8s %-8s L:%+2d G:%-3d S:%4.4g",
                  MAP_NAME,  MAP_MODE_NAMEL, LAYER, grid, scale);
 outtextxy(10,6, tmpstr);

 switch(MAP_MODE)
  {
   case 0 : handle_title_sector(color);
            show_sector_layout(color);
            show_all_sector_fields(color);
            break;
   case 1 : handle_title_wall(color);
            show_wall_layout(color);
            show_all_wall_fields(color);
            break;
   case 2 : handle_title_vertex(color);
            show_vertex_layout(color);
            show_all_vertex_fields(color);
            break;
   case 3 : handle_title_object(color);
            show_object_layout(color);
            show_all_object_fields(color);
            break;
  }
 setviewport(0, TITLE_BOX_Y+1, getmaxx(), getmaxy(), 1);
}

void handle_titlebar(int color, int color_border)
{
 setviewport(0, 0, getmaxx(), getmaxy(), 1);
 setcolor(color_border);
 rectangle(0,0, TITLE_BOX_X, TITLE_BOX_Y);
 setfillstyle(SOLID_FILL, color);
 floodfill(10,10, color_border);
 rectangle(0,0, TITLE_BOX_X / 2, TITLE_BOX_Y);
 rectangle(0,0, TITLE_BOX_X / 2, 17);
 setviewport(0, TITLE_BOX_Y+1, getmaxx(), getmaxy(), 1);
}


void handle_loading(int color)
{
 setviewport(0, 0, getmaxx(), getmaxy(), 1);
 setcolor(color);
 outtextxy(10, 6, "LEVMAP "LEVMAP_VERSION" - Dark Forces Mapper");
 outtextxy(10,35, "(c) Yves BORCKMANS 1995");
 outtextxy(10,50, "(yborckmans@abcomp.be)");
 outtextxy(10,81, "Loading Level Data...");
 setviewport(0, TITLE_BOX_Y+1, getmaxx(), getmaxy(), 1);
}

void draw_a_sector(int sector, int color)
{
 int Wall;
 int VxF;
 int VxT;
 register w_ix;

 for(w_ix=0; w_ix < MAP_SEC[sector].wno; w_ix++)
  {
   Wall = GetSectorWL(sector, w_ix);
   VxF  = GetSectorVX(sector, MAP_WAL[Wall].left_vx);
   VxT  = GetSectorVX(sector, MAP_WAL[Wall].right_vx);
   moveto(M2SX(MAP_VRT[VxF].x), M2SY(MAP_VRT[VxF].z));
   if((MAP_WAL[Wall].walk != -1) && (color == LINE_AT_ALT))
    {
     setcolor(LINW_AT_ALT);
     lineto(M2SX(MAP_VRT[VxT].x), M2SY(MAP_VRT[VxT].z));
    }
   else
    {
     setcolor(color);
     lineto(M2SX(MAP_VRT[VxT].x), M2SY(MAP_VRT[VxT].z));
    }
  }
}

/* ************************************************************************** */
/* GetWLlen and GetWLhei                                                      */
/* ************************************************************************** */

float GetWLlen(int num)
{
 int l,r;
 float distance;

 l = GetAbsoluteVXFfromWL(num);
 r = GetAbsoluteVXTfromWL(num);

 distance = (float)((MAP_VRT[l].x - MAP_VRT[r].x) * (MAP_VRT[l].x - MAP_VRT[r].x )
          +         (MAP_VRT[l].z - MAP_VRT[r].z) * (MAP_VRT[l].z - MAP_VRT[r].z ));

 return( sqrt(distance) );
}

float GetWLhei(int num)
{
 return(MAP_SEC[MAP_WAL[num].sec].floor_alt - MAP_SEC[MAP_WAL[num].sec].ceili_alt);
}

void draw_shadow(void)
{
  register s_ix;
  register i,j;

   for(s_ix=0; s_ix <= sector_max ; s_ix++)
    {
     if(MAP_SEC[s_ix].del == 0)
      if(MAP_SEC[s_ix].layer != LAYER)
        draw_a_sector(s_ix, LINE_NOTALT);
     if(kbhit()) break;
    };
}

void draw_current_layer(void)
{
  register s_ix;
  register i,j;

  for(s_ix=0; s_ix <= sector_max ; s_ix++)
   {
    if(MAP_SEC[s_ix].del == 0)
     if(MAP_SEC[s_ix].layer == LAYER)
      draw_a_sector(s_ix, LINE_AT_ALT);
   };
}

void draw_specials(void)
{
  register s_ix;
  register i,j;

  /* redraw secrets, elev and sector triggers */
  for(s_ix=0; s_ix <= sector_max ; s_ix++)
   {
    if(MAP_SEC[s_ix].del == 0)
     if(MAP_SEC[s_ix].layer == LAYER)
      {
       if(MAP_SEC[s_ix].elev == 1)
        draw_a_sector(s_ix, LINE_ELEV);
       if(MAP_SEC[s_ix].trig == 1)
        draw_a_sector(s_ix, LINE_TRIG);
       if(MAP_SEC[s_ix].secret == 1)
        draw_a_sector(s_ix, LINE_SECRET);
      }
   };
}

void draw_line_triggers(void)
{
  register s_ix;
  register i,j;

  /* redraw line triggers */
  for(s_ix=0; s_ix <= wall_max ; s_ix++)
   {
    if(MAP_WAL[s_ix].trig != 0)
     if(MAP_SEC[MAP_WAL[s_ix].sec].layer == LAYER)
      {
       draw_a_wall(s_ix, LINE_TRIG);
      }
   };
}

/* ************************************************************************** */
/* REFRESH MAP WHILE EDITING because of a problem of viewports                */
/* ************************************************************************** */

void refresh_map_in_editor()
{
 setviewport(0, TITLE_BOX_Y+1, getmaxx(), getmaxy(), 1);
 clearviewport();
 draw_the_map();
 setviewport(0, 0, getmaxx(), getmaxy(), 1);
}

