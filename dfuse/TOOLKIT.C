#include "toolkit.h"

/* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³  GLOBALS                                                              ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

boolean MousePresent;
boolean BeepingKeys ;

/* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³  MISCELLANEOUS ROUTINES                                               ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

void Beep(int frequency, int duration_ms)
{
 sound(frequency);
 delay(duration_ms);
 nosound();
}

void Bip()                                      /* also used for BeepingKeys */
{
 Beep(2000,1);                         
}

/* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³  MOUSE HANDLING                                                       ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

void InitMouseDriver()
{
 union  REGS  regs;

 regs.x.ax = 0;
 int86(MOUSEINT, &regs, &regs);
 if (regs.x.ax == 0xffff)
  MousePresent = TRUE;
 else
  MousePresent = FALSE;
}

void ShowMousePointer()
{
 union REGS regs;
 if(MousePresent == TRUE)
  {
   regs.x.ax = 1;
   int86(MOUSEINT, &regs, &regs);
  }
}

void HideMousePointer()
{
 union REGS regs;

 if(MousePresent == TRUE)
  {
   regs.x.ax = 2;
   int86(MOUSEINT, &regs, &regs);
  }
}

void GetMouseButtons(int *buttons)
{
 union REGS regs;

 if(MousePresent == TRUE)
  {
   regs.x.ax = 3;
   int86(MOUSEINT, &regs, &regs);
   *buttons = regs.x.bx;
  }
 else
  *buttons = 0;
}

void GetMousePos(int *x, int *y)
{
 union REGS regs;

 if(MousePresent == TRUE)
  {
   regs.x.ax = 3;
   int86(MOUSEINT, &regs, &regs);
   *x = regs.x.cx;
   *y = regs.x.dx;
  }
 else
  {
   *x = -1;
   *y = -1;
  }
}

void GetMouseTextPos(int *x, int *y)
{
 union REGS regs;

 if(MousePresent == TRUE)
  {
   regs.x.ax = 3;
   int86(MOUSEINT, &regs, &regs);
   *x = regs.x.cx / 8 + 1;
   *y = regs.x.dx / 8 + 1;
  }
 else
  {
   *x = -1;
   *y = -1;
  }
}

void SetMousePos(int x, int y)
{
 union REGS regs;

 if(MousePresent == TRUE)
  {
   regs.x.ax = 4;
   regs.x.cx = (unsigned) x;
   regs.x.dx = (unsigned) y;
   int86(MOUSEINT, &regs, &regs);
  }
}

void SetMouseTextPos(int x, int y)
{
  SetMousePos(8 * (x-1), 8 * (y-1));
}

void ClipMouse(int left, int top, int right, int bottom)
{
 union REGS regs;

 if(MousePresent == TRUE)
  {
   regs.x.ax = 7;
   regs.x.cx = (unsigned) left;
   regs.x.dx = (unsigned) right;
   int86(MOUSEINT, &regs, &regs);
   regs.x.ax = 8;
   regs.x.cx = (unsigned) top;
   regs.x.dx = (unsigned) bottom;
   int86(MOUSEINT, &regs, &regs);
  }
}

void ClipMouseText(int left, int top, int right, int bottom)
{
 ClipMouse((left-1) * 8, (top-1) * 8,(right-1) * 8, (bottom-1) * 8);
}

void UnClipMouseText()
{
 ClipMouseText(1,1,80,25);
}

int mousehit()
{
 int buttons;

 GetMouseButtons(&buttons);
 return(buttons == 0 ? 0 : buttons);
}


/* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³  JOYSTICK HANDLING                                                    ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

#ifdef TOOLKIT_JOYSTICK
void GetJoy1Buttons(BYTE *j1b1, BYTE *j1b2)
{
 union REGS regs;

 regs.h.ah = 0x84;
 regs.x.dx = 0;
 int86(JOYINT, &regs, &regs);
 *j1b1 = (( regs.h.al &  16 ) >> 4) ^ 1;        /* Bit 4 de AL = J1B1 */
 *j1b2 = (( regs.h.al &  32 ) >> 5) ^ 1;        /* Bit 5 de AL = J1B2 */
}

void GetJoy2Buttons(BYTE *j2b1, BYTE *j2b2)
{
 union REGS regs;

 regs.h.ah = 0x84;
 regs.x.dx = 0;
 int86(JOYINT, &regs, &regs);
 *j2b1 = (( regs.h.al &  64 ) >> 6) ^ 1;        /* Bit 6 de AL = J2B1 */
 *j2b2 = (( regs.h.al & 128 ) >> 7) ^ 1;        /* Bit 7 de AL = J2B2 */
}

