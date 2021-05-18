/* ========================================================================== */
/* LEVMULTI.C : MULTIPLE SELECTION HANDLING                                   */
/*                + TEXTURES STITCHING                                        */
/* ========================================================================== */
#include "levmap.h"
#include "levext.h"

/* ************************************************************************** */
/* ADD/REMOVE OBJECTS TO MULTISELECTION                                       */
/* ************************************************************************** */

void multi_sector(int num)
{
 if(MAP_SEC[num].mark == 0)
  {
   MULTISEL++;
   MAP_SEC[num].mark = MULTISEL;
  }
 else
  {
   MAP_SEC[num].mark = 0;
   MULTISEL--;
  }
}

void multi_wall(int num)
{
 if(MAP_WAL[num].mark == 0)
  {
   MULTISEL++;
   MAP_WAL[num].mark = MULTISEL;
  }
 else
  {
   MAP_WAL[num].mark = 0;
   MULTISEL--;
  }
}

void multi_vertex(int num)
{
 if(MAP_VRT[num].mark == 0)
  {
   MULTISEL++;
   MAP_VRT[num].mark = MULTISEL;
  }
 else
  {
   MAP_VRT[num].mark = 0;
   MULTISEL--;
  }
}

void multi_object(int num)
{
 if(MAP_OBJ[num].mark == 0)
  {
   MULTISEL++;
   MAP_OBJ[num].mark = MULTISEL;
  }
 else
  {
   MAP_OBJ[num].mark = 0;
   MULTISEL--;
  }
}

void clear_multi_sector(void)
{
 int i;
 for(i=0; i<=sector_max; i++) MAP_SEC[i].mark = 0;
 MULTISEL = 0;
}

void clear_multi_wall(void)
{
 int i;
 for(i=0; i<=wall_max; i++)   MAP_WAL[i].mark = 0;
 MULTISEL = 0;
}

void clear_multi_vertex(void)
{
 int i;
 for(i=0; i<=vertex_max; i++) MAP_VRT[i].mark = 0;
 MULTISEL = 0;
}

void clear_multi_object(void)
{
 int i;
 for(i=0; i<=obj_max; i++)    MAP_OBJ[i].mark = 0;
 MULTISEL = 0;
}

void convert_multi_SC2WL(void)
{
 int i,w;

 MULTISEL=0;
 for(i=0; i<=sector_max; i++)
  if(MAP_SEC[i].mark != 0)
   {
    for(w=0; w<MAP_SEC[i].wno; w++)
     multi_wall(GetSectorWL(i,w));
    MAP_SEC[i].mark = 0;
   }
}

void convert_multi_SC2VX(void)
{
 int i,v;

 MULTISEL=0;
 for(i=0; i<=sector_max; i++)
  if(MAP_SEC[i].mark != 0)
   {
    for(v=0; v<MAP_SEC[i].vno; v++)
     multi_vertex(GetSectorVX(i,v));
    MAP_SEC[i].mark = 0;
   }
}

/* !! cannot use multi_vertex, because vertices are normally used by 2 WLs
      so they would be selected then unselected !!
*/
void convert_multi_WL2VX(void)
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
    MAP_WAL[i].mark = 0;
   }
}


int find_multisel_SC(int num)
{
 int i;

 for(i=0; i<=sector_max; i++)
  if(MAP_SEC[i].mark == num)
    return(i);
 return(0);
}

int find_multisel_OB(int num)
{
 int i;

 for(i=0; i<=obj_max; i++)
  if(MAP_OBJ[i].mark == num)
    return(i);
 return(0);
}

int find_multisel_WL(int num)
{
 int i;

 for(i=0; i<=wall_max; i++)
  if(MAP_WAL[i].mark == num)
    return(i);
 return(0);
}

/* ************************************************************************** */
/* TEXTURE STITCHING                                                          */
/* ************************************************************************** */

