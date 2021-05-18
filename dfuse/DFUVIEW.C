#include "dfuse.h"
#include "dfuseext.h"

void choose_palette(void)
{
 char tmp[127];

 cleardevice();
 draw_menu_box();
 setcolor(MENU_FORE);
 outtextxy(OUT_X, OUT_Y +   8,"      .PAL directory ");
 outtextxy(OUT_X, OUT_Y +  50,"    Please enter .PAL dir");
 outtextxy(OUT_X, OUT_Y + 188,"    Press [Esc] to Cancel");
 sprintf(tmpstr, "%s", pa_data_dir);
 if(stredit((getmaxx()-TOP_X)/2+8, (getmaxy()-TOP_Y)/2+80, tmpstr, 127, 38, EDIT_FORE, EDIT_BACK, EDIT_CURSOR) == VK_ENTER)
  {
   strcpy(pa_data_dir, tmpstr);
  }
 sprintf(tmp, "dir /B %s\\*.pal | sort > temp\\pals.$$$", pa_data_dir);
 system(tmp);
 if(listpick(318, 198, "Please pick a .pal", "temp\\pals.$$$", tmpstr, PICK_FORE, PICK_BACK, PICK_BORDER, PICK_HILITE) != -1)
  {
   strcpy(pa_file, tmpstr);
  }
 system("del temp\\pals.$$$ > NUL");
 cleardevice();
}

void prepare_viewer(char *which)
{
 char tmp[50];

 cleardevice();
 draw_menu_box();
 setcolor(MENU_FORE);
 sprintf(tmp, "       .%s directory", which);
 outtextxy(OUT_X, OUT_Y +   8, tmp);
 sprintf(tmp, "    Please enter .%s dir", which);
 outtextxy(OUT_X, OUT_Y +  50, tmp);
 outtextxy(OUT_X, OUT_Y + 188,"    Press [Esc] to Cancel");
}

void edit_ini(void)
{
 char tmp[127];

 gr_shutdown();
 sprintf(tmp, call_editor, DFUSE_INI);
 system(tmp);
 gr_startup();
}


/* ************************************************************************** */
/* VIEWERS MENU                                                               */
/* ************************************************************************** */

void view_menu()
{
 char tmp[127];
 int  i;

 cleardevice();
 ccc = 0;
 write_view_menu();
 do
  {
   switch(ccc)
    {
     case  'b' :
     case  'B' : bm_menu();
                 cleardevice();
                 break;
     case  'f' :
     case  'F' : fme_menu();
                 cleardevice();
                 break;
     case  'v' :
     case  'V' : voc_menu();
                 cleardevice();
                 break;
     case  'w' :
     case  'W' : wax_menu();
                 cleardevice();
                 break;
     case  'z' :
     case  'Z' : shell_to_DOS();
                 break;
    };
    write_view_menu();
  } while((ccc=getVK()) != VK_ESC);
}

void write_view_menu()
{
 char tmp[127];

 draw_menu_box();

 setcolor(MENU_FORE);
 outtextxy(OUT_X, OUT_Y +   8,"    DFUSE Viewers MENU");
 draw_menu_copyright();
 outtextxy(OUT_X, OUT_Y +  50," [B].  .BM  Menu (Textures)");
 outtextxy(OUT_X, OUT_Y +  65," [F].  .FME Menu (Frames)");
 outtextxy(OUT_X, OUT_Y +  80," [V].  .VOC Menu (Sounds)");
 outtextxy(OUT_X, OUT_Y +  95," [W].  .WAX Menu (Sprites)");
 setcolor(MENU_FORE);
 draw_menu_footer();
}

/* ************************************************************************** */
/* BM  MENU                                                                   */
/* ************************************************************************** */

