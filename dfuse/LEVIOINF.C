/* ========================================================================== */
/* LEVIOINF.C : MAP I/O                                                       */
/*              * .INF read                                                   */
/* ========================================================================== */
#include "levmap.h"
#include "levext.h"

/* ************************************************************************** */
/* INF FUNCTIONS                                                              */
/* ************************************************************************** */

int silently;

void handle_inf_file(int silent)
{
 char keyword[255];
 FILE *finf;
 int comment = 0;
 int i;

 silently = silent;
 inf_ix = -1;
 INF_ITEMS = -1;
 finf = fopen(fname_inf , "rt");

 while(!feof(finf))
 {
  strcpy(fbuffer, "");
  fgets(fbuffer, 255, finf);
  if(fbuffer[0] != '\n')              /* skip empty line        */
   {
    if(comment == 0)
     {
      strcpy(keyword, "");
      sscanf(fbuffer, "%s", keyword);
      /* this won't accept the start of a comment inside a line ! */
      /* but I don't care !!! Put it in the doc                   */
      if(strncmp(keyword, "/*", 2) ==0 )
       {
        comment = 1;
        /* now, must search to see if end of comment is in the same line ! */
        for(i=0; i< strlen(fbuffer)-1; i++)
         {
          if(fbuffer[i] == '*')
           if(fbuffer[i+1] == '/')
            comment = 0;
         }
       }
      else
      if(strcmp(keyword, "INF")==0)          handle_inf();
      else
      if(strcmp(keyword, "inf")==0)          handle_inf();
      else
      if(strcmp(keyword, "LEVELNAME")==0)    handle_lnai();
      else
      if(strcmp(keyword, "ITEMS")==0)        handle_items();
      else
      if(strcmp(keyword, "items")==0)        handle_items();
      else
      if(strcmp(keyword, "item:")==0)        handle_item();
      else
      if(strcmp(keyword, "class:")==0)       handle_classinf();
      else
      if(strcmp(keyword, "client:")==0)      handle_client();
     }
    else
     {
      /* search for end of comment */
      for(i=0; i< strlen(fbuffer)-1; i++)
       {
        if(fbuffer[i] == '*')
         if(fbuffer[i+1] == '/')
          comment = 0;
       }
     }
   }
 }
 fclose(finf);

}

/* -------------------------------------------------------------------------- */

void handle_inf()
{
 if(silently == 0)
  {
   setcolor(HEAD_FORE);
   outtextxy(0,96,"Reading INF file.");
  }
}

void handle_lnai()
{
}

void handle_items()
{
 sscanf(fbuffer, "%*s %d", &INF_ITEMS);
}

void handle_item()
{
  char name[50];
  char num[10];
  int  numnum;
  int  line;
  int  i;

  inf_ix++;
  sscanf(fbuffer, "%*s %*s %*s %s", name);
  strcpy(num, "");
  sscanf(fbuffer, "%*s %*s %*s %*s %*s %s", num);

  if(strcmp(num, "") != 0)
   {
    line = 1;
    numnum = atoi(num);
   }
  else
   line = 0;

  if(line == 0)
   {
    secnum = -1;
    walnum = -1;
    for(i=0; i<=sector_max; i++)
     {
      get_sector_info(i);
       if(strcmp(swpSEC.name, name) == 0)
        {
          secnum = i;
          break;
        }
     }
   }
  else
   {
    secnum = -1;
    walnum = -1;
    for(i=0; i<=sector_max; i++)
     {
      get_sector_info(i);
      if(strcmp(swpSEC.name, name) == 0)
       {
         secnum = i;
         walnum = GetSectorWL(secnum, numnum);
         /* if wall is invalid simulate sec not found ! */
         if(walnum == -1) secnum = -1;
         break;
       }
     }
   }

  found_elev = 0;
  found_trig = 0;
  found_cli = 0;

 if(silently == 0)
  {
   setcolor(LINE_AT_ALT);
   moveto(inf_ix, 112);
   lineto(inf_ix, 120);
  }
}

void handle_classinf()
{
  char class[20];
  char type[20];

  sscanf(fbuffer, "%*s %s", class);
  strcpy(type, "");
  sscanf(fbuffer, "%*s %*s %s", type);

if(secnum != -1)
 {
  if(strcmp(class, "elevator") == 0)
   {
    get_sector_info(secnum);
    if(found_elev == 0)
     {
      strcpy(swpSEC.elevator_name, type);
      MAP_SEC[secnum].elev = 1;
      found_elev = 1;
     }
    swpSEC.num_classes++;
    set_sector_info(secnum);
   }

  if(strcmp(class, "trigger") == 0)
   {
    if(walnum == -1)
     {
      get_sector_info(secnum);
      if(found_trig == 0)
       {
        strcpy(swpSEC.trigger_name, type);
        MAP_SEC[secnum].trig = 1;
        found_trig = 1;
       }
      swpSEC.num_classes++;
      set_sector_info(secnum);
     }
    else
     {
      get_wall_info(walnum);
      if(found_trig == 0)
       {
        strcpy(swpWAL.trigger_name, type);
        MAP_WAL[walnum].trig = 1;
        found_trig = 1;
       }
      set_wall_info(walnum);
     }
    }
 }
}

void handle_client()
{
 char client[20];

if(secnum != -1)
{
 sscanf(fbuffer, "%*s %s", client);
 if(walnum == -1)
  {
   get_sector_info(secnum);
   if(found_cli == 0)
    {
     strcpy(swpSEC.client_name, client);
     found_cli = 1;
    }
   set_sector_info(secnum);
  }
 else
  {
   get_wall_info(walnum);
   if(found_cli == 0)
    {
     strcpy(swpWAL.client_name, client);
     found_cli = 1;
    }
   set_wall_info(walnum);
  }
}

}

