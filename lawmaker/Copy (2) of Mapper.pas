unit Mapper;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Buttons, ExtCtrls, IniFiles, Menus,
  StdCtrls, FileCtrl, Grids, misc_utils, Level_Utils, FileOperations,
  ComCtrls, Level, GlobalVars, MultiSelection,ShellAPI,
  m_Scedit,m_obedit,m_vxedit,m_wledit, files, Cons_Checker,
  Q_Sectors,Q_Walls, Q_Objects, M_Tools, Stitch, Containers, CopyPaste;

Const
   d_Floors=1;
   d_Ceilings=2;
   d_Ambients=4;

   st_Horizontal=0; {Stitch constants}
   st_HorizontalInverse=1;
   st_Vertical=2;


type
P_type=(p_sector,p_gap,p_subsector);
Find_type=(f_first,f_next);
  TMapWindow = class(TForm)
    ToolbarMain: TPanel;
    PanelBottom: TPanel;
    PanelText: TPanel;
    SpeedButtonOpen: TSpeedButton;
    SpeedButtonSave: TSpeedButton;
    SpeedButtonNewProject: TSpeedButton;
    SpeedButtonTest: TSpeedButton;
    DummyFileListBox: TFileListBox;
    MapPopup: TPopupMenu;
    PopupDelete: TMenuItem;
    PopupS2: TMenuItem;
    PopupS1: TMenuItem;
    PopupCopy: TMenuItem;
    PopupSplit: TMenuItem;
    PopupExtrude: TMenuItem;
    PopupAdjoin: TMenuItem;
    PopupUnAdjoin: TMenuItem;
    PopupNew: TMenuItem;
    PopupOpen: TMenuItem;
    PopupMenuDIFF: TPopupMenu;
    DIFFAll: TMenuItem;
    N1: TMenuItem;
    DIFFEasy: TMenuItem;
    DIFFMed: TMenuItem;
    DIFFHard: TMenuItem;
    SaveMapDialog: TSaveDialog;
    PopupMenuMapType: TPopupMenu;
    NormalMap: TMenuItem;
    N2: TMenuItem;
    LightsMap: TMenuItem;
    DamageMap: TMenuItem;
    SecAltitudesMap: TMenuItem;
    SkiesPitsMap: TMenuItem;
    PanelMapALL: TPanel;
    Map: TPaintBox;
    PanelMapRIGHT: TPanel;
    PanelMapBOTTOM: TPanel;
    HScrollBar: TScrollBar;
    VScrollBar: TScrollBar;
    SBCenterMap: TSpeedButton;
    MainMenu: TMainMenu;
    ProjectMenu: TMenuItem;
    ProjectExit: TMenuItem;
    ProjectSave: TMenuItem;
    ProjectOpen: TMenuItem;
    ProjectNew: TMenuItem;
    ProjectChecks: TMenuItem;
    MenuTest: TMenuItem;
    N5: TMenuItem;
    HelpMenu: TMenuItem;
    HelpContents: TMenuItem;
    HelpDFSpecs: TMenuItem;
    N6: TMenuItem;
    HelpTutorial: TMenuItem;
    HelpAbout: TMenuItem;
    N7: TMenuItem;
    HelpRegister: TMenuItem;
    ModeMenu: TMenuItem;
    ModeSectors: TMenuItem;
    ModeWalls: TMenuItem;
    ModeVertices: TMenuItem;
    ModeObjects: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    ModeShadow: TMenuItem;
    ModeObjectShadow: TMenuItem;
    ModeObjectDisplay: TMenuItem;
    ToolsMenu: TMenuItem;
    ToolsTools: TMenuItem;
    N10: TMenuItem;
    ToolsGOBFileManager: TMenuItem;
    MapMenu: TMenuItem;
    MapZoomIn: TMenuItem;
    MapZoomOut: TMenuItem;
    MapZoomNone: TMenuItem;
    N12: TMenuItem;
    MapGridIn: TMenuItem;
    MapGridOut: TMenuItem;
    MapGrid8: TMenuItem;
    N13: TMenuItem;
    MapSetMarker: TMenuItem;
    MapGotoMarker: TMenuItem;
    ModeMultiselection: TMenuItem;
    ToolbarTools: TPanel;
    SpeedButtonCenterMap: TSpeedButton;
    PanelLayer: TPanel;
    PanelMulti: TPanel;
    PanelMultiMode: TPanel;
    PanelX: TPanel;
    PanelZ: TPanel;
    PanelZoom: TPanel;
    PanelGrid: TPanel;
    PanelMapType: TPanel;
    PanelOBLayer: TPanel;
    SpeedButtonAbout: TSpeedButton;
    SpeedButtonExit: TSpeedButton;
    PanelLevelName: TPanel;
    ViewMenu: TMenuItem;
    ViewOptions: TMenuItem;
    ViewStatistics: TMenuItem;
    N4: TMenuItem;
    N15: TMenuItem;
    ViewToolbars: TMenuItem;
    N11: TMenuItem;
    MapCenter: TMenuItem;
    MSToggle: TMenuItem;
    MSAdd: TMenuItem;
    MSSubtract: TMenuItem;
    ODAll: TMenuItem;
    ODEasy: TMenuItem;
    ODMed: TMenuItem;
    ODHard: TMenuItem;
    N16: TMenuItem;
    ModeMapMode: TMenuItem;
    MMNormal: TMenuItem;
    MMLight: TMenuItem;
    MMDamage: TMenuItem;
    MM2ndAltitudes: TMenuItem;
    MMSkiesPits: TMenuItem;
    N14: TMenuItem;
    ViewEditors: TMenuItem;
    ViewEditorINF: TMenuItem;
    ViewEditorMSG: TMenuItem;
    ViewEditorTXT: TMenuItem;
    ViewEditorHeader: TMenuItem;
    TBMain: TMenuItem;
    TBTools: TMenuItem;
    FindMenu: TMenuItem;
    SM1: TMenuItem;
    SM2: TMenuItem;
    SM3: TMenuItem;
    SM4: TMenuItem;
    SM5: TMenuItem;
    GM1: TMenuItem;
    GM2: TMenuItem;
    GM3: TMenuItem;
    GM4: TMenuItem;
    GM5: TMenuItem;
    PanelNothingYet: TPanel;
    HiddenINFOutMemo: TMemo;
    N18: TMenuItem;
    EditMenu: TMenuItem;
    EditCopy: TMenuItem;
    EditPaste: TMenuItem;
    PopupMenuShadowLayers: TPopupMenu;
    N91: TMenuItem;
    N81: TMenuItem;
    N71: TMenuItem;
    N61: TMenuItem;
    N51: TMenuItem;
    N41: TMenuItem;
    N31: TMenuItem;
    N21: TMenuItem;
    N19: TMenuItem;
    N01: TMenuItem;
    N110: TMenuItem;
    N22: TMenuItem;
    N32: TMenuItem;
    N42: TMenuItem;
    N52: TMenuItem;
    N62: TMenuItem;
    N72: TMenuItem;
    N82: TMenuItem;
    N92: TMenuItem;
    SpeedButtonGridEight: TSpeedButton;
    SpeedButtonGridOut: TSpeedButton;
    SpeedButtonGridIn: TSpeedButton;
    SpeedButtonZoomOut: TSpeedButton;
    SpeedButtonZoomIn: TSpeedButton;
    SpeedButtonZoomNone: TSpeedButton;
    SpeedButtonGridOnOff: TSpeedButton;
    GridOnOff1: TMenuItem;
    PanelMapLayer: TPanel;
    LScrollBar1: TScrollBar;
    LScrollBar: TScrollBar;
    SaveProject: TSaveDialog;
    PublishDialog: TSaveDialog;
    PublishMenu: TMenuItem;
    FixUpDialog: TOpenDialog;
    ApplyFixUpMenu: TMenuItem;
    FindNext: TMenuItem;
    Pages: TPageControl;
    MapMode: TTabSheet;
    SpeedButtonSC: TSpeedButton;
    SpeedButtonWL: TSpeedButton;
    SpeedButtonVX: TSpeedButton;
    SpeedButtonOB: TSpeedButton;
    Tools: TTabSheet;
    SpeedButtonGobFM: TSpeedButton;
    SpeedButtonChecks: TSpeedButton;
    SpeedButtonTools: TSpeedButton;
    SpeedButtonQuery: TSpeedButton;
    SpeedButton1: TSpeedButton;
    SpeedButtonTKT: TSpeedButton;
    LevelPage: TTabSheet;
    SpeedButtonINF: TSpeedButton;
    SpeedButtonGOL: TSpeedButton;
    SpeedButtonMSG: TSpeedButton;
    SpeedButtonLevel: TSpeedButton;
    Misc: TTabSheet;
    SBSaveMapBMP: TSpeedButton;
    SpeedButtonOptions: TSpeedButton;
    SpeedButtonStat: TSpeedButton;
    SpeedButtonMapKey: TSpeedButton;
    SpeedButtonHelp: TSpeedButton;
    ImportMenu: TMenuItem;
    Messagewindow1: TMenuItem;
    Scripteditor1: TMenuItem;
    RecentBreak: TMenuItem;
    procedure FormActivate(Sender: TObject);
    procedure MapPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SpeedButtonAboutClick(Sender: TObject);
    procedure SpeedButtonExitClick(Sender: TObject);
    procedure MapMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure SpeedButtonOpenClick(Sender: TObject);
    procedure SpeedButtonZoomNoneClick(Sender: TObject);
    procedure SpeedButtonZoomInClick(Sender: TObject);
    procedure SpeedButtonZoomOutClick(Sender: TObject);
    procedure PanelLayerClick(Sender: TObject);
    procedure PanelGridClick(Sender: TObject);
    procedure SpeedButtonGridInClick(Sender: TObject);
    procedure SpeedButtonGridOutClick(Sender: TObject);
    procedure SpeedButtonGridEightClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SpeedButtonCenterMapClick(Sender: TObject);
    procedure SpeedButtonNewProjectClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure MapMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SpeedButtonStatClick(Sender: TObject);
    procedure PanelMultiClick(Sender: TObject);
    procedure MapMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PanelMultiModeClick(Sender: TObject);
    procedure SpeedButtonOptionsClick(Sender: TObject);
    procedure SpeedButtonSaveClick(Sender: TObject);
    procedure SpeedButtonTestClick(Sender: TObject);
    procedure SpeedButtonToolsClick(Sender: TObject);
    procedure MapPopupPopup(Sender: TObject);
    procedure PopupNewClick(Sender: TObject);
    procedure DIFFAllClick(Sender: TObject);
    procedure PanelOBLayerClick(Sender: TObject);
    procedure SpeedButtonChecksClick(Sender: TObject);
    procedure SpeedButtonLevelClick(Sender: TObject);
    procedure PanelMapTypeClick(Sender: TObject);
    procedure NormalMapClick(Sender: TObject);
    procedure SpeedButtonQueryClick(Sender: TObject);
    procedure PanelMapBOTTOMResize(Sender: TObject);
    procedure PanelMapRIGHTResize(Sender: TObject);
    procedure TBMainClick(Sender: TObject);
    procedure TBToolsClick(Sender: TObject);
    procedure HScrollBarScroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure VScrollBarScroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure LScrollBarScroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure MSToggleClick(Sender: TObject);
    procedure SM1Click(Sender: TObject);
    procedure HelpDFSpecsClick(Sender: TObject);
    procedure HelpTutorialClick(Sender: TObject);
    procedure MapDblClick(Sender: TObject);
    procedure ProjectCloseClick(Sender: TObject);
    procedure EditCopyClick(Sender: TObject);
    procedure EditPasteClick(Sender: TObject);
    procedure N91Click(Sender: TObject);
    procedure SpeedButtonSCClick(Sender: TObject);
    procedure SpeedButtonWLClick(Sender: TObject);
    procedure SpeedButtonGobFMClick(Sender: TObject);
    procedure SpeedButtonVXClick(Sender: TObject);
    procedure SpeedButtonOBClick(Sender: TObject);
    procedure SpeedButtonLfdFMClick(Sender: TObject);
    procedure SpeedButtonTKTClick(Sender: TObject);
    procedure SpeedButtonHelpClick(Sender: TObject);
    procedure SBSaveMapBMPClick(Sender: TObject);
    procedure SpeedButtonINFClick(Sender: TObject);
    procedure SpeedButtonMSGClick(Sender: TObject);
    procedure SpeedButtonTXTClick(Sender: TObject);
    procedure SpeedButtonGridOnOffClick(Sender: TObject);
    procedure PanelMapLayerClick(Sender: TObject);
    procedure SpeedButtonMapKeyClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure ToolsGOBFileManagerClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PublishMenuClick(Sender: TObject);
    procedure ApplyFixUpMenuClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure ImportMenuClick(Sender: TObject);
    procedure EditMenuClick(Sender: TObject);
    procedure Messagewindow1Click(Sender: TObject);
    procedure Scripteditor1Click(Sender: TObject);
    procedure FindNextClick(Sender: TObject);


  private
{Sector/Wall/etc editors}
 ObjectEditor:TObjectEditor;
 SectorEditor:TSectorEditor;
 WallEditor:TWallEditor;
 VertexEditor:TVertexEditor;
 FindSectors:TFindSectors;
 FindWalls:TFindWalls;
 FindObjects:TFindObjects;
 Consistency:TConsistency;
 ToolsWindow:TToolsWindow;
{ Private declarations }
  MouseDownHappened:Boolean; {Mouse was clicked over the mapper window}

  ScreenX       : Integer;
  ScreenZ       : Integer;
  ScreenCenterX : Integer;
  ScreenCenterZ : Integer;
  Xoffset       : Integer;
  Zoffset       : Integer;
  LAYER         : Integer;
  LAYER_MIN,
  LAYER_MAX     : Integer;
  MAP_RECT      : TRect;
  Scale         :Double;

{Display parameters}

  SHADOW        : Boolean;
  SHADOW_LAYERS : array[-100..100] of Boolean;
  OBSHADOW      : Boolean;
  OBLAYERMODE   : Integer;
  OBDIFF        : Integer;
  FastSCROLL    : Boolean;
  UsePlusVX     : Boolean;
  UsePlusOBShad : Boolean;
  MAP_MODE      : Integer;
  MAP_TYPE      : Integer;
  SpecialsVX    : Boolean;
  SpecialsOB    : Boolean;
  LEVELloaded   : Boolean;
  GridON        : Boolean;
  GRID          : Integer;
  FastDRAG      : Boolean;
  IsDRAG        : Boolean;
  FirstDRAG     : Boolean;
  MODIFIED      : Boolean;
  BACKUPED      : Boolean;
  IsFOCUSRECT   : Boolean;
  FOCUSRECT     : TRect;
  IsRULERLINE   : Boolean;
  ORIGIN        : TPoint;
  DESTIN        : TPoint;
  MULTISEL_MODE : String[1];

  {Level variables}
  TheLevel:TLevel;
  LevelFile:String;
  LevelSrcFile:String;
  NewLevel:Boolean;
   SC_MULTIS,
   WL_MULTIS,
   VX_MULTIS,
   OB_MULTIS     : TMultiSelection;

   SC_HILITE,
   WL_HILITE,
   VX_HILITE,
   OB_HILITE     : Integer;
   SUPERHILITE   : Integer;
   MAP_SEC_CLIP  : TStringList;
   MAP_OBJ_CLIP  : TStringList;

   function S2MX(x : Double) : Double;
   function S2MZ(z : Double) : Double;
   function M2SX(x : Double) : Integer;
   function M2SZ(z : Double) : Integer;
   function  DifficultyOk(O:TOB) : Boolean;

   function GetNearestGridPoint(X, Z : Double; VAR GX, GZ : Double) : Boolean;
   procedure DO_Layer_Up;
   procedure DO_Layer_Down;
   Procedure SetLevel(L:TLevel);
   Procedure Do_Fill_SectorEditor;
   Procedure Do_Fill_WallEditor;
   Procedure Do_Fill_VertexEditor;
   Procedure Do_Fill_ObjectEditor;

   Procedure DO_Switch_To_SC_Mode;
   Procedure DO_Switch_To_WL_Mode;
   Procedure DO_Switch_To_VX_Mode;
   Procedure DO_Switch_To_OB_Mode;

   Procedure SetScale(newscale:double);
   Procedure Do_Zoom_None;
   Procedure Do_Zoom_In;
   Procedure Do_Zoom_Out;
   Procedure DO_Center_Map;
   procedure DO_Layer_OnOff;
   Procedure DO_Set_ScrollBars_Ranges(Left, Right, Bottom, Up : Integer);
   Procedure DO_Center_On_Cursor;
   Procedure DO_Center_On_CurrentObject;
   Procedure DO_SaveProject;
   Procedure DO_ResetEditor;
   Procedure DO_OBShadow_OnOff;
   Procedure SetGrid(size:Integer);
   Procedure DO_Grid_OnOff;
   Procedure DO_Grid_In;
   Procedure DO_Grid_Out;
   Procedure DO_ScrollLRBy(N:Integer);
   Procedure DO_ScrollUDBy(N:Integer);
   procedure DO_MultiSel_SC(s : Integer);
   procedure DO_MultiSel_VX(s, v : Integer);
   procedure DO_MultiSel_WL(s, w : Integer);
   procedure DO_MultiSel_OB(o : Integer);
   procedure DO_Clear_MultiSel;
   Procedure SetCurSC(sc:Integer);
   Procedure SetCurWL(sc,wl:Integer);
   Procedure SetCurVX(sc,vx:Integer);
   Procedure SetCurOB(ob:Integer);
   procedure ShellDeleteSC;
   Procedure ShellDeleteWL(sc,wl:Integer);
   Procedure ShellDeleteVX(SC,VX:Integer);
   Procedure ShellDeleteOB;
   Procedure AdjustSelection;
   Procedure DO_MakeAdjoins;
   Procedure DO_Unadjoin;
   procedure ShellSplitWL(sc, wl : Integer);
   procedure ShellSplitVX(sc, vx : Integer);
   procedure ShellInsertOB(cursX, cursZ : Double);
   Procedure DO_Find_WL_Adjoin(n:Integer);
   Procedure DO_Find_SC_Adjoin;
   procedure MeasureWindow;
   Procedure ShellExtrudeWall;
   Procedure SynchronizeMultis(masterMulti:Integer);
   Function GetProjDir:String;
   Function DO_Publish(Const LABName:String):Boolean;
   procedure ShellInsertSC(cursX, cursZ : Double);
   procedure DO_Select_In_Rect(Var FRect:TRect);
   Procedure DO_Find(how:find_Type);
   Procedure DO_Polygon(kind:P_type);
   Procedure DO_PasteAtCursor;
   Procedure Shell_JumpTo;
   procedure RecentClick(Sender: TObject);
  protected
   { procedure WMSize(var Msg: TWMSize); message WM_SIZE;}
  public
    { Public declarations }
    Procedure AddRecent(const FName:String);
    procedure DisplayHint(Sender: TObject);
    procedure AppIdle(Sender: TObject; var Done: Boolean);
    procedure DO_Draw_BigVX(X, Z : Double; color : LongInt);
    procedure DO_Draw_WLPerp(s, w : Integer; color : LongInt);
    procedure DO_DrawShadow;
    procedure DO_DrawObjectShadow;
    procedure DO_DrawCurrentLayer;
    procedure DO_DrawCurrentLayerMono;
    procedure DO_DrawSpecials;
    procedure DO_DrawMultiSel(isxor : Boolean);
    procedure DO_DrawSelection(isxor : Boolean);
    procedure DO_DrawGrid;
    procedure DO_DrawSuperHilite;
    procedure DO_DrawLightMap;
    procedure DO_DrawDamageMap;
    procedure DO_Draw2ndAltitudeMap;
    procedure DO_DrawSkyPitMap;
    procedure DO_NewProject;
    procedure OpenLevel(Const FName:String);
    procedure ImportLevel(Const FName:String);
    function  IsPtVisible(X, Z : Double) : Boolean;
    function SetXOffset(XOff : Integer) : Boolean;
    function SetZOffset(ZOff : Integer) : Boolean;
    procedure DO_FreeGeometryClip;
    {For interface}
    Property Level:TLevel read TheLevel write SetLevel;
    Property ProjectDirectory:String read GetProjDir;
    Procedure GoTo_Sector(sc:Integer);
    Procedure GoTo_Wall(sc,wl:Integer);
    Procedure GoTo_Object(ob:Integer);
    Property SCMultiSel:TMultiSelection read SC_MULTIS;
    Property WLMultiSel:TMultiSelection read WL_MULTIS;
    Property VXMultiSel:TMultiSelection read VX_MULTIS;
    Property OBMultiSel:TMultiSelection read OB_MULTIS;
    Property ConsChecker:TConsistency read Consistency;
    Procedure LayerAllObjects(force:Boolean);
    Procedure DO_Rotate(angle:Double;rotateYaw:Boolean);
    Function GetCenterX:Double;
    Function GetCenterZ:Double;
    Procedure MakePolygon(x,z:double;kind:P_type;sides:Integer; rad:Double);
    Procedure DO_Scale(factor:double);
    procedure DO_Translate_SelMultiSel(x, z : Double);
    Procedure DO_Offset(dy:Double;how:Integer);
    Procedure DO_Distribute(what:Integer);
    Procedure DO_Stitch(how:Integer;mid,top,bot:Boolean);
    Procedure DO_CopyGeometry;
    Procedure DO_CopyObjects;
    Procedure DO_PasteGeometry(x,z:Double);
    Procedure DO_PasteObjects(x,z:Double);
    Procedure GoToLayer(NewLayer:Integer);
    Procedure ForceLayerObjects;
  end;


procedure HandleCommandLine;

var
  MapWindow: TMapWindow;

implementation

uses M_about, FileDialogs,
  ContManager, U_Options, ProgressDialog, LHEdit, M_stat, MsgWindow,
  LECScripts;

{$R *.DFM}

Procedure TMapWindow.SetLevel(L:TLevel);
begin
 TheLevel:=l;
 Layer:=1;
 Scale:=1;
 LevelLoaded:=l<>nil;
end;

function  TMapWindow.DifficultyOk(O:TOB) : Boolean;
begin
 Result := TRUE;
end;

procedure DO_FreeObjectsClip;
var i,j,k     : Integer;
    TheObject : TOB;
begin
{ for i := 0 to MAP_OBJ_Clip.Count - 1 do
  TOB(MAP_OBJ_Clip.Objects[i]).Free;
 MAP_OBJ_Clip.Clear;}
end;


procedure TMapWindow.DO_FreeGeometryClip;
var i,j,k     : Integer;
    TheSector : TSector;
    TheWall   : TWall;
begin
{  for i := 0 to MAP_SEC_Clip.Count - 1 do
   begin
    TheSector := TSector(MAP_SEC_Clip.Objects[i]);
    for j := 0 to TheSector.Vx.Count - 1 do
     TVertex(TheSector.Vx.Objects[j]).Free;
    for j := 0 to TheSector.Wl.Count - 1 do
     TWall(TheSector.Wl.Objects[j]).Free;
    TheSector.Free;
   end;
 MAP_SEC_Clip.Clear;}
end;



function TMapWindow.S2MX(x : Double) : Double;
begin
  S2MX := Xoffset + ((x - ScreenCenterX) / scale);
end;

function TMapWindow.S2MZ(z : Double) : Double;
begin
  S2MZ := Zoffset + ((ScreenCenterZ - z) / scale);
end;

function TMapWindow.M2SX(x : Double) : Integer;
begin
  M2SX := Round( ScreenCenterX + ((x - xoffset) * scale) );
end;

function TMapWindow.M2SZ(z : Double) : Integer;
begin
  M2SZ := Round( ScreenCenterZ + ((Zoffset - z) * scale) );
