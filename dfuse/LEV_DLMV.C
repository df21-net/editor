/* ========================================================================== */
/* LEV_DLMV.C : MAP DELETION AND MOVE FUNCTIONS                               */
/*              * Deletion & undeletion                                       */
/*              * Deletion & undeletion with multiple selection               */
/*              * Object moving                                               */
/*              * Object moving with multiple selection                       */
/* ========================================================================== */

#include "levmap.h"
#include "levext.h"

/* ************************************************************************** */
/* DELETION and UNDELETION FUNCTIONS                                          */
/* ************************************************************************** */

void delete_sector(int num)
{
 int i;

 MAP_SEC[num].del = 1;
 MODIFIED = 1;
}

void undelete_sector(int num)
{
 int i;

 MAP_SEC[num].del = 0;
 MODIFIED = 1;
}

void DeleteVX(int sector, int num)
{
 int wl;
 int vx;
 int i;

 vx = MAP_SEC[sector].vrt0 + num;
 for(i = vx; i < vertex_max; i++)
  MAP_VRT[i] = MAP_VRT[i+1];
 vertex_max--;
 for(i = sector + 1; i <= sector_max; i++) MAP_SEC[i].vrt0--;
 MAP_SEC[sector].vno--;

 for(i=0; i<MAP_SEC[sector].wno; i++)
  {
   wl = GetSectorWL(sector, i);
   if(MAP_WAL[wl].left_vx  >=  num)  MAP_WAL[wl].left_vx--;
   if(MAP_WAL[wl].left_vx  == -1)    MAP_WAL[wl].left_vx = MAP_SEC[sector].vno-1;
   if(MAP_WAL[wl].right_vx >=  num)  MAP_WAL[wl].right_vx--;
  }
}

void DeleteWL(int sector, int num)
{
 int i;
 int wl;
 int adjoin,mirror;
 long the_size;

 wl = MAP_SEC[sector].wal0 + num;

 /* move up the others */
 for(i = wl; i < wall_max; i++)  MAP_WAL[i] = MAP_WAL[i+1];
 for(i = sector + 1; i <= sector_max; i++) MAP_SEC[i].wal0--;

 /* UPDATE THE swp file */
 for(i = wl; i < wall_max; i++)
  {
   get_wall_info(i+1);
   set_wall_info(i);
  }

 /* DONT FORGET TO TRUNCATE THE LAST ELEMENT OF swpWAL file */
 chsize(fwal, filelength(fwal) - sizeof(swpWAL));

 wall_max--;
 MAP_SEC[sector].wno--;

 /* finished; now update the adjoins of the modified walls */
 for(i=0; i<MAP_SEC[sector].wno; i++)
  {
   if(MAP_WAL[MAP_SEC[sector].wal0 + i].adjoin != -1)
    {
     adjoin = MAP_WAL[MAP_SEC[sector].wal0 + i].adjoin;
     mirror = MAP_WAL[MAP_SEC[sector].wal0 + i].mirror;
     MAP_WAL[GetSectorWL(adjoin,mirror)].mirror = i;
    }
  }
}

void delete_wall(int num)
{
 int sector;
 int vxa;
 int vx;
 int wl1;

 sector = MAP_WAL[num].sec;
 vxa    = GetAbsoluteVXTfromWL(num);
 vx     = GetRelativeVXfromAbsoluteVX(vxa);
 wl1    = GetRelativeWLfromAbsoluteWL(num);

 DeleteVX(sector, vx);
 DeleteWL(sector, wl1);

 MODIFIED = 1;
}

void delete_object(int num)
{
 MAP_OBJ[num].del = 1;
 MODIFIED = 1;
}

void undelete_object(int num)
{
 MAP_OBJ[num].del = 0;
 MODIFIED = 1;
}

/* ************************************************************************** */
/* DELETION and UNDELETION FUNCTIONS WITH MULTIPLE SELECTION                  */
/* ************************************************************************** */

void delete_multi_sector(void)
{
 int i;

 for(i=0; i<=sector_max; i++)
  if(MAP_SEC[i].mark != 0)
    MAP_SEC[i].del = 1;
 MODIFIED = 1;
}

void undelete_multi_sector(void)
{
 int i;

 for(i=0; i<=sector_max; i++)
  if(MAP_SEC[i].mark != 0)
   MAP_SEC[i].del = 0;
 MODIFIED = 1;
}

