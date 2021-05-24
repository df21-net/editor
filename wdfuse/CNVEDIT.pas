unit CNVEdit;

interface

uses
  WinTypes, WinProcs, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, StdCtrls, ExtCtrls, Grids, ColorGrd, DF2Art;

type

TPalette=array[0..255] of record
 r,g,b:byte;
end;

  TCNV_edit = class(TForm)
    Label1: TLabel;
    EBColor1: TEdit;
    Label2: TLabel;
    EBColor2: TEdit;
    PBColor1: TPaintBox;
    PBColor2: TPaintBox;
    MainMenu1: TMainMenu;
    Open1: TMenuItem;
    Save1: TMenuItem;
    Exit1: TMenuItem;
    CNVOpen: TOpenDialog;
    CNVSave: TSaveDialog;
    GPalette2: TDrawGrid;
    Special1: TMenuItem;
    Generatedefault1: TMenuItem;
    Label3: TLabel;
    GPalette1: TDrawGrid;
    LBCNVName: TLabel;
    Label5: TLabel;
    procedure Open1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure PBColor1Paint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EBColor1Change(Sender: TObject);
    procedure EBColor2Change(Sender: TObject);
    procedure PBColor2Paint(Sender: TObject);
    procedure GPalette1SelectCell(Sender: TObject; Col, Row: Longint;
      var CanSelect: Boolean);
    procedure GPalette1DrawCell(Sender: TObject; Col, Row: Longint;
      Rect: TRect; State: TGridDrawState);
    procedure GPalette2DrawCell(Sender: TObject; Col, Row: Longint;
      Rect: TRect; State: TGridDrawState);
    procedure GPalette2SelectCell(Sender: TObject; Col, Row: Longint;
      var CanSelect: Boolean);
    procedure Generatedefault1Click(Sender: TObject);
  private
    Color1,Color2:byte;
    Modified:Boolean;
    Palette1,Palette2:TPalette;
    Table:TPaletteConversionTable;

    { Private declarations }
   Procedure SetColor1(color:byte);
   Procedure SetColor2(color:byte);
  public
    { Public declarations }
  end;
var
  CNV_edit: TCNV_edit;

Function EDIT_CNV(Pal1,Pal2:TPalette;CnvFile:TFileName):TFileName;
Procedure MatchColors(Pal1,pal2:TPalette;var CNV:TPaletteConversionTable);
implementation
{$R *.DFM}

Procedure MatchColors(Pal1,pal2:TPalette;var CNV:TPaletteConversionTable);
var i, j      : Integer;
    Bidon     : LongInt;
    minfound  : LongInt;
    minsq     : Longint;
begin

Bidon := 1;

for i := 0 to 255 do
 begin
   minfound := 999999999;
   for j := 0 to 255 do
    begin
     {palette options}
         minsq := Bidon *
         longint(pal1[i].r-pal2[j].r)*longint(pal1[i].r-pal2[j].r)
       + longint(pal1[i].g-pal2[j].g)*longint(pal1[i].g-pal2[j].g)
       + longint(pal1[i].b-pal2[j].b)*longint(pal1[i].b-pal2[j].b);
     if i = j then
      begin
       { so if color i has multiple possible minseqs, it will take the
          one with the same index if possible. This will solve the
          0 20 0  <=> 20 0 0 problem when palettes are the same
       }
       if minsq <= minfound then
        begin
         minfound          := minsq;
         cnv.cnv[i] := j;
        end;
      end
     else
      begin
       if minsq < minfound then
        begin
         minfound          := minsq;
         cnv.cnv[i] := j;
        end;
      end;
    end;
  end;
cnv.color0:=0;
end;

Function EDIT_CNV(Pal1,Pal2:TPalette;CnvFile:TFileName):TFileName;
var f:file;
begin
 CNV_Edit.Palette1:=Pal1;
 CNV_Edit.Palette2:=Pal2;
 CNV_Edit.LBCNVName.Caption:=CnvFile;
 if CnvFile<>'' then
 begin
  assignfile(f,CnvFile);
{$i-}
  reset(f,1);
  if ioresult<>0 then begin MatchColors(CNV_Edit.Palette1,CNV_Edit.Palette2,CNV_Edit.Table); end
  else
 begin
   Blockread(f,CNV_Edit.Table,sizeof(CNV_Edit.Table));
   CloseFile(f);
 end;
 end
 else MatchColors(CNV_Edit.Palette1,CNV_Edit.Palette2,CNV_Edit.Table);
 CNV_Edit.ShowModal;
 Result:=CNV_Edit.LBCNVName.Caption;
end;

procedure TCNV_edit.Open1Click(Sender: TObject);
var f:file;
    fname:TFileName;
begin
 if modified then
  If Application.MessageBox('File modified. Save?','First Warning',MB_YESNO)=IDYES then
   Save1.Click;
 CNVOpen.Filename:='*.cnv';
 if CNVOpen.Execute then
 begin
  fname:=CNVOpen.Filename;
  assignfile(f,fname);
  {$i-}
  reset(f,1);
  if ioresult<>0 then begin Application.MessageBox('Cannot Open File','Error',MB_OK); exit; end;
  Blockread(f,Table,sizeof(Table));
  CloseFile(f);
  LBCNVName.Caption:=Fname;
  SetColor1(0);
  Modified:=false;
 end;

end;

procedure TCNV_edit.Exit1Click(Sender: TObject);
begin
 if Modified then
 if Application.MessageBox('File Modified. Save?','Last Warning',MB_YESNO)=IDYES then Save1.Click;
 CNV_edit.close;
end;

procedure TCNV_edit.Save1Click(Sender: TObject);
var f:file;
    Fname:TFileName;