end;



procedure TMapWindow.DisplayHint(Sender: TObject);
begin
  PanelText.Caption := Application.Hint;
end;

procedure TMapWindow.AppIdle(Sender: TObject; var Done: Boolean);
begin
  Done := True;
end;

{  **********  **********  **********  **********  **********  **********  }

function  TMapWindow.IsPtVisible(X, Z : Double) : Boolean;
var ThePoint : TPoint;
begin
 ThePoint.X      := M2SX(X);
 ThePoint.Y      := M2SZ(Z);
 Result          := PtInRect(MAP_RECT, ThePoint);
end;

procedure TMapWindow.DO_Draw_BigVX(X, Z : Double; color : LongInt);
var Dimension : Integer;
begin
 with Map.Canvas do
  begin
    Pen.Color   := color;
    Brush.Color := color;
    Brush.Style := bsSolid;
    Dimension := Round(bigvx_scale*SCALE/2);
    if Dimension > bigvx_dim_max then Dimension := bigvx_dim_max;
    Ellipse(M2SX(X)-Dimension, M2SZ(Z)-Dimension,
            M2SX(X)+Dimension, M2SZ(Z)+Dimension);
  end;
end;

procedure TMapWindow.DO_Draw_WLPerp(s, w : Integer; color : LongInt);
var
  TheSector            : TSector;
  TheWall              : TWall;
  LVertex, RVertex     : TVertex;
  x, z, x2, z2, dx, dz : Double;
begin
Try
 with Map.Canvas do
  begin
    Pen.Color := color;
    TheSector := TheLevel.Sectors[s];
    TheWall   := TheSector.Walls[w];
    LVertex   := TheSector.Vertices[TheWall.V1];
    RVertex   := TheSector.Vertices[TheWall.V2];

    x  := (LVertex.X + RVertex.X) / 2;
    z  := (LVertex.Z + RVertex.Z) / 2;
    dx := LVertex.X - RVertex.X;
    dz := LVertex.Z - RVertex.Z;
    x2 := x - perp_ratio * dz;
    z2 := z + perp_ratio * dx;
    MoveTo(M2SX(x),  M2SZ(z));
    LineTo(M2SX(x2), M2SZ(z2));
  end;
 except
  on E:EListError do PanMessage(mt_Warning,e.Message);
 end;
end;

procedure TMapWindow.DO_DrawShadow;
var i,j         : Integer;
    TheSector   : TSector;
    LVertex     : TVertex;
    RVertex     : TVertex;
    TheWall     : TWall;
    TheMsg      : TMsg;
begin
 with Map.Canvas do
  begin
    Pen.Color := col_shadow;
    if SHADOW then
    for i := 0 to TheLevel.Sectors.Count - 1 do
      begin
        if FastSCROLL and
           (PeekMessage(TheMsg, 0, WM_KEYUP,   WM_KEYUP,   PM_NOYIELD or PM_NOREMOVE) or
            PeekMessage(TheMsg, 0, WM_LBUTTONDOWN, WM_LBUTTONDOWN, PM_NOYIELD or PM_NOREMOVE))
              then Break;
        TheSector := TheLevel.Sectors[i];
        Try
        if (TheSector.Layer <> LAYER) and SHADOW_LAYERS[TheSector.Layer] then
        for j := 0 to TheSector.Walls.Count - 1 do
          begin
            TheWall := TheSector.Walls[j];
            LVertex := TheSector.Vertices[TheWall.V1];
            RVertex := TheSector.Vertices[TheWall.V2];
            MoveTo(M2SX(LVertex.X), M2SZ(LVertex.Z));
            LineTo(M2SX(RVertex.X), M2SZ(RVertex.Z));
          end;
        except
         on E:EListError do PanMessage(mt_Warning,e.Message);
        end;
      end;
  end;
end;

procedure TMapWindow.DO_DrawObjectShadow;
var i           : Integer;
    TheSector   : TSector;
    TheObject   : TOB;
    TheLayer    : Integer;
    Dimension   : Integer;
    TheMsg      : TMsg;
begin
 with Map.Canvas do
  begin
    Pen.Color := col_shadow;
    Dimension := Round(ob_scale*SCALE/2);
    if Dimension > ob_dim_max then Dimension := ob_dim_max;
    if OBSHADOW then
     for i := 0 to TheLevel.Objects.Count - 1 do
      begin
      if FastSCROLL and
           (PeekMessage(TheMsg, 0, WM_KEYUP,   WM_KEYUP,   PM_NOYIELD or PM_NOREMOVE) or
            PeekMessage(TheMsg, 0, WM_LBUTTONDOWN, WM_LBUTTONDOWN, PM_NOYIELD or PM_NOREMOVE))
              then Break;
       TheObject := TheLevel.Objects[i];
       if not DifficultyOk(TheObject) then continue;
       if (TheObject.Sector > -1) and (TheObject.Sector<TheLevel.Sectors.Count) then
        begin
         TheSector := TheLevel.Sectors[TheObject.Sector];
         TheLayer  := TheSector.Layer;
        end
       else
        TheLayer := 9999;
       if (TheLayer = LAYER) or (TheLayer = 9999) then
        begin
         if IsPtVisible(TheObject.X, TheObject.Z) then
         if not UsePlusOBShad then
           Ellipse(M2SX(TheObject.X)-Dimension, M2SZ(TheObject.Z)-Dimension,
                 M2SX(TheObject.X)+Dimension, M2SZ(TheObject.Z)+Dimension)
         else
          begin
           MoveTo(M2SX(TheObject.X)-Dimension, M2SZ(TheObject.Z));
           LineTo(M2SX(TheObject.X)+Dimension, M2SZ(TheObject.Z));
           MoveTo(M2SX(TheObject.X),M2SZ(TheObject.Z) -Dimension);
           LineTo(M2SX(TheObject.X),M2SZ(TheObject.Z) +Dimension);
          end;
        end;
      end;
  end;
end;

procedure TMapWindow.DO_DrawCurrentLayer;
var i,j         : Integer;
    TheSector   : TSector;
    LVertex     : TVertex;
    RVertex     : TVertex;
    TheWall     : TWall;
    Npen, Apen  : HPen;
    OldPen      : HPen;
    TheMsg      : TMsg;
begin
 with Map.Canvas do
  begin
   NPen := CreatePen(PS_SOLID, 1, col_wall_n);
   APen := CreatePen(PS_SOLID, 1, col_wall_a);
   OldPen := SelectObject(Handle, NPen);
   for i := 0 to TheLevel.Sectors.Count - 1 do
    begin
      if FastSCROLL and
           (PeekMessage(TheMsg, 0, WM_KEYUP,   WM_KEYUP,   PM_NOYIELD or PM_NOREMOVE) or
            PeekMessage(TheMsg, 0, WM_LBUTTONDOWN, WM_LBUTTONDOWN, PM_NOYIELD or PM_NOREMOVE))
              then Break;
   Try
      TheSector := TheLevel.Sectors[i];
      if TheSector.Layer = LAYER then
      for j := 0 to TheSector.Walls.Count - 1 do
        begin
          TheWall := TheSector.Walls[j];

          if TheWall.Adjoin = -1 then
           SelectObject(Handle, NPen)
          else
           SelectObject(Handle, APen);
          {
          LVertex := TVertex(TheSector.Vx.Objects[TheWall.left_vx]);
          RVertex := TVertex(TheSector.Vx.Objects[TheWall.right_vx]);
          MoveTo(M2SX(LVertex.X), M2SZ(LVertex.Z));
          LineTo(M2SX(RVertex.X), M2SZ(RVertex.Z));
          }
          MoveTo(M2SX(TheSector.Vertices[TheWall.V1].X),
                 M2SZ(TheSector.Vertices[TheWall.V1].Z));
          LineTo(M2SX(TheSector.Vertices[TheWall.V2].X),
                 M2SZ(TheSector.Vertices[TheWall.V2].Z));
        end;
   except
    on E:EListError do PanMessage(mt_Warning,e.Message);
   end;
    end;

   SelectObject(Handle, OldPen);
   DeleteObject(NPen);
   DeleteObject(APen);
  end;
end;

procedure TMapWindow.DO_DrawCurrentLayerMono;
var i,j         : Integer;
    TheSector   : TSector;
    LVertex     : TVertex;
    RVertex     : TVertex;
    TheWall     : TWall;
    Apen        : HPen;
    OldPen      : HPen;
begin
 with Map.Canvas do
  begin
   APen := CreatePen(PS_SOLID, 1, col_wall_a);
   OldPen := SelectObject(Handle, APen);
   for i := 0 to TheLevel.Sectors.Count - 1 do
    begin
    try
      TheSector := TheLevel.Sectors[i];
      if TheSector.Layer = LAYER then
      for j := 0 to TheSector.Walls.Count - 1 do
        begin
          TheWall := TheSector.Walls[j];
          LVertex := TheSector.Vertices[TheWall.V1];
          RVertex := TheSector.Vertices[TheWall.V2];
          MoveTo(M2SX(LVertex.X), M2SZ(LVertex.Z));
          LineTo(M2SX(RVertex.X), M2SZ(RVertex.Z));
        end;
     except
      on E:EListError do PanMessage(mt_Warning,e.Message);
     end;
    end;
   SelectObject(Handle, OldPen);
   DeleteObject(APen);
  end;
end;

procedure TMapWindow.DO_DrawSpecials;
var i,j         : Integer;
    TheSector   : TSector;
    LVertex     : TVertex;
    RVertex     : TVertex;
    TheWall     : TWall;
    TheMsg      : TMsg;
begin
 if (MAP_MODE = MM_VX) and not SpecialsVX then Exit;
 if (MAP_MODE = MM_OB) and not SpecialsOB then Exit;

 with Map.Canvas do
  begin
   for i := 0 to TheLevel.Sectors.Count - 1 do
    begin
      if FastSCROLL and
           (PeekMessage(TheMsg, 0, WM_KEYUP,   WM_KEYUP,   PM_NOYIELD or PM_NOREMOVE) or
            PeekMessage(TheMsg, 0, WM_LBUTTONDOWN, WM_LBUTTONDOWN, PM_NOYIELD or PM_NOREMOVE))
              then Break;
      TheSector :=TheLevel.Sectors[i];
      if TheSector.Layer = LAYER then
      for j := 0 to TheSector.Walls.Count - 1 do
        begin
          TheWall := TheSector.Walls[j];
          if (TheSector.Elevator or
              TheSector.Trigger  or
              TheSector.Secret   or
              TheWall.Elevator   or
              TheWall.Trigger    ) then
           begin
            if TheSector.Elevator  then Pen.Color := col_elev;
            if TheSector.Trigger   then Pen.Color := col_trig;
            if TheSector.Secret    then Pen.Color := col_secr;
            if TheWall.Elevator    then Pen.Color := col_elev;
            if TheWall.Trigger     then Pen.Color := col_trig;

            LVertex := TheSector.Vertices[TheWall.V1];
            RVertex := TheSector.Vertices[TheWall.V2];
            MoveTo(M2SX(LVertex.X), M2SZ(LVertex.Z));
            LineTo(M2SX(RVertex.X), M2SZ(RVertex.Z));
            if TheWall.Trigger then DO_Draw_WLperp(i, j, col_trig);
           end;
        end;
    end;
  end;
end;

procedure TMapWindow.DO_DrawMultiSel(isxor : Boolean);
var j,m,s,w     : Integer;
    TheSector   : TSector;
    TheVertex   : TVertex;
    LVertex     : TVertex;
    RVertex     : TVertex;
    TheWall     : TWall;
    TheObject   : TOB;
    Dimension   : Integer;
begin
  if LEVELloaded then
    with Map.Canvas do
      begin
        Pen.Color := col_multis;
        if isxor then
         Pen.Mode := pmXor
        else
         Pen.Mode := pmCopy;
        CASE MAP_MODE OF
        MM_SC: begin
                 for m := 0 to SC_MULTIS.Count - 1 do
                  begin
                   TheSector := TheLevel.Sectors[SC_MULTIS.GetSector(m)];
                   for j := 0 to TheSector.Walls.Count - 1 do
                     begin
                       TheWall := TheSector.Walls[j];
                       LVertex := TheSector.Vertices[TheWall.V1];
                       RVertex := TheSector.Vertices[TheWall.V2];
                       MoveTo(M2SX(LVertex.X), M2SZ(LVertex.Z));
                       LineTo(M2SX(RVertex.X), M2SZ(RVertex.Z));
                     end;
                   end;
               end;
        MM_WL: begin
                 for m := 0 to WL_MULTIS.Count - 1 do
                  begin
                   s := WL_MULTIS.GetSector(m);
                   TheSector := TheLevel.Sectors[s];
                   w := WL_MULTIS.GetWall(m);
                   TheWall := TheSector.Walls[w];
                   LVertex := TheSector.Vertices[TheWall.V1];
                   RVertex := TheSector.Vertices[TheWall.V2];
                   MoveTo(M2SX(LVertex.X), M2SZ(LVertex.Z));
                   LineTo(M2SX(RVertex.X), M2SZ(RVertex.Z));
                   DO_Draw_WLperp(s, w, col_multis);
                  end;
               end;
        MM_VX: begin
                 Dimension := Round(vx_scale*SCALE/2);
                 if Dimension > vx_dim_max then Dimension := vx_dim_max;
                 for m := 0 to VX_MULTIS.Count - 1 do
                  begin
                   TheSector := TheLevel.Sectors[VX_MULTIS.GetSector(m)];
                   TheVertex := TheSector.Vertices[VX_MULTIS.GetVertex(m)];
                   if IsPtVisible(TheVertex.X, TheVertex.Z) then
                    if not UsePlusVX then
                      Ellipse(M2SX(TheVertex.X)-Dimension, M2SZ(TheVertex.Z)-Dimension,
                              M2SX(TheVertex.X)+Dimension, M2SZ(TheVertex.Z)+Dimension)
                    else
                     begin
                      MoveTo(M2SX(TheVertex.X)-Dimension, M2SZ(TheVertex.Z));
                      LineTo(M2SX(TheVertex.X)+Dimension, M2SZ(TheVertex.Z));
                      MoveTo(M2SX(TheVertex.X),M2SZ(TheVertex.Z) -Dimension);
                      LineTo(M2SX(TheVertex.X),M2SZ(TheVertex.Z) +Dimension);
                     end;
                  end;
               end;
        MM_OB: begin
                Dimension := Round(ob_scale*SCALE/2);
                if Dimension > ob_dim_max then Dimension := ob_dim_max;
                for m := 0 to OB_MULTIS.Count - 1 do
                  begin
                   TheObject := TheLevel.Objects[OB_MULTIS.GetObject(m)];
                   if IsPtVisible(TheObject.X, TheObject.Z) then
                    Rectangle(M2SX(TheObject.X)-Dimension, M2SZ(TheObject.Z)-Dimension,
                              M2SX(TheObject.X)+Dimension, M2SZ(TheObject.Z)+Dimension)
                end;
               end;
        END;
       Pen.Mode := pmCopy;
      end;
end;

procedure TMapWindow.DO_DrawSelection(isxor : Boolean);
var j           : Integer;
    TheSector   : TSector;
    TheVertex   : TVertex;
    LVertex     : TVertex;
    RVertex     : TVertex;
    TheWall     : TWall;
    TheObject   : TOB;
    Dimension   : Integer;
begin
Try
  if LEVELloaded then
    with Map.Canvas do
      begin
        Pen.Color := col_select;
        if isxor then
         Pen.Mode := pmXor
        else
         Pen.Mode := pmCopy;
        CASE MAP_MODE OF
        MM_SC: begin
                 TheSector := TheLevel.Sectors[SC_HILITE];
                 for j := 0 to TheSector.Walls.Count - 1 do
                   begin
                     TheWall := TheSector.Walls[j];
                     LVertex := TheSector.Vertices[TheWall.V1];
                     if j = 0 then DO_Draw_BigVX(LVertex.X, LVertex.Z, col_select);
                     RVertex := TheSector.Vertices[TheWall.V2];
                     MoveTo(M2SX(LVertex.X), M2SZ(LVertex.Z));
                     LineTo(M2SX(RVertex.X), M2SZ(RVertex.Z));
                   end;
               end;
        MM_WL: begin
                 TheSector := TheLevel.Sectors[SC_HILITE];
                 TheWall := TheSector.Walls[WL_HILITE];
                 LVertex := TheSector.Vertices[TheWall.V1];
                 DO_Draw_BigVX(LVertex.X, LVertex.Z, col_select);
                 RVertex := TheSector.Vertices[TheWall.V2];
                 MoveTo(M2SX(LVertex.X), M2SZ(LVertex.Z));
                 LineTo(M2SX(RVertex.X), M2SZ(RVertex.Z));
                 DO_Draw_WLperp(SC_HILITE, WL_HILITE, col_select);
               end;
        MM_VX: begin
                 Dimension := Round(vx_scale*SCALE/2);
                 if Dimension > vx_dim_max then Dimension := vx_dim_max;
                 TheSector := TheLevel.Sectors[SC_HILITE];
                 TheVertex := TheSector.Vertices[VX_HILITE];
                 DO_Draw_BigVX(TheVertex.X, TheVertex.Z, col_select);
               end;
        MM_OB: begin
                Dimension := Round(bigob_scale*SCALE/2);
                if Dimension > bigob_dim_max then Dimension := bigob_dim_max;
                Brush.Style := bsClear;
                Pen.Width := 2;
                TheObject := TheLevel.Objects[OB_HILITE];
                Ellipse(M2SX(TheObject.X)-Dimension, M2SZ(TheObject.Z)-Dimension,
                        M2SX(TheObject.X)+Dimension + 1, M2SZ(TheObject.Z)+Dimension + 1);
                Brush.Style := bsSolid;
                {object orientation}
                MoveTo(M2SX(TheObject.x) + Round(1.1 * Dimension * sin(TheObject.Yaw/360*6.283)),
                       M2SZ(TheObject.z) - Round(1.1 * Dimension * cos(TheObject.Yaw/360*6.283)));
                LineTo(M2SX(TheObject.x) + Round(5   * Dimension * sin(TheObject.Yaw/360*6.283)),
                       M2SZ(TheObject.z) - Round(5   * Dimension * cos(TheObject.Yaw/360*6.283)));
                Pen.Width := 1;
               end;
        END;
       Pen.Mode := pmCopy;
      end;
except
 on E:EListError do PanMessage(mt_Warning,e.Message);
end;
end;

procedure TMapWindow.DO_DrawGrid;
var i, j   : Integer;
    TheMsg : TMsg;
    w,h,step,start:integer;
begin
 w:=Map.Width;  h:=Map.Height;
 Start:=Round(S2MX(0));
 Step:=Round(S2MX(Grid)-S2MX(0)*256);
  with Map.Canvas do
    begin
      i := Round(S2MX(0)/Grid)*Grid-Grid;
      while  i <= Round(S2MX(ScreenX)/Grid)*Grid+Grid do
        begin
          if FastSCROLL and
           (PeekMessage(TheMsg, 0, WM_KEYUP,   WM_KEYUP,   PM_NOYIELD or PM_NOREMOVE) or
            PeekMessage(TheMsg, 0, WM_LBUTTONDOWN, WM_LBUTTONDOWN, PM_NOYIELD or PM_NOREMOVE))
              then Break;
          j := Round(S2MZ(ScreenZ)/Grid)*Grid-Grid;
          while j <= Round(S2MZ(0)/Grid)*Grid+Grid do
            begin
              SetPixelV(Handle, M2SX(i), M2SZ(j), col_grid);
              Inc(j ,Grid);
            end;
          Inc(i, Grid);
        end;
    end;
end;

procedure TMapWindow.DO_DrawSuperHilite;
var j           : Integer;
    TheSector   : TSector;
    LVertex     : TVertex;
    RVertex     : TVertex;
    TheWall     : TWall;
begin
 if LEVELLoaded then
  if SUPERHILITE <> -1 then
   with Map.Canvas do
    begin
      Pen.Color := col_select;
      Pen.Width := 2;
      TheSector := TheLevel.Sectors[SUPERHILITE];
      for j := 0 to TheSector.Walls.Count - 1 do
       begin
         TheWall := TheSector.Walls[j];
         LVertex := TheSector.Vertices[TheWall.V1];
         RVertex := TheSector.Vertices[TheWall.V2];
         MoveTo(M2SX(LVertex.X), M2SZ(LVertex.Z));
         LineTo(M2SX(RVertex.X), M2SZ(RVertex.Z));
       end;
      Pen.Width := 1;
      Pen.Style := psSolid;
    end;
end;

procedure TMapWindow.DO_DrawLightMap;
var i,j,w       : Integer;
    TheSector   : TSector;
    LVertex     : TVertex;
    RVertex     : TVertex;
    TheWall     : TWall;
    deltax,
    deltaz      : Double;
    dx, dz      : Integer;
    px, pz      : Double;
    TheMsg      : TMsg;
begin
 with Map.Canvas do
  begin
   Brush.Style := bsSolid;
   for i := 0 to TheLevel.Sectors.Count - 1 do
    begin
      if FastSCROLL and
       (PeekMessage(TheMsg, 0, WM_KEYUP,   WM_KEYUP,   PM_NOYIELD or PM_NOREMOVE) or
        PeekMessage(TheMsg, 0, WM_LBUTTONDOWN, WM_LBUTTONDOWN, PM_NOYIELD or PM_NOREMOVE))
       then Break;
      TheSector := TheLevel.Sectors[i];
      if TheSector.Layer = LAYER then
       begin
        for j := 0 to 1 do
         begin
          (*
          {this should give a better fill by trying again at the wall
           opposite wall 0. It is also twice slower !}
          if j = 0 then
           w := 0
          else
           w := TheSector.Wl.Count div 2;

          {leave it disabled for now, as there is a light per sector for
           sure, we'll enable it in the other maps, which have far less
           to draw !}
          *)
          if j = 1 then break;
          w := 0;

          TheWall := TheSector.Walls[w];
          LVertex := TheSector.Vertices[TheWall.V1];
          RVertex := TheSector.Vertices[TheWall.V2];
          {find a point near the middle of the wall, but INSIDE the
           sector, and start floodfilling from there, with a color
           related to the Ambient of the sector}
          deltax  := LVertex.X - RVertex.x;
          deltaz  := LVertex.z - RVertex.z;
          if deltax > 0 then dx := 1;
          if deltax = 0 then dx := 0;
          if deltax < 0 then dx := -1;
          if deltaz > 0 then dz := 1;
          if deltaz = 0 then dz := 0;
          if deltaz < 0 then dz := -1;
          px      := (LVertex.X + RVertex.X) / 2;
          pz      := (LVertex.Z + RVertex.Z) / 2;

          Brush.Color := RGB(6*TheSector.Ambient+32,
                             6*TheSector.Ambient+32,
                             6*TheSector.Ambient+32);

          {it is -dx because of the direction of the Z axis in WINDOWS !}
          FloodFill(M2SX(px)-dz, M2SZ(pz)-dx, col_wall_a, fsBorder);
         end;
       end;
    end;
  end;
end;

procedure TMapWindow.DO_DrawDamageMap;
var i,j,w       : Integer;
    dam         : Integer;
    TheSector   : TSector;
    LVertex     : TVertex;
    RVertex     : TVertex;
    TheWall     : TWall;
    deltax,
    deltaz      : Double;
    dx, dz      : Integer;
    px, pz      : Double;
    TheMsg      : TMsg;