void GetJoysButtons( BYTE *j1b1, BYTE *j1b2, BYTE *j2b1, BYTE *j2b2 )
{
 union REGS regs;

 regs.h.ah = 0x84;
 regs.x.dx = 0;
 int86(JOYINT, &regs, &regs);
 *j1b1 = (( regs.h.al &  16 ) >> 4) ^ 1;        /* Bit 4 de AL = J1B1 */
 *j1b2 = (( regs.h.al &  32 ) >> 5) ^ 1;        /* Bit 5 de AL = J1B2 */
 *j2b1 = (( regs.h.al &  64 ) >> 6) ^ 1;        /* Bit 6 de AL = J2B1 */
 *j2b2 = (( regs.h.al & 128 ) >> 7) ^ 1;        /* Bit 7 de AL = J2B2 */
}

void GetJoy1Pos(int *j1x, int *j1y)
{
 union REGS regs;

 regs.h.ah = 0x84;
 regs.x.dx = 1;
 int86(JOYINT, &regs, &regs);
 *j1x = regs.x.ax;                           /* Position X Joystick 1 */
 *j1y = regs.x.bx;                           /* Position Y Joystick 1 */
}

void GetJoy2Pos(int *j2x, int *j2y)
{
 union REGS regs;

 regs.h.ah = 0x84;
 regs.x.dx = 1;
 int86(JOYINT, &regs, &regs);
 *j2x = regs.x.cx;                           /* Position X Joystick 2 */
 *j2y = regs.x.dx;                           /* Position Y Joystick 2 */
}

void GetJoysPos(int *j1x, int *j1y, int *j2x, int *j2y)
{
 union REGS regs;

 regs.h.ah = 0x84;
 regs.x.dx = 1;
 int86(JOYINT, &regs, &regs);
 *j1x = regs.x.ax;                           /* Position X Joystick 1 */
 *j1y = regs.x.bx;                           /* Position Y Joystick 1 */
 *j2x = regs.x.cx;                           /* Position X Joystick 2 */
 *j2y = regs.x.dx;                           /* Position Y Joystick 2 */
}


int joy1hit()
{
 BYTE b11,b12;

 GetJoy1Buttons(&b11, &b12);
 return(b11|b12);
}

int joy2hit()
{
 BYTE b21,b22;

 GetJoy2Buttons(&b21, &b22);
 return(b21|b22);
}

int joyshit()
{
 BYTE b11,b12,b21,b22;

 GetJoysButtons(&b11, &b12, &b21, &b22);
 return(b11|b12|b21|b22);
}
#endif

/* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³  CURSOR HANDLING                                                      ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

void HideCursor()
{
 _setcursortype(_NOCURSOR);
}

void NormalCursor()
{
 _setcursortype(_NORMALCURSOR);
}

void BlockCursor()
{
 _setcursortype(_SOLIDCURSOR);
}

/* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³  VIRTUAL KEYBOARD HANDLING                                            ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

int VKhit()
{
 return(kbhit() || mousehit());
}

void VKwait()
{
 while(!VKhit());
 if(kbhit()) getVK();
}

int getVK()
{
 int       c;
 int       shifts;
 int       toadd;

 while(!kbhit() && !(c=mousehit())) ;              /* we have buttons in c ! */

 if(!kbhit())                     /* this will give priority to the KEYBOARD */
 {
  shifts = bioskey(2);                                     /* get shift keys */
  toadd                = 0;
  if(shifts & 8) toadd = 1000;                      /* ALT    key is pressed */
  if(shifts & 4) toadd = 2000;                      /* CTRL   key is pressed */
  if(shifts & 2) toadd = 3000;                      /* R SHFT key is pressed */
  if(shifts & 1) toadd = 3000;                      /* L SHFT key is pressed */
                                       /* priority to SHFT over CTLR and ALT */

  c &= 7;
  switch(c)
   {
    case 1   : return(toadd + VK_LBUTT);
    case 2   : return(toadd + VK_RBUTT);
    case 3   : return(toadd + VK_2BUTT);
    case 4   : return(toadd + VK_MBUTT);
    case 5   : return(toadd + VK_LMBUTT);
    case 6   : return(toadd + VK_RMBUTT);
    case 7   : return(toadd + VK_3BUTT);

    default  : return(VK_UNKNOWN);
   }
 }

 if(BeepingKeys) Bip();
 c = getch();
 if(c != 0)
  {
   /* Implementation des ^K A, ... … la Borland
   if(c == VK_C_K)
    {
     c=getch();
     if(c==0) c=getch();
     c += 5000;
    }
   */
   return(c);
  }
 else
  {
   c = getch();
   switch(c)
    {
     case   1 : return(VK_A_ESC);

     case  14 : return(VK_A_BACKSPC);
     case  15 : return(VK_S_TAB);
     case  16 : return(VK_A_Q);     /* this is also AltGr A */
     case  17 : return(VK_A_W);     /* this is also AltGr Z */
     case  18 : return(VK_A_E);
     case  19 : return(VK_A_R);
     case  20 : return(VK_A_T);
     case  21 : return(VK_A_Y);
     case  22 : return(VK_A_U);
     case  23 : return(VK_A_I);
     case  24 : return(VK_A_O);
     case  25 : return(VK_A_P);

     case  28 : return(VK_A_RETURN);

     case  30 : return(VK_A_A);     /* this is also AltGr Q */
     case  31 : return(VK_A_S);
     case  32 : return(VK_A_D);
     case  33 : return(VK_A_F);
     case  34 : return(VK_A_G);
     case  35 : return(VK_A_H);
     case  36 : return(VK_A_J);
     case  37 : return(VK_A_K);
     case  38 : return(VK_A_L);
     case  39 : return(VK_A_M);

     case  44 : return(VK_A_Z);     /* this is also AltGr W */
     case  45 : return(VK_A_X);
     case  46 : return(VK_A_C);
     case  47 : return(VK_A_V);
     case  48 : return(VK_A_B);
     case  49 : return(VK_A_N);

     case  55 : return(VK_A_NUMMUL);

     case  59 : return(VK_F1);
     case  60 : return(VK_F2);
     case  61 : return(VK_F3);
     case  62 : return(VK_F4);
     case  63 : return(VK_F5);
     case  64 : return(VK_F6);
     case  65 : return(VK_F7);
     case  66 : return(VK_F8);
     case  67 : return(VK_F9);
     case  68 : return(VK_F10);

     case  71 : return(VK_HOME);
     case  72 : return(VK_UP);
     case  73 : return(VK_PGUP);
     case  74 : return(VK_A_NUMMIN);
     case  75 : return(VK_LEFT);
     case  77 : return(VK_RIGHT);
     case  78 : return(VK_A_NUMPLS);
     case  79 : return(VK_END);
     case  80 : return(VK_DOWN);
     case  81 : return(VK_PGDN);
     case  82 : return(VK_INS);
     case  83 : return(VK_DEL);
     case  84 : return(VK_S_F1);
     case  85 : return(VK_S_F2);
     case  86 : return(VK_S_F3);
     case  87 : return(VK_S_F4);
     case  88 : return(VK_S_F5);
     case  89 : return(VK_S_F6);
     case  90 : return(VK_S_F7);
     case  91 : return(VK_S_F8);
     case  92 : return(VK_S_F9);
     case  93 : return(VK_S_F10);
     case  94 : return(VK_C_F1);
     case  95 : return(VK_C_F2);
     case  96 : return(VK_C_F3);
     case  97 : return(VK_C_F4);
     case  98 : return(VK_C_F5);
     case  99 : return(VK_C_F6);
     case 100 : return(VK_C_F7);
     case 101 : return(VK_C_F8);
     case 102 : return(VK_C_F9);
     case 103 : return(VK_C_F10);
     case 104 : return(VK_A_F1);
     case 105 : return(VK_A_F2);
     case 106 : return(VK_A_F3);
     case 107 : return(VK_A_F4);
     case 108 : return(VK_A_F5);
     case 109 : return(VK_A_F6);
     case 110 : return(VK_A_F7);
     case 111 : return(VK_A_F8);
     case 112 : return(VK_A_F9);
     case 113 : return(VK_A_F10);

     case 115 : return(VK_C_LEFT);
     case 116 : return(VK_C_RIGHT);
     case 117 : return(VK_C_END);
     case 118 : return(VK_C_PGDN);
     case 119 : return(VK_C_HOME);
     case 120 : return(VK_A_1);
     case 121 : return(VK_A_2);
     case 122 : return(VK_A_3);
     case 123 : return(VK_A_4);
     case 124 : return(VK_A_5);
     case 125 : return(VK_A_6);
     case 126 : return(VK_A_7);
     case 127 : return(VK_A_8);
     case 128 : return(VK_A_9);
     case 129 : return(VK_A_0);

     case 132 : return(VK_C_PGUP);
     case 133 : return(VK_F11);
     case 134 : return(VK_F12);
     case 135 : return(VK_S_F11);
     case 136 : return(VK_S_F12);
     case 137 : return(VK_C_F11);
     case 138 : return(VK_C_F12);
     case 139 : return(VK_A_F11);
     case 140 : return(VK_A_F12);
     case 141 : return(VK_C_UP);
     case 142 : return(VK_C_NUMMIN);

     case 144 : return(VK_C_NUMPLS);
     case 145 : return(VK_C_DOWN);
     case 146 : return(VK_C_INS);
     case 147 : return(VK_C_DEL);
     case 148 : return(VK_C_TAB);
     case 149 : return(VK_C_NUMDIV);
     case 150 : return(VK_C_NUMMUL);
     case 151 : return(VK_A_HOME);
     case 152 : return(VK_A_UP);
     case 153 : return(VK_A_PGUP);

     case 155 : return(VK_A_LEFT);

     case 157 : return(VK_A_RIGHT);

     case 159 : return(VK_A_END);
     case 160 : return(VK_A_DOWN);
     case 161 : return(VK_A_PGDN);
     case 162 : return(VK_A_INS);
     case 163 : return(VK_A_DEL);
     case 164 : return(VK_A_NUMDIV);
     case 165 : return(VK_A_TAB);
     case 166 : return(VK_A_NUMENT);

     default  : return(VK_UNKNOWN);
    }
  }
}


/* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³  .INI HANDLING                                                        ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

boolean fexists(char *filename)
{
 if(access(filename,0)!=0)
  return(FALSE);
 else
  return(TRUE);
}

int ReadIniString(char *Section,
                  char *Key,
                  char *Default,
                  char *Returned,
                  int  Size,
                  char *IniFile)
{
  FILE     *ini;
  char     buf1[256];
  char     section2[82];
  boolean  secfound;
  char     key2[82];
  int      slen;

  if(fexists(IniFile) == FALSE)
   {
    /* printf("%s doesn't exist! \n", IniFile); */
    strcpy(Returned, Default);
    return(0);
   };

  ini = fopen(IniFile , "rt");
  secfound = FALSE;

  strcpy(section2, "[");
  strcat(section2, Section);
  strcat(section2, "]");

  strcpy(key2 , Key);
  strcat(key2 , "=");
  slen = strlen(key2);

  while(fgets(buf1, 255, ini) != NULL)
   {
    buf1[strlen(buf1)-1] = '\0'; /* fgets brings back CRLF */
    if((secfound) && (strncmp(key2,buf1,slen) == 0))
     {
      /* printf("*** Found Searched Value *** : %s\n", &(buf1[slen])); */
      strncpy(Returned, &(buf1[slen]), Size-1);
      fclose(ini);
      return(strlen(Returned));
     }

    if(buf1[0] == '[')
     {
      if(strcmp(buf1, section2) == 0)
        secfound = TRUE;
      else /* find section, but not key then MAY find key in next sections */
        secfound = FALSE;
     };
   };
  strcpy(Returned, Default);
  fclose(ini);
  return(0);
}


int ReadIniInt(char *Section,
               char *Key,
               int  Default,
               char *IniFile)
{
 char the_int[20];
 char def[20];

 sprintf(def, "%d", Default);
 if(ReadIniString(Section, Key, def, the_int, 20, IniFile) !=0 )
   return(atoi(the_int));
 else
   return(Default);
}

float    ReadIniFloat(char *Section, char *Key, float Default, char *IniFile)
{
 char the_float[20];
 char def[20];

 sprintf(def, "%f", Default);
 if(ReadIniString(Section, Key, def, the_float, 20, IniFile) !=0 )
   return(atof(the_float));
 else
   return(Default);
}

