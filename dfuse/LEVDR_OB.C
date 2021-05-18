/* ========================================================================== */
/* LEVDR_OB.C : MAP DRAWING FUNCTIONS for OBJECTS                             */
/* ========================================================================== */

#include "levmap.h"
#include "levext.h"
#include "math.h"   /* needed for sin, cos, sqrt */

void handle_title_object(int color)
{
 setcolor(color);
 get_object_info(OB_HILITE);
 sprintf(tmpstr, "OB  : %-4d", OB_HILITE);
 outtextxy(10,36, tmpstr);
 if(MAP_OBJ[OB_HILITE].del == 1)
  {
   outtextxy(10,21, "***** DELETED OBJECT *****");
  }

 if(OBJECT_LAYERING == 1)
  if(MAP_OBJ[OB_HILITE].sec != -1)
   {
    get_sector_info(MAP_OBJ[OB_HILITE].sec);
    sprintf(tmpstr, "SEC : %-4d  Nam : %s", MAP_OBJ[OB_HILITE].sec, swpSEC.name);
    outtextxy(10, 51, tmpstr);
    sprintf(tmpstr, "Lay : %d     Flo.: % 5.2f Ceil: % 5.2f ",
                      MAP_SEC[MAP_OBJ[OB_HILITE].sec].layer,
                     -MAP_SEC[MAP_OBJ[OB_HILITE].sec].floor_alt,
                     -MAP_SEC[MAP_OBJ[OB_HILITE].sec].ceili_alt);
    outtextxy(10, 66, tmpstr);
   }
  else
   {
    sprintf(tmpstr, "SEC : None!");
    outtextxy(10, 51, tmpstr);
   }
}

void draw_an_object(int obj, int color)
{
 float dimension;

 dimension = 0.75 * scale;
 if(dimension > 8) dimension = 8;


 if((color == COLOR_MULTISEL) || (color == OBJ_HILITED))
   setcolor(color);
 else
   setcolor(MAP_OBJ[obj].col);
 switch(MAP_OBJ[obj].type)
  {
   case OBT_SPIRIT :
     moveto(M2SX(MAP_OBJ[obj].x) - dimension, M2SY(MAP_OBJ[obj].z) + dimension);
     lineto(M2SX(MAP_OBJ[obj].x) + dimension, M2SY(MAP_OBJ[obj].z) - dimension);
     moveto(M2SX(MAP_OBJ[obj].x) - dimension, M2SY(MAP_OBJ[obj].z) - dimension);
     lineto(M2SX(MAP_OBJ[obj].x) + dimension, M2SY(MAP_OBJ[obj].z) + dimension);
    break;
   case OBT_SAFE :
     moveto(M2SX(MAP_OBJ[obj].x) + dimension, M2SY(MAP_OBJ[obj].z) - dimension);
     lineto(M2SX(MAP_OBJ[obj].x) - dimension, M2SY(MAP_OBJ[obj].z) - dimension);
     lineto(M2SX(MAP_OBJ[obj].x) - dimension, M2SY(MAP_OBJ[obj].z) );
     lineto(M2SX(MAP_OBJ[obj].x) + dimension, M2SY(MAP_OBJ[obj].z) );
     lineto(M2SX(MAP_OBJ[obj].x) + dimension, M2SY(MAP_OBJ[obj].z) + dimension);
     lineto(M2SX(MAP_OBJ[obj].x) - dimension, M2SY(MAP_OBJ[obj].z) + dimension);
    break;
   case OBT_3D :
     moveto(M2SX(MAP_OBJ[obj].x) - dimension, M2SY(MAP_OBJ[obj].z) - dimension);
     lineto(M2SX(MAP_OBJ[obj].x) + dimension, M2SY(MAP_OBJ[obj].z) - dimension);
     lineto(M2SX(MAP_OBJ[obj].x) + dimension, M2SY(MAP_OBJ[obj].z) + dimension);
     lineto(M2SX(MAP_OBJ[obj].x) - dimension, M2SY(MAP_OBJ[obj].z) + dimension);
     moveto(M2SX(MAP_OBJ[obj].x)            , M2SY(MAP_OBJ[obj].z)            );
     lineto(M2SX(MAP_OBJ[obj].x) + dimension, M2SY(MAP_OBJ[obj].z)            );
    break;
   case OBT_SPRITE :
    if(MAP_OBJ[obj].special != OBS_GENERATOR)
     {
     moveto(M2SX(MAP_OBJ[obj].x) - dimension, M2SY(MAP_OBJ[obj].z) - dimension);
     lineto(M2SX(MAP_OBJ[obj].x) - dimension, M2SY(MAP_OBJ[obj].z) + dimension);
     lineto(M2SX(MAP_OBJ[obj].x) + dimension, M2SY(MAP_OBJ[obj].z) + dimension);
     lineto(M2SX(MAP_OBJ[obj].x) + dimension, M2SY(MAP_OBJ[obj].z) - dimension);
     lineto(M2SX(MAP_OBJ[obj].x) - dimension, M2SY(MAP_OBJ[obj].z) - dimension);
     }
    else
     {
     moveto(M2SX(MAP_OBJ[obj].x) + dimension, M2SY(MAP_OBJ[obj].z) - dimension);
     lineto(M2SX(MAP_OBJ[obj].x) - dimension, M2SY(MAP_OBJ[obj].z) - dimension);
     lineto(M2SX(MAP_OBJ[obj].x) - dimension, M2SY(MAP_OBJ[obj].z) + dimension);
     lineto(M2SX(MAP_OBJ[obj].x) + dimension, M2SY(MAP_OBJ[obj].z) + dimension);
     lineto(M2SX(MAP_OBJ[obj].x) + dimension, M2SY(MAP_OBJ[obj].z)            );
     lineto(M2SX(MAP_OBJ[obj].x)            , M2SY(MAP_OBJ[obj].z)            );
     }
    break;
   case OBT_FRAME :
     circle(M2SX(MAP_OBJ[obj].x), M2SY(MAP_OBJ[obj].z), (int)dimension);
    break;
   case OBT_SOUND :
     moveto(M2SX(MAP_OBJ[obj].x) - dimension, M2SY(MAP_OBJ[obj].z) - dimension);
     lineto(M2SX(MAP_OBJ[obj].x)            , M2SY(MAP_OBJ[obj].z) + dimension);
     lineto(M2SX(MAP_OBJ[obj].x) + dimension, M2SY(MAP_OBJ[obj].z) - dimension);
    break;
   default:
     circle(M2SX(MAP_OBJ[obj].x), M2SY(MAP_OBJ[obj].z), (int)dimension);
  }
}

