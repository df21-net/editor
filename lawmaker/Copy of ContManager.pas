unit ContManager;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ComCtrls, CommCtrl, Files, FileOperations, LView, ExtCtrls;

type
  TContMan = class(TForm)
    StatusBar: TStatusBar;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Close1: TMenuItem;
    N1: TMenuItem;
    Edit1: TMenuItem;
    Cut1: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    N2: TMenuItem;
    SelectAll1: TMenuItem;
    InvertSelection1: TMenuItem;
    T1: TMenuItem;
    Toolbar1: TMenuItem;
    Statusbar2: TMenuItem;
    N3: TMenuItem;
    LargeIcons: TMenuItem;
    SmallIcons: TMenuItem;
    List: TMenuItem;
    Details: TMenuItem;
    N4: TMenuItem;
    ArrageIcons1: TMenuItem;
    ByName1: TMenuItem;
    ByType1: TMenuItem;
    BySize1: TMenuItem;
    LineupIcons1: TMenuItem;
    N5: TMenuItem;
    Refresh1: TMenuItem;
    Options1: TMenuItem;
    Help1: TMenuItem;
    HelpTopics1: TMenuItem;
    N6: TMenuItem;
    AboutContainermanager1: TMenuItem;
    Openanothercontainer1: TMenuItem;
    NewContainer1: TMenuItem;
    GOB1: TMenuItem;
    LFD1: TMenuItem;
    AddFiles1: TMenuItem;
    N7: TMenuItem;
    Extractfiles1: TMenuItem;
    OpenDialog1: TOpenDialog;
    LVDir: TListView;
    procedure FormCreate(Sender: TObject);
    procedure IconArrage(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    Dir:TContainerFile;
    DirControl:TMaskedDirectoryControl;
    LV:TSysLView;
    { Private declarations }
  public
   Procedure OpenFile(name:String);
    { Public declarations }
  end;

var
  ContMan: TContMan;

implementation

{$R *.DFM}

Procedure TContMan.OpenFile(name:String);
var
    j,i:integer;
    Txt:Array[0..100] of char;
    l:TStringList;
    sz:integer;
    b:LongBool;
begin
 Dir:=OpenContainer(name);
{ DirControl.SetDir(Dir);}
 l:=Dir.ListFiles;
 sz:=l.count;
{ DirControl.SetMask('*.*');}
 lv.ColumnWidth:=80;
 lv.SetColumn(0);
 lv.clear;
 for i:=0 to 999 do
 begin
  lv.ItemText:=l[i];
  lv.InsertItem(i);
  lv.SetSubItem(i,1,IntToStr(i));
 end;
if lv.GetSubItem(i,1)='' then;
end;

procedure TContMan.FormCreate(Sender: TObject);
begin
 LV:=TSysLView.Create(Self);
 LV.ColumnText:='Name';
 LV.InsertColumn(0);
 LV.ColumnText:='Number';
 LV.InsertColumn(1);
 {DirControl:=TMaskedDirectoryControl.CreateFromLV(LVDir);}
end;

procedure TContMan.IconArrage(Sender: TObject);
begin
 if Sender=SmallIcons then LV.ViewStyle:=LVS_SmallIcon
 else if Sender=LargeIcons then LV.ViewStyle:=LVS_Icon
 else if Sender=Details then LV.ViewStyle:=LVS_Report
 else if Sender=List then LV.ViewStyle:=LVS_List;
 TMenuItem(Sender).Checked:=true;
end;

procedure TContMan.Close1Click(Sender: TObject);
begin
 Close;
end;

procedure TContMan.FormResize(Sender: TObject);
begin
  LV.Resize(0,0,Clientwidth,ClientHeight-StatusBar.height);
end;

end.
