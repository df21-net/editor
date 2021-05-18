#include "dfuse.h"
#include "dfuseext.h"

/* ************************************************************************** */
/* various beginning checks                                                   */
/* ************************************************************************** */

void chk_cmdline()
{
 /* Check number of arguments */
 if(_argc != 1)
   {
    printf("Usage is DFUSE\n");
    remove("dfuse.run");
    exit(ERR_CMDLINE);
   }
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
   ReadIniString(section, "EDIT",      "edit %s" ,    call_editor,    100, DFUSE_INI);
   ReadIniString(section, "PAGE",      "edit %s" ,    call_pager,     100, DFUSE_INI);
   ReadIniString(section, "VOCPLAYER", "" ,           call_vocplayer, 100, DFUSE_INI);
   ReadIniString(section, "VOC2WAV",   "" ,           call_voc2wav,   100, DFUSE_INI);

   strcpy(section, "DFUSE-SECURITY");
   EDIT_ALLOWED     = ReadIniInt(section, "EDIT_ALLOWED",      1, DFUSE_INI);
   EDIT_LEV_ALLOWED = ReadIniInt(section, "EDIT_LEV_ALLOWED",  0, DFUSE_INI);

   strcpy(section, "DFUSE-TESTMETHOD");
   TEST_AS_GOB      = ReadIniInt(section, "TEST_AS_GOB",       1, DFUSE_INI);

   strcpy(section, "DFUSE-COLORS");
   MENU_FORE        = ReadIniInt(section,   "MENU_FORE",        15, DFUSE_INI);
   MENU_BACK        = ReadIniInt(section,   "MENU_BACK",        14, DFUSE_INI);
   MENU_BORDER      = ReadIniInt(section,   "MENU_BORDER",       9, DFUSE_INI);
   MENU_DIR         = ReadIniInt(section,   "MENU_DIR",         10, DFUSE_INI);
   PICK_FORE        = ReadIniInt(section,   "PICK_FORE",        15, DFUSE_INI);
   PICK_BACK        = ReadIniInt(section,   "PICK_BACK",         0, DFUSE_INI);
   PICK_BORDER      = ReadIniInt(section,   "PICK_BORDER",      15, DFUSE_INI);
   PICK_HILITE      = ReadIniInt(section,   "PICK_HILITE",      12, DFUSE_INI);
   EDIT_FORE        = ReadIniInt(section,   "EDIT_FORE",        15, DFUSE_INI);
   EDIT_BACK        = ReadIniInt(section,   "EDIT_BACK",         1, DFUSE_INI);
   EDIT_CURSOR      = ReadIniInt(section,   "EDIT_CURSOR",       9, DFUSE_INI);
   COLOR_ERASER     = MENU_BACK;

   ReadIniString("DFUSE-BGI", ".BGI", "", BGIdriver, 10, DFUSE_INI);
   BGImode = ReadIniInt("DFUSE-BGI", "MODE", 30000, DFUSE_INI);

   /* [DEFAULT-BGI] handling */
   if((strcmp(BGIdriver,"")==0) || (BGImode == 30000))
    {
     ReadIniString("DEFAULT-BGI", ".BGI", "", BGIdriver, 10, DFUSE_INI);
     BGImode = ReadIniInt("DEFAULT-BGI", "MODE", 30000, DFUSE_INI);
     if((strcmp(BGIdriver,""))==0 || (BGImode == 30000))
      {
       printf("DFUSE can't find coherent values for .BGI and MODE !\n");
       printf("Please reconfigure the [DEFAULT-BGI] or [DFUSE-BGI] sections of DFUSE.INI .\n\n");
       remove("dfuse.run");
       exit(ERR_GRAPHIC);
      }
    }
  }
 else
  {
   printf("DFUSE can't find "DFUSE_INI"\n");
   printf("Please restore and reconfigure it.\n\n");
   remove("dfuse.run");
   exit(ERR_INIFILE);
  }
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
       printf("DFUSE can't find %s on the CD.\n", problem_in);
       printf("If you have inserted the wrong CD, replace it and restart DFUSE.\n");
       printf("Else you may have a software / hardware / CD support problem.\n");
       printf("Aborting...\n");
       remove("dfuse.run");
       exit(ERR_NOTFOUND);
      }
    }
   else
    {
     printf("DFUSE can't find drive.cd in your install dir.\n");
     printf("It needs it to find your CD files.\n");
     printf("Try to launch the game, as this will recreate it.\n");
     printf("Aborting...\n");
     remove("dfuse.run");
     exit(ERR_NOTFOUND);
    }
  }

#ifdef SHOWGOBS
 printf("Found [INSTALL DIR] at : %s\n", df_inst_dir);
 if(drive_cd[0] == '?')
   printf("Found drive.cd to be   : NOT NEEDED\n");
 else
   printf("Found drive.cd to be   : %s\n", drive_cd);
 printf("Found DARK.GOB      at : %s\n", dark_gob);
 printf("Found TEXTURES.GOB  at : %s\n", textures_gob);
 printf("Found SPRITES.GOB   at : %s\n", sprites_gob);
 printf("Found SOUNDS.GOB    at : %s\n", sounds_gob);
 getVK();
#endif
}

