/* ========================================================================== */
/* LEVGENER.C : GENERAL PURPOSE FUNCTIONS                                     */
/*              * help                                                        */
/*              * graphics startup and shutdown                               */
/*              * command line checking and file name assignments             */
/*              * cleanup functions                                           */
/*              * .INI handling                                               */
/*              * GOB finding and possibly CD                                 */
/*              * mouse handling (also see basic mouse handling in TOOLKIT)   */
/* ========================================================================== */
#include "levmap.h"
#include "levext.h"
#include <alloc.h>

/* ************************************************************************** */
/* HELP FUNCTIONS                                                             */
/* ************************************************************************** */

void show_help_keys(void)
{
 char tmp[127];

 gr_shutdown();
 sprintf(tmp, call_pager, "doc\\levkeys.doc");
 system(tmp);
 gr_startup();
 handle_titlebar(HEAD_BACK, HEAD_BORDER);
}

void show_help_doc(void)
{
 char tmp[127];

 gr_shutdown();
 sprintf(tmp, call_pager, "doc\\levmap.doc");
 system(tmp);
 gr_startup();
 handle_titlebar(HEAD_BACK, HEAD_BORDER);
}

void show_help_specs(void)
{
 char tmp[127];

 gr_shutdown();
 sprintf(tmp, call_pager, "doc\\df_specs.doc");
 system(tmp);
 gr_startup();
 handle_titlebar(HEAD_BACK, HEAD_BORDER);
}

void notepad(void)
{
 char tmp[127];

 gr_shutdown();
 sprintf(tmp, call_editor, "doc\\notepad.txt");
 system(tmp);
 gr_startup();
 handle_titlebar(HEAD_BACK, HEAD_BORDER);
}

/* ************************************************************************** */
/* GRAPHICS & TEXT MODES                                                      */
/* ************************************************************************** */

void gr_startup()
{
 char  tmp[127];

 int   f1;
 union  REGS   regs;
 struct SREGS  sregs;

 /* to avoid problems with current directory due to OS Shell option */
 sprintf(tmp, "%s", golden_path_drive);
 system(tmp);
 sprintf(tmp, "cd %s", golden_path);
 system(tmp);

 gdriver = installuserdriver(BGIdriver, NULL);
 gmode   = BGImode;
 initgraph(&gdriver, &gmode, NULL);
 errorcode = graphresult();
 if (errorcode != grOk)
   {
    printf("\n\n\n\nGraphic Error : %d\n", errorcode);
    exit(ERR_GRAPHIC);
   }
 cleardevice();

 /* correct default pal handling !! */
 if((f1=open("dfuse.pal" , O_BINARY | O_RDONLY)) == -1)
  {
   /* error handling !! */
   gr_shutdown();
   printf("DFUSE.PAL not found !!\n");
   printf("Restore a copy in your DFUSE main directory and retry.\n");
   getVK();
   exit(999);
  }
 read(f1, &DACbuffer, 768);
 close(f1);

 regs.x.ax = 0x1012;
 regs.x.bx = 0;
 regs.x.cx = 256;
 sregs.es  = FP_SEG(DACbuffer);
 regs.x.dx = FP_OFF(DACbuffer);
 int86x( 0x10, &regs, &regs, &sregs );

 ScreenX = getmaxx();
 ScreenY = getmaxy();
 ScreenCenterX = getmaxx() / 2;
 ScreenCenterY = (getmaxy() - TITLE_BOX_Y) / 2;

 ClipMouse(0, 0, getmaxx()-7, getmaxy()-TITLE_BOX_Y-7);
}

void gr_shutdown()
{
 closegraph();
 restorecrtmode();
}

/* ************************************************************************** */
/* INI file handling                                                          */
/* ************************************************************************** */

