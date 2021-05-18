/* ========================================================================== */
/* LEVIOO.C   : MAP I/O                                                       */
/*              * .O   read & write                                           */
/* ========================================================================== */
#include "levmap.h"
#include "levext.h"
#include <alloc.h>
#include <time.h>


/* ************************************************************************** */
/* O FUNCTIONS                                                                */
/* ************************************************************************** */

void handle_o_file()
{
 char keyword[255];

 fo = fopen(fname_o , "rt");

 if(fexists(fname_obj) == FALSE)
  fobj = open(fname_obj , O_BINARY | O_CREAT | O_RDWR, S_IWRITE);
 else
  fobj = open(fname_obj , O_BINARY | O_TRUNC | O_RDWR, S_IWRITE);

 if(fobj == -1)
  {
   gr_shutdown();
   printf("Problem opening temporary file %s \n", fname_obj);
   getVK();
   exit(0);
  }

 if(fexists(fname_pods) == FALSE)
  fpods = open(fname_pods , O_BINARY | O_CREAT | O_RDWR, S_IWRITE);
 else
  fpods = open(fname_pods , O_BINARY | O_TRUNC | O_RDWR, S_IWRITE);

 if(fpods == -1)
  {
   gr_shutdown();
   printf("Problem opening temporary file %s \n", fname_pods);
   getVK();
   exit(0);
  }

 if(fexists(fname_sprs) == FALSE)
  fsprs = open(fname_sprs , O_BINARY | O_CREAT | O_RDWR, S_IWRITE);
 else
  fsprs = open(fname_sprs , O_BINARY | O_TRUNC | O_RDWR, S_IWRITE);

 if(fsprs == -1)
  {
   gr_shutdown();
   printf("Problem opening temporary file %s \n", fname_sprs);
   getVK();
   exit(0);
  }

 if(fexists(fname_fmes) == FALSE)
  ffmes = open(fname_fmes , O_BINARY | O_CREAT | O_RDWR, S_IWRITE);
 else
  ffmes = open(fname_fmes , O_BINARY | O_TRUNC | O_RDWR, S_IWRITE);

 if(ffmes == -1)
  {
   gr_shutdown();
   printf("Problem opening temporary file %s \n", fname_fmes);
   getVK();
   exit(0);
  }

 if(fexists(fname_sounds) == FALSE)
  fsounds = open(fname_sounds , O_BINARY | O_CREAT | O_RDWR, S_IWRITE);
 else
  fsounds = open(fname_sounds , O_BINARY | O_TRUNC | O_RDWR, S_IWRITE);

 if(fsounds == -1)
  {
   gr_shutdown();
   printf("Problem opening temporary file %s \n", fname_sounds);
   getVK();
   exit(0);
  }

 while(!feof(fo))
 {
  strcpy(fbuffer, "");
  fgets(fbuffer, 255, fo);
  if(fbuffer[0] != '#')                 /* skip full line comment */
   {
    if(fbuffer[0] != '\n')              /* skip empty line        */
     {
      strcpy(keyword, "");
      sscanf(fbuffer, "%s", keyword);
      if(strcmp(keyword, "O")==0)            handle_o();
      else
      if(strcmp(keyword, "LEVELNAME")==0)    handle_lnao();
      else
      if(strcmp(keyword, "PODS")==0)         handle_pods();
      else
      if(strcmp(keyword, "POD:")==0)         handle_pod();
      else
      if(strcmp(keyword, "SPRS")==0)         handle_sprs();
      else
      if(strcmp(keyword, "SPR:")==0)         handle_spr();
      else
      if(strcmp(keyword, "FMES")==0)         handle_fmes();
      else
      if(strcmp(keyword, "FME:")==0)         handle_fme();
      else
      if(strcmp(keyword, "SOUNDS")==0)       handle_sounds();
      else
      if(strcmp(keyword, "SOUND:")==0)       handle_sound();
      else
      if(strcmp(keyword, "OBJECTS")==0)      handle_objects();
      else
      if(strcmp(keyword, "CLASS:")==0)       handle_class();
      else
      if(strcmp(keyword, "SEQ")==0)          handle_seq();
      else
      if(strcmp(keyword, "SEQEND")==0)       handle_seqend();
      else
      if(seqfound==1)                        handle_seqitem();
     }
   }
 }
 fclose(fo);

 /* write last object in obj file */
 swpOBJ.seqs = seq_ix;
 if(obj_ix != 0) write(fobj, &swpOBJ, sizeof(swpOBJ));

 close(fpods);
 close(ffmes);
 close(fsprs);
 close(fsounds);
 remove(fname_pods);
 remove(fname_fmes);
 remove(fname_sprs);
 remove(fname_sounds);
}

