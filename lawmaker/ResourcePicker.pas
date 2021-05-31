unit ResourcePicker;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, GlobalVars, misc_utils, ExtCtrls, Preview, Olh_Oll, Level,
  Buttons;

type
  TResPicker = class(TForm)
    ResList: TListBox;
    ImageList: TImageList;
    EBResName: TEdit;
    BNOK: TButton;
    BNCancel: TButton;
    TVGroups: TTreeView;
    BMPreview: TImage;
    Memo: TMemo;
    SBHelp: TSpeedButton;
    LBDetails: TLabel;
    LBTauntList: TListBox;
    BNToList: TButton;
    BNFromList: TButton;
    procedure ResListClick(Sender: TObject);
    procedure EBResNameChange(Sender: TObject);
    procedure BNOKClick(Sender: TObject);
    procedure ResListDblClick(Sender: TObject);
    procedure TVGroupsChange(Sender: TObject; Node: TTreeNode);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SBHelpClick(Sender: TObject);
    procedure LBTauntListClick(Sender: TObject);
    procedure BNToListClick(Sender: TObject);
    procedure BNFromListClick(Sender: TObject);
  private
    { Private declarations }
{    ProjDir:String;
    FLevel:TLevel;}
    Pv:TPreviewThread;
    CurTXGroup,
    CurPalGroup,
    CurSndGroup,
    CurITMGroup,
    CurMSCGroup,
    curNWXGroup:string;
    Procedure AddLabGroup(const Lab,mask:String;perm:Boolean);
    Procedure AddProjDirGroup(const mask:String);
    Procedure AddDirGroup(const dir,name,mask:String);
    Procedure SaveCurrentGroup(var s:String);
    procedure PickIDResListClick(Sender: TObject);
    procedure TauntsResListClick(Sender: TObject);
    procedure TauntsResListDblClick(Sender: TObject);
    Procedure SetTaunts(const taunts:string);
    Function GetTaunts:String;
    Procedure SetResName(const s:string); {Doesn't call OnChange}
    Procedure ChangeResName(const s:string); {Always calls OnChange}
  public
   Function PickTexture(const curTexture:String):String;
   Function PickItem(Const CurItem:String):String;
   Function PickPalette(Const curPal:string):String;
   Function PickFloorSound(Const curSound:String):String;
   Function PickSound(Const curSound:String):String;
   Function PickTaunts(Const curTaunts:String):String;
   Function PickMusic(Const curMsc:String):String;
   Function PickSectorName(const curSC:string):String;
   Function PickLevel(const CurLVT:string):string;
   Function PickMovie(const CurMovie:string):string;
   Function PickTXT(const CurTXT:string):string;
   Function PickCHK(const CurCHK:string):string;
   Function PickForCHK(const CurFile:string):string;
   Function PickAnim(Const curAnim:String):String;
   Function PickItemID(Const CurID:String):String;
   Function PickNWX(Const curNWX:string):String;
   Function PickGeneratee(Const curGen:String):String;
   Function PickDropItem(Const curItem:String):String;
   Procedure ClearGroups;
   Procedure ResetGroups(const curnode:String);
{   Property ProjectDirectory:String read ProjDir write ProjDir;
   Property Level:TLevel write FLevel;}
    { Public declarations }
  end;

var
  ResPicker: TResPicker;

implementation
uses Files, FileOperations, Mapper;

{$R *.DFM}

Procedure TResPicker.SetResName(const s:string);
var p:TNotifyEvent;
begin
 p:=EBResName.OnChange;
 EBResName.OnChange:=nil;
 EBResName.Text:=s;
 EBResName.OnChange:=p;
end;

Procedure TResPicker.ChangeResName(const s:string);
begin
 SetResName(s);
 if Assigned(EBResName.OnChange) then EBResName.OnChange(EBResName); 
end;

Procedure TResPicker.ClearGroups;
var i:integer;
    Lists:TList;
    List:TStringList;
begin
 Lists:=TList.Create;
 for i:=0 to TVGroups.Items.Count-1 do
 With TVGroups.Items[i] do
 begin
  List:=TStringList(Data);
  if List=nil then continue;
  if Lists.IndexOf(List)<>-1 then Continue;
  List.Free;
  Lists.Add(List);
  Data:=nil;
 end;
 Lists.Free;
 TVGroups.Items.Clear;
end;

Procedure TResPicker.SaveCurrentGroup(var s:String);
begin
 if TVGroups.Selected<>nil then s:=TVGroups.Selected.Text else s:='';
end;

Procedure TResPicker.ResetGroups(const curnode:String);
var Node:TTreeNode;
    i:Integer;
begin
 Node:=TVGroups.Items.GetFirstNode;
 for i:=0 to TVGroups.Items.Count-1 do
 With TVGroups.Items[i] do
 begin
  if Text=CurNode then
  begin
   Node:=TVGroups.Items[i];
   break;
  end;
 end;
 TVGroups.Selected:=Node;
{ TVGroupsChange(Nil,TVGroups.Items.GetFirstNode);
 TVGroups.Items[0].Focused:=true;}
end;

Procedure TResPicker.AddLabGroup(const Lab,mask:String;perm:Boolean);
var files,sl:TStringList; cf:TContainerFile;
    filemask:TWildCardMask;
    i:Integer;
begin

 Try
 if perm then cf:=OpenGameContainer(lab)
  else cf:=OpenContainer(lab);

 sl:=TStringList.Create;
 filemask:=TWildCardMask.Create;
 fileMask.Mask:=Mask;
 Files:=cf.ListFiles;
 for i:=0 to files.count-1 do
  if filemask.Match(Files[i]) then sl.Add(Files[i]);
  sl.Sorted:=true;
  sl.Sorted:=false;
 TVGroups.Items.AddObject(nil,ExtractName(lab),sl);
 if not perm then cf.Free;
  except
  on E:Exception do PanMessage(mt_Error,E.Message);
 else exit;
 end;
end;

Procedure TResPicker.AddProjDirGroup(const mask:String);
begin
 AddDirGroup(MapWindow.ProjectDirectory,'Project Directory',Mask);
end;

Procedure TResPicker.AddDirGroup(const dir,name,mask:String);
var sl:TStringList;
begin
 if Dir<>'' then
 begin
  sl:=TStringList.Create;
  ListDirMask(Dir,mask,sl);
  TVGroups.Items.AddObject(nil,Name,sl);
 end;
end;

Function TResPicker.PickSectorName(const curSC:string):String;
var i:integer;sl:TStringList;
begin
 ClearGroups;
 sl:=TStringList.Create;
 for i:=0 to MapWindow.Level.Sectors.Count-1 do
 With MapWindow.Level.Sectors[i] do
  if Name<>'' then sl.Add(Name);

 TVGroups.Items.AddObject(nil,'Named sectors',sl);
 sl:=TStringList.Create;
 sl.Add('SYSTEM');
 TVGroups.Items.AddObject(nil,'Special',sl);
 ResetGroups('Named sectors');
 ChangeResName(CurSC);
  if ShowModal=idOK then Result:=EBResName.Text else Result:=curSC;
end;

Function TResPicker.PickTexture(const curTexture:String):String;
begin
 ClearGroups;
 AddLabGroup(textures_lab,'*.pcx;*.atx',true);
 AddLabGroup(olpatch2_lab,'*.pcx;*.atx',true);
 AddProjDirGroup('*.pcx;*.atx');
 LoadOLH('textures.olh',TVGroups);
 ResetGroups(curTXGroup);
 ChangeResName(curTexture);

 if ShowModal=idOK then Result:=EBResName.Text else Result:=curTexture;
 SaveCurrentGroup(curTXGroup);
end;

Function TResPicker.PickPalette(Const curPal:string):String;
begin
 ClearGroups;
 AddLabGroup(Outlaws_lab,'*.pcx',true);
 LoadOLH('palettes.olh',TVGroups);
 AddProjDirGroup('*.pcx');
 ResetGroups(curPalGroup);
 ChangeResName(curPal+'.pcx');

 if ShowModal=idOK then Result:=ChangeFileExt(EBResName.Text,'') else Result:=curPal;
 SaveCurrentGroup(curPalGroup);
end;


Function TResPicker.PickItem(Const CurItem:String):String;
var sl:TStringList;
begin
 ClearGroups;
 AddLabGroup(weapons_lab,'*.itm',true);
 AddLabGroup(objects_lab,'*.itm',true);
 AddLabGroup(olpatch1_lab,'*.itm',true);
 AddLabGroup(olpatch2_lab,'*.itm',true);
 AddProjDirGroup('*.itm');
 sl:=TStringList.Create;
 sl.Add('PLAYER');
 sl.Add('STARTPOS');
 sl.Add('BALLSTAR');
 sl.Add('DOCSTART');
 sl.Add('FLAGSTAR');

 TVGroups.Items.AddObject(nil,'Special',sl);
 LoadOLH('objects.olh',TVGroups);

 ResetGroups(CurITMGroup);
 ChangeResName(curItem+'.itm');

 if ShowModal=idOK then Result:=ChangeFileExt(EBResName.Text,'') else Result:=curItem;
 SaveCurrentGroup(CurITMGroup);
end;


Function GetIDFromITM(const ITM:String):Integer;
var t:TLecTextFile;s,w:String;p:integer;
begin
 Result:=-1;
 t:=TLecTextFile.CreateRead(OpenGameFile(ITM));
 While not t.eof do
 begin
  T.Readln(s);
  p:=GetWord(s,1,w);
  if w<>'INT' then Continue;
  p:=GetWord(s,p,w);
  if w<>'USE_ID' then continue;
  GetWord(s,p,w);
  if not ValInt(w,Result) then Result:=-1;
  break;
 end;
 t.FClose;
end;


procedure TResPicker.PickIDResListClick(Sender: TObject);
var i:Integer;
begin
if ResList.ItemIndex<0 then exit;
i:=GetIDFromITM(ResList.Items[ResList.ItemIndex]);
if i<>-1 then SetResName(IntToStr(i));
 Pv.StartPreview(ResList.Items[ResList.ItemIndex]);
end;


Function TResPicker.PickItemID(Const CurID:String):String;
begin
 ClearGroups;
 LoadOLH('use_id.olh',TVGroups);
 AddProjDirGroup('*.itm');
 ResetGroups('');
 ResList.OnClick:=PickIDResListClick;
Try
 ChangeResName(curID);
 if ShowModal=idOK then Result:=ChangeFileExt(EBResName.Text,'') else Result:=curID;
Finally
 ResList.OnClick:=ResListClick;
end;
end;


Function TResPicker.PickSound(Const curSound:String):String;
var sl:TStringList;
begin
 ClearGroups;
 AddLabGroup(Sounds_lab,'*.wav',true);
 AddLabGroup(taunts_lab,'*.wav',true);
 sl:=TStringList.Create;
 sl.Add('NULL');
 TVGroups.Items.AddObject(nil,'Special',sl);
 LoadOLH('sounds.olh',TVGroups);
 AddProjDirGroup('*.wav');
 ResetGroups(curSndGroup);
 ChangeResName(CurSound);
 if ShowModal=idOK then Result:=EBResName.Text else Result:=curSound;
 SaveCurrentGroup(curSndGroup);
end;


procedure TResPicker.TauntsResListClick(Sender: TObject);
begin
 if ResList.ItemIndex>=0 then PV.StartPreview(ResList.Items[ResList.ItemIndex]);
end;

procedure TResPicker.TauntsResListDblClick(Sender: TObject);
begin
 BNToList.Click;
end;

Procedure TResPicker.SetTaunts(const taunts:string);
var ps,pc:Pchar;
    s:array[0..255] of char;
begin
 LBTauntList.Items.Clear;
 ps:=@Taunts[1];
 repeat
  pc:=StrScan(ps,',');
  if pc=nil then pc:=StrEnd(ps);
  LBTauntList.Items.Add(Trim(StrLCopy(s,ps,pc-ps)));
  ps:=pc+1;
 until pc^=#0;
end;

Function TResPicker.GetTaunts:String;
var i:integer;
begin
 Result:='';
 for i:=0 to LBTauntList.Items.Count-2 do
  Result:=Result+LBTauntList.Items[i]+',';
 Result:=Result+LBTauntList.Items[LBTauntList.Items.Count-1];
end;


Function TResPicker.PickTaunts(Const curTaunts:String):String;
begin
 ClearGroups;
 AddLabGroup(Sounds_lab,'*.wav',true);
 AddLabGroup(taunts_lab,'*.wav',true);
 AddProjDirGroup('*.wav');
 LoadOLH('sounds.olh',TVGroups);
 ResetGroups(curSndGroup);

  SaveCurrentGroup(curSndGroup);

  LBTauntList.Show;
  ResList.MultiSelect:=true;
  ResList.ExtendedSelect:=true;
  ResList.OnClick:=TauntsResListClick;
  ResList.OnDblClick:=TauntsResListDblClick;
  BNToList.Show;
  BNFromList.Show;
  EBResName.Hide;

 try
  SetTaunts(CurTaunts);
  if ShowModal=idOK then Result:=GetTaunts else Result:=curTaunts;
 finally
  SaveCurrentGroup(curSndGroup);
  ResList.MultiSelect:=false;
  ResList.ExtendedSelect:=false;
  ResList.OnClick:=ResListClick;
  ResList.OnDblClick:=ResListDblClick;
  LBTauntList.Hide;
  BNToList.Hide;
  BNFromList.Hide;
  EBResName.Show;
 end;
end;

Function TResPicker.PickNWX(Const curNWX:string):String;
begin
 ClearGroups;
 AddLabGroup(weapons_lab,'*.nwx',true);
 AddLabGroup(objects_lab,'*.nwx',true);
 AddLabGroup(olpatch2_lab,'*.nwx',true);
 AddProjDirGroup('*.nwx');
 LoadOLH('sprites.olh',TVGroups);
 ResetGroups(curNWXGroup);
 ChangeResName(curNWX);
 if ShowModal=idOK then Result:=EBResName.Text else Result:=curNWX;
 SaveCurrentGroup(curNWXGroup);
end;

Function TResPicker.PickGeneratee(Const curGen:String):String;
begin
 ClearGroups;
 AddLabGroup(weapons_lab,'*.nwx',true);
 AddLabGroup(objects_lab,'*.nwx',true);
 AddLabGroup(olpatch2_lab,'*.nwx',true);
 AddLabGroup(Sounds_lab,'*.wav',true);
 AddLabGroup(taunts_lab,'*.wav',true);
 AddLabGroup(weapons_lab,'*.itm',true);
 AddLabGroup(objects_lab,'*.itm',true);
 AddLabGroup(olpatch1_lab,'*.itm',true);
 AddLabGroup(olpatch2_lab,'*.itm',true);
 AddProjDirGroup('*.nwx;*.itm;*.wav');
 LoadOLH('objects.olh',TVGroups);
 LoadOLH('sprites.olh',TVGroups);
 LoadOLH('sounds.olh',TVGroups);
 ResetGroups('');
 ChangeResName(curGen);
 if ShowModal=idOK then Result:=EBResName.Text else Result:=curGen;
end;

Function TResPicker.PickDropItem(Const curItem:String):String;
begin
 ClearGroups;
 AddLabGroup(weapons_lab,'*.nwx',true);
 AddLabGroup(objects_lab,'*.nwx',true);
 AddLabGroup(olpatch2_lab,'*.nwx',true);
 AddLabGroup(weapons_lab,'*.itm',true);
 AddLabGroup(objects_lab,'*.itm',true);
 AddLabGroup(olpatch1_lab,'*.itm',true);
 AddLabGroup(olpatch2_lab,'*.itm',true);
 AddProjDirGroup('*.nwx;*.itm');
 LoadOLH('objects.olh',TVGroups);
 LoadOLH('sprites.olh',TVGroups);
 ResetGroups('');
 ChangeResName(curItem);
 if ShowModal=idOK then Result:=EBResName.Text else Result:=curItem;
end;

Function TResPicker.PickAnim(Const curAnim:String):String;
var sl:TStringList;
begin
 ClearGroups;
 AddLabGroup(objects_lab,'*.nwx;*.3do',true);
 AddLabGroup(weapons_lab,'*.nwx;*.3do',true);
 AddLabGroup(olpatch2_lab,'*.nwx',true);
 sl:=TStringList.Create;
 sl.Add('NULL');
 TVGroups.Items.AddObject(nil,'Special',sl);
 LoadOLH('objects.olh',TVGroups);
 LoadOLH('3dos.olh',TVGroups);
 AddProjDirGroup('*.nwx;*.3do');
 ResetGroups('');
 ChangeResName(CurAnim);
 if ShowModal=idOK then Result:=EBResName.Text else Result:=curAnim;
{ SaveCurrentGroup(curSndGroup);}
end;


Function TResPicker.PickFloorSound(Const curSound:String):String;
var sl:TStringList;
begin
 ClearGroups;
 AddLabGroup(Sounds_lab,'*.wav',true);
 sl:=TStringList.Create;
 sl.Add('NULL');
 TVGroups.Items.AddObject(nil,'Special',sl);
 AddProjDirGroup('*.wav');
 LoadOLH('sounds.olh',TVGroups);
 ResetGroups(CurSndGroup);
 if UpperCase(CurSound)<>'NULL' then
  ChangeResName(curSound+'.wav') else ChangeResName(CurSound);
 if ShowModal=idOK then Result:=ChangeFileExt(EBResName.Text,'') else Result:=curSound;
 SaveCurrentGroup(curSndGroup);
end;

Function TResPicker.PickMusic(Const curMsc:String):String;
var sl:TStringList;
begin
 ClearGroups;
 AddLabGroup(outlaws_lab,'*.msc',true);
 AddLabGroup(geo_lab,'*.msc',true);
 AddLabGroup(olpatch2_lab,'*.msc',true);
 sl:=TStringList.Create;
 sl.Add('NULL');
 TVGroups.Items.AddObject(nil,'Special',sl);
 AddProjDirGroup('*.msc');
 LoadOLH('music.olh',TVGroups);
 ResetGroups(curMSCGroup);
 ChangeResName(CurMsc);
 if ShowModal=idOK then Result:=EBResName.Text else Result:=curMsc;
 SaveCurrentGroup(curMSCGroup);
end;


Function TResPicker.PickLevel(const CurLVT:string):string;
begin
 ClearGroups;
 AddLabGroup(geo_lab,'*.lvt',true);
 AddProjDirGroup('*.lvt');
 ResetGroups('');
 ChangeResName(ChangeFileExt(CurLVT,'.lvt'));
 if ShowModal=idOK then Result:=EBResName.Text else Result:=curLVT;
 Result:=ChangeFileExt(Result,'');
end;

Function TResPicker.PickMovie(const CurMovie:string):string;
begin
 ClearGroups;
 AddDirGroup(GameDir,GameDir,'*.san');
 AddDirGroup(CDDir,CDDir,'*.san');
 AddProjDirGroup('*.san');
 LoadOLH('movies.olh',TVGroups);
 ResetGroups('');
 ChangeResName(CurMovie);
 if ShowModal=idOK then Result:=EBResName.Text else Result:=curMovie;
end;

Function TResPicker.PickTXT(const CurTXT:string):string;
begin
 ClearGroups;
 AddDirGroup(GameDir,GameDir,'*.txt');
 AddDirGroup(CDDir,CDDir,'*.txt');
 AddProjDirGroup('*.txt');
 ResetGroups('');
 ChangeResName(CurTxt);
 if ShowModal=idOK then Result:=EBResName.Text else Result:=curTxt;
end;


procedure TResPicker.ResListClick(Sender: TObject);
begin
 if ResList.ItemIndex<0 then exit;
 SetResName(ResList.Items[ResList.ItemIndex]);
 Pv.StartPreview(EBResName.Text);
end;

procedure TResPicker.EBResNameChange(Sender: TObject);
var i:Integer;
begin
 i:=ResList.Items.IndexOf(EBResName.Text);
 if i<>-1 then
 begin
  ResList.ItemIndex:=i;
{  ResListClick(ResList);}
 end;
end;

procedure TResPicker.BNOKClick(Sender: TObject);
begin
 ModalResult:=mrOk;
 Hide;
end;

procedure TResPicker.ResListDblClick(Sender: TObject);
begin
 BNOK.Click;
end;

procedure TResPicker.TVGroupsChange(Sender: TObject; Node: TTreeNode);
begin
 if Node.Data<>nil then ResList.Items.Assign(TStringList(Node.Data))
 else ResList.Items.Clear;
end;

procedure TResPicker.FormShow(Sender: TObject);
begin
 Pv:=TPreviewThread.Create(BMPreview,Memo,LBDetails);
end;

procedure TResPicker.FormHide(Sender: TObject);
begin
 Pv.Terminate;
 PV.Resume;
end;

procedure TResPicker.FormCreate(Sender: TObject);
begin
 ClientHeight:=BNOK.Top+BNOK.height+TVGroups.Top;
 ClientWidth:=ResList.Left+ResList.Width+TVGroups.Left;
end;

Function TResPicker.PickCHK(const CurCHK:string):string;
begin
 ClearGroups;
 AddLabGroup(geo_lab,'*.chk',true);
 AddProjDirGroup('*.chk');
 ResetGroups('');
 ChangeResName(CurCHK);
 if ShowModal=idOK then Result:=EBResName.Text else Result:=curCHK;
end;

Function TResPicker.PickForCHK(const CurFile:string):string;
begin
 ClearGroups;
 AddLabGroup(outlaws_lab,'*.phy',true);
 AddLabGroup(weapons_lab,'*.itm',true);
 AddLabGroup(objects_lab,'*.itm',true);
 AddLabGroup(olpatch1_lab,'*.itm',true);
 AddLabGroup(olpatch2_lab,'*.itm',true);
 AddProjDirGroup('*.itm;*phy');
 LoadOLH('objects.olh',TVGroups);
 ResetGroups('');
 ChangeResName(CurFile);
 if ShowModal=idOK then Result:=EBResName.Text else Result:=curFile;
end;

procedure TResPicker.SBHelpClick(Sender: TObject);
begin
 Application.HelpJump('Hlp_Resource_Picker');
end;

procedure TResPicker.LBTauntListClick(Sender: TObject);
begin
 if LBTauntList.ItemIndex>=0 then
  PV.StartPreview(LBTauntList.Items[LBTauntList.ItemIndex]);
end;

procedure TResPicker.BNToListClick(Sender: TObject);
var i:Integer; s:String;
begin
 for i:=0 to ResList.Items.Count-1 do
  if ResList.Selected[i] then
  begin
   s:=ResList.Items[i];
   if LBTauntList.Items.IndexOf(s)=-1 then LBTauntList.Items.Add(s);
  end;
end;

procedure TResPicker.BNFromListClick(Sender: TObject);
var i:integer;
begin
 for i:=LBTauntList.Items.Count-1 downto 0 do
  if LBTauntList.Selected[i] then LBTauntList.Items.Delete(i);
end;

end.
