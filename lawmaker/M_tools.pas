unit M_tools;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, Dialogs, Level, GlobalVars,
  SysUtils, ComCtrls, Cons_Checker, Misc_utils{, Stitch};

Const
     tp_General=0;
     tp_Stitch=1;
     tp_Distribute=2;
     tp_Polygon=3;
     tp_Deform=4;
     tp_Offset=5;
     tp_water=6;
type
  TToolsWindow = class(TForm)
    Pages: TPageControl;
    General: TTabSheet;
    BNIntegrity: TBitBtn;
    BNLayerNON: TBitBtn;
    BNLayerALL: TBitBtn;
    Stitch: TTabSheet;
    CBStitchHoriz: TCheckBox;
    CBHMid: TCheckBox;
    CBHTop: TCheckBox;
    CBHBot: TCheckBox;
    CBStitchVert: TCheckBox;
    CBVTop: TCheckBox;
    CBVMid: TCheckBox;
    CBVBot: TCheckBox;
    BNSuperStitchLeft: TBitBtn;
    BNSuperStitchRight: TBitBtn;
    BNStitch: TBitBtn;
    RGStitchHoriz: TRadioGroup;
    Bevel1: TBevel;
    Distribute: TTabSheet;
    CBAltitudes: TCheckBox;
    CBAmbient: TCheckBox;
    BNDistribute: TBitBtn;
    Polygon: TTabSheet;
    EBSides: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    EDPolyRadius: TEdit;
    Label3: TLabel;
    EDPolyX: TEdit;
    Label4: TLabel;
    EDPolyZ: TEdit;
    BNPolygon: TBitBtn;
    RGPolyAs: TRadioGroup;
    Deform: TTabSheet;
    EDRotate: TEdit;
    BNRotate: TBitBtn;
    BNRotateReverse: TBitBtn;
    Label7: TLabel;
    CBRotateOBOrient: TCheckBox;
    BNScale: TBitBtn;
    BNScaleReverse: TBitBtn;
    EDScale: TEdit;
    Label8: TLabel;
    Offset: TTabSheet;
    Label5: TLabel;
    Label6: TLabel;
    EDTranslateX: TEdit;
    EDTranslateZ: TEdit;
    Label11: TLabel;
    EDOffset: TEdit;
    BNTranslate: TBitBtn;
    BNTranslateReverse: TBitBtn;
    BNRaise: TBitBtn;
    BNOffsetReverse: TBitBtn;
    RGOffset: TRadioGroup;
    Flip: TTabSheet;
    CBFlipHorizontal: TCheckBox;
    CBFlipVertical: TCheckBox;
    CBObjectOrient: TCheckBox;
    Label10: TLabel;
    Label9: TLabel;
    BNFlip: TBitBtn;
    RGAltitudes: TRadioGroup;
    Water: TTabSheet;
    BNWaterBelow: TButton;
    BN: TButton;
    BNClose: TBitBtn;
    BNHelp: TBitBtn;
    CBOnTop: TCheckBox;
    CBPin: TCheckBox;
    BNPutOnFloor: TBitBtn;
    BNPutToCeiling: TBitBtn;
    procedure BNIntegrityClick(Sender: TObject);
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
    procedure BNRaiseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BNSuperStitchLeftClick(Sender: TObject);
    procedure BNSuperStitchRightClick(Sender: TObject);
    procedure CBAltitudesClick(Sender: TObject);
    procedure PagesChange(Sender: TObject);
    procedure CBStitchHorizClick(Sender: TObject);
    procedure CBHMidClick(Sender: TObject);
    procedure CBVMidClick(Sender: TObject);
    procedure BNPutOnFloorClick(Sender: TObject);
    procedure BNPutToCeilingClick(Sender: TObject);

  private
    { Private declarations }
  public
   MapWindow:TForm;
   Procedure NotYet;
   Procedure Display(page:Integer);
    { Public declarations }
  end;

implementation
uses Mapper;
Const
 NB_Polygon=3;
 NB_Offset=5;
{$R *.DFM}

procedure TToolsWindow.BNIntegrityClick(Sender: TObject);
begin
 TMapWindow(MapWindow).ConsChecker.Check;
 if not CBPin.Checked then Close;
end;

procedure TToolsWindow.BNLayerNONClick(Sender: TObject);
begin
 TMapWindow(MapWindow).LayerAllObjects(false);
 TMapWindow(MapWindow).Map.Invalidate;
 if not CBPin.Checked then Close;
end;

procedure TToolsWindow.BNLayerALLClick(Sender: TObject);
begin
 TMapWindow(MapWindow).LayerAllObjects(True);
 TMapWindow(MapWindow).Map.Invalidate;
 if not CBPin.Checked then Close;
end;