begin
 with Map.Canvas do
  begin
   Brush.Style := bsSolid;
   for i := 0 to TheLevel.Sectors.Count - 1 do
    begin
      if FastSCROLL and
       (PeekMessage(TheMsg, 0, WM_KEYUP,   WM_KEYUP,   PM_NOYIELD or PM_NOREMOVE) or
        PeekMessage(TheMsg, 0, WM_LBUTTONDOWN, WM_LBUTTONDOWN, PM_NOYIELD or PM_NOREMOVE))
       then Break;
      TheSector := TheLevel.Sectors[i];
      if TheSector.Layer = LAYER then
       begin
        for j := 0 to 1 do
         begin
          {this should give a better fill by trying again at the wall
           opposite wall 0. It is also twice slower !}
          if j = 0 then
           w := 0
          else
           w := TheSector.Walls.Count div 2;

          dam := 0;
          if (TheSector.Flags and SECFLAG1_SECDAMAGE_SML) <> 0 then dam := dam + 1;
          if (TheSector.Flags and SECFLAG1_SECDAMAGE_LGE) <> 0 then dam := dam + 2;

          if dam <> 0 then
           begin
            TheWall := TheSector.Walls[w];
            LVertex := TheSector.Vertices[TheWall.V1];
            RVertex := TheSector.Vertices[TheWall.V2];
            deltax  := LVertex.X - RVertex.x;
            deltaz  := LVertex.z - RVertex.z;
            if deltax > 0 then dx := 1;
            if deltax = 0 then dx := 0;
            if deltax < 0 then dx := -1;
            if deltaz > 0 then dz := 1;
            if deltaz = 0 then dz := 0;
            if deltaz < 0 then dz := -1;
            px      := (LVertex.X + RVertex.X) / 2;
            pz      := (LVertex.Z + RVertex.Z) / 2;

            case dam of
             1 : Brush.Color := Col_dm_low;
             2 : Brush.Color := Col_dm_high;
             3 : Brush.Color := Col_dm_gas;
            end;

            FloodFill(M2SX(px)-dz, M2SZ(pz)-dx, col_wall_a, fsBorder);
           end;
         end;
       end;
    end;
  end;
end;

procedure TMapWindow.DO_Draw2ndAltitudeMap;
var i,j,w       : Integer;
    dam         : Integer;
    TheSector   : TSector;
    LVertex     : TVertex;
    RVertex     : TVertex;
    TheWall     : TWall;
    deltax,
    deltaz      : Double;
    dx, dz      : Integer;
    px, pz      : Double;
    TheMsg      : TMsg;
begin
 with Map.Canvas do
  begin
   Brush.Style := bsSolid;
   for i := 0 to TheLevel.Sectors.Count - 1 do
    begin
      if FastSCROLL and
       (PeekMessage(TheMsg, 0, WM_KEYUP,   WM_KEYUP,   PM_NOYIELD or PM_NOREMOVE) or
        PeekMessage(TheMsg, 0, WM_LBUTTONDOWN, WM_LBUTTONDOWN, PM_NOYIELD or PM_NOREMOVE))
       then Break;
      TheSector := TheLevel.Sectors[i];
      if TheSector.Layer = LAYER then
       begin
        for j := 0 to 1 do
         begin
          {this should give a better fill by trying again at the wall
           opposite wall 0. It is also twice slower !}
          if j = 0 then
           w := 0
          else
           w := TheSector.Walls.Count div 2;

          dam := 0;
          if dam <> 0 then
           begin
            TheWall := TheSector.Walls[w];
            LVertex := TheSector.Vertices[TheWall.V1];
            RVertex := TheSector.Vertices[TheWall.V2];
            deltax  := LVertex.X - RVertex.x;
            deltaz  := LVertex.z - RVertex.z;
            if deltax > 0 then dx := 1;
            if deltax = 0 then dx := 0;
            if deltax < 0 then dx := -1;
            if deltaz > 0 then dz := 1;
            if deltaz = 0 then dz := 0;
            if deltaz < 0 then dz := -1;
            px      := (LVertex.X + RVertex.X) / 2;
            pz      := (LVertex.Z + RVertex.Z) / 2;

            case dam of
             1 : Brush.Color := Col_2a_water;
             2 : Brush.Color := Col_2a_catwlk;
            end;

            FloodFill(M2SX(px)-dz, M2SZ(pz)-dx, col_wall_a, fsBorder);
           end;
         end;
       end;
    end;
  end;
end;

procedure TMapWindow.DO_DrawSkyPitMap;
var i,j,w       : Integer;
    dam         : Integer;
    TheSector   : TSector;
    LVertex     : TVertex;
    RVertex     : TVertex;
    TheWall     : TWall;
    deltax,
    deltaz      : Double;
    dx, dz      : Integer;
    px, pz      : Double;
    TheMsg      : TMsg;
begin
 with Map.Canvas do
  begin
   Brush.Style := bsSolid;
   for i := 0 to TheLevel.Sectors.Count - 1 do
    begin
      if FastSCROLL and
       (PeekMessage(TheMsg, 0, WM_KEYUP,   WM_KEYUP,   PM_NOYIELD or PM_NOREMOVE) or
        PeekMessage(TheMsg, 0, WM_LBUTTONDOWN, WM_LBUTTONDOWN, PM_NOYIELD or PM_NOREMOVE))
       then Break;
      TheSector := TheLevel.Sectors[i];
      if TheSector.Layer = LAYER then
       begin
        for j := 0 to 1 do
         begin
          {this should give a better fill by trying again at the wall
           opposite wall 0. It is also twice slower !}
          if j = 0 then
           w := 0
          else
           w := TheSector.Walls.Count div 2;

          dam := 0;
          if (TheSector.Flags and 1)   <> 0 then dam := 1;
          if (TheSector.Flags and 128) <> 0 then dam := 2;

          if dam <> 0 then
           begin
            TheWall := TheSector.Walls[w];
            LVertex := TheSector.Vertices[TheWall.V1];
            RVertex := TheSector.Vertices[TheWall.V2];
            deltax  := LVertex.X - RVertex.x;
            deltaz  := LVertex.z - RVertex.z;
            if deltax > 0 then dx := 1;
            if deltax = 0 then dx := 0;
            if deltax < 0 then dx := -1;
            if deltaz > 0 then dz := 1;
            if deltaz = 0 then dz := 0;
            if deltaz < 0 then dz := -1;
            px      := (LVertex.X + RVertex.X) / 2;
            pz      := (LVertex.Z + RVertex.Z) / 2;

            case dam of
             1 : Brush.Color := Col_sp_sky;
             2 : Brush.Color := Col_sp_pit;
            end;

            FloodFill(M2SX(px)-dz, M2SZ(pz)-dx, col_wall_a, fsBorder);
           end;
         end;
       end;
    end;
  end;
end;

procedure TMapWindow.MapPaint(Sender: TObject);
var i,j         : Integer;
    TheSector   : TSector;
    TheVertex   : TVertex;
    LVertex     : TVertex;
    RVertex     : TVertex;
    TheWall     : TWall;
    TheObject   : TOB;
    TheLayer    : Integer;
    Dimension   : Integer;
    TheMsg      : TMsg;
begin

if LEVELloaded then
  with Map.Canvas do
    begin
     CASE MAP_MODE OF
      MM_SC,
      MM_WL: begin
               if MAP_TYPE = MT_NO then
                begin
                 {draw the grid}
                 if GridON then DO_DrawGrid;
                 {draw the shadow}
                 DO_DrawShadow;
                 DO_DrawOBjectShadow;
                 {draw the current layer}
                 DO_DrawCurrentLayer;
                end
               else
                begin
                 DO_DrawCurrentLayerMono;
                 CASE MAP_TYPE OF
                  MT_LI : DO_DrawLightMap;
                  MT_DM : DO_DrawDamageMap;
                  MT_2A : DO_Draw2ndAltitudeMap;
                  MT_SP : DO_DrawSkyPitMap;
                 END;
                 {draw the grid}
                 if GridON then DO_DrawGrid;
                 DO_DrawShadow;
                 DO_DrawOBjectShadow;
                 DO_DrawCurrentLayer;
                end;
             end;
      MM_VX: begin
              {draw the grid}
              if GridON then DO_DrawGrid;
              {draw the shadow (special for MM_VX)}
              Pen.Color := col_shadow;
              for i := 0 to TheLevel.Sectors.Count - 1 do
                begin
                  if FastSCROLL and
                    (PeekMessage(TheMsg, 0, WM_KEYUP,   WM_KEYUP,   PM_NOYIELD or PM_NOREMOVE) or
                     PeekMessage(TheMsg, 0, WM_LBUTTONDOWN, WM_LBUTTONDOWN, PM_NOYIELD or PM_NOREMOVE))
                     then Break;
      Try
                  TheSector := TheLevel.Sectors[i];
                  if SHADOW or (TheSector.Layer = LAYER) then
                  for j := 0 to TheSector.Walls.Count - 1 do
                    begin
                      TheWall := TheSector.Walls[j];
                      LVertex := TheSector.Vertices[TheWall.V1];
                      RVertex := TheSector.Vertices[TheWall.V2];
                      MoveTo(M2SX(LVertex.X), M2SZ(LVertex.Z));
                      LineTo(M2SX(RVertex.X), M2SZ(RVertex.Z));
                    end;
      except
       on E:EListError do PanMessage(mt_Warning,e.Message);
      end;
                end;


               DO_DrawOBjectShadow;
               {draw the current layer}
               Pen.Color := col_wall_a;
               Dimension := Round(vx_scale*SCALE/2);
               if Dimension > vx_dim_max then Dimension := vx_dim_max;
               for i := 0 to TheLevel.Sectors.Count - 1 do
                begin
                  if FastSCROLL and
                   (PeekMessage(TheMsg, 0, WM_KEYUP,   WM_KEYUP,   PM_NOYIELD or PM_NOREMOVE) or
                    PeekMessage(TheMsg, 0, WM_LBUTTONDOWN, WM_LBUTTONDOWN, PM_NOYIELD or PM_NOREMOVE))
                    then Break;
      try
                  TheSector := TheLevel.Sectors[i];
                  if TheSector.Layer = LAYER then
                  for j := 0 to TheSector.Vertices.Count - 1 do
                    begin
                      TheVertex := TheSector.Vertices[j];
                      if IsPtVisible(TheVertex.X, TheVertex.Z) then
                      if not UsePlusVX then
                       Ellipse(M2SX(TheVertex.X)-Dimension, M2SZ(TheVertex.Z)-Dimension,
                               M2SX(TheVertex.X)+Dimension, M2SZ(TheVertex.Z)+Dimension)
                      else
                       begin
                        MoveTo(M2SX(TheVertex.X)-Dimension, M2SZ(TheVertex.Z));
                        LineTo(M2SX(TheVertex.X)+Dimension, M2SZ(TheVertex.Z));
                        MoveTo(M2SX(TheVertex.X),M2SZ(TheVertex.Z) -Dimension);
                        LineTo(M2SX(TheVertex.X),M2SZ(TheVertex.Z) +Dimension);
                       end;
                    end;
      except
       on E:EListError do PanMessage(mt_Warning,e.Message);
      end;
                end;
             end;
      MM_OB: begin
              {draw the grid}
              if GridON then DO_DrawGrid;
              {draw the shadow}
              DO_DrawShadow;
              {draw the current layer}
              DO_DrawCurrentLayer;
              Dimension := Round(ob_scale*SCALE/2);
              if Dimension > ob_dim_max then Dimension := ob_dim_max;
              for i := 0 to TheLevel.Objects.Count - 1 do
                begin
                  if FastSCROLL and
                   (PeekMessage(TheMsg, 0, WM_KEYUP,   WM_KEYUP,   PM_NOYIELD or PM_NOREMOVE) or
                    PeekMessage(TheMsg, 0, WM_LBUTTONDOWN, WM_LBUTTONDOWN, PM_NOYIELD or PM_NOREMOVE))
                    then Break;
                  TheObject := TheLevel.Objects[i];
                  if not DifficultyOk(TheObject) then continue;

                  if (TheObject.Sector>-1) and (TheObject.Sector<TheLevel.Sectors.Count) then
                   begin
                    TheSector := TheLevel.Sectors[TheObject.Sector];
                    TheLayer  := TheSector.Layer;
                   end
                  else
                   TheLayer := 9999;

                  if (TheLayer = LAYER) or (TheLayer = 9999) then
                   begin
                    Pen.Color := col_Object; {TheObject.Col;}
                    if IsPtVisible(TheObject.X, TheObject.Z) then
                    Rectangle(M2SX(TheObject.X)-Dimension, M2SZ(TheObject.Z)-Dimension,
                              M2SX(TheObject.X)+Dimension, M2SZ(TheObject.Z)+Dimension);
                   end;
                end;
             end;
     END; {CASE MAP_MODE OF}
     {draw the specials}
     DO_DrawSpecials;
     {draw the multiselection}
     DO_DrawMultiSel(FALSE);
     {draw the selection}
     DO_DrawSelection(FALSE);
     {draw the SuperHilite, ie the slave / client of the selection }
     DO_DrawSuperHilite;
    end; {with Map.Canvas}

{just to be sure}
if LEVELLoaded then
 begin
  Map.Canvas.Pen.Width   := 1;
  Map.Canvas.Pen.Color   := clGray;
  Map.Canvas.Pen.Style   := psSolid;
  Map.Canvas.Brush.Color := col_back;
  Map.Canvas.Brush.Style := bsSolid;
 end;
end;

procedure TMapWindow.FormCreate(Sender: TObject);
var OldCursor : HCursor;
    IniName   : TFileName;
    i, cnt    : Integer;
    section   : String;
begin
 {Create Sector/Wall/Vertex/Object editors}

  Application.OnIdle := AppIdle;
  TheLevel:=TLevel.Create;

  OldCursor  := SetCursor(LoadCursor(0, IDC_WAIT));
  LEVELloaded      := FALSE;

  MAP_SEC_CLIP     := TStringList.Create;
  MAP_OBJ_CLIP     := TStringList.Create;
   SC_MULTIS:=TMultiSelection.Create;
   WL_MULTIS:=TMultiSelection.Create;
   VX_MULTIS:=TMultiSelection.Create;
   OB_MULTIS:=TMultiSelection.Create;


  for i := -100 to 100 do SHADOW_LAYERS[i] := TRUE;
  Scale:=1;
  Layer:=1;
  MeasureWindow;

  SetCursor(OldCursor);
end;

procedure TMapWindow.FormClose(Sender: TObject; var Action: TCloseAction);
var i         : Integer;
    section   : String;
begin
 ObjectEditor.Free;
 VertexEditor.Free;
 WallEditor.Free;
 SectorEditor.Free;

  Do_FreeGeometryClip;
  Do_FreeObjectsClip;

  SC_MULTIS.Free;
  VX_MULTIS.Free;
  WL_MULTIS.Free;
  OB_MULTIS.Free;
  TheLevel.Free;
  LevelLoaded:=false;
  WinHelp(Handle, 'LAWMAKER.HLP', HELP_QUIT, 0);
end;

procedure TMapWindow.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if LEVELLoaded and MODIFIED then
   begin
    CASE Application.MessageBox('Level has been modified. Do you want to SAVE ?',
                                 'Exit Mapper',
                                 mb_YesNoCancel or mb_IconQuestion) OF
     idYes    : begin
                   Do_SaveProject;
                   CanClose := TRUE;
                end;
     idNo     : begin
                 CanClose := TRUE;
                end;
     idCancel : CanClose := FALSE;
    END;
   end
  else
   begin
    CanClose := TRUE;
   end;
end;

Procedure TMapWindow.DO_ResetEditor;
begin
 Do_Center_Map;
 SC_Multis.Clear;
 WL_Multis.Clear;
 OB_Multis.Clear;
 VX_Multis.Clear;
 
 SC_HILITE:=0;
 WL_HILITE:=0;
 VX_HILITE:=0;
 OB_HILITE:=0;
 DO_Switch_TO_SC_Mode;
 SUPERHILITE:=-1;
 Grid:=8;
 LevelLoaded:=true;
 OBSHADOW:=true;
 Shadow:=true;
 Scale:=1;
 GoToLayer(1);
 ProjectSave.Enabled:=true;
 EditMenu.Enabled:=true;
 MapMenu.Enabled:=true;
 ModeMenu.Enabled:=true;
 FindMenu.Enabled:=true;
 FindNext.Enabled:=true;
 EditMenu.Enabled:=true;
 ToolsTools.Enabled:=true;
 ProjectChecks.Enabled:=true;
 ViewEditors.Enabled:=true;
 SpeedButtonINF.Enabled:=true;
 SpeedButtonSC.Enabled:=true;
 SpeedButtonWL.Enabled:=true;
 SpeedButtonVX.Enabled:=true;
 SpeedButtonOB.Enabled:=true;
 SpeedButtonLevel.Enabled:=true;
 SpeedButtonQuery.Enabled:=true;
 SpeedButtonChecks.Enabled:=true;
 SpeedButtonTools.Enabled:=true;
 SpeedButtonGridEight.Enabled:=true;
 SpeedButtonGridOnOff.Enabled:=true;
 SpeedButtonGridIn.Enabled:=true;
 SpeedButtonGridOut.Enabled:=true;
 SpeedButtonZoomNone.Enabled:=true;
 SpeedButtonZoomIn.Enabled:=true;
 SpeedButtonZoomOut.Enabled:=true;
 SpeedButtonSave.Enabled:=true;
 SBCenterMap.Enabled:=true;
 ApplyFixUpMenu.Enabled:=true;
 MenuTest.Enabled:=true;
 PublishMenu.Enabled:=true;
 SpeedButtonTest.Enabled:=true;
 MULTISEL_MODE:='T';
 Caption:='LawMaker - '+LevelSrcFile;
end;

procedure TMapWindow.ImportLevel(Const FName:String);
begin
 TheLevel.ImportLEV(Fname);
 LayerAllObjects(False);
 LevelSrcFile:=Fname;
 NewLevel:=true;
 LevelFile:=BaseDir+ChangeFileExt(ExtractName(FName),'')+'\'+ChangeFileExt(ExtractName(FName),'.lvt');
 DO_ResetEditor;
end;

procedure TMapWindow.OpenLevel(Const FName:String);
begin
 TheLevel.Load(Fname);
 if IsInContainer(Fname) then
 begin
  NewLevel:=true;
  LevelSrcFile:=Fname;
  LevelFile:=BaseDir+ChangeFileExt(ExtractName(FName),'')+'\'+ExtractName(FName);
 end
 else
 begin
  LevelSrcFile:=Fname;
  LevelFile:=Fname;
  NewLevel:=false;
 end;
 AddRecent(Fname);
 DO_ResetEditor;
end;

procedure TMapWindow.SpeedButtonOpenClick(Sender: TObject);
begin
  if LEVELLoaded and MODIFIED then
 case MsgBox('Level has been modified. Do you want to SAVE ?',
             'Open Project', mb_YesNoCancel or mb_IconQuestion) of
  idYes: DO_SaveProject;
  idCancel: Exit;
 end;
 With GetFileOpen do
 begin
  FileName:='';
  Filter:=Filter_OLLevelFiles;
  if Execute then OpenLevel(FileName);
 end;
end;

procedure TMapWindow.DO_NewProject;
var TheObject:TOB; LName:String;
begin
    if LEVELLoaded and MODIFIED then
    CASE MsgBox('Level has been modified. Do you want to SAVE ?',
                                 'LawMaker - New Project',
                                 mb_YesNoCancel or mb_IconQuestion) OF
     idYes    : Do_SaveProject;
     idCancel : exit;
    END;
 LName:='Untitled';
 if not InputQuery('Create a level','Level name:',LName) then exit;

 TheLevel.Clear;
 TheLevel.SetDefaultShades;
 {Create square sector right in the middle}
 SetCurSC(CreatePolygonSector(TheLevel,0,0,Sqrt(2)*32,4,-1,-1));
 With TheLevel.Sectors[0] do
 begin
  Floor_Y:=0;
  Ceiling_Y:=8;
 end;

 TheObject:=TheLevel.NewObject;
 With TheObject do
 begin
  X:=0;
  Y:=0;
  Y:=0;
  Sector:=0;
  Name:='PLAYER';
  Flags2:=LEV_OBJ_FLAG2_OBJECT_NOVICE or LEV_OBJ_FLAG2_OBJECT_NORMAL or
          LEV_OBJ_FLAG2_OBJECT_ADVANCED or LEV_OBJ_FLAG2_OBJECT_EXPERT;
 end;
 TheLevel.Objects.Add(TheObject);
 LName:=ExtractName(Lname);
 LevelFile:=BaseDir+LName+'\'+LName+'.lvt';
 LevelSrcFile:=LName;
 Map.Invalidate;
 NewLevel:=true;
 LevelLoaded:=True;
 Modified:=false;
 DO_ResetEditor;
end;

procedure TMapWindow.SpeedButtonNewProjectClick(Sender: TObject);
begin
 DO_NewProject;
end;


procedure TMapWindow.FormActivate(Sender: TObject);
begin
  KeyPreview := TRUE;
  Application.OnHint := DisplayHint;
end;

procedure TMapWindow.SpeedButtonAboutClick(Sender: TObject);
begin
  Application.CreateForm(TAboutBox, AboutBox);
  AboutBox.ShowModal;
  AboutBox.Destroy;
end;

procedure TMapWindow.SpeedButtonExitClick(Sender: TObject);
begin
  Close;
end;

procedure TMapWindow.SpeedButtonZoomNoneClick(Sender: TObject);
begin
 DO_Zoom_None;
end;

procedure TMapWindow.SpeedButtonZoomInClick(Sender: TObject);
begin
 DO_Zoom_In;
end;

procedure TMapWindow.SpeedButtonZoomOutClick(Sender: TObject);
begin
  DO_Zoom_out;
end;

procedure TMapWindow.PanelLayerClick(Sender: TObject);
begin
 DO_Layer_OnOff;
end;

procedure TMapWindow.PanelGridClick(Sender: TObject);
begin
  DO_Grid_OnOff;
end;

procedure TMapWindow.SpeedButtonGridInClick(Sender: TObject);
begin
  DO_Grid_In;
end;

procedure TMapWindow.SpeedButtonGridOutClick(Sender: TObject);
begin
 DO_Grid_Out;
end;

procedure TMapWindow.SpeedButtonGridEightClick(Sender: TObject);
begin
 SetGrid(8);
end;

procedure TMapWindow.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var adjoins : Integer;
    ThePoint : TPoint;
    MapPoint : TPoint;
    px, pz   : Double;
    TheObject: TOB;
    m        : Integer;
