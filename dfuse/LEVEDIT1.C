/* ========================================================================== */
/* LEVEDIT1.C : SUPPLEMENTARY EDITOR FUNCTIONS                                */
/*              * Level   data editor (beta as text, switch to graphics ASAP) */
/*              * Flags   data editor                                         */
/* ========================================================================== */
#include "levmap.h"
#include "levext.h"

/* ************************************************************************** */
/* LEVEL EDITOR FUNCTIONS                                                     */
/* ************************************************************************** */

#define LFIELDS      11

void show_level_layout(void)
{
 textattr(TX_ATTR_BACK);
 clrscr();
 textattr(TX_ATTR_TITL);
 gotoxy(1,1);
 cprintf("LEVEL DATA EDITOR (text mode beta)             ³ [F2] SAVE + EXIT ³ [Esc] ABORT ");
 textattr(TX_ATTR_BACK);
 gotoxy(3,3);
 cprintf("LEV MAP NAME........");
 gotoxy(3,5);
 cprintf("LEV VERSION......... ");

 gotoxy(43,3);
 cprintf("O MAP NAME..........");
 gotoxy(43,5);
 cprintf("O VERSION........... ");

 gotoxy(3,7);
 cprintf("PALETTE ............ ");
 gotoxy(3,9);
 cprintf("MUSIC FILE ......... ");
 gotoxy(3,11);
 cprintf("PARALLAXES ......... ");

 gotoxy(3,16);
 cprintf("AUTHOR ............. ");
}

void show_level_field(int fieldnum, int color)
{
 char tmp[127];

 textattr(color);
 switch(fieldnum)
  {
   case  0 : gotoxy(24,3);
             cprintf("%s ",    MAP_NAME);
             break;
   case  1 : gotoxy(24,5);
             cprintf("%s ",    MAP_VERSION);
             break;
   case  2 : gotoxy(64,3);
             cprintf("%s ",    MAP_NAME_O);
             break;
   case  3 : gotoxy(64,5);
             cprintf("%s ",    MAP_VERSION_O);
             break;
   case  4 : gotoxy(24,7);
             cprintf("%s ",    PAL_NAME);
             break;
   case  5 : gotoxy(24,9);
             cprintf("%s ",    MUS_NAME);
             break;
   case  6 : gotoxy(24,11);
             cprintf("%9.4f",  PARALLAX1);
             break;
   case  7 : gotoxy(40,11);
             cprintf("%9.4f",  PARALLAX2);
             break;
   case  8 : gotoxy(24,16);
             cprintf("%s ",    MAP_AUTHOR);
             break;
   case  9 : gotoxy(3,18);
             cprintf("%s ",    MAP_COMNT1);
             break;
   case 10 : gotoxy(3,19);
             cprintf("%s ",    MAP_COMNT2);
             break;
  }
}

void edit_level_field(int fieldnum)
{
 char tmp[127];

 textattr(TX_ATTR_BACK);
 gotoxy(3,25);
 cprintf("Enter new value :> ");
 BlockCursor();
 gotoxy(22,25);
 switch(fieldnum)
  {
   case  0 : cscanf("%s",    MAP_NAME);
             break;
   case  1 : cscanf("%s",    MAP_VERSION);
             break;
   case  2 : cscanf("%s",    MAP_NAME_O);
             break;
   case  3 : cscanf("%s",    MAP_VERSION_O);
             break;
   case  4 : cscanf("%s",    PAL_NAME);
             break;
   case  5 : cscanf("%s",    MUS_NAME);
             break;
   case  6 : cscanf("%f",    &PARALLAX1);
             break;
   case  7 : cscanf("%f",    &PARALLAX2);
             break;
   case  8 : cscanf("%s",    MAP_AUTHOR);
             break;
   case  9 : cscanf("%s",    MAP_COMNT1);
             break;
   case 10 : cscanf("%s",    MAP_COMNT2);
             break;
  }
 getVK();
 textattr(TX_ATTR_BACK);
 gotoxy(3,25);
 clreol();
}

