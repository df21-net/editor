/* ========================================================================== */
/* LEVINFO.C  : INFORMATION FUNCTIONS                                         */
/*              * Information functions                                       */
/*              * Information with swap file access reading                   */
/*              * Information with swap file access writing                   */
/* ========================================================================== */
#include "levmap.h"
#include "levext.h"
#include <math.h>

/* ************************************************************************** */
/* GENERAL INFORMATION FUNCTIONS                                              */
/* ************************************************************************** */

int GetSectorVX(int the_sector, int num)
{
 if(num >= MAP_SEC[the_sector].vno)
  return(-1);
 else
  return(MAP_SEC[the_sector].vrt0 + num);
}

int GetSectorWL(int the_sector, int num)
{
 if(num >= MAP_SEC[the_sector].wno)
  return(-1);
 else
  return(MAP_SEC[the_sector].wal0 + num);
}

int GetAbsoluteVXFfromWL(int the_wl)
{
 return(GetSectorVX(MAP_WAL[the_wl].sec, MAP_WAL[the_wl].left_vx));
}

int GetAbsoluteVXTfromWL(int the_wl)
{
 return(GetSectorVX(MAP_WAL[the_wl].sec, MAP_WAL[the_wl].right_vx));
}

int GetRelativeVXfromAbsoluteVX(int num)
{
 return(num - MAP_SEC[MAP_VRT[num].sec].vrt0);
}

int GetRelativeWLfromAbsoluteWL(int num)
{
 return(num - MAP_SEC[MAP_WAL[num].sec].wal0);
}

int GetAbsoluteWLfromVXF(int num)
{
 int wall;
 int the_sector;
 int the_relvx;

 the_sector = MAP_VRT[num].sec;
 the_relvx  = GetRelativeVXfromAbsoluteVX(num);
 wall  = 0;
 while(wall < MAP_SEC[the_sector].wno)
  {
   if(MAP_WAL[GetSectorWL(the_sector, wall)].left_vx == the_relvx)
    {
     return(GetSectorWL(the_sector, wall));
    }
   wall++;
  }
  return(-1);
}

int GetAbsoluteWLfromVXT(int num)
{
 int wall;
 int the_sector;
 int the_relvx;

 the_sector = MAP_VRT[num].sec;
 the_relvx  = GetRelativeVXfromAbsoluteVX(num);
 wall  = 0;
 while(wall < MAP_SEC[the_sector].wno)
  {
   if(MAP_WAL[GetSectorWL(the_sector, wall)].right_vx == the_relvx)
    {
     return(GetSectorWL(the_sector, wall));
    }
   wall++;
  }
  return(-1);
}

void set_map_centered()
{
 int i;

 maxx  = -32000.0;
 maxz  = -32000.0;
 minx  =  32000.0;
 minz  =  32000.0;

 for(i=0; i<=vertex_max; i++)
  {
   if(MAP_VRT[i].x > maxx) maxx = MAP_VRT[i].x;
   if(MAP_VRT[i].x < minx) minx = MAP_VRT[i].x;
   if(MAP_VRT[i].z > maxz) maxz = MAP_VRT[i].z;
   if(MAP_VRT[i].z < minz) minz = MAP_VRT[i].z;
  }

 xoffset = (maxx+minx) / 2;
 yoffset = (maxz+minz) / 2;
}

int get_nearest_VX(float x, float z)
{
 int i;
 float distance1;
 float distance_min = 999999999;
 int vx_min        = -1;

 for(i=0; i<=vertex_max; i++)
  {
   if(MAP_SEC[MAP_VRT[i].sec].del == 0)
   {
    distance1 = (float)((MAP_VRT[i].x - x) * (MAP_VRT[i].x - x)
              +         (MAP_VRT[i].z - z) * (MAP_VRT[i].z - z));
    if(distance1 < distance_min)
     if(MAP_SEC[MAP_VRT[i].sec].layer == LAYER)
        {
         vx_min       = i;
         distance_min = distance1;
        }
   }
  }
 return(vx_min);
}

