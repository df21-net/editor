/* ========================================================================== */
/* LEVIOLEV.C : MAP I/O                                                       */
/*              * Level save                                                  */
/*              * .LEV read & write                                           */
/* ========================================================================== */
#include "levmap.h"
#include "levext.h"
#include <alloc.h>
#include <time.h>

/* ************************************************************************** */
/* LEVEL SAVE                                                                 */
/* ************************************************************************** */
void save_level(void)
{
 char tmp[127];

 if(BACKUP_DONE == 0)
  {
   sprintf(tmp, "copy %s backups\\backup.lev > NUL", fname_lev);
   system(tmp);
   sprintf(tmp, "copy %s backups\\backup.o > NUL", fname_o);
   system(tmp);
   sprintf(tmp, "copy %s backups\\backup.gol > NUL", fname_gol);
   system(tmp);
   sprintf(tmp, "copy %s backups\\backup.inf > NUL", fname_inf);
   system(tmp);
   BACKUP_DONE = 1;
  }
 flev = fopen(fname_lev , "wt");
 write_lev();
 fclose(flev);
 fo = fopen(fname_o , "wt");
 write_o();
 fclose(fo);
 MODIFIED = 0;
}

/* ************************************************************************** */
/* LEV FUNCTIONS                                                              */
/* ************************************************************************** */

void handle_lev_file()
{
 char keyword[255];
 char keyword2[255];

 flev = fopen(fname_lev , "rt");

 if(fexists(fname_tex) == FALSE)
  ftex = open(fname_tex , O_BINARY | O_CREAT | O_RDWR, S_IWRITE);
 else
  ftex = open(fname_tex , O_BINARY | O_TRUNC | O_RDWR, S_IWRITE);

 if(ftex == -1)
  {
   gr_shutdown();
   printf("Problem opening temporary file %s \n", fname_tex);
   getVK();
   exit(0);
  }

 if(fexists(fname_sec) == FALSE)
  fsec = open(fname_sec , O_BINARY | O_CREAT | O_RDWR, S_IWRITE);
 else
  fsec = open(fname_sec , O_BINARY | O_TRUNC | O_RDWR, S_IWRITE);

 if(fsec == -1)
  {
   gr_shutdown();
   printf("Problem opening temporary file %s \n", fname_sec);
   getVK();
   exit(0);
  }

 if(fexists(fname_wal) == FALSE)
  fwal = open(fname_wal , O_BINARY | O_CREAT | O_RDWR, S_IWRITE);
 else
  fwal = open(fname_wal , O_BINARY | O_TRUNC | O_RDWR, S_IWRITE);

 if(fwal == -1)
  {
   gr_shutdown();
   printf("Problem opening temporary file %s \n", fname_wal);
   getVK();
   exit(0);
  }

 while(!feof(flev))
 {
  strcpy(fbuffer, "");
  fgets(fbuffer, 255, flev);
  if(fbuffer[0] != '#')                 /* skip full line comment */
   {
    if(fbuffer[0] != '\n')              /* skip empty line        */
     {
      strcpy(keyword, "");
      sscanf(fbuffer, "%s", keyword);
      if(strcmp(keyword, "LEV")==0)          handle_lev();

      if(strcmp(keyword, "LEVELNAME")==0)    handle_lna();
      if(strcmp(keyword, "PALETTE")==0)      handle_pfl();
      if(strcmp(keyword, "MUSIC")==0)        handle_mfl();
      if(strcmp(keyword, "PARALLAX")==0)     handle_lnf();

      if(strcmp(keyword, "TEXTURES")==0)     handle_tex();
      if(strcmp(keyword, "TEXTURE:")==0)     handle_tna();

      if(strcmp(keyword, "NUMSECTORS")==0)   handle_sno();

      if(strcmp(keyword, "SECTOR")==0)       handle_sec();
      if(strcmp(keyword, "NAME")==0)         handle_sna();
      if(strcmp(keyword, "AMBIENT")==0)      handle_sam();
      if(strcmp(keyword, "FLOOR")==0)
       {
        sscanf(fbuffer, "%*s %s", keyword2);
        if(strcmp(keyword2, "TEXTURE")==0)    handle_sft();
        if(strcmp(keyword2, "ALTITUDE")==0)   handle_sfa();
       };
      if(strcmp(keyword, "CEILING")==0)
       {
        sscanf(fbuffer, "%*s %s", keyword2);
        if(strcmp(keyword2, "TEXTURE")==0)    handle_sct();
        if(strcmp(keyword2, "ALTITUDE")==0)   handle_sca();
       };
      if(strcmp(keyword, "SECOND")==0)        handle_2da();
      if(strcmp(keyword, "FLAGS")==0)         handle_snf();
      if(strcmp(keyword, "LAYER")==0)         handle_sla();

      if(strcmp(keyword, "VERTICES")==0)      handle_vno();
      if(strcmp(keyword, "X:")==0)            handle_vrt();

      if(strcmp(keyword, "WALLS")==0)         handle_wno();
      if(strcmp(keyword, "WALL")==0)          handle_wal();
     }
   }
 }
 fclose(flev);
 /* write last sector in sec file */
 if(sector_ix != 0) write(fsec, &swpSEC, sizeof(swpSEC));
 close(ftex);
 remove(fname_tex);
}
/* -------------------------------------------------------------------------- */

