/* ========================================================================== */
/* LEV_INSR.C : MAP INSERTION                                                 */
/*              * Insertion                                                   */
/*              * Splitting/Extruding/Adjoinning functions                    */
/* ========================================================================== */

#include "levmap.h"
#include "levext.h"

/* ************************************************************************** */
/* INSERTION FUNCTIONS                                                        */
/* ************************************************************************** */

void InsertVX(int sector, int num, struct tagMAP_VRT new_vx)
{
 int i;
 int vx;
 int wl;

 vx = MAP_SEC[sector].vrt0 + num;

 /* update the others */
 vertex_max++;
 for(i = vertex_max; i > vx; i--)
  MAP_VRT[i] = MAP_VRT[i-1];
 for(i = sector + 1; i <= sector_max; i++) MAP_SEC[i].vrt0++;

 for(i=0; i<MAP_SEC[sector].wno; i++)
  {
   wl = GetSectorWL(sector, i);
   if(MAP_WAL[wl].left_vx  >= num)  MAP_WAL[wl].left_vx++;
   if(MAP_WAL[wl].right_vx >  num)  MAP_WAL[wl].right_vx++;
  }

 /* insert the new one */
 MAP_VRT[vx] = new_vx;
 MAP_SEC[sector].vno++;
}

void InsertWL(int sector, int num, struct tagMAP_WAL new_wl)
{
 int i;
 int wl;
 int adjoin,mirror;

 wl = MAP_SEC[sector].wal0 + num;

 /* move up the others */
 wall_max++;
 for(i = wall_max; i > wl; i--)  MAP_WAL[i] = MAP_WAL[i-1];
 for(i = sector + 1; i <= sector_max; i++) MAP_SEC[i].wal0++;

 /* insert the new one */
 MAP_WAL[wl] = new_wl;
 MAP_SEC[sector].wno++;

 /* UPDATE THE swp file */
 get_wall_info(wall_max - 1);
 swpWAL2 = swpWAL;             /* preserve last WL info */

 for(i = wall_max; i > wl; i--)
  {
   get_wall_info(i-1);
   set_wall_info(i);
  }                            /* could be optimized by bulk copy ??? */

 /* handle the last one */
 lseek(fwal, 0 , SEEK_END);
 write(fwal, &swpWAL2, sizeof(swpWAL));

 /* handle current one */
 get_wall_info(wl-1); /* get the preceeding info ie the splitted wall */
 set_wall_info(wl);

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

int insert_object(float x, float z)
{
 if(obj_max + 1 < obj_alloc - 1)
  {
   get_object_info(OB_HILITE);

   obj_max++;
   MAP_OBJ[obj_max] = MAP_OBJ[OB_HILITE];
   OB_HILITE = obj_max;

   MAP_OBJ[OB_HILITE].del  = 0;
   MAP_OBJ[OB_HILITE].mark = 0;
   MAP_OBJ[OB_HILITE].x    = x;
   MAP_OBJ[OB_HILITE].z    = z;
   MAP_OBJ[OB_HILITE].sec  = get_object_SC(OB_HILITE);

   lseek(fobj, 0, SEEK_END);
   write(fobj, &swpOBJ, sizeof(swpOBJ));
   MODIFIED = 1;
   return(OB_HILITE);
  }
 else
  {
   message_out_of_ob();
   return(0);
  }
}

int insert_objects(float x, float z)
{
 float xo, zo;
 int i;
 int multi;

 if(obj_max + MULTISEL < obj_alloc - 1)
  {
   xo = x - MAP_OBJ[OB_HILITE].x;
   zo = z - MAP_OBJ[OB_HILITE].z;
   for(i=1; i<=MULTISEL; i++)
    {
     OB_HILITE = find_multisel_OB(i);
     insert_object(MAP_OBJ[OB_HILITE].x + xo, MAP_OBJ[OB_HILITE].z + zo);
    }

   if(MULTISEL != 0)
    {
     messageTRANSFER_SEL();
     if(getVK() == VK_ENTER)
      {
       multi = MULTISEL;
       clear_multi_object();
       for(i=1; i<=multi; i++) multi_object(obj_max-multi+i);
      }
    }
   return(OB_HILITE);
  }
 else
  {
   message_out_of_ob();
   return(0);
  }
}

int split_wall(int num)
{
 struct tagMAP_VRT new_vx;
 struct tagMAP_WAL new_wl;
 int sector;
 int vx1,vx2;
 int adjoin;
 int adjlower = 0;

 if(MAP_WAL[num].adjoin != -1)
  {
   adjoin = GetSectorWL(MAP_WAL[num].adjoin,MAP_WAL[num].mirror);
   if(adjoin < num) adjlower = 1;
   un_adjoin(num);
  }
 else
  adjoin = -1;

 if((wall_max + 2 < wall_alloc - 1) && (vertex_max + 2 < vertex_alloc - 1))
   {
    sector = MAP_WAL[num].sec;
    vx1    = GetAbsoluteVXFfromWL(num);
    vx2    = GetAbsoluteVXTfromWL(num);

    new_vx.mark  = 0;
    new_vx.sec   = sector;
    new_vx.x = (MAP_VRT[vx1].x + MAP_VRT[vx2].x) / 2 ;
    new_vx.z = (MAP_VRT[vx1].z + MAP_VRT[vx2].z) / 2 ;

    new_wl.mark  = 0;
    new_wl.sec   = sector;
    new_wl.adjoin= -1;
    new_wl.mirror= -1;
    new_wl.walk  = -1;
    new_wl.trig  = 0;
    if(MAP_WAL[num].right_vx > MAP_WAL[num].left_vx) /* is this the end of a cycle ? */
     {
      new_wl.left_vx   = MAP_WAL[num].left_vx + 1;
      new_wl.right_vx  = MAP_WAL[num].right_vx + 1;
      InsertVX(sector, MAP_WAL[num].right_vx, new_vx);
      InsertWL(sector, num - MAP_SEC[sector].wal0 + 1, new_wl);
     }
    else
     {
      new_wl.left_vx   = MAP_WAL[num].left_vx + 1;
      new_wl.right_vx  = MAP_WAL[num].right_vx;
      InsertVX(sector, MAP_SEC[sector].vno, new_vx);
      InsertWL(sector, num - MAP_SEC[sector].wal0 + 1, new_wl);
      MAP_WAL[num].right_vx = MAP_SEC[sector].vno - 1;
     }
    MODIFIED = 1;

    if(adjoin != -1)
     {
      if(adjlower == 1)
        split_wall(adjoin);
      else
        split_wall(adjoin+1);
      make_adjoin(num + adjlower);
      make_adjoin(num+1 +adjlower);
     }

    return(num+1+adjlower);
   }
  else
   {
    message_out_of_vxwl();
    return(0);
   }
}

void flip_wall(int num)
{
 int tmpvx;

 tmpvx                 = MAP_WAL[num].left_vx;
 MAP_WAL[num].left_vx  = MAP_WAL[num].right_vx;
 MAP_WAL[num].right_vx = tmpvx;
}

int make_adjoin(int num)
{
 int i;
 int retval = 0;

 if(MAP_WAL[num].adjoin == -1)
  {
   for(i=0;i<=wall_max;i++)
   {
    if(MAP_VRT[GetAbsoluteVXFfromWL(num)].x == MAP_VRT[GetAbsoluteVXTfromWL(i)].x)
    if(MAP_VRT[GetAbsoluteVXFfromWL(num)].z == MAP_VRT[GetAbsoluteVXTfromWL(i)].z)
    if(MAP_VRT[GetAbsoluteVXTfromWL(num)].x == MAP_VRT[GetAbsoluteVXFfromWL(i)].x)
    if(MAP_VRT[GetAbsoluteVXTfromWL(num)].z == MAP_VRT[GetAbsoluteVXFfromWL(i)].z)
     {
      /* found a possible adjoin/mirror */
      MAP_WAL[num].adjoin = MAP_WAL[i].sec;
      MAP_WAL[num].mirror = GetRelativeWLfromAbsoluteWL(i);
      MAP_WAL[num].walk   = MAP_WAL[i].sec;
      MAP_WAL[i  ].adjoin = MAP_WAL[num].sec;
      MAP_WAL[i  ].mirror = GetRelativeWLfromAbsoluteWL(num);
      MAP_WAL[i  ].walk   = MAP_WAL[num].sec;
      retval = 1;
      break;
     }
   }
  }
 return(retval);
}

int un_adjoin(int num)
{
 int i;
 int retval = 0;

 if(MAP_WAL[num].adjoin != -1)
  {
   i = GetSectorWL(MAP_WAL[num].adjoin,MAP_WAL[num].mirror);
   MAP_WAL[i  ].adjoin = -1;
   MAP_WAL[i  ].mirror = -1;
   MAP_WAL[i  ].walk   = -1;
   MAP_WAL[num].adjoin = -1;
   MAP_WAL[num].mirror = -1;
   MAP_WAL[num].walk   = -1;
   retval = 1;
  }
 return(retval);
}

int  insert_sector(float x, float z)
{
 int old_vrt0;
 int old_wal0;
 int i;
 float xofs, zofs;

 get_sector_info(SC_HILITE);

 if(sector_max + 1 < sector_alloc - 1)
  {
   if((wall_max + MAP_SEC[SC_HILITE].wno < wall_alloc - 1) && (vertex_max + MAP_SEC[SC_HILITE].vno < vertex_alloc - 1))
    {
     sector_max++;
     MAP_SEC[sector_max] = MAP_SEC[SC_HILITE];
     SC_HILITE = sector_max;

     MAP_SEC[SC_HILITE].del    = 0;
     MAP_SEC[SC_HILITE].mark   = 0;
     old_vrt0 = MAP_SEC[SC_HILITE].vrt0;
     old_wal0 = MAP_SEC[SC_HILITE].wal0;
     MAP_SEC[SC_HILITE].vrt0 = vertex_max+1;
     MAP_SEC[SC_HILITE].wal0 = wall_max+1;

     vertex_max += MAP_SEC[SC_HILITE].vno;
     wall_max   += MAP_SEC[SC_HILITE].wno;

     xofs = x - MAP_VRT[old_vrt0].x;
     zofs = z - MAP_VRT[old_vrt0].z;

     for(i=0; i<MAP_SEC[SC_HILITE].vno; i++)
      {
       MAP_VRT[MAP_SEC[SC_HILITE].vrt0 + i].x = MAP_VRT[old_vrt0 + i].x + xofs;
       MAP_VRT[MAP_SEC[SC_HILITE].vrt0 + i].z = MAP_VRT[old_vrt0 + i].z + zofs;
       MAP_VRT[MAP_SEC[SC_HILITE].vrt0 + i].sec   = SC_HILITE;
       MAP_VRT[MAP_SEC[SC_HILITE].vrt0 + i].mark  = 0;
      }

     for(i=0; i<MAP_SEC[SC_HILITE].wno; i++)
      {
       MAP_WAL[MAP_SEC[SC_HILITE].wal0 + i] = MAP_WAL[old_wal0 + i];
       MAP_WAL[MAP_SEC[SC_HILITE].wal0 + i].sec    = SC_HILITE;
       MAP_WAL[MAP_SEC[SC_HILITE].wal0 + i].mark   = 0;

       MAP_WAL[MAP_SEC[SC_HILITE].wal0 + i].adjoin = -1;
       MAP_WAL[MAP_SEC[SC_HILITE].wal0 + i].mirror = -1;
       MAP_WAL[MAP_SEC[SC_HILITE].wal0 + i].walk   = -1;

       get_wall_info(old_wal0 + i);
       lseek(fwal, 0, SEEK_END);
       write(fwal, &swpWAL, sizeof(swpWAL));
      }

     lseek(fsec, 0, SEEK_END);
     write(fsec, &swpSEC, sizeof(swpSEC));
     MODIFIED = 1;
     return(SC_HILITE);
    }
   else
    {
     message_out_of_vxwl();
     return(0);
    }
   }
 else
  {
   message_out_of_sectors();
   return(0);
  }
}

int insert_sectors(float x, float z)
{
 float xo, zo;
 int countvx, countwl, multi;
 int sector;
 int i,j;

 if(sector_max + MULTISEL < sector_alloc - 1)
  {
   countvx = 0;
   countwl = 0;
   for(i=0; i<=sector_max; i++)
    {
     if(MAP_SEC[i].mark != 0)
      {
       countvx += MAP_SEC[i].vno;
       countwl += MAP_SEC[i].wno;
      }
    }

   if((wall_max + countwl < wall_alloc - 1) && (vertex_max + countvx < vertex_alloc - 1))
    {
     xo = x - MAP_VRT[MAP_SEC[SC_HILITE].vrt0].x;
     zo = z - MAP_VRT[MAP_SEC[SC_HILITE].vrt0].z;
     for(i=1; i<=MULTISEL; i++)
      {
       SC_HILITE = find_multisel_SC(i);
       insert_sector(MAP_VRT[MAP_SEC[SC_HILITE].vrt0].x + xo,
                     MAP_VRT[MAP_SEC[SC_HILITE].vrt0].z + zo);
      }


   /* Remove the adjoins and try to recreate those internal */
   multi = MULTISEL;
   for(i=1; i<=multi; i++)
    {
     sector = sector_max-multi+i;
     for(j = MAP_SEC[sector].wal0; j < MAP_SEC[sector].wal0 + MAP_SEC[sector].wno; j++ )
      {
        MAP_WAL[j].adjoin = -1;
        MAP_WAL[j].mirror = -1;
        MAP_WAL[j].walk   = -1;
      }
    }
   for(i=1; i<=multi; i++)
    {
     sector = sector_max-multi+i;
     for(j = MAP_SEC[sector].wal0; j < MAP_SEC[sector].wal0 + MAP_SEC[sector].wno; j++ )
      {
        make_adjoin(j);
      }
    }

   if(MULTISEL != 0)
    {
     messageTRANSFER_SEL();
     if(getVK() == VK_ENTER)
      {
       multi = MULTISEL;
       clear_multi_sector();
       for(i=1; i<=multi; i++) multi_sector(sector_max-multi+i);
      }
    }
     return(SC_HILITE);
    }
   else
    {
     message_out_of_vxwl();
     return(0);
    }
  }
 else
  {
   message_out_of_sectors();
   return(0);
  }
}

int insert_sector_gap(float x, float z)
{
 int i;
 int secori;
 float xofs,   zofs;
 float deltax, deltaz;
 struct tagMAP_VRT new_vx;
 struct tagMAP_WAL new_wl;

 if((wall_max + 3 < wall_alloc - 1) && (vertex_max + 3 < vertex_alloc - 1))
  {
   new_vx.x = x-3;
   new_vx.z = z;
   InsertVX(SC_HILITE, MAP_SEC[SC_HILITE].vno, new_vx);
   new_vx.x = x;
   new_vx.z = z-3;
   InsertVX(SC_HILITE, MAP_SEC[SC_HILITE].vno, new_vx);
   new_vx.x = x;
   new_vx.z = z+3;
   InsertVX(SC_HILITE, MAP_SEC[SC_HILITE].vno, new_vx);

   for(i=MAP_SEC[SC_HILITE].vno-3; i<MAP_SEC[SC_HILITE].vno; i++)
    {
     MAP_VRT[MAP_SEC[SC_HILITE].vrt0 + i].sec   = SC_HILITE;
     MAP_VRT[MAP_SEC[SC_HILITE].vrt0 + i].mark  = 0;
    }

   InsertWL(SC_HILITE, MAP_SEC[SC_HILITE].wno, new_wl);
   InsertWL(SC_HILITE, MAP_SEC[SC_HILITE].wno, new_wl);
   InsertWL(SC_HILITE, MAP_SEC[SC_HILITE].wno, new_wl);

   MAP_WAL[GetSectorWL(SC_HILITE,MAP_SEC[SC_HILITE].wno-3)].left_vx  = MAP_SEC[SC_HILITE].vno-3;
   MAP_WAL[GetSectorWL(SC_HILITE,MAP_SEC[SC_HILITE].wno-3)].right_vx = MAP_SEC[SC_HILITE].vno-2;
   MAP_WAL[GetSectorWL(SC_HILITE,MAP_SEC[SC_HILITE].wno-2)].left_vx  = MAP_SEC[SC_HILITE].vno-2;
   MAP_WAL[GetSectorWL(SC_HILITE,MAP_SEC[SC_HILITE].wno-2)].right_vx = MAP_SEC[SC_HILITE].vno-1;
   MAP_WAL[GetSectorWL(SC_HILITE,MAP_SEC[SC_HILITE].wno-1)].left_vx  = MAP_SEC[SC_HILITE].vno-1;
   MAP_WAL[GetSectorWL(SC_HILITE,MAP_SEC[SC_HILITE].wno-1)].right_vx = MAP_SEC[SC_HILITE].vno-3;

   for(i=MAP_SEC[SC_HILITE].wno-3; i<MAP_SEC[SC_HILITE].wno; i++)
    {
     MAP_WAL[MAP_SEC[SC_HILITE].wal0 + i].sec    = SC_HILITE;
     MAP_WAL[MAP_SEC[SC_HILITE].wal0 + i].mark   = 0;
     MAP_WAL[MAP_SEC[SC_HILITE].wal0 + i].trig   = 0;
     MAP_WAL[MAP_SEC[SC_HILITE].wal0 + i].adjoin = -1;
     MAP_WAL[MAP_SEC[SC_HILITE].wal0 + i].mirror = -1;
     MAP_WAL[MAP_SEC[SC_HILITE].wal0 + i].walk   = -1;
     MAP_WAL[MAP_SEC[SC_HILITE].wal0 + i].trig   =  0;
     MAP_WAL[MAP_SEC[SC_HILITE].wal0 + i].reserved= 0;
     get_wall_info(GetSectorWL(SC_HILITE, 1));
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
     set_wall_info(MAP_SEC[SC_HILITE].wal0 + i);
    }

   MODIFIED = 1;
   return(SC_HILITE);
  }
 else
  {
   message_out_of_vxwl();
   return(0);
  }
}

int extrude_wall4(int num)
{
 int i;
 float xofs,   zofs;
 float deltax, deltaz;

 get_sector_info(MAP_WAL[num].sec);

 if(sector_max + 1 < sector_alloc - 1)
  {
   if((wall_max + 4 < wall_alloc - 1) && (vertex_max + 4 < vertex_alloc - 1))
    {
     sector_max++;
     MAP_SEC[sector_max] = MAP_SEC[MAP_WAL[num].sec];
     SC_HILITE = sector_max;

     MAP_SEC[SC_HILITE].del  = 0;
     MAP_SEC[SC_HILITE].mark = 0;
     MAP_SEC[SC_HILITE].elev   = 0;
     MAP_SEC[SC_HILITE].trig   = 0;
     MAP_SEC[SC_HILITE].secret = 0;
     swpSEC.flag1 &= ~2;
     swpSEC.flag1 &= ~64;
     swpSEC.flag1 &= ~524288;
     MAP_SEC[SC_HILITE].vrt0 = vertex_max+1;
     MAP_SEC[SC_HILITE].vno  = 4;
     MAP_SEC[SC_HILITE].wal0 = wall_max+1;
     MAP_SEC[SC_HILITE].wno  = 4;

     vertex_max += 4;
     wall_max   += 4;

     MAP_VRT[MAP_SEC[SC_HILITE].vrt0].x   = MAP_VRT[GetSectorVX(MAP_WAL[num].sec,MAP_WAL[num].right_vx)].x;
     MAP_VRT[MAP_SEC[SC_HILITE].vrt0].z   = MAP_VRT[GetSectorVX(MAP_WAL[num].sec,MAP_WAL[num].right_vx)].z;
     MAP_VRT[MAP_SEC[SC_HILITE].vrt0+1].x = MAP_VRT[GetSectorVX(MAP_WAL[num].sec,MAP_WAL[num].left_vx)].x;
     MAP_VRT[MAP_SEC[SC_HILITE].vrt0+1].z = MAP_VRT[GetSectorVX(MAP_WAL[num].sec,MAP_WAL[num].left_vx)].z;

     deltax =   MAP_VRT[GetSectorVX(MAP_WAL[num].sec,MAP_WAL[num].left_vx)].x
              - MAP_VRT[GetSectorVX(MAP_WAL[num].sec,MAP_WAL[num].right_vx)].x;
     deltaz =   MAP_VRT[GetSectorVX(MAP_WAL[num].sec,MAP_WAL[num].left_vx)].z
              - MAP_VRT[GetSectorVX(MAP_WAL[num].sec,MAP_WAL[num].right_vx)].z;

     MAP_VRT[MAP_SEC[SC_HILITE].vrt0+2].x = MAP_VRT[MAP_SEC[SC_HILITE].vrt0+1].x + EXTRUDE_RATIO * deltaz;
     MAP_VRT[MAP_SEC[SC_HILITE].vrt0+2].z = MAP_VRT[MAP_SEC[SC_HILITE].vrt0+1].z - EXTRUDE_RATIO * deltax;
     MAP_VRT[MAP_SEC[SC_HILITE].vrt0+3].x = MAP_VRT[MAP_SEC[SC_HILITE].vrt0].x   + EXTRUDE_RATIO * deltaz;
     MAP_VRT[MAP_SEC[SC_HILITE].vrt0+3].z = MAP_VRT[MAP_SEC[SC_HILITE].vrt0].z   - EXTRUDE_RATIO * deltax;

     for(i=0; i<4; i++)
      {
       MAP_VRT[MAP_SEC[SC_HILITE].vrt0 + i].sec   = SC_HILITE;
       MAP_VRT[MAP_SEC[SC_HILITE].vrt0 + i].mark  = 0;
      }

     for(i=0; i<4; i++)
      {
       MAP_WAL[MAP_SEC[SC_HILITE].wal0 + i].sec    = SC_HILITE;
       MAP_WAL[MAP_SEC[SC_HILITE].wal0 + i].mark   = 0;
       MAP_WAL[MAP_SEC[SC_HILITE].wal0 + i].trig   = 0;
       MAP_WAL[MAP_SEC[SC_HILITE].wal0 + i].adjoin = -1;
       MAP_WAL[MAP_SEC[SC_HILITE].wal0 + i].mirror = -1;
       MAP_WAL[MAP_SEC[SC_HILITE].wal0 + i].walk   = -1;
       get_wall_info(num);
       lseek(fwal, 0, SEEK_END);
       write(fwal, &swpWAL, sizeof(swpWAL));
      }

      MAP_WAL[MAP_SEC[SC_HILITE].wal0].left_vx    = 0;
      MAP_WAL[MAP_SEC[SC_HILITE].wal0].right_vx   = 1;
      MAP_WAL[MAP_SEC[SC_HILITE].wal0+1].left_vx  = 1;
      MAP_WAL[MAP_SEC[SC_HILITE].wal0+1].right_vx = 2;
      MAP_WAL[MAP_SEC[SC_HILITE].wal0+2].left_vx  = 2;
      MAP_WAL[MAP_SEC[SC_HILITE].wal0+2].right_vx = 3;
      MAP_WAL[MAP_SEC[SC_HILITE].wal0+3].left_vx  = 3;
      MAP_WAL[MAP_SEC[SC_HILITE].wal0+3].right_vx = 0;

     strcpy(swpSEC.name,"");
     lseek(fsec, 0, SEEK_END);
     write(fsec, &swpSEC, sizeof(swpSEC));

     /* update the adjoins/mirrors/walks */
      MAP_WAL[MAP_SEC[SC_HILITE].wal0].adjoin    = MAP_WAL[num].sec;
      MAP_WAL[MAP_SEC[SC_HILITE].wal0].walk      = MAP_WAL[num].sec;
      MAP_WAL[MAP_SEC[SC_HILITE].wal0].mirror    = GetRelativeWLfromAbsoluteWL(num);

      MAP_WAL[num].adjoin = SC_HILITE;
      MAP_WAL[num].walk   = SC_HILITE;
      MAP_WAL[num].mirror = 0;

     MODIFIED = 1;
     return(GetSectorWL(SC_HILITE, 0));
    }
   else
    {
     message_out_of_vxwl();
     return(0);
    }
   }
 else
  {
   message_out_of_sectors();
   return(0);
  }
}

void message_out_of_sectors(void)
{
   gr_shutdown();
   printf("Not enough allocated SECTORS !!!\n\n");
   printf("Use [F3] to SAVE and RELOAD level.\n");
   printf("This will discard deleted sectors and reallocate new ones.\n\n\n");
   printf("Press Any Key To Continue\n");
   HideCursor();
   getVK();
   gr_startup();
   handle_titlebar(HEAD_BACK, HEAD_BORDER);
}

void message_out_of_vxwl(void)
{
   gr_shutdown();
   printf("Not enough allocated VERTICES or WALLS !!!\n\n");
   printf("Use [F3] to SAVE and RELOAD level.\n");
   printf("This will discard deleted objects and reallocate new ones.\n\n\n");
   printf("Press Any Key To Continue\n");
   HideCursor();
   getVK();
   gr_startup();
   handle_titlebar(HEAD_BACK, HEAD_BORDER);
}

void message_out_of_ob(void)
{
   gr_shutdown();
   printf("Not enough allocated OBJECTS !!!\n\n");
   printf("Use [F3] to SAVE and RELOAD level.\n");
   printf("This will discard deleted objects and reallocate new ones.\n\n\n");
   printf("Press Any Key To Continue\n");
   HideCursor();
   getVK();
   gr_startup();
   handle_titlebar(HEAD_BACK, HEAD_BORDER);
}

void messageTRANSFER_SEL(void)
{
 setcolor(HEAD_FORE);
 rectangle(0,0, TITLE_BOX_X / 2 + 1, 60);
 setfillstyle(SOLID_FILL, HILI_AT_ALT);
 floodfill(10,10, HEAD_FORE);
 outtextxy(5, 5, "Transfer the (multi)selection ?");
 outtextxy(5,35, "Press [Enter] to Transfer");
 outtextxy(5,50, "OR Any Other Key To Continue");
}
