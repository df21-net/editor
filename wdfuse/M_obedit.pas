unit M_obedit;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Buttons, ExtCtrls, Grids, IniFiles,
  M_Global, Menus, StdCtrls, M_OBClas;

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
    OBSeq: TMemo;
    ShapeMulti: TShape;
    SBLogic: TSpeedButton;
    SBGen: TSpeedButton;
    SBSel: TSpeedButton;
    N1: TMenuItem;
    SelectObject: TMenuItem;
    FillLogic: TMenuItem;
    CreateGenerator: TMenuItem;
    N2: TMenuItem;
    ForceCurrentField: TMenuItem;
    N3: TMenuItem;
    StayOnTop: TMenuItem;
    Panel1: TPanel;
    SBHelp: TSpeedButton;
    OBStayOnTopCheckBox: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure SBRollbackClick(Sender: TObject);
    procedure SBCommitClick(Sender: TObject);
    procedure OBEdKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure OBEdDblClick(Sender: TObject);
    procedure SBLogicClick(Sender: TObject);
    procedure SBGenClick(Sender: TObject);
    procedure SBSelClick(Sender: TObject);
    procedure ForceCurrentFieldClick(Sender: TObject);
    procedure SBHelpClick(Sender: TObject);
    procedure OBStayOnTopCheckBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ObjectEditor: TObjectEditor;

implementation
uses M_Util, M_Editor, Mapper;

{$R *.DFM}

procedure TObjectEditor.FormCreate(Sender: TObject);
var OnTop : Integer;
begin
  ObjectEditor.Left   := Ini.ReadInteger('WINDOWS', 'Object Editor  X', 0);
  ObjectEditor.Top    := Ini.ReadInteger('WINDOWS', 'Object Editor  Y', 72);
  ObjectEditor.Width  := Ini.ReadInteger('WINDOWS', 'Object Editor  W', 400);
  ObjectEditor.Height := Ini.ReadInteger('WINDOWS', 'Object Editor  H', 700);
  OnTop               := Ini.ReadInteger('WINDOWS', 'Object Editor  T', 1);
  ObEd.ColWidths[0]   := Ini.ReadInteger('WINDOWS', 'Object Editor  G', 85);
  PanelInfoLeft.Width := Ini.ReadInteger('WINDOWS', 'Object Editor  G', 85);
  if OnTop = 0 then
   begin
    StayOnTop.Checked := FALSE;
    OBStayOnTopCheckBox.Checked := FALSE;
    ObjectEditor.FormStyle := fsNormal;
   end
  else
   begin
    StayOnTop.Checked := TRUE;
    OBStayOnTopCheckBox.Checked := TRUE;
    ObjectEditor.FormStyle := fsStayOnTop;
   end;

  OBEd.Cells[0,  0] := '+Class';
  OBEd.Cells[0,  1] := '+Name';
  OBEd.Cells[0,  2] := 'X';
  OBEd.Cells[0,  3] := 'Y';
  OBEd.Cells[0,  4] := 'Z';
  OBEd.Cells[0,  5] := 'Yaw';
  OBEd.Cells[0,  6] := 'Pitch';
  OBEd.Cells[0,  7] := 'Roll';
  OBEd.Cells[0,  8] := '+Difficulty';
  OBEd.Cells[0,  9] := 'Sector';
  OBEd.Cells[0, 10] := '(Color)';
  OBEd.Cells[0, 11] := '(Type)';
  OBEd.Cells[0, 12] := '(Generator)';
end;

procedure TObjectEditor.FormDeactivate(Sender: TObject);
begin
  // This is a hack to prevent refocus on own object
  // Do not autocommit multiple items as it is dangerous
  if AUTOCOMMIT and (OB_MULTIS.Count = 0) then
    begin
      AUTOCOMMIT_FLAG := True;
      SBCommitClick(NIL);
      AUTOCOMMIT_FLAG := False;
    end;

  Ini.WriteInteger('WINDOWS', 'Object Editor  X', ObjectEditor.Left);
  Ini.WriteInteger('WINDOWS', 'Object Editor  Y', ObjectEditor.Top);
  Ini.WriteInteger('WINDOWS', 'Object Editor  W', ObjectEditor.Width);
  Ini.WriteInteger('WINDOWS', 'Object Editor  H', ObjectEditor.Height);
  if ObjectEditor.FormStyle = fsStayOnTop then
   Ini.WriteInteger('WINDOWS', 'Object Editor  T', 1)
  else
   Ini.WriteInteger('WINDOWS', 'Object Editor  T', 0);
  Ini.WriteInteger('WINDOWS', 'Object Editor  G', ObEd.ColWidths[0]);