void edit_level(void)
{
 int current = 0;
 int i       = 0;
 int key     = 0;

 show_level_layout();

 do
 {
  show_level_layout();
  for(i=0; i<LFIELDS;i++) show_level_field(i, TX_ATTR_BACK);
  show_level_field(current, TX_ATTR_EDIT);
  HideCursor();
  key = getVK();
  switch(key)
   {
    case VK_TAB   :
    case VK_DOWN  :
    case VK_RIGHT : current++;
                    if(current >= LFIELDS) current = 0;
                    break;
    case VK_S_TAB :
    case VK_UP    :
    case VK_LEFT  : current--;
                    if(current < 0 ) current = LFIELDS - 1;
                    break;
    case VK_ENTER :
    case VK_SPACE : edit_level_field(current);
                    break;
   }
 } while((key != VK_ESC) && (key != VK_F2));

 if(key == VK_F2)
  {
   MODIFIED = 1;
  }
}

/* ************************************************************************** */
/* FLAG EDITOR FUNCTIONS                                                      */
/* ************************************************************************** */

unsigned edit_flag(char *flagfile, unsigned currentval)
{
 int       i;
 unsigned  value;
 unsigned  temp;
 /* should make a far buffer of this (takes a lot of stack!) */
 char      descriptions[17][38]; 
 char      alpha_value[10];
 unsigned  bitset[16];
 unsigned  bitval[16];
 int       key;
 FILE      *fflag;
 int       pos;

 for(i=0; i<16; i++) strcpy(descriptions[i], "----- ?");

 if(fexists(flagfile) == TRUE)
  {
   fflag = fopen(flagfile , "rt");
   value = 0;
   while(!feof(fflag))
    {
     fgets(fbuffer, 36, fflag);
     fbuffer[strlen(fbuffer)-1] = '\0';
     fbuffer[36] = '\0';
     strcpy(descriptions[value], fbuffer);
     value++;
    }
   fclose(fflag);
  }
 else
  {
   value = 1;
   for(i=0; i<16; i++)
    {
     sprintf(descriptions[i], "%5u ?", value);
     value *= 2;
    }
  }

 value = currentval;

 temp = 32768;
 for(i=15; i>=0; i--)
  {
   bitval[i] = temp;
   if(value >= temp)
    {
     bitset[i] = 1;
     value -= temp;
    }
   else
    bitset[i] = 0;
   temp /= 2;
  }

 value = currentval;

 setviewport(TITLE_BOX_X / 2+ 1, TITLE_BOX_Y+1, TITLE_BOX_X /2 + 40 * 8, TITLE_BOX_Y+2 + 20 * 8 , 1);
 clearviewport();
 setcolor(HEAD_FORE);
 rectangle(0, 0, 40 * 8-1, 20 * 8-1);
 rectangle(0, 0, 40 * 8-1,  3 * 8-1);
 outtextxy(8, 8, "FLAG EDITOR    Current value :");
 sprintf(alpha_value, "%u", value);
 outtextxy(8 + 31*8, 8, alpha_value);

 pos = 0;

 do
 {
  for(i=0; i<16; i++)
   {
    if(bitset[i] == 1)
     setcolor(HILI_AT_ALT);
    else
     setcolor(HEAD_FORE);
    outtextxy(16, 28 + 8*i, descriptions[i]);

    if(i==pos)
     setcolor(HILI_AT_ALT);
    else
     setcolor(0);

    outtextxy(8,   28 + 8*i, "");
    outtextxy(304, 28 + 8*i, "");
   }
 key = getVK();
  switch(key)
   {
    case VK_DOWN  :
    case VK_RIGHT : pos++;
                    if(pos >= 16) pos = 0;
                    break;
    case VK_UP    :
    case VK_LEFT  : pos--;
                    if(pos < 0 ) pos = 15;
                    break;
    case VK_SPACE : sprintf(alpha_value, "%u", value);
                    setcolor(0);
                    outtextxy(8 + 31*8, 8, alpha_value);
                    if(bitset[pos] == 1)
                     {
                      bitset[pos] = 0;
                      value -= bitval[pos];
                     }
                    else
                     {
                      bitset[pos] = 1;
                      value += bitval[pos];
                     }
                    sprintf(alpha_value, "%u", value);
                    setcolor(HEAD_FORE);
                    outtextxy(8 + 31*8, 8, alpha_value);
                    break;
   }
 } while(key != VK_ENTER);

 setviewport(0, 0, getmaxx(), getmaxy(), 1);
 return(value);
}