/* -------------------------------------------------------------------------- */

void handle_o()
{
 sscanf(fbuffer, "%*s %s", MAP_VERSION_O);
 setcolor(HEAD_FORE);
 outtextxy(0,56,"Reading O file.");
}

void handle_lnao()
{
 sscanf(fbuffer, "%*s %s", MAP_NAME_O);
}

void handle_pods()
{
 sscanf(fbuffer, "%*s %d", &pod_max);
 pod_max--;
}

void handle_pod()
{
 char tmp[16];

 memset(tmp, '\0', 16);
 sscanf(fbuffer, "%*s %s", tmp);
 write(fpods, tmp, 16);
}

void handle_sprs()
{
 sscanf(fbuffer, "%*s %d", &spr_max);
 spr_max--;
}

void handle_spr()
{
 char tmp[16];

 memset(tmp, '\0', 16);
 sscanf(fbuffer, "%*s %s", tmp);
 write(fsprs, tmp, 16);
}

void handle_fmes()
{
 sscanf(fbuffer, "%*s %d", &fme_max);
 fme_max--;
}

void handle_fme()
{
 char tmp[16];

 memset(tmp, '\0', 16);
 sscanf(fbuffer, "%*s %s", tmp);
 write(ffmes, tmp, 16);
}

void handle_sounds()
{
 sscanf(fbuffer, "%*s %d", &sound_max);
 sound_max--;
}

void handle_sound()
{
 char tmp[16];

 memset(tmp, '\0', 16);
 sscanf(fbuffer, "%*s %s", tmp);
 write(fsounds, tmp, 16);
}

void handle_objects()
{
 long             obj;

 sscanf(fbuffer, "%*s %ld", &obj);
 if((MAP_OBJ = (struct tagMAP_OBJ huge *) farcalloc(sizeof(struct tagMAP_OBJ), obj+ (long)SUP_OBJECTS)) == NULL)
  {
   gr_shutdown();
   printf("Cannot allocate %ld objects (of %ld bytes). Aborting...\n", obj, sizeof(struct tagMAP_OBJ));
   printf("Press Any Key To Continue.\n");
   getVK();
   exit(ERR_DYNALLOC);
  }
  obj_alloc = (int)obj + SUP_OBJECTS;
  memset(&swpOBJ, '\0', sizeof(swpOBJ));
}

