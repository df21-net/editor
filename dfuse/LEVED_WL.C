/* ========================================================================== */
/* LEVED_WL.C : WALL EDITOR                                                   */
/* ========================================================================== */
#include "levmap.h"
#include "levext.h"

/* ************************************************************************** */
/* WALL EDITOR FUNCTIONS                                                      */
/* ************************************************************************** */

#define WFIELDS      22

void show_wall_layout(int color)
{
 setcolor(color);
 outtextxy(TITLE_BOX_X / 2 + 6 +  0,  6, "Adj:");
 outtextxy(TITLE_BOX_X / 2 + 6 + 88,  6, "Mir:");
 outtextxy(TITLE_BOX_X / 2 + 6 +208,  6, "Wlk:");
 outtextxy(TITLE_BOX_X / 2 + 6 +  0, 21, "MID:");
 outtextxy(TITLE_BOX_X / 2 + 6 +136, 21, "Xo:");
 outtextxy(TITLE_BOX_X / 2 + 6 +216, 21, "Yo:");
 outtextxy(TITLE_BOX_X / 2 + 6 +  0, 36, "TOP:");
 outtextxy(TITLE_BOX_X / 2 + 6 +136, 36, "Xo:");
 outtextxy(TITLE_BOX_X / 2 + 6 +216, 36, "Yo:");
 outtextxy(TITLE_BOX_X / 2 + 6 +  0, 51, "BOT:");
 outtextxy(TITLE_BOX_X / 2 + 6 +136, 51, "Xo:");
 outtextxy(TITLE_BOX_X / 2 + 6 +216, 51, "Yo:");
 outtextxy(TITLE_BOX_X / 2 + 6 +  0, 66, "SGN:");
 outtextxy(TITLE_BOX_X / 2 + 6 +136, 66, "Xo:");
 outtextxy(TITLE_BOX_X / 2 + 6 +216, 66, "Yo:");
 outtextxy(TITLE_BOX_X / 2 + 6 +  0, 81, "Flg:");
 outtextxy(TITLE_BOX_X / 2 + 6 +208, 81, "Lig:");
}

void show_all_wall_fields(int color)
{
 int i;

 for(i=0; i<WFIELDS;i++) show_wall_field(i, color);
}