int WriteIniString(char *Section,
                   char *Key,
                   char *Value,
                   char *IniFile)
{
  FILE     *ini;
  FILE     *dollars;
  char     Dollars[127];
  char     buf1[256];
  char     section2[82];
  boolean  secfound = FALSE;
  int      line = 0;
  int      atline = -1;
  int      out  = 0;
  char     key2[82];
  int      slen;

  if(fexists(IniFile) == FALSE)
   {
    /* create the file, the section and the key */
    ini = fopen(IniFile , "wt");
    strcpy(section2, "[");
    strcat(section2, Section);
    strcat(section2, "]\n");
    fputs(section2, ini);
    strcpy(section2, Key);
    strcat(section2, "=");
    strcat(section2, Value);
    strcat(section2, "\n");
    fputs(section2, ini);
    fclose(ini);
    return(0);
   };

  /* open the file in read! mode */
  ini = fopen(IniFile , "rt");

  secfound = FALSE;

  strcpy(section2, "[");
  strcat(section2, Section);
  strcat(section2, "]");
  strcpy(key2 , Key);
  strcat(key2 , "=");
  slen = strlen(key2);

  while( (fgets(buf1, 255, ini) != NULL) && (out == 0))
   {
    line++;
    buf1[strlen(buf1)-1] = '\0'; /* fgets brings back CRLF */
    if((secfound) && (strncmp(key2,buf1,slen) == 0))
     {
      atline = line - 1;
      out    = 2;
     }

    if(buf1[0] == '[')
     {
      if(strcmp(buf1, section2) == 0)
       {
        secfound = TRUE;
        atline = line;
       }
      else /* found another section */
       {
        if(secfound == TRUE) /* if we did find the correct one */
         {
          out = 1;
         }
       }
     };
   };

  if((secfound == TRUE) && (out == 0)) out = 1; /* section was last one */

  fclose(ini);

  /* Now, if out == 0 nothing was found
                    1 section was found but not item
                    2 section and item where found    */

  /* if out == 0                                      */
  /* read .ini and copy to .$$$ until eof             */
  /* write [section]                                  */
  /* write key=value                                  */
  /* if all is well, delete .ini and rename .$$$      */

  /* if out != 0                                      */
  /* read .ini and copy to .$$$ until line 'atline'   */
  /* write key=value                                  */
  /* read .ini and copy to .$$$ until eof             */
  /* if all is well, delete .ini and rename .$$$      */

  strcpy(Dollars, IniFile);
  Dollars[strlen(Dollars)-1] = '$';
  Dollars[strlen(Dollars)-2] = '$';
  Dollars[strlen(Dollars)-3] = '$';

  ini     = fopen(IniFile , "rt");
  dollars = fopen(Dollars , "wt");

  if(out == 0)
   {
    while(fgets(buf1, 255, ini) != NULL)
     {
      fputs(buf1, dollars);
     }
    fputs("\n", dollars);
    strcpy(section2, "[");
    strcat(section2, Section);
    strcat(section2, "]\n");
    fputs(section2, dollars);
    strcpy(section2, Key);
    strcat(section2, "=");
    strcat(section2, Value);
    strcat(section2, "\n");
    fputs(section2, dollars);
    fclose(ini);
    fclose(dollars);
   }
  else
   {
    line = 0;
    while( (fgets(buf1, 255, ini) != NULL) && (line < atline))
     {
      fputs(buf1, dollars);
      line++;
     }
    strcpy(section2, Key);
    strcat(section2, "=");
    strcat(section2, Value);
    strcat(section2, "\n");
    fputs(section2, dollars);
    /* must not put oldvalue if replaced, but well if added */
    if(out == 1)  fputs(buf1, dollars);
    while(fgets(buf1, 255, ini) != NULL)
     {
      fputs(buf1, dollars);
     }
    fclose(ini);
    fclose(dollars);
   }

  remove(IniFile);
  rename(Dollars, IniFile);

  return(0);
}


int WriteIniInt(char *Section,
                char *Key,
                int  Value,
                char *IniFile)
{
 char the_int[20];

 sprintf(the_int, "%d", Value);
 WriteIniString(Section, Key, the_int, IniFile);
 return(0);
}

int WriteIniFloat(char *Section,
                  char *Key,
                  float Value,
                  char *IniFile)
{
 char the_float[20];

 sprintf(the_float, "%f", Value);
 WriteIniString(Section, Key, the_float, IniFile);
 return(0);
}



/* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³  BORDERS HANDLING                                                     ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */


void DrawLine(int left, int top, int len, int ltype, int hv)
{
 int            old_wscroll;
 unsigned char  buf[160];
 int            i;

 old_wscroll = _wscroll;
 _wscroll    = 0;

  if(hv == HORIZ_DIR)
   {
    switch(ltype)
     {
      case SINGLE_LINE : memset(buf, 'Ä', len);
                         break;
      case DOUBLE_LINE : memset(buf, 'Í', len);
                         break;
      case SHADOW_LINE : memset(buf, 'Û', len);
                         break;
      default          : memset(buf, 'Ä', len);
     }
     buf[len] = '\0';
     gotoxy(left, top);
     cputs(buf);
   }
  else
   {
    for(i=0;i<len;i++)
     {
      gotoxy(left, top+i);
      switch(ltype)
       {
        case SINGLE_LINE : cputs("³");
                           break;
        case DOUBLE_LINE : cputs("º");
                           break;
        case SHADOW_LINE : cputs("Û");
                           break;
        default          : cputs("³");
       }
     }
   }
 _wscroll    = old_wscroll;
}

