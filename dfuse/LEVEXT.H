/* ************************************************************************** */
/*  GLOBAL VARIABLES EXTERN COPY TO USE ACROSS FILES                          */
/* ************************************************************************** */

/* general */
extern char  DACbuffer[768];
extern char  DACbuffer2[768];
extern int   BM_MEMORY;
extern char  tmpstr[127];
extern int   ccc;

extern char  golden_path[127];
extern char  golden_path_drive[5];

extern char  fns_drive[MAXDRIVE];
extern char  fns_dir[MAXDIR];
extern char  fns_fname[MAXFILE];
extern char  fns_ext[MAXEXT];

extern char  df_inst_dir[81];
extern char  dark_gob[101];
extern char  textures_gob[101];
extern char  sprites_gob[101];
extern char  sounds_gob[101];

extern char pk_textures[80];
extern char pk_sprites[80];
extern char pk_frames[80];
extern char pk_3d[80];
extern char pk_sounds[80];

/* file related */
extern FILE  *flev;
extern int   ftex;
extern int   fsec;
extern int   fwal;
extern FILE  *fo;
extern int   fobj;
extern int   fpods;
extern int   fsprs;
extern int   ffmes;
extern int   fsounds;

extern char  fname_lev[127];
extern char  fname_tex[127];
extern char  fname_sec[127];
extern char  fname_wal[127];
extern char  fname_o[127];
extern char  fname_obj[127];
extern char  fname_pods[127];
extern char  fname_sprs[127];
extern char  fname_fmes[127];
extern char  fname_sounds[127];
extern char  fname_inf[127];
extern char  fname_gol[127];

extern char  fbuffer[255];

/* graphics related */
extern char  BGIdriver[10]  ;
extern int   BGImode        ;
extern int   gdriver;
extern int   gmode;
extern int   errorcode      ;


/* MAP related */
extern int   BACKUP_DONE    ;
extern int   MODIFIED       ;
extern int   MULTISEL       ;
extern int   APPLY_TO_MULTI ;
extern int   NGON_GAP       ;

extern char  MAP_AUTHOR[50] ;
extern char  MAP_COMNT1[70] ;
extern char  MAP_COMNT2[70] ;

extern char  MAP_VERSION[20];
extern char  MAP_NAME[20];
extern char  PAL_NAME[20];
extern char  MUS_NAME[20];
extern float PARALLAX1;
extern float PARALLAX2;
extern char  MAP_VERSION_O[20];
extern char  MAP_NAME_O[20];
extern int   INF_ITEMS;

extern int   seqfound          ;
extern int   logfound          ;
extern int   texture_max       ;
extern int   pod_max           ;
extern int   spr_max           ;
extern int   fme_max           ;
extern int   sound_max         ;
                               ;
extern int   sector_ix         ;
extern int   sector_max        ;
extern int   sector_alloc      ;
extern int   vertex_ix         ;
extern int   vertex_max        ;
extern int   vertex_alloc      ;
extern int   wall_ix           ;
extern int   wall_max          ;
extern int   wall_alloc        ;
extern int   obj_ix            ;
extern int   obj_cur           ;
extern int   obj_max           ;
extern int   obj_alloc         ;
extern int   seq_ix            ;

extern int   inf_ix            ;
extern int   inf_max           ;
extern int   secnum;
extern int   walnum;
extern int   found_elev;
extern int   found_trig;
extern int   found_cli;
                               ;
extern float scale             ;
extern int   grid              ;
extern int   GRID              ;
extern int   PERPS             ;
extern int   DIFFICULTY        ;
extern int   ScreenX           ;
extern int   ScreenY           ;
extern int   ScreenCenterX     ;
extern int   ScreenCenterY     ;
extern int   xoffset           ;
extern int   yoffset           ;
extern int   LAYER             ;
extern float maxx              ;
extern float maxz              ;
extern float minx              ;
extern float minz              ;
extern int   maxlayer          ;
extern int   minlayer          ;
                               ;
extern int   MAP_MODE          ;
extern char  MAP_MODE_NAMEL[12];
extern char  MAP_MODE_NAMES[3] ;
                               ;
extern int   SC_HILITE         ;
extern int   VX_HILITE         ;
extern int   WL_HILITE         ;
extern int   OB_HILITE         ;

/* extern float vx_tmpx, vx_tmpz; OBSOLETE */
extern int   wl_tmpadjoin, wl_tmpmirror, wl_tmpwalk;

/* all the sectors/walls/vertices/objects and their swap file buffers */
extern MAP_SECtype  huge *MAP_SEC;
extern swpSECtype   swpSEC, swpSEC2;
extern MAP_WALtype  huge *MAP_WAL;
extern swpWALtype   swpWAL, swpWAL2;
extern MAP_VRTtype  huge *MAP_VRT;
extern MAP_OBJtype  huge *MAP_OBJ;
extern swpOBJtype   swpOBJ, swpOBJ2;


/* INI related */
extern char  call_editor[101];
extern char  call_pager[101];
extern char  call_vplayer[101];

extern int   MAX_VERTICES;
extern int   MAX_WALLS;
extern int   SUP_SECTORS  ;
extern int   SUP_OBJECTS  ;
extern int   REVERSE      ;
extern int   HEAD_FORE    ;
extern int   HEAD_BACK    ;
extern int   HEAD_BORDER  ;
extern int   LINE_AT_ALT  ;
extern int   LINW_AT_ALT  ;
extern int   LINE_NOTALT  ;
extern int   LINE_SECRET  ;
extern int   LINE_ELEV    ;
extern int   LINE_TRIG    ;
extern int   HILI_AT_ALT  ;
extern int   HILI_NOTALT  ;
extern int   OBJ_HILITED  ;
extern int   OBJ_NOTHILI  ;
extern int   COLOR_DELETED;
extern int   COLOR_GRID   ;
extern int   COLOR_MULTISEL;
extern int   COLOR_ERASER ;

extern int   SHADOW       ;
extern int   OBJECT_LAYERING;
extern int   CENTERZOOM   ;

extern int   TX_ATTR_TITL ;
extern int   TX_ATTR_BACK ;
extern int   TX_ATTR_EDIT ;

/* MOUSE related */
extern void  *mouse_background;
extern void  *mouse_cursor;
extern int   oldmx;
extern int   oldmy;
extern float MAP_MOUSE_X;
extern float MAP_MOUSE_Z;
extern float MAP_MOUSE_GX;
extern float MAP_MOUSE_GZ;
