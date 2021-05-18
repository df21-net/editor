/* ========================================================================== */
/* LEVMAP2.C  : unclutter levmap.c (obj too big!)                             */
/*              don't forget levmap.c is the core and isn't overlayed!        */
/*              the message boxes                                             */
/* ========================================================================== */

#include "levmap.h"
#include "levext.h"

void read_level(void)
{
 sector_ix              = -1;
 vertex_ix              = 0;
 wall_ix                = 0;
 obj_ix                 = -1;
 maxx                   = -32000;
 maxz                   = -32000;
 minx                   =  32000;
 minz                   =  32000;
 /* read the level */
 handle_lev_file();
 sector_max = sector_ix;
 vertex_max = vertex_ix - 1;
 wall_max   = wall_ix - 1;
 handle_o_file();
 obj_max    = obj_ix;
 handle_inf_file(0);           /* need sector_max !  0 = not silently */
 inf_max = inf_ix;
 if(OBJECT_LAYERING == 1) layer_objects();
}

void show_memory(void)
{
  gr_shutdown();
  printf("LEVMAP "LEVMAP_VERSION"\n");
  printf("(c) Yves BORCKMANS 1995 (yborckmans@abcomp.be)\n\n");
  printf("  Objects       Loaded  Alloc   Free\n");
  printf("  ------------------------------------\n");
  printf("  SECTORS .....  %4d    %4d    %4d\n",     sector_max+1, sector_alloc, sector_alloc-sector_max-1);
  printf("  WALLS .......  %4d    %4d    %4d\n",     wall_max+1  , wall_alloc  , wall_alloc - wall_max-1);
  printf("  VERTICES ....  %4d    %4d    %4d\n",     vertex_max+1, vertex_alloc, vertex_alloc-vertex_max-1);
  printf("  OBJECTS .....  %4d    %4d    %4d\n",     obj_max+1,    obj_alloc  , obj_alloc - obj_max - 1);
  printf("  TEXTURES ....  %4d    DISK     N/A\n",   texture_max+1);
  printf("  PODS ........  %4d    DISK     N/A\n",   pod_max+1);
  printf("  SPRITES .....  %4d    DISK     N/A\n",   spr_max+1);
  printf("  FRAMES ......  %4d    DISK     N/A\n",   fme_max+1);
  printf("  SOUNDS ......  %4d    DISK     N/A\n\n", sound_max+1);
  printf("Far core left : %lu bytes\n", farcoreleft());
  getVK();
  gr_startup();
  handle_titlebar(HEAD_BACK, HEAD_BORDER);
}

void edit_gol(void)
{
  char tmp[127];

  gr_shutdown();
  sprintf(tmp, call_editor, fname_gol);
  system(tmp);
  gr_startup();
  handle_titlebar(HEAD_BACK, HEAD_BORDER);
}

void edit_inf(void)
{
  int i;
  char tmp[127];

  gr_shutdown();
  sprintf(tmp, call_editor, fname_inf);
  system(tmp);
  gr_startup();
  /* clear the SC and WL elev & trig, but not if flag 2/64 */
  /* then reread INF                                       */
  for(i=0; i <= wall_max;   i++) MAP_WAL[i].trig = 0;
  for(i=0; i <= sector_max; i++)
   {
    MAP_SEC[i].trig = 0;
    get_sector_info(i);
    if((swpSEC.flag1 & 2) || (swpSEC.flag1 & 64))
      MAP_SEC[i].elev = 1;
    else
      MAP_SEC[i].elev = 0;
   }
  handle_inf_file(0);
  clearviewport();
  handle_titlebar(HEAD_BACK, HEAD_BORDER);
}