void bm_menu()
{
 char tmp[127];
 char tmp2[127];
 int  i;

 cleardevice();
 ccc = 0;
 write_bm_menu();
 do
  {
   switch(ccc)
    {
     case  'c' :
     case  'C' : prepare_viewer("BM");
                 sprintf(tmpstr, "%s", bm_data_dir);
                 if(stredit((getmaxx()-TOP_X)/2+8, (getmaxy()-TOP_Y)/2+80, tmpstr, 127, 38, EDIT_FORE, EDIT_BACK, EDIT_CURSOR) == VK_ENTER)
                  {
                   strcpy(bm_data_dir, tmpstr);
                  }
                 cleardevice();
                 break;
     case  'p' :
     case  'P' : choose_palette();
                 break;
     case  'i' :
     case  'I' : edit_ini();
                 break;
     case  'v' :
     case  'V' : sprintf(tmp, "dir /B %s\\*.bm  | sort > temp\\bms.$$$", bm_data_dir);
                 system(tmp);
                 while(listpick(318, 198, "Please pick a .bm", "temp\\bms.$$$", tmpstr, PICK_FORE, PICK_BACK, PICK_BORDER, PICK_HILITE) != -1)
                  {
                   gr_shutdown();
                   sprintf(tmp, "bmview %s\\%s %s\\%s", bm_data_dir, tmpstr, pa_data_dir, pa_file);
                   system(tmp);
                   gr_startup();
                  }
                 system("del temp\\bms.$$$ > NUL");
                 cleardevice();
                 break;
     case  '2' : sprintf(tmp, "dir /B %s\\*.bm | sort > temp\\bms.$$$", bm_data_dir);
                 system(tmp);
                 if(listpick(318, 198, "Please pick a .bm", "temp\\bms.$$$", tmpstr, PICK_FORE, PICK_BACK, PICK_BORDER, PICK_HILITE) != -1)
                  {
                   gr_shutdown();
                   for(i=0;i<strlen(tmpstr);i++) if(tmpstr[i]==' ') tmpstr[i]='\0';
                   sprintf(tmp, "%s\\%s" , bm_data_dir, tmpstr);
                   strcpy(tmpstr, tmp);
                   sprintf(tmp, "bm2bmp %s %s\\%s %sp", tmpstr, pa_data_dir, pa_file, tmpstr);
                   system(tmp);
                   gr_startup();
                  }
                 system("del temp\\bms.$$$ > NUL");
                 cleardevice();
                 break;
     case  'z' :
     case  'Z' : shell_to_DOS();
                 break;
    };
    write_bm_menu();
  } while((ccc=getVK()) != VK_ESC);
}

void write_bm_menu()
{
 char tmp[127];
 char tmp2[127];

 draw_menu_box();
 strcpy(tmp, bm_data_dir);
 tmp[40] = '\0';
 strcpy(tmp2, pa_data_dir);
 if(strcmp(pa_data_dir,"") == 0) strcat(tmp2, ".");
 strcat(tmp2, "\\");
 strcat(tmp2, pa_file);
 tmp2[40] = '\0';

 setcolor(MENU_FORE);
 outtextxy(OUT_X, OUT_Y +   8,"      DFUSE .BM  MENU");
 draw_menu_copyright();
 outtextxy(OUT_X, OUT_Y +  35," Current .BM directory is :");
 outtextxy(OUT_X, OUT_Y +  65," Current .PAL for [V] & [2] is :");
 setcolor(MENU_DIR);
 outtextxy((getmaxx()-TOP_X)/2+4 ,(getmaxy()-TOP_Y)/2+  50, tmp);
 outtextxy((getmaxx()-TOP_X)/2+4 ,(getmaxy()-TOP_Y)/2+  80, tmp2);
 setcolor(MENU_FORE);
 outtextxy(OUT_X, OUT_Y +  95," [C].  Change .BM directory");
 outtextxy(OUT_X, OUT_Y + 110," [I].  Edit "DFUSE_INI);
 outtextxy(OUT_X, OUT_Y + 125," [P].  Change .PAL");
 outtextxy(OUT_X, OUT_Y + 140," [V].  View .BM");
 outtextxy(OUT_X, OUT_Y + 155," [2].  .BM -> .BMP");
 draw_menu_footer();
}

/* ************************************************************************** */
/* FME MENU                                                                   */
/* ************************************************************************** */

void fme_menu()
{
 char tmp[127];
 char tmp2[127];
 int  i;

 cleardevice();
 ccc = 0;
 write_fme_menu();
 do
  {
   switch(ccc)
    {
     case  'c' :
     case  'C' : prepare_viewer("FME");
                 sprintf(tmpstr, "%s", fme_data_dir);
                 if(stredit((getmaxx()-TOP_X)/2+8, (getmaxy()-TOP_Y)/2+80, tmpstr, 127, 38, EDIT_FORE, EDIT_BACK, EDIT_CURSOR) == VK_ENTER)
                  {
                   strcpy(fme_data_dir, tmpstr);
                  }
                 cleardevice();
                 break;
     case  'p' :
     case  'P' : choose_palette();
                 break;
     case  'i' :
     case  'I' : edit_ini();
                 break;
     case  'v' :
     case  'V' : sprintf(tmp, "dir /B %s\\*.fme | sort > temp\\fmes.$$$", fme_data_dir);
                 system(tmp);
                 while(listpick(318, 198, "Please pick a .fme", "temp\\fmes.$$$", tmpstr, PICK_FORE, PICK_BACK, PICK_BORDER, PICK_HILITE) != -1)
                  {
                   gr_shutdown();
                   sprintf(tmp, "fmeview %s\\%s %s\\%s", fme_data_dir, tmpstr, pa_data_dir, pa_file);
                   system(tmp);
                   gr_startup();
                  }
                 system("del temp\\fmes.$$$ > NUL");
                 cleardevice();
                 break;
     case  'z' :
     case  'Z' : shell_to_DOS();
                 break;
    };
    write_fme_menu();
  } while((ccc=getVK()) != VK_ESC);
}