void handle_lev()
{
 sscanf(fbuffer, "%*s %s", MAP_VERSION);
 setcolor(HEAD_FORE);
 outtextxy(0,16,"Reading LEV file.");
}

void handle_lna()
{
 sscanf(fbuffer, "%*s %s", MAP_NAME);
}

void handle_pfl()
{
 sscanf(fbuffer, "%*s %s", PAL_NAME);
}

void handle_mfl()
{
 sscanf(fbuffer, "%*s %s", MUS_NAME);
}

void handle_lnf()
{
 sscanf(fbuffer, "%*s %f %f", &PARALLAX1, &PARALLAX2);
}

void handle_tex()
{
 sscanf(fbuffer, "%*s %d", &texture_max);
 texture_max--;
}

void handle_tna()
{
 char tmp[16];

 memset(tmp, '\0', 16);
 sscanf(fbuffer, "%*s %s", tmp);
 write(ftex, tmp, 16);
}

void handle_sno()
{
 long sno;

 sscanf(fbuffer, "%*s %ld", &sno);
 if((MAP_SEC = (MAP_SECtype huge *) farcalloc(sizeof(MAP_SECtype), sno + (long)SUP_SECTORS)) == NULL)
  {
   gr_shutdown();
   printf("Cannot allocate %ld sectors (of %ld bytes). Aborting...\n", sno, (long)sizeof(MAP_SECtype));
   printf("Press Any Key To Continue.\n");
   getVK();
   exit(ERR_DYNALLOC);
  }

 sector_alloc = (int)sno + SUP_SECTORS;

 if((MAP_VRT = (MAP_VRTtype huge *) farcalloc(sizeof(MAP_VRTtype), MAX_VERTICES)) == NULL)
  {
   gr_shutdown();
   printf("Cannot allocate %d vertices (of %ld bytes). Aborting...\n", MAX_VERTICES, (long)sizeof(MAP_VRTtype));
   printf("Press Any Key To Continue.\n");
   getVK();
   exit(ERR_DYNALLOC);
  }
 vertex_alloc = MAX_VERTICES;

 if((MAP_WAL = (MAP_WALtype huge *) farcalloc(sizeof(MAP_WALtype), MAX_WALLS)) == NULL)
  {
   gr_shutdown();
   printf("Cannot allocate %d walls (of %ld bytes). Aborting...\n", MAX_WALLS, (long)sizeof(MAP_WALtype));
   printf("Press Any Key To Continue.\n");
   getVK();
   exit(ERR_DYNALLOC);
  }
  wall_alloc = MAX_WALLS;

  vertex_ix  = 0;
  wall_ix    = 0;
}

