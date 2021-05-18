#include "dfuse.h"
#include "dfuseext.h"

/* ************************************************************************** */
/* LVL MENU                                                                   */
/* ************************************************************************** */

void lvl_menu()
{
 char tmp[127];
 char df_test_dir[127];
 int  i;

 cleardevice();
 ccc = 0;
 write_lvl_menu();
 do
  {
   switch(ccc)
    {
     case  'c' :
     case  'C' : system("seejedi dark\\jedi.lvl > temp\\levels.$$$");
                 if(listpick(318, 198, "Please pick a level", "temp\\levels.$$$", tmpstr,
                          PICK_FORE, PICK_BACK, PICK_BORDER, PICK_HILITE) != -1)
                  {
                   for(i=0;i<9;i++) if(tmpstr[i] == ' ') tmpstr[i] = '\0';
                   strcpy(level_name, tmpstr);
                   sprintf(fname_lev, "dark\\%s.LEV", tmpstr);
                   if(fexists(fname_lev) == FALSE) extract_a_level(level_name);
                   sprintf(fname_pal, "dark\\%s.PAL", tmpstr);
                   sprintf(fname_inf, "dark\\%s.INF", tmpstr);
                   sprintf(fname_gol, "dark\\%s.GOL", tmpstr);
                   sprintf(fname_o  , "dark\\%s.O",   tmpstr);
                   level_selected = 1;
                  }
                 system("del temp\\levels.$$$ > NUL");
                 cleardevice();
                 break;
     case  'i' :
     case  'I' : if(level_selected)
                  {
                   gr_shutdown();
                   if(EDIT_ALLOWED)
                    sprintf(tmp, call_editor, fname_inf);
                   else
                    sprintf(tmp, call_pager, fname_inf);
                   system(tmp);
                   gr_startup();
                  }
                 break;
     case  'g' :
     case  'G' : if(level_selected)
                  {
                   gr_shutdown();
                   if(EDIT_ALLOWED)
                    sprintf(tmp, call_editor, fname_gol);
                   else
                    sprintf(tmp, call_pager, fname_gol);
                   system(tmp);
                   gr_startup();
                  }
                 break;
     case  'l' :
     case  'L' : if(level_selected)
                  {
                   gr_shutdown();
                   if(EDIT_LEV_ALLOWED)
                    sprintf(tmp, call_editor, fname_lev);
                   else
                    sprintf(tmp, call_pager, fname_lev);
                   system(tmp);
                   gr_startup();
                  }
                 break;
     case  'm' :
     case  'M' : if(level_selected)
                  {
                   gr_shutdown();
                   sprintf(tmp, "levmap %s", fname_lev);
                   system(tmp);
                   gr_startup();
                  }
                 break;
     case  'p' :
     case  'P' : if(level_selected)
                  {
                   set_mode_pal();
                  }
                 break;
     case  'o' :
     case  'O' : if(level_selected)
                  {
                   gr_shutdown();
                   if(EDIT_ALLOWED)
                    sprintf(tmp, call_editor, fname_o);
                   else
                    sprintf(tmp, call_pager, fname_o);
                   system(tmp);
                   gr_startup();
                  }
                 break;
     case  't' :
     case  'T' : if(level_selected)
                  {
                   if(TEST_AS_GOB == 1)
                   {
                   gr_shutdown();
                   strcpy(df_test_dir, "dfutest");
                   system("del dfutest\\*.*");
                   sprintf(tmp, "copy dark\\%s.* %s", level_name, df_test_dir);
                   system(tmp);
                   sprintf(tmp, "copy dark\\jedi.lvl %s", df_test_dir);
                   system(tmp);
                   sprintf(tmp, "copy dark\\text.msg %s", df_test_dir);
                   system(tmp);
                   sprintf(tmp, "copy dark\\*.3do %s",    df_test_dir);
                   system(tmp);
                   sprintf(tmp, "copy textures\\*.bm %s", df_test_dir);
                   system(tmp);
                   sprintf(tmp, "copy sprites\\*.fme %s", df_test_dir);
                   system(tmp);
                   sprintf(tmp, "copy sprites\\*.wax %s", df_test_dir);
                   system(tmp);
                   sprintf(tmp, "copy sounds\\*.voc %s", df_test_dir);
                   system(tmp);
                   sprintf(tmp, "copy sounds\\*.gmd %s", df_test_dir);
                   system(tmp);
                   sprintf(tmp, "copy dfuplus\\*.* %s", df_test_dir);
                   system(tmp);
                   system("DIR2GOB DFUTEST testlevl.gob");
                   sprintf(tmp, "copy testlevl.gob %s", df_inst_dir);
                   system(tmp);
                   system("del dfutest\\*.*");
                   system("del testlevl.gob");
                   clrscr();
                   Beep(100,20);
                   sprintf(tmp, "%-2.2s", df_inst_dir);
                   system(tmp);
                   sprintf(tmp, "cd %s", &(df_inst_dir[2]));
                   system(tmp);
                   system("dark -utestlevl.gob");
                   gr_startup();
                   }
                   else
                   {
                   gr_shutdown();
                   sprintf(tmp, "copy dark\\%s.* %s", level_name, df_inst_dir);
                   system(tmp);
                   sprintf(tmp, "copy dark\\jedi.lvl %s", df_inst_dir);
                   system(tmp);
                   sprintf(tmp, "copy dark\\text.msg %s", df_inst_dir);
                   system(tmp);
                   sprintf(tmp, "copy dark\\*.3do %s",    df_inst_dir);
                   system(tmp);
                   sprintf(tmp, "copy textures\\*.bm %s", df_inst_dir);
                   system(tmp);
                   sprintf(tmp, "copy sprites\\*.fme %s", df_inst_dir);
                   system(tmp);
                   sprintf(tmp, "copy sprites\\*.wax %s", df_inst_dir);
                   system(tmp);
                   sprintf(tmp, "copy sounds\\*.voc %s", df_inst_dir);
                   system(tmp);
                   sprintf(tmp, "copy sounds\\*.gmd %s", df_inst_dir);
                   system(tmp);
                   sprintf(tmp, "copy dfuplus\\*.* %s", df_inst_dir);
                   system(tmp);
                   clrscr();
                   Beep(100,20);
                   sprintf(tmp, "%-2.2s", df_inst_dir);
                   system(tmp);
                   sprintf(tmp, "cd %s", &(df_inst_dir[2]));
                   system(tmp);
                   system("dark");
                   gr_startup();
                   }
                  }
                 break;
     case  'z' :
     case  'Z' : shell_to_DOS();
                 break;
    };
    write_lvl_menu();
  } while((ccc=getVK()) != VK_ESC);
}