void handle_ini()
{
 char section[50];

 if(fexists(DFUSE_INI))
  {
   ReadIniString("INSTALLED", "DIR", "c:\\dark", df_inst_dir, 80, DFUSE_INI);

   strcpy(section, "TOOLS");
   ReadIniString(section, "EDIT", "edit %s" ,       call_editor, 100, DFUSE_INI);
   ReadIniString(section, "PAGE", "edit %s" ,       call_pager,  100, DFUSE_INI);
   ReadIniString(section, "VOCPLAYER", "vplay %s" , call_vplayer,100, DFUSE_INI);

   strcpy(section, "LEVMAP-MEM");
   MAX_VERTICES   = ReadIniInt(section, "VERT",        4000, DFUSE_INI);
   MAX_WALLS      = ReadIniInt(section, "WALL",        4000, DFUSE_INI);
   SUP_SECTORS    = ReadIniInt(section, "SSEC",          80, DFUSE_INI);
   SUP_OBJECTS    = ReadIniInt(section, "SOBJ",          80, DFUSE_INI);
   BM_MEMORY      = ReadIniInt(section, "BUF",          140, DFUSE_INI);

   strcpy(section, "LEVMAP-TXT-COLORS");
   TX_ATTR_TITL   = ReadIniInt(section, "TITLE",         78, DFUSE_INI);
   TX_ATTR_BACK   = ReadIniInt(section, "BACKG",         23, DFUSE_INI);
   TX_ATTR_EDIT   = ReadIniInt(section, "EDIT",          62, DFUSE_INI);

   strcpy(section, "LEVMAP-MAP-COLORS");
   HEAD_FORE      = ReadIniInt(section, "HEAD_FORE",      1, DFUSE_INI);
   HEAD_BACK      = ReadIniInt(section, "HEAD_BACK",     17, DFUSE_INI);
   HEAD_BORDER    = ReadIniInt(section, "HEAD_BORDER",    5, DFUSE_INI);
   LINE_AT_ALT    = ReadIniInt(section, "LINE_AT_ALT",   10, DFUSE_INI);
   LINW_AT_ALT    = ReadIniInt(section, "LINW_AT_ALT",   12, DFUSE_INI);
   LINE_NOTALT    = ReadIniInt(section, "LINE_NOTALT",   56, DFUSE_INI);
   LINE_SECRET    = ReadIniInt(section, "LINE_SECRET",   15, DFUSE_INI);
   LINE_ELEV      = ReadIniInt(section, "LINE_ELEV",     19, DFUSE_INI);
   LINE_TRIG      = ReadIniInt(section, "LINE_TRIG",      5, DFUSE_INI);
   HILI_AT_ALT    = ReadIniInt(section, "HILI_AT_ALT",    6, DFUSE_INI);
   HILI_NOTALT    = ReadIniInt(section, "HILI_NOTALT",    8, DFUSE_INI);
   OBJ_HILITED    = ReadIniInt(section, "OBJ_HILITED",    2, DFUSE_INI);
   OBJ_NOTHILI    = ReadIniInt(section, "OBJ_NOTHILI",   15, DFUSE_INI);
   COLOR_DELETED  = ReadIniInt(section, "DELETED",       24, DFUSE_INI);
   COLOR_GRID     = ReadIniInt(section, "GRID",          21, DFUSE_INI);
   COLOR_MULTISEL = ReadIniInt(section, "MULTISEL",       1, DFUSE_INI);
   COLOR_ERASER   = HEAD_BACK;
   REVERSE        = ReadIniInt("CURSORS", "DIRECTION",   -1, DFUSE_INI);

   strcpy(section, "LEVMAP-OPTIONS");
   SHADOW         = ReadIniInt(section, "SHADOW",         1, DFUSE_INI);
   OBJECT_LAYERING= ReadIniInt(section, "OBLAYER",        1, DFUSE_INI);
   CENTERZOOM     = ReadIniInt(section, "CENTERZOOM",     1, DFUSE_INI);

   strcpy(section, "LEVMAP-GEN");
   ReadIniString(section, "AUTHOR", "LCE", MAP_AUTHOR,   50, DFUSE_INI);
   ReadIniString(section, "COMNT1", "*",   MAP_COMNT1,   70, DFUSE_INI);
   ReadIniString(section, "COMNT2", "*",   MAP_COMNT2,   70, DFUSE_INI);

   ReadIniString("LEVMAP-BGI", ".BGI", "", BGIdriver,    10, DFUSE_INI);
   BGImode = ReadIniInt("LEVMAP-BGI", "MODE",         30000, DFUSE_INI);

   /* [DEFAULT-BGI] handling */
   if((strcmp(BGIdriver,"")==0) || (BGImode == 30000))
    {
     ReadIniString("DEFAULT-BGI", ".BGI", "", BGIdriver, 10, DFUSE_INI);
     BGImode = ReadIniInt("DEFAULT-BGI", "MODE", 30000, DFUSE_INI);
     if((strcmp(BGIdriver,""))==0 || (BGImode == 30000))
      {
       printf("LEVMAP can't find coherent values for .BGI and MODE !\n");
       printf("Please reconfigure the [DEFAULT-BGI] or [LEVMAP-BGI] sections of DFUSE.INI .\n\n");
       getVK();
       exit(ERR_GRAPHIC);
      }
    }
   /* add default palette handling */
  }
 else
  {
   printf("LEVMAP can't find "DFUSE_INI"\n");
   printf("Please restore and reconfigure it.\n\n");
   exit(ERR_INIFILE);
  }
}