void handle_sec()
{
 sector_ix++;
 MAP_SEC[sector_ix].del    = 0;
 MAP_SEC[sector_ix].mark   = 0;
 MAP_SEC[sector_ix].vrt0   = vertex_ix;
 MAP_SEC[sector_ix].wal0   = wall_ix;
 MAP_SEC[sector_ix].secret = 0;
 MAP_SEC[sector_ix].elev   = 0;
 MAP_SEC[sector_ix].trig   = 0;

 if(sector_ix != 0) write(fsec, &swpSEC, sizeof(swpSEC));
 memset(&swpSEC, '\0', sizeof(swpSEC));

 setcolor(LINE_AT_ALT);
 moveto(sector_ix, 32);
 lineto(sector_ix, 40);

}

void handle_sna()
{
 sscanf(fbuffer, "%*s %s", swpSEC.name);
}

void handle_sam()
{
 sscanf(fbuffer, "%*s %d", &(swpSEC.ambient));
}

void handle_sft()
{
 sscanf(fbuffer, "%*s %*s %d %f %f %d", &(swpSEC.floor_tx),&(swpSEC.floor_tx_f1),&(swpSEC.floor_tx_f2),&(swpSEC.floor_tx_i) );
 get_texture_name(swpSEC.floor_tx, swpSEC.floor_tx_name);
}

void handle_sfa()
{
 sscanf(fbuffer, "%*s%*s%f", &(MAP_SEC[sector_ix].floor_alt));
}

void handle_sct()
{
 sscanf(fbuffer, "%*s %*s %d %f %f %d", &(swpSEC.ceili_tx),&(swpSEC.ceili_tx_f1),&(swpSEC.ceili_tx_f2),&(swpSEC.ceili_tx_i) );
 get_texture_name(swpSEC.ceili_tx, swpSEC.ceili_tx_name);
}

void handle_sca()
{
 sscanf(fbuffer, "%*s%*s%f", &(MAP_SEC[sector_ix].ceili_alt));
}

void handle_2da()
{
 sscanf(fbuffer, "%*s %*s %f", &(swpSEC.second_alt));
}

void handle_snf()
{
 sscanf(fbuffer, "%*s %lu %u %u", &(swpSEC.flag1),&(swpSEC.flag2),&(swpSEC.flag3));

 if(swpSEC.flag1 &      2) MAP_SEC[sector_ix].elev = 1;
 if(swpSEC.flag1 &     64) MAP_SEC[sector_ix].elev = 1;
 if(swpSEC.flag1 & 524288) MAP_SEC[sector_ix].secret = 1;
}

void handle_sla()
{
 sscanf(fbuffer, "%*s %d", &(MAP_SEC[sector_ix].layer));
 if(MAP_SEC[sector_ix].layer > maxlayer)
   maxlayer = MAP_SEC[sector_ix].layer;
 if(MAP_SEC[sector_ix].layer < minlayer)
   minlayer = MAP_SEC[sector_ix].layer;

 sscanf(fbuffer, "%*s %d", &(swpSEC.layer));
}

void handle_vno()
{
 sscanf(fbuffer, "%*s %d", &(MAP_SEC[sector_ix].vno));
}

void handle_vrt()
{
 float         x,z;

 sscanf(fbuffer, "%*s %f %*s %f", &x, &z);
 MAP_VRT[vertex_ix].mark  = 0;
 MAP_VRT[vertex_ix].x     = x;
 MAP_VRT[vertex_ix].z     = z;
 MAP_VRT[vertex_ix].sec   = sector_ix;
 vertex_ix++;

 if(x > maxx) maxx = x;
 if(x < minx) minx = x;
 if(z > maxz) maxz = z;
 if(z < minz) minz = z;
}