begin
 if LEVELLoaded then
  begin
    if Shift = [] then
    Case Key of
      VK_TAB    : begin
                    CASE MAP_MODE of
                      MM_SC : SectorEditor.EditIt;
                      MM_WL : WallEditor.EditIt;
                      MM_VX : VertexEditor.EditIt;
                      MM_OB : ObjectEditor.EditIt;
                     END;
                   end;
      VK_SPACE   : begin
                     CASE MAP_MODE of
                      MM_SC : DO_MultiSel_SC(SC_HILITE);
                      MM_WL : DO_MultiSel_WL(SC_HILITE, WL_HILITE);
                      MM_VX : DO_MultiSel_VX(SC_HILITE, VX_HILITE);
                      MM_OB : DO_MultiSel_OB(OB_HILITE);
                     END;
                     CASE MAP_MODE of
                      MM_SC : DO_Fill_SectorEditor;
                      MM_WL : DO_FILL_WallEditor;
                      MM_VX : DO_Fill_VertexEditor;
                      MM_OB : begin
                               DO_Fill_ObjectEditor;
                               Map.Invalidate;
                              end;
                     END;
                   end;
      VK_BACK    : DO_Clear_MultiSel;
      VK_PRIOR   : DO_Layer_Up;
      VK_NEXT    : DO_Layer_Down;
      VK_LEFT    : DO_ScrollLRBy(-Trunc(1+25/scale));
      VK_UP      : DO_ScrollUDBy(Trunc(1+25/scale));
      VK_RIGHT   : DO_ScrollLRBy(Trunc(1+25/scale));
      VK_DOWN    : DO_ScrollUDBy(-Trunc(1+25/scale));
      $41 {VK_A} : CASE MAP_MODE of
                    MM_SC : ;
                    MM_WL : DO_MakeAdjoins;
                    MM_VX : ;
                    MM_OB : ;
                   END;
      $43 {VK_C} : DO_Center_On_Cursor;
      $44 {VK_D} : ToolsWindow.Display(tp_Deform);
      $45 {VK_E} : IF MAP_MODE = MM_WL THEN ShellExtrudeWall;
      $46 {VK_F} : CASE MAP_MODE of
                    MM_SC : DO_Find_SC_Adjoin;
                    MM_WL : DO_Find_WL_Adjoin(1);
                    MM_VX : {DO_Find_VX_AtSameCoords};
                    MM_OB : {DO_Find_PlayerStart};
                   END;
      $47 {VK_G} : DO_Grid_Out;
      $49 {VK_I} : SpeedButtonINFClick(NIL);
      $4A {VK_J} : Shell_JumpTo;
      $4B {VK_K} : DO_Polygon(p_sector);
                   {DEU compatibility}
      $4C {VK_L} : DO_Switch_To_WL_Mode;
      $4D {VK_M} : ;
      $4E {VK_N} : CASE MAP_MODE of
                    MM_SC : SetCurSC(SC_HILITE+1);
                    MM_WL : SetCurWL(SC_HILITE, WL_HILITE+1);
                    MM_VX : SetCurVX(SC_HILITE, VX_HILITE+1);
                    MM_OB : SetCurOB(OB_HILITE+1);
                   END;
      $4F {VK_O} : DO_Switch_To_OB_Mode;
      $50 {VK_P} : CASE MAP_MODE of
                    MM_SC : SetCurSC(SC_HILITE-1);
                    MM_WL : SetCurWL(SC_HILITE, WL_HILITE-1);
                    MM_VX : SetCurVX(SC_HILITE, VX_HILITE-1);
                    MM_OB : SetCurOB(OB_HILITE-1);
                   END;
      $51 {VK_Q} : SpeedButtonQueryClick(NIL);
      $52 {VK_R} : begin
                   end;
      $53 {VK_S} : DO_Switch_To_SC_Mode;
                   {DEU compatibility}
      $54 {VK_T} : DO_Switch_To_OB_Mode;
      $55 {VK_U} : {if MAP_MODE = MM_WL then SuperStitch(SC_HILITE, WL_HILITE, 0, 0)};
      $56 {VK_V} : DO_Switch_To_VX_Mode;
      $57 {VK_W} : DO_Switch_To_WL_Mode;
      $58 {VK_X} : DO_Center_On_CurrentObject;
      $59 {VK_Y} : {if MAP_MODE = MM_WL then SuperStitch(SC_HILITE, WL_HILITE, 0, 1)};
      $5A {VK_Z} : {DO_StoreUndo};
      VK_ADD     : DO_Zoom_In;
      VK_SUBTRACT: DO_Zoom_Out;
      VK_MULTIPLY: DO_Zoom_None;
      VK_DIVIDE  : DO_Center_Map;
      VK_DELETE  : CASE MAP_MODE of
                    MM_SC : ShellDeleteSC;
                    MM_WL : ShellDeleteWL(SC_HILITE, WL_HILITE);
                    MM_VX : ShellDeleteVX(SC_HILITE, VX_HILITE);
                    MM_OB : ShellDeleteOB;
                   END;
      VK_INSERT  : begin
                    {Compute cursor position. If grid is on, must paste on a grid point!}
                    GetCursorPos(ThePoint);
                    MapPoint := Map.ScreenToClient(ThePoint);
                    px := S2MX(MapPoint.X);
                    pz := S2MZ(MapPoint.Y);
                    GetNearestGridPoint(S2MX(MapPoint.X),S2MZ(MapPoint.Y), px, pz);
                    CASE MAP_MODE of
                     MM_SC : ShellInsertSC(px, pz);
                     MM_WL : ShellSplitWL(SC_HILITE, WL_HILITE);
                     MM_VX : ShellSplitVX(SC_HILITE, VX_HILITE);
                     MM_OB : ShellInsertOB(px, pz);
                    END;
                   end;
      { too annoying !
      VK_ESCAPE  : MapWindow.Close;
      }
      VK_F1      : HelpContents.Click;
      VK_F2      : SpeedButtonSaveClick(NIL);
      VK_F3      : SpeedButtonSaveClick(NIL);
      VK_F4      : begin
                     DO_Stitch(st_Horizontal,TRUE, TRUE, TRUE);
                     DO_Stitch(st_Vertical,TRUE, TRUE, TRUE);
                    end;
      VK_F5      : DO_Stitch(st_Horizontal,TRUE, FALSE, FALSE);
      VK_F6      : DO_Stitch(st_HorizontalInverse,TRUE, FALSE, FALSE);
      VK_F7      : DO_Stitch(st_Vertical,TRUE, FALSE, FALSE);
      VK_F8      : DO_Distribute(d_Floors+d_Ceilings);
      VK_F9      : SpeedButtonToolsClick(NIL);
      VK_F10     : Consistency.Check;
      VK_NUMPAD0 : DIFFAllClick(ODAll);
      VK_NUMPAD1 : DIFFAllClick(ODEasy);
      VK_NUMPAD2 : DIFFAllClick(ODMed);
      VK_NUMPAD3 : DIFFAllClick(ODHard);
      $31 {VK_1} : {DO_Goto_Marker(0)};
      $32 {VK_2} : {DO_Goto_Marker(1)};
      $33 {VK_3} : {DO_Goto_Marker(2)};
      $34 {VK_4} : {DO_Goto_Marker(3)};
      $35 {VK_5} : {DO_Goto_Marker(4)};
    end;

    if Shift = [ssShift] then
    Case Key of
      VK_INSERT  : DO_PasteAtCursor;
      VK_RETURN  : begin
                   end;
      $41 {VK_A} : CASE MAP_MODE of
                    MM_SC : ;
                    MM_WL : begin
                             {if MakeLayerAdjoin(SC_HILITE, WL_HILITE) then
                              adjoins := 1
                             else
                              adjoins := 0;
                             adjoins := adjoins + MultiMakeAdjoin;
                             DO_Fill_WallEditor;
                             PanelText.Caption := IntToStr(adjoins) + ' ADJOIN(S) MADE';}
                            end;
                    MM_VX : ;
                    MM_OB : ;
                   END;
      $43 {VK_C} : begin
                    DO_Center_On_Cursor;
                    DO_Zoom_In;
                    DO_Zoom_In;
                    DO_Zoom_In;
                    DO_Zoom_In;
                   end;
      $44 {VK_D} : ;
      $46 {VK_F} : FastSCROLL := not FastSCROLL;
      $47 {VK_G} : Do_Grid_In;
      $49 {VK_I} : ;
      $4C {VK_L} : CASE MAP_MODE of
                    MM_SC : ;
                    MM_WL : ;
                    MM_VX : ;
                    MM_OB : ForceLayerObjects;
                   END;
      $4B {VK_K} : DO_Polygon(p_gap);
      $4D {VK_M} : ;
      $4E {VK_N} : ;
      $50 {VK_P} : ;

{Shift+R complete renderer exists only in WDFUSE 32}
{$IFDEF WDF32}
      $52 {VK_R} : begin
                    if not ZRenderer.Visible then ZRenderer.InitRenderer;
                    GetCursorPos(ThePoint);
                    MapPoint := Map.ScreenToClient(ThePoint);
                    px := S2MX(MapPoint.X);
                    pz := S2MZ(MapPoint.Y);
                    GetNearestGridPoint(S2MX(MapPoint.X),S2MZ(MapPoint.Y), px, pz);
                    ZRenderer.SetCamera(px, pz, 6.5, -0.0001);
                    ZRenderer.CreateLists;
                    {ZRenderer.Invalidate;}
                    ZRenderer.Show;
                   end;
{$ENDIF}

      $53 {VK_S} : ScriptEdit.Show;
      $58 {VK_X} : begin
                    DO_Center_On_CurrentObject;
                    DO_Zoom_In;
                    DO_Zoom_In;
                    DO_Zoom_In;
                    DO_Zoom_In;
                   end;
      VK_F5      : DO_Stitch(st_Horizontal,TRUE, TRUE, TRUE);
      VK_F6      : DO_Stitch(st_HorizontalInverse,TRUE, TRUE, TRUE);
      VK_F7      : DO_Stitch(st_Vertical,TRUE, TRUE, TRUE);
      VK_F8      : DO_Distribute(D_Ambients);
    end;

    if Shift = [ssCtrl] then
    Case Key of
      VK_RETURN  : begin
                   end;
      VK_LEFT    : DO_ScrollLRBy(- Trunc(1+100/scale));
      VK_UP      : DO_ScrollUDBy(Trunc(1+100/scale));
      VK_RIGHT   : DO_ScrollLRBy(Trunc(1+100/scale));
      VK_DOWN    : DO_ScrollUDBy(- Trunc(1+100/scale));
      $31 {VK_1} : {DO_Set_Marker(0)};
      $32 {VK_2} : {DO_Set_Marker(1)};
      $33 {VK_3} : {DO_Set_Marker(2)};
      $34 {VK_4} : {DO_Set_Marker(3)};
      $35 {VK_5} : {DO_Set_Marker(4)};
      $41 {VK_A} : ;
      { $43VK_C,}VK_INSERT
                : CASE MAP_MODE OF
                    MM_SC : DO_CopyGeometry;
                    MM_OB : DO_CopyObjects;
                   END;
      $46 {VK_F} : DO_Find(f_first);
      $44 {VK_D} : FastDRAG := not FastDRAG;
      $47 {VK_G} : DO_Find(f_next);
      $49 {VK_I} : {ToolsWindow.BNRereadINFClick(NIL)};
      $4B {VK_K} : DO_Polygon(p_Subsector);
     (* $4B {VK_K} : IF MAP_MODE = MM_SC THEN DO_CloseSector(SC_HILITE); *)
      $4C {VK_L} : CASE MAP_MODE of
                    MM_SC : ;
                    MM_WL : ;
                    MM_VX : ;
                    MM_OB : begin
                             {case OBLAYERMODE of
                              0 : begin
                                   OBLAYERMODE := 1;
                                   PanelText.Caption := 'Moving Objects relayered to FLOOR';
                                  end;
                              1 : begin
                                   OBLAYERMODE := 2;
                                   PanelText.Caption := 'Moving Objects relayered to CEILING';
                                  end;
                              2 : begin
                                   OBLAYERMODE := 0;
                                   PanelText.Caption := 'Moving Objects Altitude NOT changed (if possible)';
                                  end;
                             end;}
                            end;
                   END;
      $4D {VK_M} : ;
      $4E {VK_N} : ;
      $4F {VK_O} : ProjectOpen.Click;
      $50 {VK_P} : begin
                    {GetCursorPos(ThePoint);
                    MapPoint := MapWindow.Map.ScreenToClient(ThePoint);
                    px := S2MX(MapPoint.X);
                    pz := S2MZ(MapPoint.Y);
                    GetNearestGridPoint(S2MX(MapPoint.X),S2MZ(MapPoint.Y), px, pz);
                    INFWindow2.EDElevCenterX.Text := Format('%5.2f', [px]);
                    INFWindow2.EDElevCenterZ.Text := Format('%5.2f', [pz]);}
                   end;
      $53 {VK_S} : ProjectSave.Click;
      $54 {VK_T} : ToolsWindow.Display(-1);
      (* $56 {VK_V} : DO_PasteAtCursor;*)
      VK_F5      : DO_Stitch(st_Horizontal,FALSE, FALSE, TRUE);
      VK_F6      : DO_Stitch(st_HorizontalInverse,FALSE, FALSE, TRUE);
      VK_F7      : DO_Stitch(st_Vertical,FALSE, FALSE, TRUE);
      VK_F8      : DO_Distribute(d_Ceilings);
    end;

    if Shift = [ssAlt] then
    Case Key of
      VK_RETURN  : begin
                   end;
      $41 {VK_A} : CASE MAP_MODE of
                    MM_SC : ;
                    MM_WL : DO_UnAdjoin;
                    MM_VX : ;
                    MM_OB : ;
                   END;
      $43 {VK_C} : SpeedButtonStatClick(NIL);
      $44 {VK_D} : ToolsWindow.Display(tp_Offset);
      $46 {VK_F} : if MAP_MODE=MM_WL then DO_Find_WL_Adjoin(2);
      $47 {VK_G} : DO_Grid_OnOff;
      $4B {VK_K} : ;
      $4D {VK_M} : ;
      $4E {VK_N} : ;
      $4F {VK_O} : DO_OBShadow_OnOff;
      $53 {VK_S} : DO_Layer_OnOff;
      $57 {VK_W} : ToolsWindow.Display(tp_water);
      $5A {VK_Z} : {DO_ApplyUndo};
      VK_F5      : DO_Stitch(st_Horizontal,FALSE, TRUE, FALSE);
      VK_F6      : DO_Stitch(st_HorizontalInverse,FALSE, TRUE, FALSE);
      VK_F7      : DO_Stitch(st_Vertical,FALSE, TRUE, FALSE);
      VK_F8      : DO_Distribute(d_Floors);
    end;
  end;
 Key:=0;
end;

procedure TMapWindow.SpeedButtonCenterMapClick(Sender: TObject);
begin
  DO_Center_Map;
end;

procedure TMapWindow.SpeedButtonStatClick(Sender: TObject);
begin
  if LevelLoaded then StatWindow.ShowInfo(TheLevel)
  else StatWindow.ShowInfo(Nil);
end;

procedure TMapWindow.PanelMultiClick(Sender: TObject);
begin
  if LEVELLOADED then DO_Clear_MultiSel;
end;

procedure TMapWindow.MapMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
    m         : Integer;
    TheObject : TOB;
begin
if Not MouseDownHappened then exit;
MouseDownHappened:=false;
 {
  RESUME MOUSE UP

  [rien] => Simple Select
  Shift  => Multiselection
  C+S    => Select Next Nearest VX [MM_VX only]
 }

if LEVELLoaded then
 BEGIN
  if Button = mbLeft then
   BEGIN
     IF IsFOCUSRECT then
      BEGIN
       Map.Canvas.DrawFocusRect(FOCUSRECT);
       IsFOCUSRECT := FALSE;
       DO_Select_In_Rect(FOCUSRECT);
       case MAP_MODE of
          MM_SC :   SectorEditor.LoadSector(SC_HILITE);
          MM_WL :   WallEditor.LoadWall(SC_HILITE,WL_HILITE);
          MM_VX :   VertexEditor.LoadVertex(SC_HILITE,VX_HILITE);
          MM_OB :   ObjectEditor.LoadObject(OB_HILITE);
       end;
      END
     ELSE
     IF IsRULERLINE then
      BEGIN
       {draw the line one last time to remove it and set
        the canvas out of XOR mode}
       Map.Canvas.MoveTo(ORIGIN.X, ORIGIN.Y);
       Map.Canvas.LineTo(DESTIN.X, DESTIN.Y);
       Map.Canvas.Pen.Mode    := pmCopy;
       PanelText.Caption := '';
       IsRULERLINE := FALSE;
      END
     ELSE
     IF IsDRAG then
      BEGIN
       {Gestion du DRAG}
       IsDRAG := FALSE;
       if FastDRAG then Map.Invalidate;
       case MAP_MODE of
          MM_SC :   DO_Fill_SectorEditor;
          MM_WL :   DO_Fill_WallEditor;
          MM_VX :   DO_Fill_VertexEditor;
          MM_OB :   begin
                     TheObject := TheLevel.Objects[OB_HILITE];
                     ForceLayerObjects;
                    end;
       end;
      END
     ELSE
      BEGIN
       if Shift = [] then
        case MAP_MODE of
          MM_SC : if GetNearestSC(TheLevel,Layer,S2MX(X), S2MZ(Y), SC_HILITE) then
                   begin
                    DO_Fill_SectorEditor;
                    Map.Invalidate;
                   end;
          MM_WL : if GetNearestWL(TheLevel,Layer,S2MX(X), S2MZ(Y), SC_HILITE, WL_HILITE) then
                   begin
                    DO_Fill_WallEditor;
                    Map.Invalidate;
                   end;
          MM_VX : if GetNearestVX(TheLevel,Layer,S2MX(X), S2MZ(Y), SC_HILITE, VX_HILITE) then
                   begin
                    DO_Fill_VertexEditor;
                    Map.Invalidate;
                   end;
          MM_OB : if GetNearestOB(TheLevel,Layer,S2MX(X), S2MZ(Y), OB_HILITE) then
                   begin
                    DO_Fill_ObjectEditor;
                    Map.Invalidate;
                   end;
        end;

       if Shift = [ssAlt] then
        case MAP_MODE of
          MM_SC : if GetNextNearestSC(TheLevel,Layer, S2MX(X), S2MZ(Y),SC_HILITE) then
                   begin
                    SetCurSC(SC_HILITE);
                   end;
          MM_WL : ;
          MM_VX : if GetNextNearestVX(TheLevel,Layer,S2MX(X), S2MZ(Y), SC_HILITE, VX_HILITE) then
                   begin
                    SetCurVX(SC_HILITE,VX_HILITE);
                   end;
          MM_OB : ;
        end;

       if Shift = [ssShift] then
        case MAP_MODE of
          MM_SC : if GetNearestSC(TheLevel,Layer,S2MX(X), S2MZ(Y), SC_HILITE) then
                   begin
                    DO_MultiSel_SC(SC_HILITE);
                    DO_Fill_SectorEditor;
                    Map.Invalidate;
                   end;
          MM_WL : if GetNearestWL(TheLevel,Layer,S2MX(X), S2MZ(Y), SC_HILITE, WL_HILITE) then
                   begin
                    DO_MultiSel_WL(SC_HILITE, WL_HILITE);
                    DO_Fill_WallEditor;
                    Map.Invalidate;
                   end;
          MM_VX : if GetNearestVX(TheLevel,Layer,S2MX(X), S2MZ(Y), SC_HILITE, VX_HILITE) then
                   begin
                    DO_MultiSel_VX(SC_HILITE, VX_HILITE);
                    DO_Fill_VertexEditor;
                    Map.Invalidate;
                   end;
          MM_OB : if GetNearestOB(TheLevel,Layer,S2MX(X), S2MZ(Y), OB_HILITE) then
                   begin
                    DO_MultiSel_OB(OB_HILITE);
                    DO_Fill_ObjectEditor;
                    Map.Invalidate;
                   end;
        end;
     END; {not dragging}
   END; {left button}
 END; {level loaded}

end;

procedure TMapWindow.MapMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ORIGIN.X  := X;
  ORIGIN.Y  := Y;
  FirstDRAG := TRUE;
  MouseDownHappened:=true;
end;

procedure TMapWindow.MapMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var rx, rz    : Double;
    dx, dz    : Double;
    vx, vz    : Double;
    a,b       : Double;
    TheVertex : TVertex;
    TheSector : TSector;
    TheWall   : TWall;
    TheObject : TOB;
    s,v       : Integer;
    TestRect  : TRect;
    gx,gy:integer;
begin
 {
  RESUME MOUSE MOVE

  Ctrl   => Drag (eventuellement avec Grid)
  C+S    => Drag on Nearest VX/OB
  Alt    => Create Rectangle for Multiselection
 }

  if LEVELLoaded then
    begin
      PanelX.Caption := Format('%5.2f', [S2MX(X)]);
      PanelZ.Caption := Format('%5.2f', [S2MZ(Y)]);
     { if not MouseDownHappened then exit;}
      if (Shift = [ssCtrl] + [ssLeft]) or (Shift = [ssCtrl] + [ssShift] + [ssLeft]) then
       begin
         IsDRAG := TRUE;
         case MAP_MODE of
          MM_SC : begin
                   TheSector := TheLevel.Sectors[SC_HILITE];
                   TheVertex := TheSector.Vertices[0];
                   rx        := TheVertex.X;
                   rz        := TheVertex.Z;
                  end;
          MM_WL : begin
                   TheSector := TheLevel.Sectors[SC_HILITE];
                   TheWall   := TheSector.Walls[WL_HILITE];
                   TheVertex := TheSector.Vertices[TheWall.V1];
                   rx        := TheVertex.X;
                   rz        := TheVertex.Z;
                  end;
          MM_VX : begin
                   TheSector := TheLevel.Sectors[SC_HILITE];
                   TheVertex := TheSector.Vertices[VX_HILITE];
                   rx        := TheVertex.X;
                   rz        := TheVertex.Z;
                  end;
          MM_OB : begin
                   TheObject := TheLevel.Objects[OB_HILITE];
                   rx := TheObject.X;
                   rz := TheObject.Z;
                  end;
         end;
         {offset (multi)selection}
         if Shift = [ssCtrl] + [ssShift] + [ssLeft] then
          {snap to nearest vertex/ob}
          begin
            CASE MAP_MODE OF
             MM_SC, MM_WL, MM_VX :
                    begin
                     if GetNearestVX(TheLevel,Layer,S2MX(X), S2MZ(Y), s, v) then
                     if {s <> SC_HILITE} TRUE then
                      begin
                       TheSector := TheLevel.Sectors[s];
                       TheVertex := TheSector.Vertices[v];
                       vx        := TheVertex.X;
                       vz        := TheVertex.Z;
                       if FastDRAG then
                        if FirstDRAG then
                         begin
                          FirstDrag := FALSE;
                         end
                        else
                         begin
                          DO_DrawMultiSel(TRUE);
                          DO_DrawSelection(TRUE);
                         end;
                       DO_Translate_SelMultiSel(vx-rx, vz-rz);
                       {prepare next displacement}
                       gx:=M2SX(vx)-M2SX(rx+S2MX(X)-S2MX(Origin.X));
                       gy:=M2SZ(vz)-M2SZ(rz+S2MZ(Y)-S2MZ(Origin.Y));
                       ORIGIN.X := X+gx;
                       ORIGIN.Y := Y+gy;
                       {ORIGIN.X := Trunc(M2SX(vx));
                       ORIGIN.Y := Trunc(M2SZ(vz));}
                       {update the window}
                       if FastDRAG then
                       begin
                         DO_DrawMultiSel(TRUE);
                         DO_DrawSelection(TRUE);
                        end
                       else
                        Map.Invalidate;
                      end;

                    end;
             MM_OB :
                     begin
                     if GetNearestOB(TheLevel,Layer,S2MX(X), S2MZ(Y), s) then
                     if s <> OB_HILITE then
                      begin
                       TheObject := TheLevel.Objects[s];
                       vx        := TheObject.X;
                       vz        := TheObject.Z;
                       if FastDRAG then
                        if FirstDRAG then
                         begin
                          FirstDrag := FALSE;
                         end
                        else
                         begin
                          DO_DrawMultiSel(TRUE);
                          DO_DrawSelection(TRUE);
                         end;
                       DO_Translate_SelMultiSel(vx-rx, vz-rz);
                       {prepare next displacement}
                       gx:=M2SX(vx)-M2SX(rx+S2MX(X)-S2MX(Origin.X));
                       gy:=M2SZ(vz)-M2SZ(rz+S2MZ(Y)-S2MZ(Origin.Y));
                       ORIGIN.X := X+gx;
                       ORIGIN.Y := Y+gy;

