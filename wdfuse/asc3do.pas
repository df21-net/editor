unit Asc3do;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, StdCtrls, Buttons, Gauges, _Strings,IniFiles,M_global;

type
  TASCto3DO = class(TForm)
    Edit1: TEdit;
    Edit2: TEdit;
    SBInputAsc: TSpeedButton;
    SBSave3DO: TSpeedButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Label1: TLabel;
    Label2: TLabel;
    Bevel1: TBevel;
    ListBoxRender: TListBox;
    Label3: TLabel;
    Panel2: TPanel;
    EditName: TEdit;
    EditColor: TEdit;
    EditScale: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Bevel2: TBevel;
    Gauge1: TGauge;
    BitBtnConvert: TBitBtn;
    BitBtnExit: TBitBtn;
    procedure SBInputAscClick(Sender: TObject);
    procedure SBSave3DOClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure BitBtnExitClick(Sender: TObject);
    procedure BitBtnConvertClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure AscTo3do(InputF,OutputF: string);
    function MakeZero(s: string): string;
  end;

var
  ASCto3DO: TASCto3DO;

implementation

{$R *.DFM}

function TASCto3DO.MakeZero(s: string): string;
begin
  while Length(s) < 6 do
    s := '0'+s;
  MakeZero := s;
end;

procedure TASCto3DO.AscTo3do(InputF,OutputF: string);
var
  pars: TStringParserWithColon;
  Asc,Tdo: System.TextFile;
  oScale: double;
  oName,oShading,oColor,oTextu: string;
  oNumVerts,oNumObjs,oNumFaces: integer;
  NumFace,Numvert: integer;
  LineN,Err: integer;
  L,ObjName: string;
  dX,dY,dZ: double;
  sX,sY,sZ: string;
begin
  NumFace:=0;
  NumVert:=0;
  LineN := 0;
  oNumVerts := 0;
  oNumObjs := 0;
  oNumFaces := 0;
  if (ListBoxRender.Items[ListBoxRender.ItemIndex] = 'TEXTURE') or
     (ListBoxRender.Items[ListBoxRender.ItemIndex] = 'GOURTEX') then
    oTextu := '0'
  else oTextu := '-1';
  Val(EditScale.Text,oScale,Err);
  oShading := ListBoxRender.Items[ListBoxRender.ItemIndex];
  oColor := EditColor.Text;
  oName := EditName.Text;
  AssignFile(Asc,InputF);
  Reset(Asc);
  while not SeekEof(Asc) do
  begin
    ReadLn(Asc,L);
    pars := TStringParserWithColon.Create(L);
    Inc(LineN);
    if pars.count = 4 then
      if pars[1] = 'Named' then
        Inc(oNumObjs);
    if pars.count = 9 then
      if pars[1] = 'Vertex' then
        Inc(oNumVerts);
    if pars.count >= 10 then
      if pars[1] = 'Face' then
        Inc(oNumFaces);
  end;
  System.CloseFile(Asc);
  Gauge1.MaxValue := (LineN*2)+1;
  Gauge1.Progress := LineN;
  AssignFile(Asc,InputF);
  Reset(Asc);
  AssignFile(Tdo,OutputF);
  ReWrite(Tdo);
  WriteLn(Tdo,'3DO 1.20');
  WriteLn(Tdo,'');
  WriteLn(Tdo,'#');
  WriteLn(Tdo,'# This 3DO was converted from the ASC file: '+InputF);
  WriteLn(Tdo,'# Using a port of Was ASC Now 3DO Version 1.0 by Frank A. Krueger');
  WriteLn(Tdo,'# =================================================================');
  WriteLn(Tdo,'# Original file was '+IntToStr(LineN)+' lines long');
  WriteLn(Tdo,'# GENTIME ', DateTimeToStr(Now));
  WriteLn(Tdo,'#');
  WriteLn(Tdo,'# AUTHOR ', USERname);
  WriteLn(Tdo,'# EMAIL  ', USERemail);
  WriteLn(Tdo,'#');
  WriteLn(Tdo,'');
  WriteLn(Tdo,'3DONAME '+oName);
  WriteLn(Tdo,'OBJECTS '+MakeZero(IntToStr(oNumObjs)));
  WriteLn(Tdo,'VERTICES '+MakeZero(IntToStr(oNumVerts)));
  WriteLn(Tdo,'POLYGONS '+MakeZero(IntToStr(oNumFaces)));
  WriteLn(Tdo,'PALETTE DEFAULT.PAL');
  WriteLn(Tdo,'');
  WriteLn(Tdo,'TEXTURES 0');
  while not SeekEof(Asc) do
  begin
    ReadLn(Asc,L);
    pars := TStringParserWithColon.Create(L);
    if pars.count = 4 then
      ObjName := Pars[3];
    if pars.Count = 6 then
      if UpperCase(pars[1]) = 'TRI-MESH,' then
      begin
        NumVert := StrToInt(Pars[3]);
        NumFace := StrToInt(Pars[5]);
      end;
    if pars.count = 3 then
      if pars[1] = 'Vertex' then
      begin
        WriteLn(Tdo,'');
        WriteLn(Tdo,'#------------------------------------------------------------------');
        WriteLn(Tdo,'OBJECT '+ObjName);
        WriteLn(Tdo,'TEXTURE '+oTextu);
        WriteLn(Tdo,'');
        WriteLn(Tdo,'VERTICES '+IntToStr(NumVert));
        WriteLn(Tdo,'#  <num>     <x>         <y>         <z>');
      end;
    if pars.count = 9 then
    begin
      Val(Pars[4],dX,Err);
      Val(Pars[6],dY,Err);
      Val(Pars[8],dZ,Err);
      dX := dX*oScale;
      dY := dY*oScale;
      dZ := dZ*oScale;
      Str(dX:12:4,sX);
      Str(dY:12:4,sY);
      Str(dZ:12:4,sZ);
      WriteLn(Tdo,'    '+pars[2]+sx+sy+sz);
    end;
    if pars.count = 3 then
      if pars[1] = 'Face' then
      begin
        WriteLn(Tdo,'');
        WriteLn(Tdo,'TRIANGLES '+IntToStr(NumFace));
        WriteLn(Tdo,'#  <num>   <a>   <b>   <c>   <col>   <fill>');
      end;
    if pars.count >= 10 then
      if UpperCase(pars[3]) = 'A:' then
      WriteLn(Tdo,'    '+pars[2]+'      '+pars[4]+'     '+pars[6]+'     '+pars[8]+
        '     '+oColor+'    '+oShading);
    Gauge1.Progress := Gauge1.Progress+1;
  end;
  System.CloseFile(Asc);
  System.CloseFile(Tdo);
  Gauge1.Progress := 0;
  Gauge1.MaxValue := 100;
  PARS := TStringParserWithColon.Create('Hi');
  Pars.Free;