void jump_to_thing(void)
{
  char tmp[127];

  setviewport(0, 0, getmaxx(), getmaxy(), 1);
  switch(MAP_MODE)
   {
    case 0 :
            itoa(SC_HILITE, tmp,10);
            if(stredit(58, 36, tmp, 4, 5, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
             {
              SC_HILITE = atoi(tmp);
              if(SC_HILITE > sector_max ) SC_HILITE = 0;
              if(SC_HILITE < 0) SC_HILITE = sector_max;
              xoffset = MAP_VRT[GetSectorVX(SC_HILITE,0)].x;
              yoffset = MAP_VRT[GetSectorVX(SC_HILITE,0)].z;
              LAYER   = MAP_SEC[SC_HILITE].layer;
             }
            break;
    case 1 :
            itoa(WL_HILITE, tmp,10);
            if(stredit(58, 36, tmp, 4, 5, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
             {
              WL_HILITE = atoi(tmp);
              if(WL_HILITE > wall_max ) WL_HILITE = 0;
              if(WL_HILITE < 0) WL_HILITE = wall_max;
              xoffset = MAP_VRT[GetSectorVX(MAP_WAL[WL_HILITE].sec, MAP_WAL[WL_HILITE].left_vx)].x;
              yoffset = MAP_VRT[GetSectorVX(MAP_WAL[WL_HILITE].sec, MAP_WAL[WL_HILITE].left_vx)].z;
              LAYER   = MAP_SEC[MAP_WAL[WL_HILITE].sec].layer;
             }
            break;
    case 2 :
            itoa(VX_HILITE, tmp,10);
            if(stredit(58, 36, tmp, 4, 5, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
             {
              VX_HILITE = atoi(tmp);
              if(VX_HILITE > vertex_max ) VX_HILITE = 0;
              if(VX_HILITE < 0) VX_HILITE = vertex_max;
              xoffset = MAP_VRT[VX_HILITE].x;
              yoffset = MAP_VRT[VX_HILITE].z;
              LAYER   = MAP_SEC[MAP_VRT[VX_HILITE].sec].layer;
             }
            break;
    case 3 :
            itoa(OB_HILITE, tmp,10);
            if(stredit(58, 36, tmp, 4, 5, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
             {
              OB_HILITE = atoi(tmp);
              if(OB_HILITE > obj_max ) OB_HILITE = 0;
              if(OB_HILITE < 0) OB_HILITE = obj_max;
              xoffset = MAP_OBJ[OB_HILITE].x;
              yoffset = MAP_OBJ[OB_HILITE].z;
             }
            break;
   }

  clearviewport();
  handle_titlebar(HEAD_BACK, HEAD_BORDER);
}

void find_thing(void)
{
  int i;
  FILE  *ftmp;
  char tmp[127];

  switch(MAP_MODE)
   {
    case 0 :
            ftmp = fopen("temp\\snames.$$$" , "wt");
            for(i=0; i<=sector_max; i++)
             {
              get_sector_info(i);
              if(swpSEC.name[0] != '\0')
               {
                if(MAP_SEC[SC_HILITE].del == 0)
                 fprintf(ftmp, "%s\n", swpSEC.name);
                else
                 fprintf(ftmp, "%s *DEL*\n", swpSEC.name);
               }
             }
            fclose(ftmp);
            system("type temp\\snames.$$$ | sort > temp\\snames.$$$");
            if(listpick(318, 198, "Please pick a sector", "temp\\snames.$$$", tmp,
               HEAD_FORE, 0, HEAD_BORDER, HILI_AT_ALT) != -1)
             {
              i = 0;
              get_sector_info(i);
              while((strcmp(swpSEC.name, tmp) != 0) && (i<=sector_max))
               {
                get_sector_info(++i);
               }
              SC_HILITE = i;
              if(SC_HILITE > sector_max ) SC_HILITE = 0;
              if(SC_HILITE < 0) SC_HILITE = sector_max;
              xoffset = MAP_VRT[GetSectorVX(SC_HILITE,0)].x;
              yoffset = MAP_VRT[GetSectorVX(SC_HILITE,0)].z;
              LAYER   = MAP_SEC[SC_HILITE].layer;
             }
            remove("temp\\snames.$$$");
            break;
    case 1 : if(MAP_WAL[WL_HILITE].adjoin != -1)
              {
               handle_title(COLOR_ERASER);
               WL_HILITE = GetSectorWL(MAP_WAL[WL_HILITE].adjoin, MAP_WAL[WL_HILITE].mirror);
               LAYER     = MAP_SEC[MAP_WAL[WL_HILITE].sec].layer;
              }
              break;
    case 3 : handle_title(COLOR_ERASER);
             for(i=0; i<=obj_max; i++)
             {
              get_object_info(i);
              if(strcmp(swpOBJ.logic, "PLAYER") == 0)
               {
                OB_HILITE = i;
                break;
               }
             }
             break;
   }
  clearviewport();
  handle_titlebar(HEAD_BACK, HEAD_BORDER);
}

/* ************************************************************************** */
/* SOME MESSAGE BOXES                                                         */
/* ************************************************************************** */

void messageOK(char *the_message)
{
 setcolor(HEAD_FORE);
 rectangle(0,0, TITLE_BOX_X / 2 + 1, 40);
 setfillstyle(SOLID_FILL, HILI_AT_ALT);
 floodfill(10,10, HEAD_FORE);
 outtextxy(5,5, the_message);
 outtextxy(5,25, "Press Any Key To Continue");
 getVK();
}

void messageSAVE(void)
{
 setcolor(HEAD_FORE);
 rectangle(0,0, TITLE_BOX_X / 2 + 1, 45);
 setfillstyle(SOLID_FILL, HILI_AT_ALT);
 floodfill(10,10, HEAD_FORE);
 outtextxy(5, 5, "LEVMAP is going to SAVE the level.");
 outtextxy(5,20, "   Press [Esc] to Cancel");
 outtextxy(5,35, "OR Any Other Key To Continue");
}

void messageQUIT(void)
{
 setcolor(HEAD_FORE);
 rectangle(0,0, TITLE_BOX_X / 2 + 1, 60);
 setfillstyle(SOLID_FILL, HILI_AT_ALT);
 floodfill(10,10, HEAD_FORE);
 outtextxy(5, 5, "You have UNSAVED changes.");
 outtextxy(5,20, "   Press [F2]    to Save");
 outtextxy(5,35, "OR Press [Enter] to Quit w/o Saving");
 outtextxy(5,50, "OR Any Other Key To Return to LEVMAP");
}

void messageREREAD(void)
{
 setcolor(HEAD_FORE);
 rectangle(0,0, TITLE_BOX_X / 2 + 1, 45);
 setfillstyle(SOLID_FILL, HILI_AT_ALT);
 floodfill(10,10, HEAD_FORE);
 outtextxy(5, 5, "LEVMAP is going to SAVE & REREAD.");
 outtextxy(5,20, "   Press [Esc] to Cancel");
 outtextxy(5,35, "OR Any Other Key To Continue");
}