{                       ORIGIN.X := Trunc(M2SX(vx));
                       ORIGIN.Y := Trunc(M2SZ(vz));}
                       {update the window}
                       if FastDRAG then
                        begin
                         DO_DrawMultiSel(TRUE);
                         DO_DrawSelection(TRUE);
                        end
                       else
                        Map.Invalidate;
                      end;
                    end;
            END;
          end
         else
         {no vertex snapping}
         if not GridON then
          begin
           if FastDRAG then
            if FirstDRAG then
             begin
              FirstDrag := FALSE;
             end
            else
             begin
              DO_DrawMultiSel(TRUE);
              DO_DrawSelection(TRUE);
             end;
            DO_Translate_SelMultiSel(S2MX(X)-S2MX(ORIGIN.X), S2MZ(Y)-S2MZ(ORIGIN.Y));
           {prepare next displacement}
           ORIGIN.X := X;
           ORIGIN.Y := Y;
           if FastDRAG then
            begin
             DO_DrawMultiSel(TRUE);
             DO_DrawSelection(TRUE);
            end
           else
            Map.Invalidate;
          end
         else
          begin
           if FastDRAG then
            if FirstDRAG then
             begin
              FirstDrag := FALSE;
             end
            else
             begin
              DO_DrawMultiSel(TRUE);
              DO_DrawSelection(TRUE);
             end;
           GetNearestGridPoint(rx+S2MX(X)-S2MX(Origin.X), rz+S2MZ(Y)-S2MZ(Origin.Y),
                               dx, dz);
           DO_Translate_SelMultiSel(dx-rx, dz-rz);
{           DO_Translate_SelMultiSel(S2MX(X)-S2MX(ORIGIN.X), S2MZ(Y)-S2MZ(ORIGIN.Y));}
           {prepare next displacement}
           gx:=M2SX(dx)-M2SX(rx+S2MX(X)-S2MX(Origin.X));
           gy:=M2SZ(dz)-M2SZ(rz+S2MZ(Y)-S2MZ(Origin.Y));
           ORIGIN.X := X+gx; {Trunc(M2SX(dx));}
           ORIGIN.Y := Y+gy; {Trunc(M2SZ(dz));}
           {update the window}
           if FastDRAG then
            begin
             DO_DrawMultiSel(TRUE);
             DO_DrawSelection(TRUE);
            end
           else
            Map.Invalidate;
           {
           if ((dx - rx) <> 0) or ((dz - rz) <> 0) then
             Map.Invalidate;
           }
          end;
       end;

      if Shift = [ssAlt] + [ssLeft] then
       begin
         {draw a FocusRect for rectangle selection
          the 2 following lines are mandatory for Win32
          Win16 just uses black and white, whatever the brush :-)}
         Map.Canvas.Brush.Color := clWhite;
         Map.Canvas.Brush.Style := bsSolid;
         if IsFOCUSRECT then Map.Canvas.DrawFocusRect(FOCUSRECT);
         DESTIN.X              := X;
         DESTIN.Y              := Y;
         if (ORIGIN.X < DESTIN.X) then
          if (ORIGIN.Y < DESTIN.Y) then
           SetRect(FOCUSRECT, ORIGIN.X, ORIGIN.Y, DESTIN.X, DESTIN.Y)
          else
           SetRect(FOCUSRECT, ORIGIN.X, DESTIN.Y, DESTIN.X, ORIGIN.Y)
         else
          if (ORIGIN.Y < DESTIN.Y) then
           SetRect(FOCUSRECT, DESTIN.X, ORIGIN.Y, ORIGIN.X, DESTIN.Y)
          else
           SetRect(FOCUSRECT, DESTIN.X, DESTIN.Y, ORIGIN.X, ORIGIN.Y);
         Map.Canvas.DrawFocusRect(FOCUSRECT);
         IsFOCUSRECT           := TRUE;
       end;

      if Shift = [ssCtrl] + [ssAlt] + [ssLeft] then
       begin
         {draw a ruler}
         Map.Canvas.Brush.Color := clWhite;
         Map.Canvas.Brush.Style := bsSolid;
         Map.Canvas.Pen.Color   := clWhite;
         Map.Canvas.Pen.Mode    := pmXOR;
         if IsRULERLINE then
          begin
           Map.Canvas.MoveTo(ORIGIN.X, ORIGIN.Y);
           Map.Canvas.LineTo(DESTIN.X, DESTIN.Y);
          end;
         DESTIN.X              := X;
         DESTIN.Y              := Y;
         Map.Canvas.MoveTo(ORIGIN.X, ORIGIN.Y);
         Map.Canvas.LineTo(DESTIN.X, DESTIN.Y);
         IsRULERLINE           := TRUE;
         {now just write the distance in the status line}
         dx := S2MX(ORIGIN.X);
         dz := S2MZ(ORIGIN.Y);
         rx := S2MX(DESTIN.X);
         rz := S2MZ(DESTIN.Y);
         vx := sqrt((dx-rx)*(dx-rx)+(dz-rz)*(dz-rz));
         if (dx-rx = 0) then
          if dz < rz then
           a := 90
          else
           a := 270
         else
          a := 180 * ArcTan((dz-rz)/(dx-rx)) / PI;

         if (dx > rx) then a := 180 + a;
         if (dz > rz) and (dx < rx) then a := 360 + a;

         if (a >= 0) and (a <= 90) then
          b := 90-a
         else
          b := 450 - a;

         PanelText.Caption := Format('Distance = %6.3f   Angle = %5.2f   DFAngle = %5.2f', [vx, a, b]);
       end;
    end;
end;

procedure TMapWindow.MSToggleClick(Sender: TObject);
begin
 MSToggle.Checked := FALSE;
 MSAdd.Checked := FALSE;
 MSSubtract.Checked := FALSE;

 if Sender = MSToggle then
  begin
   MULTISEL_MODE := 'T';
   PanelMultiMode.Caption := 'T';
   MSToggle.Checked := TRUE;
  end;
 if Sender = MSAdd then
  begin
   MULTISEL_MODE := '+';
   PanelMultiMode.Caption := '+';
   MSAdd.Checked := TRUE;
  end;
 if Sender = MSSubtract then
  begin
   MULTISEL_MODE := '-';
   PanelMultiMode.Caption := '-';
   MSSubtract.Checked := TRUE;
  end;
end;

procedure TMapWindow.PanelMultiModeClick(Sender: TObject);
begin
 MSToggle.Checked := FALSE;
 MSAdd.Checked := FALSE;
 MSSubtract.Checked := FALSE;

 CASE MULTISEL_MODE[1] of
  'T' : begin
         MULTISEL_MODE := '+';
         PanelMultiMode.Caption := '+';
         MSAdd.Checked := TRUE;
        end;
  '+' : begin
         MULTISEL_MODE := '-';
         PanelMultiMode.Caption := '-';
         MSSubtract.Checked := TRUE;
        end;
  '-' : begin
         MULTISEL_MODE := 'T';
         PanelMultiMode.Caption := 'T';
         MSToggle.Checked := TRUE;
        end;
 END;
end;

procedure TMapWindow.SpeedButtonOptionsClick(Sender: TObject);
begin
 Options.SetOptions(nil);
end;

procedure TMapWindow.SpeedButtonSaveClick(Sender: TObject);
begin
 DO_SaveProject;
end;



procedure TMapWindow.SpeedButtonTestClick(Sender: TObject);
var pi:TProcessInformation;
    si:TStartupInfo;
begin
 if Modified or NewLevel then begin ShowMessage('Save the level first'); exit; end;
 if DO_Publish(GameDir+ChangeFileExt(ExtractFileName(LevelFile),'.lab')) then
 begin
 With si do
 begin
   cb:=Sizeof(si);
   lpReserved:=nil;
   lpDesktop:=nil;
   lpTitle:=nil;
   dwFlags:=0;
  end;

  CreateProcess(
   PChar(GameDir+'olwin.exe'),
   PChar('/LEVEL '+ExtractName(LevelFile)),
   nil,nil,false,0,nil,Pchar(GameDir),si,pi);
   
 end
 else ShowMessage('Publishing failed - check free disk space');
end;



procedure TMapWindow.SpeedButtonToolsClick(Sender: TObject);
begin
 ToolsWindow.Display(-1);
end;

procedure TMapWindow.MapPopupPopup(Sender: TObject);
begin
 if LEVELLoaded then
  begin
   PopupNew.Visible     := FALSE;
   PopupOpen.Visible    := FALSE;
   PopupDelete.Visible  := TRUE;
   PopupS1.Visible      := TRUE;
   PopupS2.Visible      := TRUE;
   if MAP_MODE = MM_WL then
    begin
     PopupCopy.Visible     := FALSE;
     PopupSplit.Visible    := TRUE;
    { if WallEditor.WLEd.Cells[1,0] = '-1' then
      begin
       PopupExtrude.Visible  := TRUE;
       PopupAdjoin.Visible   := TRUE;
       PopupUnAdjoin.Visible := FALSE;
      end
     else
      begin
       PopupExtrude.Visible  := FALSE;
       PopupAdjoin.Visible   := FALSE;
       PopupUnAdjoin.Visible := TRUE;
      end;}
    end
   else
    begin
     PopupCopy.Visible     := TRUE;
     PopupSplit.Visible    := FALSE;
     PopupExtrude.Visible  := FALSE;
     PopupAdjoin.Visible   := FALSE;
     PopupUnAdjoin.Visible := FALSE;
    end
  end
 else
  begin
     PopupNew.Visible      := TRUE;
     PopupOpen.Visible     := TRUE;
     PopupCopy.Visible     := FALSE;
     PopupSplit.Visible    := FALSE;
     PopupExtrude.Visible  := FALSE;
     PopupAdjoin.Visible   := FALSE;
     PopupUnAdjoin.Visible := FALSE;
     PopupDelete.Visible   := FALSE;
     PopupS1.Visible       := FALSE;
     PopupS2.Visible       := FALSE;
  end;
end;

procedure TMapWindow.PopupNewClick(Sender: TObject);
begin
  if Sender = PopupCopy then
  begin
   CASE MAP_MODE of
    MM_SC : ShellInsertSC(GetCenterX,GetCenterZ);
    MM_WL : ;
    MM_VX : ShellSplitVX(SC_HILITE,VX_HILITE);
    MM_OB : ShellInsertOB(GetCenterX,GetCenterZ);
   END;
  end;

 if Sender = PopupSplit then
  begin
   ShellSplitWL(SC_HILITE, WL_HILITE);
  end;

 if Sender = PopupExtrude then
  begin
   ShellExtrudeWall;
  end;

 if Sender = PopupAdjoin then
  begin
   DO_MakeAdjoins;
  end;

 if Sender = PopupUnAdjoin then
  begin
   DO_UnAdjoin;
  end;

 if Sender = PopupDelete then
  begin
   CASE MAP_MODE of
    MM_SC : ShellDeleteSC;
    MM_WL : ShellDeleteWL(SC_HILITE, WL_HILITE);
    MM_VX : ShellDeleteVX(SC_HILITE, VX_HILITE);
    MM_OB : ShellDeleteOB;
   END;
  end;

end;

procedure TMapWindow.DIFFAllClick(Sender: TObject);
begin
DIFFAll.Checked  := FALSE;
DIFFEasy.Checked := FALSE;
DIFFMed.Checked  := FALSE;
DIFFHard.Checked := FALSE;

ODAll.Checked  := FALSE;
ODEasy.Checked := FALSE;
ODMed.Checked  := FALSE;
ODHard.Checked := FALSE;

