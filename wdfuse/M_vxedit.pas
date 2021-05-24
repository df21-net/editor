unit M_vxedit;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Buttons, ExtCtrls, Grids, IniFiles,
  M_Global, Menus;

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
    procedure FormDeactivate(Sender: TObject);
    procedure SBRollbackClick(Sender: TObject);
    procedure SBCommitClick(Sender: TObject);
    procedure VXEdKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ForceCurrentFieldClick(Sender: TObject);
    procedure SBHelpClick(Sender: TObject);
    procedure StayOnTopClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  VertexEditor: TVertexEditor;

implementation
uses M_Util, M_Editor, Mapper;

{$R *.DFM}

procedure TVertexEditor.FormCreate(Sender: TObject);
var OnTop : Integer;
begin
  VertexEditor.Left   := Ini.ReadInteger('WINDOWS', 'Vertex Editor  X', 0);
  VertexEditor.Top    := Ini.ReadInteger('WINDOWS', 'Vertex Editor  Y', 72);
  VertexEditor.Width  := Ini.ReadInteger('WINDOWS', 'Vertex Editor  W', 186);
  VertexEditor.Height := Ini.ReadInteger('WINDOWS', 'Vertex Editor  H', 156);
  OnTop               := Ini.ReadInteger('WINDOWS', 'Vertex Editor  T', 0);
  VxEd.ColWidths[0]   := Ini.ReadInteger('WINDOWS', 'Vertex Editor  G', 73);
  PanelInfoLeft.Width := Ini.ReadInteger('WINDOWS', 'Vertex Editor  G', 73);
  if OnTop = 0 then
   begin
    StayOnTop.Checked := FALSE;
    VertexEditor.FormStyle := fsNormal;
   end
  else
   begin
    StayOnTop.Checked := TRUE;
    VertexEditor.FormStyle := fsStayOnTop;
   end;

  VXEd.Cells[0,  0] := 'X';
  VXEd.Cells[0,  1] := 'Z';
end;

procedure TVertexEditor.FormDeactivate(Sender: TObject);
begin
  Ini.WriteInteger('WINDOWS', 'Vertex Editor  X', VertexEditor.Left);
  Ini.WriteInteger('WINDOWS', 'Vertex Editor  Y', VertexEditor.Top);
  Ini.WriteInteger('WINDOWS', 'Vertex Editor  W', VertexEditor.Width);
  Ini.WriteInteger('WINDOWS', 'Vertex Editor  H', VertexEditor.Height);
  if VertexEditor.FormStyle = fsStayOnTop then
   Ini.WriteInteger('WINDOWS', 'Vertex Editor  T', 1)
  else
   Ini.WriteInteger('WINDOWS', 'Vertex Editor  T', 0);
  Ini.WriteInteger('WINDOWS', 'Vertex Editor  G', VxEd.ColWidths[0]);
end;

procedure TVertexEditor.SBRollbackClick(Sender: TObject);
begin
  DO_Fill_VertexEditor;
  MapWindow.SetFocus;
end;

procedure TVertexEditor.SBCommitClick(Sender: TObject);
begin
  DO_Commit_VertexEditor;
  MapWindow.SetFocus;
end;

procedure TVertexEditor.VXEdKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Shift = [] then
    Case Key of
      VK_F1     : Application.HelpJump('wdfuse_help_VXeditor');
      VK_F2     : SBCommitClick(NIL);
      VK_ESCAPE : SBRollbackClick(NIL);
      VK_TAB    : MapWindow.SetFocus;
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
 DO_ForceCommit_VertexEditorField(VxEd.Row);
end;

procedure TVertexEditor.SBHelpClick(Sender: TObject);
begin
 Application.HelpJump('wdfuse_help_VXeditor');
end;

procedure TVertexEditor.StayOnTopClick(Sender: TObject);
begin
 if StayOnTop.Checked then
  begin
   StayOnTop.Checked := FALSE;
   VertexEditor.FormStyle := fsNormal;
  end
 else
  begin
   StayOnTop.Checked := TRUE;
   VertexEditor.FormStyle := fsStayOnTop;
  end;
end;

end.
