#define OFFSTVUE_VERSION "v 1.0"

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <math.h>
#include <time.h>
#include <errno.h>
#include <fcntl.h>
#include <io.h>
#include <dos.h>
#include <sys\types.h>
#include <sys\stat.h>

#define TOOLKIT_NO_GRAPHICS
#include "toolkit.c"

#include "dark.h"
#include "dark.c"

#define BUF_SIZE        1024

#define ERR_NOERROR       00
#define ERR_CMDLINE       10
#define ERR_WRONGFILE     20
#define ERR_NOTGOB        30
#define ERR_TOOLONG       40

char            fname1[80]     ;
char            fname2[80]     ;
unsigned char   fbuffer[BUF_SIZE];
FILE            *f1            ;
FILE            *f2            ;

long            counter;
char            keyword[255];
char            id[20]     ;
float           xo, zo, yo;

void handle_version(void);
void handle_frame(void);
void handle_transform(void);


void handle_version()
{
 fprintf(f2, "%s\n", fbuffer);
}

void handle_frame()
{
 fprintf(f2, "%s", fbuffer);
}

void handle_transform()
{
 float f_1, f_2, f_3, f_4, f_5, f_6, f_7, f_8, f_9;
 float x,z,y;
 char str1[50], str2[50];

 sscanf(fbuffer, "%s %s %f %f %f %f %f %f %f %f %f %f %f %f",
                  str1, str2,
                  &f_1, &f_2, &f_3,
                  &f_4, &f_5, &f_6,
                  &f_7, &f_8, &f_9,
                  &x, &z, &y );

 x += xo;
 z += zo;
 y += yo;

 if(strcmp(str2, id) == 0)
 fprintf(f2,     "%s %s % 5.4f % 5.4f % 5.4f \
% 5.4f % 5.4f % 5.4f \
% 5.4f % 5.4f % 5.4f \
% 5.4f % 5.4f % 5.4f\n\n",
                  str1, str2,
                  f_1, f_2, f_3,
                  f_4, f_5, f_6,
                  f_7, f_8, f_9,
                  x, z, y );

}

/* ========================================================================== */
/* MAIN                                                                       */
/* ========================================================================== */


main()
{
  printf("\nOFFSTVUE "OFFSTVUE_VERSION" (c) Yves BORCKMANS 1995.\n\n");

/* Check number of arguments */
if(_argc != 7)
  {
   printf("Usage is OFFSTVUE vuefile id xoffset zoffset yoffset newname\n");
   return(ERR_CMDLINE);
  }

strcpy(fname1  , _argv[1]);
strcpy(id      , "\"");
strcat(id      , _argv[2]);
strcat(id      , "\"");
strcpy(fname2  , _argv[6]);

xo = atof(_argv[3]);
zo = atof(_argv[4]);
yo = atof(_argv[5]);


/* Check existence of the files */
if(fexists(fname1) == FALSE)
  {
   printf("%s doesn't exist! \n",fname1);
   return(ERR_WRONGFILE);
  };

 f1 = fopen(fname1 , "rt");
 f2 = fopen(fname2 , "wt");

 while(!feof(f1))
 {
  strcpy(fbuffer, "");
  fgets(fbuffer, 255, f1);
  if(fbuffer[0] != '#')                 /* skip full line comment */
   {
    if(fbuffer[0] != '\n')              /* skip empty line        */
     {
      strcpy(keyword, "");
      sscanf(fbuffer, "%s", keyword);
      if(strcmp(keyword, "VERSION")==0)      handle_version();

      if(strcmp(keyword, "frame")==0)        handle_frame();
      if(strcmp(keyword, "transform")==0)    handle_transform();
     }
   }
 }
 fclose(f1);
 fclose(f2);

return(ERR_NOERROR);
}
