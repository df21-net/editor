/* ========================================================================== */
/* LEV_NGON.C : POLYGON CONSTRUCTION                                          */
/* ========================================================================== */

#include "levmap.h"
#include "levext.h"
#include <math.h>

#define BOX_BACK LINE_NOTALT

struct tagNGON
{
 float x;
 float z;
 float r;
 int   s;
} OLD_NGON, NGON = {0.0, 0.0, 16.0, 4};

#define NFIELDS       4
void show_ngon_layout(int color)
{
 setcolor(HEAD_BORDER);
 rectangle(0,0, TITLE_BOX_X / 2 + 1, 75);
 setfillstyle(SOLID_FILL, BOX_BACK);
 floodfill(10,10, HEAD_BORDER);
 setcolor(color);
 outtextxy(  5,  5, "POLYGON     [Esc] Aborts [F2] Executes");
 outtextxy(  5, 20, "Center    X:");
 outtextxy(  5, 35, "          Z:");
 outtextxy(  5, 50, "Radius    r:");
 outtextxy(  5, 65, "Sides     s:");
}

void show_all_ngon_fields(int color)
{
 int i       = 0;

 for(i=0; i<NFIELDS;i++) show_ngon_field(i, color);
}

void show_ngon_field(int fieldnum, int color)
{
 char tmpstr[40];

 setcolor(color);
 switch(fieldnum)
  {
   case  0 : sprintf(tmpstr, "%+5.2f", NGON.x);
             outtextxy(125, 20, tmpstr);
             break;
   case  1 : sprintf(tmpstr, "%+5.2f", NGON.z);
             outtextxy(125, 35, tmpstr);
             break;
   case  2 : sprintf(tmpstr, "%-5.2f", NGON.r);
             outtextxy(125, 50, tmpstr);
             break;
   case  3 : sprintf(tmpstr, "%d", NGON.s);
             outtextxy(125, 65, tmpstr);
             break;
  }
}