/* ************************************************************************** */
/* command line checking and file names assignments                           */
/* ************************************************************************** */

void chk_cmdline()
{
 /* Check number of arguments */
 if(_argc != 2)
   {
    printf("LEVMAP "LEVMAP_VERSION" (c) Yves BORCKMANS 1995\n\n");
    printf("Usage is LEVMAP levfile\n\n");
    printf("(Note : corresponding .O & .INF files must also exist!)\n");
    exit(ERR_CMDLINE);
   };

  strcpy(fname_lev, _argv[1]);
  if(fexists(_argv[1]) == FALSE)
   {
    printf("%s doesn't exist! \n", fname_lev);
    exit(ERR_WRONGFILE);
   };

  strcpy(fname_o, _argv[1]);
  fname_o[strlen(fname_o)-3] = 'o';
  fname_o[strlen(fname_o)-2] = '\0';

 if(fexists(fname_o) == FALSE)
  {
   printf("%s doesn't exist! \n", fname_o);
   exit(ERR_WRONGFILE);
  };

  strcpy(fname_inf, _argv[1]);
  fname_inf[strlen(fname_inf)-3] = 'i';
  fname_inf[strlen(fname_inf)-2] = 'n';
  fname_inf[strlen(fname_inf)-1] = 'f';

  strcpy(fname_gol, _argv[1]);
  fname_gol[strlen(fname_gol)-3] = 'g';
  fname_gol[strlen(fname_gol)-2] = 'o';
  fname_gol[strlen(fname_gol)-1] = 'l';

  strcpy(fname_tex, _argv[1]);
  fname_tex[strlen(fname_tex)-3] = 't';
  fname_tex[strlen(fname_tex)-2] = 'e';
  fname_tex[strlen(fname_tex)-1] = 'x';

  strcpy(fname_sec, _argv[1]);
  fname_sec[strlen(fname_sec)-3] = 's';
  fname_sec[strlen(fname_sec)-2] = 'e';
  fname_sec[strlen(fname_sec)-1] = 'c';

  strcpy(fname_wal, _argv[1]);
  fname_wal[strlen(fname_wal)-3] = 'w';
  fname_wal[strlen(fname_wal)-2] = 'a';
  fname_wal[strlen(fname_wal)-1] = 'l';

  strcpy(fname_obj, _argv[1]);
  fname_obj[strlen(fname_obj)-3] = 'o';
  fname_obj[strlen(fname_obj)-2] = 'b';
  fname_obj[strlen(fname_obj)-1] = 't';

  strcpy(fname_pods, _argv[1]);
  fname_pods[strlen(fname_pods)-3] = 'p';
  fname_pods[strlen(fname_pods)-2] = 'o';
  fname_pods[strlen(fname_pods)-1] = 'd';

  strcpy(fname_sprs, _argv[1]);
  fname_sprs[strlen(fname_sprs)-3] = 's';
  fname_sprs[strlen(fname_sprs)-2] = 'p';
  fname_sprs[strlen(fname_sprs)-1] = 'r';

  strcpy(fname_fmes, _argv[1]);
  fname_fmes[strlen(fname_fmes)-3] = 'f';
  fname_fmes[strlen(fname_fmes)-2] = 'm';
  fname_fmes[strlen(fname_fmes)-1] = 's';

  strcpy(fname_sounds, _argv[1]);
  fname_sounds[strlen(fname_sounds)-3] = 's';
  fname_sounds[strlen(fname_sounds)-2] = 'n';
  fname_sounds[strlen(fname_sounds)-1] = 'd';
}

