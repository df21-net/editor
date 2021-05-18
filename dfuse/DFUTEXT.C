#include "dfuse.h"
#include "dfuseext.h"

/* ************************************************************************** */
/* TEXT FILES MENU                                                            */
/* ************************************************************************** */

void text_menu()
{
 char tmp[127];
 int  i;

 cleardevice();
 ccc = 0;
 write_text_menu();
 do
  {
   switch(ccc)
    {
     case  'j' :
     case  'J' : gr_shutdown();
                 if(EDIT_ALLOWED)
                   sprintf(tmp, call_editor, "dark\\jedi.lvl");
                 else
                   sprintf(tmp, call_pager, "dark\\jedi.lvl");
                 system(tmp);
                 gr_startup();
                 break;
     case  't' :
     case  'T' : gr_shutdown();
                 if(EDIT_ALLOWED)
                   sprintf(tmp, call_editor, "dark\\text.msg");
                 else
                   sprintf(tmp, call_pager, "dark\\text.msg");
                 system(tmp);
                 gr_startup();
                 break;
     case  'z' :
     case  'Z' : shell_to_DOS();
                 break;
    };
    write_text_menu();
  } while((ccc=getVK()) != VK_ESC);
}

void write_text_menu()
{
 char tmp[127];

 draw_menu_box();

 setcolor(MENU_FORE);
 outtextxy(OUT_X, OUT_Y +   8,"      DFUSE Text MENU");
 draw_menu_copyright();
 outtextxy(OUT_X, OUT_Y +  50," [J].  Edit JEDI.LVL");
 outtextxy(OUT_X, OUT_Y +  65," [T].  Edit TEXT.MSG");
 setcolor(MENU_FORE);
 draw_menu_footer();
}

