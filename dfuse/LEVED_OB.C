/* ========================================================================== */
/* LEVED_OB.C : OBJECT EDITOR                                                 */
/* ========================================================================== */
#include "levmap.h"
#include "levext.h"

/* ************************************************************************** */
/* OBJECT EDITOR FUNCTIONS                                                    */
/* ************************************************************************** */

#define OFIELDS      11

void show_object_layout(int color)
{
 setcolor(color);
 outtextxy(TITLE_BOX_X / 2 + 6 +  0,  6, "Cls:");
 outtextxy(TITLE_BOX_X / 2 + 6 +160,  6, "Nam:");
 outtextxy(TITLE_BOX_X / 2 + 6 +  0, 21, "Log:");
       outtextxy(TITLE_BOX_X / 2 + 6 + 40, 21, swpOBJ.logic);
 outtextxy(TITLE_BOX_X / 2 + 6 +  0, 36, "X  :");
 outtextxy(TITLE_BOX_X / 2 + 6 +108, 36, "Z  :");
 outtextxy(TITLE_BOX_X / 2 + 6 +216, 36, "Y  :");
 outtextxy(TITLE_BOX_X / 2 + 6 +  0, 51, "Pch:");
 outtextxy(TITLE_BOX_X / 2 + 6 +108, 51, "Yaw:");
 outtextxy(TITLE_BOX_X / 2 + 6 +216, 51, "Rol:");
 outtextxy(TITLE_BOX_X / 2 + 6 +  0, 66, "Dif:");
 outtextxy(TITLE_BOX_X / 2 + 6 +  0, 81, "Seq:");
}

void show_all_object_fields(int color)
{
 int i;

 for(i=0; i<OFIELDS;i++) show_object_field(i, color);
}

void show_object_field(int fieldnum, int color)
{
 char tmpstr[40];

 setcolor(color);
 switch(fieldnum)
  {
   case  0 : sprintf(tmpstr, "%s", swpOBJ.classname);
             outtextxy(TITLE_BOX_X / 2 + 6 + 40,  6, tmpstr);
             break;
   case  1 : sprintf(tmpstr, "%s", swpOBJ.dataname);
             outtextxy(TITLE_BOX_X / 2 + 6 +200,  6, tmpstr);
             break;
   case  2 : sprintf(tmpstr, "%s", swpOBJ.logic);
             outtextxy(TITLE_BOX_X / 2 + 6 + 40, 21, tmpstr);
             break;
   case  3 : sprintf(tmpstr, "% 5.2f", MAP_OBJ[OB_HILITE].x);
             outtextxy(TITLE_BOX_X / 2 + 6 + 40, 36, tmpstr);
             break;
   case  4 : sprintf(tmpstr, "% 5.2f", MAP_OBJ[OB_HILITE].z);
             outtextxy(TITLE_BOX_X / 2 + 6 +148, 36, tmpstr);
             break;
   case  5 : sprintf(tmpstr, "% 5.2f", -MAP_OBJ[OB_HILITE].y);
             outtextxy(TITLE_BOX_X / 2 + 6 +256, 36, tmpstr);
             break;
   case  6 : sprintf(tmpstr, "% 5.2f", swpOBJ.pch);
             outtextxy(TITLE_BOX_X / 2 + 6 + 40, 51, tmpstr);
             break;
   case  7 : sprintf(tmpstr, "% 5.2f", MAP_OBJ[OB_HILITE].yaw);
             outtextxy(TITLE_BOX_X / 2 + 6 +148, 51, tmpstr);
             break;
   case  8 : sprintf(tmpstr, "% 5.2f", swpOBJ.rol);
             outtextxy(TITLE_BOX_X / 2 + 6 +256, 51, tmpstr);
             break;
   case  9 : sprintf(tmpstr, "%-d", MAP_OBJ[OB_HILITE].diff);
             outtextxy(TITLE_BOX_X / 2 + 6 + 40, 66, tmpstr);
             break;
   case 10 : sprintf(tmpstr, "%-d", swpOBJ.seqs);
             outtextxy(TITLE_BOX_X / 2 + 6 + 40, 81, tmpstr);
             break;
  }
}

