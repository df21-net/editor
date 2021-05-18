/* ========================================================================== */
/* LEV_____.C : DELETED ROUTINES FROM OTHER MODULES                           */
/*              kept as reference, or if ...                                  */
/*              This file ISN'T in the MAKE process                           */
/* ========================================================================== */

/* -------------------------------------------------------------------------- */
/* FROM LEVMAP.C  in case VK_C_LBUTT :                                        */
/* -------------------------------------------------------------------------- */

                 case 0 :
                         if((new_object = get_next_nearest_SC(S2MXF(mx),S2MYF(my))) != -1)
                          {
                           handle_title(COLOR_ERASER);
                           SC_HILITE = new_object;
                           clearviewport();
                          }
                         break;
                 case 1 :
                         if((new_object = get_next_nearest_WL(S2MXF(mx),S2MYF(my))) != -1)
                          {
                           handle_title(COLOR_ERASER);
                           WL_HILITE = new_object;
                           clearviewport();
                          }
                         break;




/* -------------------------------------------------------------------------- */
/* FROM LEVINFOF.C                                                            */
/* -------------------------------------------------------------------------- */

/* OLD VERSION */
int  get_nearest_SC(float x, float z)
{
 int vx;

 if((vx = get_nearest_VX(x,z)) != -1)
   return(MAP_VRT[vx].sec);
 else
   return(-1);
}

/* OLD VERSION */
int  get_nearest_WL(float x, float z)
{
 int vx;

 if((vx = get_nearest_VX(x,z)) != -1)
   return(GetAbsoluteWLfromVXF(vx));
 else
   return(-1);
}

/* SUPPRESSED BECAUSE THE NEW get_nearest_SC and WL don't need this anymore */
int  get_next_nearest_SC(float x, float z);
int  get_next_nearest_WL(float x, float z);

int  get_next_nearest_SC(float x, float z)
{
 int vx;
 VX_HILITE = get_nearest_VX(x,z);

 if((vx = get_next_nearest_VX(x,z)) != -1)
   return(MAP_VRT[vx].sec);
 else
   return(-1);
}

int  get_next_nearest_WL(float x, float z)
{
 int vx;

 VX_HILITE = get_nearest_VX(x,z);
 if((vx = get_next_nearest_VX(x,z)) != -1)
   return(GetAbsoluteWLfromVXF(vx));
 else
   return(-1);
}


/* -------------------------------------------------------------------------- */
/* FROM LEVCHECK.C                                                            */
/* -------------------------------------------------------------------------- */

 fprintf(fchk,"LEVEL NAMES CONSISTENCY\n");
 fprintf(fchk,"-----------------------\n\n");

 if(stricmp(MAP_NAME, MAP_NAME_O) == 0)
   fprintf(fchk,"Ok.\n\n");
 else
   fprintf(fchk,"WARN  : LEV name and O name differ       %s %s\n\n", MAP_NAME, MAP_NAME_O);