void write_fme_menu()
{
 char tmp[127];
 char tmp2[127];

 draw_menu_box();
 strcpy(tmp, fme_data_dir);
 tmp[40] = '\0';
 strcpy(tmp2, pa_data_dir);
 if(strcmp(pa_data_dir,"") == 0) strcat(tmp2, ".");
 strcat(tmp2, "\\");
 strcat(tmp2, pa_file);
 tmp2[40] = '\0';

 setcolor(MENU_FORE);
 outtextxy(OUT_X, OUT_Y +   8,"     DFUSE .FME MENU");
 draw_menu_copyright();
 outtextxy(OUT_X, OUT_Y +  35," Current .FME directory is :");
 outtextxy(OUT_X, OUT_Y +  65," Current .PAL for [V] & [2] is :");
 setcolor(MENU_DIR);
 outtextxy((getmaxx()-TOP_X)/2+4 ,(getmaxy()-TOP_Y)/2+  50, tmp);
 outtextxy((getmaxx()-TOP_X)/2+4 ,(getmaxy()-TOP_Y)/2+  80, tmp2);
 setcolor(MENU_FORE);
 outtextxy(OUT_X, OUT_Y +  95," [C].  Change .FME directory");
 outtextxy(OUT_X, OUT_Y + 110," [I].  Edit "DFUSE_INI);
 outtextxy(OUT_X, OUT_Y + 125," [P].  Change .PAL");
 outtextxy(OUT_X, OUT_Y + 140," [V].  View .FME");
 draw_menu_footer();
}

/* ************************************************************************** */
/* WAX MENU                                                                   */
/* ************************************************************************** */

void wax_menu()
{
 char tmp[127];
 char tmp2[127];
 int  i;

 cleardevice();
 ccc = 0;
 write_wax_menu();
 do
  {
   switch(ccc)
    {
     case  'c' :
     case  'C' : prepare_viewer("WAX");
                 sprintf(tmpstr, "%s", wax_data_dir);
                 if(stredit((getmaxx()-TOP_X)/2+8, (getmaxy()-TOP_Y)/2+80, tmpstr, 127, 38, EDIT_FORE, EDIT_BACK, EDIT_CURSOR) == VK_ENTER)
                  {
                   strcpy(wax_data_dir, tmpstr);
                  }
                 cleardevice();
                 break;
     case  'p' :
     case  'P' : choose_palette();
                 break;
     case  'i' :
     case  'I' : edit_ini();
                 break;
     case  'v' :
     case  'V' : sprintf(tmp, "dir /B %s\\*.wax | sort > temp\\waxs.$$$", wax_data_dir);
                 system(tmp);
                 while(listpick(318, 198, "Please pick a .wax", "temp\\waxs.$$$", tmpstr, PICK_FORE, PICK_BACK, PICK_BORDER, PICK_HILITE) != -1)
                  {
                   gr_shutdown();
                   sprintf(tmp, "waxview %s\\%s %s\\%s", wax_data_dir, tmpstr, pa_data_dir, pa_file);
                   system(tmp);
                   gr_startup();
                  }
                 system("del temp\\waxs.$$$ > NUL");
                 cleardevice();
                 break;
     case  'z' :
     case  'Z' : shell_to_DOS();
                 break;
    };
    write_wax_menu();
  } while((ccc=getVK()) != VK_ESC);
}