void edit_object_field(int fieldnum)
{
 char tmp[40];
 int  ret;
 int  i,j;

 switch(fieldnum)
  {
   case  0 : sprintf(tmpstr, "%s", swpOBJ.classname);
             sprintf(tmp   , "%s", swpOBJ.classname);
             obpicker("   CLASS  ", "dfudata\\ob_class.dfu", tmpstr, HEAD_FORE, 0, HEAD_FORE, HILI_AT_ALT);
             if(strlen(tmpstr) != 0)
               strcpy(swpOBJ.classname, tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 + 40, 6, 12, HEAD_BACK);

             if(strcmp(swpOBJ.classname, "SPIRIT") == 0)
              {
               MAP_OBJ[OB_HILITE].type = OBT_SPIRIT;
               strcpy(swpOBJ.dataname, "SPIRIT");
               SE_erase_all(TITLE_BOX_X / 2 + 6 +200,  6, 12, HEAD_BACK);
               set_object_info(OB_HILITE);
              }
             else
             if(strcmp(swpOBJ.classname, "SAFE"  ) == 0)
              {
               MAP_OBJ[OB_HILITE].type = OBT_SAFE;
               strcpy(swpOBJ.dataname, "SAFE");
               SE_erase_all(TITLE_BOX_X / 2 + 6 +200,  6, 12, HEAD_BACK);
               set_object_info(OB_HILITE);
              }
             else
              {
               /* if CLASS changed, propose to choose dataname */
               if((strcmp(swpOBJ.classname, tmp) != 0) && (strcmp(tmpstr,"") != 0))
                {
                 show_object_field(0, HEAD_FORE);
                 /* MAINTENANCE WARNING : this code is duplicated just below */
                 sprintf(tmpstr, "%s", swpOBJ.dataname);
                 if(strcmp(swpOBJ.classname, "3D" ) == 0)
                  {
                   MAP_OBJ[OB_HILITE].type = OBT_3D;
                   obpicker("     3D   ", pk_3d, tmpstr, HEAD_FORE, 0, HEAD_FORE, HILI_AT_ALT);
                  }
                 if(strcmp(swpOBJ.classname, "FRAME" ) == 0)
                  {
                   MAP_OBJ[OB_HILITE].type = OBT_FRAME;
                   obpicker("  FRAMES  ", pk_frames, tmpstr, HEAD_FORE, 0, HEAD_FORE, HILI_AT_ALT);
                  }
                 if(strcmp(swpOBJ.classname, "SPRITE") == 0)
                  {
                   MAP_OBJ[OB_HILITE].type = OBT_SPRITE;
                   obpicker("  SPRITES ", pk_sprites, tmpstr, HEAD_FORE, 0, HEAD_FORE, HILI_AT_ALT);
                  }
                 if(strcmp(swpOBJ.classname, "SOUND" ) == 0)
                  {
                   MAP_OBJ[OB_HILITE].type = OBT_SOUND;
                   obpicker("  SOUNDS  ", pk_sounds, tmpstr, HEAD_FORE, 0, HEAD_FORE, HILI_AT_ALT);
                  }
                 if(strlen(tmpstr) != 0)
                  {
                   strcpy(swpOBJ.dataname, tmpstr);
                   MAP_OBJ[OB_HILITE].col = ReadIniInt(swpOBJ.dataname, "COLOR",
                                         OBJ_NOTHILI , "dfudata\\ob_cols.dfu");
                  }
                 SE_erase_all(TITLE_BOX_X / 2 + 6 +200,  6, 12, HEAD_BACK);
                 show_object_field(1, HEAD_FORE);
                 set_object_info(OB_HILITE);
                }
              }
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* !Esc pressed*/
              {
               swpOBJ2 = swpOBJ;
               for(i=0; i<=obj_max; i++) if(MAP_OBJ[i].mark != 0)
                {
                 MAP_OBJ[i].type = MAP_OBJ[OB_HILITE].type;
                 MAP_OBJ[i].col  = MAP_OBJ[OB_HILITE].col;
                 get_object_info(i);
                 strcpy(swpOBJ.classname, swpOBJ2.classname);
                 strcpy(swpOBJ.dataname,  swpOBJ2.dataname);
                 set_object_info(i);
                }
               swpOBJ = swpOBJ2;
              }
             refresh_map_in_editor();
             break;
   case  1 : /* MAINTENANCE WARNING : this code is quasi duplicated just above */
             sprintf(tmpstr, "%s", swpOBJ.dataname);
             if(strcmp(swpOBJ.classname, "3D" ) == 0)
              obpicker("     3D   ", pk_3d, tmpstr, HEAD_FORE, 0, HEAD_FORE, HILI_AT_ALT);
             if(strcmp(swpOBJ.classname, "FRAME" ) == 0)
              obpicker("  FRAMES  ", pk_frames, tmpstr, HEAD_FORE, 0, HEAD_FORE, HILI_AT_ALT);
             if(strcmp(swpOBJ.classname, "SPRITE") == 0)
              obpicker("  SPRITES ", pk_sprites, tmpstr, HEAD_FORE, 0, HEAD_FORE, HILI_AT_ALT);
             if(strcmp(swpOBJ.classname, "SOUND" ) == 0)
              obpicker("  SOUNDS  ", pk_sounds, tmpstr, HEAD_FORE, 0, HEAD_FORE, HILI_AT_ALT);
             if(strlen(tmpstr) != 0)
              {
                strcpy(swpOBJ.dataname, tmpstr);
                MAP_OBJ[OB_HILITE].col = ReadIniInt(swpOBJ.dataname, "COLOR",
                                         OBJ_NOTHILI , "dfudata\\ob_cols.dfu");
              }
             SE_erase_all(TITLE_BOX_X / 2 + 6 +200,  6, 12, HEAD_BACK);
             set_object_info(OB_HILITE);
             if((APPLY_TO_MULTI) && (strlen(tmpstr) != 0)) /* Esc pressed*/
              {
               swpOBJ2 = swpOBJ;
               for(i=0; i<=obj_max; i++) if(MAP_OBJ[i].mark != 0)
                {
                 MAP_OBJ[i].col  = MAP_OBJ[OB_HILITE].col;
                 get_object_info(i);
                 strcpy(swpOBJ.dataname, swpOBJ2.dataname);
                 set_object_info(i);
                }
               swpOBJ = swpOBJ2;
              }
             refresh_map_in_editor();
             break;
   case  2 : break;
   case  3 : sprintf(tmpstr, "%-5.2f", MAP_OBJ[OB_HILITE].x);
             if(stredit(TITLE_BOX_X / 2 + 6 + 40, 36, tmpstr, 7, 8, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
             MAP_OBJ[OB_HILITE].x  = atof(tmpstr);
             MAP_OBJ[OB_HILITE].sec = get_object_SC(OB_HILITE);
             SE_erase_all(TITLE_BOX_X / 2 + 6 + 40, 36, 8, HEAD_BACK);
             if(APPLY_TO_MULTI)
              {
               for(i=0; i<=obj_max; i++) if(MAP_OBJ[i].mark != 0)
                MAP_OBJ[i].x   = MAP_OBJ[OB_HILITE].x;
                MAP_OBJ[i].sec = get_object_SC(i);
              }
             clearviewport();
             handle_titlebar(HEAD_BACK, HEAD_BORDER);
             handle_title(HEAD_FORE);
             setviewport(0, 0, getmaxx(), getmaxy(), 1);
             if(APPLY_TO_MULTI) show_object_layout(HILI_AT_ALT);
             show_all_object_fields(HEAD_FORE);
             refresh_map_in_editor();
             break;
   case  4 : sprintf(tmpstr, "%-5.2f", MAP_OBJ[OB_HILITE].z);
             if(stredit(TITLE_BOX_X / 2 + 6 +148, 36, tmpstr, 7, 8, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
             MAP_OBJ[OB_HILITE].z  = atof(tmpstr);
             MAP_OBJ[OB_HILITE].sec = get_object_SC(OB_HILITE);
             SE_erase_all(TITLE_BOX_X / 2 + 6 +148, 36, 8, HEAD_BACK);
             if(APPLY_TO_MULTI)
              {
               for(i=0; i<=obj_max; i++) if(MAP_OBJ[i].mark != 0)
                MAP_OBJ[i].z   = MAP_OBJ[OB_HILITE].z;
                MAP_OBJ[i].sec = get_object_SC(i);
              }
             clearviewport();
             handle_titlebar(HEAD_BACK, HEAD_BORDER);
             handle_title(HEAD_FORE);
             setviewport(0, 0, getmaxx(), getmaxy(), 1);
             if(APPLY_TO_MULTI) show_object_layout(HILI_AT_ALT);
             show_all_object_fields(HEAD_FORE);
             refresh_map_in_editor();
             break;
   case  5 : sprintf(tmpstr, "%-5.2f", -MAP_OBJ[OB_HILITE].y);
             if(stredit(TITLE_BOX_X / 2 + 6 +256, 36, tmpstr, 7, 7, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
             MAP_OBJ[OB_HILITE].y   = -atof(tmpstr);
             MAP_OBJ[OB_HILITE].sec = get_object_SC(OB_HILITE);
             SE_erase_all(TITLE_BOX_X / 2 + 6 +256, 36, 7, HEAD_BACK);
             if(APPLY_TO_MULTI)
              {
               for(i=0; i<=obj_max; i++) if(MAP_OBJ[i].mark != 0)
                MAP_OBJ[i].y   = MAP_OBJ[OB_HILITE].y;
                MAP_OBJ[i].sec = get_object_SC(i);
              }
             clearviewport();
             handle_titlebar(HEAD_BACK, HEAD_BORDER);
             handle_title(HEAD_FORE);
             setviewport(0, 0, getmaxx(), getmaxy(), 1);
             if(APPLY_TO_MULTI) show_object_layout(HILI_AT_ALT);
             show_all_object_fields(HEAD_FORE);
             refresh_map_in_editor();
             break;
   case  6 : sprintf(tmpstr, "%-5.2f", swpOBJ.pch);
             if(stredit(TITLE_BOX_X / 2 + 6 + 40, 51, tmpstr, 7, 8, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
             swpOBJ.pch = atof(tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 + 40, 51, 8, HEAD_BACK);
             set_object_info(OB_HILITE);
             if(APPLY_TO_MULTI)
              {
               swpOBJ2 = swpOBJ;
               for(i=0; i<=obj_max; i++) if(MAP_OBJ[i].mark != 0)
                {
                 get_object_info(i);
                 swpOBJ.pch = swpOBJ2.pch;
                 set_object_info(i);
                }
               swpOBJ = swpOBJ2;
              }
             break;
   case  7 : sprintf(tmpstr, "%-5.2f", MAP_OBJ[OB_HILITE].yaw);
             if(stredit(TITLE_BOX_X / 2 + 6 +148, 51, tmpstr, 7, 8, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
             MAP_OBJ[OB_HILITE].yaw  = atof(tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 +148, 51, 8, HEAD_BACK);
             if(APPLY_TO_MULTI)
              {
               for(i=0; i<=obj_max; i++) if(MAP_OBJ[i].mark != 0)
                MAP_OBJ[i].yaw = MAP_OBJ[OB_HILITE].yaw;
              }
             refresh_map_in_editor();
             break;
   case  8 : sprintf(tmpstr, "%-5.2f", swpOBJ.rol);
             if(stredit(TITLE_BOX_X / 2 + 6 +256, 51, tmpstr, 7, 7, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
             swpOBJ.rol = atof(tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 +256, 51, 7, HEAD_BACK);
             set_object_info(OB_HILITE);
             if(APPLY_TO_MULTI)
              {
               swpOBJ2 = swpOBJ;
               for(i=0; i<=obj_max; i++) if(MAP_OBJ[i].mark != 0)
                {
                 get_object_info(i);
                 swpOBJ.rol = swpOBJ2.rol;
                 set_object_info(i);
                }
               swpOBJ = swpOBJ2;
              }
             break;
   case  9 : sprintf(tmpstr, "%-d", MAP_OBJ[OB_HILITE].diff);
             if(stredit(TITLE_BOX_X / 2 + 6 + 40, 66, tmpstr, 2, 3, HEAD_FORE, 0, HEAD_FORE) == VK_ENTER)
               MAP_OBJ[OB_HILITE].diff = atoi(tmpstr);
             SE_erase_all(TITLE_BOX_X / 2 + 6 + 40, 66, 3, HEAD_BACK);
             if(APPLY_TO_MULTI)
              {
               for(i=0; i<=obj_max; i++) if(MAP_OBJ[i].mark != 0)
                MAP_OBJ[i].diff = MAP_OBJ[OB_HILITE].diff;
              }
             refresh_map_in_editor();
             break;
   case 10 : edit_object__seqs();
             set_object_info(OB_HILITE);
             if(APPLY_TO_MULTI)
              {
               swpOBJ2 = swpOBJ;
               for(i=0; i<=obj_max; i++) if(MAP_OBJ[i].mark != 0)
                {
                 MAP_OBJ[i].special = MAP_OBJ[OB_HILITE].special;
                 get_object_info(i);
                 strcpy(swpOBJ.logic, swpOBJ2.logic);
                 swpOBJ.seqs  = swpOBJ2.seqs;
                 for(j=0; j<swpOBJ2.seqs; j++)
                  strcpy(swpOBJ.seq[j], swpOBJ2.seq[j]);
                 set_object_info(i);
                }
               swpOBJ = swpOBJ2;
              }
             refresh_map_in_editor();
             if(APPLY_TO_MULTI) show_object_layout(HILI_AT_ALT);
             break;
  }

}

void edit_object(void)
{
 int   current = 0;
 int   key     = 0;
 int   i;
 char  section[20];
 char  buf1[81];
 FILE  *osq;
 int   found;
 int   multiple;

 get_object_info(OB_HILITE);

 setviewport(0, 0, getmaxx(), getmaxy(), 1);
 if(APPLY_TO_MULTI) show_object_layout(HILI_AT_ALT);

 do
 {
  show_all_object_fields(HEAD_FORE);
  show_object_field(current, HILI_AT_ALT);
  key = getVK();
  switch(key)
   {
    case 'g'      :
    case 'G'      :
                    found = 0;
                    osq = fopen("DFUDATA\\OB_SEQS.DFU" , "rt");
                    strcpy(section, "[GENERATOR]");
                    while(fgets(buf1, 80, osq) != NULL)
                     {
                      buf1[strlen(buf1)-1] = '\0'; /* fgets brings back CRLF */
                      if(buf1[0] == '[')
                       {
                        if(strcmp(buf1, section) == 0)
                         {
                          found = 1;
                          break;
                         }
                       };
                     };
                    i=0;
                    if(found == 1)
                     while(fgets(buf1, 80, osq) != NULL)
                      {
                       if((buf1[0] == '\n') || (buf1[0] == '[')) break;
                       else
                        {
                         strcpy(swpOBJ.seq[i], buf1);
                         if(i == 0)
                          {
                           swpOBJ.seq[0][strlen(buf1)-1] = '\0';  /* del CRLF */
                           strcat(swpOBJ.seq[0], " ");
                           strcat(swpOBJ.seq[0], swpOBJ.logic);
                           strcat(swpOBJ.seq[0], "\n");
                          }
                         i++;
                        }
                      };
                    swpOBJ.seqs = i;
                    recalc_logic();
                    set_object_info(OB_HILITE);
                    fclose(osq);
                    SE_erase_all(TITLE_BOX_X / 2 + 6 + 40, 21, 24, HEAD_BACK);
                    SE_erase_all(TITLE_BOX_X / 2 + 6 + 40, 81,  3, HEAD_BACK);
                    outtextxy(TITLE_BOX_X / 2 + 6 + 100, 81, "Edit GENERATOR !");
                    break;
    case 's'      :
    case 'S'      :
                    found    = 0;
                    multiple = 0;
                    osq = fopen("DFUDATA\\OB_SEQS.DFU" , "rt");
                    strcpy(section, "[");
                    strcat(section, swpOBJ.dataname);
                    strcat(section, "]");
                    while(fgets(buf1, 80, osq) != NULL)
                     {
                      buf1[strlen(buf1)-1] = '\0'; /* fgets brings back CRLF */
                      if(buf1[0] == '[')
                       {
                        if(strcmp(buf1, section) == 0)
                         {
                          found = 1;
                          break;
                         }
                       };
                     };
                    i=0;
                    if(found == 1)
                     while(fgets(buf1, 80, osq) != NULL)
                      {
                       if((buf1[0] == '\n') || (buf1[0] == '[')) break;
                       else
                        {
                         if(buf1[0] == 'æ')
                           multiple = 1;
                         else
                          {
                           strcpy(swpOBJ.seq[i], buf1);
                           i++;
                          }
                        }
                      };
                    swpOBJ.seqs = i;
                    recalc_logic();
                    set_object_info(OB_HILITE);
                    fclose(osq);
                    SE_erase_all(TITLE_BOX_X / 2 + 6 + 40, 21, 24, HEAD_BACK);
                    SE_erase_all(TITLE_BOX_X / 2 + 6 + 40, 81,  3, HEAD_BACK);
                    if(multiple == 1)
                      outtextxy(TITLE_BOX_X / 2 + 6 + 100, 81, "Choose LOGIC !");
                    break;
    case VK_TAB   :
    case VK_DOWN  :
    case VK_RIGHT : current++;
                    if(current >= OFIELDS) current = 0;
                    break;
    case VK_S_TAB :
    case VK_UP    :
    case VK_LEFT  : current--;
                    if(current < 0 ) current = OFIELDS - 1;
                    break;
    case VK_ENTER :
    case VK_SPACE : edit_object_field(current);
                    break;
   }
 } while(key != VK_ESC);

  show_object_field(current, HEAD_FORE);
  setviewport(0, TITLE_BOX_Y+1, getmaxx(), getmaxy(), 1);
  set_object_info(OB_HILITE);  /* security, is done at field level */
  MODIFIED = 1;
}

void edit_object__seqs()
{
 char tmp[127];
 char fbuffer[127];
 char msg[127];
 FILE      *fseqs;
 int       i;

 gr_shutdown();
 fseqs = fopen("temp\\objseqs.$$$" , "wt");
 /* if(fseqs == NULL) error checking */;

 sprintf(msg, "SEQ    /* MAXIMUM SIZE : %d lines of %d chars (not included SEQ)        */\n",
                                        MAX_OBJECT_SEQUENCE, MAX_OBJECT_SEQ_LEN);
 fputs(msg, fseqs);
 for(i=0; i<swpOBJ.seqs; i++)
   fputs(swpOBJ.seq[i], fseqs);
 sprintf(msg, "SEQ    /* MAXIMUM SIZE : %d lines of %d chars (you have been warned!!)  */\n",
                                        MAX_OBJECT_SEQUENCE, MAX_OBJECT_SEQ_LEN);
 fputs(msg, fseqs);
 fclose(fseqs);

 sprintf(tmp, call_editor, "temp\\objseqs.$$$");
 system(tmp);

 fseqs = fopen("temp\\objseqs.$$$" , "rt");
 i = -1;
 while(!feof(fseqs))
  {
   fgets(fbuffer, 80, fseqs);
   if(i < MAX_OBJECT_SEQUENCE)
    {
     if(i >= 0) strcpy(swpOBJ.seq[i], fbuffer);
     i++;
    }
  }
 fclose(fseqs);
 i--;
 i--;
 swpOBJ.seqs = i;
 set_object_info(OB_HILITE);

 remove("temp\\objseqs.$$$");

 recalc_logic();

 gr_startup();
 handle_titlebar(HEAD_BACK, HEAD_BORDER);
 handle_title(HEAD_FORE);
}

void recalc_logic(void)
{
 char key1[20];
 char key2[20];
 char key3[20];
 int       i;

logfound = 0;

for(i=0; i<swpOBJ.seqs; i++)
 {
 strcpy(fbuffer, swpOBJ.seq[i]);
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
       MAP_OBJ[OB_HILITE].special = OBS_GENERATOR;
      }
     else
      {
       MAP_OBJ[OB_HILITE].special = !OBS_GENERATOR;
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
 }

 if(logfound == 0) strcpy(swpOBJ.logic, "");
 set_object_info(OB_HILITE);
}

