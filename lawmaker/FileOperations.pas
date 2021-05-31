unit FileOperations;

{This unit contains the service functions and
 procedures for file and directory operations.}

interface
uses Windows, files, Classes, ComCTRLS, StdCtrls, SysUtils, Containers,
ProgressDialog, Forms, Graphics,ShlObj, GlobalVars;

Const
{OpenFileWrite flags}
     fm_Create=1; {Create new file}
     fm_LetReWrite=2;{Let rewrite file
                    if exists - OpenFileWrite}
     fm_AskUser=4; {Ask user if something}
     fm_CreateAskRewrite=fm_Create+fm_LetRewrite+fm_AskUser;
{OpenFileRead&Write flags}
     fm_Share=8;   {Let share file}
     fm_Buffered=16;


Type

TWildCardMask=class
private
 masks:TStringList;
 Procedure SetMask(s:string);
 Function GetMask:String;
Public
 Property mask:String read GetMask Write SetMask;
 Procedure AddTrailingAsterisks;
 Function Match(s:String):boolean;
 Destructor Destroy;override;
end;


TMaskedDirectoryControl=class
 Dir:TContainerFile;
 LBDir:TListBox;
 LVDir:TListView;
 Mask:String;
 control_type:(LBox,LView);
 LastViewStyle:TViewStyle;
 Constructor CreateFromLB(L:TlistBox); {ListBox}
 Constructor CreateFromLV(L:TlistView); {ListView}
 Procedure SetDir(D:TContainerFile);
 Procedure SetMask(mask:string);
Private
 Procedure AddFile(s:string;fi:TFileInfo);
 Procedure ClearControl;
 Procedure BeginUpdate;
 Procedure EndUpdate;
end;

TFileTStream=class(TStream)
 f:TFile;
 Constructor CreateFromTFile(af:TFile);
 function Read(var Buffer; Count: Longint): Longint; override;
 function Write(const Buffer; Count: Longint): Longint; override;
 function Seek(Offset: Longint; Origin: Word): Longint; override;
end;


Function OpenFileRead(const path:TFileName;mode:word):TFile;
Function OpenFileWrite(const path:TFileName;mode:word):TFile;
Function IsContainer(const path:TFileName):boolean;
Function IsInContainer(const path:TFileName):Boolean;
Function OpenContainer(const path:TFileName):TContainerFile;
Function OpenGameContainer(const path:TFileName):TContainerFile;
Function OpenGameFile(const name:TFileName):TFile;
{opens it just once and keeps it open then only returns references on it.
 Used for game data files}

Function ExtractExt(path:String):String;
Function ExtractPath(path:String):String;
Function ExtractName(path:String):String;
Procedure CopyFileData(Ffrom,Fto:TFile;size:longint);
Function CopyAllFile(const Fname,ToName:String):boolean;
Function BackupFile(const Name:String):String;
Procedure ListDirMask(const path,mask:String;sl:TStringList);
Function ChangeExt(path:String; const newExt:String):String;

implementation
var
 CopyBuf:array[0..$8000-1] of byte;
 Containers:TStringList;
 i:integer;
Function BackupFile(Const Name:String):String;
var cext:String;
begin
 cext:=ExtractExt(Name);
 Insert('~',cext,2);
 if length(cext)>4 then setLength(cext,4);
 Result:=ChangeFileExt(Name,cext);
 if FileExists(Result) then DeleteFile(Result);
 RenameFile(Name,Result);
end;

Procedure ListDirMask(const path,mask:String;sl:TStringList);
var sr:TSearchRec;
    Res:Integer;
    CurMask:array[0..128] of char;
    P,PM:Pchar;
begin
 sl.Clear;
 PM:=PChar(Mask);
