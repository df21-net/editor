/* ========================================================================== */
/*  LEVMAP.H : DEFINES, PROTOTYPES and TYPES                                  */
/* ========================================================================== */
#define LEVMAP_VERSION "v 2.42.00"
#define DFUSE_INI      "DFUSE.INI"

#ifndef __HUGE__
#error LEVMAP MUST BE COMPILED USING THE HUGE MEMORY MODEL !!!
#endif

/* ************************************************************************** */
/* convert SCREEN coordinates to MAP coordinates                              */
#define S2MX(x)      (xoffset + (int) (((x) - ScreenCenterX) / scale))
#define S2MY(y)      (yoffset + (int) ((ScreenCenterY - (y)) / scale))
/* convert MAP coordinates to SCREEN coordinates                              */
#define M2SX(x)      (ScreenCenterX + (int) (((x) - xoffset) * scale))
#define M2SY(y)      (ScreenCenterY + (int) ((yoffset - (y)) * scale))
/* ************************************************************************** */
/* convert SCREEN coordinates to MAP coordinates (float)                      */
#define S2MXF(x)     ((float)((float)xoffset + (((float)(x) - (float)ScreenCenterX) / scale)))
#define S2MYF(y)     ((float)((float)yoffset + (((float)ScreenCenterY - (float)(y)) / scale)))
/* convert MAP coordinates to SCREEN coordinates (float)                      */
#define M2SXF(x)     ((float)((float)ScreenCenterX + (((float)(x) - (float)xoffset) * scale)))
#define M2SYF(y)     ((float)((float)ScreenCenterY + (((float)yoffset - (float)(y)) * scale)))
/* ************************************************************************** */

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <io.h>
#include <fcntl.h>
#include <conio.h>
#include <dos.h>
#include <dir.h>
#include <sys\types.h>
#include <sys\stat.h>
#include <graphics.h>

#include "toolkit.h"

#define MAX_OBJECT_SEQUENCE 25
#define MAX_OBJECT_SEQ_LEN  60

#define ERR_NOERROR       00
#define ERR_INIFILE       10
#define ERR_CMDLINE       20
#define ERR_NOTFOUND      30
#define ERR_GRAPHIC       40
#define ERR_WRONGFILE     50
#define ERR_NOTLVB        60
#define ERR_TOOLONG       70
#define ERR_DYNALLOC      80

#define TITLE_BOX_X      638
#define TITLE_BOX_Y       96

#define EXTRUDE_RATIO     0.25


void invert_sector_vertices_order(int num);

void chk_cmdline(void);
void handle_ini(void);
void handle_locations(void);
void gr_startup(void);
void gr_shutdown(void);

void read_level(void);
void save_level(void);
void close_temp_files(void);
void free_memory(void);
void show_help_keys(void);
void show_help_doc(void);
void show_help_specs(void);
void notepad(void);
void messageOK(char *the_message);
void messageSAVE(void);
void messageREREAD(void);
void messageQUIT(void);
void message_out_of_sectors(void);
void message_out_of_vxwl(void);
void message_out_of_ob(void);
void messageTRANSFER_SEL(void);

void show_memory(void);
void edit_gol(void);
void edit_inf(void);
void jump_to_thing(void);
void find_thing(void);

int GetSectorVX(int the_sector, int the_vx);
int GetRelativeVXfromAbsoluteVX(int num);
int GetSectorWL(int the_sector, int the_wl);
int GetRelativeWLfromAbsoluteWL(int num);
int GetAbsoluteVXFfromWL(int num);
int GetAbsoluteVXTfromWL(int num);
int GetAbsoluteWLfromVXF(int num);
int GetAbsoluteWLfromVXT(int num);

float GetWLlen(int num);
float GetWLhei(int num);

void set_mode_map(void);
void handle_titlebar(int color, int color_border);
void handle_loading(int color);
void handle_title(int color);
void handle_title_sector(int color);
void handle_title_wall(int color);
void handle_title_vertex(int color);
void handle_title_object(int color);
void handle_mapkinput(void);
int  get_nearest_SC(float x, float z, int start_at);
int  get_nearest_WL(float x, float z);
int  get_nearest_VX(float x, float z);
int  get_next_nearest_VX(float x, float z);
int  get_nearest_OB(float x, float z);
int  get_object_SC(int num);
int layer_objects(void);
void set_map_centered(void);

void draw_a_sector(int sector, int color);
void draw_a_wall(int wall, int color);
void draw_a_wall_side(int num, int color);
void draw_a_vertex(int vertex, int color);
void draw_a_bigger_vertex(int vertex, int color);
void draw_an_object(int obj, int color);
void draw_a_bigger_object(int obj, int color);
void draw_sector_vertices(int sector, int color);
void draw_the_map(void);
void draw_in_sc_mode(void);
void draw_in_wl_mode(void);
void draw_in_vx_mode(void);
void draw_in_ob_mode(void);
int  difficulty_ok(int diff);
void draw_shadow(void);
void draw_current_layer(void);
void draw_specials(void);
void draw_line_triggers(void);

