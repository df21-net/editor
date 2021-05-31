unit M_scedit;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Buttons, ExtCtrls, Grids, MultiSelection,
  Menus, StdCtrls, Level, FieldEdit, misc_utils, GlobalVars;

Const
 ID_Name=0;
 ID_Ambient=1;
 ID_Palette=2;
 ID_ColorMap=3;
 ID_Friction=4;
 ID_Gravity=5;
 ID_Elasticity=6;
 ID_VelocityX=8;
 ID_VelocityY=9;
 ID_VelocityZ=10;
 ID_VAdjoin=11;
 ID_Floor_Sound=13;
 ID_FloorY=14;

 ID_Floor_TX=40;
 ID_Floor_XOffs=41;
 ID_Floor_YOffs=42;
 ID_Floor_extra=43;

 ID_Ceiling_Y=50;
 ID_Ceiling_TX=51;
 ID_Ceiling_XOffs=52;
 ID_Ceiling_YOffs=53;
 ID_Ceiling_Extra=54;

 ID_F_Overlay_TX=60;
 ID_F_Overlay_XOffs=61;
 ID_F_Overlay_YOffs=62;
 ID_F_Overlay_Extra=63;

 ID_C_Overlay_TX=70;
 ID_C_Overlay_XOffs=71;
 ID_C_Overlay_YOffs=72;
 ID_C_Overlay_Extra=73;

{ floor_offsets: Integer;}

 ID_Flags=80;
 ID_FSlopeSC=90;
 ID_FSlopeWL=91;
 ID_FSlopeANG=92;

 ID_CSlopeSC=100;
 ID_CSlopeWL=101;
 ID_CSlopeANG=102;

 ID_Layer=110;


