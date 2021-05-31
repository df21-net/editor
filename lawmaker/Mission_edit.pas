unit Mission_edit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, misc_utils, Files, FileOperations, GlobalVars;

type
  TMissionEdit = class(TForm)
    GroupBox1: TGroupBox;
    CBSolo: TCheckBox;
    BNRCS: TButton;
    GroupBox2: TGroupBox;
    CBHistoric: TCheckBox;
    BNRCA: TButton;
    GroupBox3: TGroupBox;
    CBMulti: TCheckBox;
    BNRCM: TButton;
    BNITM: TButton;
    BNCHK: TButton;
    LBMissionIs: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure CBClick(Sender: TObject);
    procedure BNRCSClick(Sender: TObject);
    procedure BNRCAClick(Sender: TObject);
    procedure BNRCMClick(Sender: TObject);
    procedure BNITMClick(Sender: TObject);
    procedure BNCHKClick(Sender: TObject);
  private
    { Private declarations }
    RCSName:String;
    RCAName:String;
    RCMName:String;
    Procedure SetHandlers;
    Procedure ClearHandlers;
    Function GetITMName:String;
    Function GetCHKName:String;
    Function LevelName:String;
    Function ProjDir:String;
  public
    { Public declarations }
    Procedure Reset;
    Procedure EditMission;
  end;

Function GetCHKFromITM(const ITM:String):String;

var
  MissionEdit: TMissionEdit;
Const
  NewRCS:String=
   'RCP 1.0'#13#10+
   'NAME:   Outlaws Story'#13#10+
   'FLAGS:  0'#13#10#13#10+
   'STORY:'#13#10+
   'BEGIN'#13#10+
   'LEVEL: %s'#13#10+
   'END'#13#10#13#10+
   'PATHS:  0';

  NewRCA:String=
   'RCP 1.0'#13#10+
   'NAME:   Marshal Training'#13#10+
   'FLAGS:  0'#13#10#13#10+
   'STORY:'#13#10+
   'BEGIN'#13#10+
   'LEVEL: %s'#13#10+
   'END'#13#10#13#10+
   'PATHS:  0';

  NewRCM:String=
   'RCP 1.0'#13#10+
   'NAME: %s'#13#10+
   '# c - capture the flag'#13#10+
   '# t - tag'#13#10+
   '# k - kill man with ball'#13#10+
   '# s - secret doc'#13#10+
   '# m - team play'#13#10+
   '# d - death match'#13#10+
   'MODES:	CKMD'#13#10#13#10+
   'STORY:'#13#10+
   'BEGIN'#13#10+
   'LEVEL: %s'#13#10+
   'END';

  NewITM:String=
   'ITEM 1.0'#13#10+
   'NAME %s'#13#10+
   'FUNC NULL'#13#10+
   'ANIM NULL'#13#10+
   'PRELOAD: %s.chk'#13#10+
   'DATA 1';

implementation

uses Mapper, LECScripts;

{$R *.DFM}

procedure TMissionEdit.FormCreate(Sender: TObject);
begin
 ClientWidth:=2*GroupBox1.Left+GroupBox1.Width;
 ClientHeight:=LBMissionIs.Top+GroupBox3.Top+GroupBox3.Height;
end;

Procedure TMissionEdit.Reset;
begin
 ClearHandlers;
 CBSolo.Checked:=false;
 CBHistoric.Checked:=false;
 CBMulti.Checked:=false;
 BNRCS.Enabled:=false;
 BNRCA.Enabled:=false;
 BNRCM.Enabled:=false;
 BNITM.Enabled:=false;
 BNCHK.Enabled:=false;
 SetHandlers;
end;

Procedure TMissionEdit.EditMission;
var sr:TSearchRec;
begin
 Reset;
 ClearHandlers;
 If FindFirst(ProjDir+'*.rcs',faAnyFile,sr)=0 then
  begin
   RCSName:=sr.Name; CBSolo.Checked:=true; BNRCS.Enabled:=true;
  end;
 FindClose(sr);
 If FindFirst(ProjDir+'*.rca',faAnyFile,sr)=0 then
  begin
   RCAName:=sr.Name; CBHistoric.Checked:=true; BNRCA.Enabled:=true;
  end;
 FindClose(sr);
 If FindFirst(ProjDir+'*.rcm',faAnyFile,sr)=0 then
  begin
   RCMName:=sr.Name;
   CBMulti.Checked:=true;
   BNRCM.Enabled:=true;
   BNITM.Enabled:=true;
   BNCHK.Enabled:=true;
  end;
 FindClose(sr);
 SetHandlers;
 ShowModal;
end;