void show_wall_field(int fieldnum, int color)
{
 char tmp[40];

 setcolor(color);
 switch(fieldnum)
  {
   case  0 : sprintf(tmpstr, "%-d", MAP_WAL[WL_HILITE].adjoin);
             outtextxy(TITLE_BOX_X / 2 + 6 + 40, 6, tmpstr);
             break;
   case  1 : sprintf(tmpstr, "%-d", MAP_WAL[WL_HILITE].mirror);
             outtextxy(TITLE_BOX_X / 2 + 6 +128, 6, tmpstr);
             break;
   case  2 : sprintf(tmpstr, "%-d", MAP_WAL[WL_HILITE].walk);
             outtextxy(TITLE_BOX_X / 2 + 6 +248, 6, tmpstr);
             break;
   case  3 : sprintf(tmpstr, "%s", swpWAL.mid_tx_name);
             outtextxy(TITLE_BOX_X / 2 + 6 + 40, 21, tmpstr);
             break;
   case  4 : sprintf(tmpstr, "% 6.2f", swpWAL.mid_tx_f1);
             outtextxy(TITLE_BOX_X / 2 + 6 +160, 21, tmpstr);
             break;
   case  5 : sprintf(tmpstr, "% 6.2f", swpWAL.mid_tx_f2);
             outtextxy(TITLE_BOX_X / 2 + 6 +240, 21, tmpstr);
             break;
   case  6 : sprintf(tmpstr, "%-d", swpWAL.mid_tx_i);
             outtextxy(TITLE_BOX_X / 2 + 6 +296, 21, tmpstr);
             break;
   case  7 : sprintf(tmpstr, "%s", swpWAL.top_tx_name);
             outtextxy(TITLE_BOX_X / 2 + 6 + 40, 36, tmpstr);
             break;
   case  8 : sprintf(tmpstr, "% 6.2f", swpWAL.top_tx_f1);
             outtextxy(TITLE_BOX_X / 2 + 6 +160, 36, tmpstr);
             break;
   case  9 : sprintf(tmpstr, "% 6.2f", swpWAL.top_tx_f2);
             outtextxy(TITLE_BOX_X / 2 + 6 +240, 36, tmpstr);
             break;
   case 10 : sprintf(tmpstr, "%-d", swpWAL.top_tx_i);
             outtextxy(TITLE_BOX_X / 2 + 6 +296, 36, tmpstr);
             break;
   case 11 : sprintf(tmpstr, "%s", swpWAL.bot_tx_name);
             outtextxy(TITLE_BOX_X / 2 + 6 + 40, 51, tmpstr);
             break;
   case 12 : sprintf(tmpstr, "% 6.2f", swpWAL.bot_tx_f1);
             outtextxy(TITLE_BOX_X / 2 + 6 +160, 51, tmpstr);
             break;
   case 13 : sprintf(tmpstr, "% 6.2f", swpWAL.bot_tx_f2);
             outtextxy(TITLE_BOX_X / 2 + 6 +240, 51, tmpstr);
             break;
   case 14 : sprintf(tmpstr, "%-d", swpWAL.bot_tx_i);
             outtextxy(TITLE_BOX_X / 2 + 6 +296, 51, tmpstr);
             break;
   case 15 : if(strcmp(swpWAL.sgn_tx_name,"") == 0)
              strcpy(tmpstr, "[none]");
             else
              sprintf(tmpstr, "%s", swpWAL.sgn_tx_name);
             outtextxy(TITLE_BOX_X / 2 + 6 + 40, 66, tmpstr);
             break;
   case 16 : sprintf(tmpstr, "% 6.2f", swpWAL.sign_f1);
             outtextxy(TITLE_BOX_X / 2 + 6 +160, 66, tmpstr);
             break;
   case 17 : sprintf(tmpstr, "% 6.2f", swpWAL.sign_f2);
             outtextxy(TITLE_BOX_X / 2 + 6 +240, 66, tmpstr);
             break;
   case 18 : sprintf(tmpstr, "%-5u", swpWAL.flag1);
             outtextxy(TITLE_BOX_X / 2 + 6 + 40, 81, tmpstr);
             break;
   case 19 : sprintf(tmpstr, "%-5u", swpWAL.flag2);
             outtextxy(TITLE_BOX_X / 2 + 6 + 88, 81, tmpstr);
             break;
   case 20 : sprintf(tmpstr, "%-5u", swpWAL.flag3);
             outtextxy(TITLE_BOX_X / 2 + 6 +132, 81, tmpstr);
             break;
   case 21 : sprintf(tmpstr, "%-5d", swpWAL.light);
             outtextxy(TITLE_BOX_X / 2 + 6 +248, 81, tmpstr);
             break;
  }
}

