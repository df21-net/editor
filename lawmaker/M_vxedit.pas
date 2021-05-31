unit M_vxedit;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Buttons, ExtCtrls, Grids,  Menus, Level, misc_utils,
  FieldEdit, GlobalVars, Level_Utils, MultiSelection;

type
  TVertexEditor = class(TForm)
    VXEd: TStringGrid;
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
    Panel5: TPanel;
    Panel7: TPanel;
    PanelSCName: TPanel;
    PanelFloorAlt: TPanel;
    PanelLeftOfWL: TPanel;
    PanelRightOfWL: TPanel;
    ShapeMulti: TShape;
    N1: TMenuItem;
    ForceCurrentField: TMenuItem;
    N2: TMenuItem;
    StayOnTop: TMenuItem;
    Panel1: TPanel;
    SBHelp: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure SBRollbackClick(Sender: TObject);
    procedure SBCommitClick(Sender: TObject);
    procedure VXEdKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ForceCurrentFieldClick(Sender: TObject);
    procedure SBHelpClick(Sender: TObject);
    procedure StayOnTopClick(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
   fe:TFieldEdit;
   TheVertex:TVertex;
   Sel:TMultiSelection;
    { Private declarations }
  public
   MapWindow:TForm;
   Procedure LoadVertex(Sc,Vx:Integer);
   Procedure EditIt;
   Procedure Reload;
   Property MultiSel:TMultiSelection read sel write sel;
   Function L:TLevel;
    { Public declarations }
   Procedure Commit(Vertex:TVertex);
  end;

implementation

uses Mapper;

{$R *.DFM}

Const
ID_X=1;
ID_Z=2;

procedure TVertexEditor.FormCreate(Sender: TObject);
begin
 StayOnTop.Checked:=VXEditOnTop;
 if VXEditOnTop then FormStyle:=fsStayOnTop;

   Fe:=TFieldEdit.Create(VXEd);
 With fe do
 begin
  AddField('X',ID_X,vtDouble);
  AddField('Z',ID_Z,vtDouble);
 end;
end;

procedure TVertexEditor.SBRollbackClick(Sender: TObject);
begin
 VXEd.EditorMode:=false;
 ReLoad;
  if MapWindow<>nil then MapWindow.SetFocus;
end;

Procedure TVertexEditor.Commit(Vertex:TVertex);
Var i:Integer;
Begin
 if Vertex=nil then exit;
  for i:=0 to fe.FieldCount-1 do
  With fe.Fields[i] do
  With Vertex do
  if changed then
  case id of
   ID_X       : ReadDouble(X);
   ID_Z       : ReadDouble(Z);
  end;
End;


procedure TVertexEditor.SBCommitClick(Sender: TObject);
var i:Integer;
begin
 VXEd.EditorMode:=false;
 Commit(TheVertex);
 For i:=0 to MultiSel.COunt-1 do
 begin
  Commit(L.Sectors[Sel.GetSector(i)].Vertices[Sel.GetVertex(i)]);
 end;

 for i:=0 to fe.fieldCount-1 do fe.Fields[i].Changed:=false;
 Reload;
  if MapWindow<>nil then
  begin
   MapWindow.SetFocus;
   TMapWindow(MapWindow).Map.Invalidate;
  end;
end;

procedure TVertexEditor.VXEdKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Shift = [] then
    Case Key of
      VK_F1     : {Application.HelpJump('wdfuse_help_VXeditor')};
      VK_F2     : SBCommitClick(NIL);
      VK_ESCAPE : SBRollbackClick(NIL);
      VK_TAB    : if MapWindow<>nil then MapWindow.SetFocus;
    end;
  if Shift = [ssCtrl] then
    Case Key of
      VK_LEFT   : begin
                   if VxEd.ColWidths[0] > 1 then
                    begin
                     VxEd.ColWidths[0] := VxEd.ColWidths[0] - 1;
                     PanelInfoLeft.Width := PanelInfoLeft.Width - 1;
                    end;
                  end;
      VK_RIGHT  : begin
                   VxEd.ColWidths[0] := VxEd.ColWidths[0] + 1;
                   PanelInfoLeft.Width := PanelInfoLeft.Width + 1;
                  end;
    end;
end;

procedure TVertexEditor.ForceCurrentFieldClick(Sender: TObject);
begin
 {DO_ForceCommit_VertexEditorField(VxEd.Row);}
end;

procedure TVertexEditor.SBHelpClick(Sender: TObject);
begin
 Application.HelpJump('Hlp_Vertex_Editor');
end;

procedure TVertexEditor.StayOnTopClick(Sender: TObject);
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

Procedure TVertexEditor.Reload;
var i:integer;
begin
 For i:=0 to fe.FieldCount-1 do
 With fe.Fields[i] do
 With TheVertex do
 begin
 case id of
     id_X: s:=FloatToStr(X);
     id_Z: s:=FloatToStr(Z);
 end;
   changed:=false;
 end;
end;

Procedure TVertexEditor.LoadVertex(Sc,Vx:Integer);
var TheSector:TSector;
begin
 TheSector:=l.Sectors[sc];
 TheVertex:=TheSector.Vertices[Vx];
 Caption:=Format('SC %d VX: %x',[sc,vx]);

 PanelSCName.Caption:=TheSector.Name;
 PanelFloorAlt.Caption:=Format('%f %f',[TheSector.Floor_Y,TheSector.Ceiling_Y]);
 PanelLeftOfWL.Caption:=IntToStr(GetWLFromV1(L,sc,vx));
 PanelRightOfWL.Caption:=IntToStr(GetWLFromV2(L,sc,vx));

 Reload;
end;

Procedure TVertexEditor.EditIt;
begin
 if not visible then Visible:=true;
 Self.SetFocus;
end;

procedure TVertexEditor.FormDeactivate(Sender: TObject);
var Changed:Boolean;
    i:integer;
begin
 VXEd.EditorMode:=false;
 Changed:=false;
 for i:= 0 to fe.fieldcount-1 do
  Changed:=Changed or fe.Fields[i].Changed;
 if changed then
 if MsgBox('Commit changes?','Question',mb_YesNo)=idYes then
 SBCommit.Click else Reload;
 ShapeMulti.Brush.Color:=clBtnFace;
end;

procedure TVertexEditor.FormShow(Sender: TObject);
begin
 SetFormPos(Self,VertexEditPos);
end;

procedure TVertexEditor.FormHide(Sender: TObject);
begin
 GetFormPos(Self,VertexEditPos);
 VXEditOnTop:=FormStyle=fsStayOnTop;
end;

Function TVertexEditor.L:TLevel;
begin
 Result:=TMapWindow(MapWindow).Level;
end;


procedure TVertexEditor.FormActivate(Sender: TObject);
begin
 if MultiSel.Count=0 then ShapeMulti.Brush.Color:=clBtnFace
 else ShapeMulti.Brush.Color:=clRed;
end;

end.
