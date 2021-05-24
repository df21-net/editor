unit M_tools;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, TabNotBk, Dialogs,
  M_Global, Spin, SysUtils, M_MapFun,
{$IFDEF WDF32}
  ComCtrls,
{$ENDIF}
  M_Editor, Stitch;

type
  TToolsWindow = class(TForm)
    ToolsNotebook: TTabbedNotebook;
    BNIntegrity: TBitBtn;
    BNRereadINF: TBitBtn;
    BNLayerNON: TBitBtn;
    BNLayerALL: TBitBtn;
    CBStitchHoriz: TCheckBox;
    CBHMid: TCheckBox;
    CBHTop: TCheckBox;
    CBHBot: TCheckBox;
    RGStitchHoriz: TRadioGroup;
    CBStitchVert: TCheckBox;
    CBVMid: TCheckBox;
    CBVTop: TCheckBox;
    CBVBot: TCheckBox;
    CBAltitudes: TCheckBox;
    RGAltitudes: TRadioGroup;
    CBAmbient: TCheckBox;
    BNClose: TBitBtn;
    BNStitch: TBitBtn;
    BNDistribute: TBitBtn;
    BNPolygon: TBitBtn;
    RGPolyAs: TRadioGroup;
    SEPolySides: TSpinEdit;
    Label1: TLabel;
    EDPolyRadius: TEdit;
    Label2: TLabel;
    EDPolyX: TEdit;
    EDPolyZ: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    EDRotate: TEdit;
    Label7: TLabel;
    BNRotate: TBitBtn;
    EDScale: TEdit;
    Label8: TLabel;
    BNScale: TBitBtn;
    CBPin: TCheckBox;
    BNFlip: TBitBtn;
    CBFlipHorizontal: TCheckBox;
    CBFlipVertical: TCheckBox;
    Label9: TLabel;
    Label10: TLabel;
    CBObjectOrient: TCheckBox;
    CBRotateOBOrient: TCheckBox;
    BNHelp: TBitBtn;
    BNOffset: TBitBtn;
    Label11: TLabel;
    EDOffset: TEdit;
    CBOnTop: TCheckBox;
    Label5: TLabel;
    EDTranslateX: TEdit;
    Label6: TLabel;
    EDTranslateZ: TEdit;
    BNTranslate: TBitBtn;
    RGOffset: TRadioGroup;
    BNOffsetReverse: TBitBtn;
    BNTranslateReverse: TBitBtn;
    BNRotateReverse: TBitBtn;
    BNScaleReverse: TBitBtn;
    Bevel1: TBevel;
    BNSuperStitchLeft: TBitBtn;
    BNSuperStitchRight: TBitBtn;
    RGSplitType: TRadioGroup;
    SEStairs: TSpinEdit;
    RGStairsType: TRadioGroup;
    BNSplit: TBitBtn;
    procedure BNIntegrityClick(Sender: TObject);
    procedure BNRereadINFClick(Sender: TObject);
    procedure BNLayerNONClick(Sender: TObject);
    procedure BNLayerALLClick(Sender: TObject);
    procedure BNStitchClick(Sender: TObject);
    procedure BNDistributeClick(Sender: TObject);
    procedure BNPolygonClick(Sender: TObject);
    procedure BNTranslateClick(Sender: TObject);
    procedure BNRotateClick(Sender: TObject);
    procedure BNScaleClick(Sender: TObject);
    procedure BNFlipClick(Sender: TObject);
    procedure BNHelpClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure CBOnTopClick(Sender: TObject);
    procedure BNCloseClick(Sender: TObject);
    procedure BNOffsetClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BNSuperStitchLeftClick(Sender: TObject);
    procedure BNSuperStitchRightClick(Sender: TObject);
    procedure RGSplitTypeClick(Sender: TObject);
    procedure BNSplitClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ToolsWindow: TToolsWindow;

implementation
uses Mapper, M_Io, M_Util;

{$R *.DFM}

procedure TToolsWindow.BNIntegrityClick(Sender: TObject);
begin
 DO_ConsistencyChecks;
 if not CBPin.Checked then Close;
end;

procedure TToolsWindow.BNRereadINFClick(Sender: TObject);
var i, j      : Integer;
    TheSector : TSector;
    TheWall   : TWall;
