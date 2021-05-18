#include "dfuse.h"
#include "dfuseext.h"

/* ************************************************************************** */
/* GOB MENU                                                                   */
/* ************************************************************************** */

void gob_menu()
{
 char tmp[127];
 char gob[127];
 int  i;

 cleardevice();
 ccc = 0;
 write_gob_menu();
 do
  {
   switch(ccc)
    {
     case  'j' : 
     case  'J' : extract_a_file("DARK", "JEDI.LVL");
                 break;
     case  'l' :
     case  'L' : system("seejedi dark\\jedi.lvl > temp\\levels.$$$");
                 if(listpick(318, 198, "Please pick a level", "temp\\levels.$$$", tmpstr,
                          PICK_FORE, PICK_BACK, PICK_BORDER, PICK_HILITE) != -1)
                  {
                   for(i=0;i<9;i++) if(tmpstr[i] == ' ') tmpstr[i] = '\0';
                   strcpy(level_name, tmpstr);
                   extract_a_level(level_name);
                   sprintf(fname_lev, "dark\\%s.LEV", tmpstr);
                   sprintf(fname_pal, "dark\\%s.PAL", tmpstr);
                   sprintf(fname_inf, "dark\\%s.INF", tmpstr);
                   sprintf(fname_gol, "dark\\%s.GOL", tmpstr);
                   sprintf(fname_o  , "dark\\%s.O", tmpstr);
                   level_selected = 1;
                  }
                 system("del temp\\levels.$$$ > NUL");
                 cleardevice();
                 break;
     case  't' :
     case  'T' : extract_a_file("DARK", "TEXT.MSG");
                 break;
     case  'x' :
     case  'X' : if(listpick(318, 198, "Please pick a .GOB", "dfudata\\gobs.dfu", tmpstr,
                          PICK_FORE, PICK_BACK, PICK_BORDER, PICK_HILITE) != -1)
                  {
                   for(i=0;i<9;i++) if(tmpstr[i] == ' ') tmpstr[i] = '\0';
                   if(strcmp(tmpstr, "DARK") == 0)     strcpy(gob, dark_gob);
                   if(strcmp(tmpstr, "TEXTURES") == 0) strcpy(gob, textures_gob);
                   if(strcmp(tmpstr, "SPRITES") == 0)  strcpy(gob, sprites_gob);
                   if(strcmp(tmpstr, "SOUNDS") == 0)   strcpy(gob, sounds_gob);
                   sprintf(tmp, "gobinfo %s /r | sort > temp\\gobdir.$$$", gob);
                   system(tmp);
                   strcpy(tmp, tmpstr);    /* careful here ! */
                   if(listpick(318, 198, "Please pick a file", "temp\\gobdir.$$$", tmpstr,
                          PICK_FORE, PICK_BACK, PICK_BORDER, PICK_HILITE) != -1)
                    {
                     extract_a_file(tmp, tmpstr);
                    }
                   system("del temp\\gobdir.$$$ > NUL");
                  }
                 cleardevice();
                 break;
     case  'z' :
     case  'Z' : shell_to_DOS();
                 break;
    };
    write_gob_menu();
  } while((ccc=getVK()) != VK_ESC);
}

void write_gob_menu()
{
 draw_menu_box();

 setcolor(MENU_FORE);
 outtextxy(OUT_X, OUT_Y +   8,"    Single .GOB Extract");
 draw_menu_copyright();
 setcolor(MENU_FORE);
 outtextxy(OUT_X, OUT_Y +  50," [J].  Extract JEDI.LVL");
 outtextxy(OUT_X, OUT_Y +  65," [L].  Extract a Level");
 outtextxy(OUT_X, OUT_Y +  80," [T].  Extract TEXT.MSG");
 outtextxy(OUT_X, OUT_Y + 110," [X].  Extract Single File");
 draw_menu_footer();
}

/* ************************************************************************** */
/* FULL GOB MENU                                                              */
/* ************************************************************************** */