void delete_multi_object(void)
{
 int i;

 for(i=0; i<=obj_max; i++) if(MAP_OBJ[i].mark != 0) MAP_OBJ[i].del = 1;
 MODIFIED = 1;
}

void undelete_multi_object(void)
{
 int i;

 for(i=0; i<=obj_max; i++) if(MAP_OBJ[i].mark != 0) MAP_OBJ[i].del = 0;
 MODIFIED = 1;
}


/* ************************************************************************** */
/* OBJECT MOVING FUNCTIONS                                                    */
/* ************************************************************************** */

/* x and z are the mouse position 'after'           */
/* the reference vertex is vrt0                     */
/* All the mirror walls in adjoin SC are also moved */
void move_sector(int num, float x, float z)
{
 float xofs, zofs;
 int   i;
 int   wl;
 int   l,r;

 xofs = x - MAP_VRT[MAP_SEC[num].vrt0].x;
 zofs = z - MAP_VRT[MAP_SEC[num].vrt0].z;

 for(i=0; i<MAP_SEC[num].vno; i++)
  {
   MAP_VRT[MAP_SEC[num].vrt0+i].x += xofs;
   MAP_VRT[MAP_SEC[num].vrt0+i].z += zofs;
  }

 /* got a problem here if the vertices are moved twice       */
 /* ie if we move 1 wall ok, but if we move 2 consecutive    */
 /* walls the middle vx is moved twice !!                    */
 /* so, we will use the mark property to test if they have   */
 /* already moved (mark is reserved for multisel, but we are */
 /* sure to be in SC mode, and use VX marks                  */

 for(i=0; i<=vertex_max; i++) MAP_VRT[i].mark = 0;

 for(i=0; i<MAP_SEC[num].wno; i++)
  {
   if(MAP_WAL[MAP_SEC[num].wal0+i].adjoin != -1)
    {
     wl = GetSectorWL(MAP_WAL[MAP_SEC[num].wal0+i].adjoin,MAP_WAL[MAP_SEC[num].wal0+i].mirror);
     l  = GetSectorVX(MAP_WAL[MAP_SEC[num].wal0+i].adjoin,MAP_WAL[wl].left_vx);
     r  = GetSectorVX(MAP_WAL[MAP_SEC[num].wal0+i].adjoin,MAP_WAL[wl].right_vx);
     if(MAP_VRT[l].mark == 0)
      {
       MAP_VRT[l].x += xofs;
       MAP_VRT[l].z += zofs;
       MAP_VRT[l].mark = 1;
      }
     if(MAP_VRT[r].mark == 0)
      {
       MAP_VRT[r].x += xofs;
       MAP_VRT[r].z += zofs;
       MAP_VRT[r].mark = 1;
      }
    }
  }

 for(i=0; i<=vertex_max; i++) MAP_VRT[i].mark = 0;
 MODIFIED = 1;
}


/* x and z are the mouse position 'after'           */
/* the reference vertex is left_vx                  */
/* The mirror wall in adjoin SC is also moved       */
void move_wall(int num, float x, float z)
{
 float xofs, zofs;
 int   i;
 int   wl;
 int   l,r;

 l    = GetAbsoluteVXFfromWL(num);
 r    = GetAbsoluteVXTfromWL(num);
 xofs = x - MAP_VRT[l].x;
 zofs = z - MAP_VRT[l].z;

 MAP_VRT[l].x += xofs;
 MAP_VRT[l].z += zofs;
 MAP_VRT[r].x += xofs;
 MAP_VRT[r].z += zofs;

 if(MAP_WAL[num].adjoin != -1)
  {
   wl = GetSectorWL(MAP_WAL[num].adjoin,MAP_WAL[num].mirror);
   l  = GetSectorVX(MAP_WAL[num].adjoin,MAP_WAL[wl].left_vx);
   r  = GetSectorVX(MAP_WAL[num].adjoin,MAP_WAL[wl].right_vx);
   MAP_VRT[l].x += xofs;
   MAP_VRT[l].z += zofs;
   MAP_VRT[r].x += xofs;
   MAP_VRT[r].z += zofs;
  }

 MODIFIED = 1;
}

void move_vertex(int num, float x, float z)
{
 MAP_VRT[num].x = x;
 MAP_VRT[num].z = z;
 MODIFIED = 1;
}

void move_object(int num, float x, float z)
{
 MAP_OBJ[num].x = x;
 MAP_OBJ[num].z = z;
 MAP_OBJ[num].sec = get_object_SC(num);
 MODIFIED = 1;
}

