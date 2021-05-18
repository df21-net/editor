#ifndef __HUGE__
#error DFUSE MUST BE COMPILED USING THE HUGE MEMORY MODEL !!!
#endif

#define DFUSE_VERSION "v 2.14.00"
#define DFUSE_INI     "DFUSE.INI"
#define BUF_SIZE      32768            /* do not go above 64534 */
#define TOP_X         318
#define TOP_Y         198


/* This will show at startup where DFUSE assumes the GOBS to be */
/* #define SHOWGOBS */

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <fcntl.h>
#include <io.h>
#include <dos.h>
#include <dir.h>
#include <sys\types.h>
#include <sys\stat.h>
#include <alloc.h>

#include <graphics.h>

#include "toolkit.h"

#include "dark.h"
/* #include "dark.c" */

#define ERR_NOERROR       00
#define ERR_INIFILE       10
#define ERR_CMDLINE       20
#define ERR_NOTFOUND      30
#define ERR_GRAPHIC       40
#define ERR_RUNNING       50


void chk_cmdline(void);
void handle_ini(void);
void handle_locations(void);
void gr_startup(void);
void gr_shutdown(void);
void shell_to_DOS(void);
void choose_palette(void);
void prepare_viewer(char *which);
void edit_ini(void);
int  extract_a_file(char *gob , char *name);
int  extract_a_level(char *name);

void draw_menu_box(void);
void draw_menu_copyright(void);
void draw_menu_footer(void);

void top_menu(void);
void write_top_menu(void);

void view_menu(void);
void write_view_menu(void);

void text_menu(void);
void write_text_menu(void);

void lvl_menu(void);
void write_lvl_menu(void);

void gob_menu(void);
void write_gob_menu(void);

void full_gob_menu(void);
void write_full_gob_menu(void);

void bm_menu(void);
void write_bm_menu(void);

void fme_menu(void);
void write_fme_menu(void);

void wax_menu(void);
void write_wax_menu(void);

void voc_menu(void);
void write_voc_menu(void);

void set_mode_pal(void);
void show_palette(void);
