/* ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
   º TOOLKIT C                                                              º
   º                                                                        º
   º v 0.99999                                                              º
   º                                                                        º
   º (c) Yves BORCKMANS 1994,1995                                           º
   º------------------------------------------------------------------------º
   º Includes :                                                             º
   º               v    MOUSE                                               º
   º               v    JOYSTICK                                            º
   º               v    VIRTUAL KEYBOARD                                    º
   º               v    CURSOR                                              º
   º               v    .INI READ AND WRITE                                 º
   º                                                                        º
   ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼ */

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <io.h>
#include <conio.h>
#include <dos.h>
#include <bios.h>
#include <sys\types.h>
#include <sys\stat.h>
#include <math.h>

#ifndef TOOLKIT_NO_GRAPHICS
#include <graphics.h>
#include <alloc.h>
#endif

#define TOOLKIT_JOYSTICK
#define USING_TOOLKIT

/* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³  MISCELLANEOUS DEFINES                                                ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

#define FALSE               0
#define TRUE                1

typedef int                 BOOL;
typedef int                 BOOLEAN;
typedef int                 boolean;
typedef unsigned char       BYTE;
typedef unsigned char       byte;
typedef unsigned short      WORD;
typedef unsigned short      word;
typedef unsigned long       DWORD;
typedef unsigned long       dword;
typedef unsigned int        UINT;
typedef unsigned int        uint;
typedef long                LONG;

#define LOBYTE(w)           ((BYTE)(w))
#define HIBYTE(w)           ((BYTE)((UINT)(w) >> 8))
#define LOWORD(l)           ((WORD)(l))
#define HIWORD(l)           ((WORD)((DWORD)(l) >> 16))


/* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³  GLOBALS                                                              ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

extern boolean MousePresent;
extern boolean BeepingKeys ;


/* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³  MISCELLANEOUS ROUTINES                                               ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

void Beep(int, int);
void Bip(void);


/* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³  MOUSE HANDLING                                                       ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

#define MOUSEINT 0x33

void InitMouseDriver(void);
void ShowMousePointer(void);
void HideMousePointer(void);
void GetMouseButtons(int *);
void GetMousePos(int *, int *);
void GetMouseTextPos(int *, int *);
void SetMousePos(int, int);
void SetMouseTextPos(int, int);
void ClipMouse(int, int, int, int);
void ClipMouseText(int, int, int, int);
void UnClipMouseText(void);

int  mousehit(void);


/* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³  JOYSTICK HANDLING                                                    ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

#ifdef TOOLKIT_JOYSTICK
#define JOYINT 0x15

void GetJoy1Buttons(BYTE *j1b1, BYTE *j1b2);
void GetJoy2Buttons(BYTE *j2b1, BYTE *j2b2);
void GetJoysButtons(BYTE *j1b1, BYTE *j1b2, BYTE *j2b1, BYTE *j2b2);
void GetJoy1Pos(int *j1x, int *j1y);
void GetJoy2Pos(int *j2x, int *j2y);
void GetJoysPos(int *j1x, int *j1y, int *j2x, int *j2y);

int joy1hit(void);
int joy2hit(void);
int joyshit(void);
#endif


/* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³  CURSOR HANDLING                                                      ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

void HideCursor(void);
void NormalCursor(void);
void BlockCursor(void);

/* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³  VIRTUAL KEYBOARD HANDLING                                            ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

int  VKhit(void);       /* check key or mouse button pressed                 */
void VKwait(void);      /* wait for key or mouse button (eat key)            */
int  getVK(void);       /* get virtual key                                   */

/* Conventions adopted (it doesn't really matter, but just to stay logical...)
   The getVK() function returns the same code when not extended (1 byte),
   so those mnemonics are for convenience only.

   Unmodified extended keys go in the 1001 - 1999 range
   Then, ALT  keys are given the      2001 - 2999
         CTL                          3000 - 3999
         SHFT                         4000 - 4999

   In there, "middle keys" receive 7xx range, function keys receive 8xx range,
   and mouse buttons 9xx range.
   But remember this is only a convention, and as long as you code it
   correctly in getVK(), you can do anything...

   A quick amelioration would be to get the VK_C_K and there make another
   getch() which will lead to a Borland style ^KA ^KB etc. Using that method
   you can get nearly infinite virtual keys.
                                                                             */