void handle_wno()
{
 sscanf(fbuffer, "%*s %d", &(MAP_SEC[sector_ix].wno));
}

void handle_wal()
{
 memset(&swpWAL, '\0', sizeof(swpWAL));

 sscanf(fbuffer,
"%*s %*s %d %*s %d\
 %*s %d %f %f %d\
 %*s %d %f %f %d\
 %*s %d %f %f %d\
 %*s %d %f %f\
 %*s %d\
 %*s %d\
 %*s %d\
 %*s %u %u %u\
 %*s %u",
  &(MAP_WAL[wall_ix].left_vx), &(MAP_WAL[wall_ix].right_vx),
  &(swpWAL.mid_tx), &(swpWAL.mid_tx_f1), &(swpWAL.mid_tx_f2), &(swpWAL.mid_tx_i),
  &(swpWAL.top_tx), &(swpWAL.top_tx_f1), &(swpWAL.top_tx_f2), &(swpWAL.top_tx_i),
  &(swpWAL.bot_tx), &(swpWAL.bot_tx_f1), &(swpWAL.bot_tx_f2), &(swpWAL.bot_tx_i),
  &(swpWAL.sign), &(swpWAL.sign_f1), &(swpWAL.sign_f2),
  &(MAP_WAL[wall_ix].adjoin),
  &(MAP_WAL[wall_ix].mirror),
  &(MAP_WAL[wall_ix].walk  ),
  &(swpWAL.flag1), &(swpWAL.flag2), &(swpWAL.flag3),
  &(swpWAL.light)
 );

 /* zero two ugly uninitialized fields in original levels */
 if(swpWAL.sign == -1)
  {
   swpWAL.sign_f1 = 0.0;
   swpWAL.sign_f2 = 0.0;
  }

 get_texture_name(swpWAL.mid_tx, swpWAL.mid_tx_name);
 get_texture_name(swpWAL.top_tx, swpWAL.top_tx_name);
 get_texture_name(swpWAL.bot_tx, swpWAL.bot_tx_name);
 if(swpWAL.sign != -1)
  get_texture_name(swpWAL.sign,   swpWAL.sgn_tx_name);
 else
  strcpy(swpWAL.sgn_tx_name, "");

 write(fwal, &swpWAL, sizeof(swpWAL));

 MAP_WAL[wall_ix].mark      = 0;
 MAP_WAL[wall_ix].sec       = sector_ix;
 wall_ix++;
}

int search_add_table(char *table, char *txname)
{
 int found  = 0;
 int retval = 0;

 for(;;)
  {
    if(strcmp(&(table[retval*17]),"") == 0)
      break;
    if(strcmp(&(table[retval*17]),txname) == 0)
     {
      found = 1;
      break;
     }
    retval++;
  }

 if(found == 0) strcpy(&(table[retval*17]),txname);
 return(retval);
}

