unit FileOperations;

{This unit contains the service functions and
 procedures for file and directory operations.}

interface
uses files, Classes, ComCTRLS, StdCtrls, SysUtils, GOBLFD, WAD, LAB;

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
 Constructor Create;
 Property mask:String read GetMask Write SetMask;
 Procedure AddTrailingAsterisks;
 Function Match(s:String):boolean;
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
 Procedure AddFile(s:string);
 Procedure ClearControl;
 Procedure BeginUpdate;
 Procedure EndUpdate;
end;

Function OpenFileRead(path:TFileName;mode:word):TFile;
Function OpenFileWrite(path:TFileName;mode:word):TFile;
Function IsContainer(path:TFileName):boolean;
Function OpenContainer(path:TFileName):TContainerFile;
Function ExtractExt(path:String):String;
Function ExtractPath(path:String):String;
Function ExtractName(path:String):String;

implementation

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
 if masks<>nil then masks.free;
 masks:=ParseMasks(s);
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
   Result:=Result or WildCardMatch(masks.Strings[j],s);
   if Result then break;
  end;
end;


Type
    ct_type=(ct_unknown,ct_gob,ct_wad,ct_lab);

Function WhatContainer(Path:String):ct_type;
var ext:String;
begin
 Result:=ct_unknown;
 if not FileExists(path) then exit;
 Ext:=UpperCase(ExtractFileExt(path));
 if ext='.WAD' then result:=ct_wad
 else if ext='.GOB' then result:=ct_gob
 else if ext='.LAB' then result:=ct_lab;
end;

Function IsContainer(path:TFileName):boolean;
begin
 Result:=WhatContainer(path)<>ct_unknown;
end;

Function OpenContainer(path:TFileName):TContainerFile;
begin
 Case WhatContainer(Path) of
  ct_gob: Result:=TGOBDirectory.CreateOpen(path);
  ct_wad: Result:=TWADDirectory.CreateOpen(path);
  ct_lab: Result:=TLABDirectory.CreateOpen(path);
 else Raise Exception.Create(Path+' is not a container');
 end;
end;


Function OpenFileRead(path:TFileName;mode:word):TFile;
begin
 Result:=TDiskFile.CreateRead(path);
end;

Function OpenFileWrite(path:TFileName;mode:word):TFile;
begin
 Result:=TDiskFile.CreateWrite(path);
end;

Procedure TMaskedDirectoryControl.ClearControl;
begin
Case Control_type of
 LBox: LbDir.Items.Clear;
 LView: LVdir.Items.Clear;
end;
end;

Procedure TMaskedDirectoryControl.SetDir(D:TContainerFile);
var s:String;i:integer;
begin
 Dir:=d;
if control_type=LBox then
begin
 s:=''; for i:=0 to d.AvgFileNameLength-1 do s:=s+Chr(Ord('A')+i);
 LBDir.Columns:=lBDir.Width div lBDir.canvas.TextWidth(s);
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

Function AddAsteriscs(mask:String):String;
var p,ps:pchar;
begin
 if mask='' then begin result:='*'; exit; end;
 Result:=mask;
 ps:=@result[1];
 Repeat
  p:=StrScan(ps,';'); if p=nil then break;
  if (p-1)^<>'*' then Insert('*',Result,p-@Result[1]+1);
  ps:=p+2;
 Until false;
 if Result[length(Result)] in ['*',';'] then
 else Result:=Concat(Result,'*');
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
  LBox: LBDir.Items.Add(s);
  LView: With LVDir.Items do
         begin
          Li:=Add;
          Li.Caption:=s;
         end;
 end;
end;


Procedure TMaskedDirectoryControl.SetMask(mask:string);
var Masks,Ts:TStringList;
    i,j:integer;s:string;
    match:boolean;
begin
 ClearControl;
 Mask:=AddAsteriscs(mask);
 Masks:=ParseMasks(mask);
 ts:=Dir.ListFiles;
 BeginUpdate;
 for i:=0 to ts.count-1 do
 begin
  s:=UpperCase(ts.Strings[i]);
  match:=false;
  for j:=0 to masks.count-1 do
  begin
   match:=match or WildCardMatch(masks.Strings[j],s);
   if match then begin AddFile(ts.Strings[i]); break; end;
  end;
 end;
 EndUpdate;
 masks.free;
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

end.