/* ************************************************************************** */
/* CLEANUP FUNCTIONS                                                          */
/* ************************************************************************** */

void close_temp_files(void)
{
 close(fsec);
 close(fwal);
 close(fobj);

 remove(fname_sec);
 remove(fname_wal);
 remove(fname_obj);
}

void free_memory(void)
{
 farfree(MAP_SEC);
 farfree(MAP_VRT);
 farfree(MAP_WAL);
 farfree(MAP_OBJ);
}

/* ************************************************************************** */
/* TRY TO FIND LOCATIONS FOR THE GOB FILES (and possibly the CD)              */
/* ************************************************************************** */

void handle_locations()
{
 char trythis[101];
 int  found_dark      = 0;
 int  found_textures  = 0;
 int  found_sprites   = 0;
 int  found_sounds    = 0;
 char drive_cd[3]     = "?:";
 int  fcd;
 int  problem         = 0;
 char problem_in[20];

 strcpy(trythis, df_inst_dir);
 strcat(trythis, "\\dark.gob");
 if(fexists(trythis))
  {
   strcpy(dark_gob, trythis);
   found_dark = 1;
  }

 strcpy(trythis, df_inst_dir);
 strcat(trythis, "\\textures.gob");
 if(fexists(trythis))
  {
   strcpy(textures_gob, trythis);
   found_textures = 1;
  }

 strcpy(trythis, df_inst_dir);
 strcat(trythis, "\\sprites.gob");
 if(fexists(trythis))
  {
   strcpy(sprites_gob, trythis);
   found_sprites = 1;
  }

 strcpy(trythis, df_inst_dir);
 strcat(trythis, "\\sounds.gob");
 if(fexists(trythis))
  {
   strcpy(sounds_gob, trythis);
   found_sounds = 1;
  }

 if(!found_dark || !found_textures || !found_sprites || !found_sounds)
  {
   strcpy(trythis, df_inst_dir);
   strcat(trythis, "\\drive.cd");
   if(fexists(trythis))
    {
     fcd = open(trythis , O_BINARY | O_RDONLY);
     read(fcd, drive_cd, 1);
     close(fcd);

     if(!found_dark)
      {
       strcpy(trythis, drive_cd);
       strcat(trythis, "\\dark\\dark.gob");
       if(fexists(trythis))
         strcpy(dark_gob, trythis);
       else
        {
         problem = 1;
         strcpy(problem_in, "dark.gob");
        }
      }
     if(!found_textures)
      {
       strcpy(trythis, drive_cd);
       strcat(trythis, "\\dark\\textures.gob");
       if(fexists(trythis))
         strcpy(textures_gob, trythis);
       else
        {
         problem = 1;
         strcpy(problem_in, "textures.gob");
        }
      }
     if(!found_sprites)
      {
       strcpy(trythis, drive_cd);
       strcat(trythis, "\\dark\\sprites.gob");
       if(fexists(trythis))
         strcpy(sprites_gob, trythis);
       else
        {
         problem = 1;
         strcpy(problem_in, "sprites.gob");
        }
      }
     if(!found_sounds)
      {
       strcpy(trythis, drive_cd);
       strcat(trythis, "\\dark\\sounds.gob");
       if(fexists(trythis))
         strcpy(sounds_gob, trythis);
       else
        {
         problem = 1;
         strcpy(problem_in, "sounds.gob");
        }
      }

     if(problem)
      {
       printf("LEVMAP can't find %s on the CD.\n", problem_in);
       printf("If you have inserted the wrong CD, replace it and restart DFUSE.\n");
       printf("Else you may have a software / hardware / CD support problem.\n");
       printf("Aborting... Press Any Key to Continue\n");
       getVK();
       exit(ERR_NOTFOUND);
      }
    }
   else
    {
     printf("LEVMAP can't find drive.cd in you install dir.\n");
     printf("It needs it to find your CD files.\n");
     printf("Try to launch the game, as this will recreate it.\n");
     printf("Aborting... Press Any Key to Continue\n");
     getVK();
     exit(ERR_NOTFOUND);
    }
  }
}

/* ************************************************************************** */
/* MOUSE HANDLING                                                             */
/* ************************************************************************** */

