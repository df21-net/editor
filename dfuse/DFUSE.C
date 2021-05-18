#include "dfuse.h"

char            golden_path[127];
char            golden_path_drive[5];

char            call_editor[101];
char            call_pager[101];
char            call_vocplayer[101];
char            call_voc2wav[101];

char            fns_drive[MAXDRIVE];
char            fns_dir[MAXDIR];
char            fns_fname[MAXFILE];
char            fns_ext[MAXEXT];
char            fns_ext2[MAXEXT];


char            df_inst_dir[81];
char            dark_gob[101];
char            textures_gob[101];
char            sprites_gob[101];
char            sounds_gob[101];

char            bm_data_dir[81] = "textures";
char            fme_data_dir[81] = "sprites";
char            wax_data_dir[81] = "sprites";
char            vo_data_dir[81] = "sounds";
char            pa_data_dir[81] = "dark";
char            pa_file[20]     = "dfuse.pal";
char            lv_data_dir[81] = "dark";
int             level_selected = 0;
char            level_name[9];
char            fname[80];
char            fname_lev[80];
char            fname_pal[80];
char            fname_inf[80];
char            fname_gol[80];
char            fname_o[80];
long            counter;

char            BGIdriver[10];
int             BGImode;
int             gdriver;
int             gmode;
int             errorcode              = grNoInitGraph;

char            tmpstr[80];
int             ccc                    =  0;
int             TEST_AS_GOB            ;
int             MENU_FORE              ;
int             MENU_BACK              ;
int             MENU_BORDER            ;
int             MENU_DIR               ;
int             COLOR_ERASER           ;

int             PICK_FORE              ;
int             PICK_BACK              ;
int             PICK_BORDER            ;
int             PICK_HILITE            ;

int             EDIT_FORE              ;
int             EDIT_BACK              ;
int             EDIT_CURSOR            ;

int             EDIT_ALLOWED           ;
int             EDIT_LEV_ALLOWED       ;

char            DACbuffer[768];

int             OUT_X, OUT_Y;


/* ************************************************************************** */
/* GRAPHICS & TEXT MODES - must stay in the kernel                            */
/* ************************************************************************** */

void gr_startup()
{
 char  tmp[127];

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
    printf("\n\n\n\nGraphic Error : %d \n%s\n",
                                    errorcode,
                                    grapherrormsg(errorcode));
    remove("dfuse.run");
    exit(ERR_GRAPHIC);
   }
 cleardevice();
}

void gr_shutdown()
{
 closegraph();
 restorecrtmode();
}

/* ************************************************************************** */
/* SHELL TO DOS - must stay in the kernel                                     */
/* ************************************************************************** */

void shell_to_DOS(void)
{
 gr_shutdown();
 clrscr();
 Beep(100,20);
 printf("\n\n\nType 'exit' to return to DFUSE.\n\n");
 system(getenv("COMSPEC"));
 gr_startup();
}

/* ************************************************************************** */
/* SINGLE GOB EXTRACTIONS  - must stay in the kernel                          */
/* ************************************************************************** */

/* the gob to pass is only "DARK" or "TEXTURES", ...                          */
/* do NOT include the ".gob" as this will also be the name of the dir !       */

int  extract_a_file(char *gob , char *name)
{
 char          gobname[127];
 char          filename[127];
 struct GOB_INDEX_ENTRY is;
 long          master_entries ;
 long          counter;
 int           f1,f2;
 char          *buf;

 /* get start address */
 if(strcmp(gob, "DARK") == 0)     strcpy(gobname, dark_gob);
 if(strcmp(gob, "TEXTURES") == 0) strcpy(gobname, textures_gob);
 if(strcmp(gob, "SPRITES") == 0)  strcpy(gobname, sprites_gob);
 if(strcmp(gob, "SOUNDS") == 0)   strcpy(gobname, sounds_gob);

 f1 = open(gobname , O_BINARY | O_RDONLY);
 master_entries = get_master_entries(f1);
 seek_master_index(f1);
 counter = 0;
 while(counter < master_entries)
  {
   read(f1 , &is , sizeof(is));
   if(strcmp(is.NAME, name) == 0) break;
   counter++;
  }
 if(counter < master_entries)  /* we did find it */
  {
   if((buf = (char *) farcalloc( (long)(BUF_SIZE) ,1) ) == NULL)
    {
     gr_shutdown();
     printf("Cannot allocate memory for extraction !\n");
     getVK();
     gr_startup();
     close(f1);
     return(-1);
    };

   strcpy(filename, gob);
   strcat(filename, "\\");
   strcat(filename, name);

   if(fexists(filename) == FALSE)
     f2 = open(filename , O_BINARY | O_CREAT | O_WRONLY, S_IWRITE);
   else
     f2 = open(filename , O_BINARY | O_TRUNC | O_WRONLY, S_IWRITE);

   lseek(f1, is.IX , SEEK_SET);

   while(is.LEN >= (long) BUF_SIZE)
    {
     read(f1  , buf , BUF_SIZE);
     write(f2 , buf , BUF_SIZE);
     is.LEN -= BUF_SIZE;
    }
    read(f1  ,  buf , is.LEN);
    write(f2 ,  buf , is.LEN);

   farfree(buf);
   close(f2);
   close(f1);
   return(0);
  }
 else
  {
   gr_shutdown();
   printf("[%s]\\%s not found !\n", gobname, name);
   getVK();
   gr_startup();
   close(f1);
   return(-1);
  }
}

