#define SEEJEDI_VERSION "v 1.0"

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <conio.h>
#include <dos.h>
#include <dir.h>
#include <io.h>
#include <sys\types.h>
#include <sys\stat.h>

#include "dark.h"
#include "dark.c"

#define ERR_NOERROR       00
#define ERR_CMDLINE       10
#define ERR_WRONGFILE     20
#define ERR_NOTLVB        30
#define ERR_TOOLONG       40
#define ERR_GRAPHIC       60

char            fname[127];
FILE            *jedi;
char            tmpstr[127];
char            tmpstr2[127];
char            buf[256];
int             count  = 0;
int             count2 = 0;
int             i;

/* ************************************************************************** */
/* MAIN                                                                       */
/* ************************************************************************** */

main()
{
 if(_argc == 1)
   {
    printf("\nSEEJEDI "SEEJEDI_VERSION" (c) Yves BORCKMANS 1995.\n\n");
    printf("Usage is SEEJEDI jedi.lvl\n");
    exit(ERR_CMDLINE);
   }
 else
   strcpy(fname, _argv[1]);

 if(fexists(fname) == FALSE)
   {
    printf("%s doesn't exist! \n",fname);
    exit(ERR_WRONGFILE);
   };

 jedi  = fopen(fname  , "rt");
 while(fgets(buf, 255, jedi) != NULL)
  {
   count++;
   if(count == 1)
    {
     count2 = atoi(&(buf[7]));
    }
   else
    {
     if(count2 > 0)
      {
       strncpy(tmpstr, &(buf[20]), 8);
       tmpstr[8] = '\0';
       strncpy(tmpstr2, buf, 20);
       tmpstr2[20] = '\0';
       strcat(tmpstr, "         ");
       strcat(tmpstr, tmpstr2);
       strcat(tmpstr, "\n");
       for(i=0;i<strlen(tmpstr);i++) if(tmpstr[i] == ',') tmpstr[i] = ' ';
       printf(tmpstr);
       count2--;
      }
    }
  }
 fclose(jedi);
 return(ERR_NOERROR);
}