unsigned long edit_lflag(char *flagfile, unsigned long currentval)
{
 int       i;
 unsigned long  value;
 unsigned long  temp;
 /* should make a far buffer of this (takes a lot of stack!) */
 char      descriptions[21][38];
 char      alpha_value[10];
 unsigned long bitset[20];
 unsigned long bitval[20];
 int       key;
 FILE      *fflag;
 int       pos;

 for(i=0; i<20; i++) strcpy(descriptions[i], "----- ?");

 if(fexists(flagfile) == TRUE)
  {
   fflag = fopen(flagfile , "rt");
   value = 0;
   while(!feof(fflag))
    {
     fgets(fbuffer, 36, fflag);
     fbuffer[strlen(fbuffer)-1] = '\0';
     fbuffer[36] = '\0';
     strcpy(descriptions[value], fbuffer);
     value++;
    }
   fclose(fflag);
  }
 else
  {
   value = 1;
   for(i=0; i<20; i++)
    {
     sprintf(descriptions[i], "%7lu ?", value);
     value *= 2;
    }
  }

 value = currentval;

 temp = (long)65536 * 8;
 for(i=19; i>=0; i--)
  {
   bitval[i] = temp;
   if(value >= temp)
    {
     bitset[i] = 1;
     value -= temp;
    }
   else
    bitset[i] = 0;
   temp /= 2;
  }

 value = currentval;

 setviewport(TITLE_BOX_X / 2+ 1, TITLE_BOX_Y+1, TITLE_BOX_X /2 + 40 * 8, TITLE_BOX_Y+2 + 24 * 8 , 1);
 clearviewport();
 setcolor(HEAD_FORE);
 rectangle(0, 0, 40 * 8-1, 24 * 8-1);
 rectangle(0, 0, 40 * 8-1,  3 * 8-1);
 outtextxy(8, 8, "FLAG EDITOR  Current value :");
 sprintf(alpha_value, "%lu", value);
 outtextxy(8 + 29*8, 8, alpha_value);

 pos = 0;

 do
 {
  for(i=0; i<20; i++)
   {
    if(bitset[i] == 1)
     setcolor(HILI_AT_ALT);
    else
     setcolor(HEAD_FORE);
    outtextxy(16, 28 + 8*i, descriptions[i]);

    if(i==pos)
     setcolor(HILI_AT_ALT);
    else
     setcolor(0);

    outtextxy(8,   28 + 8*i, "");
    outtextxy(304, 28 + 8*i, "");
   }
 key = getVK();
  switch(key)
   {
    case VK_DOWN  :
    case VK_RIGHT : pos++;
                    if(pos >= 20) pos = 0;
                    break;
    case VK_UP    :
    case VK_LEFT  : pos--;
                    if(pos < 0 ) pos = 19;
                    break;
    case VK_SPACE : sprintf(alpha_value, "%lu", value);
                    setcolor(0);
                    outtextxy(8 + 29*8, 8, alpha_value);
                    if(bitset[pos] == 1)
                     {
                      bitset[pos] = 0;
                      value -= bitval[pos];
                     }
                    else
                     {
                      bitset[pos] = 1;
                      value += bitval[pos];
                     }
                    sprintf(alpha_value, "%lu", value);
                    setcolor(HEAD_FORE);
                    outtextxy(8 + 29*8, 8, alpha_value);
                    break;
   }
 } while(key != VK_ENTER);

 setviewport(0, 0, getmaxx(), getmaxy(), 1);
 return(value);
}

