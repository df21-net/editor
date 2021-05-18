/* ========================================================================== */
/* LEVED_SC.C : SECTOR EDITOR                                                 */
/* ========================================================================== */
#include "levmap.h"
#include "levext.h"

/* ************************************************************************** */
/* SECTOR EDITOR FUNCTIONS                                                    */
/* ************************************************************************** */

#define SFIELDS      17
void show_sector_layout(int color)
{
 setcolor(color);
 outtextxy(TITLE_BOX_X / 2 + 6 +  0,  6, "Nam:");
 outtextxy(TITLE_BOX_X / 2 + 6 +  0, 21, "Lay:");
 outtextxy(TITLE_BOX_X / 2 + 6 + 88, 21, "FAl:");
 outtextxy(TITLE_BOX_X / 2 + 6 +208, 21, "CAl:");
 outtextxy(TITLE_BOX_X / 2 + 6 +  0, 36, "FTx:");
 outtextxy(TITLE_BOX_X / 2 + 6 +136, 36, "Xo:");
 outtextxy(TITLE_BOX_X / 2 + 6 +216, 36, "Zo:");
 outtextxy(TITLE_BOX_X / 2 + 6 +  0, 51, "CTx:");
 outtextxy(TITLE_BOX_X / 2 + 6 +136, 51, "Xo:");
 outtextxy(TITLE_BOX_X / 2 + 6 +216, 51, "Zo:");
 outtextxy(TITLE_BOX_X / 2 + 6 +  0, 66, "Flg:");
 outtextxy(TITLE_BOX_X / 2 + 6 +208, 66, "Amb:");
 outtextxy(TITLE_BOX_X / 2 + 6 +  0, 81, "2Al:");

 if(MAP_SEC[SC_HILITE].elev != 0)
  {
   if(color != COLOR_ERASER) setcolor(LINE_AT_ALT);
   sprintf(tmpstr, "elevator %s", swpSEC.elevator_name);
   outtextxy(TITLE_BOX_X / 2 + 6 +  96, 81, tmpstr);
  }
}

void show_all_sector_fields(int color)
{
 int i       = 0;

 for(i=0; i<SFIELDS;i++) show_sector_field(i, color);
}

void show_sector_field(int fieldnum, int color)
{
 char tmpstr[40];

 setcolor(color);
 switch(fieldnum)
  {
   case  0 : sprintf(tmpstr, "'%s'", swpSEC.name);
             outtextxy(TITLE_BOX_X / 2 + 6 + 40, 6, tmpstr);
             break;
   case  1 : sprintf(tmpstr, "%+d", MAP_SEC[SC_HILITE].layer);
             outtextxy(TITLE_BOX_X / 2 + 6 + 40, 21, tmpstr);
             break;
   case  2 : sprintf(tmpstr, "% 5.2f", -MAP_SEC[SC_HILITE].floor_alt);
             outtextxy(TITLE_BOX_X / 2 + 6 +128, 21, tmpstr);
				 break;
   case  3 : sprintf(tmpstr, "% 5.2f", -MAP_SEC[SC_HILITE].ceili_alt);
             outtextxy(TITLE_BOX_X / 2 + 6 +248, 21, tmpstr);
             break;
   case  4 : sprintf(tmpstr, "%-11s", swpSEC.floor_tx_name);
             outtextxy(TITLE_BOX_X / 2 + 6 + 40, 36, tmpstr);
             break;
   case  5 : sprintf(tmpstr, "% 6.2f", swpSEC.floor_tx_f1);
             outtextxy(TITLE_BOX_X / 2 + 6 +160, 36, tmpstr);
             break;
   case  6 : sprintf(tmpstr, "% 6.2f", swpSEC.floor_tx_f2);
             outtextxy(TITLE_BOX_X / 2 + 6 +240, 36, tmpstr);
             break;
   case  7 : sprintf(tmpstr, "%-d", swpSEC.floor_tx_i);
             outtextxy(TITLE_BOX_X / 2 + 6 +296, 36, tmpstr);
             break;
   case  8 : sprintf(tmpstr, "%-11s", swpSEC.ceili_tx_name);
             outtextxy(TITLE_BOX_X / 2 + 6 + 40, 51, tmpstr);
             break;
   case  9 : sprintf(tmpstr, "% 6.2f", swpSEC.ceili_tx_f1);
             outtextxy(TITLE_BOX_X / 2 + 6 +160, 51, tmpstr);
             break;
   case 10 : sprintf(tmpstr, "% 6.2f", swpSEC.ceili_tx_f2);
             outtextxy(TITLE_BOX_X / 2 + 6 +240, 51, tmpstr);
             break;
	case 11 : sprintf(tmpstr, "%-d", swpSEC.ceili_tx_i);
             outtextxy(TITLE_BOX_X / 2 + 6 +296, 51, tmpstr);
             break;
   case 12 : sprintf(tmpstr, "%-7lu", swpSEC.flag1);
             outtextxy(TITLE_BOX_X / 2 + 6 + 40, 66, tmpstr);
             break;
   case 13 : sprintf(tmpstr, "%-5u", swpSEC.flag2);
             outtextxy(TITLE_BOX_X / 2 + 6 +104, 66, tmpstr);
             break;
   case 14 : sprintf(tmpstr, "%-5u", swpSEC.flag3);
             outtextxy(TITLE_BOX_X / 2 + 6 +148, 66, tmpstr);
             break;
   case 15 : sprintf(tmpstr, "%-5d", swpSEC.ambient);
             outtextxy(TITLE_BOX_X / 2 + 6 +248, 66, tmpstr);
             break;
   case 16 : sprintf(tmpstr, "% 5.2f", swpSEC.second_alt);
             outtextxy(TITLE_BOX_X / 2 + 6+ 40, 81, tmpstr);
             break;
  }
}