#define VK_UNKNOWN       0

/* Normal Keys          */
#define VK_C_A           1
#define VK_C_B           2
#define VK_C_C           3
#define VK_C_D           4
#define VK_C_E           5
#define VK_C_F           6
#define VK_C_G           7
#define VK_BELL          7
#define VK_C_H           8
#define VK_BACKSPC       8
#define VK_BACKSPACE     8
#define VK_C_I           9
#define VK_TAB           9
#define VK_C_J          10
#define VK_LF           10
#define VK_C_K          11
#define VK_C_L          12
#define VK_C_M          13
#define VK_RETURN       13
#define VK_ENTER        13
#define VK_CR           13
#define VK_C_N          14
#define VK_C_O          15
#define VK_C_P          16
#define VK_C_Q          17
#define VK_C_R          18
#define VK_C_S          19
#define VK_C_T          20
#define VK_C_U          21
#define VK_C_V          22
#define VK_C_W          23
#define VK_C_X          24
#define VK_C_Y          25
#define VK_C_Z          26
#define VK_C_LBRACK     27
#define VK_ESC          27
#define VK_ESCAPE       27
#define VK_C_BACKSLSH   28
#define VK_C_BACKSLASH  28
#define VK_C_RBRACK     29
#define VK_C_CFLEX      30
#define VK_C_UNDER      31
#define VK_SPC          32
#define VK_SPACE        32
#define VK_BLANK        32
#define VK_EXCLAM       33
#define VK_EXCLAMATION  33
#define VK_DQUOTE       34
#define VK_CROSSR       35
#define VK_CROSSROADS   35
#define VK_DIESE        35
#define VK_POUND        35
#define VK_DOLLAR       36
#define VK_PERCENT      37
#define VK_AMPERSAND    38
#define VK_SQUOTE       39
#define VK_LPAREN       40
#define VK_RPAREN       41
#define VK_STAR         42
#define VK_PLUS         43
#define VK_COMMA        44
#define VK_MINUS        45
#define VK_DOT          46
#define VK_SLASH        47
#define VK_0            48
#define VK_1            49
#define VK_2            50
#define VK_3            51
#define VK_4            52
#define VK_5            53
#define VK_6            54
#define VK_7            55
#define VK_8            56
#define VK_9            57
#define VK_COL          58
#define VK_SEMICOL      59
#define VK_LESS         60
#define VK_EQUAL        61
#define VK_GREATER      62
#define VK_QUESTION     63
#define VK_AT           64
#define VK_A            65
#define VK_B            66
#define VK_C            67
#define VK_D            68
#define VK_E            69
#define VK_F            70
#define VK_G            71
#define VK_H            72
#define VK_I            73
#define VK_J            74
#define VK_K            75
#define VK_L            76
#define VK_M            77
#define VK_N            78
#define VK_O            79
#define VK_P            80
#define VK_Q            81
#define VK_R            82
#define VK_S            83
#define VK_T            84
#define VK_U            85
#define VK_V            86
#define VK_W            87
#define VK_X            88
#define VK_Y            89
#define VK_Z            90
#define VK_LBRACK       91
#define VK_LBRACKET     91
#define VK_BACKSLASH    92
#define VK_RBRACK       93
#define VK_RBRACKET     93
#define VK_CFLEX        94
#define VK_CIRCUMFLEX   94
#define VK_UNDERSC      95
#define VK_UNDERSCORE   95
#define VK_BACKQUOTE    96
#define VK_a            97
#define VK_b            98
#define VK_c            99
#define VK_d           100
#define VK_e           101
#define VK_f           102
#define VK_g           103
#define VK_h           104
#define VK_i           105
#define VK_j           106
#define VK_k           107
#define VK_l           108
#define VK_m           109
#define VK_n           110
#define VK_o           111
#define VK_p           112
#define VK_q           113
#define VK_r           114
#define VK_s           115
#define VK_t           116
#define VK_u           117
#define VK_v           118
#define VK_w           119
#define VK_x           120
#define VK_y           121
#define VK_z           122
#define VK_LBRACE      123
#define VK_PIPE        124
#define VK_RBRACE      125
#define VK_TILDE       126
#define VK_DELETE      127