void edit_ngon_field(int fieldnum)
{

 switch(fieldnum)
  {
   case  0 : sprintf(tmpstr, "%+5.2f", NGON.x);
             if(stredit(125, 20, tmpstr, 7, 7, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               NGON.x = atof(tmpstr);
             SE_erase_all(125, 20, 7, BOX_BACK);
             break;
   case  1 : sprintf(tmpstr, "%+5.2f", NGON.z);
             if(stredit(125,35, tmpstr, 7, 7, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               NGON.z = atof(tmpstr);
             SE_erase_all(125, 35, 7, BOX_BACK);
             break;
   case  2 : sprintf(tmpstr, "%-5.2f", NGON.r);
             if(stredit(125,50, tmpstr, 7, 7, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               NGON.r = atof(tmpstr);
             SE_erase_all(125, 50, 7, BOX_BACK);
             break;
   case  3 : sprintf(tmpstr, "%d", NGON.s);
             if(stredit(125,65, tmpstr, 7, 7, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               NGON.s = atoi(tmpstr);
             SE_erase_all(125, 65, 7, BOX_BACK);
             break;
  }
}

void edit_ngon(void)
{
 int current = 0;
 int key     = 0;
 int i, j;
 int was_multi;
 int old_multi;

 OLD_NGON.x = NGON.x;
 OLD_NGON.z = NGON.z;
 OLD_NGON.r = NGON.r;
 OLD_NGON.s = NGON.s;

 if(GRID == 0)
  {
   NGON.x = MAP_MOUSE_X;
   NGON.z = MAP_MOUSE_Z;
  }
 else
  {
   NGON.x = MAP_MOUSE_GX;
   NGON.z = MAP_MOUSE_GZ;
  }

 NGON.r = 16.0;
 NGON.s = 4;

 show_ngon_layout(HEAD_FORE);

 do
 {
  show_all_ngon_fields(HEAD_FORE);
  show_ngon_field(current, HILI_AT_ALT);
  key = getVK();
  switch(key)
   {
    case 'p'      :
    case 'P'      : NGON.x = OLD_NGON.x;
                    NGON.z = OLD_NGON.z;
                    NGON.r = OLD_NGON.r;
                    NGON.s = OLD_NGON.s;
                    show_ngon_layout(HEAD_FORE);
                    break;
    case VK_TAB   :
    case VK_DOWN  :
    case VK_RIGHT : current++;
                    if(current >= NFIELDS) current = 0;
                    break;
    case VK_S_TAB :
    case VK_UP    :
    case VK_LEFT  : current--;
                    if(current < 0 ) current = NFIELDS - 1;
                    break;
    case VK_ENTER :
    case VK_SPACE : edit_ngon_field(current);
                    break;
   }
 } while((key != VK_ESC) && (key != VK_F2));

 if(key == VK_F2)
  {
   if(NGON.s > 2)
    {
     handle_title(COLOR_ERASER);
     if(NGON_GAP == 0)
       construct_ngon();
     else
       construct_ngon_gap();
    }
  }
}

void construct_ngon(void)
{
 int i;
 int old_wal0;
 double alpha, delta;

 get_sector_info(SC_HILITE);

 if(sector_max + 1 < sector_alloc - 1)
  {
   if((wall_max + NGON.s < wall_alloc - 1) && (vertex_max + NGON.s < vertex_alloc - 1))
    {
     old_wal0 = MAP_SEC[SC_HILITE].wal0;

     sector_max++;
     MAP_SEC[sector_max] = MAP_SEC[SC_HILITE];
     SC_HILITE = sector_max;

     MAP_SEC[SC_HILITE].del    = 0;
     MAP_SEC[SC_HILITE].mark   = 0;

     MAP_SEC[SC_HILITE].vno    = NGON.s;
     MAP_SEC[SC_HILITE].wno    = NGON.s;

     MAP_SEC[SC_HILITE].elev   = 0;
     MAP_SEC[SC_HILITE].trig   = 0;
     MAP_SEC[SC_HILITE].secret = 0;
     MAP_SEC[SC_HILITE].reserved = 0;
     strcpy(swpSEC.name, "");
     swpSEC.flag1 &= ~2;
     swpSEC.flag1 &= ~64;
     swpSEC.flag1 &= ~524288;
     MAP_SEC[SC_HILITE].vrt0 = vertex_max+1;
     MAP_SEC[SC_HILITE].wal0 = wall_max+1;

     vertex_max += NGON.s;
     wall_max   += NGON.s;

     alpha = 0;
     delta = 2 * M_PI / NGON.s;

     for(i=0; i<MAP_SEC[SC_HILITE].vno; i++)
      {
       MAP_VRT[MAP_SEC[SC_HILITE].vrt0 + i].x     = NGON.x + floor(NGON.r * cos(alpha) * 10000) / 10000;
       MAP_VRT[MAP_SEC[SC_HILITE].vrt0 + i].z     = NGON.z + floor(NGON.r * sin(alpha) * 10000) / 10000;
       MAP_VRT[MAP_SEC[SC_HILITE].vrt0 + i].sec   = SC_HILITE;
       MAP_VRT[MAP_SEC[SC_HILITE].vrt0 + i].mark  = 0;
       alpha -= delta;
      }

     for(i=0; i<MAP_SEC[SC_HILITE].wno; i++)
      {
       MAP_WAL[MAP_SEC[SC_HILITE].wal0 + i] = MAP_WAL[old_wal0 + 1];

       MAP_WAL[MAP_SEC[SC_HILITE].wal0 + i].left_vx  = i;
       MAP_WAL[MAP_SEC[SC_HILITE].wal0 + i].right_vx = i + 1;
       if(MAP_WAL[MAP_SEC[SC_HILITE].wal0 + i].right_vx == NGON.s)
        MAP_WAL[MAP_SEC[SC_HILITE].wal0 + i].right_vx = 0;

       MAP_WAL[MAP_SEC[SC_HILITE].wal0 + i].sec      = SC_HILITE;
       MAP_WAL[MAP_SEC[SC_HILITE].wal0 + i].mark     = 0;
       MAP_WAL[MAP_SEC[SC_HILITE].wal0 + i].trig     = 0;
       MAP_WAL[MAP_SEC[SC_HILITE].wal0 + i].reserved = 0;
       /* Remove the adjoins */
       MAP_WAL[MAP_SEC[SC_HILITE].wal0 + i].adjoin   = -1;
       MAP_WAL[MAP_SEC[SC_HILITE].wal0 + i].mirror   = -1;
       MAP_WAL[MAP_SEC[SC_HILITE].wal0 + i].walk     = -1;
       get_wall_info(old_wal0 + 1);
       /* Reinitialize */
       swpWAL.mid_tx_f1   = 0.0;
       swpWAL.mid_tx_f2   = 0.0;
       swpWAL.top_tx_f1   = 0.0;
       swpWAL.top_tx_f2   = 0.0;
       swpWAL.bot_tx_f1   = 0.0;
       swpWAL.bot_tx_f2   = 0.0;
       swpWAL.sign        = -1;
       swpWAL.sign_f1     = 0.0;
       swpWAL.sign_f2     = 0.0;
       swpWAL.flag1       = 0;
       swpWAL.flag2       = 0;
       swpWAL.flag3       = 0;
       swpWAL.light       = 0;
       strcpy(swpWAL.trigger_name, "");
       strcpy(swpWAL.client_name,  "");

       lseek(fwal, 0, SEEK_END);
       write(fwal, &swpWAL, sizeof(swpWAL));
      }

     lseek(fsec, 0, SEEK_END);
     write(fsec, &swpSEC, sizeof(swpSEC));
     MODIFIED = 1;
    }
   else
    {
     message_out_of_vxwl();
    }
   }
 else
  {
   message_out_of_sectors();
  }
}

void construct_ngon_gap(void)
{
 int i;
 int old_vrt0;
 int old_wal0;
 int old_wno;
 int old_vno;
 double alpha, delta;
 char tmp[127];

 if((wall_max + NGON.s < wall_alloc - 1) && (vertex_max + NGON.s < vertex_alloc - 1))
  {
   old_vrt0 = MAP_SEC[SC_HILITE].vrt0;
   old_wal0 = MAP_SEC[SC_HILITE].wal0;
   old_vno  = MAP_SEC[SC_HILITE].vno;
   old_wno  = MAP_SEC[SC_HILITE].wno;

   MAP_SEC[SC_HILITE].vno   += NGON.s;
   MAP_SEC[SC_HILITE].wno   += NGON.s;

   vertex_max               += NGON.s;
   wall_max                 += NGON.s;

   /* move up the vertices */
   for(i=vertex_max; i >= old_vrt0 + old_vno + NGON.s; i--)
   {
    MAP_VRT[i] = MAP_VRT[i-NGON.s];
   }

   /* note : the vertices are created in the opposite sens when compared
             to construct_ngon
   */
   alpha = 0.0;
   delta = 2 * M_PI / NGON.s;

   for(i=0; i<NGON.s; i++)
    {
     MAP_VRT[old_vrt0 + old_vno + i].x     = NGON.x + floor(NGON.r * cos(alpha) * 10000) / 10000;
     MAP_VRT[old_vrt0 + old_vno + i].z     = NGON.z + floor(NGON.r * sin(alpha) * 10000) / 10000;
     MAP_VRT[old_vrt0 + old_vno + i].sec   = SC_HILITE;
     MAP_VRT[old_vrt0 + old_vno + i].mark  = 0;
     alpha += delta;
    }

   /* make room for NGON.s walls */
   for(i=0; i<NGON.s; i++)
   {
     lseek(fwal, 0, SEEK_END);
     write(fwal, &swpWAL, sizeof(swpWAL));
   }

   /* move up the walls */
   for(i=wall_max; i >= old_wal0 + old_wno + NGON.s; i--)
   {
    MAP_WAL[i] = MAP_WAL[i-NGON.s];
    get_wall_info(i-NGON.s);
    set_wall_info(i);
   }

   /* relink the vx and wall pos to the sectors */
   for(i=SC_HILITE+1; i<=sector_max; i++)
    {
     MAP_SEC[i].vrt0 += NGON.s;
     MAP_SEC[i].wal0 += NGON.s;
    }

   for(i=0; i<NGON.s; i++)
    {
     MAP_WAL[old_wal0 + old_wno + i]          = MAP_WAL[old_wal0 + 1];

     MAP_WAL[old_wal0 + old_wno + i].left_vx  = old_vno + i;
     MAP_WAL[old_wal0 + old_wno + i].right_vx = old_vno + i + 1;
     if(MAP_WAL[old_wal0 + old_wno + i].right_vx == old_vno + NGON.s)
        MAP_WAL[old_wal0 + old_wno + i].right_vx = old_vno;

     MAP_WAL[old_wal0 + old_wno + i].sec      = SC_HILITE;
     MAP_WAL[old_wal0 + old_wno + i].mark     = 0;
     MAP_WAL[old_wal0 + old_wno + i].trig     = 0;
     MAP_WAL[old_wal0 + old_wno + i].reserved = 0;
     MAP_WAL[old_wal0 + old_wno + i].adjoin   = -1;
     MAP_WAL[old_wal0 + old_wno + i].mirror   = -1;
     MAP_WAL[old_wal0 + old_wno + i].walk     = -1;
     get_wall_info(old_wal0 + 1);
       swpWAL.mid_tx_f1   = 0.0;
       swpWAL.mid_tx_f2   = 0.0;
       swpWAL.top_tx_f1   = 0.0;
       swpWAL.top_tx_f2   = 0.0;
       swpWAL.bot_tx_f1   = 0.0;
       swpWAL.bot_tx_f2   = 0.0;
       swpWAL.sign        = -1;
       swpWAL.sign_f1     = 0.0;
       swpWAL.sign_f2     = 0.0;
       swpWAL.flag1       = 0;
       swpWAL.flag2       = 0;
       swpWAL.flag3       = 0;
       swpWAL.light       = 0;
       strcpy(swpWAL.trigger_name, "");
       strcpy(swpWAL.client_name,  "");
     set_wall_info(old_wal0 + old_wno + i);
    }
   MODIFIED = 1;
  }
 else
  {
   message_out_of_vxwl();
  }
}