end;

procedure TObjectEditor.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  // This is a hack to prevent refocus on own object
  // Do not autocommit multiple items as it is dangerous
  if AUTOCOMMIT and (OB_MULTIS.Count = 0) then
    begin
      AUTOCOMMIT_FLAG := True;
      SBCommitClick(NIL);
      AUTOCOMMIT_FLAG := False;
    end;
end;

procedure TObjectEditor.SBRollbackClick(Sender: TObject);
begin
  DO_Fill_ObjectEditor;
  MapWindow.SetFocus;
end;

procedure TObjectEditor.SBCommitClick(Sender: TObject);
begin
  DO_Commit_ObjectEditor;
end;


procedure TObjectEditor.OBEdKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Shift = [] then
    Case Key of
      VK_F1     : MapWindow.HelpTutorialClick(NIL);
      VK_F3,
      VK_RETURN : SBCommitClick(NIL);
      VK_ESCAPE : SBRollbackClick(NIL);
      VK_TAB    : MapWindow.SetFocus;
      VK_HOME,
      VK_END    : OBEdDblClick(NIL);
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

procedure TObjectEditor.OBStayOnTopCheckBoxMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 if StayOnTop.Checked then
  begin
   StayOnTop.Checked := FALSE;
   ObjectEditor.FormStyle := fsNormal;
  end
 else
  begin
   StayOnTop.Checked := TRUE;
   ObjectEditor.FormStyle := fsStayOnTop;
  end;
end;

procedure TObjectEditor.OBEdDblClick(Sender: TObject);
var oldclass : String;
begin
 with OBEd do
  case Row of
    0 : begin
         oldclass := Cells[1,  0];
         Cells[1,  0] := ClassEdit(Cells[1,  0]);
         if (Cells[1,  0] = 'SPIRIT') then Cells[1,  1] := 'SPIRIT'
         else
         if (Cells[1,  0] = 'SAFE')   then Cells[1,  1] := 'SAFE'
         else
         if Cells[1,  0] <> oldclass then
          begin
           Cells[1,  1] := '';
           if Cells[1,  0] = 'SPRITE' then Cells[1,  1] := ResEdit(Cells[1,  1], RST_WAX);
           if Cells[1,  0] = 'FRAME'  then Cells[1,  1] := ResEdit(Cells[1,  1], RST_FME);
           if Cells[1,  0] = '3D'     then Cells[1,  1] := ResEdit(Cells[1,  1], RST_3DO);
           if Cells[1,  0] = 'SOUND'  then Cells[1,  1] := ResEdit(Cells[1,  1], RST_SND);
          end;
         DO_FillOBColor;
         DO_FillLogic;
        end;
    1 : begin
           if Cells[1,  0] = 'SPRITE' then Cells[1,  1] := ResEdit(Cells[1,  1], RST_WAX);
           if Cells[1,  0] = 'FRAME'  then Cells[1,  1] := ResEdit(Cells[1,  1], RST_FME);
           if Cells[1,  0] = '3D'     then Cells[1,  1] := ResEdit(Cells[1,  1], RST_3DO);
           if Cells[1,  0] = 'SOUND'  then Cells[1,  1] := ResEdit(Cells[1,  1], RST_SND);
           DO_FillOBColor;
        end;
    8 : Cells[1, 8] := DiffEdit(Cells[1, 8]);
  end;
end;

procedure TObjectEditor.SBLogicClick(Sender: TObject);
begin
 DO_FillLogic;
end;

procedure TObjectEditor.SBGenClick(Sender: TObject);
begin
 DO_MakeGenerator;
end;

procedure TObjectEditor.SBSelClick(Sender: TObject);
begin
 DO_SelectObject;
end;

procedure TObjectEditor.ForceCurrentFieldClick(Sender: TObject);
begin
 DO_ForceCommit_ObjectEditorField(ObEd.Row);
end;

procedure TObjectEditor.SBHelpClick(Sender: TObject);
begin
 MapWindow.HelpTutorialClick(NIL);
end;

end.