void edit_sector_field(int fieldnum)
{
 char tmp[40];
 int  i;
 unsigned      old_flag,  xor_flag,  set_flag,  reset_flag;
 unsigned long lold_flag, lxor_flag, lset_flag, lreset_flag;

 switch(fieldnum)
  {
   case  0 : sprintf(tmpstr, "%s", swpSEC.name);
             if(stredit(TITLE_BOX_X / 2 + 6 + 40, 6, tmpstr, 19, 20, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               strcpy(swpSEC.name, tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 + 40, 6, 20, HEAD_BACK);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               swpSEC2 = swpSEC;
               for(i=0; i<=sector_max; i++) if(MAP_SEC[i].mark != 0)
                {
                 get_sector_info(i);
                 strcpy(swpSEC.name , swpSEC2.name);
                 set_sector_info(i);
                }
               swpSEC = swpSEC2;
              }
             break;
   case  1 : sprintf(tmpstr, "%-d", MAP_SEC[SC_HILITE].layer);
             if(stredit(TITLE_BOX_X / 2 + 6 + 40, 21, tmpstr, 2, 3, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               MAP_SEC[SC_HILITE].layer = atoi(tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 + 40, 21, 3, HEAD_BACK);
             if(MAP_SEC[SC_HILITE].layer > maxlayer) maxlayer = MAP_SEC[SC_HILITE].layer;
				 if(MAP_SEC[SC_HILITE].layer < minlayer) minlayer = MAP_SEC[SC_HILITE].layer;
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               for(i=0; i<=sector_max; i++) if(MAP_SEC[i].mark != 0)
                {
                 MAP_SEC[i].layer = MAP_SEC[SC_HILITE].layer;
                }
              }
             refresh_map_in_editor();
             break;
   case  2 : sprintf(tmpstr, "%-5.2f", -MAP_SEC[SC_HILITE].floor_alt);
             if(stredit(TITLE_BOX_X / 2 + 6 +128, 21, tmpstr, 7, 8, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               MAP_SEC[SC_HILITE].floor_alt = -atof(tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 +128, 21, 8, HEAD_BACK);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               for(i=0; i<=sector_max; i++) if(MAP_SEC[i].mark != 0)
                {
                 MAP_SEC[i].floor_alt = MAP_SEC[SC_HILITE].floor_alt;
                }
              }
				 break;
   case  3 : sprintf(tmpstr, "%-5.2f", -MAP_SEC[SC_HILITE].ceili_alt);
             if(stredit(TITLE_BOX_X / 2 + 6 +248, 21, tmpstr, 7, 8, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               MAP_SEC[SC_HILITE].ceili_alt = -atof(tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 +248, 21, 8, HEAD_BACK);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               for(i=0; i<=sector_max; i++) if(MAP_SEC[i].mark != 0)
                {
                 MAP_SEC[i].ceili_alt = MAP_SEC[SC_HILITE].ceili_alt;
                }
              }
             break;
   case  4 : sprintf(tmpstr, "%s", swpSEC.floor_tx_name);
             bmpicker("  TEXTURES", pk_textures, tmpstr,
                      HEAD_FORE, 0, HEAD_FORE, HILI_AT_ALT);
             if(strlen(tmpstr) != 0)
               strcpy(swpSEC.floor_tx_name, tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 + 40, 36, 12, HEAD_BACK);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               swpSEC2 = swpSEC;
               for(i=0; i<=sector_max; i++) if(MAP_SEC[i].mark != 0)
                {
                 get_sector_info(i);
                 strcpy(swpSEC.floor_tx_name , swpSEC2.floor_tx_name);
                 set_sector_info(i);
                }
               swpSEC = swpSEC2;
              }
             refresh_map_in_editor();
             break;
   case  5 : sprintf(tmpstr, "%-6.2f", swpSEC.floor_tx_f1);
             if(stredit(TITLE_BOX_X / 2 + 6 +160, 36, tmpstr, 7, 7, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               swpSEC.floor_tx_f1 = atof(tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 +160, 36, 7, HEAD_BACK);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               swpSEC2 = swpSEC;
               for(i=0; i<=sector_max; i++) if(MAP_SEC[i].mark != 0)
                {
                 get_sector_info(i);
                 swpSEC.floor_tx_f1 = swpSEC2.floor_tx_f1;
                 set_sector_info(i);
                }
               swpSEC = swpSEC2;
				  }
             break;
   case  6 : sprintf(tmpstr, "%-6.2f", swpSEC.floor_tx_f2);
             if(stredit(TITLE_BOX_X / 2 + 6 +240, 36, tmpstr, 7, 7, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               swpSEC.floor_tx_f2 = atof(tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 +240, 36, 7, HEAD_BACK);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               swpSEC2 = swpSEC;
               for(i=0; i<=sector_max; i++) if(MAP_SEC[i].mark != 0)
                {
                 get_sector_info(i);
                 swpSEC.floor_tx_f2 = swpSEC2.floor_tx_f2;
                 set_sector_info(i);
                }
               swpSEC = swpSEC2;
              }
             break;
   case  7 : sprintf(tmpstr, "%-d", swpSEC.floor_tx_i);
             if(stredit(TITLE_BOX_X / 2 + 6 +296, 36, tmpstr, 2, 2, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               swpSEC.floor_tx_i = atoi(tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 +296, 36, 2, HEAD_BACK);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               swpSEC2 = swpSEC;
					for(i=0; i<=sector_max; i++) if(MAP_SEC[i].mark != 0)
                {
                 get_sector_info(i);
                 swpSEC.floor_tx_i = swpSEC2.floor_tx_i;
                 set_sector_info(i);
                }
               swpSEC = swpSEC2;
              }
             break;
   case  8 : sprintf(tmpstr, "%s", swpSEC.ceili_tx_name);
             bmpicker("  TEXTURES", pk_textures, tmpstr,
                      HEAD_FORE, 0, HEAD_FORE, HILI_AT_ALT);
             if(strlen(tmpstr) != 0)
               strcpy(swpSEC.ceili_tx_name, tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 + 40, 51, 12, HEAD_BACK);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               swpSEC2 = swpSEC;
               for(i=0; i<=sector_max; i++) if(MAP_SEC[i].mark != 0)
                {
                 get_sector_info(i);
                 strcpy(swpSEC.ceili_tx_name , swpSEC2.ceili_tx_name);
                 set_sector_info(i);
                }
               swpSEC = swpSEC2;
				  }
             refresh_map_in_editor();
             break;
   case  9 : sprintf(tmpstr, "%-6.2f", swpSEC.ceili_tx_f1);
             if(stredit(TITLE_BOX_X / 2 + 6 +160, 51, tmpstr, 7, 7, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               swpSEC.ceili_tx_f1 = atof(tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 +160, 51, 7, HEAD_BACK);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               swpSEC2 = swpSEC;
               for(i=0; i<=sector_max; i++) if(MAP_SEC[i].mark != 0)
                {
                 get_sector_info(i);
                 swpSEC.ceili_tx_f1 = swpSEC2.ceili_tx_f1;
                 set_sector_info(i);
                }
               swpSEC = swpSEC2;
              }
             break;
   case 10 : sprintf(tmpstr, "%-6.2f", swpSEC.ceili_tx_f2);
             if(stredit(TITLE_BOX_X / 2 + 6 +240, 51, tmpstr, 7, 7, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               swpSEC.ceili_tx_f2 = atof(tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 +240, 51, 7, HEAD_BACK);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
					swpSEC2 = swpSEC;
               for(i=0; i<=sector_max; i++) if(MAP_SEC[i].mark != 0)
                {
                 get_sector_info(i);
                 swpSEC.ceili_tx_f2 = swpSEC2.ceili_tx_f2;
                 set_sector_info(i);
                }
               swpSEC = swpSEC2;
              }
             break;
   case 11 : sprintf(tmpstr, "%-d", swpSEC.ceili_tx_i);
             if(stredit(TITLE_BOX_X / 2 + 6 +296, 51, tmpstr, 2, 2, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               swpSEC.ceili_tx_i = atoi(tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 +296, 51, 2, HEAD_BACK);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               swpSEC2 = swpSEC;
               for(i=0; i<=sector_max; i++) if(MAP_SEC[i].mark != 0)
                {
                 get_sector_info(i);
                 swpSEC.ceili_tx_i = swpSEC2.ceili_tx_i;
                 set_sector_info(i);
                }
               swpSEC = swpSEC2;
              }
				 break;
   case 12 : lold_flag = swpSEC.flag1;
             swpSEC.flag1 = edit_lflag("dfudata\\sc_flag1.dfu" , swpSEC.flag1);
             MAP_SEC[SC_HILITE].elev   = 0;
             MAP_SEC[SC_HILITE].secret = 0;
             if(swpSEC.flag1 &      2) MAP_SEC[SC_HILITE].elev = 1;
             if(swpSEC.flag1 &     64) MAP_SEC[SC_HILITE].elev = 1;
             if(swpSEC.flag1 & 524288) MAP_SEC[SC_HILITE].secret = 1;
             SE_erase_all(TITLE_BOX_X / 2 + 6 + 40, 66, 7, HEAD_BACK);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               lxor_flag   = lold_flag ^ swpSEC.flag1;
               lset_flag   = lxor_flag & swpSEC.flag1;
               lreset_flag = lxor_flag & lold_flag;
               swpSEC2 = swpSEC;
               for(i=0; i<=sector_max; i++) if(MAP_SEC[i].mark != 0)
                {
                 get_sector_info(i);
                 swpSEC.flag1 = (swpSEC.flag1 | lset_flag) & ~lreset_flag;
                 MAP_SEC[i].elev   = 0;
                 MAP_SEC[i].secret = 0;
                 if(swpSEC.flag1 &      2) MAP_SEC[i].elev = 1;
                 if(swpSEC.flag1 &     64) MAP_SEC[i].elev = 1;
                 if(swpSEC.flag1 & 524288) MAP_SEC[i].secret = 1;
                 set_sector_info(i);
                }
               swpSEC = swpSEC2;
              }
             refresh_map_in_editor();
             break;
   case 13 : old_flag = swpSEC.flag2;
             swpSEC.flag2 = edit_flag("dfudata\\sc_flag2.dfu" , swpSEC.flag2);
             SE_erase_all(TITLE_BOX_X / 2 + 6 +104, 66, 5, HEAD_BACK);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               xor_flag   = old_flag ^ swpSEC.flag2;
               set_flag   = xor_flag & swpSEC.flag2;
               reset_flag = xor_flag & old_flag;
               swpSEC2 = swpSEC;
               for(i=0; i<=sector_max; i++) if(MAP_SEC[i].mark != 0)
                {
                 get_sector_info(i);
                 swpSEC.flag2 = (swpSEC.flag2 | set_flag) & ~reset_flag;
                 set_sector_info(i);
                }
               swpSEC = swpSEC2;
              }
             refresh_map_in_editor();
             break;
   case 14 : old_flag = swpSEC.flag3;
             swpSEC.flag3 = edit_flag("dfudata\\sc_flag3.dfu" , swpSEC.flag3);
             SE_erase_all(TITLE_BOX_X / 2 + 6 +148, 66, 5, HEAD_BACK);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               xor_flag   = old_flag ^ swpSEC.flag3;
               set_flag   = xor_flag & swpSEC.flag3;
               reset_flag = xor_flag & old_flag;
               swpSEC2 = swpSEC;
               for(i=0; i<=sector_max; i++) if(MAP_SEC[i].mark != 0)
                {
                 get_sector_info(i);
                 swpSEC.flag3 = (swpSEC.flag3 | set_flag) & ~reset_flag;
                 set_sector_info(i);
                }
               swpSEC = swpSEC2;
              }
             refresh_map_in_editor();
             break;
   case 15 : sprintf(tmpstr, "%-d", swpSEC.ambient);
             if(stredit(TITLE_BOX_X / 2 + 6 +248, 66, tmpstr, 6, 5, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               swpSEC.ambient = atoi(tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 +248, 66, 6, HEAD_BACK);
				 if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               swpSEC2 = swpSEC;
               for(i=0; i<=sector_max; i++) if(MAP_SEC[i].mark != 0)
                {
                 get_sector_info(i);
                 swpSEC.ambient = swpSEC2.ambient;
                 set_sector_info(i);
                }
               swpSEC = swpSEC2;
				  }
				 break;
	case 16 : sprintf(tmpstr, "%-5.2f", swpSEC.second_alt);
				 if(stredit(TITLE_BOX_X / 2 + 6 + 40, 81, tmpstr, 7, 7, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
					swpSEC.second_alt = atof(tmpstr);
				 SE_erase_all(TITLE_BOX_X / 2 + 6 + 40, 81, 7, HEAD_BACK);
				 if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
				  {
					swpSEC2 = swpSEC;
					for(i=0; i<=sector_max; i++) if(MAP_SEC[i].mark != 0)
					 {
					  get_sector_info(i);
					  swpSEC.second_alt = swpSEC2.second_alt;
					  set_sector_info(i);
					 }
					swpSEC = swpSEC2;
				  }
				 break;
  }
}

void edit_sector()
{
 int current = 0;
 int key     = 0;
 int i;

 get_sector_info(SC_HILITE);
 setviewport(0, 0, getmaxx(), getmaxy(), 1);
 if(APPLY_TO_MULTI) show_sector_layout(HILI_AT_ALT);

 do
 {
  show_all_sector_fields(HEAD_FORE);
  show_sector_field(current, HILI_AT_ALT);
  key = getVK();
  switch(key)
   {
    case 'c'      :
    case 'C'      : set_sector_info(SC_HILITE); /* 'cause handle_title will get it */
                    system("seejedi dfudata\\textures.dfu > temp\\text.$$$");
                    if(listpick(318, 198, "Please pick a textures file", "temp\\text.$$$", tmpstr,
                             HEAD_FORE, 0, HEAD_FORE, HILI_AT_ALT) != -1)
                     {
                      for(i=0;i<9;i++) if(tmpstr[i] == ' ') tmpstr[i] = '\0';
                      strcat(tmpstr, ".DFU");
                      strcpy(pk_textures, "DFUDATA\\");
                      strcat(pk_textures, tmpstr);
                     }
                    system("del temp\\text.$$$ > NUL");
                    setviewport(0, TITLE_BOX_Y+1, getmaxx(), getmaxy(), 1);
                    clearviewport();
                    handle_titlebar(HEAD_BACK, HEAD_BORDER);
                    handle_title(HEAD_FORE);
                    setviewport(0, 0, getmaxx(), getmaxy(), 1);
                    if(APPLY_TO_MULTI) show_sector_layout(HILI_AT_ALT);
                    show_all_sector_fields(HEAD_FORE);
                    refresh_map_in_editor();
                    break;
    case VK_TAB   :
    case VK_DOWN  :
    case VK_RIGHT : current++;
                    if(current >= SFIELDS) current = 0;
                    break;
    case VK_S_TAB :
    case VK_UP    :
    case VK_LEFT  : current--;
                    if(current < 0 ) current = SFIELDS - 1;
                    break;
    case VK_ENTER :
    case VK_SPACE : edit_sector_field(current);
                    break;
   }
 } while(key != VK_ESC);

 show_sector_field(current, HEAD_FORE);
 setviewport(0, TITLE_BOX_Y+1, getmaxx(), getmaxy(), 1);
 set_sector_info(SC_HILITE); /* security, is done at field level */
 MODIFIED = 1;
}
