unit MsgPick;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, ExtCtrls;

type
  TMsgPicker = class(TForm)
    Panel1: TPanel;
    MsgList: TListBox;
    BNOK: TButton;
    BNCancel: TButton;
    SBHelp: TSpeedButton;
    LBDetails: TLabel;
    BNFind: TButton;
    FindText: TFindDialog;
    procedure MsgListClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BNFindClick(Sender: TObject);
    procedure FindTextFind(Sender: TObject);
  private
    curMsg:integer;
    Procedure ClearMsgs;
    Procedure LoadMsgs;
    Procedure SelectMsg(nMsg:Integer);
    { Private declarations }
  public
    { Public declarations }
   Function PickMsg(oldMsg:Integer):Integer;
  end;

var
  MsgPicker: TMsgPicker;

implementation

{$R *.DFM}
uses Files, FileOperations, GlobalVars, misc_utils;

Type
 TMSGDetails=class
  ID:Integer;
  N:Integer;
 end;

Procedure TMsgPicker.ClearMsgs;
var i:integer;
begin
 for i:=0 to MsgList.Items.Count-1 do MsgList.Items.Objects[i].Free;
 MsgList.Items.Clear;
end;

Procedure TMsgPicker.SelectMsg(nMsg:Integer);
var i:integer;
begin
 for i:=0 to MsgList.Items.Count-1 do
 With MsgList.Items.Objects[i] as TMsgDetails do
 begin
  if ID=nMsg then begin MsgList.ItemIndex:=i; exit; end;
 end;
 MsgList.ItemIndex:=0;
end;

Procedure TMsgPicker.LoadMsgs;
var t:TLECTextFile;
    s,w:string;
    p:integer;
    md:TMSGDetails;
    n,nSel:Integer;
begin
 nSel:=0; n:=0;
 ClearMsgs;
 t:=TLECTextFile.CreateRead(OpenGameFile('local.msg'));
 Try
 While not t.eof do
 begin
  t.Readln(s);
  s:=Trim(s);
  if s='' then continue;
  md:=TMsgDetails.Create;
  p:=GetWord(s,1,w);
  ValInt(w,md.ID);
  p:=GetWord(s,p,w);
  SetLength(w,length(w));
  ValInt(w,md.n);
  MsgList.Items.AddObject(Copy(s,p,Length(s)-p+1),md);
  if md.ID=CurMsg then nSel:=n;
  inc(n);
 end;
 MsgList.ItemIndex:=nSel;
 MsgListClick(nil);
finally
 t.FClose;
end;
end;

Function TMsgPicker.PickMsg(oldMsg:Integer):Integer;
var i:integer;
begin
 CurMsg:=oldMsg;
 SelectMsg(oldMsg);
 ActiveControl:=MsgList;
 if ShowModal<>idOK then Result:=oldMsg else
 begin
  Result:=oldMsg;
  i:=MsgList.ItemIndex;
  if i>=0 then
  With MsgList.Items.Objects[i] as TMSGDetails do
   Result:=ID;
 end;
end;

procedure TMsgPicker.MsgListClick(Sender: TObject);
begin
 if MsgList.ItemIndex<0 then exit;
 With MsgList.Items.Objects[MsgList.ItemIndex] as TMsgDetails do
  LBDetails.Caption:=Format('ID: %d',[ID]);
end;

procedure TMsgPicker.FormCreate(Sender: TObject);
begin
  LoadMsgs;
end;

procedure TMsgPicker.BNFindClick(Sender: TObject);
begin
 FindText.Execute;
end;

procedure TMsgPicker.FindTextFind(Sender: TObject);
var i,n:integer;s,w:string;
begin
 n:=MsgList.ItemIndex;
 if n<0 then n:=-1;
 for i:=n+1 to MsgList.Items.Count-1 do
 begin
  s:=Uppercase(MsgList.Items[i]);
  w:=UpperCase(FindText.FindText);
  if Pos(w,s)<>0 then begin MsgList.ItemIndex:=i; MsgList.OnClick(MsgList); exit; end;
 end;
 ShowMessage('Text not found');
end;

end.