void full_gob_menu()
{
 char tmp[127];
 char gob[127];
 int  i;

 cleardevice();
 ccc = 0;
 write_full_gob_menu();
 do
  {
   switch(ccc)
    {
     case  'e' :
     case  'E' : system("dir /B gobdata\\*.gom | sort > temp\\goms.$$$");
                 while(listpick(318, 198, "Please pick a .gom", "temp\\goms.$$$", tmpstr, PICK_FORE, PICK_BACK, PICK_BORDER, PICK_HILITE) != -1)
                  {
                   gr_shutdown();
                   sprintf(tmp, "gobdata\\%s", tmpstr);
                   strcpy(tmpstr, tmp);
                   sprintf(tmp, call_editor, tmpstr);
                   system(tmp);
                   gr_startup();
                  }
                 system("del temp\\goms.$$$ > NUL");
                 cleardevice();
                 break;
     case  'i' :
     case  'I' : while(listpick(318, 198, "Please pick a .gob", "dfudata\\gobs.dfu", tmpstr,
                          PICK_FORE, PICK_BACK, PICK_BORDER, PICK_HILITE) != -1)
                  {
                   for(i=0;i<9;i++) if(tmpstr[i] == ' ') tmpstr[i] = '\0';
                   if(strcmp(tmpstr, "DARK") == 0)     strcpy(gob, dark_gob);
                   if(strcmp(tmpstr, "TEXTURES") == 0) strcpy(gob, textures_gob);
                   if(strcmp(tmpstr, "SPRITES") == 0)  strcpy(gob, sprites_gob);
                   if(strcmp(tmpstr, "SOUNDS") == 0)   strcpy(gob, sounds_gob);
                   sprintf(tmp, "gobinfo %s > temp\\gobinfo.$$$", gob);
                   system(tmp);
                   gr_shutdown();
                   sprintf(tmp, call_pager, "temp\\gobinfo.$$$");
                   system(tmp);
                   system("del temp\\gobinfo.$$$ > NUL");
                   gr_startup();
                  }
                 cleardevice();
                 break;
     case  'm' :
     case  'M' : system("dir /B gobdata\\*.gom | sort > temp\\goms.$$$");
                 while(listpick(318, 198, "Please pick a .gom", "temp\\goms.$$$", tmpstr, PICK_FORE, PICK_BACK, PICK_BORDER, PICK_HILITE) != -1)
                  {
                   gr_shutdown();
                   sprintf(tmp, "gobmake gobdata\\%s > gobmake.log", tmpstr);
                   system(tmp);
                   sprintf(tmp, call_pager, "gobmake.log");
                   system(tmp);
                   gr_startup();
                  }
                 system("del temp\\goms.$$$ > NUL");
                 cleardevice();
                 break;
     case  'x' :
     case  'X' : while(listpick(318, 198, "Please pick a .gob", "dfudata\\gobs.dfu", tmpstr,
                          PICK_FORE, PICK_BACK, PICK_BORDER, PICK_HILITE) != -1)
                  {
                   for(i=0;i<9;i++) if(tmpstr[i] == ' ') tmpstr[i] = '\0';
                   if(strcmp(tmpstr, "DARK") == 0)     strcpy(gob, dark_gob);
                   if(strcmp(tmpstr, "TEXTURES") == 0) strcpy(gob, textures_gob);
                   if(strcmp(tmpstr, "SPRITES") == 0)  strcpy(gob, sprites_gob);
                   if(strcmp(tmpstr, "SOUNDS") == 0)   strcpy(gob, sounds_gob);
                   strcpy(tmpstr, gob);
                   cleardevice();
                   draw_menu_box();
                   setcolor(MENU_FORE);
                   outtextxy(OUT_X, OUT_Y +   8,"      GOB Extraction");
                   outtextxy(OUT_X, OUT_Y + 50 ,"Creating Extract Batch...");
                   sprintf(tmp, "gobinfo %s /s > gobx$$$.bat", tmpstr);
                   system(tmp);
                   outtextxy(OUT_X, OUT_Y + 65 ,"Updating GOBDATA...");
                   fnsplit(tmpstr, fns_drive, fns_dir, fns_fname, fns_ext);
                   strcpy(fns_ext2, fns_ext);
                   fns_ext2[strlen(fns_ext)-1] = 'M';
                   sprintf(tmp, "gobinfo %s /r > gobdata\\%s%s", tmpstr, fns_fname, fns_ext2);
                   system(tmp);
                   strcpy(tmpstr, "gobdata\\");
                   strcat(tmpstr, fns_fname);
                   strcat(tmpstr, fns_ext);
                   tmpstr[strlen(tmpstr)-1] = 'X';
                   outtextxy(OUT_X, OUT_Y + 80 ,"Deleting Extract Dir...");
                   sprintf(tmp, "deltree /Y %s > NUL", tmpstr);
                   system(tmp);
                   outtextxy(OUT_X, OUT_Y + 95 ,"Creating Extract Dir...");
                   sprintf(tmp, "md %s > NUL", tmpstr);
                   system(tmp);
                   sprintf(tmp, "move gobx$$$.bat %s > NUL", tmpstr);
                   system(tmp);
                   sprintf(tmp, "copy fextract.exe %s > NUL", tmpstr);
                   system(tmp);
                   sprintf(tmp, "cd %s > NUL", tmpstr);
                   system(tmp);
                   outtextxy(OUT_X, OUT_Y +110 ,"Extracting from .GOB...");
                   system("gobx$$$.bat > NUL");
                   system("del gobx$$$.bat > NUL");
                   system("del fextract.exe > NUL");
                   sprintf(tmp, "%s", golden_path_drive);
                   system(tmp);
                   sprintf(tmp, "cd %s", golden_path);
                   system(tmp);
                  }
                 cleardevice();
                 break;
     case  'z' :
     case  'Z' : shell_to_DOS();
                 break;
    };
    write_full_gob_menu();
  } while((ccc=getVK()) != VK_ESC);
}

void write_full_gob_menu()
{
 draw_menu_box();

 setcolor(MENU_FORE);
 outtextxy(OUT_X, OUT_Y +   8,"    Full .GOB Extract");
 draw_menu_copyright();
 outtextxy(OUT_X, OUT_Y +  50," [E].  Edit GOM file");
 outtextxy(OUT_X, OUT_Y +  65," [I].  GOB info");
 outtextxy(OUT_X, OUT_Y +  80," [M].  GOB make (reconstruct)");
 outtextxy(OUT_X, OUT_Y +  95," [X].  GOB extract");
 draw_menu_footer();
}