void get_sector_info(int num);
void set_sector_info(int num);
void get_sector_info2(int num); /* uses swpSEC2*/
void get_wall_info(int num);
void set_wall_info(int num);
void get_texture_name(int num, char *name);
void set_texture_name(int num, char *name);
void get_object_info(int num);
void set_object_info(int num);
void get_pod_name(int num, char *name);
void get_fme_name(int num, char *name);
void get_spr_name(int num, char *name);
void get_snd_name(int num, char *name);

void edit_level(void);
void show_level_layout(void);
void show_level_field(int fieldnum, int color);
void edit_level_field(int fieldnum);

unsigned edit_flag(char *flagfile, unsigned currentval);
unsigned long edit_lflag(char *flagfile, unsigned long currentval);

void refresh_map_in_editor(void);
int  bmpicker(char *title, char *filename, char *returned,
              int color_fore, int color_back, int color_border, int color_hilite);
int  show_bm(char *bm, char *pal);

void edit_sector(void);
void show_sector_layout(int color);
void show_all_sector_fields(int color);
void show_sector_field(int fieldnum, int color);
void edit_sector_field(int fieldnum);

void edit_wall(void);
void show_wall_layout(int color);
void show_all_wall_fields(int color);
void show_wall_field(int fieldnum, int color);
void edit_wall_field(int fieldnum);

void edit_vertex(void);
void show_vertex_layout(int color);
void show_all_vertex_fields(int color);
void show_vertex_field(int fieldnum, int color);
void edit_vertex_field(int fieldnum);

void edit_object__seqs(void);
void recalc_logic(void); /* uses only OB_HILITE ! */
int  obpicker(char *title, char *filename, char *returned,
              int color_fore, int color_back, int color_border, int color_hilite);
int  show_fme(char *fme, char *pal);
int  show_wax(char *wax, char *pal);

void edit_object(void);
void show_object_layout(int color);
void show_all_object_fields(int color);
void show_object_field(int fieldnum, int color);
void edit_object_field(int fieldnum);

void InsertWL(int sector, int num, struct tagMAP_WAL new_wl);
void InsertVX(int sector, int num, struct tagMAP_VRT new_vx);
void DeleteVX(int sector, int num);
void DeleteWL(int sector, int num);

void move_sector(int num, float x, float z);
int  insert_sector(float x, float z);
int  insert_sectors(float x, float z);
void delete_sector(int num);
void undelete_sector(int num);
int  insert_sector_gap(float x, float z);

void move_vertex(int num, float x, float z);

void move_wall(int num, float x, float z);
void delete_wall(int num);
int  split_wall(int num);
/* int  extrude_wall(int num); */
int  extrude_wall4(int num);
void flip_wall(int num);
int make_adjoin(int num);
int un_adjoin(int num);

void move_object(int num, float x, float z);
int  insert_object(float x, float z);
int  insert_objects(float x, float z);
void delete_object(int num);
void undelete_object(int num);

void handle_lev_file(void);
void handle_lev(void);
void handle_lna(void);
void handle_pfl(void);
void handle_mfl(void);
void handle_lnf(void);
void handle_tex(void);
void handle_tna(void);
void handle_sno(void);
void handle_sec(void);
void handle_sna(void);
void handle_sam(void);
void handle_sft(void);
void handle_sfa(void);
void handle_sct(void);
void handle_sca(void);
void handle_sla(void);
void handle_2da(void);
void handle_snf(void);
void handle_vno(void);
void handle_vrt(void);
void handle_wno(void);
void handle_wal(void);

int search_add_table(char *table, char *txname);
void write_lev(void);

void handle_o_file(void);
void handle_o(void);
void handle_lnao(void);
void handle_pods(void);
void handle_pod(void);
void handle_sprs(void);
void handle_spr(void);
void handle_fmes(void);
void handle_fme(void);
void handle_sounds(void);
void handle_sound(void);
void handle_objects(void);
void handle_class(void);
void handle_seq(void);
void handle_seqitem(void);
void handle_seqend(void);

void write_o(void);

void handle_mouse(void);
void create_mouse(void);
void show_mouse(int x, int y);
void hide_mouse(int x, int y);

void check_level(void);
int check_adjoin_mirror(int wall);

void multi_sector(int num);
void multi_wall(int num);
void multi_vertex(int num);
void multi_object(int num);

void clear_multi_sector(void);
void clear_multi_wall(void);
void clear_multi_vertex(void);
void clear_multi_object(void);

void convert_multi_SC2WL(void);
void convert_multi_SC2VX(void);
void convert_multi_WL2VX(void);
void convert_multi_SC2VX_noclear(void);
void convert_multi_WL2VX_noclear(void);

void move_multi_sector(int num, float x, float z);
void move_multi_wall(int num, float x, float z);
void move_multi_vertex(int num, float x, float z);
void move_multi_object(int num, float x, float z);