Procedure TMissionEdit.SetHandlers;
begin
 CBSolo.OnClick:=CBClick;
 CBHistoric.OnClick:=CBClick;
 CBMulti.OnClick:=CBClick;
end;

Procedure TMissionEdit.ClearHandlers;
begin
 CBSolo.OnClick:=nil;
 CBHistoric.OnClick:=nil;
 CBMulti.OnClick:=nil;
end;

Function TMissionEdit.GetITMName:String;
begin
 Result:=LevelName+'.itm';
end;

Function GetCHKFromITM(const ITM:String):String;
var t:TLecTextFile;s,w:String;p:integer;
begin
 Result:='';
 t:=TLecTextFile.CreateRead(OpenFileRead(ITM,0));
 While not t.eof do
 begin
  T.Readln(s);
  p:=GetWord(s,1,w);
  if w='PRELOAD:' then begin GetWord(s,p,Result); break; end;
 end;
 t.FClose;
end;

Function TMissionEdit.GetCHKName:String;
begin
 Result:=GetCHKFromITM(ProjDir+GetITMName);
end;

procedure TMissionEdit.CBClick(Sender: TObject);
var CB:TCheckBox;
    FName:String;
    DefExt:String;
    FNew:String;
    sr:TSearchRec;
    t:TextFile;
begin
 CB:=(Sender as TCheckBox);
 if CB=CBSolo then Fname:=RCSName;
 if CB=CBHistoric then Fname:=RCAName;
 if CB=CBMulti then FName:=RCMName;
 case CB.Checked of
  false:
   begin
    if MsgBox('Do you really want to delete '+Fname+'?','Confirm',mb_YesNo)=idNo
     then begin ClearHandlers; CB.Checked:=true; SetHandlers; exit; end;
     DeleteFile(ProjDir+FName);
     if CB=CBSolo then BNRCS.Enabled:=false;
    if CB=CBHistoric then BNRCA.Enabled:=false;
    if CB=CBMulti then begin BNRCM.Enabled:=false; BNITM.Enabled:=false; BNCHK.Enabled:=false; end;
   end;
  true:
   begin
    if CB=CBSolo then begin defExt:='.rcs'; Fnew:=Format(NewRCS,[LevelName]); end;
    if CB=CBHistoric then begin defExt:='.rca'; Fnew:=Format(NewRCA,[LevelName]); end;
    if CB=CBMulti then begin DefExt:='.rcm'; Fnew:=Format(NewRCM,[LevelName,LevelName]); end;
     FName:=LevelName+DefExt;
     AssignFile(t,ProjDir+FName); Rewrite(t);
     Write(t,Fnew);
     CloseFile(t);
     if CB=CBMulti then
     begin

     if not FileExists(ProjDir+LevelName+'.itm') then
     begin
      AssignFile(t,ProjDir+LevelName+'.itm');ReWrite(t);
      Write(t,Format(NewITM,[LevelName,LevelName]));
      CloseFile(t);
     end;

     Fnew:=GetCHKName;
     if (Fnew='') or (not FileExists(Fnew)) then
     begin
      if FileExists(BaseDir+'Lmdata\usrlevel.chk') then
      CopyAllFile(BaseDir+'Lmdata\usrlevel.chk',ProjDir+LevelName+'.chk')
      else CopyAllFile(BaseDir+'usrlevel.chk',ProjDir+LevelName+'.chk')
     end;

     end;
    if CB=CBSolo then begin RCSName:=Fname; BNRCS.Enabled:=true; end;
    if CB=CBHistoric then begin RCAName:=FName; BNRCA.Enabled:=true; end;
    if CB=CBMulti then begin RCMName:=FName; BNRCM.Enabled:=true; BNITM.Enabled:=true; BNCHK.Enabled:=true; end;
   end;
 end;
end;

Function TMissionEdit.LevelName:String;
begin
 Result:=MapWIndow.LevelName;
end;

Function TMissionEdit.ProjDir:String;
begin
 Result:=MapWIndow.ProjectDirectory;
end;


procedure TMissionEdit.BNRCSClick(Sender: TObject);
begin
 ScriptEdit.OpenScript(ProjDir+RCSName);
end;

procedure TMissionEdit.BNRCAClick(Sender: TObject);
begin
 ScriptEdit.OpenScript(ProjDir+RCAName);
end;

procedure TMissionEdit.BNRCMClick(Sender: TObject);
begin
 ScriptEdit.OpenScript(ProjDir+RCMName);
end;

procedure TMissionEdit.BNITMClick(Sender: TObject);
begin
 ScriptEdit.OpenScript(ProjDir+GetITMName);
end;

procedure TMissionEdit.BNCHKClick(Sender: TObject);
begin
 ScriptEdit.OpenScript(ProjDir+GetCHKName);
end;

end.