void draw_a_bigger_object(int obj, int color)
{
 float dimension;

 setcolor(color);
 dimension = 1.75 * scale;
 if(dimension > 12) dimension = 12;
 circle(M2SX(MAP_OBJ[obj].x), M2SY(MAP_OBJ[obj].z), (int)dimension);

 /* show the orientation */
 moveto(M2SX(MAP_OBJ[obj].x) + 1.5 * scale * sin(MAP_OBJ[obj].yaw/360*6.283),
        M2SY(MAP_OBJ[obj].z) - 1.5 * scale * cos(MAP_OBJ[obj].yaw/360*6.283));
 lineto(M2SX(MAP_OBJ[obj].x) + 5 * scale * sin(MAP_OBJ[obj].yaw/360*6.283),
        M2SY(MAP_OBJ[obj].z) - 5 * scale * cos(MAP_OBJ[obj].yaw/360*6.283));

}

void draw_in_ob_mode(void)
{
  register s_ix;
  register i,j;
  int      layerok;

  if(SHADOW == 1) draw_shadow();
  draw_current_layer();
  draw_specials();
  draw_line_triggers();

  for(s_ix=0; s_ix <= obj_max ; s_ix++)
   {
    layerok = 1;
    if(OBJECT_LAYERING == 1)
     if(MAP_OBJ[s_ix].sec != -1)
      if(MAP_SEC[MAP_OBJ[s_ix].sec].layer != LAYER)
       layerok = 0;

    if(MAP_OBJ[s_ix].del == 0)
     if(layerok == 1)
      if(difficulty_ok(MAP_OBJ[s_ix].diff) == TRUE)
        draw_an_object(s_ix, OBJ_NOTHILI);
   }

  if(MULTISEL != 0)
  /* redraw multiple selection */
  for(s_ix=0; s_ix <= obj_max ; s_ix++)
   {
    if(MAP_OBJ[s_ix].mark != 0)
      draw_an_object(s_ix, COLOR_MULTISEL);
   };

  /* redraw hilited OB */
  if(MAP_OBJ[OB_HILITE].mark != 0)
   draw_a_bigger_object(OB_HILITE, COLOR_MULTISEL);
  else
   if(MAP_OBJ[OB_HILITE].del == 0)
    draw_a_bigger_object(OB_HILITE, OBJ_HILITED);
   else
    draw_a_bigger_object(OB_HILITE, COLOR_DELETED);
}

int difficulty_ok(int diff)
{
  int retval;

  switch(DIFFICULTY)
   {
    case 0 : retval = TRUE;
             break;
    case 1 : if( (diff==2) || (diff == 3) )
               retval = FALSE;
             else
               retval = TRUE;
             break;
    case 2 : if( (diff==-1) || (diff == 3) )
               retval = FALSE;
             else
               retval = TRUE;
             break;
    case 3 : if( (diff==-2) || (diff == -1) )
               retval = FALSE;
             else
               retval = TRUE;
             break;
   }

  return(retval);
}

/*
        +------+------------------+
        | DIFF | EASY   MED  HARD |
        +------+------------------+
        |  -3  |   X     X     X  |
        |  -2  |   X     X        |
        |  -1  |   X              |
        |   0  |   X     X     X  |
        |   1  |   X     X     X  |
        |   2  |         X     X  |
        |   3  |               X  |
        +------+------------------+
*/