void stitch_horizontal_MID(void)
{
 float xofs;
 int wall;
 int i;

 if(MULTISEL > 1)
  {
   wall = find_multisel_WL(1);
   get_wall_info(wall);
   xofs      = swpWAL.mid_tx_f1 + GetWLlen(wall);
   for(i=2; i<= MULTISEL; i++)
    {
     wall = find_multisel_WL(i);
     get_wall_info(wall);
     swpWAL.mid_tx_f1 = xofs;
     set_wall_info(wall);
     xofs += GetWLlen(wall);
    }
   MODIFIED = 1;
  }
}

void stitch_horizontal_TOP(void)
{
 float xofs;
 int wall;
 int i;

 if(MULTISEL > 1)
  {
   wall = find_multisel_WL(1);
   get_wall_info(wall);
   xofs      = swpWAL.top_tx_f1 + GetWLlen(wall);
   for(i=2; i<= MULTISEL; i++)
    {
     wall = find_multisel_WL(i);
     get_wall_info(wall);
     swpWAL.top_tx_f1 = xofs;
     set_wall_info(wall);
     xofs += GetWLlen(wall);
    }
   MODIFIED = 1;
  }
}

void stitch_horizontal_BOT(void)
{
 float xofs;
 int wall;
 int i;

 if(MULTISEL > 1)
  {
   wall = find_multisel_WL(1);
   get_wall_info(wall);
   xofs      = swpWAL.bot_tx_f1 + GetWLlen(wall);
   for(i=2; i<= MULTISEL; i++)
    {
     wall = find_multisel_WL(i);
     get_wall_info(wall);
     swpWAL.bot_tx_f1 = xofs;
     set_wall_info(wall);
     xofs += GetWLlen(wall);
    }
   MODIFIED = 1;
  }
}

void stitch_horizontal_inv_MID(void)
{
 float xofs;
 int wall;
 int i;

 if(MULTISEL > 1)
  {
   wall = find_multisel_WL(MULTISEL);
   get_wall_info(wall);
   xofs      = swpWAL.mid_tx_f1;
   for(i=MULTISEL-1; i>0; i--)
    {
     wall = find_multisel_WL(i);
     xofs -= GetWLlen(wall);
     get_wall_info(wall);
     swpWAL.mid_tx_f1 = xofs;
     set_wall_info(wall);
    }
   MODIFIED = 1;
  }
}

void stitch_horizontal_inv_TOP(void)
{
 float xofs;
 int wall;
 int i;

 if(MULTISEL > 1)
  {
   wall = find_multisel_WL(MULTISEL);
   get_wall_info(wall);
   xofs      = swpWAL.top_tx_f1;
   for(i=MULTISEL-1; i>0; i--)
    {
     wall = find_multisel_WL(i);
     xofs -= GetWLlen(wall);
     get_wall_info(wall);
     swpWAL.top_tx_f1 = xofs;
     set_wall_info(wall);
    }
   MODIFIED = 1;
  }
}

void stitch_horizontal_inv_BOT(void)
{
 float xofs;
 int wall;
 int i;

 if(MULTISEL > 1)
  {
   wall = find_multisel_WL(MULTISEL);
   get_wall_info(wall);
   xofs      = swpWAL.bot_tx_f1;
   for(i=MULTISEL-1; i>0; i--)
    {
     wall = find_multisel_WL(i);
     xofs -= GetWLlen(wall);
     get_wall_info(wall);
     swpWAL.bot_tx_f1 = xofs;
     set_wall_info(wall);
    }
   MODIFIED = 1;
  }
}