void write_lev(void)
{
 int    i,j,a;
 char   tmp[127];
 time_t t;
 int    deleted_sectors;
 int    correct_adjoin;
 int    correct_walk;
 char   *txtable;

 time(&t);

#define TEX_TABLE_SIZE 1000
 if((txtable = (char *) farcalloc( (long) ((long)(17)*(long)TEX_TABLE_SIZE) ,1)) == NULL)
  {
   /* error checking */
  };

 memset(txtable, '\0', 17 * TEX_TABLE_SIZE);

 textattr(7);
 gotoxy(1,8);
 cprintf("Creating WL TX :");
 textattr(15);

 for(i=0; i<=wall_max;i++)
  {
   get_wall_info(i);
    swpWAL.mid_tx = search_add_table(txtable, swpWAL.mid_tx_name);
    swpWAL.top_tx = search_add_table(txtable, swpWAL.top_tx_name);
    swpWAL.bot_tx = search_add_table(txtable, swpWAL.bot_tx_name);
    if(strcmp(swpWAL.sgn_tx_name,"") != 0)
     swpWAL.sign   = search_add_table(txtable, swpWAL.sgn_tx_name);
    else
     swpWAL.sign   = -1;
   set_wall_info(i);
   gotoxy(18,8);
   cprintf("%4.4d", i);
  }

 textattr(7);
 gotoxy(1,10);
 cprintf("Creating SC TX :");
 textattr(15);

 for(i=0; i<=sector_max;i++)
  {
   get_sector_info(i);
    swpSEC.floor_tx = search_add_table(txtable, swpSEC.floor_tx_name);
    swpSEC.ceili_tx = search_add_table(txtable, swpSEC.ceili_tx_name);
   set_sector_info(i);
   gotoxy(18,10);
   cprintf("%4.4d", i);
  }

 textattr(7);
 gotoxy(1,12);
 cprintf("Writing Sector : ");
 textattr(15);

 fprintf(flev, "LEV %s\n", MAP_VERSION);
 fprintf(flev, "# \n");
 fprintf(flev, "# GENERATED BY LEVMAP "LEVMAP_VERSION" \n");
 fprintf(flev, "# (c) Yves BORCKMANS 1995\n");
 fprintf(flev, "# \n");
 fprintf(flev, "# GENTIME %s", ctime(&t));
 fprintf(flev, "# \n");
 fprintf(flev, "# AUTHOR  %s\n", MAP_AUTHOR);
 fprintf(flev, "# \n");
 fprintf(flev, "# %s\n",MAP_COMNT1);
 fprintf(flev, "# %s\n",MAP_COMNT2);
 fprintf(flev, "# \n");
 fprintf(flev, "# GENERAL LEVEL INFORMATION\n");
 fprintf(flev, "# =========================\n");
 fprintf(flev, "# \n");
 fprintf(flev, "LEVELNAME %s\n", MAP_NAME);
 fprintf(flev, "PALETTE   %s\n", PAL_NAME);
 fprintf(flev, "MUSIC     %s\n", MUS_NAME);
 fprintf(flev, "PARALLAX  %9.4f %9.4f\n", PARALLAX1, PARALLAX2);
 fprintf(flev, "# \n");
 fprintf(flev, "# TEXTURE TABLE\n");
 fprintf(flev, "# =============\n");
 fprintf(flev, "# \n");

 texture_max = 0;
 for(;;)
  {
	 if(strcmp(&(txtable[texture_max*17]),"") == 0)
		break;
	 texture_max++;
  }
 texture_max--;

 fprintf(flev, "TEXTURES %d\n", texture_max + 1);
 for(i=0;i<=texture_max;i++)
  {
	fprintf(flev, " TEXTURE: %-12.12s # %2.2d\n", &(txtable[i*17]), i);
  }

 farfree(txtable);

 fprintf(flev, "# \n");
 fprintf(flev, "# SECTOR DEFINITIONS\n");
 fprintf(flev, "# ==================\n");
 fprintf(flev, "# \n");

 j = 0;
 for(i=0;i<=sector_max;i++)
  if(MAP_SEC[i].del == 0) j++;

 fprintf(flev, "NUMSECTORS %d\n", j);
 fprintf(flev, "# \n");
 for(i=0;i<=sector_max;i++)
  if(MAP_SEC[i].del == 1)
  {
  }
  else
  {
	gotoxy(18,12);
	cprintf("%4.4d", i);
	get_sector_info(i);
	fprintf(flev, "SECTOR %d\n", i);
	fprintf(flev, " NAME             %s\n",                 swpSEC.name);
	fprintf(flev, " AMBIENT          %d\n",                 swpSEC.ambient);
	fprintf(flev, " FLOOR TEXTURE    %d %5.2f %5.2f %d\n",  swpSEC.floor_tx,
																			  swpSEC.floor_tx_f1,
																			  swpSEC.floor_tx_f2,
																			  swpSEC.floor_tx_i);
    fprintf(flev, " FLOOR ALTITUDE   %5.2f\n",              MAP_SEC[i].floor_alt);
	fprintf(flev, " CEILING TEXTURE  %d %5.2f %5.2f %d\n",  swpSEC.ceili_tx,
																			  swpSEC.ceili_tx_f1,
																			  swpSEC.ceili_tx_f2,
																			  swpSEC.ceili_tx_i);
    fprintf(flev, " CEILING ALTITUDE %5.2f\n",              MAP_SEC[i].ceili_alt);
	fprintf(flev, " SECOND ALTITUDE  %5.2f\n",              swpSEC.second_alt);
    fprintf(flev, " FLAGS            %lu %u %u\n",          swpSEC.flag1,
                                                            swpSEC.flag2,
                                                            swpSEC.flag3);
    fprintf(flev, " LAYER            %d\n",                 MAP_SEC[i].layer);

	fprintf(flev, " VERTICES %d\n",                         MAP_SEC[i].vno);
	vertex_ix = MAP_SEC[i].vrt0;
	j = 0;
	while(j < MAP_SEC[i].vno)
	 {
	  fprintf(flev, "  X: %5.2f Z: %5.2f # %2d\n",         MAP_VRT[vertex_ix].x,
																			 MAP_VRT[vertex_ix].z,
																			 j);
	  j++;
	  vertex_ix++;
	 }

	fprintf(flev, " WALLS %d\n",                           MAP_SEC[i].wno);
	wall_ix = MAP_SEC[i].wal0;
	j = 0;
   while(j < MAP_SEC[i].wno)
    {
     get_wall_info(wall_ix);

  /* !!!!! ADAPT ADJOIN, WALK for deleted sectors  !!!!!*/

  if(MAP_WAL[wall_ix].adjoin != -1)
	{
	 deleted_sectors = 0;
    for(a=0; a<MAP_WAL[wall_ix].adjoin; a++) if(MAP_SEC[a].del != 0) deleted_sectors++;
    correct_adjoin = MAP_WAL[wall_ix].adjoin-deleted_sectors;
   }
  else
   correct_adjoin = -1;

  if(MAP_WAL[wall_ix].walk != -1)
   {
    deleted_sectors = 0;
    for(a=0; a<MAP_WAL[wall_ix].walk; a++) if(MAP_SEC[a].del != 0) deleted_sectors++;
    correct_walk   = MAP_WAL[wall_ix].walk-deleted_sectors;
   }
  else
   correct_walk   = -1;

     fprintf(flev,"  WALL LEFT: %2d RIGHT: %2d MID: %3d %5.2f %5.2f %d TOP: %3d %5.2f %5.2f %d BOT: %3d %5.2f %5.2f %d\
 SIGN: %d %5.2f %5.2f ADJOIN: %d MIRROR: %d WALK: %d FLAGS: %u %u %u LIGHT: %u\n",
  MAP_WAL[wall_ix].left_vx /* swpWAL.left_vx */, MAP_WAL[wall_ix].right_vx /* swpWAL.right_vx */,
  swpWAL.mid_tx,  swpWAL.mid_tx_f1, swpWAL.mid_tx_f2, swpWAL.mid_tx_i,
  swpWAL.top_tx,  swpWAL.top_tx_f1, swpWAL.top_tx_f2, swpWAL.top_tx_i,
  swpWAL.bot_tx,  swpWAL.bot_tx_f1, swpWAL.bot_tx_f2, swpWAL.bot_tx_i,
  swpWAL.sign,    swpWAL.sign_f1,   swpWAL.sign_f2,
  correct_adjoin, MAP_WAL[wall_ix].mirror,    correct_walk,
  swpWAL.flag1,   swpWAL.flag2,     swpWAL.flag3,
  swpWAL.light
 );
     j++;
     wall_ix++;
    }

   fprintf(flev, "#\n");
  }
}