int  get_next_nearest_VX(float x, float z)
{
 int i;
 float distance1;
 float distance_min = 999999999;
 int vx_min        = -1;

 for(i=0; i<=vertex_max; i++)
  {
   if(MAP_SEC[MAP_VRT[i].sec].del == 0)
    {
     distance1 = (float)((MAP_VRT[i].x - x) * (MAP_VRT[i].x - x)
               +         (MAP_VRT[i].z - z) * (MAP_VRT[i].z - z));
     if(distance1 < distance_min)
      if(MAP_SEC[MAP_VRT[i].sec].layer == LAYER)
       if(i != VX_HILITE)
         {
          vx_min       = i;
          distance_min = distance1;
         }
    }
  }
 return(vx_min);
}

int  get_nearest_OB(float x, float z)
{
 int i;
 float distance1;
 float distance_min = 999999999;
 int ob_min        = -1;

 for(i=0; i<=obj_max; i++)
  {
   if(MAP_OBJ[i].del == 0)
    {
     distance1 = (float)((MAP_OBJ[i].x - x) * (MAP_OBJ[i].x - x)
               +         (MAP_OBJ[i].z - z) * (MAP_OBJ[i].z - z));
     if(distance1 < distance_min)
       if((OBJECT_LAYERING == 0) ||
          (MAP_OBJ[i].sec == -1) ||
          (MAP_SEC[MAP_OBJ[i].sec].layer == LAYER)
         )
        if(difficulty_ok(MAP_OBJ[i].diff) == TRUE)
         {
          ob_min       = i;
          distance_min = distance1;
         }
    }
  }
 return(ob_min);
}

/* are the double necessary ? */
int get_nearest_SC(float x, float z, int start_at)
{
 double x1, z1, x2, z2, dd, a1, b1, a2, b2;
 double dmin, cal;
 double xx, xi, zi;
 double ox, oz, deltax, deltaz, dx, dz, gx, gz;
 double dist_d, dist_g;
 int    i;
 int    it;
 int    wl_start;
 int    retval;

 dmin = 999999.0;
 it  = -1;

 wl_start = MAP_SEC[start_at].wal0;

 for(i=wl_start; i <= wall_max ; i++)
   {
    if(MAP_SEC[MAP_WAL[i].sec].layer == LAYER)
     {
      x1 = (double)MAP_VRT[GetSectorVX(MAP_WAL[i].sec, MAP_WAL[i].left_vx)].x;
      z1 = (double)MAP_VRT[GetSectorVX(MAP_WAL[i].sec, MAP_WAL[i].left_vx)].z;
      x2 = (double)MAP_VRT[GetSectorVX(MAP_WAL[i].sec, MAP_WAL[i].right_vx)].x;
      z2 = (double)MAP_VRT[GetSectorVX(MAP_WAL[i].sec, MAP_WAL[i].right_vx)].z;

      if(z1 != z2) /* NOT horizontal */
       {
        if(x1 == x2) /* vertical */
         {
          xi = (double)x1;
         }
        else
         {
          dd = (double)( ((double)z1-(double)z2 ) / ((double)x1-(double)x2) );
          xi = (double)( (double)z + (double)dd * (double)x1 - (double)z1) / (double)dd;
         }

        /* is intersection in the wall ? */
        if( ((double)z >= min((double)z1, (double)z2)) &&
            ((double)z <= max((double)z1, (double)z2))
          )
         {
          cal = fabs((double)((double)xi - (double)x));

          /* a test on the orientation of the wall */
          ox = (double)(((double)x1 + (double)x2) / (double)2);
          oz = (double)(((double)z1 + (double)z2) / (double)2);
          deltax = (double)((double)x1 - (double)x2);
          deltaz = (double)((double)z1 - (double)z2);
          dx = (double)((double)ox - (double)deltaz);
          dz = (double)((double)oz + (double)deltax);
          gx = (double)((double)ox + (double)deltaz);
          gz = (double)((double)oz - (double)deltax);
          dist_d = (double)(((double)dx - (double)x) * ((double)dx - (double)x) +
                            ((double)dz - (double)z) * ((double)dz - (double)z));
          dist_g = (double)(((double)gx - (double)x) * ((double)gx - (double)x) +
                            ((double)gz - (double)z) * ((double)gz - (double)z));

          /* must be <= to give adjoins a chance ! */
          if(cal <= dmin)
           {
            if(dist_d > dist_g)
             {
              if(MAP_WAL[i].adjoin != -1)
               {
                it = GetSectorWL(MAP_WAL[i].adjoin, MAP_WAL[i].mirror);
                /* adjoin could be on wrong layer! */
                if(MAP_SEC[MAP_WAL[i].adjoin].layer != LAYER) it = -1;
                dmin = cal;
               }
              else
               {
                it   = -1;
                dmin = cal;
               }
             }
            else
             {
              it       = i;
              dmin     = cal;
             }
           }; /* dist <= */
         }; /* intersection on the wall */
       }; /* horizontal */
     }; /* LAYER */
   }; /* for walls */

 if(it != -1)
   retval = MAP_WAL[it].sec;
 else
   retval = -1;

 return(retval);
}

