/* ************************************************************************** */
/*  GLOBAL VARIABLES                                                          */
/* ************************************************************************** */

/* general */

char  DACbuffer[768];
char  DACbuffer2[768];
int   BM_MEMORY;
char  tmpstr[127];
int   ccc = 0;

char  golden_path[127];
char  golden_path_drive[5];

char  fns_drive[MAXDRIVE];
char  fns_dir[MAXDIR];
char  fns_fname[MAXFILE];
char  fns_ext[MAXEXT];

char df_inst_dir[81];
char dark_gob[101];
char textures_gob[101];
char sprites_gob[101];
char sounds_gob[101];

char pk_textures[80] = "DFUDATA\\text0000.dfu";
char pk_sprites[80]  = "DFUDATA\\sprites.dfu";
char pk_frames[80]   = "DFUDATA\\frames.dfu";
char pk_3d[80]       = "DFUDATA\\3d.dfu";
char pk_sounds[80]   = "DFUDATA\\sounds.dfu";

/* file related */
FILE  *flev;
int   ftex;
int   fsec;
int   fwal;
FILE  *fo;
int   fobj;
int   fpods;
int   fsprs;
int   ffmes;
int   fsounds;

char  fname_lev[127];
char  fname_tex[127];
char  fname_sec[127];
char  fname_wal[127];
char  fname_o[127];
char  fname_obj[127];
char  fname_pods[127];
char  fname_sprs[127];
char  fname_fmes[127];
char  fname_sounds[127];
char  fname_inf[127];
char  fname_gol[127];

char  fbuffer[255];

/* graphics related */
char  BGIdriver[10];
int   BGImode;
int   gdriver;
int   gmode;
int   errorcode              = grNoInitGraph;


/* MAP related */
int   BACKUP_DONE            = 0;
int   MODIFIED               = 0;
int   MULTISEL               = 0;
int   APPLY_TO_MULTI         = 0;
int   NGON_GAP               = 0;

char  MAP_AUTHOR[50];
char  MAP_COMNT1[70];
char  MAP_COMNT2[70];

char  MAP_VERSION[20];
char  MAP_NAME[20];
char  PAL_NAME[20];
char  MUS_NAME[20];
float PARALLAX1,
      PARALLAX2;
char  MAP_VERSION_O[20];
char  MAP_NAME_O[20];
int   INF_ITEMS;

int   seqfound               =  0;
int   logfound               =  0;
int   texture_max            =  0;
int   pod_max                =  0;
int   spr_max                =  0;
int   fme_max                =  0;
int   sound_max              =  0;

int   sector_ix              = -1;
int   sector_max             =  0;
int   sector_alloc           =  0;
int   vertex_ix              =  0;
int   vertex_max             =  0;
int   vertex_alloc           =  0;
int   wall_ix                =  0;
int   wall_max               =  0;
int   wall_alloc             =  0;
int   obj_ix                 = -1;
int   obj_cur                =  0;
int   obj_max                =  0;
int   obj_alloc              =  0;
int   seq_ix                 =  0;

int   inf_ix                 = -1;
int   inf_max                =  0;
int   secnum;
int   walnum;
int   found_elev;
int   found_trig;
int   found_cli;

float scale                  =  1;
int   grid                   = 16;
int   GRID                   =  0;
int   PERPS                  =  1;
int   DIFFICULTY             =  0;
int   ScreenX                =  0;
int   ScreenY                =  0;
int   ScreenCenterX          =  0;
int   ScreenCenterY          =  0;
int   xoffset                =  0;
int   yoffset                =  0;
int   LAYER                  =  0;
float maxx                   = -32000.0;
float maxz                   = -32000.0;
float minx                   =  32000.0;
float minz                   =  32000.0;
int   maxlayer               = -32000;
int   minlayer               =  32000;

int   MAP_MODE               = 0; /* 0=SC 1=WL 2=VX 3=OB */
char  MAP_MODE_NAMEL[12]     = "SECTORS";
char  MAP_MODE_NAMES[3]      = "SC";

int   SC_HILITE              =  0;
int   VX_HILITE              =  0;
int   WL_HILITE              =  0;
int   OB_HILITE              =  0;

int   wl_tmpadjoin, wl_tmpmirror, wl_tmpwalk;

/* all the sectors/walls/vertices/objects and their swap file buffers */
MAP_SECtype  huge *MAP_SEC;
MAP_WALtype  huge *MAP_WAL;
MAP_VRTtype  huge *MAP_VRT;
MAP_OBJtype  huge *MAP_OBJ;
swpSECtype   swpSEC, swpSEC2;
swpWALtype   swpWAL, swpWAL2;
swpOBJtype   swpOBJ, swpOBJ2;

/* INI related */
char  call_editor[101];
char  call_pager[101] ;
char  call_vplayer[101];

int   MAX_VERTICES   ;
int   MAX_WALLS      ;
int   SUP_SECTORS    ;
int   SUP_OBJECTS    ;
int   REVERSE        ;
int   HEAD_FORE      ;
int   HEAD_BACK      ;
int   HEAD_BORDER    ;
int   LINE_AT_ALT    ;
int   LINW_AT_ALT    ;
int   LINE_NOTALT    ;
int   LINE_SECRET    ;
int   LINE_ELEV      ;
int   LINE_TRIG      ;
int   HILI_AT_ALT    ;
int   HILI_NOTALT    ;
int   OBJ_HILITED    ;
int   OBJ_NOTHILI    ;
int   COLOR_DELETED  ;
int   COLOR_GRID     ;
int   COLOR_MULTISEL ;
int   COLOR_ERASER   ;

int   SHADOW         ;
int   OBJECT_LAYERING;
int   CENTERZOOM     ;

int   TX_ATTR_TITL   ;
int   TX_ATTR_BACK   ;
int   TX_ATTR_EDIT   ;


/* MOUSE related */
void  *mouse_background;
void  *mouse_cursor;
int   oldmx               = -32000;
int   oldmy               = -32000;
float MAP_MOUSE_X;
float MAP_MOUSE_Z;
float MAP_MOUSE_GX;
float MAP_MOUSE_GZ;