type
  TSectorEditor = class(TForm)
    SCEd: TStringGrid;
    PanelButtons: TPanel;
    PanelInfo: TPanel;
    PanelInfoLeft: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    SBCommit: TSpeedButton;
    SBRollback: TSpeedButton;
    SCEdPopupMenu: TPopupMenu;
    CommitF21: TMenuItem;
    RollbackEsc1: TMenuItem;
    ShapeMulti: TShape;
    N1: TMenuItem;
    ForceCurrentField: TMenuItem;
    N2: TMenuItem;
    StayOnTop: TMenuItem;
    ShapeINF: TShape;
    Panel1: TPanel;
    SBHelp: TSpeedButton;
    PanelVXNum: TPanel;
    PanelWLnum: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure SBCommitClick(Sender: TObject);
    procedure SBRollbackClick(Sender: TObject);
    procedure SCEdKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure CBClassClick(Sender: TObject);
    procedure CBSlaCliClick(Sender: TObject);
    procedure ForceCurrentFieldClick(Sender: TObject);
    procedure SBHelpClick(Sender: TObject);
    procedure StayOnTopClick(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
   fe:TFieldEdit;
   TheSector:TSector;
   Sel:TMultiSelection;
    { Private declarations }
    Procedure DblClickHandler(Fi:TFieldInfo);
  public
   MapWindow:TForm;
    { Public declarations }
   Procedure LoadSector(s:Integer);
   Procedure EditIt;
   Procedure ReLoad;
   Property MultiSel:TMultiSelection read sel write sel;
   Function L:TLevel;
   Procedure Commit(Sector:TSector);
  end;

implementation

uses ResourcePicker, M_scedit, FlagEditor, Mapper;
{$R *.DFM}

procedure TSectorEditor.FormCreate(Sender: TObject);
begin
 StayOnTop.Checked:=SCEditOnTop;
 if SCEditOnTop then FormStyle:=fsStayOnTop;
 
 Fe:=TFieldEdit.Create(SCEd);
 With fe do
 begin
  AddField('Name',ID_Name,vtString);
  AddField('Ambient',ID_Ambient,vtInteger);
  AddField('+Palette',ID_Palette,vtString);
  AddField('+ColorMap',ID_ColorMap,vtString);
  AddField('Friction',ID_Friction,vtDouble);
  AddField('Gravity',ID_Gravity,vtDouble);
  AddField('Elasticity',ID_Elasticity,vtDouble);
  AddField('Velocity X',ID_VelocityX,vtDouble);
  AddField('         Y',ID_VelocityY,vtDouble);
  AddField('         Z',ID_VelocityZ,vtDouble);
  AddField('VAdjoin',ID_VAdjoin,vtInteger);
  AddField('+Floor Sound',ID_Floor_Sound,vtString);
  AddField('Floor     Y',ID_FloorY,vtDouble);
  AddField('+    Texture',ID_Floor_TX,vtString);
  AddField('   X Offset',ID_Floor_XOffs,vtDouble);
  AddField('   Y Offset',ID_Floor_YOffs,vtDouble);
  AddField('      Angle',ID_Floor_Extra,vtDouble);
  AddField('Ceiling   Y',ID_Ceiling_Y,vtDouble);
  AddField('+    Texture',ID_Ceiling_TX,vtString);
  AddField('   X Offset',ID_Ceiling_XOffs,vtDouble);
  AddField('   Y Offset',ID_Ceiling_YOffs,vtDouble);
  AddField('      Angle',ID_Ceiling_Extra,vtDouble);

  AddField('+Floor Overlay',ID_F_Overlay_TX,vtString);
  AddField('   X Offset',ID_F_Overlay_XOffs,vtDouble);
  AddField('   Y Offset',ID_F_Overlay_YOffs,vtDouble);
  AddField('      Angle',ID_F_Overlay_Extra,vtDouble);

  AddField('+Ceiling Overlay',ID_C_Overlay_TX,vtString);
  AddField('   X Offset',ID_C_Overlay_XOffs,vtDouble);
  AddField('   Y Offset',ID_C_Overlay_YOffs,vtDouble);
  AddField('      Angle',ID_C_Overlay_Extra,vtDouble);

  AddField('+Flags',ID_Flags,vtDword);
  AddField('Floor Slope',-1,vtString);
  AddField('     Sector',ID_FSlopeSC,vtInteger);
  AddField('       Wall',ID_FSlopeWL,vtInteger);
  AddField('      Angle',ID_FSlopeANG,vtDouble);

  AddField('Ceiling Slope',-1,vtString);
  AddField('     Sector',ID_CSlopeSC,vtInteger);
  AddField('       Wall',ID_CSlopeWL,vtInteger);
  AddField('      Angle',ID_CSlopeANG,vtInteger);

  AddField('Layer',ID_Layer,vtInteger);
 end;
fe.OnDblClick:=DblClickHandler;
end;

Procedure TSectorEditor.DblClickHandler(Fi:TFieldInfo);
var Flags:Longint;
begin
 case Fi.ID of
  ID_Floor_TX,
  ID_Ceiling_TX,
  ID_F_Overlay_TX,
  ID_C_OverLay_TX: Fi.s:=ResPicker.PickTexture(fi.s);
  ID_Palette,
  ID_Colormap: Fi.s:=ResPicker.PickPalette(fi.s);
  ID_Floor_Sound: Fi.S:=ResPicker.PickFloorSound(fi.s);
  ID_Flags: begin
             Fi.ReadDword(flags);
             flags:=FlagEdit.EditSectorFlags(Flags);
             fi.s:=DwordToStr(flags);
            end;
 end;
end;

procedure TSectorEditor.FormDeactivate(Sender: TObject);
var Changed:Boolean;
    i:integer;
begin
 ScEd.EditorMode:=false;
 Changed:=false;
 for i:= 0 to fe.fieldcount-1 do
  Changed:=Changed or fe.Fields[i].Changed;
 if changed then  
 if MsgBox('Commit changes?','Question',mb_YesNo)=idYes then
 SBCommit.Click else Reload;
 ShapeMulti.Brush.Color:=clBtnFace;
 { SUPERHILITE := -1;}
end;

Procedure TSectorEditor.Commit(Sector:TSector);
var i:Integer;
begin
 if Sector=nil then exit;
  for i:=0 to fe.FieldCount-1 do
  With fe.Fields[i] do
  With Sector do
  if changed then
  case id of
   ID_Name    : Name:=UpperCase(s);
  ID_Ambient  : Read0to31(Ambient);
 ID_Palette   : Palette:=s;
 ID_ColorMap  : ColorMap:=s;
 ID_Friction  : ReadDouble(Friction);
 ID_Gravity   : ReadDouble(Gravity);
 ID_Elasticity: ReadDouble(Elasticity);
 ID_VelocityX : ReadDouble(Velocity.dX);
 ID_VelocityY : ReadDouble(Velocity.dY);
 ID_VelocityZ : ReadDouble(Velocity.dZ);
 ID_VAdjoin   : ReadInteger(Vadjoin);
 ID_Floor_Sound: Floor_Sound:=s;
 ID_FloorY    : ReadDouble(Floor_Y);

 ID_Floor_TX  : Floor_Texture.Name:=s;
 ID_Floor_XOffs: ReadDouble(Floor_Texture.OffsX);
 ID_Floor_YOffs: ReadDouble(Floor_Texture.OffsY);
 ID_Floor_extra: ReadDouble(Floor_extra);

 ID_Ceiling_Y : ReadDouble(Ceiling_Y);
 ID_Ceiling_TX: Ceiling_Texture.Name:=s;
 ID_Ceiling_XOffs: ReadDouble(Ceiling_Texture.OffsX);
 ID_Ceiling_YOffs: ReadDouble(Ceiling_Texture.OffsY);
 ID_Ceiling_Extra: ReadDouble(Ceiling_extra);

 ID_F_Overlay_TX: F_Overlay_Texture.Name:=s;
 ID_F_Overlay_XOffs: ReadDouble(F_Overlay_Texture.OffsX);
 ID_F_Overlay_YOffs: ReadDouble(F_Overlay_Texture.OffsY);
 ID_F_Overlay_Extra: ReadDouble(F_Overlay_extra);

 ID_C_Overlay_TX: C_Overlay_Texture.Name:=s;
 ID_C_Overlay_XOffs: ReadDouble(C_Overlay_Texture.OffsX);
 ID_C_Overlay_YOffs: ReadDouble(C_Overlay_Texture.OffsY);
 ID_C_Overlay_Extra: ReadDouble(C_Overlay_extra);

{ floor_offsets: Integer;}

 ID_Flags: ReadDword(Flags);
 ID_FSlopeSC: ReadInteger(FloorSlope.Sector);
 ID_FSlopeWL: ReadInteger(FloorSlope.Wall);
 ID_FSlopeANG: ReadDouble(FloorSlope.angle);

 ID_CSlopeSC: ReadInteger(CeilingSlope.Sector);
 ID_CSlopeWL: ReadInteger(CeilingSlope.Wall);
 ID_CSlopeANG: ReadDouble(CeilingSlope.angle);

 ID_Layer:  begin
               ReadInteger(Layer);
               if Layer>L.MaxLayer then L.MaxLayer:=Layer;
               if Layer<L.MinLayer then L.MinLayer:=Layer;
               TMapWindow(MapWindow).GoToLayer(Layer);
            end;

  end;
 end;

procedure TSectorEditor.SBCommitClick(Sender: TObject);
var i:Integer;
begin
 SCEd.EditorMode:=false;
 Commit(TheSector);
 For i:=0 to MultiSel.Count-1 do
 begin
  Commit(L.Sectors[MultiSel.GetSector(i)]);
 end;

 for i:=0 to fe.fieldCount-1 do fe.Fields[i].Changed:=false;
 Reload;
  if MapWindow<>nil then MapWindow.SetFocus;
end;

procedure TSectorEditor.SBRollbackClick(Sender: TObject);
begin
  SCEd.EditorMode:=false;
  ReLoad;
  {DO_Fill_SectorEditor;}
  if MapWindow<>nil then MapWindow.SetFocus;
end;

procedure TSectorEditor.SCEdKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Shift = [] then
    Case Key of
      VK_F1     : {Application.HelpJump('wdfuse_help_SCeditor')};
      VK_F2     : SBCommitClick(NIL);
      VK_ESCAPE : SBRollbackClick(NIL);
      VK_TAB    : if MapWindow<>nil then MapWindow.SetFocus;
    end;
  if Shift = [ssCtrl] then
    Case Key of
      VK_LEFT   : begin
                   if ScEd.ColWidths[0] > 1 then
                    begin
                     ScEd.ColWidths[0] := ScEd.ColWidths[0] - 1;
                     PanelInfoLeft.Width := PanelInfoLeft.Width - 1;
                    end;
                  end;
      VK_RIGHT  : begin
                   ScEd.ColWidths[0] := ScEd.ColWidths[0] + 1;
                   PanelInfoLeft.Width := PanelInfoLeft.Width + 1;
                  end;
    end;
end;

procedure TSectorEditor.CBClassClick(Sender: TObject);
begin
 {DO_SectorEditor_Specials(CBClass.ItemIndex);}
end;

procedure TSectorEditor.CBSlaCliClick(Sender: TObject);
begin
 {SUPERHILITE := -1;
 if GetSectorNumFromName(CBSlaCli.Items[CBSlaCli.ItemIndex], SUPERHILITE)
  then MapWindow.Map.Invalidate;}
end;

procedure TSectorEditor.ForceCurrentFieldClick(Sender: TObject);
var fi:TFieldInfo;
begin
 fi:=fe.CurrentField;
 if fi<>nil then fi.Changed:=true;
end;

procedure TSectorEditor.SBHelpClick(Sender: TObject);
begin
 Application.HelpJump('Hlp_Sector_Editor');
end;

procedure TSectorEditor.StayOnTopClick(Sender: TObject);
begin
 if StayOnTop.Checked then
  begin
   StayOnTop.Checked := FALSE;
   FormStyle := fsNormal;
  end
 else
  begin
   StayOnTop.Checked := TRUE;
   FormStyle := fsStayOnTop;
  end;
end;

Procedure TSectorEditor.ReLoad;
var i:integer;
begin
 PanelWLNum.Caption:=IntToStr(TheSector.Walls.Count);
 PanelVXNum.Caption:=IntToStr(TheSector.Vertices.Count);
 For i:=0 to fe.FieldCount-1 do
 With fe.Fields[i] do
 With TheSector do
 begin
 case id of
     id_Name: s:=Name;
  ID_Ambient: s:=IntToStr(Ambient);
  ID_Palette: s:=Palette;
 ID_ColorMap: s:=ColorMap;
 ID_Friction: s:=FloatToStr(Friction);
  ID_Gravity: s:=FloatToStr(Gravity);
ID_Elasticity: s:=FloatToStr(Elasticity);
ID_VelocityX: s:=FloatToStr(Velocity.dX);
ID_VelocityY: s:=FloatToStr(Velocity.dY);
ID_VelocityZ: s:=FloatToStr(Velocity.dZ);
  ID_VAdjoin: s:=IntToStr(Vadjoin);
ID_Floor_Sound: s:=Floor_Sound;
   ID_FloorY: s:=FloatToStr(Floor_Y);
 ID_Floor_TX: s:=Floor_Texture.Name;
ID_Floor_XOffs: s:=FloatToStr(Floor_Texture.OffsX);
ID_Floor_YOffs: s:=FloatToStr(Floor_Texture.OffsY);
ID_Floor_extra: s:=FloatToStr(Floor_Extra);
ID_Ceiling_Y: s:=FloatToStr(Ceiling_Y);
   ID_Ceiling_TX: s:=Ceiling_Texture.Name;
ID_Ceiling_XOffs: s:=FloatToStr(Ceiling_Texture.OffsX);
ID_Ceiling_YOffs: s:=FloatToStr(Ceiling_Texture.OffsY);
ID_Ceiling_extra: s:=FloatToStr(Ceiling_Extra);

 ID_F_Overlay_TX: s:=F_Overlay_Texture.Name;
 ID_F_Overlay_XOffs: s:=FloatToStr(F_Overlay_texture.OffsX);
 ID_F_Overlay_YOffs: s:=FloatToStr(F_Overlay_texture.OffsY);
 ID_F_Overlay_Extra: s:=FloatToStr(F_Overlay_Extra);

 ID_C_Overlay_TX: s:=C_Overlay_Texture.Name;
 ID_C_Overlay_XOffs: s:=FloatToStr(C_Overlay_Texture.OffsX);
 ID_C_Overlay_YOffs: s:=FloatToStr(C_Overlay_Texture.OffsY);
 ID_C_Overlay_Extra: s:=FloatToStr(C_Overlay_Extra);

        ID_Flags: s:=DwordToStr(Flags);
     ID_FSlopeSC: s:=IntToStr(FloorSlope.Sector);
     ID_FSlopeWL: s:=IntToStr(FloorSlope.Wall);
    ID_FSlopeANG: s:=FloatToStr(FloorSlope.Angle);

     ID_CSlopeSC: s:=IntToStr(CeilingSlope.Sector);
     ID_CSlopeWL: s:=IntToStr(CeilingSlope.Wall);
    ID_CSlopeANG: s:=FloatToStr(CeilingSlope.Angle);
        ID_Layer: s:=IntToStr(Layer);
 end;
   Changed:=false;
 end;
end;

Procedure TSectorEditor.LoadSector(s:Integer);
begin
 TheSector:=l.Sectors[s];
 Caption:=Format('SC %d ID: %x',[s,TheSector.HexID]);
 Reload;
end;

Procedure TSectorEditor.EditIt;
begin
 if not visible then Visible:=true;
 Self.SetFocus;
end;

procedure TSectorEditor.FormHide(Sender: TObject);
begin
 GetFormPos(Self,SectorEditPos);
 SCEditOnTop:=FormStyle=fsStayOnTop;
end;

procedure TSectorEditor.FormShow(Sender: TObject);
begin
 SetFormPos(Self,SectorEditPos);
end;

Function TSectorEditor.L:TLevel;
begin
 Result:=TMapWindow(MapWindow).Level;
end;


procedure TSectorEditor.FormActivate(Sender: TObject);
begin
 if MultiSel.Count=0 then ShapeMulti.Brush.Color:=clBtnFace
 else ShapeMulti.Brush.Color:=clRed;
end;

end.
