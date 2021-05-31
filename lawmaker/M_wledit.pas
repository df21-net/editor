unit M_wledit;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Buttons, ExtCtrls, Grids, Level_Utils, MultiSelection,
  Menus, StdCtrls, Level, FieldEdit, misc_utils, GlobalVars;

type
  TWallEditor = class(TForm)
    WLEd: TStringGrid;
    PanelButtons: TPanel;
    SBCommit: TSpeedButton;
    SBRollback: TSpeedButton;
    PanelInfo: TPanel;
    PanelInfoLeft: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    PanelSCName: TPanel;
    PanelFloorAlt: TPanel;
    PanelHeight: TPanel;
    PanelLength: TPanel;
    PanelLRVX: TPanel;
    WLEdPopupMenu: TPopupMenu;
    CommitF21: TMenuItem;
    RollbackEsc1: TMenuItem;
    ShapeMulti: TShape;
    N1: TMenuItem;
    ForceCurrentField: TMenuItem;
    N2: TMenuItem;
    StayOnTop: TMenuItem;
    ShapeINF: TShape;
    N3: TMenuItem;
    CopyMIDTxtoTOPandBOT1: TMenuItem;
    Panel1: TPanel;
    SBHelp: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure SBCommitClick(Sender: TObject);
    procedure SBRollbackClick(Sender: TObject);
    procedure WLEdKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure CBClassClick(Sender: TObject);
    procedure ForceCurrentFieldClick(Sender: TObject);
    procedure SBHelpClick(Sender: TObject);
    procedure StayOnTopClick(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure CopyMIDTxtoTOPandBOT1Click(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
   fe:TFieldEdit;
   TheWall:TWall;
   sel:TMultiSelection;
    { Private declarations }
    Procedure DblClickHandler(Fi:TFieldInfo);
  public
   MapWindow:TForm;
   Procedure LoadWall(sc,wl:Integer);
   Procedure EditIt;
   Procedure Reload;
   Property MultiSel:TMultiSelection read sel write sel;
   Function L:TLevel;
    { Public declarations }
   Procedure Commit(wall:TWall);
  end;

implementation

uses Mapper, ResourcePicker, FlagEditor;

{$R *.DFM}
Const
 ID_V1=1;
 ID_V2=2;
 ID_Mid_TX=5;
 ID_MID_OffsX=6;
 ID_MID_OffsY=7;

 ID_TOP_TX=10;
 ID_TOP_OffsX=11;
 ID_TOP_OffsY=12;

 ID_BOT_TX=15;
 ID_BOT_OffsX=16;
 ID_BOT_OffsY=17;

 ID_Overlay_TX=20;
 ID_Overlay_OffsX=21;
 ID_Overlay_OffsY=22;

 ID_Adjoin=25;
 ID_Mirror=26;

 ID_DAdjoin=30;
 ID_DMirror=31;

 ID_Flags=35;
 ID_Light=40;


procedure TWallEditor.FormCreate(Sender: TObject);
begin
 StayOnTop.Checked:=WLEditOnTop;
 if WLEditOnTop then FormStyle:=fsStayOnTop;

   Fe:=TFieldEdit.Create(WLEd);
 With fe do
 begin
  AddField('V1',ID_V1,vtInteger);
  AddField('V2',ID_V2,vtInteger);
  AddField('+Middle TX',ID_MID_TX,vtString);
  AddField('     OffsX',ID_MID_OFFSX,vtDouble);
  AddField('     OffsY',ID_MID_OFFSY,vtDouble);
  AddField('+Top TX',ID_TOP_TX,vtString);
  AddField('     OffsX',ID_TOP_OFFSX,vtDouble);
  AddField('     OffsY',ID_TOP_OFFSY,vtDouble);
  AddField('+Bottom TX',ID_BOT_TX,vtString);
  AddField('     OffsX',ID_BOT_OFFSX,vtDouble);
  AddField('     OffsY',ID_BOT_OFFSY,vtDouble);
  AddField('+Overlay TX',ID_Overlay_TX,vtString);
  AddField('     OffsX',ID_Overlay_OFFSX,vtDouble);
  AddField('     OffsY',ID_Overlay_OFFSY,vtDouble);

  AddField('Adjoin',ID_Adjoin,vtInteger);
  AddField('Mirror',ID_Mirror,vtInteger);
  AddField('DAdjoin',ID_DAdjoin,vtInteger);
  AddField('DMirror',ID_DMirror,vtInteger);

  AddField('+Flags',ID_Flags,vtDword);
  AddField('Light',ID_Light,vtInteger);
 end;
 fe.OnDblClick:=DblClickHandler;
end;

Procedure TWallEditor.DblClickHandler(Fi:TFieldInfo);
var flags:Longint;
begin
 case Fi.ID of
  ID_MID_TX,
  ID_BOT_TX,
  ID_TOP_TX,
  ID_OverLay_TX: Fi.s:=ResPicker.PickTexture(fi.s);
  ID_Flags: begin
             Fi.ReadDword(flags);
             flags:=FlagEdit.EditWallFlags(Flags);
             fi.s:=DwordToStr(flags);
            end;
 end;
end;

Procedure TWallEditor.Commit(wall:TWall);
var i:integer;
begin
 if Wall=nil then exit;
  for i:=0 to fe.FieldCount-1 do
  With fe.Fields[i] do
  With Wall do
  if changed then
  case id of
   ID_V1   : ReadInteger(V1);
   ID_V2   : ReadInteger(V2);
 ID_Mid_TX : MID.Name:=s;
 ID_MID_OffsX: ReadDouble(MID.OffsX);
 ID_MID_OffsY: ReadDouble(MID.OffsY);

 ID_TOP_TX: TOP.Name:=s;
 ID_TOP_OffsX: ReadDouble(TOP.OffsX);
 ID_TOP_OffsY: ReadDouble(TOP.OffsY);

 ID_BOT_TX: BOT.Name:=s;
 ID_BOT_OffsX: ReadDouble(BOT.OffsX);
 ID_BOT_OffsY: ReadDouble(BOT.OffsY);

 ID_Overlay_TX: Overlay.Name:=s;
 ID_Overlay_OffsX: ReadDouble(Overlay.OffsX);
 ID_Overlay_OffsY: ReadDouble(Overlay.OffsY);

 ID_Adjoin: ReadInteger(Adjoin);
 ID_Mirror: ReadInteger(Mirror);

 ID_DAdjoin: ReadInteger(DAdjoin);
 ID_DMirror: ReadInteger(DMirror);

 ID_Flags: ReadDword(Flags);
 ID_Light: Read0to31(Light);

  end;
end;

procedure TWallEditor.SBCommitClick(Sender: TObject);
var i:Integer;
    aWall:TWall;
begin
 WLEd.EditorMode:=false;
 Commit(TheWall);
 for i:=0 to MultiSel.Count-1 do
 begin
  aWall:=L.Sectors[MultiSel.GetSector(i)].Walls[MultiSel.GetWall(i)];
  Commit(aWall);
 end;

  for i:=0 to fe.fieldCount-1 do fe.Fields[i].Changed:=false;
  Reload;

  if MapWindow<>nil then
  begin
   MapWindow.SetFocus;
   TMapWindow(MapWindow).Map.Invalidate;
  end;
end;

procedure TWallEditor.SBRollbackClick(Sender: TObject);
begin
{  DO_Fill_WallEditor;}
 WLEd.EditorMode:=false;
 ReLoad;
  if MapWindow<>nil then MapWindow.SetFocus;
end;

procedure TWallEditor.WLEdKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Shift = [] then
    Case Key of
      VK_F1     : {Application.HelpJump('wdfuse_help_WLeditor')};
      VK_F2     : SBCommitClick(NIL);
      VK_ESCAPE : SBRollbackClick(NIL);
      VK_TAB    : if MapWindow<>nil then MapWindow.SetFocus;
      VK_HOME,
      VK_END    : {WLEdDblClick(NIL)};
    end;
  if Shift = [ssCtrl] then
    Case Key of
      VK_LEFT   : begin
                   if WlEd.ColWidths[0] > 1 then
                    begin
                     WlEd.ColWidths[0] := WlEd.ColWidths[0] - 1;
                     PanelInfoLeft.Width := PanelInfoLeft.Width - 1;
                    end;
                  end;
      VK_RIGHT  : begin
                   WlEd.ColWidths[0] := WlEd.ColWidths[0] + 1;
                   PanelInfoLeft.Width := PanelInfoLeft.Width + 1;
                  end;
    end;
end;


procedure TWallEditor.CBClassClick(Sender: TObject);
begin
 {DO_WallEditor_Specials(CBClass.ItemIndex);}
end;

procedure TWallEditor.ForceCurrentFieldClick(Sender: TObject);
begin
 {DO_ForceCommit_WallEditorField(WlEd.Row);}
end;

procedure TWallEditor.SBHelpClick(Sender: TObject);
begin
 Application.HelpJump('Hlp_Wall_Editor');
end;

procedure TWallEditor.StayOnTopClick(Sender: TObject);
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

Procedure TWallEditor.Reload;
var i:integer;
begin
 For i:=0 to fe.FieldCount-1 do
 With fe.Fields[i] do
 With TheWall do
 begin
 case id of
        ID_V1: s:=IntToStr(V1);
        ID_V2: s:=IntToStr(V2);
    ID_Mid_TX: s:=MID.Name;
 ID_MID_OffsX: s:=FloatToStr(MID.OffsX);
 ID_MID_OffsY: s:=FloatToStr(MID.OffsY);

     ID_TOP_TX: s:=TOP.Name;
  ID_TOP_OffsX: s:=FloatToStr(TOP.OffsX);
  ID_TOP_OffsY: s:=FloatToStr(TOP.OffsY);

     ID_BOT_TX: s:=BOT.Name;
  ID_BOT_OffsX: s:=FloatToStr(BOT.OffsX);
  ID_BOT_OffsY: s:=FloatToStr(BOT.OffsY);

 ID_Overlay_TX: s:=Overlay.Name;
ID_Overlay_OffsX: s:=FloatToStr(Overlay.OffsX);
 ID_Overlay_OffsY: s:=FloatToStr(Overlay.OffsY);

     ID_Adjoin: s:=IntToStr(Adjoin);
     ID_Mirror: s:=IntToStr(Mirror);

    ID_DAdjoin: s:=IntToStr(DAdjoin);
    ID_DMirror: s:=IntToStr(DMirror);

      ID_Flags: s:=DwordToStr(Flags);
      ID_Light: s:=IntToStr(Light);
 end;
  Changed:=false;
end;
end;

Procedure TWallEditor.LoadWall(sc,wl:Integer);
var TheSector:TSector;
begin
 TheSector:=l.Sectors[sc];
 TheWall:=TheSector.Walls[wl];
 Caption:=Format('SC %d WL: %d ID: %x',[sc,wl,TheWall.HexID]);

 PanelSCName.Caption:=TheSector.Name;
 PanelFloorAlt.Caption:=Format('%f %f',[TheSector.Floor_Y,TheSector.Ceiling_Y]);
 PanelHeight.Caption:=FloatToStr(TheSector.Ceiling_Y-TheSector.Floor_Y);
 PanelLength.Caption:=Format('%f',[GetWLLen(L,sc,wl)]);
 PanelLRVX.Caption:=Format('%d %d',[TheWall.V1,TheWall.V2]);

 Reload;
end;

Procedure TWallEditor.EditIt;
begin
 if not visible then Visible:=true;
 Self.SetFocus;
end;

procedure TWallEditor.FormDeactivate(Sender: TObject);
var changed:Boolean;
    i:integer;
begin
 WLEd.EditorMode:=false;
 Changed:=false;
 for i:= 0 to fe.fieldcount-1 do
  Changed:=Changed or fe.Fields[i].Changed;
 if changed then
 if MsgBox('Commit changes?','Question',mb_YesNo)=idYes then
 SBCommit.Click else Reload;
 ShapeMulti.Brush.Color:=clBtnFace;
end;

procedure TWallEditor.CopyMIDTxtoTOPandBOT1Click(Sender: TObject);
var fi,fi2:TFieldInfo;
begin
 fi:=fe.GetFieldByID(ID_MID_TX);
 if fi<>nil then
 begin
  fi2:=fe.GetFieldByID(ID_BOT_TX);
  if fi2<>nil then fi2.s:=fi.s;
  fi2:=fe.GetFieldByID(ID_TOP_TX);
  if fi2<>nil then fi2.s:=fi.s;
 end;
end;

procedure TWallEditor.FormHide(Sender: TObject);
begin
 GetFormPos(Self,WallEditPos);
  WLEditOnTop:=FormStyle=fsStayOnTop;
end;

procedure TWallEditor.FormShow(Sender: TObject);
begin
 SetFormPos(Self,WallEditPos);
end;

Function TWallEditor.L:TLevel;
begin
 Result:=TMapWindow(MapWindow).Level;
end;

procedure TWallEditor.FormActivate(Sender: TObject);
begin
 if MultiSel.Count=0 then ShapeMulti.Brush.Color:=clBtnFace
 else ShapeMulti.Brush.Color:=clRed;
end;

end.