int  get_nearest_WL(float x, float z)
{
 int    i;
 float  ox, oz, deltax, deltaz, dx, dz, gx, gz;
 float  dmin, cal, x1, z1, x2, z2, dd, a1, b1, a2, b2, dist_d, dist_g;
 float  xx, xi, zi;
 int    it;
 int    sector;

 dmin = 9999999.0;
 it  = -1;
 sector = get_nearest_SC(x,z,0);
if(sector != -1)
{
 for(i=0; i < MAP_SEC[sector].wno ; i++)
   {
     x1 = MAP_VRT[GetSectorVX(sector, MAP_WAL[GetSectorWL(sector, i)].left_vx)].x;
     z1 = MAP_VRT[GetSectorVX(sector, MAP_WAL[GetSectorWL(sector, i)].left_vx)].z;
     x2 = MAP_VRT[GetSectorVX(sector, MAP_WAL[GetSectorWL(sector, i)].right_vx)].x;
     z2 = MAP_VRT[GetSectorVX(sector, MAP_WAL[GetSectorWL(sector, i)].right_vx)].z;

     if(z1 != z2) /* NOT horizontal */
      {
       if(x1 == x2) /* vertical */
        {
         xi = x1;
        }
       else
        {
         dd = (z1-z2)/(x1-x2);
         xi = ( z + dd * x1 - z1) / dd;
        }
       /* is intersection in the wall ? */
       if( (z >= min(z1, z2)) &&  (z <= max(z1, z2)) )
        {
         cal = fabs(xi - x);
         if(cal < dmin)
          {
           dmin = cal;
           it = i;
          }
        }
       else
        {
        }
      }
     else /* horizontal */
      {
       /* xi = x; corrected AFTER WDFUSE !! */
       zi = z1;
       /* is intersection in the wall ? */
       if( (x >= min(x1,x2)) &&  (x <= max(x1,x2)) )
        {
         cal = fabs(z1 - z);
         if(cal < dmin)
          {
           dmin = cal;
           it = i;
          }
        }
      }

    } /* for walls */
 if(it == -1)
  return(-1);
 else
  return(GetSectorWL(sector, it));
}
else
 return(-1);
}

