unit M_obedit;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Buttons, ExtCtrls, Grids, MultiSelection,
  Menus, StdCtrls, FieldEdit, Level, misc_utils, GlobalVars;

type
  TObjectEditor = class(TForm)
    OBEd: TStringGrid;
    PanelButtons: TPanel;
    SBCommit: TSpeedButton;
    SBRollback: TSpeedButton;
    VXEdPopupMenu: TPopupMenu;
    CommittF21: TMenuItem;
    RollbackEsc1: TMenuItem;
    PanelInfo: TPanel;
    PanelInfoLeft: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel7: TPanel;
    PanelSCName: TPanel;
    PanelFloorAlt: TPanel;
    PanelLayer: TPanel;
    ShapeMulti: TShape;
    N1: TMenuItem;
    ForceCurrentField: TMenuItem;
    N3: TMenuItem;
    StayOnTop: TMenuItem;
    Panel1: TPanel;
    SBHelp: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure SBRollbackClick(Sender: TObject);
    procedure SBCommitClick(Sender: TObject);
    procedure OBEdKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SBSelClick(Sender: TObject);
    procedure ForceCurrentFieldClick(Sender: TObject);
    procedure SBHelpClick(Sender: TObject);
    procedure StayOnTopClick(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
   fe:TFieldEdit;
   nob:integer;
   Sel:TMultiSelection;
   TheObject:TOB;
    { Private declarations }
    Procedure DblClickHandler(Fi:TFieldInfo);
  public
   MapWindow:TForm;
   Procedure LoadObject(ob:Integer);
   Procedure EditIt;
   Procedure Reload;
   Property MultiSel:TMultiSelection read sel write sel;
   Function L:TLevel;
   Procedure Commit(OB:TOB);
    { Public declarations }
  end;

implementation

uses Mapper, ResourcePicker, FlagEditor;

{$R *.DFM}

Const
 ID_Name=1;
 ID_Sector=2;
 ID_X=5;
 ID_Y=6;
 ID_Z=7;
 ID_PCH=10;
 ID_YAW=11;
 ID_ROL=12;
 ID_flags1=15;
 ID_Flags2=16;

procedure TObjectEditor.FormCreate(Sender: TObject);
begin
 StayOnTop.Checked:=OBEditOnTop;
 if OBEditOnTop then FormStyle:=fsStayOnTop;

  Fe:=TFieldEdit.Create(ObEd);
 With fe do
 begin
  AddField('+Name',ID_Name,vtString);
  AddField('Sector',ID_Sector,vtInteger);
  AddField('X',ID_X,vtDouble);
  AddField('Y',ID_Y,vtDouble);
  AddField('Z',ID_Z,vtDouble);
  AddField('PCH',ID_PCH,vtDouble);
  AddField('YAW',ID_YAW,vtDouble);
  AddField('ROL',ID_ROL,vtDouble);
  AddField('+Flags1',ID_Flags1,vtDword);
  AddField('+Flags2',ID_Flags2,vtDword);
 end;
 Fe.OnDblClick:=DblClickHandler;
end;

Procedure TObjectEditor.DblClickHandler(Fi:TFieldInfo);
var flags:Longint;
begin
 With Fi do
 case ID of
 ID_Name: s:=ResPicker.PickItem(fi.s);
 ID_Flags1: begin
             ReadDword(flags);
             flags:=FlagEdit.EditObjectFlags1(Flags);
             s:=DwordToStr(flags);
            end;
 ID_Flags2: begin
             ReadDword(flags);
             flags:=FlagEdit.EditObjectFlags2(Flags);
             s:=DwordToStr(flags);
            end;
 end;
end;

procedure TObjectEditor.SBRollbackClick(Sender: TObject);
begin
 OBEd.EditorMode:=false;
 ReLoad;
 { DO_Fill_ObjectEditor;}
  if MapWindow<>nil then MapWindow.SetFocus;
end;

Procedure TObjectEditor.Commit(OB:TOB);
var i:Integer;
begin
 if Ob=nil then exit;
  for i:=0 to fe.FieldCount-1 do
  With fe.Fields[i] do
  With OB do
  if changed then
  case id of
   ID_Name    : Name:=s;
   ID_Sector  : ReadInteger(Sector);
   ID_X       : ReadDouble(X);
   ID_Y       : ReadDouble(Y);
   ID_Z       : ReadDouble(Z);
   ID_PCH     : ReadDouble(PCH);
   ID_YAW     : ReadDouble(YAW);
   ID_ROL     : ReadDouble(ROL);
 ID_flags1    : ReadDword(Flags1);
 ID_Flags2    : ReadDword(Flags2);
  end;
end;


procedure TObjectEditor.SBCommitClick(Sender: TObject);
var i:Integer;
begin
 OBEd.EditorMode:=false;
 Commit(TheObject);
 For i:=0 to MultiSel.Count-1 do
 begin
  Commit(l.Objects[Sel.GetObject(i)]);
 end;
{  for i:=0 to fe.fieldCount-1 do fe.Fields[i].Changed:=false;}
  if not fe.getFieldByID(ID_Sector).Changed then TMapWindow(MapWindow).ForceLayerObjects;
  Reload;
  MapWindow.SetFocus;
  TMapWindow(MapWindow).Map.Invalidate;

end;


procedure TObjectEditor.OBEdKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Shift = [] then
    Case Key of
      VK_F1     : {Application.HelpJump('wdfuse_help_OBeditor')};
      VK_F2     : SBCommitClick(NIL);
      VK_ESCAPE : SBRollbackClick(NIL);
      VK_TAB    : if MapWindow<>nil then MapWindow.SetFocus;
      VK_HOME,
      VK_END    :;
    end;
  if Shift = [ssCtrl] then
    Case Key of
      VK_LEFT   : begin
                   if ObEd.ColWidths[0] > 1 then
                    begin
                     ObEd.ColWidths[0] := ObEd.ColWidths[0] - 1;
                     PanelInfoLeft.Width := PanelInfoLeft.Width - 1;
                    end;
                  end;
      VK_RIGHT  : begin
                   ObEd.ColWidths[0] := ObEd.ColWidths[0] + 1;
                   PanelInfoLeft.Width := PanelInfoLeft.Width + 1;
                  end;
    end;
end;


procedure TObjectEditor.SBSelClick(Sender: TObject);
begin
 {DO_SelectObject;}
end;

procedure TObjectEditor.ForceCurrentFieldClick(Sender: TObject);
begin
 {DO_ForceCommit_ObjectEditorField(ObEd.Row);}
end;

procedure TObjectEditor.SBHelpClick(Sender: TObject);
begin
 Application.HelpJump('Hlp_Object_Editor');
end;

procedure TObjectEditor.StayOnTopClick(Sender: TObject);
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

Procedure TObjectEditor.Reload;
var i:integer;
begin
 For i:=0 to fe.FieldCount-1 do
 With fe.Fields[i] do
 With TheObject do
 begin
 case id of
     id_Name: s:=Name;
   ID_Sector: s:=IntToStr(Sector);
        ID_X: s:=FloatToStr(X);
        ID_Y: s:=FloatToStr(Y);
        ID_Z: s:=FloatToStr(Z);
      ID_PCH: s:=FloatToStr(PCH);
      ID_YAW: s:=FloatToStr(YAW);
      ID_ROL: s:=FloatToStr(ROL);
   ID_flags1: s:=DwordToStr(Flags1);
   ID_Flags2: s:=DwordToStr(Flags2);
 end;
 changed:=false;
 end;
end;

Procedure TObjectEditor.LoadObject(ob:Integer);
var TheSector:TSector;
begin
 TheObject:=l.Objects[ob];
 Caption:=Format('OB %d ID: %x',[ob,TheObject.HexID]);
 if L.IsSCValid(TheObject.Sector) then
 begin
  TheSector:=L.Sectors[TheObject.Sector];
  PanelSCName.Caption:=TheSector.Name;
  PanelFloorAlt.Caption:=Format('%f %f',[TheSector.Floor_Y,TheSector.Ceiling_Y]);
  PanelLayer.Caption:=IntToStr(TheSector.Layer);
 end;
 Reload;
end;

Procedure TObjectEditor.EditIt;
begin
 if not visible then Visible:=true;
 Self.SetFocus;
end;


procedure TObjectEditor.FormDeactivate(Sender: TObject);
var Changed:Boolean;
    i:integer;
begin
 OBEd.EditorMode:=false;
 Changed:=false;
 for i:= 0 to fe.fieldcount-1 do
  Changed:=Changed or fe.Fields[i].Changed;
 if changed then
 if MsgBox('Commit changes?','Question',mb_YesNo)=idYes then
 SBCommit.Click else Reload;
 ShapeMulti.Brush.Color:=clBtnFace;
end;

procedure TObjectEditor.FormShow(Sender: TObject);
begin
 SetFormPos(Self,ObjectEditPos);
end;

procedure TObjectEditor.FormHide(Sender: TObject);
begin
 GetFormPos(Self,ObjectEditPos);
 OBEditOnTop:=FormStyle=fsStayOnTop;
end;

Function TObjectEditor.L:TLevel;
begin
 Result:=TMapWindow(MapWindow).Level;
end;


procedure TObjectEditor.FormActivate(Sender: TObject);
begin
 if MultiSel.Count=0 then ShapeMulti.Brush.Color:=clBtnFace
 else ShapeMulti.Brush.Color:=clRed;
end;

end.