void handle_mouse()
{
 int  mx,my;
 char tmp[80];
 int  g1,g2;

 GetMousePos(&mx, &my);
 MAP_MOUSE_X  = S2MXF(mx);
 MAP_MOUSE_Z  = S2MYF(my);

 g1 = ( (int)S2MXF(mx)/grid )*grid;
 if(g1 > 0) g2 = g1 + grid; else g2 = g1 - grid;
 if( abs((int)S2MXF(mx)-g1) < abs((int)S2MXF(mx)-g2) )
  MAP_MOUSE_GX = (float)g1;
 else
  MAP_MOUSE_GX = (float)g2;

 g1 = ( (int)S2MYF(my)/grid )*grid;
 if(g1 > 0) g2 = g1 + grid; else g2 = g1 - grid;
 if( abs((int)S2MYF(my)-g1) < abs((int)S2MY(my)-g2) )
  MAP_MOUSE_GZ = (float)g1;
 else
  MAP_MOUSE_GZ = (float)g2;

 if(oldmx == -32000)
  {
   sprintf(tmp, "%-6.2f , %-6.2f  %s  æ : %d", S2MXF(mx), S2MYF(my), MAP_MODE_NAMES, MULTISEL);
   setcolor(HEAD_FORE);
   outtextxy(4,ScreenY-TITLE_BOX_Y-12, tmp);
   oldmx = mx;
   oldmy = my;
   show_mouse(mx, my);
  }

 if((oldmx != mx) || (oldmy != my) )
  {
    hide_mouse(oldmx, oldmy);
    sprintf(tmp, "%-6.2f , %-6.2f  %s  æ : %d", S2MXF(oldmx), S2MYF(oldmy), MAP_MODE_NAMES, MULTISEL);
    setcolor(0);
    outtextxy(4,ScreenY-TITLE_BOX_Y-12, tmp);
    sprintf(tmp, "%-6.2f , %-6.2f  %s  æ : %d", S2MXF(mx), S2MYF(my), MAP_MODE_NAMES, MULTISEL);
    setcolor(HEAD_FORE);
    outtextxy(4,ScreenY-TITLE_BOX_Y-12, tmp);
    oldmx = mx;
    oldmy = my;
    show_mouse(mx, my);
  };
}

void create_mouse()
{
 /* what is the real size ? (for later...) */
 mouse_cursor     = malloc(250);
 mouse_background = malloc(250);
              
 putpixel(0,0,HEAD_FORE);
 putpixel(1,1,HEAD_FORE); putpixel(0,1,HEAD_FORE); putpixel(1,0,HEAD_FORE);
 putpixel(2,2,HEAD_FORE); putpixel(0,2,HEAD_FORE); putpixel(2,0,HEAD_FORE);
 putpixel(3,3,HEAD_FORE); putpixel(0,3,HEAD_FORE); putpixel(3,0,HEAD_FORE);
 putpixel(4,4,HEAD_FORE); putpixel(0,4,HEAD_FORE); putpixel(4,0,HEAD_FORE);
 putpixel(5,5,HEAD_FORE); putpixel(0,5,HEAD_FORE); putpixel(5,0,HEAD_FORE);
 putpixel(6,6,HEAD_FORE); putpixel(0,6,HEAD_FORE); putpixel(6,0,HEAD_FORE);
 putpixel(7,7,HEAD_FORE); putpixel(0,7,HEAD_FORE); putpixel(7,0,HEAD_FORE);

 putpixel(1,1,HEAD_FORE); putpixel(1,1,HEAD_FORE);
 putpixel(1,2,HEAD_FORE); putpixel(2,1,HEAD_FORE);
 putpixel(1,3,HEAD_FORE); putpixel(3,1,HEAD_FORE);
 putpixel(1,4,HEAD_FORE); putpixel(4,1,HEAD_FORE);
 putpixel(1,5,HEAD_FORE); putpixel(5,1,HEAD_FORE);

 getimage(0,0,7,7, mouse_cursor);
 ClipMouse(0, 0, getmaxx()-7, getmaxy()-TITLE_BOX_Y-7);
}

void show_mouse(int x, int y)
{
 getimage(x, y, x+7, y+7, mouse_background);
 putimage(x, y, mouse_cursor, COPY_PUT);
}

void hide_mouse(int x, int y)
{
 putimage(x, y, mouse_background, COPY_PUT);
}