void edit_wall_field(int fieldnum)
{
 char tmp[40];
 int  i;
 unsigned old_flag, xor_flag, set_flag, reset_flag;

 switch(fieldnum)
  {
   case  0 : sprintf(tmpstr, "%-d", MAP_WAL[WL_HILITE].adjoin);
             if(stredit(TITLE_BOX_X / 2 + 6 + 40,  6, tmpstr, 4, 5, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               MAP_WAL[WL_HILITE].adjoin = atoi(tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 + 40,  6, 5, HEAD_BACK);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               for(i=0; i<=wall_max; i++) if(MAP_WAL[i].mark != 0)
                {
                 MAP_WAL[i].adjoin = MAP_WAL[WL_HILITE].adjoin;
                }
              }
             refresh_map_in_editor();
             break;
   case  1 : sprintf(tmpstr, "%-d", MAP_WAL[WL_HILITE].mirror);
             if(stredit(TITLE_BOX_X / 2 + 6 +128,  6, tmpstr, 4, 5, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               MAP_WAL[WL_HILITE].mirror = atoi(tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 +128,  6, 5, HEAD_BACK);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               for(i=0; i<=wall_max; i++) if(MAP_WAL[i].mark != 0)
                {
                 MAP_WAL[i].mirror = MAP_WAL[WL_HILITE].mirror;
                }
              }
             break;
   case  2 : sprintf(tmpstr, "%-d", MAP_WAL[WL_HILITE].walk);
             if(stredit(TITLE_BOX_X / 2 + 6 +248,  6, tmpstr, 4, 5, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               MAP_WAL[WL_HILITE].walk = atoi(tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 +248,  6, 5, HEAD_BACK);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               for(i=0; i<=wall_max; i++) if(MAP_WAL[i].mark != 0)
                {
                 MAP_WAL[i].walk = MAP_WAL[WL_HILITE].walk;
                }
              }
             refresh_map_in_editor();
             break;
   case  3 : sprintf(tmpstr, "%s", swpWAL.mid_tx_name);
             bmpicker("  TEXTURES", pk_textures, tmpstr,
                      HEAD_FORE, 0, HEAD_FORE, HILI_AT_ALT);
             if(strlen(tmpstr) != 0)
               strcpy(swpWAL.mid_tx_name, tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 + 40, 21, 12, HEAD_BACK);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               swpWAL2 = swpWAL;
               for(i=0; i<=wall_max; i++) if(MAP_WAL[i].mark != 0)
                {
                 get_wall_info(i);
                 strcpy(swpWAL.mid_tx_name , swpWAL2.mid_tx_name);
                 set_wall_info(i);
                }
               swpWAL = swpWAL2;
              }
             refresh_map_in_editor();
             break;
   case  4 : sprintf(tmpstr, "%-6.2f", swpWAL.mid_tx_f1);
             if(stredit(TITLE_BOX_X / 2 + 6 +160, 21, tmpstr, 7, 7, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               swpWAL.mid_tx_f1 = atof(tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 +160, 21, 7, HEAD_BACK);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               swpWAL2 = swpWAL;
               for(i=0; i<=wall_max; i++) if(MAP_WAL[i].mark != 0)
                {
                 get_wall_info(i);
                 swpWAL.mid_tx_f1 = swpWAL2.mid_tx_f1;
                 set_wall_info(i);
                }
               swpWAL = swpWAL2;
              }
             break;
   case  5 : sprintf(tmpstr, "%-6.2f", swpWAL.mid_tx_f2);
             if(stredit(TITLE_BOX_X / 2 + 6 +240, 21, tmpstr, 7, 7, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               swpWAL.mid_tx_f2 = atof(tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 +240, 21, 7, HEAD_BACK);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               swpWAL2 = swpWAL;
               for(i=0; i<=wall_max; i++) if(MAP_WAL[i].mark != 0)
                {
                 get_wall_info(i);
                 swpWAL.mid_tx_f2 = swpWAL2.mid_tx_f2;
                 set_wall_info(i);
                }
               swpWAL = swpWAL2;
              }
             break;
   case  6 : sprintf(tmpstr, "%-d", swpWAL.mid_tx_i);
             if(stredit(TITLE_BOX_X / 2 + 6 +296, 21, tmpstr, 2, 2, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               swpWAL.mid_tx_i = atoi(tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 +296, 21, 2, HEAD_BACK);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               swpWAL2 = swpWAL;
               for(i=0; i<=wall_max; i++) if(MAP_WAL[i].mark != 0)
                {
                 get_wall_info(i);
                 swpWAL.mid_tx_i = swpWAL2.mid_tx_i;
                 set_wall_info(i);
                }
               swpWAL = swpWAL2;
              }
             break;
   case  7 : sprintf(tmpstr, "%s", swpWAL.top_tx_name);
             bmpicker("  TEXTURES", pk_textures, tmpstr,
                      HEAD_FORE, 0, HEAD_FORE, HILI_AT_ALT);
             if(strlen(tmpstr) != 0)
               strcpy(swpWAL.top_tx_name, tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 + 40, 36, 12, HEAD_BACK);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               swpWAL2 = swpWAL;
               for(i=0; i<=wall_max; i++) if(MAP_WAL[i].mark != 0)
                {
                 get_wall_info(i);
                 strcpy(swpWAL.top_tx_name , swpWAL2.top_tx_name);
                 set_wall_info(i);
                }
               swpWAL = swpWAL2;
              }
             refresh_map_in_editor();
             break;
   case  8 : sprintf(tmpstr, "%-6.2f", swpWAL.top_tx_f1);
             if(stredit(TITLE_BOX_X / 2 + 6 +160, 36, tmpstr, 7, 7, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               swpWAL.top_tx_f1 = atof(tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 +160, 36, 7, HEAD_BACK);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               swpWAL2 = swpWAL;
               for(i=0; i<=wall_max; i++) if(MAP_WAL[i].mark != 0)
                {
                 get_wall_info(i);
                 swpWAL.top_tx_f1 = swpWAL2.top_tx_f1;
                 set_wall_info(i);
                }
               swpWAL = swpWAL2;
              }
             break;
   case  9 : sprintf(tmpstr, "%-6.2f", swpWAL.top_tx_f2);
             if(stredit(TITLE_BOX_X / 2 + 6 +240, 36, tmpstr, 7, 7, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               swpWAL.top_tx_f2 = atof(tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 +240, 36, 7, HEAD_BACK);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               swpWAL2 = swpWAL;
               for(i=0; i<=wall_max; i++) if(MAP_WAL[i].mark != 0)
                {
                 get_wall_info(i);
                 swpWAL.top_tx_f2 = swpWAL2.top_tx_f2;
                 set_wall_info(i);
                }
               swpWAL = swpWAL2;
              }
             break;
   case 10 : sprintf(tmpstr, "%-d", swpWAL.top_tx_i);
             if(stredit(TITLE_BOX_X / 2 + 6 +296, 36, tmpstr, 2, 2, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               swpWAL.top_tx_i = atoi(tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 +296, 36, 2, HEAD_BACK);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               swpWAL2 = swpWAL;
               for(i=0; i<=wall_max; i++) if(MAP_WAL[i].mark != 0)
                {
                 get_wall_info(i);
                 swpWAL.top_tx_i = swpWAL2.top_tx_i;
                 set_wall_info(i);
                }
               swpWAL = swpWAL2;
              }
             break;
   case 11 : sprintf(tmpstr, "%s", swpWAL.bot_tx_name);
             bmpicker("  TEXTURES", pk_textures, tmpstr,
                      HEAD_FORE, 0, HEAD_FORE, HILI_AT_ALT);
             if(strlen(tmpstr) != 0)
               strcpy(swpWAL.bot_tx_name, tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 + 40, 51, 12, HEAD_BACK);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               swpWAL2 = swpWAL;
               for(i=0; i<=wall_max; i++) if(MAP_WAL[i].mark != 0)
                {
                 get_wall_info(i);
                 strcpy(swpWAL.bot_tx_name , swpWAL2.bot_tx_name);
                 set_wall_info(i);
                }
               swpWAL = swpWAL2;
              }
             refresh_map_in_editor();
             break;
   case 12 : sprintf(tmpstr, "%-6.2f", swpWAL.bot_tx_f1);
             if(stredit(TITLE_BOX_X / 2 + 6 +160, 51, tmpstr, 7, 7, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               swpWAL.bot_tx_f1 = atof(tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 +160, 51, 7, HEAD_BACK);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               swpWAL2 = swpWAL;
               for(i=0; i<=wall_max; i++) if(MAP_WAL[i].mark != 0)
                {
                 get_wall_info(i);
                 swpWAL.bot_tx_f1 = swpWAL2.bot_tx_f1;
                 set_wall_info(i);
                }
               swpWAL = swpWAL2;
              }
             break;
   case 13 : sprintf(tmpstr, "%-6.2f", swpWAL.bot_tx_f2);
             if(stredit(TITLE_BOX_X / 2 + 6 +240, 51, tmpstr, 7, 7, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               swpWAL.bot_tx_f2 = atof(tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 +240, 51, 7, HEAD_BACK);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               swpWAL2 = swpWAL;
               for(i=0; i<=wall_max; i++) if(MAP_WAL[i].mark != 0)
                {
                 get_wall_info(i);
                 swpWAL.bot_tx_f2 = swpWAL2.bot_tx_f2;
                 set_wall_info(i);
                }
               swpWAL = swpWAL2;
              }
             break;
   case 14 : sprintf(tmpstr, "%-d", swpWAL.bot_tx_i);
             if(stredit(TITLE_BOX_X / 2 + 6 +296, 51, tmpstr, 2, 2, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               swpWAL.bot_tx_i = atoi(tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 +296, 51, 2, HEAD_BACK);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               swpWAL2 = swpWAL;
               for(i=0; i<=wall_max; i++) if(MAP_WAL[i].mark != 0)
                {
                 get_wall_info(i);
                 swpWAL.bot_tx_i = swpWAL2.bot_tx_i;
                 set_wall_info(i);
                }
               swpWAL = swpWAL2;
              }
             break;
   case 15 : sprintf(tmpstr, "%s", swpWAL.sgn_tx_name);
             bmpicker("  TEXTURES", pk_textures, tmpstr,
                      HEAD_FORE, 0, HEAD_FORE, HILI_AT_ALT);
             strcpy(swpWAL.sgn_tx_name, tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 + 40, 66, 12, HEAD_BACK);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               swpWAL2 = swpWAL;
               for(i=0; i<=wall_max; i++) if(MAP_WAL[i].mark != 0)
                {
                 get_wall_info(i);
                 strcpy(swpWAL.sgn_tx_name , swpWAL2.sgn_tx_name);
                 set_wall_info(i);
                }
               swpWAL = swpWAL2;
              }
             refresh_map_in_editor();
             break;
   case 16 : sprintf(tmpstr, "%-6.2f", swpWAL.sign_f1);
             if(stredit(TITLE_BOX_X / 2 + 6 +160, 66, tmpstr, 7, 7, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               swpWAL.sign_f1 = atof(tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 +160, 66, 7, HEAD_BACK);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               swpWAL2 = swpWAL;
               for(i=0; i<=wall_max; i++) if(MAP_WAL[i].mark != 0)
                {
                 get_wall_info(i);
                 swpWAL.sign_f1 = swpWAL2.sign_f1;
                 set_wall_info(i);
                }
               swpWAL = swpWAL2;
              }
             break;
   case 17 : sprintf(tmpstr, "%-6.2f", swpWAL.sign_f2);
             if(stredit(TITLE_BOX_X / 2 + 6 +240, 66, tmpstr, 7, 7, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               swpWAL.sign_f2 = atof(tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 +240, 66, 7, HEAD_BACK);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               swpWAL2 = swpWAL;
               for(i=0; i<=wall_max; i++) if(MAP_WAL[i].mark != 0)
                {
                 get_wall_info(i);
                 swpWAL.sign_f2 = swpWAL2.sign_f2;
                 set_wall_info(i);
                }
               swpWAL = swpWAL2;
              }
             break;
   case 18 : old_flag = swpWAL.flag1;
             swpWAL.flag1 = edit_flag("dfudata\\wl_flag1.dfu" , swpWAL.flag1);
             SE_erase_all(TITLE_BOX_X / 2 + 6 + 40, 81, 5, HEAD_BACK);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               xor_flag   = old_flag ^ swpWAL.flag1;
               set_flag   = xor_flag & swpWAL.flag1;
               reset_flag = xor_flag & old_flag;
               swpWAL2 = swpWAL;
               for(i=0; i<=wall_max; i++) if(MAP_WAL[i].mark != 0)
                {
                 get_wall_info(i);
                 swpWAL.flag1 = (swpWAL.flag1 | set_flag) & ~reset_flag;
                 set_wall_info(i);
                }
               swpWAL = swpWAL2;
              }
             refresh_map_in_editor();
             break;
   case 19 : old_flag = swpWAL.flag2;
             swpWAL.flag2 = edit_flag("dfudata\\wl_flag2.dfu" , swpWAL.flag2);
             SE_erase_all(TITLE_BOX_X / 2 + 6 + 88, 81, 5, HEAD_BACK);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               xor_flag   = old_flag ^ swpWAL.flag2;
               set_flag   = xor_flag & swpWAL.flag2;
               reset_flag = xor_flag & old_flag;
               swpWAL2 = swpWAL;
               for(i=0; i<=wall_max; i++) if(MAP_WAL[i].mark != 0)
                {
                 get_wall_info(i);
                 swpWAL.flag2 = (swpWAL.flag2 | set_flag) & ~reset_flag;
                 set_wall_info(i);
                }
               swpWAL = swpWAL2;
              }
             refresh_map_in_editor();
             break;
   case 20 : old_flag = swpWAL.flag3;
             swpWAL.flag3 = edit_flag("dfudata\\wl_flag3.dfu" , swpWAL.flag3);
             SE_erase_all(TITLE_BOX_X / 2 + 6 +132, 81, 5, HEAD_BACK);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               xor_flag   = old_flag ^ swpWAL.flag3;
               set_flag   = xor_flag & swpWAL.flag3;
               reset_flag = xor_flag & old_flag;
               swpWAL2 = swpWAL;
               for(i=0; i<=wall_max; i++) if(MAP_WAL[i].mark != 0)
                {
                 get_wall_info(i);
                 swpWAL.flag3 = (swpWAL.flag3 | set_flag) & ~reset_flag;
                 set_wall_info(i);
                }
               swpWAL = swpWAL2;
              }
             refresh_map_in_editor();
             break;
   case 21 : sprintf(tmpstr, "%-d", swpWAL.light);
             if(stredit(TITLE_BOX_X / 2 + 6 +248, 81, tmpstr, 6, 5, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               swpWAL.light = atoi(tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 +248, 81, 6, HEAD_BACK);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               swpWAL2 = swpWAL;
               for(i=0; i<=wall_max; i++) if(MAP_WAL[i].mark != 0)
                {
                 get_wall_info(i);
                 swpWAL.light = swpWAL2.light;
                 set_wall_info(i);
                }
               swpWAL = swpWAL2;
              }
             break;
  }
}

void edit_wall()
{
 int current = 0;
 int key     = 0;
 int i;

 get_wall_info(WL_HILITE);
 setviewport(0, 0, getmaxx(), getmaxy(), 1);
 if(APPLY_TO_MULTI) show_wall_layout(HILI_AT_ALT);

 do
 {
  show_all_wall_fields(HEAD_FORE);
  show_wall_field(current, HILI_AT_ALT);
  key = getVK();
  switch(key)
   {
    case 'c'      :
    case 'C'      : set_wall_info(WL_HILITE); /* 'cause handle_title will get it */
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
                    if(APPLY_TO_MULTI) show_wall_layout(HILI_AT_ALT);
                    show_all_wall_fields(HEAD_FORE);
                    refresh_map_in_editor();
                    break;
    case VK_TAB   :
    case VK_DOWN  :
    case VK_RIGHT : current++;
                    if(current >= WFIELDS) current = 0;
                    break;
    case VK_S_TAB :
    case VK_UP    :
    case VK_LEFT  : current--;
                    if(current < 0 ) current = WFIELDS - 1;
                    break;
    case VK_ENTER :
    case VK_SPACE : edit_wall_field(current);
                    break;
   }
 } while(key != VK_ESC);

  show_wall_field(current, HEAD_FORE);
  setviewport(0, TITLE_BOX_Y+1, getmaxx(), getmaxy(), 1);
  set_wall_info(WL_HILITE); /* security, is done at field level */
  MODIFIED = 1;
}