int  extract_a_level(char *name)
{
 char filename[20];
 char gobname[20];

 strcpy(gobname, "DARK");

 strcpy(filename, name);
 strcat(filename, ".LEV");
 extract_a_file(gobname, filename);
 strcpy(filename, name);
 strcat(filename, ".O");
 extract_a_file(gobname, filename);
 strcpy(filename, name);
 strcat(filename, ".INF");
 extract_a_file(gobname, filename);
 strcpy(filename, name);
 strcat(filename, ".GOL");
 extract_a_file(gobname, filename);
 strcpy(filename, name);
 strcat(filename, ".PAL");
 extract_a_file(gobname, filename);
 strcpy(filename, name);
 strcat(filename, ".CMP");
 extract_a_file(gobname, filename);
 return(0);
}

/* ************************************************************************** */
/* TOP MENU                                                                   */
/* ************************************************************************** */

void draw_menu_box()
{
 setcolor(MENU_BORDER);
 rectangle((getmaxx()-TOP_X)/2,       (getmaxy()-TOP_Y)/2,
           (getmaxx()-TOP_X)/2+TOP_X, (getmaxy()-TOP_Y)/2+TOP_Y);
 setfillstyle(SOLID_FILL, MENU_BACK);
 floodfill((getmaxx()-TOP_X)/2+10,(getmaxy()-TOP_Y)/2+10, MENU_BORDER);
 moveto((getmaxx()-TOP_X)/2,       (getmaxy()-TOP_Y)/2 + 30);
 lineto((getmaxx()-TOP_X)/2+TOP_X, (getmaxy()-TOP_Y)/2 + 30);
}

void draw_menu_footer(void)
{
 outtextxy(OUT_X, OUT_Y + 173," [Z].  OS Shell");
 outtextxy(OUT_X, OUT_Y + 188,"[Esc]  Return to Main MENU");
}

void draw_menu_copyright(void)
{
 outtextxy(OUT_X, OUT_Y +  20,"  (c) Yves BORCKMANS 1995");
}
                             
void top_menu()
{
 char tmp[127];

 gr_startup();

 OUT_X = (getmaxx()-TOP_X)/2+48;
 OUT_Y = (getmaxy()-TOP_Y)/2;

 ccc = 0;
 write_top_menu();
 do
  {
   switch(ccc)
    {
     case  'f' :
     case  'F' : full_gob_menu();
                 cleardevice();
                 break;
     case  'g' :
     case  'G' : gob_menu();
                 cleardevice();
                 break;
     case  'l' :
     case  'L' : lvl_menu();
                 cleardevice();
                 break;
     case  't' :
     case  'T' : text_menu();
                 cleardevice();
                 break;
     case  'v' :
     case  'V' : view_menu();
                 cleardevice();
                 break;
     case  'x' :
     case  'X' : gr_shutdown();
                 clrscr();
                 Beep(100,20);
                 sprintf(tmp, "%-2.2s", df_inst_dir);
                 system(tmp);
                 sprintf(tmp, "cd %s", &(df_inst_dir[2]));
                 system(tmp);
                 system("dark");
                 gr_startup();
                 break;
     case  'z' :
     case  'Z' : shell_to_DOS();
                 break;
    };
    write_top_menu();
  } while((ccc=getVK()) != VK_ESC);
 gr_shutdown();
}

void write_top_menu()
{
 draw_menu_box();
 setcolor(MENU_FORE);
 outtextxy(OUT_X, OUT_Y +   8," DFUSE Main MENU "DFUSE_VERSION);
 draw_menu_copyright();
 outtextxy(OUT_X, OUT_Y +  50," [F].  Full   .GOB Extract");
 outtextxy(OUT_X, OUT_Y +  65," [G].  Single .GOB Extract");
 outtextxy(OUT_X, OUT_Y +  80," [L].  Levels  Menu");
 outtextxy(OUT_X, OUT_Y +  95," [T].  Special Text Files");
 outtextxy(OUT_X, OUT_Y + 110," [V].  Viewers Menu");
 outtextxy(OUT_X, OUT_Y + 140," [X].  Launch DF");
 outtextxy(OUT_X, OUT_Y + 173," [Z].  OS Shell");
 outtextxy(OUT_X, OUT_Y + 188,"[Esc]  Exit DFUSE");
}



/* ************************************************************************** */
/* MAIN                                                                       */
/* ************************************************************************** */

main()
{
int  frun;
char mess[] = "DFUSE is already RUNNING!";
char runname[] = "dfuse.run";

/* _OvrInitExt(0,0); */

if(fexists("dfuse.run") == TRUE)
   {
    printf("%s\n Please quit the shell.\n\n", mess);
    printf("[if you're getting this erroneously, delete the file DFUSE.RUN]\n\n");
    exit(ERR_RUNNING);
   };

frun = open(runname , O_BINARY | O_CREAT | O_RDWR, S_IWRITE);
write(frun, mess, strlen(mess));
close(frun);

strcpy(golden_path, _argv[0]);
fnsplit(golden_path, fns_drive, fns_dir, fns_fname, fns_ext);
strcpy(golden_path, fns_drive);
strcat(golden_path, fns_dir);
golden_path[strlen(golden_path)-1] = '\0';  /* remove trailing backslash */
strcpy(golden_path_drive, fns_drive);

chk_cmdline();
handle_ini();
handle_locations();
top_menu();

remove(runname);
return(ERR_NOERROR);
}