void handle_class()
{
 obj_ix++;
 if(obj_ix != 0)
  {
   swpOBJ.seqs = seq_ix;
   write(fobj, &swpOBJ, sizeof(swpOBJ));
  }
 memset(&swpOBJ, '\0', sizeof(swpOBJ));
 seqfound = 0;
 logfound = 0;
 seq_ix   = 0;

sscanf(fbuffer,
  "%*s %s %*s %d %*s %f %*s %f %*s %f %*s %f %*s %f %*s %f %*s %d",
  &(swpOBJ.classname),  &(swpOBJ.data),
  &(MAP_OBJ[obj_ix].x), &(MAP_OBJ[obj_ix].y),   &(MAP_OBJ[obj_ix].z),
  &(swpOBJ.pch),        &(MAP_OBJ[obj_ix].yaw), &(swpOBJ.rol),
  &(MAP_OBJ[obj_ix].diff));

  MAP_OBJ[obj_ix].del     = 0;
  MAP_OBJ[obj_ix].mark    = 0;
  MAP_OBJ[obj_ix].type    = 0;
  MAP_OBJ[obj_ix].special = 0;
  MAP_OBJ[obj_ix].sec     = -1;

  if(strcmp(swpOBJ.classname, "SPIRIT") == 0)
   {
    strcpy(swpOBJ.dataname, "SPIRIT");
    MAP_OBJ[obj_ix].type = OBT_SPIRIT;
   }

  if(strcmp(swpOBJ.classname, "SAFE"  ) == 0)
   {
    strcpy(swpOBJ.dataname, "SAFE");
    MAP_OBJ[obj_ix].type = OBT_SAFE;
   }

  if(strcmp(swpOBJ.classname, "3D"    ) == 0)
   {
    get_pod_name(swpOBJ.data, swpOBJ.dataname);
    MAP_OBJ[obj_ix].type = OBT_3D;
   }

  if(strcmp(swpOBJ.classname, "FRAME" ) == 0)
   {
    get_fme_name(swpOBJ.data, swpOBJ.dataname);
    MAP_OBJ[obj_ix].type = OBT_FRAME;
   }

  if(strcmp(swpOBJ.classname, "SPRITE") == 0)
   {
    get_spr_name(swpOBJ.data, swpOBJ.dataname);
    MAP_OBJ[obj_ix].type = OBT_SPRITE;
   }

  if(strcmp(swpOBJ.classname, "SOUND" ) == 0)
   {
    get_snd_name(swpOBJ.data, swpOBJ.dataname);
    MAP_OBJ[obj_ix].type = OBT_SOUND;
   }

  MAP_OBJ[obj_ix].col = ReadIniInt(swpOBJ.dataname, "COLOR",
                                    OBJ_NOTHILI , "dfudata\\ob_cols.dfu");
  

  setcolor(LINE_AT_ALT);
  moveto(obj_ix, 72);
  lineto(obj_ix, 80);
}

void handle_seq(void)
{
 seqfound = 1;
}

void handle_seqitem(void)
{
 char key1[20];
 char key2[20];
 char key3[20];

 strcpy(swpOBJ.seq[seq_ix], fbuffer);
 if(logfound == 0)
  {
   sscanf(fbuffer, "%s %s" , key1, key2);
   if( (strcmp(key1, "LOGIC:") == 0) || (strcmp(key1, "TYPE:") == 0))
    {
     if(strcmp(key2, "GENERATOR") == 0)
      {
       sscanf(fbuffer, "%s %s %s" , key1, key2, key3);
       strcpy(swpOBJ.logic, key2);
       strcat(swpOBJ.logic, " ");
       strcat(swpOBJ.logic, key3);
       MAP_OBJ[obj_ix].special = OBS_GENERATOR;
      }
     else
      {
       MAP_OBJ[obj_ix].special = !OBS_GENERATOR;
       if(strcmp(key2, "ITEM") == 0)
        {
         sscanf(fbuffer, "%s %s %s" , key1, key2, key3);
         strcat(swpOBJ.logic, key3); /* removed ITEM (this is just MY logic!) */
        }
       else
        {
         strcpy(swpOBJ.logic, key2);
        }
      }
     logfound = 1;
    }
  }
 seq_ix++;
}

void handle_seqend(void)
{
 seqfound = 0;
}