/* Extended Keys        */
#define VK_EXTENDED   1000

#define VK_HOME       1701
#define VK_UP         1702
#define VK_PGUP       1703
#define VK_LEFT       1704
#define VK_RIGHT      1705
#define VK_END        1706
#define VK_DOWN       1707
#define VK_PGDN       1708
#define VK_INS        1709
#define VK_DEL        1710

#define VK_F1         1801
#define VK_F2         1802
#define VK_F3         1803
#define VK_F4         1804
#define VK_F5         1805
#define VK_F6         1806
#define VK_F7         1807
#define VK_F8         1808
#define VK_F9         1809
#define VK_F10        1810
#define VK_F11        1811
#define VK_F12        1812

#define VK_LBUTT      1901
#define VK_RBUTT      1902
#define VK_MBUTT      1904
#define VK_LRBUTT     1903
#define VK_2BUTT      1903
#define VK_LMBUTT     1905
#define VK_RMBUTT     1906
#define VK_LRMBUTT    1907
#define VK_3BUTT      1907

#define VK_A_A        2001
#define VK_A_B        2002
#define VK_A_C        2003
#define VK_A_D        2004
#define VK_A_E        2005
#define VK_A_F        2006
#define VK_A_G        2007
#define VK_A_H        2008
#define VK_A_I        2009
#define VK_A_J        2010
#define VK_A_K        2011
#define VK_A_L        2012
#define VK_A_M        2013
#define VK_A_N        2014
#define VK_A_O        2015
#define VK_A_P        2016
#define VK_A_Q        2017
#define VK_A_R        2018
#define VK_A_S        2019
#define VK_A_T        2020
#define VK_A_U        2021
#define VK_A_V        2022
#define VK_A_W        2023
#define VK_A_X        2024
#define VK_A_Y        2025
#define VK_A_Z        2026

#define VK_A_1        2101
#define VK_A_2        2102
#define VK_A_3        2103
#define VK_A_4        2104
#define VK_A_5        2105
#define VK_A_6        2106
#define VK_A_7        2107
#define VK_A_8        2108
#define VK_A_9        2109
#define VK_A_0        2110

#define VK_A_ESC      2201
#define VK_A_TAB      2202
#define VK_A_BACKSPC  2203
#define VK_A_ENTER    2204
#define VK_A_RETURN   2204

#define VK_A_NUMDIV   2301
#define VK_A_NUMMUL   2302
#define VK_A_NUMMIN   2303
#define VK_A_NUMPLS   2304
#define VK_A_NUMENT   2305

#define VK_A_HOME     2701
#define VK_A_UP       2702
#define VK_A_PGUP     2703
#define VK_A_LEFT     2704
#define VK_A_RIGHT    2705
#define VK_A_END      2706
#define VK_A_DOWN     2707
#define VK_A_PGDN     2708
#define VK_A_INS      2709
#define VK_A_DEL      2710

#define VK_A_F1       2801
#define VK_A_F2       2802
#define VK_A_F3       2803
#define VK_A_F4       2804
#define VK_A_F5       2805
#define VK_A_F6       2806
#define VK_A_F7       2807
#define VK_A_F8       2808
#define VK_A_F9       2809
#define VK_A_F10      2810
#define VK_A_F11      2811
#define VK_A_F12      2812

#define VK_A_LBUTT    2901
#define VK_A_RBUTT    2902
#define VK_A_MBUTT    2904
#define VK_A_LRBUTT   2903
#define VK_A_2BUTT    2903
#define VK_A_LMBUTT   2905
#define VK_A_RMBUTT   2906
#define VK_A_LRMBUTT  2907
#define VK_A_3BUTT    2907

#define VK_C_TAB      3001

#define VK_C_NUMDIV   3201
#define VK_C_NUMMUL   3202
#define VK_C_NUMMIN   3203
#define VK_C_NUMPLS   3204

