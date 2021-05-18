/* ========================================================================== */
/* LEVDEFOR.C : DEFORMATIONS                                                  */
/*              * Translation                                                 */
/*              * Rotation                                                    */
/*              * Scaling                                                     */
/*              * Flipping (horizontal and vertical)                          */
/* ========================================================================== */

#include "levmap.h"
#include "levext.h"
#include <math.h>

#define BOX_BACK LINE_NOTALT

struct tagDEFORM
{
 float x;
 float z;
 float a;
 float s;
 int   h;
 int   v;
} OLD_DEFORM, DEFORM = {0.0, 0.0, 0.0, 1.0, 0, 0};

float DEFORM_X = 0;
float DEFORM_Z = 0;

#define DFIELDS       6
void show_deform_layout(int color)
{
 setcolor(HEAD_BORDER);
 rectangle(0,0, TITLE_BOX_X / 2 + 1, 105);
 setfillstyle(SOLID_FILL, BOX_BACK);
 floodfill(10,10, HEAD_BORDER);
 setcolor(color);
 outtextxy(  5,  5, "DEFORMATIONS [Esc] Aborts [F2] Executes");
 outtextxy(  5, 20, "Translate X:");
 outtextxy(  5, 35, "          Z:");
 outtextxy(  5, 50, "Rotate    a:");
 outtextxy(  5, 65, "Scale     s:");
 outtextxy(  5, 80, "Flip      H:");
 outtextxy(  5, 95, "          V:");
}

void show_all_deform_fields(int color)
{
 int i       = 0;

 for(i=0; i<DFIELDS;i++) show_deform_field(i, color);
}

void show_deform_field(int fieldnum, int color)
{
 char tmpstr[40];

 setcolor(color);
 switch(fieldnum)
  {
   case  0 : sprintf(tmpstr, "% 5.2f", DEFORM.x);
             outtextxy(125, 20, tmpstr);
             break;
   case  1 : sprintf(tmpstr, "% 5.2f", DEFORM.z);
             outtextxy(125, 35, tmpstr);
             break;
   case  2 : sprintf(tmpstr, "% 5.2f", DEFORM.a);
             outtextxy(125, 50, tmpstr);
             break;
   case  3 : sprintf(tmpstr, "% 10f", DEFORM.s);
             outtextxy(125, 65, tmpstr);
             break;
   case  4 : sprintf(tmpstr, "% d", DEFORM.h);
             outtextxy(125, 80, tmpstr);
             break;
   case  5 : sprintf(tmpstr, "% d", DEFORM.v);
             outtextxy(125, 95, tmpstr);
             break;
  }
}