void write_o(void)
{
 int    i,j,o;
 char   tmp[127];
 time_t t;
 int    skip_blanks;
 char   *obtable;

 time(&t);

 fprintf(fo, "O %s\n", MAP_VERSION_O);
 fprintf(fo, "/*\n");
 fprintf(fo, "# GENERATED BY LEVMAP "LEVMAP_VERSION" \n");
 fprintf(fo, "# (c) Yves BORCKMANS 1995\n");
 fprintf(fo, "# \n");
 fprintf(fo, "# GENTIME %s", ctime(&t));
 fprintf(fo, "# \n");
 fprintf(fo, "# AUTHOR  %s\n", MAP_AUTHOR);
 fprintf(fo, "# \n");
 fprintf(fo, "# %s\n",MAP_COMNT1);
 fprintf(fo, "# %s\n",MAP_COMNT2);
 fprintf(fo, "# \n");
 fprintf(fo, "# GENERAL LEVEL INFORMATION\n");
 fprintf(fo, "# =========================\n");
 fprintf(fo, "*/\n");
 fprintf(fo, "LEVELNAME %s\n", MAP_NAME_O);
 fprintf(fo, "/*\n");
 fprintf(fo, "# 3D OBJECTS\n");
 fprintf(fo, "# ==========\n");
 fprintf(fo, "*/ \n");


#define OBJ_TABLE_SIZE 500
 if((obtable = (char *) farcalloc( (long) ((long)(17)*(long)OBJ_TABLE_SIZE) ,1)) == NULL)
  {
   /* error checking */
  };

 memset(obtable, '\0', 17 * OBJ_TABLE_SIZE);

 textattr(7);
 gotoxy(1,14);
 cprintf("Creating PFSS  :"); /* nota : Pods Frames Sprites Sounds */
 textattr(15);

 for(i=0; i<=obj_max;i++)
  if(MAP_OBJ[i].del == 0)
  {
   get_object_info(i);
   if((strcmp(swpOBJ.classname,"SPIRIT") == 0) ||
      (strcmp(swpOBJ.classname,"SAFE") == 0))
    {
     swpOBJ.data   = 0;
     set_object_info(i);
    }
   gotoxy(18,14);
   cprintf("%4.4d", i);
  }

 for(i=0; i<=obj_max;i++)
  if(MAP_OBJ[i].del == 0)
  {
   get_object_info(i);
   if(strcmp(swpOBJ.classname,"3D") == 0)
    {
     swpOBJ.data   = search_add_table(obtable, swpOBJ.dataname);
     set_object_info(i);
    }
   gotoxy(18,14);
   cprintf("%4.4d", i);
  }
 pod_max = 0;
 for(;;)
  {
    if(strcmp(&(obtable[pod_max*17]),"") == 0) break;
    pod_max++;
  }
 pod_max--;
 fprintf(fo, "PODS %d\n", pod_max + 1);
 for(i=0;i<=pod_max;i++)
  {
   fprintf(fo, " POD: %-12.12s # %2.2d\n", &(obtable[i*17]), i);
  }
 fprintf(fo, "\n");
 memset(obtable, '\0', 17 * OBJ_TABLE_SIZE);

 fprintf(fo, "/*\n");
 fprintf(fo, "# SPRITES\n");
 fprintf(fo, "# =======\n");
 fprintf(fo, "*/ \n");

 for(i=0; i<=obj_max;i++)
  if(MAP_OBJ[i].del == 0)
  {
   get_object_info(i);
   if(strcmp(swpOBJ.classname,"SPRITE") == 0)
    {
     swpOBJ.data   = search_add_table(obtable, swpOBJ.dataname);
     set_object_info(i);
    }
   gotoxy(18,14);
   cprintf("%4.4d", i);
  }
 spr_max = 0;
 for(;;)
  {
    if(strcmp(&(obtable[spr_max*17]),"") == 0) break;
    spr_max++;
  }
 spr_max--;
 fprintf(fo, "SPRS %d\n", spr_max + 1);
 for(i=0;i<=spr_max;i++)
  {
   fprintf(fo, " SPR: %-12.12s # %2.2d\n", &(obtable[i*17]), i);
  }
 fprintf(fo, "\n");
 memset(obtable, '\0', 17 * OBJ_TABLE_SIZE);

 fprintf(fo, "/*\n");
 fprintf(fo, "# FRAMES\n");
 fprintf(fo, "# ======\n");
 fprintf(fo, "*/ \n");

 for(i=0; i<=obj_max;i++)
  if(MAP_OBJ[i].del == 0)
  {
   get_object_info(i);
   if(strcmp(swpOBJ.classname,"FRAME") == 0)
    {
     swpOBJ.data   = search_add_table(obtable, swpOBJ.dataname);
     set_object_info(i);
    }
   gotoxy(18,14);
   cprintf("%4.4d", i);
  }
 fme_max = 0;
 for(;;)
  {
    if(strcmp(&(obtable[fme_max*17]),"") == 0) break;
    fme_max++;
  }
 fme_max--;
 fprintf(fo, "FMES %d\n", fme_max + 1);
 for(i=0;i<=fme_max;i++)
  {
   fprintf(fo, " FME: %-12.12s # %2.2d\n", &(obtable[i*17]), i);
  }
 fprintf(fo, "\n");
 memset(obtable, '\0', 17 * OBJ_TABLE_SIZE);

 fprintf(fo, "/*\n");
 fprintf(fo, "# SOUNDS\n");
 fprintf(fo, "# ======\n");
 fprintf(fo, "*/ \n");

 for(i=0; i<=obj_max;i++)
  if(MAP_OBJ[i].del == 0)
  {
   get_object_info(i);
   if(strcmp(swpOBJ.classname,"SOUND") == 0)
    {
     swpOBJ.data   = search_add_table(obtable, swpOBJ.dataname);
     set_object_info(i);
    }
   gotoxy(18,14);
   cprintf("%4.4d", i);
  }
 sound_max = 0;
 for(;;)
  {
    if(strcmp(&(obtable[sound_max*17]),"") == 0) break;
    sound_max++;
  }
 sound_max--;
 fprintf(fo, "SOUNDS %d\n", sound_max + 1);
 for(i=0;i<=sound_max;i++)
  {
   fprintf(fo, " SOUND: %-12.12s # %2.2d\n", &(obtable[i*17]), i);
  }
 fprintf(fo, "\n");
 farfree(obtable);


 fprintf(fo, "/*\n");
 fprintf(fo, "# OBJECT DEFINITIONS\n");
 fprintf(fo, "# ==================\n");
 fprintf(fo, "*/\n");

 textattr(7);
 gotoxy(1,16);
 cprintf("Writing Object : ");
 textattr(15);

 o = 0;
 j = 0;
 for(i=0;i<=obj_max;i++)
  if(MAP_OBJ[i].del == 0) j++;

 fprintf(fo, "OBJECTS %d\n", j);
 fprintf(fo, "\n");
 for(i=0;i<=obj_max;i++)
  if(MAP_OBJ[i].del == 0)
  {
   gotoxy(18,16);
   cprintf("%4.4d", i);
   get_object_info(i);
   fprintf(fo, "/* %3d : %-13.13s */\n", o, swpOBJ.dataname);
   fprintf(fo,
   "CLASS: %-12.12s DATA: %2d X: %6.2f Y: %6.2f Z: %6.2f PCH: %6.2f YAW: %6.2f ROL: %6.2f DIFF: %d\n",
   swpOBJ.classname, swpOBJ.data,
   MAP_OBJ[i].x,   MAP_OBJ[i].y,   MAP_OBJ[i].z,
   swpOBJ.pch,     MAP_OBJ[i].yaw, swpOBJ.rol,   MAP_OBJ[i].diff);

   if(swpOBJ.seqs != 0)
    {
     skip_blanks = 0;
     while(swpOBJ.seq[0][skip_blanks] == ' ') skip_blanks++;
     fprintf(fo, " SEQ\n");
     for(j = 0; j < swpOBJ.seqs; j++)
      {
       fprintf(fo, "  %s", &(swpOBJ.seq[j][skip_blanks]));
      }
     fprintf(fo, " SEQEND\n");
    }
   o++;
   fprintf(fo, "\n");
  }
}
