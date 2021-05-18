/* ========================================================================== */
/* LEVMAP.C   : MAIN PROGRAM                                                  */
/*              don't forget levmap.c is the core and isn't overlayed!        */
/* ========================================================================== */

#include "levmap.h"
#include "levglo.h"

/* ************************************************************************** */
/* MAIN MAP FUNCTIONS                                                         */
/* ************************************************************************** */

void set_mode_map()
{
 gr_startup();
 cleardevice();

 InitMouseDriver();
 if(MousePresent) create_mouse();

 handle_titlebar(HEAD_BACK, HEAD_BORDER);
 handle_loading(HEAD_FORE);
 read_level();
 handle_loading(COLOR_ERASER);
 clearviewport();
 set_map_centered();

 /* draw header */
 handle_title(HEAD_FORE);
 draw_the_map();

 while(ccc != VK_ESC)
  {
   while(!VKhit())
    {
     handle_mouse();
    }
   ccc=getVK();
   if(MousePresent)
    {
     hide_mouse(oldmx, oldmy);
     oldmx = -32000;
    }
   /* handle keyboard input */
   handle_mapkinput();

   if(ccc != VK_ESC)
    {
     handle_title(HEAD_FORE);
     draw_the_map();
    }
  };
}

void handle_mapkinput(void)
{
  char  tmp[127];
  int   mx,my;
  int   new_object;
  int   sector;
  int   i,j;
  int   the_vx;
  float x,z;
  int   shifted=0;
  int   key;
  int   handled=0;
  int   count=0;

  switch(ccc)
   {
    case  VK_LEFT :
               xoffset += 100 * REVERSE / scale;
               clearviewport();
               break;
    case  VK_RIGHT :
               xoffset -= 100 * REVERSE / scale;
               clearviewport();
               break;
    case  VK_UP :
               yoffset -= 100 * REVERSE / scale;
               clearviewport();
               break;
    case  VK_DOWN :
               yoffset += 100 * REVERSE / scale;
               clearviewport();
               break;
    case VK_A_R : /* reverse cursors */
               REVERSE = -REVERSE;
               break;
    case '-' : /* - : zoom out */
               handle_title(COLOR_ERASER);
               scale   /= 1.4142135;
               clearviewport();
               break;
    case '+' : /* + : zoom in */
               handle_title(COLOR_ERASER);
               scale   *= 1.4142135;
               clearviewport();
               break;
    case '/' : /* / : center map */
               set_map_centered();
               clearviewport();
               break;
    case '*' : /* * : set scale to 1 */
               handle_title(COLOR_ERASER);
               scale = 1.0;
               clearviewport();
               break;
    case  VK_PGUP : /* layer ++ */
               handle_title(COLOR_ERASER);
               if(LAYER < maxlayer) LAYER++;
               clearviewport();
               break;
    case  VK_PGDN : /* layer -- */
               handle_title(COLOR_ERASER);
               if(LAYER > minlayer) LAYER--;
               clearviewport();
               break;
/* -------------------------------------------------------------------------- */
    case 'A' :
    case 'a' : /* tries to find an adjoin/mirror pair */
               switch(MAP_MODE)
                {
                 case 1 : handle_title(COLOR_ERASER);
                          if(MULTISEL == 0)
                           j = make_adjoin(WL_HILITE);
                          else
                           {
                            j = 0;
                            for(i=0; i<=wall_max; i++)
                             if(MAP_WAL[i].mark != 0)
                              j += make_adjoin(i);
                           }
                          handle_title(HEAD_FORE);
                          if(j != 0)
                           {
                            sprintf(tmp, "Made %4d adjoins/mirrors !!", j);
                            messageOK(tmp);
                           }
                          else
                            messageOK("No Adjoin found !!");
                          break;
                }
               clearviewport();
               break;
    case VK_A_A : /* unadjoins */
               switch(MAP_MODE)
                {
                 case 1 : handle_title(COLOR_ERASER);
                          if(MULTISEL == 0)
                            j = un_adjoin(WL_HILITE);
                          else
                           {
                            j = 0;
                            for(i=0; i<=wall_max; i++)
                             if(MAP_WAL[i].mark != 0)
                              j += un_adjoin(i);
                           }
                          handle_title(HEAD_FORE);
                          if(j != 0)
                           {
                            sprintf(tmp, "Removed %4d adjoins/mirrors !!", j);
                            messageOK(tmp);
                           }
                          else
                            messageOK("No Adjoin found !!");
                }
               clearviewport();
               break;
    case 'c' :
               GetMousePos(&mx, &my);
               xoffset = S2MX(mx);
               yoffset = S2MY(my);
               if(CENTERZOOM == 1)
                {
                 handle_title(COLOR_ERASER);
                 scale   *= 4;
                }
               clearviewport();
               break;
    case 'C' :
               GetMousePos(&mx, &my);
               xoffset = S2MX(mx);
               yoffset = S2MY(my);
               if(CENTERZOOM != 1)
                {
                 handle_title(COLOR_ERASER);
                 scale   *= 4;
                }
               clearviewport();
               break;
    case VK_A_C : /* memory issues */
               show_memory();
               break;
    case 'D' :
    case 'd' : /* deformations */
               edit_deform();
               clearviewport();
               break;
    case 'E' :
    case 'e' : /* extrude wall creating 4 walls "door-like" */
               switch(MAP_MODE)
                {
                 case 1 : if(MAP_WAL[WL_HILITE].adjoin == -1)
                           {
                            handle_title(COLOR_ERASER);
                            WL_HILITE = extrude_wall4(WL_HILITE);
                           }
                          else
                            messageOK("Cannot extrude WL with ADJOIN !");
                          break;
                }
               clearviewport();
               break;
    case 'F' :
    case 'f' : /* find a specific sector by name */
               /* or the mirror of a wall        */
               find_thing();
               break;
    case VK_A_F : /* flip wall */
               handle_title(COLOR_ERASER);
               switch(MAP_MODE)
                {
                 case 1 : if(MULTISEL == 0)
                           flip_wall(WL_HILITE);
                          else
                            for(i=0; i<=wall_max; i++)
                             if(MAP_WAL[i].mark != 0)
                              flip_wall(i);
                          break;
                }
               clearviewport();
               break;
    case 'g' : /* grid smaller */
               handle_title(COLOR_ERASER);
               if(grid > 1) grid /= 2;
               clearviewport();
               break;
    case 'G' : /* grid bigger */
               handle_title(COLOR_ERASER);
               if(grid<128) grid *= 2;
               clearviewport();
               break;
    case VK_A_G : /* toggle grid */
               handle_title(COLOR_ERASER);
               if(GRID == 0)
                GRID = 1;
               else
                GRID = 0;
               clearviewport();
               break;
    case VK_C_G : /* multi toggle perpendiculars */
               handle_title(COLOR_ERASER);
               if(PERPS == 0)
                PERPS = 1;
               else
                if(PERPS == 1)
                 PERPS = 2;
                else
                 PERPS = 0;
               clearviewport();
               break;
    case 'I' : /* edit .GOL */
               edit_gol();
               break;
    case 'i' : /* edit .INF */
               edit_inf();
               break;
    case 'J' :
    case 'j' : /* jump to a specific object, ... */
               jump_to_thing();
               break;
    case VK_A_K :
               NGON_GAP = 1;
               /* NO Break !! */
    case 'K' :
    case 'k' : /* n-gon */
               if(MAP_MODE != 0) { NGON_GAP = 0; break; }
               edit_ngon();
               clearviewport();
               NGON_GAP = 0;
               break;
    case VK_C_K :
               if(MAP_MODE != 0) break;
               NGON_GAP = 1;
               edit_ngon();
               construct_ngon();
               for(i=0; i<=wall_max; i++)
                {
                 if(MAP_WAL[i].sec == sector_max) make_adjoin(i);
                }
               clearviewport();
               NGON_GAP = 0;
               break;
    case 'M' :
    case 'm' : /* edit level */
               gr_shutdown();
               edit_level();
               gr_startup();
               handle_titlebar(HEAD_BACK, HEAD_BORDER);
               break;
    case 'N' :
    case 'n' : /* next object */
               handle_title(COLOR_ERASER);
               switch(MAP_MODE)
                {
                 case 0 :
                         SC_HILITE++;
                         if(SC_HILITE > sector_max ) SC_HILITE = 0;
                         break;
                 case 1 : new_object = GetRelativeWLfromAbsoluteWL(WL_HILITE);
                          if(new_object == MAP_SEC[MAP_WAL[WL_HILITE].sec].wno - 1)
                            new_object = -1;
                          WL_HILITE = GetSectorWL(MAP_WAL[WL_HILITE].sec, new_object+1);
                          break;
                 case 2 : new_object = GetRelativeVXfromAbsoluteVX(VX_HILITE);
                          if(new_object == MAP_SEC[MAP_VRT[VX_HILITE].sec].vno - 1)
                            new_object = -1;
                          VX_HILITE = GetSectorVX(MAP_VRT[VX_HILITE].sec, new_object+1);
                          break;
                 case 3 :
                         OB_HILITE++;
                         if(OB_HILITE > obj_max ) OB_HILITE = 0;
                         break;
                }
               clearviewport();
               break;
    case VK_A_N : /* 50th next SC or OB                */
                  /* or next VX or WL IN THE SAME SC ! */
               handle_title(COLOR_ERASER);
               switch(MAP_MODE)
                {
                 case 0 : SC_HILITE += 50;
                          if(SC_HILITE > sector_max) SC_HILITE = 0;
                          break;
                 case 1 :
                         WL_HILITE++;
                         if(WL_HILITE > wall_max ) WL_HILITE = 0;
                         break;
                 case 2 :
                         VX_HILITE++;
                         if(VX_HILITE > vertex_max ) VX_HILITE = 0;
                         break;
                 case 3 : OB_HILITE += 50;
                          if(OB_HILITE > obj_max) OB_HILITE = 0;
                          break;
                }
               clearviewport();
               break;
    case 'O' :
    case 'o' :
    case 'T' :
    case 't' : /* SET MODE OBJECTS */
               handle_title(COLOR_ERASER);
               switch(MAP_MODE)
                {
                 case 0 : if(MULTISEL) clear_multi_sector();
                          break;
                 case 1 : if(MULTISEL) clear_multi_wall();
                          break;
                 case 2 : if(MULTISEL) clear_multi_vertex();
                          break;
                }
               MAP_MODE = 3;
               strcpy(MAP_MODE_NAMEL, "OBJECTS");
               strcpy(MAP_MODE_NAMES, "OB");
               clearviewport();
               break;
    case VK_A_O: /* toggle object layering */
               if(OBJECT_LAYERING == 1)
                {
                 OBJECT_LAYERING = 0;
                 handle_title(COLOR_ERASER);
                 clearviewport();
                }
               else
                {
                 OBJECT_LAYERING = 1;
                 clearviewport();
                 handle_title(COLOR_ERASER);
                 layer_objects();
                 clearviewport();
                }
               break;
    case VK_C_O: /* object layering: retry misses */
               if(OBJECT_LAYERING == 1)
                {
                 clearviewport();
                 handle_title(COLOR_ERASER);
                 setcolor(HEAD_FORE);
                 outtextxy(0,136,"Quick layering objects.");
                 for(i = 0; i <= obj_max; i++)
                  {
                   if(MAP_OBJ[i].sec == -1)
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
                 sprintf(tmp, "There are %d unlinked object(s) !", count);
                 messageOK(tmp);
                 clearviewport();
                }
               break;
    case 'P' :
    case 'p' : /* previous object */
               handle_title(COLOR_ERASER);
               switch(MAP_MODE)
                {
                 case 0 :
                         SC_HILITE--;
                         if(SC_HILITE < 0) SC_HILITE = sector_max;
                         break;
                 case 1 : new_object = GetRelativeWLfromAbsoluteWL(WL_HILITE);
                          if(new_object == 0)
                            new_object = MAP_SEC[MAP_WAL[WL_HILITE].sec].wno;
                          WL_HILITE = GetSectorWL(MAP_WAL[WL_HILITE].sec, new_object-1);
                          break;
                 case 2 : new_object = GetRelativeVXfromAbsoluteVX(VX_HILITE);
                          if(new_object == 0)
                            new_object = MAP_SEC[MAP_VRT[VX_HILITE].sec].vno;
                          VX_HILITE = GetSectorVX(MAP_VRT[VX_HILITE].sec, new_object-1);
                          break;
                 case 3 :
                         OB_HILITE--;
                         if(OB_HILITE < 0) OB_HILITE = obj_max;
                         break;
                }
               clearviewport();
               break;
    case VK_A_P : /* 50th previous SC or OB */
                  /* or prev VX or WL IN THE SAME SC ! */
               handle_title(COLOR_ERASER);
               switch(MAP_MODE)
                {
                 case 0 : SC_HILITE -= 50;
                          if(SC_HILITE < 0) SC_HILITE = sector_max;
                          break;
                 case 1 :
                         WL_HILITE--;
                         if(WL_HILITE < 0) WL_HILITE = wall_max;
                         break;
                 case 2 :
                         VX_HILITE--;
                         if(VX_HILITE < 0) VX_HILITE = vertex_max;
                         break;
                 case 3 : OB_HILITE -= 50;
                          if(OB_HILITE < 0) OB_HILITE = obj_max;
                          break;
                }
               clearviewport();
               break;
    case 'S' :
    case 's' : /* SET MODE SECTOR */
               switch(MAP_MODE)
                {
                 case 1 : SC_HILITE = MAP_WAL[WL_HILITE].sec;
                          if(MULTISEL) clear_multi_wall();
                          break;
                 case 2 : SC_HILITE = MAP_VRT[VX_HILITE].sec;
                          if(MULTISEL) clear_multi_vertex();
                          break;
                 case 3 : if(MULTISEL) clear_multi_object();
                          break;
                }
               handle_title(COLOR_ERASER);
               MAP_MODE = 0;
               strcpy(MAP_MODE_NAMEL, "SECTORS");
               strcpy(MAP_MODE_NAMES, "SC");
               clearviewport();
               break;
    case VK_A_S : /* toggle shadow */
               if(SHADOW == 0)
                SHADOW = 1;
               else
                {
                 SHADOW = 0;
                 clearviewport();
                }
               break;
    case 'V' :
    case 'v' : /* SET MODE VERTEX */
               switch(MAP_MODE)
                {
                 case 0 : VX_HILITE = MAP_SEC[SC_HILITE].vrt0;
                          if(MULTISEL) convert_multi_SC2VX();
                          break;
                 case 1 : VX_HILITE = GetAbsoluteVXFfromWL(WL_HILITE);
                          if(MULTISEL) convert_multi_WL2VX();
                          break;
                 case 3 : if(MULTISEL) clear_multi_object();
                          break;
                }
               handle_title(COLOR_ERASER);
               MAP_MODE = 2;
               strcpy(MAP_MODE_NAMEL, "VERTICES");
               strcpy(MAP_MODE_NAMES, "VX");
               clearviewport();
               break;
    case 'W' :
    case 'w' :
    case 'L' :
    case 'l' : /* SET MODE WALLS */
               switch(MAP_MODE)
                {
                 case 0 : WL_HILITE = MAP_SEC[SC_HILITE].wal0;
                          if(MULTISEL) convert_multi_SC2WL();
                          break;
                 case 2 : WL_HILITE = GetAbsoluteWLfromVXF(VX_HILITE);
                          if(MULTISEL) clear_multi_vertex();
                          break;
                 case 3 : if(MULTISEL) clear_multi_object();
                          break;
                }
               handle_title(COLOR_ERASER);
               MAP_MODE = 1;
               strcpy(MAP_MODE_NAMEL, "WALLS");
               strcpy(MAP_MODE_NAMES, "WL");
               clearviewport();
               break;
    case 'z' :
    case 'Z' : gr_shutdown();
               Beep(100,20);
               printf("\n\n\nType 'exit' to return to LEVMAP.\n\n");
               system(getenv("COMSPEC"));
               gr_startup();
               handle_titlebar(HEAD_BACK, HEAD_BORDER);
               break;
/* -------------------------------------------------------------------------- */
    case VK_DEL : /* delete object */
               handle_title(COLOR_ERASER);
               switch(MAP_MODE)
                {
                 case 0 : if(MULTISEL == 0)
                           delete_sector(SC_HILITE);
                          else
                           delete_multi_sector();
                          break;
                 case 1 : if(MAP_WAL[WL_HILITE].adjoin == -1)
                           {
                            handle_title(COLOR_ERASER);
                            delete_wall(WL_HILITE);
                            if(WL_HILITE > 0) WL_HILITE--;
                           }
                          else
                            messageOK("Cannot delete WL that has an ADJOIN !");
                          break;
                 case 2 : /* delete_vertex(VX_HILITE); */
                          break;
                 case 3 : if(MULTISEL == 0)
                           delete_object(OB_HILITE);
                          else
                           delete_multi_object();
                          break;
                }
               clearviewport();
               break;
    case VK_A_DEL : /* undelete object */
               handle_title(COLOR_ERASER);
               switch(MAP_MODE)
                {
                 case 0 : if(MULTISEL == 0)
                           undelete_sector(SC_HILITE);
                          else
                           undelete_multi_sector();
                          break;
                 case 3 : if(MULTISEL == 0)
                           undelete_object(OB_HILITE);
                          else
                           undelete_multi_object();
                          break;
                }
               clearviewport();
               break;

    case VK_A_ENTER : /* edit multiple objects */
               if(MULTISEL != 0) APPLY_TO_MULTI = 1;
               /* !! no break, code follows !! */
    case VK_ENTER : /* edit object */
               switch(MAP_MODE)
                {
                 case 0 : edit_sector();
                          handle_titlebar(HEAD_BACK, HEAD_BORDER);
                          clearviewport();
                          break;
                 case 1 : edit_wall();
                          handle_titlebar(HEAD_BACK, HEAD_BORDER);
                          clearviewport();
                          break;
                 case 2 : edit_vertex();
                          handle_titlebar(HEAD_BACK, HEAD_BORDER);
                          clearviewport();
                          break;
                 case 3 : edit_object();
                          handle_titlebar(HEAD_BACK, HEAD_BORDER);
                          clearviewport();
                          break;
                }
               APPLY_TO_MULTI = 0;
               break;
    case VK_INS : /* insert object */
               switch(MAP_MODE)
                {
                 case 0 : handle_title(COLOR_ERASER);
                          if(GRID == 0)
                           if(MULTISEL == 0)
                            SC_HILITE = insert_sector(MAP_MOUSE_X, MAP_MOUSE_Z);
                           else
                            SC_HILITE = insert_sectors(MAP_MOUSE_X, MAP_MOUSE_Z);
                          else
                           if(MULTISEL == 0)
                            SC_HILITE = insert_sector(MAP_MOUSE_GX, MAP_MOUSE_GZ);
                           else
                            SC_HILITE = insert_sectors(MAP_MOUSE_GX, MAP_MOUSE_GZ);
                          break;
                 case 1 : handle_title(COLOR_ERASER);
                          WL_HILITE = split_wall(WL_HILITE);
                          break;
                 case 3 : handle_title(COLOR_ERASER);
                          if(GRID == 0)
                           if(MULTISEL == 0)
                            OB_HILITE = insert_object(MAP_MOUSE_X, MAP_MOUSE_Z);
                           else
                            OB_HILITE = insert_objects(MAP_MOUSE_X, MAP_MOUSE_Z);
                          else
                           if(MULTISEL == 0)
                            OB_HILITE = insert_object(MAP_MOUSE_GX, MAP_MOUSE_GZ);
                           else
                            OB_HILITE = insert_objects(MAP_MOUSE_GX, MAP_MOUSE_GZ);
                          break;
                }
               clearviewport();
               break;
    case VK_A_INS : /* insert object special ie sector gap */
               switch(MAP_MODE)
                {
                 case 0 : handle_title(COLOR_ERASER);
                          SC_HILITE = insert_sector_gap(MAP_MOUSE_X, MAP_MOUSE_Z);
                          break;
                }
               clearviewport();
               break;
/* -------------------------------------------------------------------------- */

    case '0'   : DIFFICULTY = 0;
                 clearviewport();
                 break;
    case '1'   : DIFFICULTY = 1;
                 clearviewport();
                 break;
    case '2'   : DIFFICULTY = 2;
                 clearviewport();
                 break;
    case '3'   : DIFFICULTY = 3;
                 clearviewport();
                 break;
    case VK_F1 : /* help levkeys.doc */
               show_help_keys();
               break;
    case VK_C_F1 : /* help levmap.doc */
               show_help_doc();
               break;
    case VK_A_F1 : /* help df_specs.doc */
               show_help_specs();
               break;
    case VK_S_F1 : /* notepad.txt */
               notepad();
               break;
    case VK_F2 : /* SAVE */
               messageSAVE();
               if(getVK() != VK_ESC)
                {
                 gr_shutdown();
                 save_level();
                 gr_startup();
                }
               else
                clearviewport();
               handle_titlebar(HEAD_BACK, HEAD_BORDER);
               break;
    case VK_F3 : /* SAVE and REREAD */
               messageREREAD();
               if(getVK() != VK_ESC)
                {
                 gr_shutdown();
                 save_level();
                 close_temp_files();
                 free_memory();
                 gr_startup();
                 handle_titlebar(HEAD_BACK, HEAD_BORDER);
                 handle_loading(HEAD_FORE);
                 read_level();
                 clearviewport();
                 cleardevice();
                 set_map_centered();
                }
               clearviewport();
               handle_titlebar(HEAD_BACK, HEAD_BORDER);
               break;
    case VK_F5 :   /* stitch MID horizontal */
               handle_title(COLOR_ERASER);
               if(MAP_MODE == 1) stitch_horizontal_MID();
               break;
    case VK_A_F5 : /* stitch TOP horizontal */
               handle_title(COLOR_ERASER);
               if(MAP_MODE == 1) stitch_horizontal_TOP();
               break;
    case VK_C_F5 : /* stitch BOT horizontal */
               handle_title(COLOR_ERASER);
               if(MAP_MODE == 1) stitch_horizontal_BOT();
               break;
    case VK_F6 :   /* stitch MID horizontal inverted */
               handle_title(COLOR_ERASER);
               if(MAP_MODE == 1) stitch_horizontal_inv_MID();
               break;
    case VK_A_F6 : /* stitch TOP horizontal inverted */
               handle_title(COLOR_ERASER);
               if(MAP_MODE == 1) stitch_horizontal_inv_TOP();
               break;
    case VK_C_F6 : /* stitch BOT horizontal inverted */
               handle_title(COLOR_ERASER);
               if(MAP_MODE == 1) stitch_horizontal_inv_BOT();
               break;
    case VK_F7 :   /* stitch MID vertical */
               handle_title(COLOR_ERASER);
               if(MAP_MODE == 1) stitch_vertical_MID();
               break;
    case VK_A_F7 : /* stitch TOP vertical */
               handle_title(COLOR_ERASER);
               if(MAP_MODE == 1) stitch_vertical_TOP();
               break;
    case VK_C_F7 : /* stitch BOT vertical */
               handle_title(COLOR_ERASER);
               if(MAP_MODE == 1) stitch_vertical_BOT();
               break;
    case VK_F8 :   /* distribute floor and ceiling altitudes */
               handle_title(COLOR_ERASER);
               if(MAP_MODE == 0)
                {
                 distribute_floor_alt();
                 distribute_ceili_alt();
                }
               break;
    case VK_A_F8 : /* distribute floor altitudes */
               handle_title(COLOR_ERASER);
               if(MAP_MODE == 0) distribute_floor_alt();
               break;
    case VK_C_F8 : /* distribute ceiling altitudes */
               handle_title(COLOR_ERASER);
               if(MAP_MODE == 0) distribute_ceili_alt();
               break;
    case VK_S_F8 :   /* distribute lights */
               handle_title(COLOR_ERASER);
               if(MAP_MODE == 0) distribute_light();
               break;
    case VK_F10 : /* level checks */
               gr_shutdown();
               check_level();
               gr_startup();
               handle_titlebar(HEAD_BACK, HEAD_BORDER);
               break;
    case VK_ESC : /* ESCAPE */
               if(MODIFIED == 1)
                {
                 messageQUIT();
                 switch(getVK())
                  {
                   case VK_F2     : gr_shutdown();
                                    save_level();
                                    break;
                   case VK_ENTER  : gr_shutdown();
                                    break;
                   default        : ccc = 0;
                                    clearviewport();
                                    handle_titlebar(HEAD_BACK, HEAD_BORDER);
                  }
                }
               else
                gr_shutdown();
               break;
/* -------------------------------------------------------------------------- */
    case VK_S_LBUTT : shifted = 1;
    case VK_LBUTT :
               GetMousePos(&mx, &my);
               handled = 0;
               if(mx==0)
                {
                 xoffset += 100 * REVERSE / scale;
                 clearviewport();
                 handled = 1;
                }
               if(mx==ScreenX-7)
                {
                 xoffset -= 100 * REVERSE / scale;
                 clearviewport();
                 handled = 1;
                }
               if(my==0)
                {
                 yoffset -= 100 * REVERSE / scale;
                 clearviewport();
                 handled = 1;
                }
               if(my==ScreenY-7-TITLE_BOX_Y)
                {
                 yoffset += 100 * REVERSE / scale;
                 clearviewport();
                 handled = 1;
                }
               if(!handled)
               switch(MAP_MODE)
                {
                 case 0 :
                         if((new_object = get_nearest_SC(S2MXF(mx),S2MYF(my), 0)) != -1)
                          {
                           handle_title(COLOR_ERASER);
                           SC_HILITE = new_object;
                           if(shifted) multi_sector(SC_HILITE);
                           clearviewport();
                          }
                         break;
                 case 1 :
                         if((new_object = get_nearest_WL(S2MXF(mx),S2MYF(my))) != -1)
                          {
                           handle_title(COLOR_ERASER);
                           WL_HILITE = new_object;
                           if(shifted) multi_wall(WL_HILITE);
                           clearviewport();
                          }
                         break;
                 case 2 :
                         if((new_object = get_nearest_VX(S2MXF(mx),S2MYF(my))) != -1)
                          {
                           handle_title(COLOR_ERASER);
                           VX_HILITE = new_object;
                           if(shifted) multi_vertex(VX_HILITE);
                           clearviewport();
                          }
                         break;
                 case 3 :
                         if((new_object = get_nearest_OB(S2MXF(mx),S2MYF(my))) != -1)
                          {
                           handle_title(COLOR_ERASER);
                           OB_HILITE = new_object;
                           if(shifted) multi_object(OB_HILITE);
                           clearviewport();
                          }
                         break;
                }
               break;
    case VK_C_LBUTT :
               GetMousePos(&mx, &my);
               switch(MAP_MODE)
                {
                 case 2 :
                         if((new_object = get_next_nearest_VX(S2MXF(mx),S2MYF(my))) != -1)
                          {
                           handle_title(COLOR_ERASER);
                           VX_HILITE = new_object;
                           clearviewport();
                          }
                         break;
                }
               break;
    case VK_RBUTT : /* move SC/WL/VX/OB */
               handle_title(COLOR_ERASER);
               if(GRID == 0)
                {
                 x = MAP_MOUSE_X;
                 z = MAP_MOUSE_Z;
                }
               else
                {
                 x = MAP_MOUSE_GX;
                 z = MAP_MOUSE_GZ;
                }
               switch(MAP_MODE)
                {
                 case 0 : if(MULTISEL == 0)
                           move_sector(SC_HILITE, x, z);
                          else
                           move_multi_sector(SC_HILITE, x, z);
                          break;
                 case 1 : if(MULTISEL == 0)
                           move_wall(WL_HILITE, x, z);
                          else
                           move_multi_wall(WL_HILITE, x, z);
                          break;
                 case 2 : if(MULTISEL == 0)
                           move_vertex(VX_HILITE, x, z);
                          else
                           move_multi_vertex(VX_HILITE, x, z);
                          break;
                 case 3 : if(MULTISEL == 0)
                           move_object(OB_HILITE, x, z);
                          else
                           move_multi_object(OB_HILITE, x, z);
                          break;
                }
               MODIFIED = 1;
               clearviewport();
               break;
    case VK_A_RBUTT : /* move SC/WL/VX but drop on nearest VX ! */
               handle_title(COLOR_ERASER);
               the_vx = get_nearest_VX(MAP_MOUSE_X, MAP_MOUSE_Z);
               x      = MAP_VRT[the_vx].x;
               z      = MAP_VRT[the_vx].z;
               switch(MAP_MODE)
                {
                 case 0 : if(MULTISEL == 0)
                           move_sector(SC_HILITE, x, z);
                          else
                           move_multi_sector(SC_HILITE, x, z);
                          break;
                 case 1 : if(MULTISEL == 0)
                           move_wall(WL_HILITE, x, z);
                          else
                           move_multi_wall(WL_HILITE, x, z);
                          break;
                 case 2 : if(MULTISEL == 0)
                           move_vertex(VX_HILITE, x, z);
                          else
                           move_multi_vertex(VX_HILITE, x, z);
                          break;
                }
               MODIFIED = 1;
               clearviewport();
               break;
    case VK_SPACE : /* space : add/remove from multisel */
               handle_title(COLOR_ERASER);
               switch(MAP_MODE)
                {
                 case 0 : multi_sector(SC_HILITE);
                          break;
                 case 1 : multi_wall(WL_HILITE);
                          break;
                 case 2 : multi_vertex(VX_HILITE);
                          break;
                 case 3 : multi_object(OB_HILITE);
                          break;
                }
               clearviewport();
               break;
    case VK_BACKSPACE : /* backspace : clear multisel */
               handle_title(COLOR_ERASER);
               switch(MAP_MODE)
                {
                 case 0 : clear_multi_sector();
                          break;
                 case 1 : clear_multi_wall();
                          break;
                 case 2 : clear_multi_vertex();
                          break;
                 case 3 : clear_multi_object();
                          break;
                }
               clearviewport();
               break;
   };
}

/* ************************************************************************** */
/* MAIN                                                                       */
/* ************************************************************************** */

main()
{

_OvrInitExt(0,0);

strcpy(golden_path, _argv[0]);
fnsplit(golden_path, fns_drive, fns_dir, fns_fname, fns_ext);
strcpy(golden_path, fns_drive);
strcat(golden_path, fns_dir);
golden_path[strlen(golden_path)-1] = '\0';  /* remove trailing backslash */
strcpy(golden_path_drive, fns_drive);

handle_ini();
handle_locations();
chk_cmdline();

set_mode_map();

free_memory();
close_temp_files();

return(ERR_NOERROR);
}
