unit Mapper;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Buttons, ExtCtrls, IniFiles, Menus,
  StdCtrls, FileCtrl, Grids,
  M_Global, M_Option, M_About, M_io, M_Util, M_MapUt, M_mapfun,
  M_NewWDP, M_Stat, M_Multi, M_Resour,
  M_Editor, M_SCedit, M_WLedit, M_VXedit, M_OBEdit, M_Tools,
  M_Extern, M_LevEd, M_regist,
  Gobs, G_Util, Lfds, L_Util, InfEdit2, ToolKit, M_Query,
  _undoc, M_Test, I_Util, GolEdit, M_Duke, M_key,
  Render,vuecreat,_conv3do, math, CNVEdit, ShellApi, Windows, vcl.AppEvnts,
{$IFDEF WDF32}
ZRender,ComCtrls,
{$ENDIF}
  Stitch,  Tabnotbk, system.notification, ui.notifications, Math.vectors,
  system.win.winrt;
type
  TMapWindow = class(TForm)
    ToolbarMain: TPanel;
    PanelBottom: TPanel;
    PanelText: TPanel;
    SpeedButtonOpen: TSpeedButton;
    OpenProjectDialog: TOpenDialog;
    SpeedButtonSave: TSpeedButton;
    SpeedButtonNewProject: TSpeedButton;
    SpeedButtonGOBTest: TSpeedButton;
    SpeedButton3DPreview: TSpeedButton;
    DummyFileListBox: TFileListBox;
    MapPopup: TPopupMenu;
    PopupDelete: TMenuItem;
    PopupS2: TMenuItem;
    PopupFind: TMenuItem;
    PopupS1: TMenuItem;
    PopUpCopy: TMenuItem;
    PopupDuplicate: TMenuItem;
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
    N3: TMenuItem;
    ProjectChecks: TMenuItem;
    ProjectGOBTest: TMenuItem;
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
    ModeObjectShadow: TMenuItem;
    ModeObjectDisplay: TMenuItem;
    ToolsMenu: TMenuItem;
    ToolsTools: TMenuItem;
    ToolsExternalTools: TMenuItem;
    N10: TMenuItem;
    ToolsGOBFileManager: TMenuItem;
    ToolsLFDFileManager: TMenuItem;
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
    ViewEditorGOL: TMenuItem;
    ViewEditorLVL: TMenuItem;
    ViewEditorMSG: TMenuItem;
    ViewEditorTXT: TMenuItem;
    ViewEditorHeader: TMenuItem;
    N17: TMenuItem;
    TBMain: TMenuItem;
    TBTools: TMenuItem;
    ToolsQuery: TMenuItem;
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
    PanelEditMode: TPanel;
    HiddenINFOutMemo: TMemo;
    N18: TMenuItem;
    ProjectDelete: TMenuItem;
    ProjectClose: TMenuItem;
    DeleteProjectDialog: TOpenDialog;
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
    TabbedNotebook1: TTabbedNotebook;
    SpeedButtonSC: TSpeedButton;
    SpeedButtonGobFM: TSpeedButton;
    SpeedButtonWL: TSpeedButton;
    SpeedButtonVX: TSpeedButton;
    SpeedButtonOB: TSpeedButton;
    SpeedButtonLfdFM: TSpeedButton;
    SpeedButtonTKT: TSpeedButton;
    SpeedButtonHelp: TSpeedButton;
    SBSaveMapBMP: TSpeedButton;
    SpeedButtonINF: TSpeedButton;
    SpeedButtonGOL: TSpeedButton;
    SpeedButtonLVL: TSpeedButton;
    SpeedButtonMSG: TSpeedButton;
    SpeedButtonTXT: TSpeedButton;
    SpeedButtonLevel: TSpeedButton;
    SpeedButtonOptions: TSpeedButton;
    SpeedButtonStat: TSpeedButton;
    SpeedButtonQuery: TSpeedButton;
    SpeedButtonTools: TSpeedButton;
    SpeedButtonXTools: TSpeedButton;
    SpeedButtonChecks: TSpeedButton;
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
    Panel1MapType: TPanel;
    Panel1OBLayer: TPanel;
    SpeedButtonMapKey: TSpeedButton;
    LabelMapType: TLabel;
    LabelObjDiffShadow: TLabel;
    SpeedButtonVue: TSpeedButton;
    SpeedButton3DO: TSpeedButton;
    Toolkit: TMenuItem;
    SectorFill: TMenuItem;
    MMSectorFill: TMenuItem;
    PopUpPaste: TMenuItem;
    PopupS3: TMenuItem;
    ClearMultiSelection1: TMenuItem;
    PopUpUndo: TMenuItem;
    PopUpRedo: TMenuItem;
    N20: TMenuItem;
    EditUndo: TMenuItem;
    EditRedo: TMenuItem;
    EditClearMultiselect: TMenuItem;
    N23: TMenuItem;
    GridLabel: TLabel;
    ZoomLabel: TLabel;
    LayerLabel: TLabel;
    N24: TMenuItem;
    IncreaseLayer: TMenuItem;
    DecreaseLayer: TMenuItem;
    ShowAllLayer: TMenuItem;
    SpeedButtonToolsMain: TSpeedButton;
    MenuSubToolStitch: TMenuItem;
    MenuSubToolGeneral: TMenuItem;
    MenuSubToolDistribute: TMenuItem;
    MenuSubToolPolygon: TMenuItem;
    MenuSubToolDeform: TMenuItem;
    MenuSubToolOffset: TMenuItem;
    MenuSubToolFlip: TMenuItem;
    SaveBMPMapDialog: TSaveDialog;
    SaveAS1: TMenuItem;
    HotKeys1: TMenuItem;
    CenteronSelectionX1: TMenuItem;
    CenterMapDefaultNumPad1: TMenuItem;
    N25: TMenuItem;
    EditAdjoin: TMenuItem;
    EditUnAdjoin: TMenuItem;
    EditExtrude: TMenuItem;
    N26: TMenuItem;
    EditNext: TMenuItem;
    EditPrevious: TMenuItem;
    Renderin3D: TMenuItem;
    SpeedButtonOptionsMain: TSpeedButton;
    ToolsVUEEditor: TMenuItem;
    Tools3DOConverter: TMenuItem;
    WDFUSESupportDiscord: TMenuItem;
    ViewLogs: TMenuItem;
    ToolsLogFolder: TMenuItem;
    SpeedButtonDF21: TSpeedButton;
    NotificationCenter: TNotificationCenter;
    FreeUndoList: TMenuItem;

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
    procedure SpeedButtonPLTEditClick(Sender: TObject);
    procedure SpeedButtonGOBTestClick(Sender: TObject);
    procedure SpeedButton3DPreviewClick(Sender: TObject);
    procedure SpeedButtonDF21Click(Sender: TObject);
    procedure SpeedButtonGridInClick(Sender: TObject);
    procedure SpeedButtonGridOutClick(Sender: TObject);
    procedure SpeedButtonGridEightClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SpeedButtonCenterCursor(Sender: TObject);
    procedure SpeedButtonCenterSelection(Sender: TObject);
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
    procedure SBSaveAsMapPClick(Sender: TObject);
    procedure SpeedButtonToolsClick(Sender: TObject);
    procedure MapPopupPopup(Sender: TObject);
    procedure PopupNewClick(Sender: TObject);
    procedure DIFFAllClick(Sender: TObject);
    procedure PanelOBLayerClick(Sender: TObject);
    procedure SpeedButtonXToolsClick(Sender: TObject);
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
    procedure HelpRegisterClick(Sender: TObject);
    procedure HelpDFSpecsClick(Sender: TObject);
    procedure HelpTutorialClick(Sender: TObject);
    procedure MapDblClick(Sender: TObject);
    procedure SpeedButtonDukeClick(Sender: TObject);
    procedure ProjectDeleteClick(Sender: TObject);
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
    procedure SpeedButtonGOLClick(Sender: TObject);
    procedure SpeedButtonLVLClick(Sender: TObject);
    procedure SpeedButtonMSGClick(Sender: TObject);
    procedure SpeedButtonTXTClick(Sender: TObject);
    procedure SpeedButtonGridOnOffClick(Sender: TObject);
    procedure PanelMapLayerClick(Sender: TObject);
    procedure SpeedButtonMapKeyClick(Sender: TObject);
     procedure SpeedButtonVueClick(Sender: TObject);
    procedure SpeedButton3DOClick(Sender: TObject);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure ToolsGOBFileManagerClick(Sender: TObject);
    procedure ToolsLFDFileManagerClick(Sender: TObject);
    procedure ToolsToolkitClick(Sender: TObject);
    procedure DO_Clear_MultiSelClick(Sender: TObject);
    procedure PopUpUndoClick(Sender: TObject);
    procedure PopUpRedoClick(Sender: TObject);
    procedure DO_Layer_Up_Click(Sender: TObject);
    procedure DO_Layer_Down_Click(Sender: TObject);
    procedure MenuSubToollClick(Sender: TObject);
    procedure DO_ZoomSelect(Sender: TObject);
    procedure EditAdjoinClick(Sender: TObject);
    procedure EditUnAdjoinClick(Sender: TObject);
    procedure EditExtrudeClick(Sender: TObject);
    procedure EditNextClick(Sender: TObject);
    procedure EditPreviousClick(Sender: TObject);
    procedure FormShortCut(var Msg: TWMKey;
      var Handled: Boolean);
    procedure WDFUSESupportDiscordClick(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure SpeedButtonCenterMapClick(Sender : TObject);
    procedure ToolsLogFilePathClick(Sender: TObject);
    procedure ToolsLogFolderClick(Sender: TObject);
    procedure FreeUndoListClick(Sender: TObject);




  private
    { Private declarations }
  protected
    procedure WMSize(var Msg: TWMSize); message WM_SIZE;
  public
    { Public declarations }
    procedure DisplayHint(Sender: TObject);
    procedure AppIdle(Sender: TObject; var Done: Boolean);
    procedure DO_Draw_BigVX(X, Z : Real; color : LongInt);
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
    procedure DO_DrawSectorFill;
    procedure DO_NewProjectShell;
    procedure DO_OpenProjectShell;
    procedure NotifyMessage(msg : string);

    function IsPtVisible(X, Z : Real) : Boolean;
    function SetXOffset(XOff : Integer) : Boolean;
    function SetZOffset(ZOff : Integer) : Boolean;
  end;

procedure DO_CheckTheGobs;
procedure HandleCommandLine;
function  IsRegistered : Boolean;
function  MaySave      : Boolean;

var
  MapWindow: TMapWindow;

implementation

{$R *.DFM}

procedure TMapWindow.Notifymessage(msg : string);
var
 Notification : TNotification;
 NCenter : TNotificationCenter;
 {ToastMessage : TToastMessage;
 WinControl : TWinControl;}
begin
{
  ToastPopUP.Visible := True;
  WinControl := TwinControl.Create(ToastPopUP);
  ToastMessage := ToastMessage.Create(WinControl);
  ToastMessage.Toast(tpInfo,'Info','My Text');}


   Notification := TNotification.Create;
   NCenter := TNotificationCenter.Create(MapWindow.NotificationCenter);
   Notification := NCenter.CreateNotification;
   Notification.Name := 'WDFUSE Notification';
   Notification.title := 'WDFUSE';
   Notification.alertbody := msg;

   NCenter.PresentNotification(Notification);

end;


procedure DO_CheckTheGobs;
var gobok : Boolean;
begin
 gobok := FALSE;

 // First Run set the options
 if NO_INI then
  begin
    OptionsDialog.ShowModal;
    NO_INI := False;
  end;

  while not gobok do
   begin
    gobok := DO_InitGOBS;
    if not gobok then
     begin
      OptionsDialog.ShowModal;
      if OptionsDialog.ModalResult = idCancel then Halt;
     end;
   end;
end;

procedure TMapWindow.DO_ZoomSelect(Sender: TObject);
begin
  DO_Center_On_CurrentObject;
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

function  TMapWindow.IsPtVisible(X, Z : Real) : Boolean;
var ThePoint : TPoint;
begin
 ThePoint.X      := M2SX(X);
 ThePoint.Y      := M2SZ(Z);
 Result          := PtInRect(MAP_RECT, ThePoint);
end;

procedure TMapWindow.DO_Draw_BigVX(X, Z : Real; color : LongInt);
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
  x, z, x2, z2, dx, dz : Real;
begin
 with Map.Canvas do
  begin
    Pen.Color := color;
    TheSector := TSector(MAP_SEC.Objects[s]);
    TheWall   := TWall(TheSector.Wl.Objects[w]);
    LVertex   := TVertex(TheSector.Vx.Objects[TheWall.left_vx]);
    RVertex   := TVertex(TheSector.Vx.Objects[TheWall.right_vx]);

    x  := (LVertex.X + RVertex.X) / 2;
    z  := (LVertex.Z + RVertex.Z) / 2;
    dx := LVertex.X - RVertex.X;
    dz := LVertex.Z - RVertex.Z;
    x2 := x - perp_ratio * dz;
    z2 := z + perp_ratio * dx;
    MoveTo(M2SX(x),  M2SZ(z));
    LineTo(M2SX(x2), M2SZ(z2));
  end;
end;

procedure TMapWindow.DO_Layer_Down_Click(Sender: TObject);
begin
  DO_Layer_Down;
end;

procedure TMapWindow.DO_Layer_Up_Click(Sender: TObject);
begin
  DO_Layer_Up;
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
      for i := 0 to MAP_SEC.Count - 1 do
        begin
          TheSector := TSector(MAP_SEC.Objects[i]);
          if (TheSector.Layer <> LAYER) and SHADOW_LAYERS[TheSector.Layer] then
          for j := 0 to TheSector.Wl.Count - 1 do
            begin
              TheWall := TWall(TheSector.Wl.Objects[j]);
              LVertex := TVertex(TheSector.Vx.Objects[TheWall.left_vx]);
              RVertex := TVertex(TheSector.Vx.Objects[TheWall.right_vx]);
              MoveTo(M2SX(LVertex.X), M2SZ(LVertex.Z));
              LineTo(M2SX(RVertex.X), M2SZ(RVertex.Z));
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
     for i := 0 to MAP_OBJ.Count - 1 do
      begin
       TheObject := TOB(MAP_OBJ.Objects[i]);
       if not DifficultyOk(TheObject.Diff) then continue;
       if TheObject.Sec <> -1 then
        begin
         TheSector := TSector(MAP_SEC.Objects[TheObject.Sec]);
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
var i,j, w      : Integer;
    TheSector   : TSector;
    LVertex     : TVertex;
    RVertex     : TVertex;
    TheWall     : TWall;
    Npen, Apen  : HPen;
    OldPen      : HPen;
    TheMsg      : TMsg;
    deltax,
    deltaz      : Real;
    dx, dz      : Integer;
    px, pz      : Real;
    TempColor   : Integer;
    TempStyle   : TBrushStyle;
    TempX       : Integer;
    drawCount   : Integer;
begin
 with Map.Canvas do
  begin
   NPen := CreatePen(PS_SOLID, 1, col_wall_n);
   APen := CreatePen(PS_SOLID, 1, col_wall_a);
   OldPen := SelectObject(Handle, NPen);

   for i := 0 to MAP_SEC.Count - 1 do
    begin
      try
        TheSector := TSector(MAP_SEC.Objects[i]);
        if TheSector.Layer = LAYER then
         begin
           for j := 0 to TheSector.Wl.Count - 1 do
            begin
              TheWall := TWall(TheSector.Wl.Objects[j]);

              if TheWall.Adjoin = -1 then
               SelectObject(Handle, NPen)
              else
               SelectObject(Handle, APen);

              LVertex := TVertex(TheSector.Vx.Objects[TheWall.left_vx]);
              RVertex := TVertex(TheSector.Vx.Objects[TheWall.right_vx]);
              TempX := M2SX(LVertex.X);
              MoveTo(Tempx,
                     M2SZ(LVertex.Z));
              TempX := M2SX(RVertex.X);
              LineTo(TempX,
                     M2SZ(RVertex.Z));

            end;
        end;
      except on E: Exception do
       begin
         Log.error('Failed to draw Sector! ' + E.ClassName +
         ' error raised, with message : '+E.Message, LogName);
        showmessage('Failed to draw Sector! ' + E.ClassName + EOL +
         ' error raised, with message : '+E.Message);
        end;
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
   for i := 0 to MAP_SEC.Count - 1 do
    begin
      TheSector := TSector(MAP_SEC.Objects[i]);
      if TheSector.Layer = LAYER then
      for j := 0 to TheSector.Wl.Count - 1 do
        begin
          TheWall := TWall(TheSector.Wl.Objects[j]);
          LVertex := TVertex(TheSector.Vx.Objects[TheWall.left_vx]);
          RVertex := TVertex(TheSector.Vx.Objects[TheWall.right_vx]);
          MoveTo(M2SX(LVertex.X), M2SZ(LVertex.Z));
          LineTo(M2SX(RVertex.X), M2SZ(RVertex.Z));
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
   for i := 0 to MAP_SEC.Count - 1 do
    begin
      TheSector := TSector(MAP_SEC.Objects[i]);
      if TheSector.Layer = LAYER then
      for j := 0 to TheSector.Wl.Count - 1 do
        begin
          TheWall := TWall(TheSector.Wl.Objects[j]);
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

            LVertex := TVertex(TheSector.Vx.Objects[TheWall.left_vx]);
            RVertex := TVertex(TheSector.Vx.Objects[TheWall.right_vx]);
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
    VXI         : Integer;
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
                   TheSector := TSector(MAP_SEC.Objects[StrToInt(Copy(SC_MULTIS[m],1,4))]);
                   for j := 0 to TheSector.Wl.Count - 1 do
                     begin
                       TheWall := TWall(TheSector.Wl.Objects[j]);
                       LVertex := TVertex(TheSector.Vx.Objects[TheWall.left_vx]);
                       RVertex := TVertex(TheSector.Vx.Objects[TheWall.right_vx]);
                       MoveTo(M2SX(LVertex.X), M2SZ(LVertex.Z));
                       LineTo(M2SX(RVertex.X), M2SZ(RVertex.Z));
                     end;
                   end;
               end;
        MM_WL: begin
                 for m := 0 to WL_MULTIS.Count - 1 do
                  begin
                   s := StrToInt(Copy(WL_MULTIS[m],1,4));
                   TheSector := TSector(MAP_SEC.Objects[s]);
                   w := StrToInt(Copy(WL_MULTIS[m],5,4));
                   if w < TheSector.Wl.Count then
                    begin
                     TheWall := TWall(TheSector.Wl.Objects[w]);
                     LVertex := TVertex(TheSector.Vx.Objects[TheWall.left_vx]);
                     RVertex := TVertex(TheSector.Vx.Objects[TheWall.right_vx]);
                     MoveTo(M2SX(LVertex.X), M2SZ(LVertex.Z));
                     LineTo(M2SX(RVertex.X), M2SZ(RVertex.Z));
                     DO_Draw_WLperp(s, w, col_multis);
                    end;
                  end;
               end;
        MM_VX: begin
                 Dimension := Round(vx_scale*SCALE/2);
                 if Dimension > vx_dim_max then Dimension := vx_dim_max;
                 for m := 0 to VX_MULTIS.Count - 1 do
                  begin
                   TheSector := TSector(MAP_SEC.Objects[StrToInt(Copy(VX_MULTIS[m],1,4))]);
                   VXI := StrToInt(Copy(VX_MULTIS[m],5,4));
                   if VXI < TheSector.Vx.Count then
                    begin
                     TheVertex := TVertex(TheSector.Vx.Objects[VXI]);
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
               end;
        MM_OB: begin
                Dimension := Round(ob_scale*SCALE/2);
                if Dimension > ob_dim_max then Dimension := ob_dim_max;
                for m := 0 to OB_MULTIS.Count - 1 do
                  begin
                   TheObject := TOB(MAP_OBJ.Objects[StrToInt(Copy(OB_MULTIS[m],5,4))]);
                   if IsPtVisible(TheObject.X, TheObject.Z) then
                    if TheObject.Special = 1 then {GENERATOR : draw a 'G'}
                     begin
                      MoveTo(M2SX(TheObject.X)+Dimension, M2SZ(TheObject.Z)-Dimension);
                      LineTo(M2SX(TheObject.X)-Dimension, M2SZ(TheObject.Z)-Dimension);
                      LineTo(M2SX(TheObject.X)-Dimension, M2SZ(TheObject.Z)+Dimension);
                      LineTo(M2SX(TheObject.X)+Dimension, M2SZ(TheObject.Z)+Dimension);
                      LineTo(M2SX(TheObject.X)+Dimension, M2SZ(TheObject.Z));
                      LineTo(M2SX(TheObject.X), M2SZ(TheObject.Z));
                     end
                    else
                    if TheObject.ClassName = 'FRAME' then
                    Ellipse(M2SX(TheObject.X)-Dimension, M2SZ(TheObject.Z)-Dimension,
                            M2SX(TheObject.X)+Dimension, M2SZ(TheObject.Z)+Dimension)
                    else
                    if TheObject.ClassName = 'SPRITE' then
                    Rectangle(M2SX(TheObject.X)-Dimension, M2SZ(TheObject.Z)-Dimension,
                              M2SX(TheObject.X)+Dimension, M2SZ(TheObject.Z)+Dimension)
                    else
                    if TheObject.ClassName = '3D' then
                     begin
                      MoveTo(M2SX(TheObject.X)-Dimension, M2SZ(TheObject.Z)+Dimension);
                      LineTo(M2SX(TheObject.X)+Dimension, M2SZ(TheObject.Z)+Dimension);
                      LineTo(M2SX(TheObject.X)+Dimension, M2SZ(TheObject.Z)-Dimension);
                      LineTo(M2SX(TheObject.X)-Dimension, M2SZ(TheObject.Z)-Dimension);
                      MoveTo(M2SX(TheObject.X), M2SZ(TheObject.Z));
                      LineTo(M2SX(TheObject.X)+Dimension, M2SZ(TheObject.Z));
                     end
                    else
                    if TheObject.ClassName = 'SAFE' then
                     begin
                      MoveTo(M2SX(TheObject.X)+Dimension, M2SZ(TheObject.Z)-Dimension);
                      LineTo(M2SX(TheObject.X)-Dimension, M2SZ(TheObject.Z)-Dimension);
                      LineTo(M2SX(TheObject.X)-Dimension, M2SZ(TheObject.Z));
                      LineTo(M2SX(TheObject.X)+Dimension, M2SZ(TheObject.Z));
                      LineTo(M2SX(TheObject.X)+Dimension, M2SZ(TheObject.Z)+Dimension);
                      LineTo(M2SX(TheObject.X)-Dimension, M2SZ(TheObject.Z)+Dimension);
                     end
                    else
                    if TheObject.ClassName = 'SOUND' then
                     begin
                      MoveTo(M2SX(TheObject.X)-Dimension, M2SZ(TheObject.Z)-Dimension);
                      LineTo(M2SX(TheObject.X), M2SZ(TheObject.Z)+Dimension);
                      LineTo(M2SX(TheObject.X)+Dimension, M2SZ(TheObject.Z)-Dimension);
                     end
                    else
                    if TheObject.ClassName = 'SPIRIT' then
                     begin
                      MoveTo(M2SX(TheObject.X)-Dimension, M2SZ(TheObject.Z)-Dimension);
                      LineTo(M2SX(TheObject.X)+Dimension, M2SZ(TheObject.Z)+Dimension);
                      MoveTo(M2SX(TheObject.X)-Dimension, M2SZ(TheObject.Z)+Dimension);
                      LineTo(M2SX(TheObject.X)+Dimension, M2SZ(TheObject.Z)-Dimension);
                     end
                    else
                    Ellipse(M2SX(TheObject.X)-Dimension, M2SZ(TheObject.Z)-Dimension,
                            M2SX(TheObject.X)+Dimension, M2SZ(TheObject.Z)+Dimension);
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
                 TheSector := TSector(MAP_SEC.Objects[SC_HILITE]);
                 for j := 0 to TheSector.Wl.Count - 1 do
                   begin
                     TheWall := TWall(TheSector.Wl.Objects[j]);
                     LVertex := TVertex(TheSector.Vx.Objects[TheWall.left_vx]);
                     if j = 0 then DO_Draw_BigVX(LVertex.X, LVertex.Z, col_select);
                     RVertex := TVertex(TheSector.Vx.Objects[TheWall.right_vx]);
                     MoveTo(M2SX(LVertex.X), M2SZ(LVertex.Z));
                     LineTo(M2SX(RVertex.X), M2SZ(RVertex.Z));
                   end;
               end;
        MM_WL: begin
                 TheSector := TSector(MAP_SEC.Objects[SC_HILITE]);
                 TheWall := TWall(TheSector.Wl.Objects[WL_HILITE]);
                 LVertex := TVertex(TheSector.Vx.Objects[TheWall.left_vx]);
                 DO_Draw_BigVX(LVertex.X, LVertex.Z, col_select);
                 RVertex := TVertex(TheSector.Vx.Objects[TheWall.right_vx]);
                 MoveTo(M2SX(LVertex.X), M2SZ(LVertex.Z));
                 LineTo(M2SX(RVertex.X), M2SZ(RVertex.Z));
                 DO_Draw_WLperp(SC_HILITE, WL_HILITE, col_select);
               end;
        MM_VX: begin
                 Dimension := Round(vx_scale*SCALE/2);
                 if Dimension > vx_dim_max then Dimension := vx_dim_max;
                 TheSector := TSector(MAP_SEC.Objects[SC_HILITE]);
                 TheVertex := TVertex(TheSector.Vx.Objects[VX_HILITE]);
                 DO_Draw_BigVX(TheVertex.X, TheVertex.Z, col_select);
               end;
        MM_OB: begin
                Dimension := Round(bigob_scale*SCALE/2);
                if Dimension > bigob_dim_max then Dimension := bigob_dim_max;
                Brush.Style := bsClear;
                Pen.Width := 2;
                TheObject := TOB(MAP_OBJ.Objects[OB_HILITE]);
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
end;

procedure TMapWindow.DO_DrawGrid;
var i, j   : Real;
    TheMsg : TMsg;
begin
  with Map.Canvas do
    begin
      while (scale * Power(2,GRID_OFFSET)) > grid do grid := grid * 2;;
      while (scale * Power(2,GRID_OFFSET+3)) < grid do  grid := grid / 2;

      i := Round(Round(Real(S2MX(0))/grid)*grid-grid);
      while  i <= Round(S2MX(ScreenX)/grid)*Grid+Grid do
        begin
          j := Round(Round(S2MZ(ScreenZ)/grid)*grid-grid);
          while j <= Round(S2MZ(0)/grid)*grid+grid do
            begin
              SetPixel(Handle, M2SX(i), M2SZ(j), col_grid);
              j := grid + j;
            end;
          i := grid + i;
        end;
    end;
    MapWindow.PanelGrid.Caption := FloatToStr(Grid);
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
      TheSector := TSector(MAP_SEC.Objects[SUPERHILITE]);
      for j := 0 to TheSector.Wl.Count - 1 do
       begin
         TheWall := TWall(TheSector.Wl.Objects[j]);
         LVertex := TVertex(TheSector.Vx.Objects[TheWall.left_vx]);
         RVertex := TVertex(TheSector.Vx.Objects[TheWall.right_vx]);
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
    deltaz      : Real;
    dx, dz      : Integer;
    px, pz      : Real;
    TheMsg      : TMsg;
begin
 with Map.Canvas do
  begin
   Brush.Style := bsSolid;
   for i := 0 to MAP_SEC.Count - 1 do
    begin
      TheSector := TSector(MAP_SEC.Objects[i]);
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

          TheWall := TWall(TheSector.Wl.Objects[w]);
          LVertex := TVertex(TheSector.Vx.Objects[TheWall.left_vx]);
          RVertex := TVertex(TheSector.Vx.Objects[TheWall.right_vx]);
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
    deltaz      : Real;
    dx, dz      : Integer;
    px, pz      : Real;
    TheMsg      : TMsg;
begin
 with Map.Canvas do
  begin
   Brush.Style := bsSolid;
   for i := 0 to MAP_SEC.Count - 1 do
    begin
      TheSector := TSector(MAP_SEC.Objects[i]);
      if TheSector.Layer = LAYER then
       begin
        for j := 0 to 1 do
         begin
          {this should give a better fill by trying again at the wall
           opposite wall 0. It is also twice slower !}
          if j = 0 then
           w := 0
          else
           w := TheSector.Wl.Count div 2;

          dam := 0;
          if (TheSector.Flag1 and 2048) <> 0 then dam := dam + 1;
          if (TheSector.Flag1 and 4096) <> 0 then dam := dam + 2;

          if dam <> 0 then
           begin
            TheWall := TWall(TheSector.Wl.Objects[w]);
            LVertex := TVertex(TheSector.Vx.Objects[TheWall.left_vx]);
            RVertex := TVertex(TheSector.Vx.Objects[TheWall.right_vx]);
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
            end;;
            FloodFill(M2SX(px)-dz, M2SZ(pz)-dx, col_wall_a, fsBorder);
           end;
         end;
       end;
    end;
  end;
end;

procedure TMapWindow.DO_Clear_MultiSelClick(Sender: TObject);
begin
    DO_Clear_MultiSel;
    DO_Clear_MultiSel2;
end;

procedure TMapWindow.DO_Draw2ndAltitudeMap;
var i,j,w       : Integer;
    dam         : Integer;
    TheSector   : TSector;
    LVertex     : TVertex;
    RVertex     : TVertex;
    TheWall     : TWall;
    deltax,
    deltaz      : Real;
    dx, dz      : Integer;
    px, pz      : Real;
    TheMsg      : TMsg;
begin
 with Map.Canvas do
  begin
   Brush.Style := bsSolid;
   for i := 0 to MAP_SEC.Count - 1 do
    begin
      TheSector := TSector(MAP_SEC.Objects[i]);
      if TheSector.Layer = LAYER then
       begin
        for j := 0 to 1 do
         begin
          {this should give a better fill by trying again at the wall
           opposite wall 0. It is also twice slower !}
          if j = 0 then
           w := 0
          else
           w := TheSector.Wl.Count div 2;

          dam := 0;
          if (TheSector.Second_Alt < 0) then dam := 1;
          if (TheSector.Second_Alt > 0) then dam := 2;

          if dam <> 0 then
           begin
            TheWall := TWall(TheSector.Wl.Objects[w]);
            LVertex := TVertex(TheSector.Vx.Objects[TheWall.left_vx]);
            RVertex := TVertex(TheSector.Vx.Objects[TheWall.right_vx]);
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
    deltaz      : Real;
    dx, dz      : Integer;
    px, pz      : Real;
    TheMsg      : TMsg;
begin
 with Map.Canvas do
  begin
   Brush.Style := bsSolid;
   for i := 0 to MAP_SEC.Count - 1 do
    begin
      TheSector := TSector(MAP_SEC.Objects[i]);
      if TheSector.Layer = LAYER then
       begin
        for j := 0 to 1 do
         begin
          {this should give a better fill by trying again at the wall
           opposite wall 0. It is also twice slower !}
          if j = 0 then
           w := 0
          else
           w := TheSector.Wl.Count div 2;

          dam := 0;
          if (TheSector.Flag1 and 1)   <> 0 then dam := 1;
          if (TheSector.Flag1 and 128) <> 0 then dam := 2;

          if dam <> 0 then
           begin
            TheWall := TWall(TheSector.Wl.Objects[w]);
            LVertex := TVertex(TheSector.Vx.Objects[TheWall.left_vx]);
            RVertex := TVertex(TheSector.Vx.Objects[TheWall.right_vx]);
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

procedure TMapWindow.DO_DrawSectorFill;
var i,j,w       : Integer;
    dam         : Integer;
    TheSector   : TSector;
    LVertex     : TVertex;
    RVertex     : TVertex;
    TheWall     : TWall;
    deltax,
    deltaz      : Real;
    dx, dz      : Integer;
    px, pz      : Real;
    TheMsg      : TMsg;
    secPolygon  : array of TPoint;
    rgn : HRGN;
begin
  try
   with Map.Canvas do
    begin
     Brush.Style := bsSolid;
     for i := 0 to MAP_SEC.Count - 1 do
      begin
        TheSector := TSector(MAP_SEC.Objects[i]);
        SetLength(secPolygon, TheSector.Vx.Count);
        //for j:= 0 to TheSector.Vx.Count - 1 do
        //  secPolygon[j] := VxToPoint(TVertex(TheSector.Vx.objects[j]));

        //rgn := CreatePolygonRgn(secPolygon[0], Length(secPolygon), WINDING);

        if TheSector.Layer = LAYER then
         begin
          for j := 0 to 1 do
           begin
            if j = 0 then
             w := 0
            else
             w := TheSector.Wl.Count div 2;

            TheWall := TWall(TheSector.Wl.Objects[w]);
            LVertex := TVertex(TheSector.Vx.Objects[TheWall.left_vx]);
            RVertex := TVertex(TheSector.Vx.Objects[TheWall.right_vx]);
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
            Brush.Color := col_sec_inner;
            //if PtInRegion(rgn, M2SX(px)-dz, M2SZ(pz)-dx) then
            FloodFill(M2SX(px)-dz, M2SZ(pz)-dx, col_wall_a, fsBorder);
          end;
         end;
      end;
    end;
   except on E: Exception do
       begin
         Log.error('Failed to Fill Sector! ' + E.ClassName +
         ' error raised, with message : '+E.Message, LogName);
        showmessage('Failed to Fill Sector! ' + E.ClassName + EOL +
         ' error raised, with message : '+E.Message);
        end;
    end;

end;

{procedure TMapWindow.DO_DrawSectorFill;
var i,j,w,w2    : Integer;
    dam         : Integer;
    TheSector   : TSector;
    LVertex     : TPoint;
    RVertex     : TPoint;
    LVertex2     : TPoint;
    RVertex2     : TPoint;
    TheWall,
    TheWall2    : TWall;

    deltax,
    deltaz      : Real;
    dx, dz      : Integer;
    px, pz      : Real;
    TheMsg      : TMsg;
    m2x, m2z    : Real;
    pxdiff,
    pzdiff,
    zMid       : Integer;
    secPolygon  : array of TPoint;
    vxPointLeft,
    vxPointRight,
    vxPointTop,
    vxPointBot,
    vxMid : TPoint;
    vxFound : Boolean;
    rgn : HRGN;
begin
 with Map.Canvas do
  begin
   Brush.Style := bsSolid;
   for i := 0 to MAP_SEC.Count - 1 do
    begin
      if FastSCROLL and
       (PeekMessage(TheMsg, 0, WM_KEYUP,   WM_KEYUP,   PM_NOYIELD or PM_NOREMOVE) or
        PeekMessage(TheMsg, 0, WM_LBUTTONDOWN, WM_LBUTTONDOWN, PM_NOYIELD or PM_NOREMOVE))
       then Break;
      TheSector := TSector(MAP_SEC.Objects[i]);
      if TheSector.Layer = LAYER then
       begin
        SetLength(secPolygon, TheSector.Vx.Count);

        for j:= 0 to TheSector.Vx.Count - 1 do
          begin
           secPolygon[j] := VxToPoint(TVertex(TheSector.Vx.objects[j]));
           if j = 0 then
            begin
              // Initialize all 4 points to the first vertex
              vxPointLeft := VxToPoint(TVertex(TheSector.Vx.objects[0]));
              vxPointRight := vxPointLeft;
              vxPointTop := vxPointLeft;
              vxPointBot := vxPointLeft;
            end
           else
            begin
              if vxPointLeft.X > secPolygon[j].X then
                vxPointLeft := secPolygon[j];
              if vxPointRight.X < secPolygon[j].X then
                vxPointRight := secPolygon[j];
              if vxPointTop.X > secPolygon[j].X then
                vxPointTop := secPolygon[j];
              if vxPointBot.X < secPolygon[j].X then
                vxPointBot := secPolygon[j];
            end;
          end;

        rgn := CreatePolygonRgn(secPolygon[0], Length(secPolygon), WINDING);

        w := 0;
        w2 := TheSector.Wl.Count div 2;

        TheWall := TWall(TheSector.Wl.Objects[w]);
        TheWall2 := TWall(TheSector.Wl.Objects[w2]);
        LVertex := VxToPoint(TVertex(TheSector.Vx.Objects[TheWall.left_vx]));
        RVertex := VxToPoint(TVertex(TheSector.Vx.Objects[TheWall.right_vx]));
        LVertex2 := VxToPoint(TVertex(TheSector.Vx.Objects[TheWall2.left_vx]));
        RVertex2 := VxToPoint(TVertex(TheSector.Vx.Objects[TheWall2.right_vx]));


        if LVertex.X = LVertex2.X then
          begin
           if LVertex.X < RVertex2.X then
            begin
              vxPointLeft :=  LVertex;
              vxPointRight := RVertex2;
            end
          else
            begin
              vxPointLeft :=  RVertex2;
              vxPointRight := LVertex;
            end;
          end
        else
          begin
           if LVertex.X < LVertex2.X then
            begin
              vxPointLeft :=  LVertex;
              vxPointRight := LVertex2;
            end
           else
            begin
              vxPointLeft :=  LVertex2;
              vxPointRight := LVertex;
            end;
          end;
        if vxPointLeft.Y > vxPointRight.Y then
          begin
            vxPointTop := vxPointLeft;
            vxPointBot := vxPointRight;
          end
        else
          begin
            vxPointTop := vxPointRight;
            vxPointBot := vxPointLeft;
          end;

        zMid := vxPointBot.Y + Round(abs(vxPointTop.Y - vxPointBot.Y) / 2);
        vxFound := False;
        for j := vxPointLeft.x+1 to vxPointRight.X-2 do
          if PtInRegion(rgn, j, zMid) then
            begin
              vxMid := Point(j, zMid);
              vxFound := True;
              break
            end;
        Brush.Color := col_sec_inner;
        if vxFound then
          begin
             log.Info('zmid s2mx = ' + floattostr(S2mX(zmid)) + ' X = ' + inttostr(vxMid.x) + ' Y = ' + inttostr(vxMid.y) +
                ' S2MX(x) = ' + floattostr(S2MX(vxmid.x)) + ' S2MZ(Y) = ' + floattostr(S2MZ(vxmid.y)), logname);
             FloodFill(vxMid.x+1, vxMid.y, col_wall_a, fsBorder);
          end;
       // FloodFill(M2SX(270)+1, M2SZ(295), col_wall_a, fsBorder);
//        FloodFill(M2SX(270.15625)+1, M2SZ(478), col_wall_a, fsBorder);


          vxMid := TPoint(j, zMid);



        deltax  := LVertex.X - RVertex.x;
        deltaz  := LVertex.z - RVertex.z;
        if deltax > 0 then dx := 1;
        if deltax = 0 then dx := 0;
        if deltax < 0 then dx := -1;
        if deltaz > 0 then dz := 1;
        if deltaz = 0 then dz := 0;
        if deltaz < 0 then dz := -1;

        log.Info('LX = ' + floattostr(M2SX(LVertex2.X)) + ' RX = ' + floattostr(M2SX(RVertex.X)) +
                ' LZ = ' + floattostr(M2SZ(LVertex2.Z)) + ' RZ = ' + floattostr(M2SZ(RVertex.Z)), logname);
        // Don't fill for width smaller than 3 pixels - Karjala 2021
        if (abs(M2SX(LVertex2.X) - M2SX(RVertex.X)) < 4) and
           (abs(M2SZ(LVertex2.Z) - M2SZ(RVertex.Z)) < 4) then continue;

        px      := (LVertex.X + RVertex.X) / 2;
        pz      := (LVertex.Z + RVertex.Z) / 2;
        Brush.Color := col_sec_inner;
        log.info('Sector Fill px = ' + floattostr(px) + ' pz = ' + floattostr(pz) +
        ' dx = ' + inttostr(dx) + ' dz = ' + inttostr(dz) +
        ' M2SX(px) = ' + floattostr(M2SX(px)) + ' M2SZ(pz) = ' + floattostr(M2SZ(pz)) +
         '  M2SX(px)-dz = ' +  floattostr(M2SX(px)-dz) + ' M2SZ(pz)-dx = ' + floattostr(M2SZ(pz)-dx), LogName);
        FloodFill(M2SX(px)-dz, M2SZ(pz)-dx, col_wall_a, fsBorder);
        SetPixel(Handle, M2SX(px)-dz, M2SZ(pz)-dx, clFuchsia);
      end;
    end;
  end;
end;}

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

{ Special Case - when Painting first time see if there is an old project we can load }
if LOADPREVPRJ and FIRSTLOAD and not LevelLoaded and (PROJECTFile <> '') then
  begin
    FIRSTLOAD := FALSE;
    if fileexists(PROJECTFile) then
     begin
      try
        MapWindow.Update;
        DO_LoadLevel;
      except on E: Exception do
        // So you don't go into a crash loop
        begin
          showmessage('Failed to load previous project ' + PROJECTFile
                      + EOL + 'Will disable Previous Loading');
          LOADPREVPRJ := False;
          Ini.WriteBool('DARK FORCES', 'LOADPREVPRJ', LOADPREVPRJ);
        end;
      end;
     end;
  end;

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
                 
                 {draw the shadow layers}
                 if SHADOW then DO_DrawShadow;
                 
                 {draw the objects even if not in object mode }
                 if OBSHADOW then DO_DrawOBjectShadow;
                 
                 {draw the current layer}
                 DO_DrawCurrentLayer;
                end
               else
                begin
                 DO_DrawCurrentLayerMono;
                 { Disable Sector Filling when Dragging }
                 if not FirstDrag then
                  begin
                   CASE MAP_TYPE OF
                    MT_LI : DO_DrawLightMap;
                    MT_DM : DO_DrawDamageMap;
                    MT_2A : DO_Draw2ndAltitudeMap;
                    MT_SP : DO_DrawSkyPitMap;
                    MT_SF : DO_DrawSectorFill;
                   end
                  end;

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
              for i := 0 to MAP_SEC.Count - 1 do
                begin
                  TheSector := TSector(MAP_SEC.Objects[i]);
                  if SHADOW or (TheSector.Layer = LAYER) then
                  for j := 0 to TheSector.Wl.Count - 1 do
                    begin
                      TheWall := TWall(TheSector.Wl.Objects[j]);
                      LVertex := TVertex(TheSector.Vx.Objects[TheWall.left_vx]);
                      RVertex := TVertex(TheSector.Vx.Objects[TheWall.right_vx]);
                      MoveTo(M2SX(LVertex.X), M2SZ(LVertex.Z));
                      LineTo(M2SX(RVertex.X), M2SZ(RVertex.Z));
                    end;
                end;
               DO_DrawOBjectShadow;
               {draw the current layer}
               Pen.Color := col_wall_a;
               Dimension := Round(vx_scale*SCALE/2);
               if Dimension > vx_dim_max then Dimension := vx_dim_max;
               for i := 0 to MAP_SEC.Count - 1 do
                begin
                  TheSector := TSector(MAP_SEC.Objects[i]);
                  if TheSector.Layer = LAYER then
                  for j := 0 to TheSector.Vx.Count - 1 do
                    begin
                      TheVertex := TVertex(TheSector.Vx.Objects[j]);
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
              for i := 0 to MAP_OBJ.Count - 1 do
                begin
                  TheObject := TOB(MAP_OBJ.Objects[i]);
                  if not DifficultyOk(TheObject.Diff) then continue;

                  if TheObject.Sec <> -1 then
                   begin
                    TheSector := TSector(MAP_SEC.Objects[TheObject.Sec]);
                    TheLayer  := TheSector.Layer;
                   end
                  else
                   TheLayer := 9999;

                  if (TheLayer = LAYER) or (TheLayer = 9999) then
                   begin
                    Pen.Color := TheObject.Col;
                    if IsPtVisible(TheObject.X, TheObject.Z) then
                    if TheObject.Special = 1 then {GENERATOR : draw a 'G'}
                     begin
                      MoveTo(M2SX(TheObject.X)+Dimension, M2SZ(TheObject.Z)-Dimension);
                      LineTo(M2SX(TheObject.X)-Dimension, M2SZ(TheObject.Z)-Dimension);
                      LineTo(M2SX(TheObject.X)-Dimension, M2SZ(TheObject.Z)+Dimension);
                      LineTo(M2SX(TheObject.X)+Dimension, M2SZ(TheObject.Z)+Dimension);
                      LineTo(M2SX(TheObject.X)+Dimension, M2SZ(TheObject.Z));
                      LineTo(M2SX(TheObject.X), M2SZ(TheObject.Z));
                     end
                    else
                    if TheObject.ClassName = 'FRAME' then
                    Ellipse(M2SX(TheObject.X)-Dimension, M2SZ(TheObject.Z)-Dimension,
                            M2SX(TheObject.X)+Dimension, M2SZ(TheObject.Z)+Dimension)
                    else
                    if TheObject.ClassName = 'SPRITE' then
                    Rectangle(M2SX(TheObject.X)-Dimension, M2SZ(TheObject.Z)-Dimension,
                              M2SX(TheObject.X)+Dimension, M2SZ(TheObject.Z)+Dimension)
                    else
                    if TheObject.ClassName = '3D' then
                     begin
                      MoveTo(M2SX(TheObject.X)-Dimension, M2SZ(TheObject.Z)+Dimension);
                      LineTo(M2SX(TheObject.X)+Dimension, M2SZ(TheObject.Z)+Dimension);
                      LineTo(M2SX(TheObject.X)+Dimension, M2SZ(TheObject.Z)-Dimension);
                      LineTo(M2SX(TheObject.X)-Dimension, M2SZ(TheObject.Z)-Dimension);
                      MoveTo(M2SX(TheObject.X), M2SZ(TheObject.Z));
                      LineTo(M2SX(TheObject.X)+Dimension, M2SZ(TheObject.Z));
                     end
                    else
                    if TheObject.ClassName = 'SAFE' then
                     begin
                      MoveTo(M2SX(TheObject.X)+Dimension, M2SZ(TheObject.Z)-Dimension);
                      LineTo(M2SX(TheObject.X)-Dimension, M2SZ(TheObject.Z)-Dimension);
                      LineTo(M2SX(TheObject.X)-Dimension, M2SZ(TheObject.Z));
                      LineTo(M2SX(TheObject.X)+Dimension, M2SZ(TheObject.Z));
                      LineTo(M2SX(TheObject.X)+Dimension, M2SZ(TheObject.Z)+Dimension);
                      LineTo(M2SX(TheObject.X)-Dimension, M2SZ(TheObject.Z)+Dimension);
                     end
                    else
                    if TheObject.ClassName = 'SOUND' then
                     begin
                      MoveTo(M2SX(TheObject.X)-Dimension, M2SZ(TheObject.Z)-Dimension);
                      LineTo(M2SX(TheObject.X), M2SZ(TheObject.Z)+Dimension);
                      LineTo(M2SX(TheObject.X)+Dimension, M2SZ(TheObject.Z)-Dimension);
                     end
                    else
                    if TheObject.ClassName = 'SPIRIT' then
                     begin
                      MoveTo(M2SX(TheObject.X)-Dimension, M2SZ(TheObject.Z)-Dimension);
                      LineTo(M2SX(TheObject.X)+Dimension, M2SZ(TheObject.Z)+Dimension);
                      MoveTo(M2SX(TheObject.X)-Dimension, M2SZ(TheObject.Z)+Dimension);
                      LineTo(M2SX(TheObject.X)+Dimension, M2SZ(TheObject.Z)-Dimension);
                     end
                    else
                    Ellipse(M2SX(TheObject.X)-Dimension, M2SZ(TheObject.Z)-Dimension,
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

procedure TMapWindow.WDFUSESupportDiscordClick(Sender: TObject);
var url : string;
begin
  url := 'https://discord.com/invite/6T9NvMh2MC';
  ShellExecute(HInstance, 'open', PChar(url), nil, nil, SW_NORMAL);
end;

procedure TMapWindow.WMSize(var Msg: TWMSize);
begin
  inherited;

  if LEVELloaded then
    begin
      ScreenX          := Map.Width;
      ScreenZ          := Map.Height;
      ScreenCenterX    := Map.Width div 2;
      ScreenCenterZ    := Map.Height div 2;
      MAP_RECT.Left    := 0;
      MAP_RECT.Right   := Map.Width;
      MAP_RECT.Top     := 0;
      MAP_RECT.Bottom  := Map.Height;
      Map.Invalidate;
    end;
end;

procedure TMapWindow.FormCreate(Sender: TObject);
var OldCursor : HCursor;
    IniName   : TFileName;
    i, cnt    : Integer;
    section   : String;
begin
  Log.Info('Initializing Mapper', LogName);
  Application.OnIdle := AppIdle;

  ShortCutProc := MapWindow.OnShortCut;

  OldCursor  := SetCursor(LoadCursor(0, IDC_WAIT));
  WDFUSEdir  := Copy(ExtractFilePath(ParamStr(0)),1, Length(ExtractFilePath(ParamStr(0)))-1);

  if NO_INI then
    showmessage('Welcome to WDFUSE ' + WDFUSE_VERSION +  EOL +
    'Please press F12 to see all the hotkeys' + EOL +
    'Visit https://df-21.net Discord for any questions');


  IniName    := ExtractFilePath(ParamStr(0)) + 'wdfuse.ini';
  Ini        := TIniFile.Create(IniName);
  Log.Info('WDFUSE Dir = ' + WDFUSEdir, LogName);

  { Write these here so that the INI file is in correct order   }
  Section := 'WDFUSE';
  Ini.WriteString(Section, 'Prog Name', 'DFUSE for WINDOWS ');
  Ini.WriteString(Section, 'Prog Vers', WDFUSE_VERSION);
  Ini.WriteString(Section, 'Copyright', '(c) Y.Borckmans,A.Novikov,D.Lovejoy,J.Kok,F Krueger 1995-1997, Karjala 2021');
  Ini.WriteString(Section, 'HomePage', 'https://df-21.net');

  Ini.WriteString('DARK FORCES', 'Copyright', '(c) LucasArts Entertainment Company 1994');

  { Actual Ini Reading }
  Section := 'DARK FORCES';
  DarkInst   := Ini.ReadString(Section, 'Installed', 'c:\dark');
  RenderInst := Ini.ReadString(Section, 'RenderPath', 'c:\dfrender');
  DarkCD     := Ini.ReadString(Section, 'CD_Letter', 'd');

  Log.Info('Dark Inst  = ' + DarkInst, LogName);
  Log.Info('Render Inst = ' + RenderInst, LogName);

  DOSBOX_PATH   := Ini.ReadString('DARK FORCES', 'DOSBOX_PATH', '');
  DOSBOX_CONF   := Ini.ReadString('DARK FORCES', 'DOSBOX_CONF', '');
  LAUNCHER_TYPE := Ini.ReadString('DARK FORCES', 'LAUNCHER_TYPE', '');
  LOADPREVPRJ   := Ini.ReadBool('DARK FORCES', 'LOADPREVPRJ', TRUE);
  UNDO_LIMIT    := Ini.ReadInteger('DARK FORCES', 'UNDO_LIMIT', 32);

  PROJECTFile   := Ini.ReadString(Section,  'PROJECTFile', '');
  Log.Info('WDFUSE Version  = ' + WDFUSE_VERSION, LogName);
  Log.Info('DOSBOX PATH  = ' + DOSBOX_PATH, LogName);
  Log.Info('DOSBOX_CONF  = ' + DOSBOX_CONF, LogName);
  Log.Info('LAUNCHER_TYPE  = ' + LAUNCHER_TYPE, LogName);
  Log.Info('LOADPREVPRJ  = ' + BoolToStr(LOADPREVPRJ), LogName);
  Log.Info('PROJECTFile  = ' + PROJECTFile, LogName);

  Section := 'TOOLS';
  INFEditor  := Ini.ReadString(Section,   'INF Editor', '');
  Voc2Wav    := Ini.ReadString(Section,   'VOC2WAV', '');
  Wav2Voc    := Ini.ReadString(Section,   'WAV2VOC', '');

  TestLaunch := Ini.ReadBool('TESTING', 'Launch DF', TRUE);
  Backup_Method := Ini.ReadInteger('BACKUP',  'Method',  0);


  Section := 'CONFIRM';
  CONFIRMMultiDelete  := Ini.ReadBool(Section, 'MultiDelete', TRUE);
  CONFIRMMultiUpdate  := Ini.ReadBool(Section, 'MultiUpdate', TRUE);
  CONFIRMMultiInsert  := Ini.ReadBool(Section, 'MultiInsert', TRUE);
  CONFIRMSectorDelete := Ini.ReadBool(Section, 'SectorDelete', TRUE);
  CONFIRMWallDelete   := Ini.ReadBool(Section, 'WallDelete', TRUE);
  CONFIRMVertexDelete := Ini.ReadBool(Section, 'VertexDelete', TRUE);
  CONFIRMObjectDelete := Ini.ReadBool(Section, 'ObjectDelete', TRUE);
  CONFIRMWallSplit    := Ini.ReadBool(Section, 'WallSplit', TRUE);
  CONFIRMWallExtrude  := Ini.ReadBool(Section, 'WallExtrude', TRUE);

  Section := 'MAP-COLORS';
  col_back         := Ini.ReadInteger(Section,  'back',      Ccol_back);
  PanelMapALL.Color := col_back;
  col_wall_n       := Ini.ReadInteger(Section,  'wall_n',    Ccol_wall_n);
  col_wall_a       := Ini.ReadInteger(Section,  'wall_a',    Ccol_wall_a);
  col_shadow       := Ini.ReadInteger(Section,  'shadow',    Ccol_shadow);
  col_grid         := Ini.ReadInteger(Section,  'grid',      Ccol_grid);
  col_select       := Ini.ReadInteger(Section,  'select',    Ccol_select);
  col_multis       := Ini.ReadInteger(Section,  'multis',    Ccol_multis);
  col_elev         := Ini.ReadInteger(Section,  'elev',      Ccol_elev);
  col_trig         := Ini.ReadInteger(Section,  'trig',      Ccol_trig);
  col_goal         := Ini.ReadInteger(Section,  'goal',      Ccol_goal);
  col_secr         := Ini.ReadInteger(Section,  'secr',      Ccol_secr);

  col_dm_low       := Ini.ReadInteger(Section,  'dm_low',    Ccol_dm_low);
  col_dm_high      := Ini.ReadInteger(Section,  'dm_high',   Ccol_dm_high);
  col_dm_gas       := Ini.ReadInteger(Section,  'dm_gas',    Ccol_dm_gas);
  col_2a_water     := Ini.ReadInteger(Section,  '2a_water',  Ccol_2a_water);
  col_2a_catwlk    := Ini.ReadInteger(Section,  '2a_catwlk', Ccol_2a_catwlk);
  col_sp_sky       := Ini.ReadInteger(Section,  'sp_sky',    Ccol_sp_sky);
  col_sp_pit       := Ini.ReadInteger(Section,  'sp_pit',    Ccol_sp_pit);
  col_sec_inner    := Ini.ReadInteger(Section,  'sec_in',    Ccol_sec_inner);

  Section := 'FINE TUNING';
  FastSCROLL       := Ini.ReadBool(Section,     'FastScroll',  TRUE);
  {Keep it always fast
  FastDRAG         := Ini.ReadBool(Section,     'FastDrag',    TRUE);}
  FastDRAG         := TRUE;

  SHADOW           := Ini.ReadBool(Section,     'LAYER_SHADOW', TRUE);

  UsePlusVX        := Ini.ReadBool(Section,     'UsePlusVX',     CUsePlusVX);
  UsePlusOBShad    := Ini.ReadBool(Section,     'UsePlusOBShad', CUsePlusOBShad);
  SpecialsVX       := Ini.ReadBool(Section,     'SpecialsVX',    CSpecialsVX);
  SpecialsOB       := Ini.ReadBool(Section,     'SpecialsOB',    CSpecialsOB);

  vx_scale         := Ini.ReadInteger(Section,  'vx_scale',      Cvx_scale);
  vx_dim_max       := Ini.ReadInteger(Section,  'vx_dim_max',    Cvx_dim_max);
  bigvx_scale      := Ini.ReadInteger(Section,  'bigvx_scale',   Cbigvx_scale);
  bigvx_dim_max    := Ini.ReadInteger(Section,  'bigvx_dim_max', Cbigvx_dim_max);

  ob_scale         := Ini.ReadInteger(Section,  'ob_scale',      Cob_scale);
  ob_dim_max       := Ini.ReadInteger(Section,  'ob_dim_max',    Cob_dim_max);
  bigob_scale      := Ini.ReadInteger(Section,  'bigob_scale',   Cbigob_scale);
  bigob_dim_max    := Ini.ReadInteger(Section,  'bigob_dim_max', Cbigob_dim_max);


  // Haha... no (Karjala 2021).
  StrPCopy(NOT_REG, 'Too many sectors or objects for the **UNREGISTERED** WDFUSE. Project NOT saved!!');

  Section := 'REGISTRATION';
  USERname         := Ini.ReadString(Section, 'Name',  '');
  USERemail        := Ini.ReadString(Section, 'email', '');
  USERreg          := Ini.ReadString(Section, 'Reg',   '**UNREGISTERED**');

  GOB_History      := TStringList.Create;
  cnt              := Ini.ReadInteger('GOB HISTORY', 'Count', 0);
  for i := 1 to cnt do
   begin
    GOB_History.Add(Ini.ReadString('GOB HISTORY', IntToStr(i), ''));
   end;

  LFD_History      := TStringList.Create;
  cnt              := Ini.ReadInteger('LFD HISTORY', 'Count', 0);
  for i := 1 to cnt do
   begin
    LFD_History.Add(Ini.ReadString('LFD HISTORY', IntToStr(i), ''));
   end;

  PAL_History      := TStringList.Create;
  cnt              := Ini.ReadInteger('PAL HISTORY', 'Count', 0);
  for i := 1 to cnt do
   begin
    PAL_History.Add(Ini.ReadString('PAL HISTORY', IntToStr(i), ''));
   end;

  PLT_History      := TStringList.Create;
  cnt              := Ini.ReadInteger('PLT HISTORY', 'Count', 0);
  for i := 1 to cnt do
   begin
    PLT_History.Add(Ini.ReadString('PLT HISTORY', IntToStr(i), ''));
   end;

  _VGA_MULTIPLIER  := Ini.ReadInteger('CONTRAST', 'VGA_MULTIPLIER', 4);

  Section := 'WINDOWS';
  MapWindow.Left   := Ini.ReadInteger(Section, 'WDFUSE Mapper  X', 0);
  MapWindow.Top    := Ini.ReadInteger(Section, 'WDFUSE Mapper  Y', 72);
  MapWindow.Width  := Ini.ReadInteger(Section, 'WDFUSE Mapper  W', 1280);
  MapWindow.Height := Ini.ReadInteger(Section, 'WDFUSE Mapper  H', 800);

  TBMain.Checked   := Ini.ReadBool('TOOLBARS', 'Main', TRUE);
  TBTools.Checked  := Ini.ReadBool('TOOLBARS', 'Tools', TRUE);

  ToolbarMain.Visible := TBMain.Checked;
  ToolbarTools.Visible := TBTools.Checked;


  GOBText  := Ini.ReadBool('TEXTBOX ', 'GOB', FALSE);
  LFDText  := Ini.ReadBool('TEXTBOX ', 'LFD', FALSE);

  LEVELloaded      := FALSE;
  ChkCmdLine       := TRUE;

  ZoomInLock         := FALSE;
  ZoomOutLock        := FALSE;

  MAP_SEC_CLIP     := TStringList.Create;
  MAP_OBJ_CLIP     := TStringList.Create;

  for i := -9 to 9 do SHADOW_LAYERS[i] := TRUE;
  SetCursor(OldCursor);
  MapWindow.Caption := 'WDFUSE ' +  WDFUSE_VERSION;

  // set the shadow colors
  SHADOW := not SHADOW;
  DO_Layer_OnOff;

  Log.Info('Done Initializing Mapper', LogName);
end;


procedure TMapWindow.FormClose(Sender: TObject; var Action: TCloseAction);
var i         : Integer;
    section   : String;
begin
  Log.Info('Exiting Mapper...', LogName);
  Do_FreeGeometryClip;
  Do_FreeObjectsClip;

  {SAVE Data to INI}
  Section := 'GOB HISTORY';
  Ini.EraseSection(Section);
  if GOB_History.Count > 20 then {limit history to 20}
   Ini.WriteInteger(Section, 'Count', 20)
  else
   Ini.WriteInteger(Section, 'Count', GOB_History.Count);
  if GOB_History.Count <> 0 then
   for i := 0 to GOB_History.Count - 1 do
    begin
     if i < 20 then {limit history to 20}
      Ini.WriteString(Section, IntToStr(i+1), GOB_History[i]);
    end;
  GOB_History.Free;

  Section := 'LFD HISTORY';
  Ini.EraseSection(Section);
  if LFD_History.Count > 20 then {limit history to 20}
   Ini.WriteInteger(Section, 'Count', 20)
  else
   Ini.WriteInteger(Section, 'Count', LFD_History.Count);
  if LFD_History.Count <> 0 then
   for i := 0 to LFD_History.Count - 1 do
    begin
     if i < 20 then {limit history to 20}
      Ini.WriteString(Section, IntToStr(i+1), LFD_History[i]);
    end;
  LFD_History.Free;

  Section := 'PAL HISTORY';
  Ini.EraseSection(Section);
  if PAL_History.Count > 20 then {limit history to 20}
   Ini.WriteInteger(Section, 'Count', 20)
  else
   Ini.WriteInteger(Section, 'Count', PAL_History.Count);
  if PAL_History.Count <> 0 then
   for i := 0 to PAL_History.Count - 1 do
    begin
     if i < 20 then {limit history to 20}
      Ini.WriteString(Section, IntToStr(i+1), PAL_History[i]);
    end;
  PAL_History.Free;

  Section := 'PLT HISTORY';
  Ini.EraseSection(Section);
  if PLT_History.Count > 20 then {limit history to 20}
   Ini.WriteInteger(Section, 'Count', 20)
  else
   Ini.WriteInteger(Section, 'Count', PLT_History.Count);
  if PLT_History.Count <> 0 then
   for i := 0 to PLT_History.Count - 1 do
    begin
     if i < 20 then {limit history to 20}
      Ini.WriteString(Section, IntToStr(i+1), PLT_History[i]);
    end;
  PLT_History.Free;

  Ini.WriteInteger('CONTRAST', 'VGA_MULTIPLIER', _VGA_MULTIPLIER);

  Section := 'WINDOWS';
  Ini.WriteInteger(Section, 'WDFUSE Mapper  X', MapWindow.Left);
  Ini.WriteInteger(Section, 'WDFUSE Mapper  Y', MapWindow.Top);
  Ini.WriteInteger(Section, 'WDFUSE Mapper  W', MapWindow.Width);
  Ini.WriteInteger(Section, 'WDFUSE Mapper  H', MapWindow.Height);

  Ini.WriteBool('TOOLBARS', 'Main', TBMain.Checked);
  Ini.WriteBool('TOOLBARS', 'Tools', TBTools.Checked);

  Ini.WriteBool('TEXTBOX',  'GOB', GOBText);
  Ini.WriteBool('TEXTBOX',  'LFD', LFDText);

  Ini.Free;

  SC_MULTIS.Free;
  VX_MULTIS.Free;
  WL_MULTIS.Free;
  OB_MULTIS.Free;

  WinHelp(MapWindow.Handle, 'WDFUSE.HLP', HELP_QUIT, 0);
  Log.Info('Exiting WDFUSE', LogName);
end;

procedure TMapWindow.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if LEVELLoaded and MODIFIED then
   begin
    CASE Application.MessageBox('Level has been modified. Do you want to SAVE ?',
                                 'WDFUSE Mapper - Exit Mapper',
                                 mb_YesNoCancel or mb_IconQuestion) OF
     idYes    : begin
                 if MaySave then
                  begin
                   Do_SaveProject;
                   FreeLevel;
                   CanClose := TRUE;
                  end
                 else
                  CanClose := FALSE;
                end;
     idNo     : begin
                 FreeLevel;
                 CanClose := TRUE;
                end;
     idCancel : CanClose := FALSE;
    END;
   end
  else
   begin
    if LEVELLoaded then FreeLevel;
    CanClose := TRUE;
   end;
end;

procedure TMapWindow.DO_OpenProjectShell;
begin
  if LEVELLoaded and MODIFIED then
   begin
    CASE Application.MessageBox('Level has been modified. Do you want to SAVE ?',
                                 'WDFUSE Mapper - Open Project',
                                 mb_YesNoCancel or mb_IconQuestion) OF
     idYes    : begin
                 if MaySave then
                  begin
                   Do_SaveProject;
                   DO_OpenProject;
                  end;
                end;
     idNo     : begin
                 DO_OpenProject;
                end;
     idCancel : ;
    END;
   end
  else
   begin
    DO_OpenProject;
   end;
end;

procedure TMapWindow.SpeedButtonOpenClick(Sender: TObject);
begin
 DO_OpenProjectShell;
end;

procedure TMapWindow.DO_NewProjectShell;
begin
   if LEVELLoaded and MODIFIED then
   begin
    CASE Application.MessageBox('Level has been modified. Do you want to SAVE ?',
                                 'WDFUSE Mapper - New Project',
                                 mb_YesNoCancel or mb_IconQuestion) OF
     idYes    : begin
                 if MaySave then
                  begin
                   Do_SaveProject;
                   NewProjectDialog.ShowModal;
                  end;
                end;
     idNo     : begin
                 NewProjectDialog.ShowModal;
                end;
     idCancel : ;
    END;
   end
  else
   begin
    NewProjectDialog.ShowModal;
   end;
end;

procedure TMapWindow.SpeedButtonNewProjectClick(Sender: TObject);
begin
 DO_NewProjectShell;
end;

{ This is incredibly hacky but this enables/disables shortcuts
  when you are not focused on the MapWindow form. This means that
  when you type code in a text field the shortcuts are disabled
  but when you are back to the main window they are restored by
  the ShortCutProc variable - Karjala}
procedure TMapWindow.FormActivate(Sender: TObject);
begin
  KeyPreview := TRUE;
  Application.OnHint := DisplayHint;
  MapWindow.OnShortCut := ShortCutProc;
  EditAdjoin.ShortCut := TextToShortCut('A');
  EditExtrude.ShortCut := TextToShortCut('E');
  EditCopy.ShortCut := TextToShortCut('Ctrl+C');
  EditPaste.ShortCut := TextToShortCut('Ctrl+V');
  EditUndo.ShortCut := TextToShortCut('Ctrl+Z');
  EditRedo.ShortCut := TextToShortCut('Ctrl+Y');
  EditNext.ShortCut := TextToShortCut('N');
  EditPrevious.ShortCut := TextToShortCut('P');
  EditClearMultiselect.ShortCut := TextToShortCut('BkSp');
  CenterMapDefaultNumPad1.ShortCut := TextToShortCut('/');
  CenteronSelectionX1.ShortCut := TextToShortCut('X');
  MapCenter.ShortCut := TextToShortCut('C');
  ModeSectors.ShortCut := TextToShortCut('S');
  ModeWalls.ShortCut := TextToShortCut('W');
  ModeVertices.ShortCut := TextToShortCut('V');
  ModeObjects.ShortCut := TextToShortCut('O');
  MapZoomIn.ShortCut := TextToShortCut('Num+');
  MapZoomOut.ShortCut := TextToShortCut('Num-');
  MapZoomNone.ShortCut := TextToShortCut('Num*');
  Tools3DOConverter.ShortCut := TextToShortCut('Shift+D');
  ToolsVUEEditor.ShortCut := TextToShortCut('Shift+V');
  ToolsExternalTools.ShortCut := TextToShortCut('Shift+E');
  ViewEditorGOL.ShortCut := TextToShortcut('Shift+I');
  MapGrid8.ShortCut := TextToShortcut('Shift+G');
end;

procedure TMapWindow.FormDeactivate(Sender: TObject);
begin
  ShortCutProc := MapWindow.OnShortCut;
  MapWindow.OnShortCut := Nil;
  EditAdjoin.ShortCut := TextToShortCut('');
  EditExtrude.ShortCut := TextToShortCut('');
  EditCopy.ShortCut := TextToShortCut('');
  EditPaste.ShortCut := TextToShortCut('');
  EditUndo.ShortCut := TextToShortCut('');
  EditRedo.ShortCut := TextToShortCut('');
  EditNext.ShortCut := TextToShortCut('');
  EditPrevious.ShortCut := TextToShortCut('');
  EditClearMultiselect.ShortCut := TextToShortCut('');
  CenterMapDefaultNumPad1.ShortCut := TextToShortCut('');
  CenteronSelectionX1.ShortCut := TextToShortCut('');
  MapCenter.ShortCut := TextToShortCut('');
  ModeSectors.ShortCut := TextToShortCut('');
  ModeWalls.ShortCut := TextToShortCut('');
  ModeVertices.ShortCut := TextToShortCut('');
  ModeObjects.ShortCut := TextToShortCut('');
  MapZoomIn.ShortCut := TextToShortCut('');
  MapZoomOut.ShortCut := TextToShortCut('');
  MapZoomNone.ShortCut := TextToShortCut('');
  Tools3DOConverter.ShortCut := TextToShortCut('');
  ToolsVUEEditor.ShortCut := TextToShortCut('');
  ToolsExternalTools.ShortCut := TextToShortCut('');
  ViewEditorGOL.ShortCut := TextToShortcut('');
  MapGrid8.ShortCut := TextToShortcut('');
end;



procedure TMapWindow.SpeedButtonAboutClick(Sender: TObject);
begin
  Application.CreateForm(TAboutBox, AboutBox);
  AboutBox.ShowModal;
  AboutBox.Destroy;
end;

procedure TMapWindow.SpeedButtonDF21Click(Sender: TObject);
begin
  Application.CreateForm(TAboutBox, AboutBox);
  AboutBox.LogoClick(NIL);
end;


procedure TMapWindow.SpeedButtonExitClick(Sender: TObject);
begin
  MapWindow.Close;
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

procedure TMapWindow.SpeedButtonGridOnOffClick(Sender: TObject);
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
  DO_Grid_8;
end;

{ Use this to ignore all shortcuts except on KeyUp
  This preservces the pretty formatting in the Menus }
procedure TMapWindow.FormShortCut(var Msg: TWMKey;
  var Handled: Boolean);
begin
   Handled := TRUE;
end;

procedure TMapWindow.FreeUndoListClick(Sender: TObject);
begin
  DO_FreeUndo;
end;

function GetCharFromVKey(vkey: Word): string;
var
  keystate: TKeyboardState;
  retcode: Integer;
begin
  Win32Check(GetKeyboardState(keystate));
  SetLength(Result, 2);
  retcode := ToAscii(vkey,
    MapVirtualKey(vkey, 0),
    keystate, @Result[1],
    0);
  case retcode of
    0: Result := ''; // no character
    1: SetLength(Result, 1);
    2:;
    else
      Result := ''; // retcode < 0 indicates a dead key
  end;
end;

procedure TMapWindow.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var adjoins : Integer;
    ThePoint : TPoint;
    MapPoint : TPoint;
    px, pz   : real;
    TheObject: TOB;
    m        : Integer;
    i        : Integer;
    prompt   : Boolean;
begin
 if LEVELLoaded then
  begin
    Log.Info('Typed Key [' + ShortCutToText(ShortCut(key, Shift)) + ']', LogName);
    if Shift = [] then

    Case Key of
      VK_TAB    : begin
                    CASE MAP_MODE of
                      MM_SC : begin
                               SectorEditor.Show;
                               SectorEditor.SCEd.Row := 0;
                               SectorEditor.SCEd.SetFocus;
                              end;
                      MM_WL : begin
                               WallEditor.Show;
                               WallEditor.WLEd.Row := 0;
                               WallEditor.WLEd.SetFocus;
                               end;
                      MM_VX : begin
                                VertexEditor.Show;
                                VertexEditor.VXEd.Row := 0;
                                VertexEditor.VXEd.SetFocus;
                              end;
                      MM_OB : begin
                               ObjectEditor.Show;
                               ObjectEditor.OBEd.Row := 0;
                               ObjectEditor.OBEd.SetFocus;
                              end;
                     END;
                   end;
      VK_SPACE   : begin
                     // Wrapper for space as it behaves differently
                     MULTISEL_SPC := TRUE;
                     CASE MAP_MODE of
                      MM_SC : DO_MultiSel_SC(SC_HILITE);
                      MM_WL : DO_MultiSel_WL(SC_HILITE, WL_HILITE);
                      MM_VX : DO_MultiSel_VX(SC_HILITE, VX_HILITE);
                      MM_OB : DO_MultiSel_OB(OB_HILITE);
                     END;
                     CASE MAP_MODE of
                      MM_SC : DO_Fill_SectorEditor;
                      MM_WL : DO_Fill_WallEditor;
                      MM_VX : DO_Fill_VertexEditor;
                      MM_OB : begin
                               DO_Fill_ObjectEditor;
                               MapWindow.Map.Invalidate;
                              end;
                     END;
                     MULTISEL_SPC := FALSE;
                   end;
      VK_BACK    : DO_Clear_MultiSel;
      VK_PRIOR   : DO_Layer_Up;
      VK_NEXT    : DO_Layer_Down;
      VK_LEFT    : DO_Scroll_Left;
      VK_UP      : DO_Scroll_Up;
      VK_RIGHT   : DO_Scroll_Right;
      VK_DOWN    : DO_Scroll_Down;
      $41 {VK_A} : EditAdjoinClick(Nil);
      $42 {VK_B} : ;//DO_ApplyUndo(True);
      $43 {VK_C} : DO_Center_On_Cursor;
      $44 {VK_D} : begin
                    ToolsWindow.ToolsNotebook.PageIndex := 4;
                    SpeedButtonToolsClick(NIL);
                   end;
      $45 {VK_E} : EditExtrudeClick(Nil);
      $46 {VK_F} : CASE MAP_MODE of
                    MM_SC : DO_Find_SC_By_Name;
                    MM_WL : DO_Find_WL_Adjoin;
                    MM_VX : DO_Find_VX_AtSameCoords;
                    MM_OB : DO_Find_PlayerStart;
                   END;
      $47 {VK_G} : DO_Grid_OnOff;
      $48 {VG_H} : SpeedButtonLevelClick(NIL);
      $49 {VK_I} : SpeedButtonINFClick(NIL);
      $4B {VK_K} : DO_Polygon;
                   {DEU compatibility}
      $4C {VK_L} : SpeedButtonLVLClick(NIL);
      $4D {VK_M} : SpeedButtonMSGClick(NIL);
      $4E {VK_N} : EditNextClick(Nil);
      $4F {VK_O} : DO_Switch_To_OB_Mode;
      $50 {VK_P} : EditPreviousClick(NIL);
      $51 {VK_Q} : SpeedButtonQueryClick(NIL);
      $52 {VK_R} : begin
                    if not Renderer.Visible then Renderer.InitRenderer;
                    GetCursorPos(ThePoint);
                    MapPoint := MapWindow.Map.ScreenToClient(ThePoint);
                    px := S2MX(MapPoint.X);
                    pz := S2MZ(MapPoint.Y);
                    GetNearestGridPoint(S2MX(MapPoint.X),S2MZ(MapPoint.Y), px, pz);
                    Renderer.SetCamera(px, pz, 6.5, -0.0001);
                    Renderer.CreateLists;
                    {Renderer.Invalidate;}
                    Renderer.Show;
                   end;
      $53 {VK_S} : DO_Switch_To_SC_Mode;
                   {DEU compatibility}
      $54 {VK_T} : SpeedButtonTXTClick(NIL);
      $55 {VK_U} : if MAP_MODE = MM_WL then SuperStitch(SC_HILITE, WL_HILITE, 0, 0);
      $56 {VK_V} : DO_Switch_To_VX_Mode;
      $57 {VK_W} : DO_Switch_To_WL_Mode;
      $58 {VK_X} : DO_Center_On_CurrentObject;
      $59 {VK_Y} : if MAP_MODE = MM_WL then SuperStitch(SC_HILITE, WL_HILITE, 0, 1);
      $5A {VK_Z} : ;//DO_ApplyUndo;
      VK_ADD     : DO_Zoom_In;
      VK_SUBTRACT: DO_Zoom_Out;
      VK_MULTIPLY: DO_Zoom_None;
      VK_DIVIDE  : DO_Center_Map;
      VK_DELETE  : CASE MAP_MODE of
                    MM_SC : ShellDeleteSC;
                    MM_WL : if WL_MULTIS.Count <> 0 then
                              begin
                                { Don't prompt for every wall - only Once }
                                prompt := CONFIRMWallDelete;
                                Do_StoreUndo;
                                WL_MULTIS.CustomSort(@SortVX);
                                IGNORE_UNDO := True;
                                if CONFIRMWallDelete = True then
                                  begin
                                    CONFIRMWallDelete := False;
                                    if Application.MessageBox('Confirm Multi Wall DELETE ?',
                                                              'WDFUSE Mapper - Delete Wall',
                                                               mb_YesNo or mb_IconQuestion) = idNo
                                      then exit;
                                  end;
                                for i := 0 to WL_MULTIS.count-1 do
                                  begin
                                    ShellDeleteWL(StrToInt(Copy(WL_MULTIS[i],1,4)),
                                                  StrToInt(Copy(WL_MULTIS[i],5,4)));
                                  end;
                                WL_MULTIS.Clear;
                                IGNORE_UNDO := False;
                                CONFIRMWallDelete := prompt;
                               end
                             else
                                ShellDeleteWL(SC_HILITE, WL_HILITE);
                    MM_VX : if VX_MULTIS.count <> 0 then
                              begin
                                { Don't prompt for every vertex - only Once }
                                prompt := CONFIRMWallDelete;
                                Do_StoreUndo;
                                VX_MULTIS.CustomSort(@SortVX);
                                IGNORE_UNDO := True;
                                if CONFIRMWallDelete = True then
                                  begin
                                    CONFIRMWallDelete := False;
                                    if Application.MessageBox('Confirm Multi Vertex DELETE ?',
                                                              'WDFUSE Mapper - Delete Vertex',
                                                               mb_YesNo or mb_IconQuestion) = idNo
                                      then exit;
                                  end;
                                for i := 0 to VX_MULTIS.count-1 do
                                  begin
                                    ShellDeleteVX(StrToInt(Copy(VX_MULTIS[i],1,4)),
                                                  StrToInt(Copy(VX_MULTIS[i],5,4)));
                                  end;
                                VX_MULTIS.Clear;
                                IGNORE_UNDO := False;
                                CONFIRMWallDelete := prompt;
                              end
                             else
                              ShellDeleteVX(SC_HILITE, VX_HILITE);

                    MM_OB : ShellDeleteOB;
                   END;
      VK_INSERT  : begin
                    {Compute cursor position. If grid is on, must paste on a grid point!}
                    DO_StoreUndo;
                    GetCursorPos(ThePoint);
                    MapPoint := MapWindow.Map.ScreenToClient(ThePoint);
                    px := S2MX(MapPoint.X);
                    pz := S2MZ(MapPoint.Y);
                    GetNearestGridPoint(S2MX(MapPoint.X),S2MZ(MapPoint.Y), px, pz);
                    CASE MAP_MODE of
                     MM_SC : ShellInsertSC(px, pz);
                     MM_WL : if WL_MULTIS.Count <> 0 then
                              ShowMessage('Cannot Split Multiple Walls !')
                             else
                              ShellSplitWL(SC_HILITE, WL_HILITE);
                     MM_VX : if VX_MULTIS.Count <> 0 then
                              ShowMessage('Cannot Split Multiple Vertices !')
                             else
                              ShellSplitVX(SC_HILITE, VX_HILITE);
                     MM_OB : ShellInsertOB(px, pz);
                    END;
                   end;
      { too annoying !    <--- HAHA - Karjala 2021
      VK_ESCAPE  : MapWindow.Close;
      }

      // These are now also globally defined regardless of level load  (Scroll Down)
      VK_F1      : HelpTutorialClick(NIL);
      VK_F2      : ;
      VK_F3      : ToolsGOBFileManagerClick(NIL);
                  {if SC_MULTIS.Count > 1 then
                    DO_Distribute(TRUE, 2, FALSE)
                   else
                    ShowMessage('You must have a Sector multiselection !');}
      VK_F4      : ToolsLFDFileManagerClick(NIL);
                  {if WL_MULTIS.Count > 1 then
                    begin
                     Do_StoreUndo;
                     IGNORE_UNDO := True;
                     DO_StitchHorizontal(TRUE, TRUE, TRUE);
                     DO_StitchVertical(TRUE, TRUE, TRUE);
                     IGNORE_UNDO := False;
                    end
                   else
                    ShowMessage('You must have a Wall multiselection !');}
      VK_F5      : ToolsLogFilePathClick(NIL);
                  {if WL_MULTIS.Count > 1 then
                    DO_StitchHorizontal(TRUE, FALSE, FALSE)
                   else
                    ShowMessage('You must have a Wall multiselection !');}
      VK_F6      : ToolsToolkitClick(NIL);
                  {if WL_MULTIS.Count > 1 then
                    DO_StitchHorizontalInvert(TRUE, FALSE, FALSE)
                   else
                    ShowMessage('You must have a Wall multiselection !'); }
      VK_F7      : SpeedButton3DPreviewClick(NIL);
                  {if WL_MULTIS.Count > 1 then
                    DO_StitchVertical(TRUE, FALSE, FALSE)
                   else
                    ShowMessage('You must have a Wall multiselection !');}
      VK_F8      : SpeedButtonToolsClick(Nil);
      VK_F9      : SpeedButtonOptionsClick(NIL);
      VK_F10     : DO_ConsistencyChecks;
      VK_F11     : ;{DEBUG_UNDO;}
      VK_F12     : SpeedButtonMapKeyClick(NIL);
      VK_NUMPAD0 : DIFFAllClick(ODAll);
      VK_NUMPAD1 : DIFFAllClick(ODEasy);
      VK_NUMPAD2 : DIFFAllClick(ODMed);
      VK_NUMPAD3 : DIFFAllClick(ODHard);
      $31 {VK_1} : DO_Goto_Marker(0);
      $32 {VK_2} : DO_Goto_Marker(1);
      $33 {VK_3} : DO_Goto_Marker(2);
      $34 {VK_4} : DO_Goto_Marker(3);
      $35 {VK_5} : DO_Goto_Marker(4);
    end;

    if Shift = [ssShift] then
    Case Key of
      VK_RETURN  : begin
                   end;
      $41 {VK_A} : CASE MAP_MODE of
                    MM_SC : ;
                    MM_WL : begin
                             Do_StoreUndo;
                             IGNORE_UNDO := True;
                             if MakeLayerAdjoin(SC_HILITE, WL_HILITE) then
                              adjoins := 1
                             else
                              adjoins := 0;
                             adjoins := adjoins + MultiMakeAdjoin;
                             DO_Fill_WallEditor;
                             PanelText.Caption := IntToStr(adjoins) + ' ADJOIN(S) MADE';
                             IGNORE_UNDO := False;
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
      $44 {VK_D} : SpeedButton3DOClick(NIL);
      $45 {VK_E} : SpeedButtonXToolsClick(NIL);
      $46 {VK_F} : FastSCROLL := not FastSCROLL;
      $47 {VK_G} : DO_Grid_8;
      $49 {VK_I} : SpeedButtonGOLClick(NIL);
      $4C {VK_L} : CASE MAP_MODE of
                    MM_SC : ;
                    MM_WL : ;
                    MM_VX : ;
                    MM_OB : begin
                             if ForceLayerObject(OB_HILITE) then
                              adjoins := 1
                             else
                              adjoins := 0;
                             adjoins := adjoins + MultiForceLayerObject;
                             DO_Fill_ObjectEditor;
                             PanelText.Caption := IntToStr(adjoins) + ' OBJECT(S) LAYERED';
                            end;
                   END;
      $4D {VK_M} : ;
      $4E {VK_N} : ;

{Shift+R complete renderer exists only in WDFUSE 32}
{$IFDEF WDF32}
      $52 {VK_R} : begin
                    if not ZRenderer.Visible then ZRenderer.InitRenderer;
                    GetCursorPos(ThePoint);
                    MapPoint := MapWindow.Map.ScreenToClient(ThePoint);
                    px := S2MX(MapPoint.X);
                    pz := S2MZ(MapPoint.Y);
                    GetNearestGridPoint(S2MX(MapPoint.X),S2MZ(MapPoint.Y), px, pz);
                    ZRenderer.SetCamera(px, pz, 6.5, -0.0001);
                    ZRenderer.CreateLists;
                    {ZRenderer.Invalidate;}
                    ZRenderer.Show;
                   end;
{$ENDIF}

      $53 {VK_S} : ;
      $56 {VK_V} : SpeedButtonVueClick(NIL);
      $58 {VK_X} : begin
                    DO_Center_On_CurrentObject;
                    DO_Zoom_In;
                    DO_Zoom_In;
                    DO_Zoom_In;
                    DO_Zoom_In;
                   end;
      VK_F5      : if WL_MULTIS.Count > 1 then
                    DO_StitchHorizontal(TRUE, TRUE, TRUE)
                   else
                    ShowMessage('You must have a Wall multiselection !');
      VK_F6      : if WL_MULTIS.Count > 1 then
                    DO_StitchHorizontalInvert(TRUE, TRUE, TRUE)
                   else
                    ShowMessage('You must have a Wall multiselection !');
      VK_F7      : if WL_MULTIS.Count > 1 then
                    DO_StitchVertical(TRUE, TRUE, TRUE)
                   else
                    ShowMessage('You must have a Wall multiselection !');
      VK_F8      : if SC_MULTIS.Count > 1 then
                    DO_Distribute(FALSE, 0, TRUE)
                   else
                    ShowMessage('You must have a Sector multiselection !');
    end;

    if Shift = [ssCtrl] then
    Case Key of
      VK_RETURN  : begin
                   end;
      VK_LEFT    : DO_Scroll_LeftLeft;
      VK_UP      : DO_Scroll_UpUp;
      VK_RIGHT   : DO_Scroll_RightRight;
      VK_DOWN    : DO_Scroll_DownDown;
      $31 {VK_1} : DO_Set_Marker(0);
      $32 {VK_2} : DO_Set_Marker(1);
      $33 {VK_3} : DO_Set_Marker(2);
      $34 {VK_4} : DO_Set_Marker(3);
      $35 {VK_5} : DO_Set_Marker(4);
      $41 {VK_A} : ;
      $43 {VK_C} : CASE MAP_MODE OF
                    MM_SC : DO_CopyGeometry;
                    MM_OB : DO_CopyObjects;
                   END;
      $44 {VK_D} : ;
      $46 {VK_F} : FastDRAG := not FastDRAG;
      $47 {VK_G} : GOB_Test_Level;
      $49 {VK_I} : ToolsWindow.BNRereadINFClick(NIL);
      $4B {VK_K} : IF MAP_MODE = MM_SC THEN DO_CloseSector(SC_HILITE);
      $4C {VK_L} : CASE MAP_MODE of
                    MM_SC : ;
                    MM_WL : ;
                    MM_VX : ;
                    MM_OB : begin
                             case OBLAYERMODE of
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
                             end;
                            end;
                   END;
      $4D {VK_M} : ;
      $4E {VK_N} : DO_NewProjectShell;
      $4F {VK_O} : DO_OpenProjectShell;
      $50 {VK_P} : begin
                    GetCursorPos(ThePoint);
                    MapPoint := MapWindow.Map.ScreenToClient(ThePoint);
                    px := S2MX(MapPoint.X);
                    pz := S2MZ(MapPoint.Y);
                    GetNearestGridPoint(S2MX(MapPoint.X),S2MZ(MapPoint.Y), px, pz);
                    INFWindow2.EDElevCenterX.Text := Format('%5.2f', [px]);
                    INFWindow2.EDElevCenterZ.Text := Format('%5.2f', [pz]);
                   end;
      $51 {VK_Q} : MapWindow.Close;
      $53 {VK_S} : if MaySave then DO_SaveProject;
      $54 {VK_T} : TestWindow.Show;
      $56 {VK_V} : begin
                    GetCursorPos(ThePoint);
                    MapPoint := MapWindow.Map.ScreenToClient(ThePoint);
                    {if grid is on, must paste on a grid point!}
                    px := S2MX(MapPoint.X);
                    pz := S2MZ(MapPoint.Y);
                    GetNearestGridPoint(S2MX(MapPoint.X),S2MZ(MapPoint.Y), px, pz);
                    EditPasteClick(Sender);
                  end;
      $59 {VK_Y} : DO_ApplyUndo(True);
      $5A {VK_Z} : DO_ApplyUndo;
      VK_F5      : if WL_MULTIS.Count > 1 then
                    DO_StitchHorizontal(FALSE, FALSE, TRUE)
                   else
                    ShowMessage('You must have a Wall multiselection !');
      VK_F6      : if WL_MULTIS.Count > 1 then
                    DO_StitchHorizontalInvert(FALSE, FALSE, TRUE)
                   else
                    ShowMessage('You must have a Wall multiselection !');
      VK_F7      : if WL_MULTIS.Count > 1 then
                    DO_StitchVertical(FALSE, FALSE, TRUE)
                   else
                    ShowMessage('You must have a Wall multiselection !');
      VK_F8      : if SC_MULTIS.Count > 1 then
                    DO_Distribute(TRUE, 1, FALSE)
                   else
                    ShowMessage('You must have a Sector multiselection !');
    end;

   if Shift = [ssAlt] then
    Case Key of
      VK_RETURN  : begin
                   end;
      $41 {VK_A} : EditUnadjoinClick(NIL);
      $43 {VK_C} : SpeedButtonStatClick(NIL);
      $44 {VK_D} : begin
                    ToolsWindow.ToolsNotebook.PageIndex := 5;
                    SpeedButtonToolsClick(NIL);
                   end;
      $4B {VK_K} : ;
      $4D {VK_M} : ;
      $4E {VK_N} : ;
      $4F {VK_O} : DO_OBShadow_OnOff;
      $53 {VK_S} : DO_Layer_OnOff;
      $5A {VK_x} : DO_ApplyUndo(True);
      VK_F5      : if WL_MULTIS.Count > 1 then
                    DO_StitchHorizontal(FALSE, TRUE, FALSE)
                   else
                    ShowMessage('You must have a Wall multiselection !');
      VK_F6      : if WL_MULTIS.Count > 1 then
                    DO_StitchHorizontalInvert(FALSE, TRUE, FALSE)
                   else
                    ShowMessage('You must have a Wall multiselection !');
      VK_F7      : if WL_MULTIS.Count > 1 then
                    DO_StitchVertical(FALSE, TRUE, FALSE)
                   else
                    ShowMessage('You must have a Wall multiselection !');
      VK_F8      : if SC_MULTIS.Count > 1 then
                    DO_Distribute(TRUE, 0, FALSE)
                   else
                    ShowMessage('You must have a Sector multiselection !');
    end;
  end
  else
    begin
      //Special Case when you don't have the map loaded
      if Shift = [ssCtrl] then
        Case Key of
          $4E {VK_N} : DO_NewProjectShell;
          $4F {VK_O} : DO_OpenProjectShell;
          $51 {VK_Q} : MapWindow.Close;
        end;
      // F keys that should be acciessble from anywhere
      if Shift = [] then
        Case Key of
          VK_F1      : HelpTutorialClick(NIL);
          VK_F3      : ToolsGOBFileManagerClick(NIL);
          VK_F4      : ToolsLFDFileManagerClick(NIL);
          VK_F5      : ToolsLogFilePathClick(NIL);
          VK_F6      : ToolsToolkitClick(NIL);
          VK_F9      : SpeedButtonOptionsClick(NIL);
          VK_F12     : SpeedButtonMapKeyClick(NIL);
      End;
    end;
end;

procedure TMapWindow.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
var now : Integer;
begin
  if Handled or not LEVELloaded  then exit;
  Handled := True;

  //Throttling mousewheel to prevent multi-grid draw
  now := GetTickCount ;
  if (now - ZoomTimer) < 25 then exit;
  ZoomTimer := now;

  if Shift = [ssCtrl] then
    DO_Grid_Out;
  if Shift = [] then
    DO_Zoom_Out;
  if Shift = [ssShift] then
    DO_Layer_Down;
end;

procedure TMapWindow.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
  var now : Integer;
begin
  if Handled or not LEVELloaded  then exit;
  Handled := True;

  //Throttling mousewheel to prevent multi-grid draw
  now := GetTickCount ;
  if (now - ZoomTimer) < 25 then exit;
  ZoomTimer := now;

  if Shift = [ssCtrl] then
    DO_Grid_In;
  if Shift = [] then
    DO_Zoom_In;
  if Shift = [ssShift] then
    DO_Layer_Up;
end;

procedure TMapWindow.SpeedButtonCenterMapClick(Sender: TObject);
begin
  DO_Center_Map;
end;

procedure TMapWindow.SpeedButtonCenterCursor(Sender: TObject);
begin
  DO_Center_On_Cursor;
end;

procedure TMapWindow.SpeedButtonCenterSelection(Sender: TObject);
begin
  DO_Center_On_CurrentObject
end;

procedure TMapWindow.SpeedButtonStatClick(Sender: TObject);
begin
  Application.CreateForm(TStatWindow, StatWindow);
  StatWindow.ShowModal;
  StatWindow.Destroy;
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
       DO_Select_In_Rect;
       case MAP_MODE of
          MM_SC :   DO_Fill_SectorEditor;
          MM_WL :   DO_Fill_WallEditor;
          MM_VX :   DO_Fill_VertexEditor;
          MM_OB :   DO_Fill_ObjectEditor;
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
       if FastDRAG then MapWindow.Map.Invalidate;
       case MAP_MODE of
          MM_SC :   DO_Fill_SectorEditor;
          MM_WL :   DO_Fill_WallEditor;
          MM_VX :   DO_Fill_VertexEditor;
          MM_OB :   begin
                     TheObject := TOB(MAP_OBJ.Objects[OB_HILITE]);
                     TheObject.Sec := -1; {why ?}
                     ForceLayerObject(OB_HILITE);
                     if OB_MULTIS.Count > 0 then
                      begin
                       for m := 0 to OB_MULTIS.Count - 1 do
                        begin
                         TheObject := TOB(MAP_OBJ.Objects[StrToInt(Copy(OB_MULTIS[m],5,4))]);
                         TheObject.Sec := -1; {why ?}
                        end;
                       MultiForceLayerObject;
                      end;
                     DO_Fill_ObjectEditor;
                    end;
       end;
      END
     ELSE
      BEGIN

       // preserve original highlights
       SC_HILITE_ORG := SC_HILITE;
       WL_HILITE_ORG := WL_HILITE;
       VX_HILITE_ORG := VX_HILITE;
       OB_HILITE_ORG := OB_HILITE;

       if Shift = [] then
          case MAP_MODE of
          MM_SC : if GetNearestSC(S2MX(X), S2MZ(Y), SC_HILITE) then
                   begin
                    DO_Fill_SectorEditor;
                    MapWindow.Map.Invalidate;
                   end;
          MM_WL : if GetNearestWL(S2MX(X), S2MZ(Y), SC_HILITE, WL_HILITE) then
                   begin
                    DO_Fill_WallEditor;
                    MapWindow.Map.Invalidate;
                   end;
          MM_VX : if GetNearestVX(S2MX(X), S2MZ(Y), SC_HILITE, VX_HILITE) then
                   begin
                    DO_Fill_VertexEditor;
                    MapWindow.Map.Invalidate;
                   end;
          MM_OB : if GetNearestOB(S2MX(X), S2MZ(Y), OB_HILITE) then
                   begin
                    DO_Fill_ObjectEditor;
                    MapWindow.Map.Invalidate;
                   end;
        end;

       if Shift = [ssCtrl] + [ssShift] then
        case MAP_MODE of
          MM_SC : ;
          MM_WL : ;
          MM_VX : if GetNextNearestVX(S2MX(X), S2MZ(Y), SC_HILITE, VX_HILITE) then
                   begin
                    DO_Fill_VertexEditor;
                    MapWindow.Map.Invalidate;
                   end;
          MM_OB : ;
        end;

       if Shift = [ssShift] then
        case MAP_MODE of
          MM_SC : if GetNearestSC(S2MX(X), S2MZ(Y), SC_HILITE) then
                   begin
                    DO_MultiSel_SC(SC_HILITE);
                    DO_Fill_SectorEditor;
                    MapWindow.Map.Invalidate;
                   end;
          MM_WL : if GetNearestWL(S2MX(X), S2MZ(Y), SC_HILITE, WL_HILITE) then
                   begin
                    DO_MultiSel_WL(SC_HILITE, WL_HILITE);
                    DO_Fill_WallEditor;
                    MapWindow.Map.Invalidate;
                   end;
          MM_VX : if GetNearestVX(S2MX(X), S2MZ(Y), SC_HILITE, VX_HILITE) then
                   begin
                    DO_MultiSel_VX(SC_HILITE, VX_HILITE);
                    DO_Fill_VertexEditor;
                    MapWindow.Map.Invalidate;
                   end;
          MM_OB : if GetNearestOB(S2MX(X), S2MZ(Y), OB_HILITE) then
                   begin
                    DO_MultiSel_OB(OB_HILITE);
                    DO_Fill_ObjectEditor;
                    MapWindow.Map.Invalidate;
                   end;
        end;
     END; {not dragging}

    { Disables Fill when panning }
    if firstdrag then
      begin
       firstdrag := False;
       MapWindow.Map.Invalidate;
      end;
   END; {left button}
 END; {level loaded}

end;

procedure TMapWindow.MapMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ORIGIN.X  := X;
  ORIGIN.Y  := Y;
  XOffsetStart := Xoffset;
  ZOffsetStart := Zoffset;
  FirstDRAG := True;

end;

procedure TMapWindow.MapMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var rx, rz    : Real;
    dx, dz    : Real;
    vx, vz    : Real;
    a,b       : Real;
    TheVertex : TVertex;
    TheSector : TSector;
    TheWall   : TWall;
    TheObject : TOB;
    s,v       : Integer;
    TestRect  : TRect;
    panXOffset, panYOffset : Integer;
    tempPt, sp: TPoint;
begin
 {
  RESUME MOUSE MOVE

  Ctrl   => Drag (eventuellement avec Grid)
  C+S    => Drag on Nearest VX/OB
  Alt    => Create Rectangle for Multiselection
 }

  // This code is to figure out the X/Y offsets of your monitor for menu clicking.
  // This is because the mouse position cursor is different when you move over a menu
  GetCursorPos(tempPt);
  sp := screentoclient(tempPt);

  // Calculate the vertical Y bars offsets
  // Do not need to calculate Menu X because the map window is the same size as wdfuse
  MenuYOffset := sp.Y - y;

  MoveXOffset := tempPt.x - sp.x;
  MoveYOffset := tempPt.Y - sp.Y;

  s := 0;
  v := 0;

  if LEVELLoaded then
    begin
      try
        PanelX.Caption := Format('%5.2f', [S2MX(X)]);
        PanelZ.Caption := Format('%5.2f', [S2MZ(Y)]);
        if (Shift = [ssCtrl] + [ssLeft]) or (Shift = [ssCtrl] + [ssShift] + [ssLeft]) then
         begin
           IsDRAG := TRUE;
           if FirstDRAG then
            DO_StoreUndo;
           case MAP_MODE of
            MM_SC : begin
                     TheSector := TSector(MAP_SEC.Objects[SC_HILITE]);
                     TheVertex := TVertex(TheSector.Vx.Objects[0]);
                     rx        := TheVertex.X;
                     rz        := TheVertex.Z;
                    end;
            MM_WL : begin
                     TheSector := TSector(MAP_SEC.Objects[SC_HILITE]);
                     TheWall   := TWall(TheSector.Wl.Objects[WL_HILITE]);
                     TheVertex := TVertex(TheSector.Vx.Objects[TheWall.left_vx]);
                     rx        := TheVertex.X;
                     rz        := TheVertex.Z;
                    end;
            MM_VX : begin
                     TheSector := TSector(MAP_SEC.Objects[SC_HILITE]);
                     TheVertex := TVertex(TheSector.Vx.Objects[VX_HILITE]);
                     rx        := TheVertex.X;
                     rz        := TheVertex.Z;
                    end;
            MM_OB : begin
                     TheObject := TOB(MAP_OBJ.Objects[OB_HILITE]);
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
                       GetNearestVX(S2MX(X), S2MZ(Y), s, v);
                       if {s <> SC_HILITE} TRUE then
                        begin
                         TheSector := TSector(MAP_SEC.Objects[s]);
                         TheVertex := TVertex(TheSector.Vx.Objects[v]);
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
                         ORIGIN.X := Trunc(M2SX(vx));
                         ORIGIN.Y := Trunc(M2SZ(vz));
                         {update the window}
                         if FastDRAG then
                         begin
                           DO_DrawMultiSel(TRUE);
                           DO_DrawSelection(TRUE);
                          end
                         else
                          MapWindow.Map.Invalidate;
                        end;
                      end;
               MM_OB :
                      begin
                       GetNearestOB(S2MX(X), S2MZ(Y), s);
                       if s <> OB_HILITE then
                        begin
                         TheObject := TOB(MAP_OBJ.Objects[s]);
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
                         ORIGIN.X := Trunc(M2SX(vx));
                         ORIGIN.Y := Trunc(M2SZ(vz));
                         {update the window}
                         if FastDRAG then
                          begin
                           DO_DrawMultiSel(TRUE);
                           DO_DrawSelection(TRUE);
                          end
                         else
                          MapWindow.Map.Invalidate;
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
              MapWindow.Map.Invalidate;
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
             GetNearestGridPoint(rx+S2MX(X)-S2MX(ORIGIN.X), rz+S2MZ(Y)-S2MZ(ORIGIN.Y),
                                 dx, dz);
             DO_Translate_SelMultiSel(dx-rx, dz-rz);
             {prepare next displacement}
             ORIGIN.X := Trunc(M2SX(dx));
             ORIGIN.Y := Trunc(M2SZ(dz));
             {update the window}
             if FastDRAG then
              begin
               DO_DrawMultiSel(TRUE);
               DO_DrawSelection(TRUE);
              end
             else
              MapWindow.Map.Invalidate;
             {
             if ((dx - rx) <> 0) or ((dz - rz) <> 0) then
               MapWindow.Map.Invalidate;
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

         { PANNING }

         if (Shift = [ssLeft]) then
          begin

           { Calculate X , Y offsets for panning including scale damping }
           panXOffset := Trunc(Abs(Origin.X-X)/scale);
           panYOffset := Trunc(Abs(Origin.Y-Y)/scale);

           { Right, Left, Up, Down }
           if Origin.X > X then
             MapWindow.SetXOffset(XOffsetStart + panXOffset);
           if Origin.X < X then
             MapWindow.SetXOffset(XOffsetStart - panXOffset);
           if Origin.Y < Y then
             MapWindow.SetZOffset(ZOffsetStart + panYOffset);
           if Origin.Y > Y then
             MapWindow.SetZOffset(ZOffsetStart - panYOffset);
           MapWindow.Map.Invalidate;
          end;
       except on E: Exception do
        begin
             Log.error('Failed to Move Mouse! ' + E.ClassName +
             ' error raised, with message : '+E.Message, LogName);
            showmessage('Failed to Move Mouse! ' + E.ClassName + EOL +
             ' error raised, with message : '+E.Message);
        end;
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
  OptionsDialog.ShowModal;
  if OptionsDialog.ModalResult = mrOk then
    DO_CheckTheGobs;
end;

procedure TMapWindow.SpeedButtonSaveClick(Sender: TObject);
begin
 if MaySave then DO_SaveProject;
end;

procedure TMapWindow.SpeedButtonPLTEditClick(Sender: TObject);
begin
  CNV_edit.ShowModal;
end;

procedure TMapWindow.SpeedButtonGOBTestClick(Sender: TObject);
begin
  GOB_Test_Level;
end;

procedure TMapWindow.SpeedButton3DPreviewClick(Sender: TObject);
begin
  Preview_3D_Level;
end;

procedure TMapWindow.SpeedButtonToolsClick(Sender: TObject);
begin
 ToolsWindow.Show;
end;

procedure TMapWindow.MapPopupPopup(Sender: TObject);
begin
 if LEVELLoaded then
  begin
   PopupNew.Visible     := FALSE;
   PopupOpen.Visible    := FALSE;
   PopupDelete.Visible  := TRUE;
   PopupFind.Visible    := TRUE;
   PopupS1.Visible      := TRUE;
   PopupS2.Visible      := TRUE;
   PopUpUndo.Visible    := TRUE;
   PopUpRedo.Visible    := TRUE;
   PopupCopy.Visible    := TRUE;
   PopupPaste.Visible   := TRUE;
   if MAP_MODE = MM_WL then
    begin

     PopupDuplicate.Visible := False;
     PopupCopy.Visible     := FALSE;
     PopupSplit.Visible    := TRUE;
     if WallEditor.WLEd.Cells[1,0] = '-1' then
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
      end;
    end
   else
    begin
     PopupDuplicate.Visible := True;
     PopupSplit.Visible    := FALSE;
     PopupExtrude.Visible  := FALSE;
     PopupAdjoin.Visible   := FALSE;
     PopupUnAdjoin.Visible := FALSE;
    end
  end
 else
  begin
     PopupNew.Visible       := TRUE;
     PopupOpen.Visible      := TRUE;
     PopupDuplicate.Visible := TRUE;
     PopupCopy.Visible      := FALSE;
     PopupPaste.Visible     := FALSE;
     PopUpUndo.Visible      := FALSE;
     PopUpRedo.Visible      := FALSE;
     PopupSplit.Visible     := FALSE;
     PopupExtrude.Visible   := FALSE;
     PopupAdjoin.Visible    := FALSE;
     PopupUnAdjoin.Visible  := FALSE;
     PopupDelete.Visible    := FALSE;
     PopupFind.Visible      := FALSE;
     PopupS1.Visible        := FALSE;
     PopupS2.Visible        := FALSE;
  end;
end;

procedure TMapWindow.MenuSubToollClick(Sender: TObject);
begin

 if (Sender=MenuSubToolGeneral) then
  ToolsWindow.ToolsNotebook.PageIndex := 0;
 if (Sender=MenuSubToolStitch) then
  ToolsWindow.ToolsNotebook.PageIndex := 1;
 if (Sender=MenuSubToolDistribute) then
  ToolsWindow.ToolsNotebook.PageIndex := 2;
 if (Sender=MenuSubToolPolygon) then
  ToolsWindow.ToolsNotebook.PageIndex := 3;
 if (Sender=MenuSubToolDeform) then
  ToolsWindow.ToolsNotebook.PageIndex := 4;
 if (Sender=MenuSubToolOffset) then
  ToolsWindow.ToolsNotebook.PageIndex := 5;
 if (Sender=MenuSubToolFlip) then
  ToolsWindow.ToolsNotebook.PageIndex := 6;
 SpeedButtonToolsClick(NIL);
end;

procedure TMapWindow.PopupNewClick(Sender: TObject);
begin
  if Sender = PopupDuplicate then
  begin
   CASE MAP_MODE of
    MM_SC : ShellInsertSC(-100000.0,-100000.0);
    MM_WL : ;
    MM_VX : ShellSplitVX(SC_HILITE, VX_HILITE);
    MM_OB : ShellInsertOB(-100000.0,-100000.0);
   END;
  end;

 if Sender = PopupSplit then
  begin
   ShellSplitWL(SC_HILITE, WL_HILITE);
  end;

 if Sender = PopupExtrude then
  begin
   ShellExtrudeWL(SC_HILITE, WL_HILITE);
  end;

 if Sender = PopupAdjoin then
  begin
   MakeAdjoin(SC_HILITE, WL_HILITE);
   MultiMakeAdjoin;
   DO_Fill_WallEditor;
  end;

 if Sender = PopupUnAdjoin then
  begin
   UnAdjoin(SC_HILITE, WL_HILITE);
   MultiUnAdjoin;
   DO_Fill_WallEditor;
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

 if Sender = PopupFind then
  begin
   CASE MAP_MODE of
    MM_SC : DO_Find_SC_By_Name;
    MM_WL : DO_Find_WL_Adjoin;
    MM_VX : DO_Find_VX_AtSameCoords;
    MM_OB : DO_Find_PlayerStart;
   END;
  end;
end;

procedure TMapWindow.PopUpRedoClick(Sender: TObject);
begin
  Do_ApplyUndo(True);
end;

procedure TMapWindow.PopUpUndoClick(Sender: TObject);
begin
  Do_ApplyUndo;
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

if (Sender=DIFFAll) or (Sender=ODAll)  then
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
MapWindow.Map.Invalidate;
end;

procedure TMapWindow.NormalMapClick(Sender: TObject);
begin
 NormalMap.Checked := FALSE;
 LightsMap.Checked := FALSE;
 DamageMap.Checked := FALSE;
 SecAltitudesMap.Checked := FALSE;
 SkiesPitsMap.Checked := FALSE;
 SectorFill.Checked := FALSE;

 MMNormal.Checked := FALSE;
 MMLight.Checked := FALSE;
 MMDamage.Checked := FALSE;
 MM2ndAltitudes.Checked := FALSE;
 MMSkiesPits.Checked := FALSE;
 MMSectorFill.Checked := FALSE;

 if (Sender=NormalMap)       or (Sender=MMNormal) then
  DO_SetMAP_TYPENormal;
 if (Sender=LightsMap)       or (Sender=MMLight) then
  DO_SetMAP_TYPELight;
 if (Sender=DamageMap)       or (Sender=MMDamage) then
  DO_SetMAP_TYPEDamage;
 if (Sender=SecAltitudesMap) or (Sender=MM2ndAltitudes) then
  DO_SetMAP_TYPE2ndAltitude;
 if (Sender=SkiesPitsMap)    or (Sender=MMSkiesPits) then
  DO_SetMAP_TYPESkyPit;
 if (Sender=SectorFill)    or (Sender=MMSectorFill) then
  DO_SetMap_TYPESectorFill;
end;

procedure TMapWindow.PanelOBLayerClick(Sender: TObject);
begin
 DO_OBShadow_OnOff;
end;



procedure TMapWindow.SpeedButtonXToolsClick(Sender: TObject);
begin
 TMPHWindow := GetFocus; {security}
 Application.CreateForm(TExtToolsWindow, ExtToolsWindow);
 ExtToolsWindow.ShowModal;
 if ExtToolsWindow.ModalResult = mrOk then
  WinProcs.SetActiveWindow(TMPHWindow);
 ExtToolsWindow.Destroy;
end;


procedure HandleCommandLine;
begin
 if ParamCount = 1 then
   BEGIN
    if UpperCase(ExtractFileExt(ParamStr(1))) = '.WDP' then
     begin
      PROJECTFile := ParamStr(1);
      {map window must be shown, or stuff in DO_LoadLevel won't execute}
      MapWindow.Show;
      DO_LoadLevel;
      BACKUPED := FALSE;
     end;

    if UpperCase(ExtractFileExt(ParamStr(1))) = '.GOB' then
    BEGIN
     Application.CreateForm(TGOBWindow, GOBWindow);
     with GobWindow do
       begin
        GOBBrowseGOB.FileName := ParamStr(1);
        GOBBrowseGOB.InitialDir := ExtractFilePath(ParamStr(1));
        CASE GOB_GetDirList(ParamStr(1) , GOBDirList) OF
          0 : begin
               CurrentGOB := ParamStr(1);
               PanelGOBName.Caption    := ExtractFileName(ParamStr(1));
               PanelGOBEntries.Caption := IntTOStr(GOBDirList.Items.Count);
               PanelGOBName.Hint  := ParamStr(1) + ' | Name of the currently selected GOB file';
               GOBDelete.Enabled  := TRUE;
               GOBInfo.Enabled    := TRUE;
               GOBAdd.Enabled     := TRUE;
               GOBExtract.Enabled := TRUE;
               GOBRemove.Enabled  := TRUE;
               GOBWindow.ShowModal;
              end;
         -1 : Application.MessageBox('File does not exist', 'GOB File Manager Error', mb_Ok or mb_IconExclamation);
         -2 : Application.MessageBox('File is not a GOB file', 'GOB File Manager Error', mb_Ok or mb_IconExclamation);
        END;
       end;
      GOBWindow.Destroy;
      MapWindow.Close;
     END;

    if UpperCase(ExtractFileExt(ParamStr(1))) = '.LFD' then
     BEGIN
     Application.CreateForm(TLFDWindow, LFDWindow);
     with LfdWindow do
       begin
        LFDBrowseLFD.FileName := ParamStr(1);
        LFDBrowseLFD.InitialDir := ExtractFilePath(ParamStr(1));
        CASE LFD_GetDirList(ParamStr(1) , LFDDirList) OF
          0 : begin
               CurrentLFD := ParamStr(1);
               PanelLFDName.Caption    := ExtractFileName(ParamStr(1));
               PanelLFDEntries.Caption := IntTOStr(LFDDirList.Items.Count);
               PanelLFDName.Hint  := ParamStr(1) + ' | Name of the currently selected LFD file';
               LFDDelete.Enabled  := TRUE;
               LFDInfo.Enabled    := TRUE;
               LFDAdd.Enabled     := TRUE;
               LFDExtract.Enabled := TRUE;
               LFDRemove.Enabled  := TRUE;
               LFDWindow.ShowModal;
              end;
         -1 : Application.MessageBox('File does not exist', 'LFD File Manager Error', mb_Ok or mb_IconExclamation);
         -2 : Application.MessageBox('File is not a LFD file', 'LFD File Manager Error', mb_Ok or mb_IconExclamation);
        END;
       end;
      LFDWindow.Destroy;
      MapWindow.Close;
     END;

   END;

 if ParamCount > 1 then
   Application.MessageBox('WDFUSE handles only ONE file at a time',
                 'WDFUSE Error', mb_Ok or mb_IconExclamation);
end;






function IsRegistered : Boolean;
var bidon    : LongInt;
    reg1,
    reg2     : LongInt;
    i        : Integer;
begin
  Bidon  := 1;

  if USERreg = '' then {was <>}
   begin
    if (USERname = '') or (Length(USERname) < 6) or (Length(USERreg) <> 10) then
     Result := TRUE {was FALSE}
    else
     begin
      {check registration}
      {set Result to TRUE if registered !}
      reg1 := Bidon * Byte(USERname[1]) * Byte(USERname[2]) * Byte(USERname[3])+
              Bidon * Byte(USERname[4]) * Byte(USERname[5]) * Byte(USERname[6])+
              10000;
      for i := 1 to Length(USERname) do reg1 := reg1 + Byte(Username[i]);
      reg1 := reg1 mod 99997;

      reg2 := Bidon * Byte(USERname[1]) * Byte(USERname[3]) * Byte(USERname[5])+
              Bidon * Byte(USERname[2]) * Byte(USERname[4]) * Byte(USERname[6])+
              10000;
      for i := 2 to Length(USERname) do reg2 := reg2 + Byte(Username[i]);
      reg2 := reg2 mod 99993;

      if Format('%-5.5d%-5.5d', [reg1, reg2]) <> USERreg then
       Result := FALSE
      else
       Result := TRUE;
     end;
   end
  else
   Result := TRUE;  {WAS FALSE}

end;

function MaySave      : Boolean;
begin
  if IsRegistered then
   Result := TRUE
  else
   begin
    if (MAP_SEC.Count <= (num1 + num3)) and (MAP_OBJ.Count <= (num2*2)) then
     Result := TRUE
    else
     begin
      Application.MessageBox(NOT_REG, 'WDFUSE', mb_Ok);
      result := FALSE;
     end;
   end;

end;

procedure TMapWindow.SpeedButtonChecksClick(Sender: TObject);
begin
 DO_ConsistencyChecks;
end;

procedure TMapWindow.SpeedButtonLevelClick(Sender: TObject);
begin
 Application.CreateForm(TLevelEditorWindow, LevelEditorWindow);

 with LevelEditorWindow do
  begin
   ED_LEV_VERSION.Text   := LEV_VERSION;
   ED_LEV_LEVELNAME.Text := LEV_LEVELNAME;
   ED_LEV_PALETTE.Text   := LEV_PALETTE;
   ED_LEV_MUSIC.Text     := LEV_MUSIC;
   ED_LEV_PARALLAX1.Text := Format('%9.4f', [LEV_PARALLAX1]);
   ED_LEV_PARALLAX2.Text := Format('%9.4f', [LEV_PARALLAX2]);
   ED_O_VERSION.Text     := O_VERSION;
   ED_O_LEVELNAME.Text   := O_LEVELNAME;
   ED_INF_VERSION.Text   := INF_VERSION;
   ED_INF_LEVELNAME.Text := INF_LEVELNAME;
   ShowModal;
  end;

 LevelEditorWindow.Destroy;
end;

procedure TMapWindow.PanelMapTypeClick(Sender: TObject);
begin
 NormalMap.Checked := FALSE;
 LightsMap.Checked := FALSE;
 DamageMap.Checked := FALSE;
 SecAltitudesMap.Checked := FALSE;
 SkiesPitsMap.Checked := FALSE;
 SectorFill.Checked := FALSE;

 MMNormal.Checked := FALSE;
 MMLight.Checked := FALSE;
 MMDamage.Checked := FALSE;
 MM2ndAltitudes.Checked := FALSE;
 MMSkiesPits.Checked := FALSE;
 MMSectorFill.Checked := FALSE;

 case MAP_TYPE of
  MT_NO : DO_SetMAP_TYPELight;
  MT_LI : DO_SetMAP_TYPEDamage;
  MT_DM : DO_SetMAP_TYPE2ndAltitude;
  MT_2A : DO_SetMAP_TYPESkyPit;
  MT_SP : DO_SetMap_TYPESectorFill;
  MT_SF : DO_SetMAP_TYPENormal;
 end;
end;

procedure TMapWindow.SpeedButtonQueryClick(Sender: TObject);
begin
if MAP_MODE <> MM_VX then
 begin
  Application.CreateForm(TQueryWindow, QueryWindow);
  QueryWindow.ShowModal;
  QueryWindow.Destroy;
 end
else
 Application.MessageBox('Query is not allowed in Vertex Mode!',
                        'WDFUSE - Query',
                        mb_Ok or mb_IconExclamation);
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


procedure TMapWindow.ToolsGOBFileManagerClick(Sender: TObject);
begin
 Application.CreateForm(TGOBWindow, GOBWindow);
 GOBWindow.ShowModal;
 GOBWindow.Destroy;
 Application.OnHint := DisplayHint;
end;

procedure TMapWindow.ToolsLFDFileManagerClick(Sender: TObject);
begin
 Application.CreateForm(TLFDWindow, LFDWindow);
 LFDWindow.ShowModal;
 LFDWindow.Destroy;
 Application.OnHint := DisplayHint;
end;

procedure TMapWindow.ToolsLogFolderClick(Sender: TObject);
begin
   if not UseLog then
    begin
      showmessage('Logs are not being written. Please go to Options (F9) and change the logging settings');
      exit;
    end;

  if not DirectoryExists(LogPath) then
    begin
      showmessage('The Log Directory ' + LogPath + ' does not exist!');
      exit;
    end;

  ShellExecute(0, 'open', 'explorer.exe', PChar('select,"' + LogPath + '"'), nil, SW_NORMAL);
end;

procedure TMapWindow.ToolsToolkitClick(Sender: TObject);
begin
 Application.CreateForm(TTktWindow, TktWindow);
 TktWindow.ShowModal;
 TktWindow.Destroy;
 Application.OnHint := DisplayHint;
end;

procedure TMapWindow.HScrollBarScroll(Sender: TObject;
  ScrollCode: TScrollCode; var ScrollPos: Integer);
begin
 if ScrollCode = scEndScroll then exit;
 XOffset := ScrollPos;
 MapWindow.Map.Invalidate;
end;

procedure TMapWindow.ToolsLogFilePathClick(Sender: TObject);
var INFProgram : string;
begin
  if not UseLog then
    begin
      showmessage('Logs are not being written. Please go to Options (F9) and change the logging settings');
      exit;
    end;

  if not DirectoryExists(LogPath) then
    begin
      showmessage('The Log Directory ' + LogPath + ' does not exist!');
      exit;
    end;

  if not FileExists(LogFilePath) then
    begin
      showmessage('The Log ' + Logname + ' is missing from ' + EOL + LogPath + ' folder!');
      exit;
    end;
  if INFEditor <> '' then
    INFProgram := INFEditor
  else
    INFProgram := 'notepad.exe';

  ShellExecute(0, 'open', PChar(INFProgram),
    PChar('"' + LogFilePath + '"'), nil, SW_NORMAL);
end;

procedure TMapWindow.VScrollBarScroll(Sender: TObject;
  ScrollCode: TScrollCode; var ScrollPos: Integer);
begin
 if ScrollCode = scEndScroll then exit;
 ZOffset := -ScrollPos;
 MapWindow.Map.Invalidate;
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

   try
    if XOff < MapWindow.HScrollBar.Min then
     MapWindow.HScrollBar.Min := XOff;

    if XOff > MapWindow.HScrollBar.Max then
     MapWindow.HScrollBar.Max := XOff;
   

    MapWindow.HScrollBar.Position := XOff;
  except on E: Exception do
       begin         
          log.Error('Failed to apply horizontal scroll position at ' + inttostr(xoff), logname );
       end;
  end;  
  
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

  try
   
    if -ZOffset < MapWindow.VScrollBar.Min then
     MapWindow.VScrollBar.Min := -ZOff;

    if -ZOffset > MapWindow.VScrollBar.Max then
     MapWindow.VScrollBar.Max := -ZOff;

  
      MapWindow.VScrollBar.Position := -ZOff;
  except on E: Exception do
       begin         
          log.Error('Failed to apply vertical scroll position at ' + inttostr(zoff), logname );
       end;
  end;
  
  ZOffset := ZOff;
  Result  := TRUE;
end;

procedure TMapWindow.SM1Click(Sender: TObject);
begin
 if (Sender = SM1) then DO_Set_Marker(0);
 if (Sender = SM2) then DO_Set_Marker(1);
 if (Sender = SM3) then DO_Set_Marker(2);
 if (Sender = SM4) then DO_Set_Marker(3);
 if (Sender = SM5) then DO_Set_Marker(4);

 if (Sender = GM1) then DO_Goto_Marker(0);
 if (Sender = GM2) then DO_Goto_Marker(1);
 if (Sender = GM3) then DO_Goto_Marker(2);
 if (Sender = GM4) then DO_Goto_Marker(3);
 if (Sender = GM5) then DO_Goto_Marker(4);
end;

procedure TMapWindow.HelpRegisterClick(Sender: TObject);
begin
 Application.CreateForm(TRegisterWindow, RegisterWindow);

 RegisterWindow.ShowModal;
 RegisterWindow.Destroy;
end;

function ArrayToString(const a: array of Char): string;
begin
  if Length(a)>0 then
    SetString(Result, PChar(@a[0]), Length(a))
  else
    Result := '';
end;

procedure TMapWindow.HelpTutorialClick(Sender: TObject);
var tmp : array[0..255] of char;
    helpExe : string;
    helpStr : string;
    result : Integer;
begin
 helpStr := WDFUSEDir +'\WDFDATA\wdftutor.hlp';
 helpExe := WDFUSEDir + '\WDFDATA\WINHLP32.EXE';
 ShellExecute(0, 'open', PChar(helpExe),
              Pchar(helpStr), nil, SW_SHOWNORMAL) ;
end;


procedure TMapWindow.HelpDFSpecsClick(Sender: TObject);
var url : string;
begin
  url := 'https://df-21.net/documentation/DFSPECS/df_specs.htm';
  ShellExecute(HInstance, 'open', PChar(url), nil, nil, SW_NORMAL);
end;


procedure TMapWindow.MapDblClick(Sender: TObject);
var TheSector : TSector;
    tmp       : array[0..255] of char;
begin
 IF LEVELLoaded THEN
  BEGIN
  TheSector := TSector(MAP_SEC.Objects[SC_HILITE]);
  if TheSector.Name = '' then
    TheSector.Name := 'SECTOR_' + IntToStr(SC_HILITE);
  case MAP_MODE of
   MM_SC : begin
            SectorEditor.Show;
            SectorEditor.SCEd.Row := 0;
            SectorEditor.SCEd.SetFocus;
            INFSector := SC_HILITE;
            INFWall   := -1;
            INFRemote := TRUE;
           end;
   MM_WL : begin
            WallEditor.Show;
            WallEditor.WLEd.Row := 0;
            WallEditor.WLEd.SetFocus;
            INFSector := SC_HILITE;
            INFWall   := WL_HILITE;
            INFRemote := TRUE;
           end;
   MM_VX : begin
            VertexEditor.Show;
            VertexEditor.VXEd.Row := 0;
            VertexEditor.VXEd.SetFocus;
           end;
   MM_OB : begin
            ObjectEditor.Show;
            ObjectEditor.OBEd.Row := 0;
            ObjectEditor.OBEd.SetFocus;
           end;
    end;
  END;
end;

procedure TMapWindow.EditPreviousClick(Sender: TObject);
begin
 CASE MAP_MODE of
      MM_SC : DO_Prev_SC;
      MM_WL : DO_Prev_WL;
      MM_VX : DO_Prev_VX;
      MM_OB : DO_Prev_OB;
     END;
end;

procedure TMapWindow.ProjectCloseClick(Sender: TObject);
begin
 if LEVELLoaded and MODIFIED then
   begin
    CASE Application.MessageBox('Level has been modified. Do you want to SAVE ?',
                                 'WDFUSE Mapper - Close Project',
                                 mb_YesNoCancel or mb_IconQuestion) OF
     idYes    : begin
                 if MaySave then
                  begin
                   Do_SaveProject;
                   FreeLevel;
                  end;
                end;
     idNo     : begin
                 FreeLevel;
                end;
     idCancel : ;
    END;
   end
  else
   begin
    if LEVELLoaded then FreeLevel;
   end;
end;

procedure TMapWindow.ProjectDeleteClick(Sender: TObject);
var tmp : array[0..255] of char;
    str : string;
    SearchRec: TSearchRec;
begin
 {careful here :-)}
 ChDir(WDFUSEdir);

{stupidly, in Win16 DeleteFile takes string param,
 and       in Win32 it takes PChar :-(

}

{$IFNDEF WDF32}
 with DeleteProjectDialog do
 if Execute then
  begin
   str := 'About to delete project ' + FileName + '  Continue ?';
   strPcopy(tmp, str);
   if Application.MessageBox(tmp, 'WDFUSE Mapper - Delete Project',
                             mb_YesNo or mb_IconQuestion) = idYes then
    begin
     {must delete .wdp, .txt, project dir and backup subdir}
     if FindFirst(ChangeFileExt(FileName, '') + '\BACKUPS\*.*', faAnyFile, SearchRec) = 0 then
      begin
       DeleteFile(ChangeFileExt(FileName, '') + '\BACKUPS\' + SearchRec.Name);
       while FindNext(SearchRec) = 0 do
        DeleteFile(ChangeFileExt(FileName, '') + '\BACKUPS\'+SearchRec.Name);
      end;
     RmDir(ChangeFileExt(FileName, '') + '\BACKUPS');
     if FindFirst(ChangeFileExt(FileName, '') + '\*.*', faAnyFile, SearchRec) = 0 then
      begin
       DeleteFile(ChangeFileExt(FileName, '') + '\'+SearchRec.Name);
       while FindNext(SearchRec) = 0 do
        DeleteFile(ChangeFileExt(FileName, '') + '\'+SearchRec.Name);
      end;
     RmDir(ChangeFileExt(FileName, ''));
     DeleteFile(ChangeFileExt(FileName, '.txt'));
     DeleteFile(FileName);
    end;
  end;
{$ELSE}
 with DeleteProjectDialog do
 if Execute then
  begin
   str := 'About to delete project ' + FileName + '  Continue ?';
   strPcopy(tmp, str);
   if Application.MessageBox(tmp, 'WDFUSE Mapper - Delete Project',
                             mb_YesNo or mb_IconQuestion) = idYes then
    begin
     {must delete .wdp, .txt, project dir and backup subdir}
     if FindFirst(ChangeFileExt(FileName, '') + '\BACKUPS\*.*', faAnyFile, SearchRec) = 0 then
      begin
       str := ChangeFileExt(FileName, '') + '\BACKUPS\' + SearchRec.Name;
       StrPCopy(tmp, str);
       DeleteFile(tmp);
       while FindNext(SearchRec) = 0 do
        begin
         str := ChangeFileExt(FileName, '') + '\BACKUPS\'+SearchRec.Name;
         StrPCopy(tmp, str);
         DeleteFile(tmp);
        end;
      end;
     RmDir(ChangeFileExt(FileName, '') + '\BACKUPS');
     if FindFirst(ChangeFileExt(FileName, '') + '\*.*', faAnyFile, SearchRec) = 0 then
      begin
       str := ChangeFileExt(FileName, '') + '\'+SearchRec.Name;
       StrPCopy(tmp, str);
       DeleteFile(tmp);
       while FindNext(SearchRec) = 0 do
        begin
         str := ChangeFileExt(FileName, '') + '\'+SearchRec.Name;
         StrPCopy(tmp, str);
         DeleteFile(tmp);
        end;
      end;
     RmDir(ChangeFileExt(FileName, ''));
     str := ChangeFileExt(FileName, '.txt');
     StrPCopy(tmp, str);
     DeleteFile(tmp);
     str := FileName;
     StrPCopy(tmp, str);
     DeleteFile(tmp);
    end;
  end;
 {$ENDIF}

 ChDir(WDFUSEdir);
end;


procedure TMapWindow.EditAdjoinClick(Sender: TObject);
var adjoins : Integer;
begin
 if MAP_MODE = MM_WL then
   begin
     Do_StoreUndo;
     IGNORE_UNDO := True;
     if MakeAdjoin(SC_HILITE, WL_HILITE) then
      adjoins := 1
     else
      adjoins := 0;
     adjoins := adjoins + MultiMakeAdjoin;
     DO_Fill_WallEditor;
     PanelText.Caption := IntToStr(adjoins) + ' ADJOIN(S) MADE';
    IGNORE_UNDO := False;
   end;
end;

procedure TMapWindow.EditCopyClick(Sender: TObject);
begin
 CASE MAP_MODE OF
  MM_SC : DO_CopyGeometry;
  MM_OB : DO_CopyObjects;
 END;
end;

procedure TMapWindow.EditExtrudeClick(Sender: TObject);
begin
  IF MAP_MODE = MM_WL THEN
    ShellExtrudeWL(SC_HILITE, WL_HILITE);
end;

procedure TMapWindow.EditNextClick(Sender: TObject);
begin
 CASE MAP_MODE of
      MM_SC : DO_Next_SC;
      MM_WL : DO_Next_WL;
      MM_VX : DO_Next_VX;
      MM_OB : DO_Next_OB;
     END;
end;

procedure TMapWindow.EditPasteClick(Sender: TObject);
var cursx, cursy : real;
    tempPt : TPoint;
begin
  GetCursorPos(tempPt);

  { if you are right cliking - use the mouse pointer, otherwise center }
  if (Sender is TMenuItem) and (TMenuItem(Sender).Name = 'PopUpPaste') then
    begin
     cursx :=  S2MX(tempPt.x - MoveXOffset);
     cursy :=  S2MZ(tempPt.y - (MoveYOffset + MenuYOffset));
    end
  else
    begin
      cursx := S2MX(width/2);
      cursy := S2MZ(height/2 - MenuYOffset);
    end;
 DO_PasteWrapper(cursx, cursy);
end;

procedure TMapWindow.EditUnAdjoinClick(Sender: TObject);
var adjoins : Integer;
begin
  if MAP_MODE = MM_WL then
    begin
      Do_StoreUndo;
       IGNORE_UNDO := True;
       if UnAdjoin(SC_HILITE, WL_HILITE) then
        adjoins := 1
       else
        adjoins := 0;
       adjoins := adjoins + MultiUnAdjoin;
       DO_Fill_WallEditor;
       PanelText.Caption := IntToStr(adjoins) + ' ADJOIN(S) REMOVED';
       IGNORE_UNDO := False;
    end;
end;

procedure TMapWindow.SpeedButtonDukeClick(Sender: TObject);
var minX, minY, minZ,
    maxX, maxY, maxZ : Real;
begin
  {find the offsets for the user}
  DO_GetMapLimits(minX, minY, minZ, maxX, maxY, maxZ);
  DukeConvertWindow.SEXOffset.Value := -((Trunc((maxX+minX)/2) div 8) * 8);
  DukeConvertWindow.SEZOffset.Value :=  (Trunc((maxZ+minZ)/2) div 8) * 8;
  {annoying !
  DukeConvertWindow.SEYOffset.Value := -Round((maxY+minY)/2);
  }

  if DukeConvertWindow.ED_MAP.Text = '' then
   DukeConvertWindow.ED_MAP.Text := ChangeFileExt(PROJECTFile, '.MAP');
  if DukeConvertWindow.ED_CNVFile.Text = '' then
   DukeConvertWindow.ED_CNVFile.Text := WDFUSEdir+'\WDFDATA\' + LEVELname + '.cnv';
  DukeConvertWindow.ShowModal;
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
 MapWindow.Map.Invalidate;
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
 Application.CreateForm(TGOBWindow, GOBWindow);
 GOBWindow.ShowModal;
 GOBWindow.Destroy;
 Application.OnHint := DisplayHint;
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
  Application.CreateForm(TLFDWindow, LFDWindow);
 LFDWindow.ShowModal;
 LFDWindow.Destroy;
 Application.OnHint := DisplayHint;
end;

procedure TMapWindow.SpeedButtonTKTClick(Sender: TObject);
begin
  ToolsToolkitClick(Sender);
end;

procedure TMapWindow.SpeedButtonHelpClick(Sender: TObject);
var url : string;
begin
  url := 'https://df-21.net/articles/index.php#editing';
  ShellExecute(HInstance, 'open', PChar(url), nil, nil, SW_NORMAL);
end;

procedure TMapWindow.SBSaveAsMapPClick(Sender: TObject);
   var SaveBMP : TBitmap;
begin
 with MapWindow.SaveMapDialog do
  if Execute then
   begin
    DO_SaveProjectAs(FileName);
   end;
end;

procedure TMapWindow.SBSaveMapBMPClick(Sender: TObject);
   var SaveBMP : TBitmap;
begin
 with MapWindow.SaveBMPMapDialog do
  if Execute then
   begin
    MapWindow.Map.Refresh;
    SaveBMP := TBitmap.Create;
    SaveBMP.Width  := MapWindow.Map.Width;
    SaveBMP.Height := MapWindow.Map.Height;
    BitBlt(SaveBMP.Canvas.Handle,        0, 0, MapWindow.Map.Width , MapWindow.Map.Height,
           MapWindow.Map.Canvas.Handle,  0, 0,
           SRCCOPY);
    SaveBMP.SaveToFile(FileName);
    SaveBMP.Free;
   end;
end;

procedure TMapWindow.SpeedButtonINFClick(Sender: TObject);
var tmp       : array[0..255] of Char;
begin
  { exec the inf editor only if it is not the internal editor
    else show it and tell it to read the file }
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
    
  if UpperCase(INFEditor) <> '' then
   begin
    StrPCopy(tmp, INFEditor + ' ' + LEVELPath + '\' + LEVELName + '.INF');
    WinExec(PAnsiChar(AnsiString(tmp)), SW_SHOW);
   end
  else
   begin
    INFWindow2.Show;
   end;
end;

procedure TMapWindow.SpeedButtonGOLClick(Sender: TObject);
begin
 DO_Edit_Short_Text_File(LEVELPath + '\' + LEVELName + '.GOL');
end;

procedure TMapWindow.SpeedButtonLVLClick(Sender: TObject);
begin
  DO_Edit_Short_Text_File(LEVELPath + '\JEDI.LVL');
end;

procedure TMapWindow.SpeedButtonMSGClick(Sender: TObject);
begin
   DO_Edit_Short_Text_File(LEVELPath + '\TEXT.MSG');
end;

procedure TMapWindow.SpeedButtonTXTClick(Sender: TObject);
begin
 DO_Edit_Short_Text_File(ChangeFileExt(PROJECTFile, '.TXT'));
end;

procedure TMapWindow.PanelMapLayerClick(Sender: TObject); {new layer control DL nov/96}
begin
 DO_Layer_OnOff;
end;

procedure TMapWindow.SpeedButtonMapKeyClick(Sender: TObject);
begin
  AllKeys.Show;
end;

 procedure TMapWindow.SpeedButtonVueClick(Sender: TObject);
begin
  Application.CreateForm(TVueCreator, VueCreator);
  VueCreator.ShowModal;
  VueCreator.Destroy;

end;

procedure TMapWindow.SpeedButton3DOClick(Sender: TObject);
begin
    Application.CreateForm(TConv3do, Conv3do);
    Conv3do.ShowModal;
    Conv3do.Destroy;
end;


end.