(*if (Sender=DIFFAll) or (Sender=ODAll)  then
 begin
  OBDIFF := 0;
  PanelOBLayer.Caption := 'All';
  Panel1OBLayer.Caption := 'All';{added nov12/DL }
  DIFFAll.Checked  := TRUE;
  ODAll.Checked  := TRUE;
 end;
if (Sender=DIFFEasy) or (Sender=ODEasy) then
 begin
  OBDIFF := 1;
  PanelOBLayer.Caption := 'Easy';
  Panel1OBLayer.Caption := 'Easy';{added nov12/DL}
  DIFFEasy.Checked := TRUE;
  ODEasy.Checked := TRUE;
 end;
if (Sender=DIFFMed) or (Sender=ODMed) then
 begin
  OBDIFF := 2;
  PanelOBLayer.Caption := 'Med';
  Panel1OBLayer.Caption := 'Med'; {added nov12/DL }
  DIFFMed.Checked  := TRUE;
  ODMed.Checked  := TRUE;
 end;
if (Sender=DIFFHard) or (Sender=ODHard) then
 begin
  OBDIFF := 3;
  PanelOBLayer.Caption := 'Hard';
  Panel1OBLayer.Caption := 'Hard';  {//added nov12/DL}
  DIFFHard.Checked := TRUE;
  ODHard.Checked  := TRUE;
  end;
 Map.Invalidate;*)
end;

procedure TMapWindow.NormalMapClick(Sender: TObject);
begin
 NormalMap.Checked := FALSE;
 LightsMap.Checked := FALSE;
 DamageMap.Checked := FALSE;
 SecAltitudesMap.Checked := FALSE;
 SkiesPitsMap.Checked := FALSE;

 MMNormal.Checked := FALSE;
 MMLight.Checked := FALSE;
 MMDamage.Checked := FALSE;
 MM2ndAltitudes.Checked := FALSE;
 MMSkiesPits.Checked := FALSE;

{ if (Sender=NormalMap)       or (Sender=MMNormal) then
  DO_SetMAP_TYPENormal;
 if (Sender=LightsMap)       or (Sender=MMLight) then
  DO_SetMAP_TYPELight;
 if (Sender=DamageMap)       or (Sender=MMDamage) then
  DO_SetMAP_TYPEDamage;
 if (Sender=SecAltitudesMap) or (Sender=MM2ndAltitudes) then
  DO_SetMAP_TYPE2ndAltitude;
 if (Sender=SkiesPitsMap)    or (Sender=MMSkiesPits) then
  DO_SetMAP_TYPESkyPit;}
end;

procedure TMapWindow.PanelOBLayerClick(Sender: TObject);
begin
 DO_OBShadow_OnOff;
end;




procedure HandleCommandLine;
begin
end;

function MaySave      : Boolean;
begin
 Result:=true;
end;

procedure TMapWindow.SpeedButtonChecksClick(Sender: TObject);
begin
 Consistency.Check;
end;

procedure TMapWindow.SpeedButtonLevelClick(Sender: TObject);
begin
 LHEditor.MapWindow:=self;
 if LHEditor.EditHeader(TheLevel) then Modified:=true;
end;

procedure TMapWindow.PanelMapTypeClick(Sender: TObject);
begin
 NormalMap.Checked := FALSE;
 LightsMap.Checked := FALSE;
 DamageMap.Checked := FALSE;
 SecAltitudesMap.Checked := FALSE;
 SkiesPitsMap.Checked := FALSE;

 MMNormal.Checked := FALSE;
 MMLight.Checked := FALSE;
 MMDamage.Checked := FALSE;
 MM2ndAltitudes.Checked := FALSE;
 MMSkiesPits.Checked := FALSE;

 case MAP_TYPE of
  MT_NO : {DO_SetMAP_TYPELight;};
  MT_LI : {DO_SetMAP_TYPEDamage;};
  MT_DM : {DO_SetMAP_TYPE2ndAltitude;};
  MT_2A : {DO_SetMAP_TYPESkyPit;};
  MT_SP : {DO_SetMAP_TYPENormal;} ;
 end;
end;

procedure TMapWindow.SpeedButtonQueryClick(Sender: TObject);
begin
 DO_Find(f_First);
end;

procedure TMapWindow.PanelMapBOTTOMResize(Sender: TObject);
begin
 HScrollBar.Width := PanelMapBOTTOM.Width
                   - PanelX.Width
                   - PanelZ.Width
                   - PanelZoom.Width
                   - PanelGrid.Width
                   - SBCenterMap.Width;
 SBCenterMap.Left := PanelMapBOTTOM.Width - SBCenterMap.Width;
end;

procedure TMapWindow.PanelMapRIGHTResize(Sender: TObject);
begin
 VScrollBar.Height := PanelMapRIGHT.Height
                     - PanelMapBOTTOM.Height + 18;
                    {- LScrollbar.Height
                    + PanelLayer.Height; { changed from - to + to make scroll bar longer until Panels are  removed}
 PanelLayer.Top    := VScrollBar.Height;
 LScrollBar.Top    := PanelMapRIGHT.Height - LScrollbar.Height;
end;

procedure TMapWindow.TBMainClick(Sender: TObject);
begin
 if TBMain.Checked then
  begin
   ToolbarMain.Visible := FALSE;
   TBMain.Checked      := FALSE;
  end
 else
  begin
   ToolbarMain.Visible := TRUE;
   TBMain.Checked      := TRUE;
  end;
end;

procedure TMapWindow.TBToolsClick(Sender: TObject);
begin
 if TBTools.Checked then
  begin
   ToolbarTools.Visible := FALSE;
   TBTools.Checked      := FALSE;
  end
 else
  begin
   ToolbarTools.Visible := TRUE;
   TBTools.Checked      := TRUE;
  end;
end;

procedure TMapWindow.HScrollBarScroll(Sender: TObject;
  ScrollCode: TScrollCode; var ScrollPos: Integer);
begin
 if ScrollCode = scEndScroll then exit;
 if (ScrollCode=scLineUp) and (XOffset<=HScrollBar.Min) then
 begin
  DO_ScrollLRBy(-Trunc(1+25/scale));
 end else
 if (ScrollCode=scLineDown) and (XOffset>=HScrollBar.Max) then
 begin
  DO_ScrollLRBy(Trunc(1+25/scale));
 end else XOffset := ScrollPos;
 Map.Invalidate;
end;

procedure TMapWindow.VScrollBarScroll(Sender: TObject;
  ScrollCode: TScrollCode; var ScrollPos: Integer);
begin
 if ScrollCode = scEndScroll then exit;

 if (ScrollCode=scLineUp) and (-ZOffset<=VScrollBar.Min) then
 begin
  DO_ScrollUDBy(Trunc(1+25/scale));
 end else
 if (ScrollCode=scLineDown) and (-ZOffset>=VScrollBar.Max) then
 begin
  DO_ScrollUDBy(-Trunc(1+25/scale));
 end
 else ZOffset := -ScrollPos;
 Map.Invalidate;
end;

procedure TMapWindow.LScrollBarScroll(Sender: TObject;
  ScrollCode: TScrollCode; var ScrollPos: Integer);
begin
 if ScrollCode = scLineUp   then DO_Layer_Up;
 if ScrollCode = scLineDown then DO_Layer_Down;
end;

function TMapWindow.SetXOffset(XOff : Integer) : Boolean;
begin
 if (XOff < -32000) or (XOff > 32000) then
   begin
    ShowMessage('Scroll Limit Reached !');
    Result  := FALSE;
    exit;
   end;

  if XOff < HScrollBar.Min then
     HScrollBar.Min := XOff;

  if XOff > HScrollBar.Max then
   HScrollBar.Max := XOff;

  HScrollBar.Position := XOff;

  XOffset := XOff;
  Result  := TRUE;
end;

function TMapWindow.SetZOffset(ZOff : Integer) : Boolean;
begin
 if (ZOff > 32000) or (ZOff < -32000) then
   begin
    ShowMessage('Scroll Limit Reached !');
    Result  := FALSE;
    exit;
   end;

  if -ZOffset < VScrollBar.Min then
   VScrollBar.Min := -ZOff;

  if -ZOffset > VScrollBar.Max then
    VScrollBar.Max := -ZOff;

   VScrollBar.Position := -ZOff;

  ZOffset := ZOff;
  Result  := TRUE;
end;

procedure TMapWindow.SM1Click(Sender: TObject);
begin
{ if (Sender = SM1) then DO_Set_Marker(0);
 if (Sender = SM2) then DO_Set_Marker(1);
 if (Sender = SM3) then DO_Set_Marker(2);
 if (Sender = SM4) then DO_Set_Marker(3);
 if (Sender = SM5) then DO_Set_Marker(4);

 if (Sender = GM1) then DO_Goto_Marker(0);
 if (Sender = GM2) then DO_Goto_Marker(1);
 if (Sender = GM3) then DO_Goto_Marker(2);
 if (Sender = GM4) then DO_Goto_Marker(3);
 if (Sender = GM5) then DO_Goto_Marker(4);}
end;

procedure TMapWindow.HelpTutorialClick(Sender: TObject);
var tmp : array[0..127] of char;
    pas : string;
begin
{ pas := 'winhelp ' + WDFUSEDir + '\wdftutor.hlp';
 strPcopy(tmp, pas);
 WinExec(tmp, SW_SHOW);}
end;

procedure TMapWindow.HelpDFSpecsClick(Sender: TObject);
var tmp : array[0..127] of char;
    pas : string;
begin
{ pas := 'winhelp ' + WDFUSEDir + '\df_specs.hlp';
 strPcopy(tmp, pas);
 WinExec(tmp, SW_SHOW);}
end;

procedure TMapWindow.MapDblClick(Sender: TObject);
var TheSector : TSector;
    tmp       : array[0..127] of char;
begin
{ IF LEVELLoaded THEN
  BEGIN
   if UpperCase(INFEditor) <> '' then
   begin
    StrPCopy(tmp, INFEditor + ' ' + LEVELPath + '\' + LEVELName + '.INF');
    WinExec(tmp, SW_SHOW);
   end
  else
   begin
    if (MAP_MODE = MM_VX) or (MAP_MODE = MM_OB) then exit;
    TheSector := TSector(MAP_SEC.Objects[SC_HILITE]);
    if TheSector.Name = '' then
     begin
      Application.MessageBox('You must name the sector first !', 'INF Editor',
                                mb_Ok or mb_IconExclamation);
      exit;
     end;
    case MAP_MODE of
     MM_SC : begin
              INFSector := SC_HILITE;
              INFWall   := -1;
              INFRemote := TRUE;
             end;
     MM_WL : begin
              INFSector := SC_HILITE;
              INFWall   := WL_HILITE;
              INFRemote := TRUE;
             end;
    end;
    INFWindow2.Show;
   end;
  END;}
end;

procedure TMapWindow.ProjectCloseClick(Sender: TObject);
begin
 if LEVELLoaded and MODIFIED then
    CASE Application.MessageBox('Level has been modified. Do you want to SAVE ?',
                                 'Mapper - Close Project',
                                 mb_YesNoCancel or mb_IconQuestion) OF
     idYes    : Do_SaveProject;
     idNo     : ;
     idCancel : ;
    END;
end;

procedure TMapWindow.EditCopyClick(Sender: TObject);
begin
 CASE MAP_MODE OF
  MM_SC : DO_CopyGeometry;
  MM_OB : DO_CopyObjects;
 END;
end;

procedure TMapWindow.EditPasteClick(Sender: TObject);
begin
 CASE MAP_MODE OF
  MM_SC : DO_PasteGeometry(GetCenterX, GetCenterZ);
  MM_OB : DO_PasteObjects(GetCenterX, GetCenterZ);
 END;
end;

procedure TMapWindow.N91Click(Sender: TObject);
begin
 TMenuItem(Sender).Checked := not TMenuItem(Sender).Checked;

 SHADOW_LAYERS[-9] := N91.Checked;
 SHADOW_LAYERS[-8] := N81.Checked;
 SHADOW_LAYERS[-7] := N71.Checked;
 SHADOW_LAYERS[-6] := N61.Checked;
 SHADOW_LAYERS[-5] := N51.Checked;
 SHADOW_LAYERS[-4] := N41.Checked;
 SHADOW_LAYERS[-3] := N31.Checked;
 SHADOW_LAYERS[-2] := N21.Checked;
 SHADOW_LAYERS[-1] := N19.Checked;
 SHADOW_LAYERS[-0] := N01.Checked;
 SHADOW_LAYERS[1]  := N110.Checked;
 SHADOW_LAYERS[2]  := N22.Checked;
 SHADOW_LAYERS[3]  := N32.Checked;
 SHADOW_LAYERS[4]  := N42.Checked;
 SHADOW_LAYERS[5]  := N52.Checked;
 SHADOW_LAYERS[6]  := N62.Checked;
 SHADOW_LAYERS[7]  := N72.Checked;
 SHADOW_LAYERS[8]  := N82.Checked;
 SHADOW_LAYERS[9]  := N92.Checked;
 Map.Invalidate;
end;



procedure TMapWindow.SpeedButtonSCClick(Sender: TObject);
begin
  DO_Switch_To_SC_Mode;
end;

procedure TMapWindow.SpeedButtonWLClick(Sender: TObject);
begin
   DO_Switch_To_WL_Mode;
end;

procedure TMapWindow.SpeedButtonGobFMClick(Sender: TObject);
begin
 ConMan.Show;
end;

procedure TMapWindow.SpeedButtonVXClick(Sender: TObject);
begin
    DO_Switch_To_VX_Mode;
end;

procedure TMapWindow.SpeedButtonOBClick(Sender: TObject);
begin
   DO_Switch_To_OB_Mode;
end;

procedure TMapWindow.SpeedButtonLfdFMClick(Sender: TObject);
begin
 {Application.CreateForm(TLFDWindow, LFDWindow);
 LFDWindow.ShowModal;
 LFDWindow.Destroy;
 Application.OnHint := DisplayHint;}
end;

procedure TMapWindow.SpeedButtonTKTClick(Sender: TObject);
begin
{ Application.CreateForm(TTKTWindow, TKTWindow);
 TKTWindow.ShowModal;
 TKTWindow.Destroy;
 Application.OnHint := DisplayHint;}
end;

procedure TMapWindow.SpeedButtonHelpClick(Sender: TObject);
begin
  Application.HelpCommand(HELP_CONTENTS, 0);
end;

procedure TMapWindow.SBSaveMapBMPClick(Sender: TObject);
   var SaveBMP : TBitmap;
begin
 with MapWindow.SaveMapDialog do
  if Execute then
   begin
    Map.Refresh;
    SaveBMP := TBitmap.Create;
    SaveBMP.Width  := Map.Width;
    SaveBMP.Height := Map.Height;
    BitBlt(SaveBMP.Canvas.Handle,        0, 0, Map.Width , Map.Height,
           Map.Canvas.Handle,  0, 0,
           SRCCOPY);
    SaveBMP.SaveToFile(FileName);
    SaveBMP.Free;
   end;
end;

procedure TMapWindow.SpeedButtonINFClick(Sender: TObject);
var n:Integer;f:TextFile;
    Inf:String;
begin
 if NewLevel then exit;
 Inf:=ChangeFileExt(LevelFile,'.inf');
 ScriptEdit.Show;
 if not FileExists(Inf) then ScriptEdit.NewScript(Inf,sc_inf)
 else ScriptEdit.OpenScript(Inf);
end;

procedure TMapWindow.SpeedButtonMSGClick(Sender: TObject);
begin
 {  DO_Edit_Short_Text_File(LEVELPath + '\TEXT.MSG');}
end;

procedure TMapWindow.SpeedButtonTXTClick(Sender: TObject);
begin
{ DO_Edit_Short_Text_File(ChangeFileExt(PROJECTFile, '.TXT'));}
end;



procedure TMapWindow.SpeedButtonGridOnOffClick(Sender: TObject); {//added by DL NOv/96}
begin
  DO_Grid_OnOff;
end;



procedure TMapWindow.PanelMapLayerClick(Sender: TObject); {new layer control DL nov/96}
begin
 DO_Layer_OnOff;
end;

procedure TMapWindow.SpeedButtonMapKeyClick(Sender: TObject);
begin
{  AllKeys.show}
end;


procedure TMapWindow.SpeedButton1Click(Sender: TObject);
begin
{    Application.CreateForm(TConv3do, Conv3do);
    Conv3do.ShowModal;
    Conv3do.Destroy;}
end;

function TMapWindow.GetNearestGridPoint(X, Z : double; VAR GX, GZ : double) : Boolean;
var tx, tz : double;
begin
 if GridON then
  begin
   {add half a grid cell}
   tx := X + Grid / 2;
   tz := Z + Grid / 2;

   {find bottom left grid point for this point}
   GX := Grid * Trunc(tx / Grid);
   GZ := Grid * Trunc(tz / Grid);

   {but the method for finding it is slightly different in negative areas!}
   if X < -Grid div 2 then GX := GX - Grid;
   if Z < -Grid div 2 then GZ := GZ - Grid;

   GetNearestGridPoint := TRUE;
  end
 else
  GetNearestGridPoint := FALSE;
end;

Procedure TMapWindow.GoToLayer(NewLayer:Integer);
begin
 if NewLayer>TheLevel.MaxLayer then Layer:=TheLevel.Maxlayer
 else if NewLayer<TheLevel.MinLayer then Layer:=TheLevel.MinLayer
 else Layer:=NewLayer;
 PanelLayer.Caption := IntToStr(LAYER);
 PanelMapLayer.Caption := IntToStr(LAYER);{// added by Dl 11/nov/96  }
 LScrollBar.Position := LAYER;
 Map.Invalidate;
end;

procedure TMapWindow.DO_Layer_Up;
begin
 GoToLayer(Layer+1);
end;

procedure TMapWindow.DO_Layer_Down;
begin
 GoToLayer(Layer-1);
end;

Procedure TMapWindow.Do_Fill_SectorEditor;
begin
 SectorEditor.LoadSector(SC_HILITE);
end;

Procedure TMapWindow.Do_Fill_WallEditor;
begin
 WallEditor.LoadWall(SC_HILITE,WL_HILITE);
end;

Procedure TMapWindow.Do_Fill_VertexEditor;
begin
 VertexEditor.LoadVertex(SC_HILITE,VX_HILITE);
end;

Procedure TMapWindow.Do_Fill_ObjectEditor;
begin
 ObjectEditor.LoadObject(OB_HILITE);
end;

Procedure TMapWindow.DO_Switch_To_SC_Mode;
begin {DO_Switch_to_SC_Mode}
 AdjustSelection;
{Convert multiselection}
 SynchronizeMultis(map_mode);

 Map_mode:=MM_SC;
 SectorEditor.Visible:=true;
 SetFocus;
 WallEditor.Visible:=false;
 VertexEditor.Visible:=false;
 ObjectEditor.Visible:=false;

 SpeedButtonSC.Down:=True;
 SpeedButtonWL.Down:=False;
 SpeedButtonVX.Down:=False;
 SpeedButtonOB.Down:=False;

 DO_Fill_SectorEditor;
 Map.Refresh;
end;

Procedure TMapWindow.DO_Switch_To_WL_Mode;

begin {DO_SWITCH_TO_WL_MODE}
 AdjustSelection;
{Convert multiselection}
 SynchronizeMultis(map_mode);

 Map_mode:=MM_WL;
 SectorEditor.Visible:=false;
 WallEditor.Visible:=true;
 SetFocus;
 VertexEditor.Visible:=false;
 ObjectEditor.Visible:=false;

 SpeedButtonSC.Down:=False;
 SpeedButtonWL.Down:=True;
 SpeedButtonVX.Down:=False;
 SpeedButtonOB.Down:=False;


 WL_HILITE:=0;
 DO_Fill_WallEditor;
 Map.Refresh;
end;

Procedure TMapWindow.DO_Switch_To_VX_Mode;
begin {Do_Switch_To_WL_Mode}

 AdjustSelection;
{Convert multiselection}
 SynchronizeMultis(map_mode);

 Map_mode:=MM_VX;
 SectorEditor.Visible:=false;
 WallEditor.Visible:=false;
 VertexEditor.Visible:=true;
 SetFocus;
 ObjectEditor.Visible:=false;

 SpeedButtonSC.Down:=False;
 SpeedButtonWL.Down:=False;
 SpeedButtonVX.Down:=True;
 SpeedButtonOB.Down:=False;


 DO_Fill_VertexEditor;
 Map.Refresh;
end;

Procedure TMapWindow.DO_Switch_To_OB_Mode;
begin
 AdjustSelection;
 SynchronizeMultis(Map_mode);
 Map_mode:=MM_OB;
 SectorEditor.Visible:=false;
 WallEditor.Visible:=false;
 VertexEditor.Visible:=false;
 ObjectEditor.Visible:=true;
 SetFocus;

 SpeedButtonSC.Down:=False;
 SpeedButtonWL.Down:=False;
 SpeedButtonVX.Down:=False;
 SpeedButtonOB.Down:=True;


 DO_Fill_ObjectEditor;
 Map.Refresh;
end;

procedure TMapWindow.DO_Zoom_None;
begin
 SetScale(1);
end;

Procedure TMapWindow.Do_Zoom_In;
begin
 if Scale < 128 then
      SetScale(Scale * Sqrt(2));
end;

Procedure TMapWindow.Do_Zoom_Out;
begin
 if Scale > 0.05 then SetScale(Scale / Sqrt(2));
end;

Procedure TMapWindow.SetScale(NewScale:Double);
begin
  if Scale <> NewScale then
    begin
      Scale:=NewScale;
      PanelZoom.Caption := Format('%-6.3f', [Scale]);
      HScrollBar.SmallChange := Trunc(1+25/scale);
      HScrollBar.LargeChange := Trunc(1+100/scale);
      VScrollBar.SmallChange := Trunc(1+25/scale);
      VScrollBar.LargeChange := Trunc(1+100/scale);
      Map.Invalidate;
    end;
end;

procedure TMapWindow.DO_Layer_OnOff;
begin
  SHADOW := not SHADOW;
  if SHADOW then
     PanelMapLayer.Font.Color := clRed {//DL nov/11/96 }
  else
    PanelMapLayer.Font.Color := clSilver; {//DL nov/11/96 }
    ModeShadow.Checked := SHADOW;
    Map.Invalidate;
end;

procedure TMapWindow.DO_Center_Map;
begin
  TheLevel.FindLimits;
 With TheLevel do
 begin
  Xoffset := Round((minX + maxX) / 2);
  Zoffset := Round((minZ + maxZ) / 2);
  DO_Set_ScrollBars_Ranges(round(minX), round(maxX), round(minZ), round(maxZ));
 end;
  Map.Invalidate;
end;

procedure TMapWindow.DO_Set_ScrollBars_Ranges(Left, Right, Bottom, Up : Integer);
var HLeft, HRight,
    Vup, Vbottom   : Integer;
begin
 HLeft   := Left;
 HRight  := Right;
 Vup     := -Bottom;
 Vbottom := -Up;

 HScrollBar.SetParams(XOffset, HLeft, HRight);
 VScrollBar.SetParams(-ZOffset, Vbottom, Vup);
{ LScrollBar.SetParams(-LAYER, -LAYER_MAX, -LAYER_MIN);}
 HScrollBar.SmallChange := Trunc(1+25/scale);
 HScrollBar.LargeChange := Trunc(1+100/scale);
 VScrollBar.SmallChange := Trunc(1+25/scale);
 VScrollBar.LargeChange := Trunc(1+100/scale);
end;

procedure TMapWindow.DO_Center_On_Cursor;
var ThePoint : TPoint;
    MapPoint : TPoint;
begin
  GetCursorPos(ThePoint);
  MapPoint := Map.ScreenToClient(ThePoint);
  SetXoffset(Round(S2MX(MapPoint.X)));
  SetZoffset(Round(S2MZ(MapPoint.Y)));
  Map.Invalidate;
end;

procedure TMapWindow.DO_Center_On_CurrentObject;
var
    TheWall   : TWall;
    TheVertex : TVertex;
    TheObject : TOB;
begin
 CASE MAP_MODE OF
  MM_SC : With TheLevel.Sectors[SC_HILITE].Vertices[0] do
          begin
           SetXoffset(Round(X)); SetZoffset(Round(Z));
          end;
  MM_WL : With TheLevel.Sectors[SC_HILITE] do
          begin
           TheWall:=Walls[WL_HILITE];
           TheVertex := Vertices[TheWall.V1];
           SetXoffset(Round(TheVertex.X));
           SetZoffset(Round(TheVertex.Z));
          end;
  MM_VX : With TheLevel.Sectors[SC_HILITE].Vertices[VX_HILITE] do
          begin
           SetXoffset(Round(X));
           SetZoffset(Round(Z));
          end;
  MM_OB : With TheLevel.Objects[OB_HILITE] do
          begin
           SetXoffset(Round(X));
           SetZoffset(Round(Z));
          end;
 END;
 Map.Invalidate;
end;

Procedure TMapWindow.Do_SaveProject;
var path:String;
begin
 if NewLevel then
 begin
  SaveProject.FileName:=LevelFile;
  if not DirectoryExists(ExtractFilePath(LevelFile)) then
   ForceDirectories(ExtractFilePath(LevelFile));
  if not SaveProject.Execute then exit;
  LevelFile:=SaveProject.FileName;
  NewLevel:=false;
 end
 else
 begin
  BackUpFile(LevelFile);
  BackUpFile(ChangeFileExt(LevelFile,'.obt'));
 end;

 path:=ExtractPath(LevelFile);
 if not DirectoryExists(path) then mkDir(Path);
 TheLevel.Name:=ChangeFileExt(ExtractFileName(LevelFile),'');
 TheLevel.Save(LevelFile);
 Modified:=false;
 LevelSrcFile:=LevelFile;
 Caption:='LawMaker - '+LevelSrcFile;
 AddRecent(LevelFile);
end;

Procedure TMapWindow.DO_OBShadow_OnOff;
begin
  OBSHADOW := not OBSHADOW;
  if OBSHADOW then
  {//  MapWindow.PanelOBLayer.Font.Color := clRed }
  { Panel1OBLayer.Font.Color := clRed }   {//DL nov/96 }
  else
  {//  MapWindow.PanelOBLayer.Font.Color := clBlack;}
  { Panel1OBLayer.Font.Color := clBlack;}
   ModeObjectShadow.Checked := OBSHADOW; {// DL/NOV/96}
   Map.Invalidate;
end;

Procedure TMapWindow.DO_Grid_OnOff;
begin
  GridON := not GridON;
  if GridON then
    PanelGrid.Font.Color := clRed
  else
    PanelGrid.Font.Color := clBlack;
    Map.Invalidate;
end;

Procedure TMapWindow.SetGrid(size:Integer);
begin
 if size>256 then size:=256
 else if size<1 then size:=1;
 if grid<>size then
 begin
  Grid:=size;
  PanelGrid.Caption := IntToStr(Grid);
  if GridON then Map.Invalidate;
 end;
end;

procedure TMapWindow.DO_Grid_In;
begin
 SetGrid(2 * Grid);
end;

procedure TMapWindow.DO_Grid_Out;
begin
 SetGrid(Grid div 2);
end;

Procedure TMapWindow.Do_ScrollLRBy(N:Integer);
begin
  if SetXOffset(Xoffset + N) then
   Map.Invalidate;
end;

Procedure TMapWindow.Do_ScrollUDBy(N:Integer);
begin
  if SetZOffset(Zoffset + N) then
   Map.Invalidate;
end;

procedure TMapWindow.DO_MultiSel_SC(s : Integer);
var m : Integer;
begin
 m := SC_MULTIS.FindSector(s);
 CASE MULTISEL_MODE[1] of
  'T' :  if  m <> -1 then
          SC_MULTIS.Delete(m)
         else
          SC_MULTIS.AddSector(s);
  '+' :  if  m  = -1 then SC_MULTIS.AddSector(s);
  '-' :  if  m <> -1 then SC_MULTIS.Delete(m);
 END;
 PanelMulti.Caption := IntToStr(SC_MULTIS.Count);
end;

procedure TMapWindow.DO_MultiSel_VX(s, v : Integer);
var m : Integer;
begin
 m := VX_MULTIS.FindVertex(s, v);
 CASE MULTISEL_MODE[1] of
  'T' :  if  m <> -1 then
          VX_MULTIS.Delete(m)
         else
          VX_MULTIS.AddVertex(s, v);
  '+' :  if  m  = -1 then VX_MULTIS.AddVertex(s, v);
  '-' :  if  m <> -1 then VX_MULTIS.Delete(m);
 END;
 PanelMulti.Caption := IntToStr(VX_MULTIS.Count);
end;

procedure TMapWindow.DO_MultiSel_WL(s, w : Integer);
var m : Integer;
begin
 m := WL_MULTIS.FindWall(s, w);
 CASE MULTISEL_MODE[1] of
  'T' :  if  m <> -1 then
          WL_MULTIS.Delete(m)
         else
          WL_MULTIS.AddWall(s, w);
  '+' :  if  m  = -1 then WL_MULTIS.AddWall(s, w);
  '-' :  if  m <> -1 then WL_MULTIS.Delete(m);
 END;
 PanelMulti.Caption := IntToStr(WL_MULTIS.Count);
end;

procedure TMapWindow.DO_MultiSel_OB(o : Integer);
var m         : Integer;
begin
 m := OB_MULTIS.FindObject(o);
 CASE MULTISEL_MODE[1] of
  'T' :  if  m <> -1 then
          OB_MULTIS.Delete(m)
         else
          OB_MULTIS.AddObject(o);
  '+' :  if  m  = -1 then OB_MULTIS.AddObject(o);
  '-' :  if  m <> -1 then OB_MULTIS.Delete(m);
 END;
 PanelMulti.Caption := IntToStr(OB_MULTIS.Count);
end;

procedure TMapWindow.DO_Clear_MultiSel;
begin
 SC_MULTIS.Clear;
 VX_MULTIS.Clear;
 WL_MULTIS.Clear;
 OB_MULTIS.Clear;

 {this handles multi color indicator, back menu...}
 CASE MAP_MODE OF
  MM_SC : DO_Fill_SectorEditor;
  MM_WL : DO_Fill_WallEditor;
  MM_VX : DO_Fill_VertexEditor;
  MM_OB : DO_Fill_ObjectEditor;
 END;

 PanelMulti.Caption := '0';
 Map.Invalidate;
end;

procedure TMapWindow.DO_Translate_SelMultiSel(x, z : Double);
var idx:Integer;
begin
 CASE MAP_MODE of
  MM_SC : if SC_Multis.Count=0 then TranslateSector(TheLevel,SC_HILITE,x,z)
          else TranslateSectorSelection(TheLevel,SC_Multis,x,z);
  MM_WL : if WL_Multis.Count=0 then TranslateWall(TheLevel,SC_HILITE,WL_HILITE,x,z)
          else TranslateWallSelection(TheLevel,WL_Multis,x,z);
  MM_VX : if VX_Multis.Count=0 then TranslateVertex(TheLevel,SC_HILITE,VX_HILITE,x,z)
          else TranslateVertexSelection(TheLevel,VX_Multis,x,z);
  MM_OB : if OB_Multis.Count=0 then TranslateObject(TheLevel,OB_HILITE,x,z)
          else TranslateObjectSelection(TheLevel,OB_Multis,x,z);
 END;
MODIFIED := TRUE;
Map.Invalidate;
end;

Procedure TMapWindow.SetCurSC(sc:Integer);
Var TheSector:TSector;
begin
 if sc>=TheLevel.Sectors.count then sc:=0
 else if sc<0 then sc:=TheLevel.Sectors.count-1;
 SC_HILITE:=sc;
 TheSector:=TheLevel.Sectors[sc];
 GoToLayer(TheSector.Layer);
 Do_Fill_SectorEditor;
 Map.Invalidate;
end;

Procedure TMapWindow.SetCurWL(sc,wl:Integer);
var wc:Integer;
    TheSector:TSector;
begin
 if sc>=TheLevel.Sectors.count then sc:=0
 else if sc<0 then sc:=TheLevel.Sectors.count-1;
 wc:=TheLevel.Sectors[sc].Walls.count;
 if wl>=wc then wl:=0
 else if wl<0 then wl:=wc-1;
 TheSector:=TheLevel.Sectors[sc];
 GoToLayer(TheSector.Layer);
 SC_HILITE:=sc;
 WL_HILITE:=wl;
 Do_Fill_WallEditor;
 Map.Invalidate;
end;

Procedure TMapWindow.SetCurVX(sc,vx:Integer);
var vc:Integer;
    TheSector:TSector;
begin
 if sc>=TheLevel.Sectors.count then sc:=0
 else if sc<0 then sc:=TheLevel.Sectors.count-1;
 vc:=TheLevel.Sectors[sc].Vertices.count;
 if vx>=vc then vx:=0
 else if vx<0 then vx:=vc-1;
 TheSector:=TheLevel.Sectors[sc];
 GoToLayer(TheSector.Layer);
 SC_HILITE:=sc;
 VX_HILITE:=vx;
 Do_Fill_VertexEditor;
 Map.Invalidate;
end;

Procedure TMapWindow.SetCurOB(ob:Integer);
var 
    TheObject:TOB;
begin
 if ob>=TheLevel.Objects.count then ob:=0
 else if ob<0 then ob:=TheLevel.Objects.count-1;
 OB_HILITE:=ob;
 TheObject:=TheLevel.Objects[ob];
 if TheLevel.IsSCValid(TheObject.Sector) then
 begin
  GoToLayer(TheLevel.Sectors[TheObject.Sector].Layer);
 end;
 Do_Fill_ObjectEditor;
 Map.Invalidate;
end;

procedure TMapWindow.ShellDeleteSC;
var
    OldCursor : HCursor;
    i:Integer;
begin
 With Thelevel do
 if (SC_MULTIS.Count = Sectors.Count) or (Sectors.Count = 1) then
  begin
   MsgBox('YOU CANNOT DELETE ALL SECTORS !',
                          'Delete Sectors',
                          mb_Ok or mb_IconExclamation);
   exit;
  end;

 if DoCONFIRM(c_MDelete) and (SC_MULTIS.Count <> 0) then
  begin
   if MsgBox('Confirm MULTIPLE SECTOR DELETE ?',
                            'Delete Sectors',
                            mb_YesNo or mb_IconQuestion) = idNo
    then exit;
  end;

 if DoCONFIRM(c_SCDelete) and (SC_MULTIS.Count = 0) then
  begin
   if MsgBox('Confirm SECTOR DELETE ?',
                            'Delete Sector',
                            mb_YesNo or mb_IconQuestion) = idNo
    then exit;
  end;

 OldCursor  := SetCursor(LoadCursor(0, IDC_WAIT));

 {handle the selection only if no multiselection
  if there is a multiselection, it will handle the selection}
 if SC_MULTIS.Count = 0 then
  DeleteSector(TheLevel,SC_HILITE)
 else
  begin
   {Fisrt sort the multiselection}
   SC_MULTIs.Sorted:=true;
   SC_MULTIs.Sorted:=false; {We don't need it sorted on the fly}

   For i:=SC_Multis.Count-1 downto 0 do {To avoid messing up multiselection}
     DeleteSector(TheLevel,SC_Multis.GetSector(i));

   SC_Multis.Clear;
   WL_Multis.Clear;
   VX_Multis.Clear;
  end;

 SetCursor(OldCursor);
 AdjustSelection;
 MODIFIED := TRUE;
 DO_Fill_SectorEditor;
 Map.Refresh;
end;

Procedure TMapWindow.AdjustSelection; {Makes sure that selection is vaild}
begin
 if SC_HILITE<0 then SC_HILITE:=0;
 if WL_HILITE<0 then WL_HILITE:=0;
 if VX_HILITE<0 then VX_HILITE:=0;
 if OB_HILITE<0 then OB_HILITE:=0;
 
 With TheLevel do
 begin
  if SC_HILITE>=Sectors.Count then SC_HILITE:=Sectors.Count-1;

  if WL_HILITE>=Sectors[SC_HILITE].Walls.Count then
   WL_HILITE:=Sectors[SC_HILITE].Walls.Count-1;

  if VX_HILITE>=Sectors[SC_HILITE].Vertices.Count then
   VX_HILITE:=Sectors[SC_HILITE].Vertices.Count-1;

  if OB_HILITE>=Objects.Count then
   OB_HILITE:=Objects.Count-1;
 end;
end;

Procedure TMapWindow.ShellDeleteWL(sc,wl:Integer);
var i:Integer;
begin
 if (WL_MULTIS.Count=0) and DoCONFIRM(c_WLDelete)  then
  if MsgBox('Delete Wall?','Confirmation',mb_YesNo)=idNo then exit;
 if (WL_MULTIS.Count>0) and DoCONFIRM(c_MDelete) then
  if MsgBox('Delete multiple Walls?','Confirmation',mb_YesNo)=idNo then exit;

  if WL_MULTIS.Count=0 then WL_MULTIS.AddWall(sc,wl);
 {First sort}
  WL_MULTIS.Sorted:=true;
  WL_MULTIS.Sorted:=false;

  For i:= WL_MULTIS.Count-1 downto 0 do
   DeleteWall(TheLevel,WL_MULTIS.GetSector(i),WL_MULTIS.GetWall(i));

  WL_MULTIS.Clear;

 SetCurWL(SC_HILITE,WL_HILITE-1);
 DO_Fill_WallEditor;
 MODIFIED := TRUE;
 Map.Invalidate;
end;

Procedure TMapWindow.ShellDeleteVX(SC,VX:Integer);
var i:Integer;
begin
 if (VX_MULTIS.Count=0) and DoCONFIRM(c_VXDelete) then
  if MsgBox('Delete Vertex?','Confirmation',mb_YesNo)=idNo then exit;

 if (VX_MULTIS.Count>0) and DoCONFIRM(c_MDelete) then
  if MsgBox('Delete multiple Vertices?','Confirmation',mb_YesNo)=idNo then exit;

  if VX_MULTIS.Count=0 then VX_MULTIS.AddVertex(SC,VX);
 {First sort}
  VX_MULTIS.Sorted:=true;
  VX_MULTIS.Sorted:=false;

  For i:= VX_MULTIS.Count-1 downto 0 do
   DeleteVertex(TheLevel,VX_MULTIS.GetSector(i),VX_MULTIS.GetVertex(i));

  VX_MULTIS.Clear;
  SetCurVX(SC_HILITE,VX_HILITE-1);
 DO_Fill_VertexEditor;
 MODIFIED := TRUE;
 Map.Invalidate;
end;

Procedure TMapWindow.ShellDeleteOB;
var OldCursor:HCursor;
    i:Integer;
begin
With TheLevel do
 if (OB_MULTIS.Count = Objects.Count) or (Objects.Count = 1) then
  begin
   MsgBox('YOU CANNOT DELETE ALL OBJECTS !',
                          'Delete Objects',
                          mb_Ok or mb_IconExclamation);
   exit;
  end;

 if DoCONFIRM(c_MDelete) and (OB_MULTIS.Count <> 0) then
  begin
   if MsgBox('Confirm MULTIPLE OBJECT DELETE ?',
                            'Delete Objects',
                            mb_YesNo or mb_IconQuestion) = idNo
    then exit;
  end;

 if DoConfirm(c_OBDelete) and (OB_MULTIS.Count = 0) then
  begin
   if MsgBox('Confirm OBJECT DELETE ?',
                            'Delete Object',
                            mb_YesNo or mb_IconQuestion) = idNo
    then exit;
  end;

 OldCursor  := SetCursor(LoadCursor(0, IDC_WAIT));

 {handle the selection only if no multiselection
  if there is a multiselection, it will handle the selection}
  if OB_MULTIS.FindObject(OB_HILITE)=-1 then OB_MULTIS.AddObject(OB_HILITE);
 if OB_MULTIS.Count <> 0 then
 begin
   OB_MULTIS.Sorted:=true;
   OB_MULTIS.Sorted:=false;;
   For i:=OB_Multis.Count-1 downto 0 do
    DeleteOB(TheLevel,OB_Multis.GetObject(i));
   OB_Multis.Clear;
   SC_Multis.Clear;
   WL_Multis.Clear;
   VX_Multis.Clear;
  end;

 SetCursor(OldCursor);

 AdjustSelection;
 DO_Fill_ObjectEditor;
 Map.Refresh;
 MODIFIED := TRUE;
end;

Procedure TMapWindow.Do_MakeAdjoins;
var m:Integer;
    Adjoins:Integer;
begin
 Adjoins:=MakeAdjoin(TheLevel,SC_HILITE, WL_HILITE);
 for m:=0 to WL_MULTIS.Count-1 do
  Inc(adjoins, MakeAdjoin(TheLevel,WL_Multis.GetSector(m),WL_Multis.GetWall(m)));
 DO_Fill_WallEditor;
 PanelText.Caption := IntToStr(adjoins) + ' ADJOIN(S) MADE';
 if Adjoins<>0 then Modified:=true;
end;

Procedure TMapWindow.DO_Unadjoin;
var m:Integer;
    Adjoins:Integer;
begin
 Adjoins:=UnAdjoin(TheLevel,SC_HILITE, WL_HILITE);
 for m:=0 to WL_MULTIS.Count-1 do
  Inc(adjoins, UnAdjoin(TheLevel,WL_Multis.GetSector(m),WL_Multis.GetWall(m)));
 DO_Fill_WallEditor;
 PanelText.Caption := IntToStr(adjoins) + ' ADJOIN(S) Removed';
 if Adjoins<>0 then Modified:=true;
end;

procedure TMapWindow.ShellSplitWL(sc, wl : Integer);
var adjoined    : Boolean;
    TheSector   : TSector;
    TheWall     : TWall;
    adjoin,
    mirror,
    DAdjoin,
    Dmirror        : Integer;
    NewWL:integer;
begin
 if DoCONFIRM(c_WLSplit) then
  begin
   if MsgBox('Confirm SPLIT WALL ?',
                            'Split Wall',
                            mb_YesNo or mb_IconQuestion) = idNo
    then exit;
  end;

 TheSector := TheLevel.Sectors[sc];
 TheWall   := TheSector.Walls[wl];

 Adjoin:=TheWall.Adjoin; Mirror:=TheWall.Mirror;
 DAdjoin:=TheWall.DAdjoin; DMirror:=TheWall.DMirror;

 if (Dadjoin<>-1) or (Adjoin <> -1) then  UnAdjoin(TheLevel,sc, wl);

 NewWL:=SplitWall(TheLevel, sc, wl);

 if Adjoin<>-1 then SplitWall(TheLevel,adjoin, mirror);
 if DAdjoin<>-1 then SplitWall(TheLevel, Dadjoin, Dmirror);
 if (Adjoin<>-1) or (DAdjoin<>-1) then
  begin
   MakeAdjoin(TheLevel,sc, wl);
   MakeAdjoin(TheLevel, sc, NewWL);
  end;
  
 MODIFIED := TRUE;
 DO_Fill_WallEditor;
 Map.Invalidate;
end;

procedure TMapWindow.ShellSplitVX(sc, vx : Integer);
var wl : Integer;
begin
 wl:=GetWLfromV1(TheLevel,sc,vx);
 if Wl<>-1 then
  begin
   ShellSplitWL(sc, wl);
   DO_Fill_VertexEditor;
  end;
end;

procedure TMapWindow.ShellInsertOB(cursX, cursZ : Double);
var s, m       : Integer;
    TheObject  : TOB;
    TheObject2 : TOB;
    oldobjs    : Integer;
    OldCursor  : HCursor;
    XZero,
    ZZero      : Double;
begin
{ If OB_MULTIS.Count<>0 then
 begin
  ShowMessage('Multiple object copying is not yet implemented');
  Exit;
 end;}
 OldCursor  := SetCursor(LoadCursor(0, IDC_WAIT));

   TheObject := TheLevel.Objects[OB_HILITE];
   XZero     := TheObject.X - cursX;
   ZZero     := TheObject.Z - cursZ;
   if OB_MULTIS.FindObject(OB_HILITE)=-1 then
       OB_MULTIS.AddObject(OB_HILITE);

   oldobjs:=TheLevel.Objects.Count;
  for m:=0 to OB_MULTIS.Count-1 do
  begin
   TheObject:=TheLevel.Objects[OB_MULTIS.GetObject(m)];
   TheObject2 := TheLevel.NewObject;
   TheObject2.Assign(TheObject);
   TheObject2.X          := RoundTo2Dec(TheObject.X - XZero);
   TheObject2.Y          := TheObject.Y;
   TheObject2.Z          := RoundTo2Dec(TheObject.Z - ZZero);
   TheObject2.Sector:=-1;
   TheLevel.Objects.Add(TheObject2);
  end;

  OB_MULTIS.Clear;
  For m:=oldobjs to TheLevel.Objects.Count-1 do
   OB_MULTIS.AddObject(m);

   SetCurOB(oldobjs);
  if OB_MULTIS.Count=1 then OB_MULTIS.Clear;
  
  ForceLayerObjects;
 SetCursor(OldCursor);
 PanelMulti.Caption := IntToStr(OB_MULTIS.Count);
 Map.Refresh;
 MODIFIED := TRUE;
end;

Procedure TMapWindow.DO_Polygon(kind:p_type);
var pt:TPoint;
    x,z:Double;
begin
  GetCursorPos(pt);
  pt := Map.ScreenToClient(pt);
  x  := pt.x;
  z  := pt.y;
  x  := S2MX(x);
  z  := S2MZ(z);
  if GridOn then GetNearestGridPoint(x, z , x, z);
  MakePolygon(x,z,kind,4,8*Sqrt(2));
end;

Procedure TMapWindow.MakePolygon(x,z:double;kind:P_type;sides:Integer; rad:Double);
var refWl,RefSC:Integer;
    NSc:Integer;
    w:Integer;
begin
  Case Map_mode of
   MM_SC,MM_VX: begin refSC:=SC_HILITE; RefWL:=0; end;
   MM_WL: Begin refSC:=SC_HILITE; RefWL:=WL_HILITE; end;
   MM_OB: exit;
  end;
  case kind of
   p_sector: SetCurSC(CreatePolygonSector(TheLevel,x,z,rad,sides,RefSC,RefWL));
   p_gap: CreatePolygonGap(TheLevel,SC_HILITE,x,z,rad,sides,refSC,RefWL);
   p_subsector: begin
                 CreatePolygonGap(TheLevel,SC_HILITE,x,z,rad,sides,refSC,RefWL);
                 nSc:=CreatePolygonSector(TheLevel,x,z,rad,sides,RefSC,RefWL);
                  For w:=0 to sides-1 do MakeAdjoin(TheLevel,nSc,w);
                 SetCurSC(nSc);
                end;
  end;
  MODIFIED := TRUE;
  Map.Invalidate;
end;

Procedure TMapWindow.DO_Find_SC_Adjoin;
var TheSector:TSector;
begin
 TheSector:=TheLevel.Sectors[SC_HILITE];
 if TheSector.VAdjoin<>-1 then
  if TheLevel.IsSCValid(TheSector.VAdjoin) then
   SetCurSC(TheSector.VAdjoin);
end;

Procedure TMapWindow.DO_Find_WL_Adjoin(n:Integer);
var Wall:TWall;
begin
 Wall:=TheLevel.Sectors[SC_HILITE].Walls[WL_HILITE];
 Case n of
  1: if Wall.Adjoin=-1 then exit
     else SetCurWL(Wall.Adjoin,Wall.Mirror);
  2: if Wall.DAdjoin=-1 then exit
     else SetCurWL(Wall.DAdjoin,Wall.DMirror);
  else exit;
 END;
 Map.Invalidate;
end;

procedure TMapWindow.ToolsGOBFileManagerClick(Sender: TObject);
begin
 ConMan.Show;
end;

procedure TMapWindow.FormDestroy(Sender: TObject);
begin
 {ObjectEditor.Destroy;
 SectorEditor.Destroy;
 WallEditor.Destroy;
 VertexEditor.Destroy;}
end;

procedure TMapWindow.FormShow(Sender: TObject);
var fname,ext:String;
begin
  Application.CreateForm(TObjectEditor, ObjectEditor);
  ObjectEditor.MapWindow:=Self;
  ObjectEditor.MultiSel:=OB_MULTIS;

  Application.CreateForm(TSectorEditor, SectorEditor);
  SectorEditor.MapWindow:=Self;
  SectorEditor.MultiSel:=SC_MULTIS;

  Application.CreateForm(TWallEditor, WallEditor);
  WallEditor.MapWindow:=Self;
  WallEditor.MultiSel:=WL_MULTIS;

  Application.CreateForm(TVertexEditor, VertexEditor);
  VertexEditor.MapWindow:=Self;
  VertexEditor.MultiSel:=VX_MULTIS;

  Application.CreateForm(TConsistency, Consistency);
  Consistency.MapWindow:=Self;

  Application.CreateForm(TFindSectors, FindSectors);
  FindSectors.MapWindow:=Self;

  Application.CreateForm(TFindWalls, FindWalls);
  FindWalls.MapWindow:=Self;

  Application.CreateForm(TFindObjects, FindObjects);
  FindObjects.MapWindow:=Self;

  Application.CreateForm(TToolsWindow, ToolsWindow);
  ToolsWindow.MapWindow:=self;

  if MapperPos.WWidth=0 then exit;
  With MapperPos do SetBounds(WLeft,WTop,Wwidth,Wheight);

  if ParamCount>0 then
  begin
   fname:=ParamStr(1);
   if IsContainer(Fname) then begin ConMan.OpenFile(Fname); ConMan.Show; exit; end;
   ext:=UpperCase(ExtractExt(Fname));
   if ext='.LVT' then OpenLevel(Fname);
  end;
end;

Function TMapWindow.DO_Publish(Const LABName:String):Boolean;
var Lc:TLabCreator; Files:TStringList; F:TFile;
    ProjectDir,ext:String; i:Integer;
    path:String;
begin
 Result:=true;
 Try
  ProjectDir:=ExtractFilePath(LevelFile);
  Files:=TStringList.Create;
  ListDirMask(ProjectDir,'*.*',Files);
  {filter out "wrong" files}
  for i:=Files.Count-1 downto 0 do
  begin
   ext:=UpperCase(ExtractExt(files[i]));
   if (ext<>'.LVT') and (ext<>'.OBT') and
      (ext<>'.LBB') and (ext<>'.OBB') and
      (ext<>'.INF') and (ext<>'.CHK') and
      (ext<>'.MSC') and (ext<>'.WAV') and
      (ext<>'.PCX') and (ext<>'.NWX') and
      (ext<>'.ITM') and (ext<>'.ATX') and
      (ext<>'.MSG') and (ext<>'.LST') and
      (ext<>'.PHY') and (ext<>'.LAF') Then Files.Delete(i);
  end;
  {Create LAB}
  Lc:=TLABCreator.Create(LabName);
  Lc.PrepareHeader(Files);
  for i:=0 to files.count-1 do
  begin
   f:=OpenFileRead(ProjectDir+Files[i],0);
   lc.AddFile(f);
   f.Fclose;
  end;
 Finally
  Lc.Free;
  Files.Free;
 end;
 Path:=ExtractFilePath(LABName);
 Files:=TStringList.Create;
 ListDirMask(ProjectDir,'*.rcs;*.rcm;*.rca;*.txt',Files);
 for i:=0 to Files.Count-1 do
 begin
  CopyAllFile(ProjectDir+Files[i],path+Files[i]);
 end;
end;

procedure TMapWindow.PublishMenuClick(Sender: TObject);
begin
 if not levelLoaded then begin ShowMessage('Load or create a level first'); exit; end;
 if Modified or NewLevel then begin ShowMessage('Save the level first'); exit; end;
 PublishDialog.FileName:=GameDir+ChangeFileExt(ExtractFileName(LevelFile),'.lab');
 if PublishDialog.Execute then DO_Publish(PublishDialog.FileName);
end;

procedure TMapWindow.MeasureWindow;
begin
 ScreenX          := Map.Width;
 ScreenZ          := Map.Height;
 ScreenCenterX    := Map.Width div 2;
 ScreenCenterZ    := Map.Height div 2;
 MAP_RECT.Left    := 0;
 MAP_RECT.Right   := Map.Width;
 MAP_RECT.Top     := 0;
 MAP_RECT.Bottom  := Map.Height;
end;

Procedure TMapWindow.ShellExtrudeWall;
begin
  With TheLevel.Sectors[SC_HILITE].Walls[WL_HILITE] do
  if (Adjoin<>-1) and (DAdjoin<>-1) then
   begin
    MsgBox('Cannot extrude DOUBLY adjoined wall !',
                           'Mapper - Extrude Wall',
                           mb_Ok or mb_IconExclamation);
    exit;
   end;

 if DoCONFIRM(c_WLExtrude) then
  begin
   if MsgBox('Confirm EXTRUDE WALL ?',
                            'Mapper - Extrude Wall',
                            mb_YesNo or mb_IconQuestion) = idNo
    then exit;
  end;
  ExtrudeWall(TheLevel,SC_HILITE,WL_HILITE,extr_ratio);
 SetCurWL(TheLevel.Sectors.Count-1,0);
 Map.Refresh;
 MODIFIED := TRUE;
end;

Procedure TMapWindow.ForceLayerObjects;
Var TheObject:TOB;
    Layered:Integer;
    i:Integer;
begin
 Layered:=0;
 TheObject:=TheLevel.Objects[OB_HILITE];
 if GetObjectSC(TheLevel,Any_Layer,OB_HILITE, TheObject.Sector) then Inc(Layered)
 else TheObject.Sector:=-1;

 for i:=0 to OB_MULTIS.count-1 do
 begin
  TheObject:=TheLevel.Objects[OB_MULTIS.GetObject(i)];
  if GetObjectSC(TheLevel,Any_Layer,OB_MULTIS.GetObject(i), TheObject.Sector) then Inc(Layered)
  else TheObject.Sector:=-1;
 end;

 SetCurOB(OB_HILITE);
 if layered<>0 then MODIFIED:=true;
 PanelText.Caption := IntToStr(Layered) + ' OBJECT(S) LAYERED';
end;

procedure TMapWindow.ApplyFixUpMenuClick(Sender: TObject);
var NFUName:String;
begin
 NfuName:=ChangeFileExt(ExtractName(LevelFile),'.nfu');
 FixUpDialog.Filter:=
 Format('FixUp for this Level (%s)|%s|FixUp Files (*.nfu)|*.nfu',[NfuName,NfuName]);
 FixUpDialog.FileName:=GameDir+NfuName;
 if FixUpDialog.Execute then
  ApplyFixUp(TheLevel,FixUpDialog.FileName);
end;

Procedure TMapWindow.SynchronizeMultis(masterMulti:Integer);
Procedure ConvertVXs2SCs;
var m,sc:Integer;
begin
 SC_MULTIS.Clear;
 For m:=0 to VX_MULTIS.Count-1 do
 begin
  sc:=VX_MULTIS.GetSector(m);
  if SC_MULTIS.FindSector(sc)=-1 then
    SC_MULTIS.AddSector(sc);
 end;
end;

Procedure ConvertWLs2SCs;
var m,sc:Integer;
begin
 SC_MULTIS.Clear;
 For m:=0 to WL_MULTIS.Count-1 do
 begin
  sc:=WL_MULTIS.GetSector(m);
  if SC_MULTIS.FindSector(sc)=-1 then
    SC_MULTIS.AddSector(sc);
 end;
end;

Procedure ConvertSCs2WLs;
var m,sc,w:Integer;
begin
 WL_MULTIS.Clear;
 For m:=0 to SC_MULTIS.Count-1 do
 begin
  sc:=SC_MULTIS.GetSector(m);
  for w:=0 to TheLevel.Sectors[sc].Walls.count-1 do
   WL_MULTIS.AddWall(sc,w);
 end;
end;

Procedure ConvertVXs2WLs;
var m,sc,wl,vx:Integer;
begin
 WL_MULTIS.Clear;
 For m:=0 to VX_MULTIS.Count-1 do
 begin
  sc:=VX_MULTIS.GetSector(m);
  vx:=VX_MULTIS.GetVertex(m);
  wl:=GetWLFromV1(TheLevel,sc,vx);
  if WL_MULTIS.FindWall(sc,wl)=-1 then
    WL_MULTIS.AddVertex(sc,wl);
 end;
end;

Procedure ConvertSCs2VXs;
var m,v,sc:Integer;
begin
 VX_MULTIS.Clear;
 For m:=0 to SC_MULTIS.Count-1 do
 begin
  sc:=SC_MULTIS.GetSector(m);
  for v:=0 to TheLevel.Sectors[sc].Vertices.count-1 do
  VX_MULTIS.AddVertex(sc,v);
 end;
end;

Procedure ConvertWLs2VXs;
var m,sc,wl:Integer;
begin
 VX_MULTIS.Clear;
 For m:=0 to WL_MULTIS.Count-1 do
 begin
  sc:=WL_MULTIS.GetSector(m);
  wl:=WL_MULTIS.GetWall(m);
  With TheLevel.Sectors[sc].Walls[wl] do
  begin
   if VX_MULTIS.FindVertex(sc,V1)=-1 then
    VX_MULTIS.AddVertex(sc,V1);
   if VX_MULTIS.FindVertex(sc,V2)=-1 then
    VX_MULTIS.AddVertex(sc,V2);
  end;
 end;
end;

begin {SynchronizeMultis}
 case masterMulti of
  MM_SC:begin
         ConvertSCs2WLs;
         ConvertSCs2VXs;
        end;
  MM_WL:begin
         ConvertWLs2SCs;
         ConvertWLs2VXs;
        end;
  MM_VX:begin
         ConvertVXs2SCs;
         ConvertVXs2WLs;
        end;
 end;
end;

procedure TMapWindow.FormResize(Sender: TObject);
begin
  MeasureWindow;
  Map.Invalidate;
end;

procedure TMapWindow.FormHide(Sender: TObject);
begin
 With MapperPos do
 begin
  Wwidth:=width;
  Wheight:=height;
  Wtop:=top;
  Wleft:=left;
 end;
end;

Function TMapWIndow.GetProjDir:String;
begin
 if NewLevel then Result:='' else Result:=ExtractFilePath(LevelFile);
end;

procedure TMapWindow.ShellInsertSC(cursX, cursZ : Double);
var s, w, v, m : Integer;
    ss, ww     : Integer;
    TheSector  : TSector;
    TheSector2 : TSector;
    TheWall    : TWall;
    TheWall2   : TWall;
    TheVertex  : TVertex;
    TheVertex2 : TVertex;
    LVertex1,
    RVertex1,
    LVertex2,
    RVertex2   : TVertex;
    oldsecs    : Integer;
    found      : Boolean;
    OldCursor  : HCursor;
    XZero,
    ZZero      : Real;
begin
 if DoCONFIRM(c_MInsert) and (SC_MULTIS.Count <> 0) then
  begin
   if MsgBox('Confirm MULTIPLE SECTOR INSERTION ?',
    'Mapper - Insert Sectors',
     mb_YesNo or mb_IconQuestion) = idNo
    then exit;
  end;

 OldCursor  := SetCursor(LoadCursor(0, IDC_WAIT));

 {Set the reference point}
   TheSector := TheLevel.Sectors[SC_HILITE];
   TheVertex := TheSector.Vertices[0];
   XZero     := TheVertex.X - cursX;
   ZZero     := TheVertex.Z - cursZ;
 if SC_MULTIS.FindSector(SC_HILITE)=-1 then SC_MULTIS.AddSector(SC_HILITE);
 oldsecs := TheLevel.Sectors.Count;

 {create a new sector for each existing one, clearing
  all adjoins in all the walls
  as well as inf information ???
 }
 for m := 0 to SC_MULTIS.Count - 1 do
  begin
   s := SC_MULTIS.GetSector(m);

   TheSector := TheLevel.Sectors[s];
   TheSector2 := TheLevel.NewSector;
   TheSector2.Assign(TheSector);
   {Adjust Slope's sector ref}
   if TheSector.FloorSlope.Sector=s then
    TheSector2.FloorSlope.Sector:=m+oldsecs;
   if TheSector.CeilingSlope.Sector=s then
    TheSector2.CeilingSlope.Sector:=m+oldsecs;

   {Add an offset to these ?}

   for v := 0 to TheSector.Vertices.Count - 1 do
     begin
      TheVertex  := TheSector.Vertices[v];
      TheVertex2 := TheLevel.NewVertex;
      TheVertex2.X := RoundTo2Dec(TheVertex.X - XZero);
      TheVertex2.Z := RoundTo2Dec(TheVertex.Z - ZZero);
      TheSector2.Vertices.Add(TheVertex2);
     end;

   for w := 0 to TheSector.Walls.Count - 1 do
     begin
      TheWall   := TheSector.Walls[w];
      TheWall2  := TheLevel.NewWall;
      TheWall2.Assign(TheWall);
      TheWall2.V1:=TheWall.V1;
      TheWall2.V2:=TheWall.V2;
      TheSector2.Walls.Add(TheWall2);
     end;

   TheLevel.Sectors.Add(TheSector2);
  end;

 { Recreate the Adjoins wall by wall, but look only in the new sectors,
   so only internal adjoins will be created }
 { and Transfer the multiselection if there was one }

 SC_MULTIS.Clear;

 for s:=oldsecs to TheLevel.Sectors.count-1 do
 begin
  for w:=0 to TheLevel.Sectors[s].Walls.Count-1 do
   MakeAdjoinFromSCUP(TheLevel,s,w,oldsecs);
  SC_MULTIS.AddSector(s);
 end;
 if SC_MULTIS.Count=1 then SC_MULTIS.Clear;
 SetCursor(OldCursor);
 SetCurSC(oldsecs);

 PanelMulti.Caption := IntToStr(SC_MULTIS.Count);
 Map.Refresh;
 MODIFIED := TRUE;
end;

procedure TMapWindow.DO_Select_In_Rect(Var FRect:TRect);
var i,j       : Integer;
    TheSector : TSector;
    TheVertex : TVertex;
    TheWall   : TWall;
    TheObject : TOB;
    p         : TPoint;
    tmp       : Integer;
    TheLayer  : Integer;
    allin     : Boolean;
begin

 if FRECT.right < FRECT.left then
  begin
   tmp := FRECT.right;
   FRECT.right := FRECT.left;
   FRECT.left := tmp;
  end;

 if not IsRectEmpty(FRECT) then
  begin
   case MAP_MODE of
     MM_SC : begin
               for i := 0 to TheLevel.Sectors.Count - 1 do
                begin
                 allin := TRUE;
                 TheSector := TheLevel.Sectors[i];
                 if (TheSector.Layer = LAYER) or SHADOW then
                  begin
                  for j := 0 to TheSector.Vertices.Count - 1 do
                   begin
                    TheVertex := TheSector.Vertices[j];
                    p.X       := M2SX(TheVertex.X);
                    p.Y       := M2SZ(TheVertex.Z);
                    If not PtInRect(FRECT, p) then
                     begin
                      allin := FALSE;
                      break;
                     end;
                   end;
                  if allin then DO_Multisel_SC(i);
                  end;
                end;
             end;
     MM_WL : begin
               for i := 0 to TheLevel.Sectors.Count - 1 do
                begin
                 TheSector := TheLevel.Sectors[i];
                 if (TheSector.Layer = LAYER) or SHADOW then
                  begin
                   for j := 0 to TheSector.Walls.Count - 1 do
                    begin
                     allin     := TRUE;
                     TheWall   := TheSector.Walls[j];
                     TheVertex := TheSector.Vertices[TheWall.V1];
                     p.X       := M2SX(TheVertex.X);
                     p.Y       := M2SZ(TheVertex.Z);
                     If not PtInRect(FRECT, p) then allin := FALSE;
                     TheVertex := TheSector.Vertices[TheWall.V1];
                     p.X       := M2SX(TheVertex.X);
                     p.Y       := M2SZ(TheVertex.Z);
                     If not PtInRect(FRECT, p) then allin := FALSE;
                     if allin then DO_Multisel_WL(i, j);
                    end;
                  end;
                end;
             end;
     MM_VX : begin
               for i := 0 to TheLevel.Sectors.Count - 1 do
                begin
                 TheSector := TheLevel.Sectors[i];
                 if (TheSector.Layer = LAYER) or SHADOW then
                 for j := 0 to TheSector.Vertices.Count - 1 do
                  begin
                   TheVertex := TheSector.Vertices[j];
                   p.X       := M2SX(TheVertex.X);
                   p.Y       := M2SZ(TheVertex.Z);
                   If PtInRect(FRECT, p) then DO_Multisel_VX(i, j);
                  end;
                end;
             end;
     MM_OB : begin
               for i := 0 to TheLevel.Objects.Count - 1 do
                begin
                  TheObject := TheLevel.Objects[i];
                  if TheObject.Sector <> -1 then
                   begin
                    TheSector := TheLevel.Sectors[TheObject.Sector];
                    TheLayer  := TheSector.Layer;
                   end
                  else
                   begin
                    TheLayer := 9999;
                   end;
                  if ((TheLayer = LAYER) or (TheLayer = 9999) or SHADOW) then
                   begin
                    p.X       := M2SX(TheObject.X);
                    p.Y       := M2SZ(TheObject.Z);
                    If PtInRect(FRECT, p) then DO_Multisel_OB(i);
                   end;
                end;
             end;
   end;
  {Update the multiselection markers}
  case MAP_MODE of
    MM_SC : PanelMulti.Caption := IntToStr(SC_MULTIS.Count);
    MM_WL : PanelMulti.Caption := IntToStr(WL_MULTIS.Count);
    MM_VX : PanelMulti.Caption := IntToStr(VX_MULTIS.Count);
    MM_OB : PanelMulti.Caption := IntToStr(OB_MULTIS.Count);
  end;
  Map.Invalidate;
 end;
end;

Procedure TMapWindow.GoTo_Sector(sc:Integer);
begin
 Do_Switch_To_SC_Mode;
 SetCurSC(sc);
 Layer:=TheLevel.Sectors[SC_HILITE].Layer;
 DO_Center_On_CurrentObject;
end;

Procedure TMapWindow.GoTo_Wall(sc,wl:Integer);
begin
 Do_Switch_To_WL_Mode;
 SetCurWL(sc,wl);
 Layer:=TheLevel.Sectors[SC_HILITE].Layer;
 DO_Center_On_CurrentObject;
end;

Procedure TMapWindow.GoTo_Object(ob:Integer);
begin
 Do_Switch_To_OB_Mode;
 SetCurOB(ob);
 if TheLevel.Objects[Ob].Sector<>-1 then
  Layer:=TheLevel.Sectors[TheLevel.Objects[OB].Sector].Layer;
 DO_Center_On_CurrentObject;
end;

Procedure TMapWindow.DO_Find;
var sSc,sWL,sOb:Integer;
    Found:Boolean;
begin
 if how=f_next then
 begin
 Case Map_mode of
  MM_SC: Found:=FindSectors.FindNext(SC_HILITE);
  MM_WL: Found:=FindWalls.FindNext(SC_HILITE,WL_HILITE);
  MM_OB: Found:=FindObjects.FindNext(OB_HILITE);
 end;
 exit;
 end;

 Case Map_mode of
  MM_SC: begin
          if how=f_first then sSC:=0 else sSC:=SC_HILITE;
          Found:=FindSectors.Find;
         end;
  MM_WL: Found:=FindWalls.Find;
  MM_OB: Found:=FindObjects.Find;
 end;

 Case map_mode of
  MM_SC: if SC_MULTIS.Count<>0 then PanelMulti.Caption:=IntToStr(SC_MULTIS.Count);
  MM_WL: if WL_MULTIS.Count<>0 then PanelMulti.Caption:=IntToStr(WL_MULTIS.Count);
  MM_OB: if OB_MULTIS.Count<>0 then PanelMulti.Caption:=IntToStr(OB_MULTIS.Count);
 end;
 Map.Invalidate;
end;

Procedure TMapWindow.LayerAllObjects(force:Boolean);
var o:Integer;
    NLayered:Integer;
begin
 Progress.Reset(TheLevel.Objects.Count);
 Progress.Msg:='Layering Objects...';
 NLayered:=0;
 For o:=0 to TheLevel.Objects.Count-1 do
 With TheLevel.Objects[o] do
 begin
  if (Force) or (Sector=-1) then
   if not GetObjectSC(TheLevel,Any_Layer,o,Sector) then Sector:=-1
   else Inc(NLayered);
   Progress.Step;
 end;
 PanelText.Caption:=IntToStr(NLayered)+' objects layered';
 if NLayered<>0 then Modified:=true;
 Progress.Hide;
end;

Procedure TMapWindow.DO_Rotate(angle:Double;rotateYaw:Boolean);
var defx,defz:Double;
    n:Integer;
begin
 case Map_Mode of
  MM_SC: begin
          With TheLevel.Sectors[SC_HILITE].Vertices[0] do
          begin
           defx:=x;
           defz:=z;
          end;
          n:=SC_Multis.FindSector(SC_HILITE);
          if n=-1 then n:=SC_MULTIS.AddSector(SC_HILITE) else N:=-1;

          RotateSectorSelection(TheLevel,SC_MULTIS,defx,defz,angle);
          if n<>-1 then SC_Multis.Delete(n);
         end;
  MM_WL: begin
          With TheLevel.Sectors[SC_HILITE] do
          With Walls[WL_HILITE] do
          With Vertices[V1] do
          begin
           defx:=x;
           defz:=z;
          end;

          n:=WL_Multis.FindWall(SC_HILITE,WL_HILITE);
          if n=-1 then n:=SC_MULTIS.AddWall(SC_HILITE,WL_HILITE) else N:=-1;

          RotateWallSelection(TheLevel,WL_MULTIS,defx,defz,angle);
          if n<>-1 then WL_MULTIS.Delete(n);
         end;
  MM_VX: begin
          With TheLevel.Sectors[SC_HILITE].Vertices[VX_HILITE] do
          begin
           defx:=x;
           defz:=z;
          end;

          n:=VX_Multis.FindVertex(SC_HILITE,VX_HILITE);
          if n=-1 then n:=SC_MULTIS.AddVertex(SC_HILITE,VX_HILITE) else N:=-1;

          RotateVertexSelection(TheLevel,VX_MULTIS,defx,defz,angle);
          if n<>-1 then VX_MULTIS.Delete(n);
          DO_Fill_VertexEditor;
         end;
  MM_OB: begin
          With TheLevel.Objects[OB_HILITE] do
          begin
           defx:=x;
           defz:=z;
          end;

          n:=OB_Multis.FindObject(OB_HILITE);
          if n=-1 then n:=OB_MULTIS.AddObject(OB_HILITE) else N:=-1;

          RotateObjectSelection(TheLevel,OB_MULTIS,defx,defz,angle,RotateYaw);

          if n<>-1 then OB_MULTIS.Delete(n);
          DO_Fill_ObjectEditor;
         end;
 end;
 Modified:=true;
 Map.Invalidate;
end;

Function TMapWindow.GetCenterX:Double;
begin
 Result:=XOffset;
end;

Function TMapWindow.GetCenterZ:Double;
begin
 Result:=ZOffset;
end;

Procedure TMapWindow.DO_Scale(factor:double);
var defx,defz:double;
    n:Integer;
begin
 case Map_Mode of
  MM_SC: begin
          With TheLevel.Sectors[SC_HILITE].Vertices[0] do
          begin
           defx:=x;
           defz:=z;
          end;
          n:=SC_Multis.FindSector(SC_HILITE);
          if n=-1 then n:=SC_MULTIS.AddSector(SC_HILITE) else N:=-1;

          ScaleSectorSelection(TheLevel,SC_MULTIS,defx,defz,factor);
          if n<>-1 then SC_Multis.Delete(n);
         end;
  MM_WL: begin
          With TheLevel.Sectors[SC_HILITE] do
          With Walls[WL_HILITE] do
          With Vertices[V1] do
          begin
           defx:=x;
           defz:=z;
          end;

          n:=WL_Multis.FindWall(SC_HILITE,WL_HILITE);
          if n=-1 then n:=SC_MULTIS.AddWall(SC_HILITE,WL_HILITE) else N:=-1;

          ScaleWallSelection(TheLevel,WL_MULTIS,defx,defz,factor);
          if n<>-1 then WL_MULTIS.Delete(n);
         end;
  MM_VX: begin
          With TheLevel.Sectors[SC_HILITE].Vertices[VX_HILITE] do
          begin
           defx:=x;
           defz:=z;
          end;

          n:=VX_Multis.FindVertex(SC_HILITE,VX_HILITE);
          if n=-1 then n:=SC_MULTIS.AddVertex(SC_HILITE,VX_HILITE) else N:=-1;

          ScaleVertexSelection(TheLevel,VX_MULTIS,defx,defz,factor);
          if n<>-1 then VX_MULTIS.Delete(n);
          DO_Fill_VertexEditor;
         end;
  MM_OB: begin
          With TheLevel.Objects[OB_HILITE] do
          begin
           defx:=x;
           defz:=z;
          end;

          n:=OB_Multis.FindObject(OB_HILITE);
          if n=-1 then n:=OB_MULTIS.AddObject(OB_HILITE) else N:=-1;

          ScaleObjectSelection(TheLevel,OB_MULTIS,defx,defz,factor);

          if n<>-1 then OB_MULTIS.Delete(n);
          DO_Fill_ObjectEditor;
         end;
 end;
 Modified:=true;
 Map.Invalidate;
end;

Procedure TMapWindow.DO_Offset(dy:Double;how:Integer);
var n:Integer;
begin
 Case Map_mode of
  MM_SC:begin
          n:=SC_Multis.FindSector(SC_HILITE);
          if n=-1 then n:=SC_MULTIS.AddSector(SC_HILITE) else N:=-1;

          RaiseSectorSelection(TheLevel,SC_MULTIS,DY,how);
          if n<>-1 then SC_Multis.Delete(n);
          Do_Fill_SectorEditor;
        end;
  MM_OB:begin
          n:=OB_Multis.FindObject(OB_HILITE);
          if n=-1 then n:=OB_MULTIS.AddObject(OB_HILITE) else N:=-1;

          RaiseObjectSelection(TheLevel,OB_MULTIS,DY);
          if n<>-1 then SC_Multis.Delete(n);
          Do_Fill_ObjectEditor;
        end;
 end;
 Modified:=true;
 Map.Invalidate;
end;

Procedure TMapWindow.DO_Distribute(what:Integer);
var First_FY,FY_Dif:Double;
    First_CY,CY_Dif:Double;
    FirstAmb,AmbDif:Double;
    m:Integer;
    ns:Integer;
begin
 if (Map_Mode<>MM_SC) or (SC_MULTIS.Count<3) then
 begin
  ShowMessage('You must be in Sectors mode and have multiselection of at least 3 sectors');
  exit;
 end;

 Ns:=SC_MULTIS.Count;

 With TheLevel.Sectors[SC_MULTIS.GetSector(0)] do
 begin
  First_FY:=Floor_Y;
  First_CY:=Ceiling_Y;
  FirstAmb:=Ambient;
 end;

 With TheLevel.Sectors[SC_MULTIS.GetSector(ns-1)] do
 begin
  FY_Dif:=Floor_Y-First_FY;
  CY_Dif:=Ceiling_Y-First_CY;
  AmbDif:=Ambient-AmbDif;
 end;

 For m:=1 to Ns-2 do
 With TheLevel.Sectors[SC_MULTIS.GetSector(m)] do
 begin
  if what and d_floors<>0 then
   Floor_Y:=RoundTo2Dec(First_FY+FY_Dif*m/ns);
  if what and d_ceilings<>0 then
   Ceiling_Y:=RoundTo2Dec(First_CY+CY_Dif*m/ns);
  if what and d_Ambients<>0 then
   Ambient:=Round(FirstAmb+AmbDif*m/ns);
 end;
Modified:=true;
Do_Fill_SectorEditor;
end;

Procedure TMapWindow.DO_Stitch(how:Integer;mid,top,bot:Boolean);
begin
 if (map_mode<>MM_WL) or (WL_MULTIS.COunt<2) then
 begin
  ShowMessage('You must be in Wall mode and have at least 2 walls selected');
  exit;
 end;
 case how of
  st_Horizontal: StitchHorizontal(TheLevel,WL_MULTIS,Mid,top,bot);
  st_HorizontalInverse: StitchHorizontalInvert(TheLevel,WL_MULTIS,Mid,top,bot);
  st_Vertical: StitchVertical(TheLevel,WL_MULTIS,Mid,top,bot);
 end;
 Modified:=true;
 DO_Fill_WallEditor;
end;

procedure TMapWindow.ImportMenuClick(Sender: TObject);
var Fname:String;
begin
  if LEVELLoaded and MODIFIED then
 case MsgBox('Level has been modified. Do you want to SAVE ?',
             'Import', mb_YesNoCancel or mb_IconQuestion) of
  idYes: DO_SaveProject;
  idCancel: Exit;
 end;
 With GetFileOpen do
 begin
  FileName:='';
  Filter:=Filter_DFLevelFiles;
  if Execute then ImportLevel(GetFileOpen.FileName);
 end;
end;

procedure TMapWindow.EditMenuClick(Sender: TObject);
begin
 Case Map_Mode of
  MM_SC: begin
          EditCopy.Enabled:=true;
          EditPaste.Enabled:=CanPasteSectors;
         end;
  MM_OB:  begin
          EditCopy.Enabled:=true;
          EditPaste.Enabled:=CanPasteObjects;
         end;
  else begin
        EditCopy.Enabled:=false;
        EditPaste.Enabled:=false;
       end;
 end;
end;

Procedure TMapWindow.DO_CopyGeometry;
begin
 if Map_Mode=MM_SC then CopySectors(TheLevel,SC_HILITE,SC_MULTIS);
end;

Procedure TMapWindow.DO_CopyObjects;
begin
 if map_mode=MM_OB then CopyObjects(TheLevel,OB_HILITE,OB_MULTIS);
end;

Procedure TMapWindow.DO_PasteGeometry(x,z:Double);
var i,fSC:Integer;
begin
 if Map_Mode<>MM_SC then exit;
 fSC:=PasteSectors(TheLevel,x,z);
 if fSC=-1 then exit;

 {Select new sectors}
 SC_HILITE:=fSc;
 SC_MULTIS.Clear;
 if TheLevel.Sectors.Count-FSC>1 then
  for i:=fSc to TheLevel.Sectors.Count-1 do SC_MULTIS.AddSector(i);
 DO_Center_Map;
 PanelText.Caption:=Format('%d Sectors pasted',[TheLevel.Sectors.Count-fSc]);
 Modified:=true;
 Map.Invalidate;
end;

Procedure TMapWindow.DO_PasteObjects(x,z:Double);
var i,fOB:Integer;
begin
 if Map_Mode<>MM_OB then exit;
 fOB:=PasteObjects(TheLevel,x,z);
 if fOB=-1 then exit;

 {Select new objects}
 OB_HILITE:=fOB;
 OB_MULTIS.Clear;

 if TheLevel.Objects.Count-fOB>1 then
  for i:=fOB to TheLevel.Objects.Count-1 do OB_MULTIS.AddObject(i);

 ForceLayerObjects;
 PanelText.Caption:=Format('%d Objects pasted',[TheLevel.Objects.Count-fOB])+PanelText.Caption;
 Modified:=true;
 Map.Invalidate;
end;

Procedure TMapWindow.DO_PasteAtCursor;
var ThePoint,MapPoint:TPoint;
    px,pz:Double;
begin
 GetCursorPos(ThePoint);
 MapPoint := MapWindow.Map.ScreenToClient(ThePoint);
 {if grid is on, must paste on a grid point!}
 px := S2MX(MapPoint.X);
 pz := S2MZ(MapPoint.Y);
 GetNearestGridPoint(S2MX(MapPoint.X),S2MZ(MapPoint.Y), px, pz);
 CASE MAP_MODE OF
  MM_SC : DO_PasteGeometry(px, pz);
  MM_OB : DO_PasteObjects(px, pz);
 END;
end;

Procedure TMapWindow.Shell_JumpTo;
var s:string;
    sc,wl,vx,ob:Integer;
begin
 Case map_mode of
  MM_SC,MM_VX: begin
          s:=Format('%d',[SC_HILITE]);
          if not InputQuery('Jump to Sector','Number',s) then exit;
          if not ValInt(s,sc) then begin ShowMessage('Invalid number');exit; end;
          if (sc<0) or (sc>=TheLevel.Sectors.Count) then begin ShowMessage('Out of range');exit; end;
          GoTo_Sector(sc);
         end;
  MM_WL: begin
          s:=Format('%d ,%d',[SC_HILITE,WL_HILITE]);
          if not InputQuery('Jump to Wall','Number',s) then exit;
          if not SScanf(s,'%d,%d',[@sc,@wl]) then begin ShowMessage('Invalid number');exit; end;
          if (sc<0) or (sc>=TheLevel.Sectors.Count) then begin ShowMessage('Sector out of range');exit; end;
          GoTo_Wall(sc,wl);
         end;
  MM_OB: begin
          s:=Format('%d',[OB_HILITE]);
          if not InputQuery('Jump to Object','Number',s) then exit;
          if not ValInt(s,ob) then begin ShowMessage('Invalid number');exit; end;
          if (ob<0) or (ob>=TheLevel.Objects.Count) then begin ShowMessage('Out of range');exit; end;
          GoTo_Object(ob);
         end;
  end;
end;

procedure TMapWindow.Messagewindow1Click(Sender: TObject);
begin
 MsgForm.Show;
end;

procedure TMapWindow.Scripteditor1Click(Sender: TObject);
begin
 ScriptEdit.Show;
end;

procedure TMapWindow.FindNextClick(Sender: TObject);
begin
 DO_Find(f_Next);
end;

Procedure TMapWindow.AddRecent(const FName:String);
Const MaxMenuLen=20;
var s:string;
    n:integer;
    Delim:char;
    mi:TmenuItem;
begin
 if Recents.IndexOf(FName)<>-1 then exit;
 if Recents.Count=4 then
 begin
  Recents.Delete(0);
  n:=ProjectMenu.IndexOf(RecentBreak)+1;
  ProjectMenu.Delete(n);
 end;
 Recents.Add(Fname);
 if length(Fname)<=MaxMenuLen then s:=Fname else
 begin
  if IsInContainer(FName) then delim:='>' else Delim:='\';
  s:=Copy(ExtractPath(Fname),1,MaxMenuLen-4)+'...'+delim+ExtractName(FName);
 end;
 mi:=TMenuItem.Create(ProjectMenu);
 Mi.Caption:=s;
 Mi.OnClick:=RecentClick;
 Mi.Hint:=Fname;
 ProjectMenu.Add(Mi);
end;

procedure TMapWindow.RecentClick(Sender: TObject);
var n:integer;
begin
  if LEVELLoaded and Modified then
 case MsgBox('Level has been modified. Do you want to SAVE ?',
             'Open Project', mb_YesNoCancel or mb_IconQuestion) of
  idYes: DO_SaveProject;
  idCancel: Exit;
 end;
 OpenLevel((Sender as TmenuItem).Hint);
end;

end.