procedure TToolsWindow.BNStitchClick(Sender: TObject);
var how:integer;
begin
 if CBStitchHoriz.Checked then
 begin
  if RGStitchHoriz.ItemIndex = 0 then how:=st_Horizontal
  else how:=st_HorizontalInverse;
  TMapWindow(MapWindow).DO_Stitch(how,CBHMid.Checked,CBHTop.Checked,CBHBot.Checked);
 end;
 
 if CBStitchVert.Checked  then
  TMapWindow(MapWindow).DO_Stitch(st_Vertical,CBVMid.Checked, CBVTop.Checked, CBVBot.Checked);
  
 if not CBPin.Checked then Close;
end;

procedure TToolsWindow.BNDistributeClick(Sender: TObject);
var what:Integer;
begin
 what:=0;
 if CBAltitudes.Checked then
 case RGAltitudes.ItemIndex of
  0: what:=D_Floors;
  1: What:=D_Ceilings;
  2: What:=D_Floors or D_Ceilings;
 end;
 if CBAmbient.Checked then What:=What or D_Ambients;  
 TMapWindow(MapWIndow).DO_Distribute(What);
 if not CBPin.Checked then Close;
end;

procedure TToolsWindow.BNPolygonClick(Sender: TObject);
var sides:Integer;
    radius,
    c_x,
    c_z     : double;
    pt:P_type;

begin
 if not ValDouble(EDPolyRadius.Text, radius) or (radius<=0) then
 begin
  msgBox('Wrong value for Radius', 'Tools', mb_Ok or mb_IconExclamation);
  exit;
 end;

 if not ValDouble(EDPolyX.Text, c_x) then
 begin
  MsgBox('Wrong value for Center X coordinate', 'Tools', mb_Ok or mb_IconExclamation);
  exit;
 end;

 if not ValDouble(EDPolyZ.Text, c_z) then
 begin
  MsgBox('Wrong value for Center Z coordinate', 'Tools', mb_Ok or mb_IconExclamation);
  exit;
 end;

 if not ValInt(EBSides.Text,sides) then
 begin
  MsgBox('Wrong value for sides', 'Tools', mb_Ok or mb_IconExclamation);
  exit;
 end;

 Case RGPolyAs.ItemIndex of
  0: pt:=p_gap;
  1: pt:=p_subSector;
  2: pt:=p_sector;
 end;

 TMapWindow(MapWindow).MakePolygon(c_x,c_z,pt,sides,radius);
 if not CBPin.Checked then Close;
end;

procedure TToolsWindow.BNTranslateClick(Sender: TObject);
var
    x,
    z       : Double;
begin
  if not ValDouble (EDTranslateX.Text, X) then
  begin
   MsgBox('Wrong value for X Translation Offset', 'Tools', mb_Ok or mb_IconExclamation);
   exit;
  end;

  if not ValDouble(EDTranslateZ.Text, Z) then
  begin
   MsgBox('Wrong value for Z Translation Offset', 'Tools', mb_Ok or mb_IconExclamation);
   exit;
  end;

 if Sender = BNTranslate then
  TMapWindow(MapWindow).DO_Translate_SelMultiSel(x, z)
 else
  TMapWindow(MapWindow).DO_Translate_SelMultiSel(-x, -z);

 if not CBPin.Checked then Close;
end;

procedure TToolsWindow.BNRotateClick(Sender: TObject);
var code    : Integer;
    AReal,
    angle   : Double;
    title   : array[0..60] of char;
begin
  if not ValDouble(EDRotate.Text, Angle) then
   begin
    MsgBox('Wrong value for Rotation Angle', Title, mb_Ok or mb_IconExclamation);
    exit;
   end;

 if angle = 0 then angle := 360;
 if Sender = BNRotate then
  TMapWindow(MapWindow).DO_Rotate(360 - angle, CBRotateOBOrient.Checked)
 else
  TMapWindow(MapWindow).DO_Rotate(angle, CBRotateOBOrient.Checked);

 if not CBPin.Checked then Close;
end;

procedure TToolsWindow.BNScaleClick(Sender: TObject);
var
    factor  : Double;
begin
  if not ValDouble(EDScale.Text, factor) then 
  begin
   MsgBox('Wrong value for Scaling Factor', 'Tools', mb_Ok or mb_IconExclamation);
   exit;
  end;

 if factor <= 0 then
 begin
  MsgBox('Scaling Factor must be > 0', 'Tools', mb_Ok or mb_IconExclamation);
  exit;
 end;

 if Sender = BNScale then
  TMapWindow(MapWindow).DO_Scale(factor)
 else
  TMapWindow(MapWindow).DO_Scale(1/factor);

 if not CBPin.Checked then Close;
end;

procedure TToolsWindow.BNRaiseClick(Sender: TObject);
var
    RValue  : Double;
    AnInt,
    IValue  : Integer;