/* ************************************************************************** */
/* OBJECT MOVING WITH MULTIPLE SELECTION FUNCTIONS                            */
/* ************************************************************************** */

/* All the mirror walls in adjoin SC are also moved */
void move_multi_sector(int num, float x, float z)
{
 float xofs, zofs;
 int   i;
 int   wl;
 int   l,r;

 xofs = x - MAP_VRT[MAP_SEC[num].vrt0].x;
 zofs = z - MAP_VRT[MAP_SEC[num].vrt0].z;

 for(i=0; i<=vertex_max; i++) MAP_VRT[i].mark = 0;
 for(i=0; i<=wall_max; i++) MAP_WAL[i].mark = 0;

 for(i=0; i<=sector_max; i++)
  if(MAP_SEC[i].mark != 0)
   {
    for(wl=0; wl<MAP_SEC[i].wno; wl++)
     MAP_WAL[GetSectorWL(i,wl)].mark = 1;
   }

 for(i=0; i<=wall_max; i++)
  {
   if(MAP_WAL[i].mark != 0)
    {
     MAP_VRT[GetAbsoluteVXFfromWL(i)].mark = 1;
     MAP_VRT[GetAbsoluteVXTfromWL(i)].mark = 1;
     if(MAP_WAL[i].adjoin != -1)
      {
       wl = GetSectorWL(MAP_WAL[i].adjoin,MAP_WAL[i].mirror);
       MAP_VRT[GetAbsoluteVXFfromWL(wl)].mark = 1;
       MAP_VRT[GetAbsoluteVXTfromWL(wl)].mark = 1;
      }
    }
  }

 for(i=0; i<=vertex_max; i++)
  if(MAP_VRT[i].mark != 0)
   {
    MAP_VRT[i].x += xofs;
    MAP_VRT[i].z += zofs;
    MAP_VRT[i].mark = 0;
   }

 for(i=0; i<=wall_max; i++) MAP_WAL[i].mark = 0;

 MODIFIED = 1;
}

void move_multi_wall(int num, float x, float z)
{
 float xofs, zofs;
 int   i;
 int   wl;
 int   l,r;

 l    = GetAbsoluteVXFfromWL(num);
 xofs = x - MAP_VRT[l].x;
 zofs = z - MAP_VRT[l].z;

 /* clear all mark in VX (we are sure not to be in VX mode)
    loop on all the walls,
        mark all the vertices (including mirrors)
    use a copy of move_multi_vertex
        clear all mark in VX
 */

 for(i=0; i<=vertex_max; i++) MAP_VRT[i].mark = 0;

 for(i=0; i<=wall_max; i++)
  {
   if(MAP_WAL[i].mark != 0)
    {
     MAP_VRT[GetAbsoluteVXFfromWL(i)].mark = 1;
     MAP_VRT[GetAbsoluteVXTfromWL(i)].mark = 1;
     if(MAP_WAL[i].adjoin != -1)
      {
       wl = GetSectorWL(MAP_WAL[i].adjoin,MAP_WAL[i].mirror);
       MAP_VRT[GetAbsoluteVXFfromWL(wl)].mark = 1;
       MAP_VRT[GetAbsoluteVXTfromWL(wl)].mark = 1;
      }
    }
  }

 for(i=0; i<=vertex_max; i++)
  if(MAP_VRT[i].mark != 0)
   {
    MAP_VRT[i].x += xofs;
    MAP_VRT[i].z += zofs;
    MAP_VRT[i].mark = 0;
   }

 MODIFIED = 1;
}

/* num is hilited VX */
void move_multi_vertex(int num, float x, float z)
{
 float xofs, zofs;
 int   i;

 xofs = x - MAP_VRT[num].x;
 zofs = z - MAP_VRT[num].z;

 for(i=0; i<=vertex_max; i++)
  if(MAP_VRT[i].mark != 0)
   {
    MAP_VRT[i].x += xofs;
    MAP_VRT[i].z += zofs;
   }
 MODIFIED = 1;
}

void move_multi_object(int num, float x, float z)
{
 float xofs, zofs;
 int   i;

 xofs = x - MAP_OBJ[num].x;
 zofs = z - MAP_OBJ[num].z;

 for(i=0; i<=obj_max; i++)
  if(MAP_OBJ[i].mark != 0)
   {
    MAP_OBJ[i].x += xofs;
    MAP_OBJ[i].z += zofs;
    MAP_OBJ[i].sec = get_object_SC(i);
   }
 MODIFIED = 1;
}