end;

procedure TASCto3DO.SBInputAscClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  Edit1.Text := OpenDialog1.FileName;
  Edit2.Text := (WDFUSEdir+ '\'+ 'WDFGRAPH' +'\' +ChangeFileExt(ExtractFileName(Edit1.Text),'.3DO'));
  EditScale.TEXT:= '1.0';
  EditColor.Text:='32';
  EditName.Text:='Default';
    end;


procedure TASCto3DO.SBSave3DOClick(Sender: TObject);
begin
  if SaveDialog1.Execute then
     Edit2.Text := SaveDialog1.FileName;
end;

procedure TASCto3DO.Button2Click(Sender: TObject);
begin
  Close;
end;

procedure TASCto3DO.Button1Click(Sender: TObject);
begin
  AscTo3do(Edit1.Text,Edit2.Text);
end;

procedure TASCto3DO.BitBtnExitClick(Sender: TObject);
begin
 Close;
end;

procedure TASCto3DO.BitBtnConvertClick(Sender: TObject);
begin
   if Edit1.Text ='' then
begin
     MessageDlg('Input File Not Specified.', mtInformation,[mbOk], 0);
     Exit ;
  end;
   if Edit2.Text ='' then
      begin
     MessageDlg('3DO File Not Specified.', mtInformation,[mbOk], 0);
     Exit ;
  end;
    if EditName.Text ='' then
      begin
     MessageDlg('3DO Name Not Specified.', mtInformation,[mbOk], 0);
     Exit ;
  end;
     if EditColor.Text ='' then
      begin
     MessageDlg('3DO Color Not Specified.', mtInformation,[mbOk], 0);
     Exit ;
    end;
      if EditScale.Text ='' then
      begin
     MessageDlg('3DO Scale Not Specified.', mtInformation,[mbOk], 0);
     Exit ;
  end;
   if   ListboxRender.ItemIndex = 2 then
      begin
     MessageDlg('Gourtex vertices not implemented.''You will have to add them by hand', mtInformation,[mbOk], 0);
     end;
   if   ListboxRender.ItemIndex = 4 then
      begin
     MessageDlg('Texture vertices not implemented.''You will have to add them by hand', mtInformation,[mbOk], 0);
     end;
   AscTo3do(Edit1.Text,Edit2.Text);
end;

procedure TASCto3DO.FormCreate(Sender: TObject);
begin
  ListboxRender.ItemIndex := 0;
end;

end.