void write_lvl_menu()
{
 char tmp[127];

 draw_menu_box();

 setcolor(MENU_FORE);
 outtextxy(OUT_X, OUT_Y +   8,"     DFUSE Levels MENU");
 draw_menu_copyright();
 if(level_selected)
 {
  sprintf(tmp, " [C].  Change from %s", level_name);
  outtextxy(OUT_X, OUT_Y +  50, tmp);
 }
 else
 {
  outtextxy(OUT_X, OUT_Y +  50," [C].  CHOOSE LEVEL !!");
  setcolor(MENU_BACK);
 }
 outtextxy(OUT_X, OUT_Y +  65," [I].  Edit .INF");
 outtextxy(OUT_X, OUT_Y +  80," [G].  Edit .GOL");
 outtextxy(OUT_X, OUT_Y +  95," [L].  Edit .LEV (Txt)");
 outtextxy(OUT_X, OUT_Y + 110," [M].  Edit .LEV (Map)");
 outtextxy(OUT_X, OUT_Y + 125," [O].  Edit .O");
 outtextxy(OUT_X, OUT_Y + 140," [P].  View Palette");
 outtextxy(OUT_X, OUT_Y + 155," [T].  Test Level");
 setcolor(MENU_FORE);
 draw_menu_footer();
}
