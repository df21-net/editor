/* ========================================================================== */
/* LEVED_VX.C : VERTEX EDITOR                                                 */
/* ========================================================================== */
#include "levmap.h"
#include "levext.h"

/* ************************************************************************** */
/* VERTEX EDITOR FUNCTIONS                                                    */
/* ************************************************************************** */

#define VFIELDS      2

void show_vertex_layout(int color)
{
 setcolor(color);
 outtextxy(TITLE_BOX_X / 2 + 6 +   0, 21, "X :");
 outtextxy(TITLE_BOX_X / 2 + 6 + 104, 21, "Z :");
}

void show_all_vertex_fields(int color)
{
 int i;

 for(i=0; i<VFIELDS;i++) show_vertex_field(i, color);
}

void show_vertex_field(int fieldnum, int color)
{
 char tmpstr[40];

 setcolor(color);
 switch(fieldnum)
  {
   case  0 : sprintf(tmpstr, "% 6.2f", MAP_VRT[VX_HILITE].x);
             outtextxy(TITLE_BOX_X / 2 + 6 +  32, 21, tmpstr);
             break;
   case  1 : sprintf(tmpstr, "% 6.2f", MAP_VRT[VX_HILITE].z);
             outtextxy(TITLE_BOX_X / 2 + 6 + 136, 21, tmpstr);
             break;
  }
}

void edit_vertex_field(int fieldnum)
{
 char tmpstr[40];
 int  i;

 switch(fieldnum)
  {
   case  0 : sprintf(tmpstr, "% 6.2f", MAP_VRT[VX_HILITE].x);
             if(stredit(TITLE_BOX_X/2+6+ 32, 21, tmpstr, 8, 7, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               MAP_VRT[VX_HILITE].x = atof(tmpstr);
             SE_erase_all(TITLE_BOX_X/2+6+ 32, 21, 7, HEAD_BACK);
             if(APPLY_TO_MULTI == 1)
              {
               for(i=0; i<= vertex_max; i++)
                if(MAP_VRT[i].mark != 0)
                 MAP_VRT[i].x = MAP_VRT[VX_HILITE].x;
              }
             refresh_map_in_editor();
             break;
   case  1 : sprintf(tmpstr, "% 6.2f", MAP_VRT[VX_HILITE].z);
             if(stredit(TITLE_BOX_X/2+6+136, 21, tmpstr, 8, 7, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               MAP_VRT[VX_HILITE].z = atof(tmpstr);
             SE_erase_all(TITLE_BOX_X/2+6+136, 21, 7, HEAD_BACK);
             if(APPLY_TO_MULTI == 1)
              {
               for(i=0; i<= vertex_max; i++)
                if(MAP_VRT[i].mark != 0)
                 MAP_VRT[i].z = MAP_VRT[VX_HILITE].z;
              }
             refresh_map_in_editor();
             break;
  }
}

void edit_vertex()
{
 int current = 0;
 int key     = 0;

 setviewport(0, 0, getmaxx(), getmaxy(), 1);
 if(APPLY_TO_MULTI) show_vertex_layout(HILI_AT_ALT);

 do
 {
  show_all_vertex_fields(HEAD_FORE);
  show_vertex_field(current, HILI_AT_ALT);
  key = getVK();
  switch(key)
   {
    case VK_TAB   :
    case VK_DOWN  :
    case VK_RIGHT : current++;
                    if(current >= VFIELDS) current = 0;
                    break;
    case VK_S_TAB :
    case VK_UP    :
    case VK_LEFT  : current--;
                    if(current < 0 ) current = VFIELDS - 1;
                    break;
    case VK_ENTER :
    case VK_SPACE : edit_vertex_field(current);
                    break;
   }
 } while(key != VK_ESC);

 show_vertex_field(current, HEAD_FORE);
 setviewport(0, TITLE_BOX_Y+1, getmaxx(), getmaxy(), 1);
 MODIFIED = 1;
}
