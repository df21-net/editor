/* ------------------------------------------------ */
/* dark.c                                           */
/* (c) Yves BORCKMANS 1994                          */
/* ------------------------------------------------ */

#ifndef DARK_H
#include "dark.h"
#endif

#define MAX_POS    100

long  POS[MAX_POS];

/*
#ifndef USING_TOOLKIT
boolean fexists(char *filename)
{
if(access(filename,0)!=0)
   return(FALSE);
else
   return(TRUE);
}
#endif
*/

/* Is file a GOB file                               */
/* This function uses the NAME of the file,         */
/* not a file handle                                */
boolean is_gob(char *filename)
{
 int f1;
 struct GOB_BEGIN ws;

 f1 = open(filename , O_BINARY | O_RDONLY);
 lseek(f1 , 0 , SEEK_SET);
 read(f1 , &ws , sizeof(ws));
 if(    (ws.GOB_MAGIC[0] == 'G')
     && (ws.GOB_MAGIC[1] == 'O')
     && (ws.GOB_MAGIC[2] == 'B')
     && (ws.GOB_MAGIC[3] == 0x0A))
   {
    close(f1);
    return(TRUE);
   }
 else
   {
    close(f1);
    return(FALSE);
   };
}

/* Is file a LEV file                               */
/* This function uses the NAME of the file,         */
/* not a file handle                                */
boolean is_lev(char *filename)
{
 int    f1;
 char   LEV_MAGIC[4];

 f1 = open(filename , O_BINARY | O_RDONLY);
 lseek(f1 , 0 , SEEK_SET);
 read(f1 , LEV_MAGIC , 4);
 if(    (LEV_MAGIC[0] == 'L')
     && (LEV_MAGIC[1] == 'E')
     && (LEV_MAGIC[2] == 'V'))
   {
    close(f1);
    return(TRUE);
   }
 else
   {
    close(f1);
    return(FALSE);
   };
}

/* This function uses the file handle of an         */
/* already opened file                              */
long get_master_index(int f)
{
 struct GOB_BEGIN gb;
 long             curpos;

 curpos = tell(f);
 lseek(f , 0    , SEEK_SET);
 read(f  , &gb  , sizeof(gb));
 lseek(f, curpos, SEEK_SET);
 return(gb.MASTERX+4);
}

/* This function uses the file handle of an         */
/* already opened file                              */
long get_master_entries(int f)
{
 struct GOB_BEGIN gb;
 long             MASTERN;
 long             curpos;

 curpos = tell(f);
 lseek(f , 0    , SEEK_SET);
 read(f  , &gb  , sizeof(gb));
 lseek(f , gb.MASTERX , SEEK_SET);
 read(f  , &MASTERN, sizeof(MASTERN));
 lseek(f, curpos, SEEK_SET);
 return(MASTERN);
}

void set_magic(int f, char *mm)
{
 long             curpos;

 curpos = tell(f);
 lseek(f , 0    , SEEK_SET);
 write(f  , mm  , 4);
 lseek(f, curpos, SEEK_SET);
}


void set_master_index(int f, long mi)
{
 long             curpos;

 curpos = tell(f);
 lseek(f , 4    , SEEK_SET);
 write(f  , &mi  , 4);
 lseek(f, curpos, SEEK_SET);
}

void set_master_entries(int f, long me)
{
 long             curpos;
 struct GOB_BEGIN gb;

 curpos = tell(f);
 lseek(f , 0    , SEEK_SET);
 read(f  , &gb  , sizeof(gb));
 lseek(f , gb.MASTERX , SEEK_SET);
 write(f  , &me  , 4);
 lseek(f, curpos, SEEK_SET);
}


/* This function uses the file handle of an         */
/* already opened file                              */
void seek_master_index(int f)
{
 lseek(f , get_master_index(f), SEEK_SET);
}


/* This function uses the file handle of an         */
/* already opened file                              */
void seek_object(int f, long offset)
{
 lseek(f , offset, SEEK_SET);
}

/* This function uses the file handle of an         */
/* already opened file                              */
void get_object(int f, void *ptr, long size)
{
 read(f  , ptr  , size);
}

/* This function uses the file handle of an         */
/* already opened file                              */
void set_object(int f, void *ptr, long size)
{
 write(f  , ptr  , size);
}

void save_pos(int f, int mem)
{
 if((mem > MAX_POS) | (mem < 0))
  {
   printf("\nsave_pos : POS number error. Aborting...\n");
   exit(9999);
  }
 else
  {
   POS[mem] = tell(f);
  }
}

void rest_pos(int f, int mem)
{
 if((mem > MAX_POS) | (mem < 0))
  {
   printf("\nrest_pos : POS number error. Aborting...\n");
   exit(9999);
  }
 else
  {
   lseek(f, POS[mem], SEEK_SET);
  }
}