Repeat
 p:=StrScan(PM,';');
 if p=nil then p:=StrEnd(PM);
 StrLCopy(CurMask,PM,P-PM);

 Res:=FindFirst(path+curMask,faAnyFile,sr);
 While Res=0 do
 begin
  if (Sr.Attr and (faVolumeID+faDirectory))=0 then sl.Add(sr.Name);
  Res:=FindNext(sr);
 end;
 FindClose(sr);
  if P^=#0 then break else PM:=P+1;
Until False;
end;

Function CopyAllFile(const Fname,ToName:String):boolean;
var f,f1:TFile;
begin
 Result:=true;
 f:=OpenFileRead(Fname,0);
 f1:=OpenFileWrite(ToName,0);
 CopyFileData(f,f1,f.Fsize);
 F.Fclose;
 f1.Fclose;
end;

Procedure CopyFileData(Ffrom,Fto:TFile;size:longint);
begin
While size>sizeof(CopyBuf) do
begin
 Ffrom.Fread(CopyBuf,sizeof(CopyBuf));
 Fto.FWrite(CopyBuf,sizeof(CopyBuf));
 dec(size,sizeof(CopyBuf));
end;
 Ffrom.Fread(CopyBuf,size);
 Fto.FWrite(CopyBuf,size);
end;

Function GetQuote(ps,quote:pchar):pchar;
var p,p1:pchar;
begin
 if ps^ in ['?','*'] then
  begin
   GetQuote:=ps+1;
   quote^:=ps^;
   (quote+1)^:=#0;
   exit;
  end;
 p:=StrScan(ps,'?'); if p=nil then p:=StrEnd(ps);
 p1:=StrScan(ps,'*'); if p1=nil then p1:=StrEnd(ps);
 if p>p1 then p:=p1;
 StrLCopy(quote,ps,p-ps);
 GetQuote:=p;
end;

Function WildCardMatch(mask,s:string):boolean;
var pmask,ps,p:pchar;
    quote:array[0..100] of char;