void edit_deform_field(int fieldnum)
{

 switch(fieldnum)
  {
   case  0 : sprintf(tmpstr, "%-5.2f", DEFORM.x);
             if(stredit(125, 20, tmpstr, 7, 7, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               DEFORM.x = atof(tmpstr);
             SE_erase_all(125, 20, 7, BOX_BACK);
             break;
   case  1 : sprintf(tmpstr, "%-5.2f", DEFORM.z);
             if(stredit(125,35, tmpstr, 7, 7, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               DEFORM.z = atof(tmpstr);
             SE_erase_all(125, 35, 7, BOX_BACK);
             break;
   case  2 : sprintf(tmpstr, "%-5.2f", DEFORM.a);
             if(stredit(125,50, tmpstr, 7, 7, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               DEFORM.a = atof(tmpstr);
             SE_erase_all(125, 50, 7, BOX_BACK);
             break;
   case  3 : sprintf(tmpstr, "%-10f", DEFORM.s);
             if(stredit(125,65, tmpstr, 11, 11, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               DEFORM.s = atof(tmpstr);
             SE_erase_all(125, 65, 11, BOX_BACK);
             break;
   case  4 : sprintf(tmpstr, "%d", DEFORM.h);
             if(stredit(125,80, tmpstr, 2, 2, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               DEFORM.h = atoi(tmpstr);
             SE_erase_all(125,80, 7, BOX_BACK);
             break;
   case  5 : sprintf(tmpstr, "%d", DEFORM.v);
             if(stredit(125,95, tmpstr, 2, 2, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               DEFORM.v = atoi(tmpstr);
             SE_erase_all(125,95, 7, BOX_BACK);
             break;
  }
}

void edit_deform(void)
{
 int current = 0;
 int key     = 0;
 int i, j;
 int was_multi;
 int old_multi;

 OLD_DEFORM.x = DEFORM.x;
 OLD_DEFORM.z = DEFORM.z;
 OLD_DEFORM.a = DEFORM.a;
 OLD_DEFORM.s = DEFORM.s;
 OLD_DEFORM.h = DEFORM.h;
 OLD_DEFORM.v = DEFORM.v;

 DEFORM.x = 0.0;
 DEFORM.z = 0.0;
 DEFORM.a = 0.0;
 DEFORM.s = 1.0;
 DEFORM.h = 0;
 DEFORM.v = 0;
 show_deform_layout(HEAD_FORE);

 do
 {
  show_all_deform_fields(HEAD_FORE);
  show_deform_field(current, HILI_AT_ALT);
  key = getVK();
  switch(key)
   {
    case 'p'      :
    case 'P'      : DEFORM.x = OLD_DEFORM.x;
                    DEFORM.z = OLD_DEFORM.z;
                    DEFORM.a = OLD_DEFORM.a;
                    DEFORM.s = OLD_DEFORM.s;
                    DEFORM.h = OLD_DEFORM.h;
                    DEFORM.v = OLD_DEFORM.v;
                    show_deform_layout(HEAD_FORE);
                    break;
    case 'r'      :
    case 'R'      : DEFORM.x = -OLD_DEFORM.x;
                    DEFORM.z = -OLD_DEFORM.z;
                    DEFORM.a = -OLD_DEFORM.a;
                    DEFORM.s = 1/OLD_DEFORM.s;
                    DEFORM.h = OLD_DEFORM.h;
                    DEFORM.v = OLD_DEFORM.v;
                    show_deform_layout(HEAD_FORE);
                    break;
    case VK_TAB   :
    case VK_DOWN  :
    case VK_RIGHT : current++;
                    if(current >= DFIELDS) current = 0;
                    break;
    case VK_S_TAB :
    case VK_UP    :
    case VK_LEFT  : current--;
                    if(current < 0 ) current = DFIELDS - 1;
                    break;
    case VK_ENTER :
    case VK_SPACE : edit_deform_field(current);
                    break;
   }
 } while((key != VK_ESC) && (key != VK_F2));

 if(key == VK_F2)
  {
   /* check the mode, then convert the (multi)selection in a multiselection
      of vertices or objects (later, objects should deform same as sectors!) */

   if(MULTISEL != 0) was_multi = 1; else was_multi = 0;

   switch(MAP_MODE)
   {
    case 0: old_multi = MULTISEL;
            clear_multi_vertex();
            if(was_multi == 0) multi_sector(SC_HILITE);
            convert_multi_SC2VX_noclear();
            DEFORM_X = MAP_VRT[MAP_SEC[SC_HILITE].vrt0].x;
            DEFORM_Z = MAP_VRT[MAP_SEC[SC_HILITE].vrt0].z;
            deform_vertices();
            if(was_multi == 0) clear_multi_sector();
            clear_multi_vertex();
            MULTISEL = old_multi;
            break;
    case 1: old_multi = MULTISEL;
            clear_multi_vertex();
            if(was_multi == 0) multi_wall(WL_HILITE);
            convert_multi_WL2VX_noclear();
            DEFORM_X = MAP_VRT[MAP_WAL[WL_HILITE].left_vx].x;
            DEFORM_Z = MAP_VRT[MAP_WAL[WL_HILITE].left_vx].z;
            deform_vertices();
            if(was_multi == 0) clear_multi_wall();
            clear_multi_vertex();
            MULTISEL = old_multi;
            break;
    case 2: old_multi = MULTISEL;
            if(was_multi == 0) multi_vertex(VX_HILITE);
            DEFORM_X = MAP_VRT[VX_HILITE].x;
            DEFORM_Z = MAP_VRT[VX_HILITE].z;
            deform_vertices();
            if(was_multi == 0) clear_multi_vertex();
            MULTISEL = old_multi;
            break;
    case 3: old_multi = MULTISEL;
            if(was_multi == 0) multi_object(OB_HILITE);
            DEFORM_X = MAP_OBJ[OB_HILITE].x;
            DEFORM_Z = MAP_OBJ[OB_HILITE].z;
            deform_objects();
            if(was_multi == 0) clear_multi_object();
            MULTISEL = old_multi;
            break;
   }
   MODIFIED = 1;
  }
}

void deform_vertices(void)
{
 int i;
 int wl;
 float rad, oldx;

 /* Translate */
 if((DEFORM.x != 0.0) || (DEFORM.z != 0.0))
  {
   for(i=0; i<=vertex_max; i++)
    if(MAP_VRT[i].mark != 0)
     {
      MAP_VRT[i].x += DEFORM.x;
      MAP_VRT[i].z += DEFORM.z;
     }
   DEFORM_X += DEFORM.x;
   DEFORM_Z += DEFORM.z;
  }

 /* Scale */
 if(DEFORM.s != 1.0)
  {
   for(i=0; i<=vertex_max; i++)
    if(MAP_VRT[i].mark != 0)
     {
      MAP_VRT[i].x = DEFORM_X + (MAP_VRT[i].x - DEFORM_X) * DEFORM.s;
      MAP_VRT[i].z = DEFORM_Z + (MAP_VRT[i].z - DEFORM_Z) * DEFORM.s;
     }
  }

 /* Rotate */
 if(DEFORM.a != 0.0)
  {
   rad = DEFORM.a * 3.1415926535 / (float)180;
   for(i=0; i<=vertex_max; i++)
    if(MAP_VRT[i].mark != 0)
     {
      oldx = MAP_VRT[i].x;
      MAP_VRT[i].x = DEFORM_X +
                          (cos(rad) * (MAP_VRT[i].x - DEFORM_X)
                         - sin(rad) * (MAP_VRT[i].z - DEFORM_Z));
      MAP_VRT[i].z = DEFORM_Z +
                          (sin(rad) * (oldx         - DEFORM_X)
                         + cos(rad) * (MAP_VRT[i].z - DEFORM_Z));
     }
  }

 /* Flip Horizontal */
 if(MAP_MODE == 0)
 if(DEFORM.h != 0)
  {
   for(i=0; i<=sector_max; i++) MAP_SEC[i].reserved = 0;
   for(i=0; i<=vertex_max; i++)
    if(MAP_VRT[i].mark != 0)
     {
      MAP_VRT[i].x -= 2 * (MAP_VRT[i].x - DEFORM_X);
      MAP_SEC[MAP_VRT[i].sec].reserved = 1;
     }
   for(i=0; i<=sector_max; i++)
    if(MAP_SEC[i].reserved == 1)
     {
      invert_sector_vertices_order(i);
      MAP_SEC[i].reserved = 0;
     }
  }

 /* Flip Vertical */
 if(MAP_MODE == 0)
 if(DEFORM.v != 0)
  {
   for(i=0; i<=wall_max; i++) MAP_WAL[i].reserved = 0;
   for(i=0; i<=vertex_max; i++)
    if(MAP_VRT[i].mark != 0)
     {
      MAP_VRT[i].z -= 2 * (MAP_VRT[i].z - DEFORM_Z);
      MAP_SEC[MAP_VRT[i].sec].reserved = 1;
     }
   for(i=0; i<=sector_max; i++)
    if(MAP_SEC[i].reserved == 1)
     {
      invert_sector_vertices_order(i);
      MAP_SEC[i].reserved = 0;
     }
  }
}

void deform_objects(void)
{
 int i;
 float rad, oldx;

 /* Translate */
 if((DEFORM.x != 0.0) || (DEFORM.z != 0.0))
  {
   for(i=0; i<=obj_max; i++)
    if(MAP_OBJ[i].mark != 0)
     {
      MAP_OBJ[i].x += DEFORM.x;
      MAP_OBJ[i].z += DEFORM.z;
     }
   DEFORM_X += DEFORM.x;
   DEFORM_Z += DEFORM.z;
  }

 /* Scale */
 if(DEFORM.s != 1.0)
  {
   for(i=0; i<=obj_max; i++)
    if(MAP_OBJ[i].mark != 0)
     {
      MAP_OBJ[i].x = DEFORM_X + (MAP_OBJ[i].x - DEFORM_X) * DEFORM.s;
      MAP_OBJ[i].z = DEFORM_Z + (MAP_OBJ[i].z - DEFORM_Z) * DEFORM.s;
     }
  }

 /* Rotate */
 if(DEFORM.a != 0.0)
  {
   rad = DEFORM.a * 3.1415926535 / (float)180;
   for(i=0; i<=obj_max; i++)
    if(MAP_OBJ[i].mark != 0)
     {
      oldx = MAP_OBJ[i].x;
      MAP_OBJ[i].x = DEFORM_X +
                          (cos(rad) * (MAP_OBJ[i].x - DEFORM_X)
                         - sin(rad) * (MAP_OBJ[i].z - DEFORM_Z));
      MAP_OBJ[i].z = DEFORM_Z +
                          (sin(rad) * (oldx         - DEFORM_X)
                         + cos(rad) * (MAP_OBJ[i].z - DEFORM_Z));
     }
  }

 /* Flip Horizontal */
 if(DEFORM.h != 0)
  {
   for(i=0; i<=obj_max; i++)
    if(MAP_OBJ[i].mark != 0)
     {
      MAP_OBJ[i].x -= 2 * (MAP_OBJ[i].x - DEFORM_X);
     }
  }

 /* Flip Vertical */
 if(DEFORM.v != 0)
  {
   for(i=0; i<=obj_max; i++)
    if(MAP_OBJ[i].mark != 0)
     {
      MAP_OBJ[i].z -= 2 * (MAP_OBJ[i].z - DEFORM_Z);
     }
  }
}

void convert_multi_SC2VX_noclear(void)
{
 int i,v;

 MULTISEL=0;
 for(i=0; i<=sector_max; i++)
  if(MAP_SEC[i].mark != 0)
   {
    for(v=0; v<MAP_SEC[i].vno; v++)
     multi_vertex(GetSectorVX(i,v));
   }
}

void convert_multi_WL2VX_noclear(void)
{
 int i,v;

 MULTISEL=0;
 for(i=0; i<=wall_max; i++)
  if(MAP_WAL[i].mark != 0)
   {
    if(MAP_VRT[GetAbsoluteVXFfromWL(i)].mark == 0)
     {
      MULTISEL++;
      MAP_VRT[GetAbsoluteVXFfromWL(i)].mark = MULTISEL;
     }

    if(MAP_VRT[GetAbsoluteVXTfromWL(i)].mark == 0)
     {
      MULTISEL++;
      MAP_VRT[GetAbsoluteVXTfromWL(i)].mark = MULTISEL;
     }
   }
}

void invert_sector_vertices_order(int num)
{
 int i;
 int wl;
 int getout = 0;
 int start, end;
 int startbis;
 MAP_VRTtype vx;
 char tmp[127];

 wl    = MAP_SEC[num].wno -1;

 while(getout == 0)
  {
   start = MAP_WAL[GetSectorWL(num,wl)].right_vx;
   end   = MAP_WAL[GetSectorWL(num,wl)].left_vx;

   sprintf(tmp, "echo start : %d end : %d >> test.tst", start, end);
   system(tmp);

   for(i=start; i < start + (end-start)/2 + (end-start) % 2; i++)
    {
     vx = MAP_VRT[GetSectorVX(num, i)];
     MAP_VRT[GetSectorVX(num, i)] = MAP_VRT[GetSectorVX(num, end - i)];
     MAP_VRT[GetSectorVX(num, end - i)] = vx;
    }

   if(wl>0)
   while((getout==0) &&
         (
          (MAP_WAL[wl].left_vx >= start) &&
          (MAP_WAL[wl].left_vx  <= end)
         )
        )
    {
      sprintf(tmp, "echo wl : %d >> test.tst", wl);
      system(tmp);
      wl--;
      if(wl==0) getout=1;
    }

  }

}

/*
void invert_sector_vertices_order(int num)
{
 int i;
 MAP_VRTtype vx;

 for(i=0; i<MAP_SEC[num].vno / 2; i++)
  {
   vx = MAP_VRT[GetSectorVX(num, i)];
   MAP_VRT[GetSectorVX(num, i)] = MAP_VRT[GetSectorVX(num, MAP_SEC[num].vno - 1 - i)];
   MAP_VRT[GetSectorVX(num, MAP_SEC[num].vno - 1 - i)] = vx;
  }
}
*/