void DrawBorder(int left, int top, int right, int bottom, int ltype)
{
 int      old_wscroll;

 old_wscroll = _wscroll;
 _wscroll    = 0;

 switch(ltype)
  {
   case SINGLE_LINE : DrawLine(left,  top,    right-left+1, ltype, HORIZ_DIR);
                      DrawLine(left,  bottom, right-left+1, ltype, HORIZ_DIR);
                      DrawLine(left,  top,    bottom-top+1, ltype, VERT_DIR);
                      DrawLine(right, top,    bottom-top+1, ltype, VERT_DIR);
                      gotoxy(left, top);
                      cputs("Ú");
                      gotoxy(right, top);
                      cputs("¿");
                      gotoxy(left, bottom);
                      cputs("À");
                      gotoxy(right, bottom);
                      cputs("Ù");
                      break;
   case DOUBLE_LINE : DrawLine(left,  top,    right-left+1, ltype, HORIZ_DIR);
                      DrawLine(left,  bottom, right-left+1, ltype, HORIZ_DIR);
                      DrawLine(left,  top,    bottom-top+1, ltype, VERT_DIR);
                      DrawLine(right, top,    bottom-top+1, ltype, VERT_DIR);
                      gotoxy(left, top);
                      cputs("É");
                      gotoxy(right, top);
                      cputs("»");
                      gotoxy(left, bottom);
                      cputs("È");
                      gotoxy(right, bottom);
                      cputs("¼");
                      break;
   case DOUBLE_TOP  : DrawLine(left,  top,    right-left+1, DOUBLE_LINE, HORIZ_DIR);
                      DrawLine(left,  bottom, right-left+1, DOUBLE_LINE, HORIZ_DIR);
                      DrawLine(left,  top,    bottom-top+1, SINGLE_LINE, VERT_DIR);
                      DrawLine(right, top,    bottom-top+1, SINGLE_LINE, VERT_DIR);
                      gotoxy(left, top);
                      cputs("Õ");
                      gotoxy(right, top);
                      cputs("¸");
                      gotoxy(left, bottom);
                      cputs("Ô");
                      gotoxy(right, bottom);
                      cputs("¾");
                      break;
   case DOUBLE_SIDE : DrawLine(left,  top,    right-left+1, SINGLE_LINE, HORIZ_DIR);
                      DrawLine(left,  bottom, right-left+1, SINGLE_LINE, HORIZ_DIR);
                      DrawLine(left,  top,    bottom-top+1, DOUBLE_LINE, VERT_DIR);
                      DrawLine(right, top,    bottom-top+1, DOUBLE_LINE, VERT_DIR);
                      gotoxy(left, top);
                      cputs("Ö");
                      gotoxy(right, top);
                      cputs("·");
                      gotoxy(left, bottom);
                      cputs("Ó");
                      gotoxy(right, bottom);
                      cputs("½");
                      break;
   default          : DrawLine(left,  top,    right-left+1, SINGLE_LINE, HORIZ_DIR);
                      DrawLine(left,  bottom, right-left+1, SINGLE_LINE, HORIZ_DIR);
                      DrawLine(left,  top,    bottom-top+1, SINGLE_LINE, VERT_DIR);
                      DrawLine(right, top,    bottom-top+1, SINGLE_LINE, VERT_DIR);
                      gotoxy(left, top);
                      cputs("Ú");
                      gotoxy(right, top);
                      cputs("¿");
                      gotoxy(left, bottom);
                      cputs("À");
                      gotoxy(right, bottom);
                      cputs("Ù");
  }

 _wscroll    = old_wscroll;
}

/* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³  SPECIAL WINDOWS                                                      ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

#define MB_CANCEL      0
#define MB_OK          1

int MessageBox(char *Title, char *Message, int Type, int Text, int Border)
{
 char buffer[8192];
 char title[77];
 char message[77];
 int  len;
 int  i,j;
 struct text_info t_info;
 int  Left, Top, Right, Bottom;

 len = Type; /* bogus, just to avoid Type never used ... */

 strncpy(title,   Title,   76);
 title[76] = '\0';
 strncpy(message, Message, 76);
 message[76] = '\0';
 len = strlen(title) > strlen(message) ? strlen(title) : strlen(message);
 len += 4;
 len--;

 if(len < 13) len = 13;  /* depending on type in fact */

 gettextinfo(&t_info);
 Left   = (t_info.winright - t_info.winleft - len) / 2;
 Right  = Left + len;
 Top    = (t_info.winbottom - t_info.wintop - 4) / 2;
 Bottom = Top + 4;

 HideMousePointer();
 gettext(Left, Top, Right, Bottom, buffer);
 textattr(Border);
 DrawBorder(Left, Top, Right, Bottom, DOUBLE_LINE);
 gotoxy(Left+(Right-Left-strlen(title))/2, Top);
 cprintf(" %s ",title);

 textattr(Text);
 for(i=Left+1;i<Right;i++)
  for(j=Top+1;j<Bottom;j++)
   {
    gotoxy(i,j);
    cputs(" ");
   }
 gotoxy(Left+2, Top+1);
 cputs(message);

 ShowMousePointer();
 getVK();
 puttext(Left, Top, Right, Bottom, buffer);

 return(0);
}



#ifndef TOOLKIT_NO_GRAPHICS

/* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³  STRING EDITOR (GRAPHICAL)                                            ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */


void SE_show_string(int x, int y, char *editstr, int pos, int maxdisplay,
                    int col_fore)
{
   int cur_color;
   int win;
   char wrkstr[128];

   cur_color = getcolor();
   setcolor(col_fore);

   if(pos < maxdisplay+1)
    {
     strcpy(wrkstr, editstr);
     wrkstr[maxdisplay+1] = '\0';
     outtextxy(x,y, wrkstr);
    }
   else
    {
     win = pos;
     while(win > maxdisplay) win = win - maxdisplay;
     strcpy(wrkstr, &(editstr[win]));
     wrkstr[maxdisplay+1] = '\0';
     outtextxy(x,y, wrkstr);
    }
   setcolor(cur_color);
}

void SE_show_cursor(int x, int y, int pos, int maxdisplay,int col_curs)
  {
   int cur_color;
   int clines;
   int cpos;

   if(pos < maxdisplay)
    {
     cpos = pos;
    }
   else
    {
     cpos = maxdisplay;
    }

   cur_color = getcolor();
   setcolor(col_curs);
   setwritemode(XOR_PUT);
   for(clines=0;clines<8;clines++)
    {
     moveto(x+cpos*8,   y+7-clines);
     lineto(x+cpos*8+7, y+7-clines);
    }
   setwritemode(COPY_PUT);
   setcolor(cur_color);
  }

void SE_erase_all(int x, int y, int maxlen, int col_back)
{
  int cur_color;
  int  i,j;

  cur_color = getcolor();
  for(i=0;i<maxlen*8;i++)
   for(j=0;j<8;j++)
    {
     putpixel(x+ i, y + j, col_back);
    }
  setcolor(cur_color);
}

int stredit(int x, int y, char *editstr, int maxlen, int maxdisplay,
            int col_fore, int col_back, int col_curs)
{
 int pos;
 int len;
 int ccc;
 char bidon[5];
 int  i,j;
 char wrkstr[128];
 char restorestr[128];

 if(maxlen > 127) maxlen = 127;
 strcpy(restorestr, editstr);

 pos = strlen(editstr);
 len = strlen(editstr);

 SE_erase_all(x, y, maxdisplay, col_back);
 setcolor(col_fore);
 outtextxy(x,y,editstr);
 SE_show_cursor(x, y, pos, maxdisplay-1, col_curs);

 ccc = getVK();
 while((ccc != VK_ESC) && (ccc != VK_ENTER))
  {
   SE_show_cursor(x, y, pos, maxdisplay-1, col_curs);
   SE_erase_all(x, y, maxdisplay, col_back);
   switch(ccc)
    {
     case VK_BACKSPACE :
                 if(pos>0)
                 {
                  strncpy(wrkstr, editstr, pos-1);
                  wrkstr[pos-1] = '\0';
                  strcat(wrkstr, &(editstr[pos]));
                  strcpy(editstr, wrkstr);
                  len--;
                  editstr[len] = '\0';
                  pos--;
                 }
                 else Bip();
                 break;
     case VK_DEL :
                 if(pos<len)
                 {
                  strncpy(wrkstr, editstr, pos);
                  wrkstr[pos] = '\0';
                  strcat(wrkstr, &(editstr[pos+1]));
                  strcpy(editstr, wrkstr);
                  len--;
                  editstr[len] = '\0';
                 }
                 else Bip();
                 break;
     case VK_C_Y :
                  pos = 0;
                  len = 0;
                  strcpy(editstr, "");
                 break;
     case VK_C_R : /* restore original string */
                  strcpy(editstr, restorestr);
                  len = strlen(editstr);
                  pos = len;
                 break;
     case VK_HOME :
                  pos = 0;
                 break;
     case VK_END :
                  pos = len;
                 break;
     case VK_LEFT :
                 if(pos > 0)
                 {
                  pos--;
                 }
                 break;
     case VK_RIGHT :
                 if(pos < len)
                 {
                  pos++;
                 }
                 break;
     default   : if((ccc < VK_EXTENDED) && (len < maxlen))
                  {
                   strncpy(wrkstr, editstr, pos);
                   wrkstr[pos] = '\0';
                   bidon[0] = ccc;
                   bidon[1] = '\0';
                   strcat(wrkstr, bidon);
                   strcat(wrkstr, &(editstr[pos]));
                   strcpy(editstr, wrkstr);
                   len++;
                   pos++;
                  }
                 else Bip();
    }
   SE_show_string(x, y, editstr, pos, maxdisplay-1, col_fore);
   /* outtextxy(x,y,editstr); */
   /* show the cursor */
   SE_show_cursor(x, y, pos, maxdisplay-1, col_curs);
   ccc = getVK();
  }
  return(ccc);
}

/* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³  LIST PICKER   (GRAPHICAL)                                            ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

int listpick(int w, int h, char *title, char *filename, char *returned,
             int color_fore, int color_back, int color_border, int color_hilite)
{
 char  *buffer;
 int   nbitems  = 0;
 int   selected = 0;
 int   wi;
 int   he;
 FILE  *pf;
 int   i;
 int   top = 0;
 int   oldtop = 0;
 int   topchanged = 0;
 char  buf[255];
 char  buf2[36];
 int   ccc;

 cleardevice();
 setcolor(color_border);
 rectangle((getmaxx()-w)/2,   (getmaxy()-h)/2,
           (getmaxx()-w)/2+w, (getmaxy()-h)/2+h);
 setfillstyle(SOLID_FILL, color_back);
 floodfill((getmaxx()-w)/2+10,(getmaxy()-h)/2+10, color_border);
 moveto((getmaxx()-w)/2,   (getmaxy()-h)/2 + 20);
 lineto((getmaxx()-w)/2+w, (getmaxy()-h)/2 + 20);
 strcpy(buf, title);
 buf[36] = '\0';
 strcpy(buf2,"");
 for(i=0; i< (1+36-strlen(buf))/2; i++) strcat(buf2," ");
 strcpy(buf, buf2);
 strcat(buf, title);
 buf[38] = '\0';
 setcolor(color_fore);
 outtextxy((getmaxx()-w)/2+4, (getmaxy()-h)/2 + 8, buf);


 wi = (w-8) / 8;
 he = (h-30) / 9;
 /* count the items */
 pf = fopen(filename , "rt");
 while(fgets(buf, wi, pf) != NULL)
  {
   nbitems++;
  }
 fclose(pf);

 if(nbitems == 0)
  {
   strcpy(returned, "");
   return(-1);
  }

 if((buffer = (char *) farcalloc( (long) ((long)(wi+1)*(long)nbitems) ,1)) == NULL)
  {
   restorecrtmode();
   printf("\n\nCannot allocate buffer for picklist (%ld). Aborting...\n", (long)((wi+1)*nbitems));
   exit(1);
  };
 i=0;
 pf = fopen(filename , "rt");
 while(fgets(buf, 255, pf) != NULL)
  {
   buf[wi] = '\0';
   buf[strlen(buf)-1] = '\0';
   if(strlen(buf) > 0)
    {
     strcpy(&(buffer[i*(wi+1)]), buf);
     i++;
    }
  }
 fclose(pf);
 nbitems = i;

 ccc = 0;
 do
  {
   oldtop = top;
   switch(ccc)
    {
     case VK_DOWN : selected++;
                    if(selected > nbitems-1) selected--;
                    if(selected > he-1)
                      {
                       topchanged = 1;
                       selected--;
                       if(top + he < nbitems) top++;
                      }
                    break;
     case VK_UP   : selected--;
                    if(selected < 0)
                      {
                       topchanged = 1;
                       selected++;
                       if(top > 0) top--;
                      }
                    break;
     case VK_PGDN : top += he;
                    if(top + he >= nbitems) top = nbitems - he ;
                    if(top < 0) top = 0;
                    topchanged = 1;
                    break;
     case VK_PGUP : top -= he;
                    if(top < 0) top = 0;
                    topchanged = 1;
                    break;
     case VK_END  : top = nbitems - he;
                    if(top < 0) top = 0;
                    topchanged = 1;
                    break;
     case VK_HOME : top = 0;
                    topchanged = 1;
                    break;
    }
   /* hide previous only if necessary to avoid flicker */
   if(topchanged)
    {
     setcolor(color_back);
     for(i=0; i<he; i++)
     if(oldtop+i < nbitems)
     outtextxy((getmaxx()-w)/2+4, (getmaxy()-h)/2 + 28+9*i, &(buffer[(oldtop+i)*(wi+1)]));
     topchanged = 0;
    }
   setcolor(15);
   for(i = 0; i < he; i++)
    if(top + i < nbitems)
     {
      if(i==selected)
       setcolor(color_hilite);
      else
       setcolor(color_fore);
      outtextxy((getmaxx()-w)/2+4, (getmaxy()-h)/2 + 28+9*i, &(buffer[(top+i)*(wi+1)]));
     }
  } while(((ccc=getVK()) != VK_ESC) && (ccc != VK_ENTER));

 if(ccc == VK_ESC)
   strcpy(returned, "");
 else
   strcpy(returned, &(buffer[(top+selected)*(wi+1)]));

 farfree(buffer);

 if(ccc == VK_ESC)
   return(-1);
 else
   return(top+selected);
}


#endif