void stitch_vertical_MID(void)
{
 float yofs;
 float oldfloor;
 int wall;
 int i;

 if(MULTISEL > 1)
  {
   wall = find_multisel_WL(1);
   get_wall_info(wall);
   oldfloor  = MAP_SEC[MAP_WAL[wall].sec].floor_alt;
   yofs      = swpWAL.mid_tx_f2;
   for(i=2; i<= MULTISEL; i++)
    {
     wall = find_multisel_WL(i);
     get_wall_info(wall);
     swpWAL.mid_tx_f2 = yofs - MAP_SEC[MAP_WAL[wall].sec].floor_alt + oldfloor;
     set_wall_info(wall);
    }
   MODIFIED = 1;
  }
}


void stitch_vertical_TOP(void)
{
 float yofs;
 float oldfloor;
 int wall;
 int i;

 if(MULTISEL > 1)
  {
   wall = find_multisel_WL(1);
   get_wall_info(wall);
   oldfloor  = MAP_SEC[MAP_WAL[wall].sec].floor_alt;
   yofs      = swpWAL.top_tx_f2;
   for(i=2; i<= MULTISEL; i++)
    {
     wall = find_multisel_WL(i);
     get_sector_info(MAP_WAL[wall].sec);
     swpWAL.top_tx_f2 = yofs - MAP_SEC[MAP_WAL[wall].sec].floor_alt + oldfloor;
     set_wall_info(wall);
    }
   MODIFIED = 1;
  }
}

void stitch_vertical_BOT(void)
{
 float yofs;
 float oldfloor;
 int wall;
 int i;

 if(MULTISEL > 1)
  {
   wall = find_multisel_WL(1);
   get_wall_info(wall);
   oldfloor  = MAP_SEC[MAP_WAL[wall].sec].floor_alt;
   yofs      = swpWAL.bot_tx_f2;
   for(i=2; i<= MULTISEL; i++)
    {
     wall = find_multisel_WL(i);
     get_wall_info(wall);
     swpWAL.bot_tx_f2 = yofs - MAP_SEC[MAP_WAL[wall].sec].floor_alt + oldfloor;
     set_wall_info(wall);
    }
   MODIFIED = 1;
  }
}


void distribute_floor_alt(void)
{
 float floor1;
 float floor2;
 int sec;
 int i;

 if(MULTISEL > 1)
  {
   sec = find_multisel_SC(1);
   floor1  = MAP_SEC[sec].floor_alt;
   sec = find_multisel_SC(MULTISEL);
   floor2  = MAP_SEC[sec].floor_alt;

   for(i=2; i< MULTISEL; i++)
    {
     sec = find_multisel_SC(i);
     MAP_SEC[sec].floor_alt = floor1 + (floor2 - floor1)*(i-1)/(MULTISEL-1);
    }
   MODIFIED = 1;
  }
}

void distribute_ceili_alt(void)
{
 float ceili1;
 float ceili2;
 int sec;
 int i;

 if(MULTISEL > 1)
  {
   sec = find_multisel_SC(1);
   ceili1  = MAP_SEC[sec].ceili_alt;
   sec = find_multisel_SC(MULTISEL);
   ceili2  = MAP_SEC[sec].ceili_alt;

   for(i=2; i< MULTISEL; i++)
    {
     sec = find_multisel_SC(i);
     MAP_SEC[sec].ceili_alt = ceili1 + (ceili2 - ceili1)*(i-1)/(MULTISEL-1);
    }
   MODIFIED = 1;
  }
}

void distribute_light(void)
{
 int light1;
 int light2;
 int sec;
 int i;

 if(MULTISEL > 1)
  {
   sec = find_multisel_SC(1);
   get_sector_info(sec);
   light1  = swpSEC.ambient;
   sec = find_multisel_SC(MULTISEL);
   get_sector_info(sec);
   light2  = swpSEC.ambient;

   for(i=2; i< MULTISEL; i++)
    {
     sec = find_multisel_SC(i);
     get_sector_info(sec);
     swpSEC.ambient = light1 + (int)((float)(light2 - light1)*(float)(i-1)/(float)(MULTISEL-1));
     set_sector_info(sec);
    }
   MODIFIED = 1;
  }
}

