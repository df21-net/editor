#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <fcntl.h>
#include <io.h>
#include <conio.h>
#include <dos.h>
#include <dir.h>
#include <sys\types.h>
#include <sys\stat.h>

#define ERR_NOERROR       00
#define ERR_INIFILE       10
#define ERR_CMDLINE       20
#define ERR_WRONGFILE     30
#define ERR_NOTBM         40
#define ERR_TOOLONG       50
#define ERR_DYNALLOC      60
#define ERR_GRAPHIC       70

char          buffer[4000];
int           f1;
int           f2;
int           f3;

typedef int                 boolean;
#define FALSE               0
#define TRUE                1

boolean fexists(char *filename);

boolean fexists(char *filename)
{
 if(access(filename,0)!=0)
  return(FALSE);
 else
  return(TRUE);
}


/* ************************************************************************** */
/* MAIN ********************************************************************* */
/* ************************************************************************** */

main()
{
 printf("\n\nMKSW_4_4 32x32 switch maker (c) Yves BORCKMANS 1995.\n\n");
 /* Check number of arguments */
 if(_argc != 4)
  {
   printf("Usage is  mksw_4_4 existing_switch bm1 bm2\n");
   printf("The existing switch will be OVERWRITTEN !!\n");
   printf("This is only a very quick patch...\n");
   return(ERR_CMDLINE);
  }

 if(fexists(_argv[1]) == FALSE)
  {
   printf("%s doesn't exist! \n", _argv[1]);
   return(ERR_WRONGFILE);
  };
 if(fexists(_argv[2]) == FALSE)
  {
   printf("%s doesn't exist! \n", _argv[2]);
   return(ERR_WRONGFILE);
  };
 if(fexists(_argv[3]) == FALSE)
  {
   printf("%s doesn't exist! \n", _argv[3]);
   return(ERR_WRONGFILE);
  };

 memset(buffer, '\0', 4000);

 f1 = open(_argv[1] , O_BINARY | O_RDWR);
 f2 = open(_argv[2] , O_BINARY | O_RDONLY);
 f3 = open(_argv[3] , O_BINARY | O_RDONLY);

 read(f2, &buffer, 32);              /* pass the header */
 read(f3, &buffer, 32);              /* pass the header */

 lseek(f1, 0x00000046, SEEK_SET);   /* skip the header as it is correct */
 read(f2, &buffer, 1024);           /* all the data   */
 write(f1, &buffer, 1024);
 lseek(f1, 0x00000462, SEEK_SET);   /* skip the header as it is correct */
 read(f3, &buffer, 1024);           /* all the data   */
 write(f1, &buffer, 1024);


 close(f1);
 close(f2);
 close(f3);
 return(0);
}
