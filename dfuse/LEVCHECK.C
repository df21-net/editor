/* ========================================================================== */
/* LEVCHECK.C : LEVEL CONSISTENCY CHECK                                       */
/* ========================================================================== */
#include "levmap.h"
#include "levext.h"

/* ************************************************************************** */
/* CHECK LEVEL AND GENERATE REPORT                                            */
/* ************************************************************************** */

void check_level(void)
{
 int   i;
 int   ret;
 char  tmp[127];
 FILE  *fchk;
 int   sector;
 int   relwall;
 int   adjoin;
 int   mirror;
 int   walk;
 int   found;

 fchk = fopen("checks.$$$" , "wt");
 /* if(fchk == NULL) error checking */;

 printf("Generating Report...\n");

 fprintf(fchk,"GEOMETRY CONSISTENCY CHECKS\n");
 fprintf(fchk,"===========================\n\n");

 fprintf(fchk,"ADJOIN/MIRROR/WALK CONSISTENCY\n");
 fprintf(fchk,"------------------------------\n\n");

 for(i=0; i<=wall_max; i++)
  {
   sector  = MAP_WAL[i].sec;
   relwall = GetRelativeWLfromAbsoluteWL(i);
   ret = check_adjoin_mirror(i);
   if(i != 0)
    switch(ret)
     {
      case  1 : fprintf(fchk,"WARN  : Adjoin -1, mirror not            SC/WL: %-4d/%-4d AbsWL: %-4d \n", sector, relwall, i);
                break;
      case  2 : fprintf(fchk,"WARN  : Adjoin -1, walk not              SC/WL: %-4d/%-4d AbsWL: %-4d \n", sector, relwall, i);
                break;
      case  3 : fprintf(fchk,"WARN  : Adjoin -1, mirror & walk not     SC/WL: %-4d/%-4d AbsWL: %-4d \n", sector, relwall, i);
                break;
      case -1 : fprintf(fchk,"ERROR : Adjoin doesn't exist             SC/WL: %-4d/%-4d AbsWL: %-4d \n", sector, relwall, i);
                break;
      case -2 : fprintf(fchk,"ERROR : Adjoin is deleted                SC/WL: %-4d/%-4d AbsWL: %-4d \n", sector, relwall, i);
                break;
      case -3 : fprintf(fchk,"ERROR : Adjoin exists, mirror = -1       SC/WL: %-4d/%-4d AbsWL: %-4d \n", sector, relwall, i);
                break;
      case -4 : fprintf(fchk,"ERROR : Mirror doesn't exist             SC/WL: %-4d/%-4d AbsWL: %-4d \n", sector, relwall, i);
                break;
      case -5 : fprintf(fchk,"ERROR : Reverse adjoin not correct       SC/WL: %-4d/%-4d AbsWL: %-4d \n", sector, relwall, i);
                break;
      case -6 : fprintf(fchk,"ERROR : Reverse mirror not correct       SC/WL: %-4d/%-4d AbsWL: %-4d \n", sector, relwall, i);
                break;
     }
  }

 fprintf(fchk,"\nSECTOR CHECKS\n");
 fprintf(fchk,"-------------\n\n");


 for(i=0; i<=sector_max; i++)
  {
   if(MAP_SEC[i].vno != MAP_SEC[i].wno)
    fprintf(fchk,"WARN  : Number of VX and WL don't match     SC: %4d\n", i);
  }

 fprintf(fchk,"\n");

 for(i=0; i<=sector_max; i++)
  {
   if(-MAP_SEC[i].floor_alt > -MAP_SEC[i].ceili_alt)
    fprintf(fchk,"ERROR : Floor higher than Ceiling           SC: %4d\n", i);
  }

 fprintf(fchk,"\nOBJECTS CONSISTENCY CHECKS\n");
 fprintf(fchk,"==========================\n\n");

 if(OBJECT_LAYERING == 1)
  for(i=0; i<=obj_max; i++)
   {
    if(MAP_OBJ[i].del == 0)
     {
      if(MAP_OBJ[i].sec == -1)
       fprintf(fchk,"WARN  : No sector found for object          OB: %4d\n", i);
      else
       if(MAP_SEC[MAP_OBJ[i].sec].del != 0)
        fprintf(fchk,"ERROR : Object is in deleted sector         OB: %4d  SC: %4d\n", i, MAP_OBJ[i].sec);
     }
   }
 else
  fprintf(fchk,"INFO  : object layering DISABLED, no sector check made\n");

 found = 0;
 for(i=0; i<=obj_max; i++)
  {
   get_object_info(i);
   if(strcmp(swpOBJ.logic, "PLAYER") == 0)
    {
     found++;
    }
  }

 fprintf(fchk,"\n");

 if(found == 0)
  fprintf(fchk,"ERROR : No PLAYER START object\n", i);

 if(found > 1)
  fprintf(fchk,"ERROR : Too many PLAYER STARTs              # : %4d\n", found);


 fprintf(fchk,"\nINF CONSISTENCY CHECKS\n");
 fprintf(fchk,"======================\n\n");

 if(inf_max + 1 != INF_ITEMS)
  fprintf(fchk,"ERROR : 'items %d' should be 'items %d'\n", INF_ITEMS, inf_max + 1);



 fclose(fchk);

 sprintf(tmp, call_editor, "checks.$$$");
 system(tmp);
 remove("checks.$$$");
}

/* ************************************************************************** */
/* CHECK EXISTENCE OF ADJOINS/MIRRORS                                         */
/* ************************************************************************** */

/* return codes : 0  ok, mirror exists      */
/*                   OR no mirror           */
/* ERRORS                                   */
/*               -1  adjoin doesn't exist   */
/*               -2  adjoin is deleted      */
/*               -3  adj exists,mirror -1   */
/*               -4  mirror doesn't exist   */
/*               -5  reverse adjoin BAD     */
/*               -6  reverse mirror BAD     */
/* WARNINGS                                 */
/*                1  adjoin -1, mirror not  */
/*                2  adjoin -1, walk   not  */
/*                3  adjoin -1, mir & walk  */

int check_adjoin_mirror(int wall)
{
  int sector;
  int relwall;
  int adjoin;
  int mirror;
  int walk;

  sector  = MAP_WAL[wall].sec;
  relwall = GetRelativeWLfromAbsoluteWL(wall);
  adjoin  = MAP_WAL[wall].adjoin;
  mirror  = MAP_WAL[wall].mirror;
  walk    = MAP_WAL[wall].walk;

  if(adjoin == -1)
   {
    if(mirror != -1)
     if(walk != -1)
      return(3);
     else
      return(1);
    else
     if(walk != -1)
      return(2);
     else
      return(0);
   }

  if((adjoin < 0) || (adjoin > sector_max))
    return(-1);
  if(MAP_SEC[adjoin].del !=0 )
    return(-2);
  if(mirror == -1 )
    return(-3);
  if((mirror<0) || (mirror>=MAP_SEC[adjoin].wno))
    return(-4);
  if(MAP_WAL[GetSectorWL(adjoin,mirror)].adjoin != sector)
    return(-5);
  if(MAP_WAL[GetSectorWL(adjoin,mirror)].mirror != relwall)
    return(-6);

  return(0);
}