begin
 CNVSave.Filename:=LBCNVName.Caption;
 if CNVSave.Execute then
 begin
  fname:=CNVSave.Filename;
  assignfile(f,fname);
  {$i-}
  rewrite(f,1);
  if ioresult<>0 then begin Application.MessageBox('Cannot create File','Error',MB_OK); exit; end;
  BlockWrite(f,Table,sizeof(Table));
  CloseFile(f);
  Modified:=false;
  LBCNVName.Caption:=Fname;
 end;
end;

procedure TCNV_edit.PBColor1Paint(Sender: TObject);
var
    r,b,g:integer;
begin
 r:=Palette1[Color1].r;
 g:=Palette1[Color1].g;
 b:=Palette1[Color1].b;
 PBColor1.Canvas.Brush.Color:=RGB(r,g,b);
 PBColor1.Canvas.FillRect(PbColor1.ClientRect);
end;

procedure TCNV_edit.FormCreate(Sender: TObject);
var f:file;
begin
 Modified:=LBCNVName.Caption='';
 SetColor1(0);
end;

procedure TCNV_edit.EBColor1Change(Sender: TObject);
var color:integer;
begin
 color:=StrToIntDef(EBColor1.Text,-1);
 if (color>=0) and (color<256) then
 begin
  SetColor1(color);
 end;
end;

procedure TCNV_edit.EBColor2Change(Sender: TObject);
var color:integer;
begin
 color:=StrToIntDef(EBColor2.Text,-1);
 if (color>=0) and (color<256) then
 begin
  if Color<>Color2 then modified:=true;
  SetColor2(Color);
 end;
end;

procedure TCNV_edit.PBColor2Paint(Sender: TObject);
var r,g,b:LongInt;
begin
 r:=Palette2[Color2].r;
 g:=Palette2[Color2].g;
 b:=Palette2[Color2].b;
 PBColor2.Canvas.Brush.Color:=RGB(r,g,b);
 PBColor2.Canvas.FillRect(PBColor2.ClientRect);
end;

Procedure TCNV_edit.SetColor1(color:byte);
Var sel:TGridRect;
    p:TNotifyEvent;
    p1:TSelectCellEvent;
begin
 Color1:=color;
 PBColor1.Repaint;

 p:=EBColor1.OnChange;
 EBColor1.OnChange:=nil;
 EBColor1.text:=IntToStr(Color1);
 EBColor1.OnChange:=p;

 p1:=GPalette1.OnSelectCell;
 GPalette1.OnSelectCell:=nil;
 GPalette1.col:=Color1 mod 16;
 GPalette1.row:=Color1 div 16;
 GPalette1.OnSelectCell:=p1;

 SetColor2(Table.cnv[Color1]);
end;

Procedure TCNV_edit.SetColor2(color:byte);
var p:TNotifyEvent;
    p1:TSelectCellEvent;
begin
 Color2:=color;
 PBColor2.Repaint;
 Table.cnv[Color1]:=Color2;

 p:=EBColor2.OnChange;
 EBColor2.OnChange:=nil;
 EBColor2.text:=IntToStr(Color2);
 EBColor2.OnChange:=p;

 p1:=GPalette2.OnSelectCell;
 GPalette2.OnSelectCell:=nil;
 GPalette2.col:=Color2 mod 16;
 GPalette2.row:=Color2 div 16;
 GPalette2.OnSelectCell:=p1;
end;


procedure TCNV_edit.GPalette1DrawCell(Sender: TObject; Col, Row: Longint;
  Rect: TRect; State: TGridDrawState);
var r,g,b:integer;
begin
 r:=Palette1[row*16+col].r;
 g:=Palette1[row*16+col].g;
 b:=Palette1[row*16+col].b;
 GPalette1.Canvas.Brush.Color:=RGB(r,g,b);
 if (Col=Gpalette1.col) and (Row=GPalette1.row) then
 begin if r+g+b<120 then GPalette1.Canvas.Pen.Color:=clRed else GPalette1.Canvas.Pen.Color:=clBlack; end
 else GPalette1.Canvas.Pen.Color:=clWhite;
 Gpalette1.Canvas.Rectangle(Rect.left, rect.top, rect.right, rect.bottom);
end;

procedure TCNV_edit.GPalette2DrawCell(Sender: TObject; Col, Row: Longint;
  Rect: TRect; State: TGridDrawState);
var r,g,b:integer;
begin
 r:=Palette2[row*16+col].r;
 g:=Palette2[row*16+col].g;
 b:=Palette2[row*16+col].b;
 GPalette2.Canvas.Brush.Color:=RGB(r,g,b);
 if (Col=Gpalette2.col) and (Row=GPalette2.row) then
 begin if r+g+b<120 then GPalette2.Canvas.Pen.Color:=clRed else GPalette2.Canvas.Pen.Color:=clBlack; end
 else GPalette2.Canvas.Pen.Color:=clWhite;
 Gpalette2.Canvas.Rectangle(Rect.left, rect.top, rect.right, rect.bottom);
end;

procedure TCNV_edit.GPalette1SelectCell(Sender: TObject; Col, Row: Longint;
  var CanSelect: Boolean);
begin
 SetColor1(Row*16+col);
end;

procedure TCNV_edit.GPalette2SelectCell(Sender: TObject; Col, Row: Longint;
  var CanSelect: Boolean);
begin
 if row*16+col<>Color2 then modified:=true;
 SetColor2(row*16+col);
end;

procedure TCNV_edit.Generatedefault1Click(Sender: TObject);
begin
 MatchColors(Palette1,Palette2,Table);
 SetColor1(Color1);
end;

end.
