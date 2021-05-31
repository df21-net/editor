unit ContManager;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ComCtrls, CommCtrl, Files, FileOperations, ExtCtrls, misc_utils,
  ShellApi, Containers, Clipbrd, DragOut;

type
  TConMan = class(TForm)
    StatusBar: TStatusBar;
    MainMenu: TMainMenu;
    File1: TMenuItem;
    Close1: TMenuItem;
    N1: TMenuItem;
    Edit1: TMenuItem;
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
    AddFiles: TMenuItem;
    N7: TMenuItem;
    Extractfiles1: TMenuItem;
    AddDialog: TOpenDialog;
    LVDir: TListView;
    LargeImages: TImageList;
    SmallImages: TImageList;
    SaveDialog: TSaveDialog;
    LAB1: TMenuItem;
    NewConDialog: TSaveDialog;
    OpenDialog: TOpenDialog;
    DeleteFiles: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure IconArrage(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure Openanothercontainer1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure AboutContainermanager1Click(Sender: TObject);
    procedure ByName1Click(Sender: TObject);
    procedure ByType1Click(Sender: TObject);
    procedure BySize1Click(Sender: TObject);
    procedure Extractfiles1Click(Sender: TObject);
    procedure Refresh1Click(Sender: TObject);
    procedure SelectAll1Click(Sender: TObject);
    procedure InvertSelection1Click(Sender: TObject);
    procedure LVDirColumnClick(Sender: TObject; Column: TListColumn);
    procedure HelpTopics1Click(Sender: TObject);
    procedure NewContainerClick(Sender: TObject);
    procedure AddFilesClick(Sender: TObject);
    procedure DeleteFilesClick(Sender: TObject);
    procedure Paste1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure LVDirMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    Dir:TContainerFile;
    DirControl:TMaskedDirectoryControl;
    FGiver:TGiveFiles;
    { Private declarations }
   Procedure ExtractFile(inFile:TFile;outFile:String);
   Procedure WMDropFiles(var msg:TWMDropFiles);message WM_DROPFILES;
   Procedure DoAddFiles(newfiles:TStrings);
   Procedure ProcessHDrop(Hdrop:Integer);
  public
   Procedure OpenFile(name:String);
    { Public declarations }
  end;

var
  ConMan: TConMan;

implementation

uses ProgressDialog, AboutCntMan;

{$R *.DFM}

Procedure TConMan.OpenFile(name:String);
begin
 if FGiver<>nil then begin Fgiver.Free; FGiver:=nil; end;
 if Dir<>nil then begin Dir.Free; Dir:=nil; end;
 LVDir.Items.BeginUpdate;
 LVDir.Items.Clear;
 LVDir.Items.EndUpdate;
 Dir:=OpenContainer(name);
 DirControl.SetDir(Dir);
 DirControl.SetMask('*');
 StatusBar.Panels[0].Text:=IntToStr(Dir.Files.Count)+' files';
 Caption:='Container Manager - '+Name;
 AddFiles.Enabled:=true;
 DeleteFiles.Enabled:=true;
 end;

procedure TConMan.FormCreate(Sender: TObject);
begin
 DirControl:=TMaskedDirectoryControl.CreateFromLV(LVDir);
 DragAcceptFiles(Handle,true);
end;

procedure TConMan.IconArrage(Sender: TObject);
begin
 if Sender=SmallIcons then LVDir.ViewStyle:=vsSmallIcon
 else if Sender=LargeIcons then LVDir.ViewStyle:=vsIcon
 else if Sender=Details then LVDir.ViewStyle:=vsReport
 else if Sender=List then LVDir.ViewStyle:=vsList;
 TMenuItem(Sender).Checked:=true;
end;

procedure TConMan.Close1Click(Sender: TObject);
begin
 Close;
end;

procedure TConMan.Openanothercontainer1Click(Sender: TObject);
begin
if OpenDialog.Execute then
begin
 OpenFile(OpenDialog.FileName);
end;
end;

procedure TConMan.FormDestroy(Sender: TObject);
begin
 DirControl.Free;
 DragAcceptFiles(Handle,false);
end;

procedure TConMan.AboutContainermanager1Click(Sender: TObject);
begin
 AboutContMan.ShowModal;
end;

procedure TConMan.ByName1Click(Sender: TObject);
begin
 LvDir.AlphaSort;
end;

function CompareExts(Item1, Item2: TListItem; ParamSort: Integer): Integer; stdcall;
var ext1,ext2:String;
begin
 ext1:=UpperCase(ExtractFileExt(Item1.Caption));
 ext2:=UpperCase(ExtractFileExt(Item2.Caption));
 Result:=StrComp(Pchar(ext1),pchar(ext2));
end;

procedure TConMan.ByType1Click(Sender: TObject);
begin
 LvDir.CustomSort(@CompareExts,0);
end;

function CompareSizes(Item1, Item2: TListItem; ParamSort: Integer): Integer; stdcall;
var size1,size2:Longint;
begin
 size1:=TFileInfo(Item1.Data).Size;
 size2:=TFileInfo(Item2.Data).Size;
 if size1>size2 then result:=1
 else if size1=size2 then result:=0
 else result:=-1;
end;


procedure TConMan.BySize1Click(Sender: TObject);
begin
 LVDir.CustomSort(@CompareSizes,0);
end;

procedure TConMan.Extractfiles1Click(Sender: TObject);
var i:integer;
    TagetDir:String;
begin
 if LVDir.SelCount=0 then begin MsgBox('Select some files first','No, no, no!',mb_ok); exit; end;
 SaveDialog.FileName:=LVDir.Selected.Caption;
 if SaveDialog.Execute then
 begin
  TagetDir:=ExtractFilePath(SaveDialog.FileName);
  Progress.Reset(LVDir.SelCount);
  Progress.Msg:='Extracting files...';
  for i:=0 to LvDir.Items.Count-1 do
   With LVDir.Items[i] do
   if Selected then
   begin
    Progress.Step;
    ExtractFile(Dir.OpenFileByFI(TFileInfo(Data)),TagetDir+Caption);
   end;
 end;
Progress.Hide;
end;

Procedure TConMan.ExtractFile(inFile:TFile;outFile:String);
var
    fout:TFile;
    bytes:longint;
    Buf:Array[0..$8000-1] of byte;
begin
 fout:=OpenFileWrite(outFile,fm_create+fm_letRewrite+fm_AskUser);
bytes:=inFile.Fsize;

Try
While bytes>sizeof(buf) do
begin
 inFile.Fread(buf,sizeof(buf));
 fout.FWrite(buf,sizeof(buf));
 dec(bytes,sizeof(buf));
end;
 inFile.Fread(buf,bytes);
 fout.FWrite(buf,bytes);
Finally
 inFile.Fclose;
 Fout.Fclose;
end;
end;

procedure TConMan.Refresh1Click(Sender: TObject);
begin
 if Dir<>nil then OpenFile(Dir.GetFullName);
end;

procedure TConMan.SelectAll1Click(Sender: TObject);
var i:Integer;
begin
With LVDir.Items do
begin
 BeginUpdate;
 For i:=0 to Count-1 do Item[i].Selected:=True;
 EndUpdate;
end;
end;

procedure TConMan.InvertSelection1Click(Sender: TObject);
var i:Integer;
begin
With LVDir.Items do
begin
 BeginUpdate;
 For i:=0 to Count-1 do With Item[i] do Selected:=Not Selected;
 EndUpdate;
end;
end;

Procedure TConMan.ProcessHDrop(Hdrop:Integer);
var s:array[0..255] of char;
    i:integer;
    files:TStringList;
begin
 files:=TStringList.Create;
 for i:=0 to DragQueryFile(Hdrop,-1,s,sizeof(s))-1 do
 begin
  DragQueryFile(HDrop,i,s,sizeof(s));
  files.Add(s);
 end;
Try
 DoAddFiles(files);
finally
 files.free;
end;
end;

Procedure TConMan.WMDropFiles(var msg:TWMDropFiles);
begin
 ProcessHDrop(msg.drop);
 DragFinish(msg.drop);
end;

procedure TConMan.LVDirColumnClick(Sender: TObject; Column: TListColumn);
begin
 Case Column.Index of
  0: LvDir.AlphaSort;
  1: LvDir.CustomSort(@CompareSizes,0);
 end;
end;

procedure TConMan.HelpTopics1Click(Sender: TObject);
begin
 Application.HelpJump('Hlp_Container_Manager');
end;

procedure TConMan.NewContainerClick(Sender: TObject);
var newCon,cdir:String;
    cc:TContainerCreator;
    files:TStringList;
    i:integer;
    f:TFile;
begin
 With NewConDialog do
 begin
  if Sender=LAB1 then
  begin
   DefaultExt:='lab';
   FileName:='Untitled.lab';
   Filter:='LAB files|*.lab';
  end;
  if Sender=GOB1 then
  begin
   DefaultExt:='gob';
   FileName:='Untitled.gob';
   Filter:='GOB files|*.gob';
  end;
  if Sender=LFD1 then
  begin
   DefaultExt:='lfd';
   FileName:='Untitled.lfd';
   Filter:='LFD files|*.lfd';
  end;
  If not Execute then exit;
  newCon:=FileName;
 end;
 if not AddDialog.Execute then exit;

 if Sender=LAB1 then cc:=TLABCreator.Create(NewCon);
 if Sender=LFD1 then cc:=TLFDCreator.Create(NewCon);
 if Sender=GOB1 then cc:=TGOBCreator.Create(NewCon);
{ cDir:=ExtractFilePath(AddDialog.FileName);}
 Files:=TStringList.Create;
 Files.Assign(AddDialog.Files);
try
 cc.prepareHeader(files);
 Progress.Reset(files.count);
 for i:=0 to files.count-1 do
 begin
  Progress.Step;
  f:=OpenFileRead(Files[i],0);
  cc.AddFile(f);
  f.Fclose;
 end;
finally
 Files.free;
 cc.Free;
 Progress.Hide;
end;
OpenFile(NewCon);
end;

Procedure TConMan.DoAddFiles(newfiles:TStrings);
var oldCon,newCon,Fname:String;
    cc:TContainerCreator;
    files:TStringList;
    i,nolds:integer;
    f:TFile;
begin
if Dir=nil then exit;
oldCon:=Dir.Name;
newCon:=Format('%s%s%x%s',[ExtractFileName(OldCon),'new',Integer(newFiles),ExtractFileExt(OldCon)]);
cc:=Dir.GetContainerCreator(NewCon);
Files:=TStringList.Create;
Files.Assign(Dir.ListFiles);
For i:=0 to newFiles.Count-1 do
begin
 Fname:=ExtractName(NewFiles[i]);
 nolds:=files.IndexOf(fname);
 if nolds<>-1 then files.Delete(nolds);
end;
nolds:=files.Count;
Files.AddStrings(NewFiles);
try
 cc.prepareHeader(files);
 Progress.Reset(files.count);
 for i:=0 to nOlds-1 do
 begin
  Progress.Step;
  f:=Dir.OpenFile(Files[i],0);
  cc.AddFile(f);
  f.Fclose;
 end;

 for i:=nolds to files.count-1 do
 begin
  Progress.Step;
  f:=OpenFileRead(Files[i],0);
  cc.AddFile(f);
  f.Fclose;
 end;
finally
 cc.Free;
 Progress.Hide;
 Files.free;
end;
Dir.Free; Dir:=nil;
BackUpFile(OldCon);
RenameFile(NewCon,OldCon);
OpenFile(OldCon);
end;

procedure TConMan.AddFilesClick(Sender: TObject);
begin
if not AddDialog.Execute then exit;
 DoAddFiles(AddDialog.Files);
end;

procedure TConMan.DeleteFilesClick(Sender: TObject);
var oldCon,newCon:String;
    cc:TContainerCreator;
    tfiles,files:TStringList;
    i,nolds:integer;
    f:TFile;
begin
if LVDir.SelCount=0 then begin MsgBox('Select some files first','No, no, no!',mb_ok); exit; end;
oldCon:=Dir.Name;
newCon:=Format('%s%s%x%s',[ExtractFileName(OldCon),'new',Integer(sender),ExtractFileExt(OldCon)]);
cc:=Dir.GetContainerCreator(NewCon);
Files:=TStringList.Create;
 for i:=0 to LvDir.Items.Count-1 do
 With LVDir.Items[i] do
 if not Selected then Files.AddObject(Caption,TFileInfo(Data));
try
 cc.prepareHeader(files);
 Progress.Reset(files.count);
 for i:=0 to Files.count-1 do
 begin
  Progress.Step;
  f:=Dir.OpenFileByFI(TFileInfo(Files.Objects[i]));
  cc.AddFile(f);
  f.Fclose;
 end;

finally
 Files.free;
 cc.Free;
 Progress.Hide;
end;
Dir.Free; Dir:=nil;
BackUpFile(OldCon);
RenameFile(NewCon,OldCon);
OpenFile(OldCon);
end;

procedure TConMan.Paste1Click(Sender: TObject);
var clp:TClipboard;
    hdrop:integer;
begin
 clp:=Clipboard;
 if clp.HasFormat(CF_HDROP) then
 begin
  hdrop:=clp.GetAsHandle(CF_HDROP);
  ProcessHDrop(hdrop);
  {DragFinish(hdrop);}
 end;
end;

procedure TConMan.Copy1Click(Sender: TObject);
var i:integer;
begin
 if Dir=nil then exit;
 FGiver:=TGiveFiles.Create(Dir);
 for i:=0 to LvDir.Items.Count-1 do
 With LVDir.Items[i] do
 if Selected then FGiver.AddFile(Caption,TFileInfo(Data));
 FGiver.CopyIt;
end;

procedure TConMan.FormHide(Sender: TObject);
begin
 if FGiver<>nil then begin Fgiver.Free; FGiver:=nil; end;
end;

procedure TConMan.LVDirMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var i:integer;
    li:TListItem;
begin
 if not (ssLeft in shift) then exit;
 li:=LVDir.GetItemAt(X,Y);
 if (li=nil) or (not li.selected) then exit;
 if Dir=nil then exit;
 if FGiver<>nil then begin Fgiver.Free; FGiver:=nil; end;
 FGiver:=TGiveFiles.Create(Dir);
 for i:=0 to LvDir.Items.Count-1 do
 With LVDir.Items[i] do
 if Selected then FGiver.AddFile(Caption,TFileInfo(Data));
 DragAcceptFiles(Handle,false);
 FGiver.DragIt;
 DragAcceptFiles(Handle,true);
end;

end.