begin
{ mask[length(mask)+1]:=#0;
 s[length(s)+1]:=#0;}
 result:=false;
 pmask:=@mask[1];
 ps:=@s[1];
While Pmask^<>#0 do
begin
 pmask:=GetQuote(pmask,quote);
 case Quote[0] of
  '?': if ps^<>#0 then inc(ps);
  '*': begin
	p:=GetQuote(pmask,quote);
	if quote[0] in ['*','?'] then continue;
        if Quote[0]=#0 then begin ps:=StrEnd(ps); continue; end;
	pmask:=p;
	p:=StrPos(ps,quote);
	if p=nil then exit;
	ps:=p+StrLen(quote);
       end;
  else if StrLComp(ps,quote,StrLen(quote))=0 then inc(ps,StrLen(quote)) else exit;
 end;
end;
if ps^=#0 then result:=true;
end;

Function ParseMasks(m:string):TStringList;{ mask -> masks string list. ie to handle "*.txt;*.asc" type masks}
var p,ps:Pchar;
    s:array[0..255] of char;
    Msk:TStringList;
begin
 msk:=TStringList.Create;
 if m='' then
 begin
  Msk.Add('');
  Result:=msk;
  exit;
 end;
 ps:=@m[1];
 Repeat
  p:=StrScan(ps,';');
  if p=nil then p:=StrEnd(ps);
  StrLCopy(s,Ps,p-ps);
  Msk.Add(UpperCase(s));
  ps:=p; if ps^=';' then inc(ps);
 Until PS^=#0;
 Result:=msk;
end;


Procedure TWildCardMask.SetMask(s:string);
begin
 if masks<>nil then begin masks.free; Masks:=nil; end;
 masks:=ParseMasks(s);
end;

Destructor TWildCardMask.Destroy;
begin
 Masks.free;
end;

Function TWildCardMask.GetMask:String;
var i:Integer;
begin
 Result:='';
 for i:=0 to masks.count-1 do Result:=Concat(Result,masks[i]);
end;

Procedure TWildCardMask.AddTrailingAsterisks;
var i:integer;s:string;
begin
 for i:=0 to masks.count-1 do
 begin
  s:=masks[i];
  if s='' then s:='*'
  else if s[length(s)]<>'*' then s:=s+'*';
  masks[i]:=s; 
 end;
end;

Function TWildCardMask.Match(s:String):boolean;
var i:integer;
begin
  s:=UpperCase(s);
  Result:=false;
  for i:=0 to masks.count-1 do
  begin
   Result:=Result or WildCardMatch(masks.Strings[i],s);
   if Result then break;
  end;
end;


Type
    ct_type=(ct_unknown,ct_gob,ct_wad,ct_lab,ct_lfd,ct_notfound);

Function WhatContainer(Path:String):ct_type;
var ext:String;
begin
 Result:=ct_unknown;
 if not FileExists(path) then begin Result:=ct_notfound; exit; end;

 Ext:=UpperCase(ExtractFileExt(path));
 if ext='.WAD' then result:=ct_wad
 else if ext='.GOB' then result:=ct_gob
 else if ext='.LAB' then result:=ct_lab
 else if ext='.LFD' then result:=ct_lfd
end;

Function IsInContainer(const path:TFileName):Boolean;
begin
 Result:=Pos('>',path)<>0;
end;

Function IsContainer(Const path:TFileName):boolean;
begin
 Result:=WhatContainer(path)<>ct_unknown;
end;

Function OpenContainer(Const path:TFileName):TContainerFile;
begin
 Case WhatContainer(Path) of
  ct_gob: Result:=TGOBDirectory.CreateOpen(path);
  ct_wad: Result:=TWADDirectory.CreateOpen(path);
  ct_lab: Result:=TLABDirectory.CreateOpen(path);
  ct_lfd: Result:=TFLDDirectory.CreateOpen(path);
  ct_notfound: Raise Exception.Create(Path+' not found');
 else Raise Exception.Create(Path+' is not a container');
 end;
end;


Function OpenFileRead(Const path:TFileName;mode:word):TFile;
var ps,i:Integer;
    ContName:String;
    cf:TContainerFile;
begin
 result:=nil;
 ps:=Pos('>',path);
 if ps=0 then Result:=TDiskFile.CreateRead(path)
 else
 begin
  ContName:=Copy(path,1,ps-1);
  i:=Containers.IndexOf(ContName);
  if i<>-1 then cf:=TContainerFile(Containers.Objects[i])
  else
   begin
    if Containers.Count>10 then
     for i:=0 to Containers.Count-1 do
     With Containers.Objects[i] as TContainerFile do
      if not Permanent then begin Free; Containers.Delete(i); break; end;
    cf:=OpenContainer(ContName);
    Containers.AddObject(ContName,cf);
   end;
  Result:=cf.OpenFile(ExtractName(Path),0);
 end;
end;

Function OpenGameContainer(const path:string):TContainerFile;
var i:Integer;
begin
 i:=Containers.IndexOf(Path);
  if i<>-1 then result:=TContainerFile(Containers.Objects[i])
  else
   begin
    Result:=OpenContainer(Path);
    Containers.AddObject(Path,Result);
   end;
 Result.Permanent:=true;
end;

Function OpenGameFile(const name:TFileName):TFile;
var cf:TContainerFile;ext:String;

function IsInLab(const LabName,FName:String):Boolean;
begin
Try
 cf:=OpenGameContainer(LabName);
 Result:=cf.ListFiles.IndexOf(Fname)<>-1;
except
 On Exception do Result:=false;
end;
end;

begin
 Result:=nil;
 if FileExists(ProjectDir+Name) then
 begin
  Result:=OpenFileRead(ProjectDir+Name,0);
  exit;
 end;
 ext:=UpperCase(ExtractExt(name));
 if (ext='.PCX') or (ext='.ATX') then
 begin
  if IsInLab(olpatch2_lab,Name) then
   begin Result:=OpenFileRead(olpatch2_lab+'>'+name,0); exit; end;
  if IsInLab(textures_lab,Name) then
   begin Result:=OpenFileRead(textures_lab+'>'+name,0); exit; end;
  if IsInLab(Outlaws_lab,Name) then
   begin Result:=OpenFileRead(Outlaws_lab+'>'+name,0); exit; end;
 end;

 if ext='.ITM' then
 begin
  if IsInLab(olpatch2_lab,Name) then
   begin Result:=OpenFileRead(olpatch2_lab+'>'+name,0); exit; end;
  if IsInLab(olpatch1_lab,Name) then
   begin Result:=OpenFileRead(olpatch1_lab+'>'+name,0); exit; end;

  if IsInLab(objects_lab,Name) then
   begin Result:=OpenFileRead(objects_lab+'>'+name,0); exit; end;
  if IsInLab(weapons_lab,Name) then
   begin Result:=OpenFileRead(weapons_lab+'>'+name,0); exit; end;
 end;

if ext='.NWX' then
 begin
  if IsInLab(olpatch2_lab,Name) then
   begin Result:=OpenFileRead(olpatch2_lab+'>'+name,0); exit; end;
  if IsInLab(objects_lab,Name) then
   begin Result:=OpenFileRead(objects_lab+'>'+name,0); exit; end;
  if IsInLab(weapons_lab,Name) then
   begin Result:=OpenFileRead(weapons_lab+'>'+name,0); exit; end;
 end;


if ext='.WAV' then
 begin
  if IsInLab(sounds_lab,Name) then
   begin Result:=OpenFileRead(sounds_lab+'>'+name,0); exit; end;
  if IsInLab(taunts_lab,Name) then
   begin Result:=OpenFileRead(taunts_lab+'>'+name,0); exit; end;
 end;
 {Other files}
  if IsInLab(olpatch2_lab,Name) then
   begin Result:=OpenFileRead(olpatch2_lab+'>'+name,0); exit; end;

  if IsInLab(olpatch1_lab,Name) then
   begin Result:=OpenFileRead(olpatch1_lab+'>'+name,0); exit; end;


  if IsInLab(outlaws_lab,Name) then
   begin Result:=OpenFileRead(outlaws_lab+'>'+name,0); exit; end;

end;

Function OpenFileWrite(Const path:TFileName;mode:word):TFile;
begin
 Result:=TDiskFile.CreateWrite(path);
end;

Procedure TMaskedDirectoryControl.ClearControl;
begin
Case Control_type of
 LBox:begin
        LbDir.Items.BeginUpdate;
        LbDir.Items.Clear;
        LbDir.Items.EndUpdate;
      end;  
 LView:begin
        LVDir.Items.BeginUpdate;
        LVdir.Items.Clear;
        LVDir.Items.EndUpdate;
       end;
end;
end;

Procedure TMaskedDirectoryControl.SetDir(D:TContainerFile);
var i:integer;
    lc:TListColumn;
    Canvas:TCanvas;
    FontWidth:Integer;
Function LineWidth(n:Integer):Integer;
begin
 Result:=n*Fontwidth;
end;

begin
 Dir:=d;
 if d=nil then exit;
 case control_type of
  LBox: FontWidth:=LBDir.Font.size;
  Lview: FontWidth:=LVDir.Font.size;
 end;

Case control_type of
LBox:begin
      LBDir.Columns:=lBDir.Width div LineWidth(Dir.GetColWidth(0));
     end;
LView:begin
       LVDir.Columns.Clear;
       for i:=0 to Dir.ColumnCount-1 do
       begin
        lc:=LVDir.Columns.Add;
        lc.Caption:=Dir.GetColName(i);
        lc.Width:=LineWidth(Dir.GetColWidth(i));
       end;
      end;
end;
end;

Constructor TMaskedDirectoryControl.CreateFromLB(L:TlistBox);
begin
 LBDir:=l;
 control_type:=LBox;
 Mask:='*.*';
end;

Constructor TMaskedDirectoryControl.CreateFromLV(L:TlistView);
begin
 LVDir:=l;
 control_type:=LView;
 Mask:='*.*'
end;

Procedure TMaskedDirectoryControl.BeginUpdate;
begin
 Case Control_type of
  LBox: begin
         LBDir.Sorted:=false;
         LBDir.Items.BeginUpdate;
        end;
  LView: begin
          LastViewStyle:=LVDir.ViewStyle;
          LVDir.ViewStyle:=vsReport;
          LVDir.Items.BeginUpdate;
         end;
 end;
end;

Procedure TMaskedDirectoryControl.EndUpdate;
begin
 Case Control_type of
  LBox: begin
         LBDir.Items.EndUpdate;
        end;
  LView: begin
          LVDir.ViewStyle:=LastViewStyle;
          LVDir.Items.EndUpdate;
         end;
 end;
end;


procedure TMaskedDirectoryControl.AddFile;
var LI:TListItem;
begin
 Case Control_type of
  LBox: LBDir.Items.AddObject(s,fi);
  LView: With LVDir.Items do
         begin
          Li:=Add;
          Li.Caption:=s;
          Li.SubItems.Add(IntToStr(fi.Size));
          Li.ImageIndex:=0;
          Li.Data:=fi;
         end;
 end;
end;


Procedure TMaskedDirectoryControl.SetMask(mask:string);
var Ts:TStringList;
    i:integer;s:string;
    Matcher:TWildCardMask;
begin
 if Dir=nil then exit;
 ClearControl;
 Matcher:=TWildCardMask.Create;
 Matcher.Mask:=Mask;
 ts:=Dir.ListFiles;
 BeginUpdate;
 Progress.Reset(ts.count);
 for i:=0 to ts.count-1 do
 begin
   if Matcher.Match(ts[i]) then AddFile(ts[i],TFileInfo(ts.Objects[i]));
   Progress.Step;
 end;
 Progress.Hide;
 EndUpdate;
 Matcher.free;
end;

Function ExtractExt(path:String):String;
var p:integer;
begin
 p:=Pos('>',path);
 if p<>0 then path[p]:='\';
 Result:=ExtractFileExt(path);
end;

Function ExtractPath(path:String):String;
var p:integer;
begin
 p:=Pos('>',path);
 if p<>0 then path[p]:='\';
 Result:=ExtractFilePath(Path);
 if p<>0 then Result[p]:='>';
end;

Function ExtractName(path:String):String;
var p:integer;
begin
 p:=Pos('>',path);
 if p<>0 then path[p]:='\';
 Result:=ExtractFileName(Path);
end;

Function ChangeExt(path:String;const newExt:String):String;
var p:integer;
begin
 p:=Pos('>',path);
 if p<>0 then path[p]:='\';
 Result:=ChangeFileExt(Path,newExt);
 if p<>0 then Result[p]:='>';
end;

Constructor TFileTStream.CreateFromTFile(af:TFile);
begin
 f:=af;
end;

function TFileTStream.Read(var Buffer; Count: Longint): Longint;
begin
 Result:=F.Fread(Buffer,Count);
end;

function TFileTStream.Write(const Buffer; Count: Longint): Longint;
begin
 Result:=F.FWrite(Buffer,Count);
end;

function TFileTStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
 Case ORigin of
  soFromBeginning: begin F.Fseek(Offset); Result:=Offset; end;
    soFromCurrent: begin F.FSeek(F.FPos+Offset); Result:=F.Fpos; end;
        soFromEnd: begin F.FSeek(F.Fsize+Offset); Result:=F.FPos; end;
 end;
end;


Initialization
begin
 Containers:=TStringList.Create;
end;

Finalization
begin
 for i:=0 to Containers.Count-1 do Containers.Objects[i].Free;
 Containers.Free;
end;


end.
