unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  FileDialogs, StdCtrls, misc_utils, Files, FileOperations, DragOut,
  Containers, Level, Mapper, M_ScEdit, graph_files, Images, ExtCtrls,
  MMSystem;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Image: TImage;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses ContManager, ResourcePicker, FlagEditor;

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
begin
 GetFileOpen.FileName:='1\night.gob>jedi.lvl';
 GetFileOpen.Filter:='LEV|*.LEV|GOB|*.GOB';
 GetFileOpen.Execute;
 if GetFileOpen.FileName='' then;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
 ConMan.OpenFile('F:\dark\textures.gob');
 ConMan.ShowModal;
end;

procedure TForm1.Button5Click(Sender: TObject);
var d:TContainerFile;
    g:TContainerCreator;
    i:Integer;
    l:TStringList;
    f:TFile;
begin
 d:=OpenContainer('1\night.gob');
 g:=TLFDCreator.Create('1.lfd');
 l:=d.ListFiles;
 g.PrepareHeader(l);
 for i:=0 to l.count-1 do
 begin
  f:=d.OpenFile(l[i],0);
  g.AddFile(f);
  f.Fclose;
 end;
 g.Free;
 d.Free;
end;

procedure TForm1.Button6Click(Sender: TObject);
var l:TLevel;
begin
 MapWindow.Show;
 {MapWindow.OpenLevel('f:\outlaws\olgeo.lab>drygulch.lvt');}
end;

procedure TForm1.Button7Click(Sender: TObject);
var i,h:integer;
    d:double;
    s:String;
begin
{ i:=FlagEdit.EditSectorFlags(-1);
 i:=FlagEdit.EditWallFlags(i);
 i:=FlagEdit.EditObjectFlags1(i);
 i:=FlagEdit.EditObjectFlags2(i);
 i:=FlagEdit.EditLevelITMFlags(i);}
{ ResPicker.ProjectDirectory:='D:\RR\Delph\LawMaker\New\';
 s:=ResPicker.PickSound('STARTPOS');

 ResPicker.ProjectDirectory:='D:\RR\Delph\LawMaker\New\';
 s:=ResPicker.PickPalette('RANCH.PCX');

 ResPicker.ProjectDirectory:='D:\RR\Delph\LawMaker\New\';
 s:=ResPicker.PickTexture('RANCH.PCX');}
end;

procedure TForm1.Button8Click(Sender: TObject);
var pcx:TPcx;bm:TBitmap;
    f:TFile;
    a:boolean;
    PWav:Pointer;
begin
 pcx:=TPcx.Create(OpenFileRead('D:\RR\Delph\LawMaker\1.PCX',0));
 bm:=Pcx.LoadBitmap(-1,-1);
 Image.Picture.Bitmap:=bm;
 bm.Free;
 Pcx.Free;

  f:=OpenGameFile('a.a');
  GetMem(PWav,F.Fsize);
  F.Fread(PWav^,F.Fsize);
  F.Fclose;
  a:=PlaySound(PWav,0,SND_NODEFAULT or SND_MEMORY or SND_ASYNC);
  if a then;
end;

end.