void write_wax_menu()
{
 char tmp[127];
 char tmp2[127];

 draw_menu_box();
 strcpy(tmp, wax_data_dir);
 tmp[40] = '\0';
 strcpy(tmp2, pa_data_dir);
 if(strcmp(pa_data_dir,"") == 0) strcat(tmp2, ".");
 strcat(tmp2, "\\");
 strcat(tmp2, pa_file);
 tmp2[40] = '\0';

 setcolor(MENU_FORE);
 outtextxy(OUT_X, OUT_Y +   8,"     DFUSE .WAX MENU");
 draw_menu_copyright();
 outtextxy(OUT_X, OUT_Y +  35," Current .WAX directory is :");
 outtextxy(OUT_X, OUT_Y +  65," Current .PAL for [V] & [2] is :");
 setcolor(MENU_DIR);
 outtextxy((getmaxx()-TOP_X)/2+4 ,(getmaxy()-TOP_Y)/2+  50, tmp);
 outtextxy((getmaxx()-TOP_X)/2+4 ,(getmaxy()-TOP_Y)/2+  80, tmp2);
 setcolor(MENU_FORE);
 outtextxy(OUT_X, OUT_Y +  95," [C].  Change .WAX directory");
 outtextxy(OUT_X, OUT_Y + 110," [I].  Edit "DFUSE_INI);
 outtextxy(OUT_X, OUT_Y + 125," [P].  Change .PAL");
 outtextxy(OUT_X, OUT_Y + 140," [V].  View .WAX");
 draw_menu_footer();
}

/* ************************************************************************** */
/* VOC MENU                                                                   */
/* ************************************************************************** */

void voc_menu()
{
 char tmp[127];

 cleardevice();
 ccc = 0;
 write_voc_menu();
 do
  {
   switch(ccc)
    {
     case  'c' :
     case  'C' : prepare_viewer("VOC");
                 sprintf(tmpstr, "%s", vo_data_dir);
                 if(stredit((getmaxx()-TOP_X)/2+8, (getmaxy()-TOP_Y)/2+80, tmpstr, 127, 38, EDIT_FORE, EDIT_BACK, EDIT_CURSOR) == VK_ENTER)
                  {
                   strcpy(vo_data_dir, tmpstr);
                  }
                 cleardevice();
                 break;
     case  'i' :
     case  'I' : edit_ini();
                 break;
     case  'p' :
     case  'P' : sprintf(tmp, "dir /B %s\\*.voc | sort > temp\\vocs.$$$", vo_data_dir);
                 system(tmp);
                 while(listpick(318, 198, "Please pick a .voc", "temp\\vocs.$$$", tmpstr, PICK_FORE, PICK_BACK, PICK_BORDER, PICK_HILITE) != -1)
                  {
                   gr_shutdown();
                   sprintf(tmp, "%s\\%s" , vo_data_dir, tmpstr);
                   strcpy(tmpstr, tmp);
                   sprintf(tmp, call_vocplayer, tmpstr);
                   system(tmp);
                   gr_startup();
                  }
                 system("del temp\\vocs.$$$ > NUL");
                 cleardevice();
                 break;
     case  '2' : sprintf(tmp, "dir /B %s\\*.voc | sort > temp\\vocs.$$$", vo_data_dir);
                 system(tmp);
                 if(listpick(318, 198, "Please pick a .voc", "temp\\vocs.$$$", tmpstr, PICK_FORE, PICK_BACK, PICK_BORDER, PICK_HILITE) != -1)
                  {
                   gr_shutdown();
                   sprintf(tmp, "%s\\%s" , vo_data_dir, tmpstr);
                   strcpy(tmpstr, tmp);
                   sprintf(tmp, call_voc2wav, tmpstr);
                   system(tmp);
                  }
                 system("del temp\\vocs.$$$ > NUL");
                 cleardevice();
                 break;
     case  'z' :
     case  'Z' : shell_to_DOS();
                 break;
    };
    write_voc_menu();
  } while((ccc=getVK()) != VK_ESC);
}

void write_voc_menu()
{
 char tmp[127];

 draw_menu_box();
 strcpy(tmp, vo_data_dir);
 tmp[40] = '\0';

 setcolor(MENU_FORE);
 outtextxy(OUT_X, OUT_Y +   8,"      DFUSE .VOC MENU");
 draw_menu_copyright();
 outtextxy(OUT_X, OUT_Y +  50," Current .VOC directory is :");
 setcolor(MENU_DIR);
 outtextxy((getmaxx()-TOP_X)/2+4 ,(getmaxy()-TOP_Y)/2+  65, tmp);
 setcolor(MENU_FORE);
 outtextxy(OUT_X, OUT_Y +  95," [C].  Change .VOC directory");
 outtextxy(OUT_X, OUT_Y + 110," [I].  Edit "DFUSE_INI);
 outtextxy(OUT_X, OUT_Y + 125," [P].  Play .VOC");
 outtextxy(OUT_X, OUT_Y + 140," [2].  .VOC -> .WAV");
 draw_menu_footer();
}