begin
 for i := 0 to MAP_SEC.Count - 1 do
  begin
    TheSector := TSector(MAP_SEC.Objects[i]);
    TheSector.InfItems.Clear;
    for j := 0 to TheSector.Wl.Count - 1 do
     begin
      TheWall := TWall(TheSector.Wl.Objects[j]);
      TheWall.InfItems.Clear;
     end;
  end;

 IO_ReadINF(LEVELPath + '\' + LEVELName + '.INF');
 Modified := TRUE;
 MapWindow.Map.Invalidate;
 if not CBPin.Checked then Close;
end;

procedure TToolsWindow.BNLayerNONClick(Sender: TObject);
begin
 LayerAllObjects;
 Modified := TRUE;
 MapWindow.Map.Invalidate;
 if not CBPin.Checked then Close;
end;

procedure TToolsWindow.BNLayerALLClick(Sender: TObject);
var o         : Integer;
    TheObject : TOB;
begin
 for o := 0 to MAP_OBJ.Count - 1 do
  begin
   TheObject := TOB(MAP_OBJ.Objects[o]);
   TheObject.Sec := -1;
  end;
 LayerAllObjects;
 Modified := TRUE;
 MapWindow.Map.Invalidate;
 if not CBPin.Checked then Close;
end;

procedure TToolsWindow.BNStitchClick(Sender: TObject);
var title   : array[0..60] of char;
begin
 StrCopy(title, 'WDFUSE Tools - Stitching');
 if MAP_MODE <> MM_WL then
  begin
   Application.MessageBox('You must be in WALL Mode', Title, mb_Ok or mb_IconExclamation);
   exit;
  end;

 if WL_MULTIS.Count < 2 then
  begin
   Application.MessageBox('You must have a MULTISELECTION of at least 2 WALLS', Title, mb_Ok or mb_IconExclamation);
   exit;
  end;

 if not CBStitchHoriz.Checked and not CBStitchVert.Checked then
  begin
   Application.MessageBox('You must select Horizontal or/and Vertical', Title, mb_Ok or mb_IconExclamation);
   exit;
  end;

 if CBStitchHoriz.Checked and not (CBHMid.Checked or CBHTop.Checked or CBHBot.Checked) then
  begin
   Application.MessageBox('You must select Mid and/or Top and/or Bot for Horizontal Stitching', Title,
                           mb_Ok or mb_IconExclamation);
   exit;
  end;

 if CBStitchVert.Checked and not (CBVMid.Checked or CBVTop.Checked or CBVBot.Checked) then
  begin
   Application.MessageBox('You must select Mid and/or Top and/or Bot for Vertical Stitching', Title,
                           mb_Ok or mb_IconExclamation);
   exit;
  end;

 if CBStitchHoriz.Checked then
  if RGStitchHoriz.ItemIndex = 0 then
   DO_StitchHorizontal(CBHMid.Checked, CBHTop.Checked, CBHBot.Checked)
  else
   DO_StitchHorizontalInvert(CBHMid.Checked, CBHTop.Checked, CBHBot.Checked);

 if CBStitchVert.Checked  then DO_StitchVertical(CBVMid.Checked, CBVTop.Checked, CBVBot.Checked);
 MODIFIED := TRUE;
 DO_Fill_WallEditor;
 {MapWindow.Map.Invalidate;}
 if not CBPin.Checked then Close;
end;

procedure TToolsWindow.BNDistributeClick(Sender: TObject);
var title   : array[0..60] of char;
begin
 StrCopy(title, 'WDFUSE Tools - Distribution');
 if MAP_MODE <> MM_SC then
  begin
   Application.MessageBox('You must be in SECTOR Mode', Title, mb_Ok or mb_IconExclamation);
   exit;
  end;

 if SC_MULTIS.Count < 3 then
  begin
   Application.MessageBox('You must have a MULTISELECTION of at least 3 SECTORS', Title, mb_Ok or mb_IconExclamation);
   exit;
  end;

 if not CBAltitudes.Checked and not CBAmbient.Checked then
  begin
   Application.MessageBox('You must select Altitudes or/and Ambient', Title, mb_Ok or mb_IconExclamation);
   exit;
  end;

 DO_Distribute(CBAltitudes.Checked, RGAltitudes.ItemIndex, CBAmbient.Checked);
 MODIFIED := TRUE;
 DO_Fill_SectorEditor;
 MapWindow.Map.Invalidate;
 if not CBPin.Checked then Close;
end;

procedure TToolsWindow.BNPolygonClick(Sender: TObject);
var code    : Integer;
    AReal,
    radius,
    c_x,
    c_z     : Real;
    title   : array[0..60] of char;
begin
  StrCopy(title, 'WDFUSE Tools - Create Polygon');

  Val(EDPolyRadius.Text, AReal, Code);
  if Code = 0 then
    Radius := AReal
  else
   begin
    Application.MessageBox('Wrong value for Radius', Title, mb_Ok or mb_IconExclamation);
    exit;
   end;

  if Radius <= 0 then
   begin
    Application.MessageBox('Radius must be > 0', Title, mb_Ok or mb_IconExclamation);
    exit;
   end;

  Val(EDPolyX.Text, AReal, Code);
  if Code = 0 then
    c_x := AReal
   else
    begin
     Application.MessageBox('Wrong value for Center X coordinate', Title, mb_Ok or mb_IconExclamation);
     exit;
    end;

  Val(EDPolyZ.Text, AReal, Code);
  if Code = 0 then
    c_z := AReal
   else
    begin
     Application.MessageBox('Wrong value for Center Z coordinate', Title, mb_Ok or mb_IconExclamation);
     exit;
    end;

 {create a polygon function in m_mapfun}
 CreatePolygon(SEPolySides.Value, radius, c_x, c_z, RGPolyAs.ItemIndex, SC_HILITE);

 {MODIFIED, Sector Editor are handled by CreatePolygon}
 if not CBPin.Checked then Close;
end;

procedure TToolsWindow.BNTranslateClick(Sender: TObject);
var code    : Integer;
    AReal,
    x,
    z       : Real;
    title   : array[0..60] of char;
begin
  StrCopy(title, 'WDFUSE Tools - Translate');

  Val(EDTranslateX.Text, AReal, Code);
  if Code = 0 then
    x := AReal
  else
   begin
    Application.MessageBox('Wrong value for X Translation Offset', Title, mb_Ok or mb_IconExclamation);
    exit;
   end;

  Val(EDTranslateZ.Text, AReal, Code);
  if Code = 0 then
   z := AReal
  else
   begin
    Application.MessageBox('Wrong value for Z Translation Offset', Title, mb_Ok or mb_IconExclamation);
    exit;
   end;

 if Sender = BNTranslate then
  DO_Translate(x, z)
 else
  DO_Translate(-x, -z);

 MODIFIED := TRUE;
 CASE MAP_MODE OF
  MM_SC : DO_Fill_SectorEditor;
  MM_WL : DO_Fill_WallEditor;
  MM_VX : DO_Fill_VertexEditor;
  MM_OB : DO_Fill_ObjectEditor;
 END;
 MapWindow.Map.Invalidate;
 if not CBPin.Checked then Close;
end;

procedure TToolsWindow.BNRotateClick(Sender: TObject);
var code    : Integer;
    AReal,
    angle   : Real;
    title   : array[0..60] of char;
begin
 StrCopy(title, 'WDFUSE Tools - Rotate');

  Val(EDRotate.Text, AReal, Code);
  if Code = 0 then
    angle := AReal
  else
   begin
    Application.MessageBox('Wrong value for Rotation Angle', Title, mb_Ok or mb_IconExclamation);
    exit;
   end;

 if angle = 0 then angle := 360;

 if Sender = BNRotate then
  DO_Rotate(360 - angle, CBRotateOBOrient.Checked)
 else
  DO_Rotate(angle, CBRotateOBOrient.Checked);

 MODIFIED := TRUE;
 CASE MAP_MODE OF
  MM_SC : DO_Fill_SectorEditor;
  MM_WL : DO_Fill_WallEditor;
  MM_VX : DO_Fill_VertexEditor;
  MM_OB : DO_Fill_ObjectEditor;
 END;
 MapWindow.Map.Invalidate;
 if not CBPin.Checked then Close;
end;

procedure TToolsWindow.BNScaleClick(Sender: TObject);
var code    : Integer;
    AReal,
    factor  : Real;
    title   : array[0..60] of char;
begin
 StrCopy(title, 'WDFUSE Tools - Scale');

  Val(EDScale.Text, AReal, Code);
  if Code = 0 then
    factor := AReal
  else
   begin
    Application.MessageBox('Wrong value for Scaling Factor', Title, mb_Ok or mb_IconExclamation);
    exit;
   end;

 if factor <= 0 then
   begin
    Application.MessageBox('Scaling Factor must be > 0', Title, mb_Ok or mb_IconExclamation);
    exit;
   end;

 if Sender = BNScale then
  DO_Scale(factor)
 else
  DO_Scale(1/factor);

 MODIFIED := TRUE;
 CASE MAP_MODE OF
  MM_SC : DO_Fill_SectorEditor;
  MM_WL : DO_Fill_WallEditor;
  MM_VX : DO_Fill_VertexEditor;
  MM_OB : DO_Fill_ObjectEditor;
 END;
 MapWindow.Map.Invalidate;
 if not CBPin.Checked then Close;
end;

procedure TToolsWindow.BNOffsetClick(Sender: TObject);
var code    : Integer;
    AReal,
    RValue  : Real;
    AnInt,
    IValue  : Integer;
    title   : array[0..60] of char;
begin
  StrCopy(title, 'WDFUSE Tools - Offset');

  IF RGOffset.ItemIndex <> 3 then
   begin
    if (MAP_MODE = MM_WL) or (MAP_MODE = MM_VX) then
     begin
      Application.MessageBox('You must be in Sector or Objects mode', Title, mb_Ok or mb_IconExclamation);
      exit;
     end;

    Val(EDOffset.Text, AReal, Code);
    if Code = 0 then
      rvalue := AReal
    else
     begin
      Application.MessageBox('Wrong value for Altitude Offset', Title, mb_Ok or mb_IconExclamation);
      exit;
     end;

    if Sender = BNOffset then
     DO_OffsetAltitude(rvalue, RGOffset.ItemIndex)
    else
     DO_OffsetAltitude(-rvalue, RGOffset.ItemIndex);
   end
  ELSE
   begin
    if (MAP_MODE <> MM_SC) then
     begin
      Application.MessageBox('You must be in Sector mode', Title, mb_Ok or mb_IconExclamation);
      exit;
     end;

    Val(EDOffset.Text, AnInt, Code);
    if Code = 0 then
      ivalue := AnInt
    else
     begin
      Application.MessageBox('Wrong value for Ambient Offset', Title, mb_Ok or mb_IconExclamation);
      exit;
     end;

    if Sender = BNOffset then
     DO_OffsetAmbient(ivalue)
    else
     DO_OffsetAmbient(-ivalue);
   end;

 MODIFIED := TRUE;
 CASE MAP_MODE OF
  MM_SC : DO_Fill_SectorEditor;
  MM_OB : DO_Fill_ObjectEditor;
 END;
 MapWindow.Map.Invalidate;
 if not CBPin.Checked then Close;
end;

procedure TToolsWindow.BNFlipClick(Sender: TObject);
var title   : array[0..60] of char;
begin
 StrCopy(title, 'WDFUSE Tools - Flip');

 if not ((MAP_MODE = MM_SC) or (MAP_MODE = MM_OB)) then
  begin
   Application.MessageBox('You must be in SECTOR or OBJECT Mode', Title, mb_Ok or mb_IconExclamation);
   exit;
  end;

 if not CBFlipHorizontal.Checked and not CBFlipVertical.Checked then
  begin
   Application.MessageBox('You must select Horizontal or/and Vertical', Title, mb_Ok or mb_IconExclamation);
   exit;
  end;

 if CBFlipHorizontal.Checked then DO_Flip(TRUE, CBObjectOrient.Checked);
 if CBFlipVertical.Checked   then DO_Flip(FALSE, CBObjectOrient.Checked);

 MODIFIED := TRUE;
 if MAP_MODE = MM_SC then
  DO_Fill_SectorEditor
 else
  DO_Fill_ObjectEditor;

 MapWindow.Map.Invalidate;
 if not CBPin.Checked then Close;
end;

procedure TToolsWindow.BNHelpClick(Sender: TObject);
begin
 CASE ToolsNotebook.PageIndex of
  0 : Application.HelpJump('wdfuse_help_toolsgeneral');
  1 : Application.HelpJump('wdfuse_help_toolsstitching');
  2 : Application.HelpJump('wdfuse_help_toolsdistribution');
  3 : Application.HelpJump('wdfuse_help_polygons');
  4 : Application.HelpJump('wdfuse_help_deformations');
  5 : Application.HelpJump('wdfuse_help_offset');
  6 : Application.HelpJump('wdfuse_help_flipping');
 END;
end;

procedure TToolsWindow.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Shift = [] then
    Case Key of
      VK_F1     : BNHelpClick(NIL);
    end;
end;

procedure TToolsWindow.CBOnTopClick(Sender: TObject);
begin
 if CBOnTop.Checked then
  FormStyle := fsStayOnTop
 else
  FormStyle := fsNormal;
end;

procedure TToolsWindow.BNCloseClick(Sender: TObject);
begin
 Close;
end;

procedure TToolsWindow.FormCreate(Sender: TObject);
begin
 ToolsWindow.Left   := Ini.ReadInteger('WINDOWS', 'Tools          X', 0);
 ToolsWindow.Top    := Ini.ReadInteger('WINDOWS', 'Tools          Y', 72);
 ToolsWindow.CBPin.Checked   := Ini.ReadBool('WINDOWS', 'Tools          P', TRUE);
 ToolsWindow.CBOnTop.Checked := Ini.ReadBool('WINDOWS', 'Tools          T', FALSE);
end;

procedure TToolsWindow.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 Ini.WriteInteger('WINDOWS', 'Tools          X', ToolsWindow.Left);
 Ini.WriteInteger('WINDOWS', 'Tools          Y', ToolsWindow.Top);
 Ini.WriteBool   ('WINDOWS', 'Tools          P', ToolsWindow.CBPin.Checked);
 Ini.WriteBool   ('WINDOWS', 'Tools          T', ToolsWindow.CBOnTop.Checked);
end;

procedure TToolsWindow.BNSuperStitchLeftClick(Sender: TObject);
var title   : array[0..60] of char;
begin
 StrCopy(title, 'WDFUSE Tools - Super Stitch');
 if MAP_MODE = MM_WL then
  SuperStitch(SC_HILITE, WL_HILITE, 0, 1)
 else
  Application.MessageBox('You must be in WALL Mode', Title, mb_Ok or mb_IconExclamation);
end;

procedure TToolsWindow.BNSuperStitchRightClick(Sender: TObject);
var title   : array[0..60] of char;
begin
 StrCopy(title, 'WDFUSE Tools - Super Stitch');
 if MAP_MODE = MM_WL then
  SuperStitch(SC_HILITE, WL_HILITE, 0, 0)
 else
  Application.MessageBox('You must be in WALL Mode', Title, mb_Ok or mb_IconExclamation);
end;

procedure TToolsWindow.RGSplitTypeClick(Sender: TObject);
begin
 if RGSplitType.ItemIndex = 2 then
  RGStairsType.Enabled := TRUE
 else
  RGStairsType.Enabled := FALSE;

end;

procedure TToolsWindow.BNSplitClick(Sender: TObject);
var title     : array[0..60] of char;
    TheSector : TSector;
    TheWall1  : TWall;
    TheWall2  : TWall;
    w1, w2    : Integer;
begin
 StrCopy(title, 'WDFUSE Tools - Split Sector');
 if MAP_MODE <> MM_SC then
  begin
   Application.MessageBox('You must be in SECTOR Mode', Title, mb_Ok or mb_IconExclamation);
   exit;
  end;

 {Check that the sector is correctly conformed}
 TheSector := TSector(MAP_SEC.Objects[SC_HILITE]);

 if TheSector.Wl.Count <> 4 then
  begin
   Application.MessageBox('The Sector must have 4 walls', Title, mb_Ok or mb_IconExclamation);
   exit;
  end;

 TheWall1 := TWall(TheSector.Wl.Objects[1]);
 TheWall2 := TWall(TheSector.Wl.Objects[3]);

 if (TheWall1.Adjoin = -1) and (TheWall2.Adjoin = -1) then
  begin
   w1        := 1;
   w2        := 3;
  end
 else
  begin
   TheWall1 := TWall(TheSector.Wl.Objects[0]);
   TheWall2 := TWall(TheSector.Wl.Objects[2]);
   if (TheWall1.Adjoin = -1) and (TheWall2.Adjoin = -1) then
    begin
     w1        := 0;
     w2        := 2;
    end
   else
    begin
     Application.MessageBox('No suitable pair of walls found.', Title, mb_Ok or mb_IconExclamation);
     exit;
    end;
  end;

 DO_SplitSector(RGSplitType.ItemIndex,
                RGStairsType.ItemIndex,
                SEStairs.Value,
                SC_HILITE, w1, w2);
end;



end.