#define VK_C_HOME     3701
#define VK_C_UP       3702
#define VK_C_PGUP     3703
#define VK_C_LEFT     3704
#define VK_C_RIGHT    3705
#define VK_C_END      3706
#define VK_C_DOWN     3707
#define VK_C_PGDN     3708
#define VK_C_INS      3709
#define VK_C_DEL      3710

#define VK_C_F1       3801
#define VK_C_F2       3802
#define VK_C_F3       3803
#define VK_C_F4       3804
#define VK_C_F5       3805
#define VK_C_F6       3806
#define VK_C_F7       3807
#define VK_C_F8       3808
#define VK_C_F9       3809
#define VK_C_F10      3810
#define VK_C_F11      3811
#define VK_C_F12      3812

#define VK_C_LBUTT    3901
#define VK_C_RBUTT    3902
#define VK_C_MBUTT    3904
#define VK_C_LRBUTT   3903
#define VK_C_2BUTT    3903
#define VK_C_LMBUTT   3905
#define VK_C_RMBUTT   3906
#define VK_C_LRMBUTT  3907
#define VK_C_3BUTT    3907

#define VK_S_TAB      4001

#define VK_S_F1       4801
#define VK_S_F2       4802
#define VK_S_F3       4803
#define VK_S_F4       4804
#define VK_S_F5       4805
#define VK_S_F6       4806
#define VK_S_F7       4807
#define VK_S_F8       4808
#define VK_S_F9       4809
#define VK_S_F10      4810
#define VK_S_F11      4811
#define VK_S_F12      4812

#define VK_S_LBUTT    4901
#define VK_S_RBUTT    4902
#define VK_S_MBUTT    4904
#define VK_S_LRBUTT   4903
#define VK_S_2BUTT    4903
#define VK_S_LMBUTT   4905
#define VK_S_RMBUTT   4906
#define VK_S_LRMBUTT  4907
#define VK_S_3BUTT    4907

/* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³  .INI HANDLING                                                        ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

boolean  fexists(char *filename);
int      ReadIniString(char *, char *, char *, char *, int, char *);
int      ReadIniInt(char *,    char *, int,    char *);
float    ReadIniFloat(char *,  char *, float,  char *);

int WriteIniString(char *Section, char *Key, char *Value,  char *IniFile);
int WriteIniInt(char *Section,    char *Key, int  Value,   char *IniFile);
int WriteIniFloat(char *Section,  char *Key, float Value,  char *IniFile);


/* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³  BORDERS HANDLING                                                     ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

/*
        ÚÄÄÄ¿        ÉÍÍÍ»        ÕÍÍÍ¸        ÖÄÄÄ·
        ³   ³        º   º        ³   ³        º   º
        ³   ³        º   º        ³   ³        º   º
        ÀÄÄÄÙ        ÈÍÍÍ¼        ÔÍÍÍ¾        ÓÄÄÄ½
     SINGLE_LINE  DOUBLE_LINE  DOUBLE_TOP   DOUBLE_SIDE
*/

#define HORIZ_DIR     0
#define VERT_DIR      1

#define SINGLE_LINE   0
#define DOUBLE_LINE   1
#define SHADOW_LINE   2
#define DOUBLE_TOP    8
#define DOUBLE_SIDE   9

void DrawLine(int, int, int, int, int);
void DrawBorder(int, int, int, int, int);

/* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³  SPECIAL WINDOWS                                                      ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

int MessageBox(char *Title, char *Message, int Type, int Text, int Border);



#ifndef TOOLKIT_NO_GRAPHICS

/* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³  STRING EDITOR (GRAPHICAL)                                            ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

void SE_show_string(int x, int y, char *editstr, int pos, int maxdisplay,
                    int col_fore);
void SE_show_cursor(int x, int y, int pos, int maxdisplay,int col_curs);
void SE_erase_all(int x, int y, int maxlen, int col_back);

/* returns VK_ENTER or VK_ESC */
int stredit(int x, int y, char *editstr, int maxlen, int maxdisplay,
            int col_fore, int col_back, int col_curs);

/* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³  LIST PICKER   (GRAPHICAL)                                            ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

int listpick(int w, int h, char *title, char *filename, char *returned,
             int color_fore, int color_back, int color_border, int color_hilite);

#endif