int  get_object_SC(int num)
{
 int l, found, sector, testsec, oldlayer;

 sector   = -1;
 found    = 0;
 oldlayer = LAYER;

 for(l=minlayer; l<=maxlayer; l++)
  {
   LAYER = l;
   testsec = get_nearest_SC(MAP_OBJ[num].x, MAP_OBJ[num].z, 0);
   if(testsec != -1)
    {
     if((-MAP_SEC[testsec].floor_alt <= -MAP_OBJ[num].y) &&
        (-MAP_SEC[testsec].ceili_alt >= -MAP_OBJ[num].y)
       )
      {
       sector = testsec;
       found  = 1;
      }
     else
      {
       /* do it a second time, in case there are 2 possible sectors on
          the same layer ! */
       if(testsec < sector_max) testsec++;
       testsec = get_nearest_SC(MAP_OBJ[num].x, MAP_OBJ[num].z, testsec);
       if(testsec != -1)
        {
         if((-MAP_SEC[testsec].floor_alt <= -MAP_OBJ[num].y) &&
            (-MAP_SEC[testsec].ceili_alt >= -MAP_OBJ[num].y)
           )
          {
           sector = testsec;
           found  = 1;
          }
        }
      }
    }
   if(found==1) break;
  }

  LAYER = oldlayer;
  return(sector);
}

int layer_objects(void)
{
 int i;
 int count = 0;

 setcolor(HEAD_FORE);
 outtextxy(0,136,"Layering objects.");

 for(i = 0; i <= obj_max; i++)
  {
   MAP_OBJ[i].sec = get_object_SC(i);
   if(MAP_OBJ[i].sec == -1)
    {
     count++;
     setcolor(HILI_AT_ALT);
    }
   else
     setcolor(LINE_AT_ALT);

   moveto(i, 152);
   lineto(i, 160);
  }

 return(count);
}


/* ************************************************************************** */
/* INFORMATION FUNCTIONS WITH SWAP FILE ACCESS (MIXED READ/WRITE)             */
/* ************************************************************************** */

void get_sector_info(int num)
{
 lseek(fsec, (long)((long)num * (long)sizeof(swpSEC)) , SEEK_SET);
 read(fsec, &swpSEC, sizeof(swpSEC));
}

void set_sector_info(int num)
{
 lseek(fsec, (long)((long)num * (long)sizeof(swpSEC)) , SEEK_SET);
 write(fsec, &swpSEC, sizeof(swpSEC));
}

void get_sector_info2(int num)
{
 lseek(fsec, (long)((long)num * (long)sizeof(swpSEC2)) , SEEK_SET);
 read(fsec, &swpSEC2, sizeof(swpSEC2));
}

void get_wall_info(int num)
{
 lseek(fwal, (long)((long)num * (long)sizeof(swpWAL)) , SEEK_SET);
 read(fwal, &swpWAL, sizeof(swpWAL));
}

void set_wall_info(int num)
{
 lseek(fwal, (long)((long)num * (long)sizeof(swpWAL)) , SEEK_SET);
 write(fwal, &swpWAL, sizeof(swpWAL));
}

void get_texture_name(int num, char *name)
{
 strcpy(name, "");
 lseek(ftex, (long)((long)num * 16L) , SEEK_SET);
 read(ftex, name, 16);
}

void set_texture_name(int num, char *name)
{
 lseek(ftex, (long)((long)num * 16L) , SEEK_SET);
 write(ftex, name, 16);
}

void get_object_info(int num)
{
 lseek(fobj, (long)((long)num * (long)sizeof(swpOBJ)) , SEEK_SET);
 read(fobj, &swpOBJ, sizeof(swpOBJ));
}

void set_object_info(int num)
{
 lseek(fobj, (long)((long)num * (long)sizeof(swpOBJ)) , SEEK_SET);
 write(fobj, &swpOBJ, sizeof(swpOBJ));
}

void get_pod_name(int num, char *name)
{
 strcpy(name, "");
 lseek(fpods, (long)((long)num * 16L) , SEEK_SET);
 read(fpods, name, 16);
}

void get_fme_name(int num, char *name)
{
 strcpy(name, "");
 lseek(ffmes, (long)((long)num * 16L) , SEEK_SET);
 read(ffmes, name, 16);
}

void get_spr_name(int num, char *name)
{
 strcpy(name, "");
 lseek(fsprs, (long)((long)num * 16L) , SEEK_SET);
 read(fsprs, name, 16);
}

void get_snd_name(int num, char *name)
{
 strcpy(name, "");
 lseek(fsounds, (long)((long)num * 16L) , SEEK_SET);
 read(fsounds, name, 16);
}