begin
 if not ValDouble(EDOffset.Text, RValue) then
 begin
  MsgBox('Wrong value for Altitude Offset', 'Title', mb_Ok or mb_IconExclamation);
  exit;
 end;

 if Sender = BNRaise then
  TMapWindow(MapWindow).DO_Offset(rvalue, RGOffset.ItemIndex)
 else
  TMapWindow(MapWindow).DO_Offset(-rvalue, RGOffset.ItemIndex);
 if not CBPin.Checked then Close;
end;

procedure TToolsWindow.BNFlipClick(Sender: TObject);
var title   : array[0..60] of char;
begin
NotYet;
(* StrCopy(title, 'WDFUSE Tools - Flip');

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
 if not CBPin.Checked then Close; *)
end;

procedure TToolsWindow.BNHelpClick(Sender: TObject);
begin
 Application.HelpJump('Hlp_Tools');
(* CASE ToolsNotebook.PageIndex of
  0 : Application.HelpJump('wdfuse_help_toolsgeneral');
  1 : Application.HelpJump('wdfuse_help_toolsstitching');
  2 : Application.HelpJump('wdfuse_help_toolsdistribution');
  3 : Application.HelpJump('wdfuse_help_polygons');
  4 : Application.HelpJump('wdfuse_help_deformations');
  5 : Application.HelpJump('wdfuse_help_offset');
  6 : Application.HelpJump('wdfuse_help_flipping');
 END; *)
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
 ToolsPos.wWidth:=0;
 ToolsPos.wHeight:=0;
 SetFormPos(Self,ToolsPos);
 CBOnTop.Checked:=ToolsOnTop;
end;

procedure TToolsWindow.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 GetFormPos(Self,ToolsPos);
 ToolsOnTop:=FormStyle=fsStayOnTop;
end;

procedure TToolsWindow.BNSuperStitchLeftClick(Sender: TObject);
var title   : array[0..60] of char;
begin
NotYet;
(* StrCopy(title, 'WDFUSE Tools - Super Stitch');
 if MAP_MODE = MM_WL then
  SuperStitch(SC_HILITE, WL_HILITE, 0, 1)
 else
  Application.MessageBox('You must be in WALL Mode', Title, mb_Ok or mb_IconExclamation); *)
end;

procedure TToolsWindow.BNSuperStitchRightClick(Sender: TObject);
var title   : array[0..60] of char;
begin
NotYet;
(* StrCopy(title, 'WDFUSE Tools - Super Stitch');
 if MAP_MODE = MM_WL then
  SuperStitch(SC_HILITE, WL_HILITE, 0, 0)
 else
  Application.MessageBox('You must be in WALL Mode', Title, mb_Ok or mb_IconExclamation); *)
end;

Procedure TToolsWIndow.NotYet;
begin
 MsgBox('Not implemented yet','Not implemented',mb_ok);
end;

Procedure TToolsWindow.Display(page:Integer);
begin
 With Pages do
 case page of
  tp_General: ActivePage:=General;
   tp_Stitch: ActivePage:=Stitch;
tp_Distribute:ActivePage:=Distribute;
  tp_Polygon: ActivePage:=Polygon;
   tp_Deform: ActivePage:=Deform;
   tp_Offset: ActivePage:=Offset;
 else Self.Pages.ONChange(Self);
 end;
 Show;
end;

procedure TToolsWindow.CBAltitudesClick(Sender: TObject);
begin
 if Not (CBAltitudes.Checked or CBAmbient.Checked) then
  TCheckBox(Sender).Checked:=true;
end;

procedure TToolsWindow.PagesChange(Sender: TObject);
begin
 if Pages.ActivePage=PolyGon then
 begin
  EDPolyX.Text:=FloatToStr(TMapWindow(MapWindow).GetCenterX);
  EDPolyZ.Text:=FloatToStr(TMapWindow(MapWindow).GetCenterZ);
 end;
end;

procedure TToolsWindow.CBStitchHorizClick(Sender: TObject);
begin
 if Not (CBStitchVert.Checked or CBStitchHoriz.Checked) then
 TCheckBox(Sender).Checked:=true;
end;

procedure TToolsWindow.CBHMidClick(Sender: TObject);
begin
 if Not (CBHTop.Checked or CBHBot.Checked or CBHMid.Checked) then
  TCheckBox(Sender).Checked:=true;
end;

procedure TToolsWindow.CBVMidClick(Sender: TObject);
begin
 if Not (CBVTop.Checked or CBVBot.Checked or CBVMid.Checked) then
  TCheckBox(Sender).Checked:=true;
end;

procedure TToolsWindow.BNPutOnFloorClick(Sender: TObject);
begin
 TMapWindow(MapWindow).PutObjectsOnFloor;
 if not CBPin.Checked then Close;
end;

procedure TToolsWindow.BNPutToCeilingClick(Sender: TObject);
begin
 TMapWindow(MapWindow).StickObjectsToCeiling;
 if not CBPin.Checked then Close;
end;

end.