void delete_multi_sector(void);
void undelete_multi_sector(void);
void delete_multi_object(void);
void undelete_multi_object(void);

int find_multisel_SC(int num);
int find_multisel_OB(int num);
int find_multisel_WL(int num);
void stitch_horizontal_MID(void);
void stitch_horizontal_TOP(void);
void stitch_horizontal_BOT(void);
void stitch_horizontal_inv_MID(void);
void stitch_horizontal_inv_TOP(void);
void stitch_horizontal_inv_BOT(void);
void stitch_vertical_MID(void);
void stitch_vertical_TOP(void);
void stitch_vertical_BOT(void);

void distribute_floor_alt(void);
void distribute_ceili_alt(void);
void distribute_light(void);

void show_deform_layout(int color);
void show_all_deform_fields(int color);
void show_deform_field(int fieldnum, int color);
void edit_deform_field(int fieldnum);
void edit_deform(void);
void deform_vertices(void);
void deform_objects(void);

void show_ngon_layout(int color);
void show_all_ngon_fields(int color);
void show_ngon_field(int fieldnum, int color);
void edit_ngon_field(int fieldnum);
void edit_ngon(void);
void construct_ngon(void);
void construct_ngon_gap(void);

void handle_inf_file(int silent);
void handle_inf(void);
void handle_lnai(void);
void handle_items(void);
void handle_item(void);
void handle_classinf(void);
void handle_client(void);

/* ************************************************************************** */
/* General use typedefs                                                       */
/* ************************************************************************** */

/* SECTORS */
typedef struct tagMAP_SEC
 {
  int        del;   /* sectors can be (un)deleted          */
  int        mark;  /* reserved for multiple selection     */
  int        layer;
  float      floor_alt;
  float      ceili_alt;
  int        vno;
  int        vrt0;
  int        wno;
  int        wal0;
  byte       secret;
  byte       elev;
  byte       trig;
  byte       reserved; /* used in the deformations */
 } MAP_SECtype;

typedef struct tagswpSEC
 {
  char       name[20];
  int        ambient;
  int        floor_tx;
  float      floor_tx_f1;
  float      floor_tx_f2;
  int        floor_tx_i;
  int        ceili_tx;
  float      ceili_tx_f1;
  float      ceili_tx_f2;
  int        ceili_tx_i;
  float      second_alt;
  unsigned long flag1;
  unsigned   flag2;
  unsigned   flag3;
  int        layer;
  char       floor_tx_name[16];
  char       ceili_tx_name[16];
  int        num_classes;
  char       elevator_name[20];
  char       trigger_name[20];
  char       client_name[20];
 } swpSECtype;

/* WALLS */
typedef struct tagMAP_WAL
 {
  int        mark;  /* reserved for multiple selection     */
  int        left_vx;
  int        right_vx;
  int        adjoin;
  int        mirror;
  int        walk;
  int        sec; 
  byte       trig;
  byte       reserved; /* used in the deformations */
 } MAP_WALtype;

typedef struct tagSWP_WAL
 {
  int        mid_tx;
  float      mid_tx_f1;
  float      mid_tx_f2;
  int        mid_tx_i;
  int        top_tx;
  float      top_tx_f1;
  float      top_tx_f2;
  int        top_tx_i;
  int        bot_tx;
  float      bot_tx_f1;
  float      bot_tx_f2;
  int        bot_tx_i;
  int        sign;
  float      sign_f1;
  float      sign_f2;
  unsigned   flag1;
  unsigned   flag2;
  unsigned   flag3;
  unsigned   light;
  char       mid_tx_name[16];
  char       top_tx_name[16];
  char       bot_tx_name[16];
  char       sgn_tx_name[16];
  char       trigger_name[20];
  char       client_name[20];
 } swpWALtype;

typedef struct tagMAP_VRT
 {
  int        mark;  /* reserved for multiple selection     */
  float      x;
  float      z;
  int        sec;
 } MAP_VRTtype;

typedef struct tagMAP_OBJ
 {
  int        del;     /* objects can be (un)deleted           */
  int        mark;    /* reserved for multiple selection      */
  int        sec;     /* reserved for future objects layering */
  float      x;
  float      y;
  float      z;
  float      yaw;
  int        diff;
  int        col;     /* reserved for different colorings     */
  unsigned   type;    /* reserved for different displays      */
  unsigned   special; /* reserved for different displays      */
 } MAP_OBJtype;

typedef struct tagSWP_OBJ
 {
  char          classname[16];
  char          dataname[16];
  char          logic[24];
  int           data;
  float         pch;
  float         rol;
  int           seqs;
  char          seq[MAX_OBJECT_SEQUENCE][MAX_OBJECT_SEQ_LEN];
 } swpOBJtype;

#define OBT_SPIRIT       1
#define OBT_SAFE         2
#define OBT_3D           4
#define OBT_SPRITE       8
#define OBT_FRAME       16
#define OBT_SOUND       32

#define OBS_GENERATOR    1
