unit M_wledit;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Buttons, ExtCtrls, Grids, IniFiles,
  M_Global, Menus, StdCtrls;

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
    Panel8: TPanel;
    PanelSlaCli: TPanel;
    PanelElev: TPanel;
    PanelTrig: TPanel;
    CBClass: TComboBox;
    CBSlaCli: TComboBox;
    N1: TMenuItem;
    ForceCurrentField: TMenuItem;
    N2: TMenuItem;
    WLStayOnTop: TMenuItem;
    ShapeINF: TShape;
    N3: TMenuItem;
    CopyMIDTxtoTOPandBOT1: TMenuItem;
    Panel1: TPanel;
    SBHelp: TSpeedButton;
    INFButton: TSpeedButton;
    WLStayonTopCheckBox: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure SBCommitClick(Sender: TObject);
    procedure SBRollbackClick(Sender: TObject);
    procedure WLEdKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure WLEdDblClick(Sender: TObject);
    procedure CBClassClick(Sender: TObject);
    procedure CBSlaCliClick(Sender: TObject);
    procedure ForceCurrentFieldClick(Sender: TObject);
    procedure SBHelpClick(Sender: TObject);
    procedure CopyMIDTxtoTOPandBOT1Click(Sender: TObject);
    procedure SBOpenINFClick(Sender: TObject);
    procedure WLStayonTopCheckBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  WallEditor: TWallEditor;

implementation
uses M_Util, M_Editor, Mapper;

{$R *.DFM}

procedure TWallEditor.FormCreate(Sender: TObject);
var OnTop : Integer;
begin
  WallEditor.Left     := Ini.ReadInteger('WINDOWS', 'Wall Editor    X', 0);
  WallEditor.Top      := Ini.ReadInteger('WINDOWS', 'Wall Editor    Y', 72);
  WallEditor.Width    := Ini.ReadInteger('WINDOWS', 'Wall Editor    W', 295);
  WallEditor.Height   := Ini.ReadInteger('WINDOWS', 'Wall Editor    H', 730);
  WlEd.ColWidths[0]   := Ini.ReadInteger('WINDOWS', 'Wall Editor    G', 95);
  PanelInfoLeft.Width := Ini.ReadInteger('WINDOWS', 'Wall Editor    G', 95);
  OnTop               := Ini.ReadInteger('WINDOWS', 'Wall Editor    T', 1);

  if OnTop = 0 then
    begin
     WLStayOnTop.Checked := FALSE;
     WLStayonTopCheckBox.Checked := FALSE;
     WallEditor.FormStyle := fsNormal;
    end
  else
    begin
     WLStayOnTop.Checked := TRUE;
     WLStayonTopCheckBox.Checked := True;
     WallEditor.FormStyle := fsStayOnTop;
    end;

  WLEd.Cells[0,  0] := 'Adjoin';
  WLEd.Cells[0,  1] := 'Mirror';
  WLEd.Cells[0,  2] := 'Walk';
  WLEd.Cells[0,  3] := 'Light';
  WLEd.Cells[0,  4] := '+Flag 1';
  WLEd.Cells[0,  5] := '+Flag 2';
  WLEd.Cells[0,  6] := '+Flag 3';
  WLEd.Cells[0,  7] := '+Mid Tx Nam';
  WLEd.Cells[0,  8] := 'Mid Tx X Off';
  WLEd.Cells[0,  9] := 'Mid Tx Y Off';
  WLEd.Cells[0, 10] := 'Mid Tx #';
  WLEd.Cells[0, 11] := '+Top Tx Nam';
  WLEd.Cells[0, 12] := 'Top Tx X Off';
  WLEd.Cells[0, 13] := 'Top Tx Y Off';
  WLEd.Cells[0, 14] := 'Top Tx #';
  WLEd.Cells[0, 15] := '+Bot Tx Nam';
  WLEd.Cells[0, 16] := 'Bot Tx X Off';
  WLEd.Cells[0, 17] := 'Bot Tx Y Off';
  WLEd.Cells[0, 18] := 'Bot Tx #';
  WLEd.Cells[0, 19] := '+Sgn Tx Nam';
  WLEd.Cells[0, 20] := 'Sgn Tx X Off';
  WLEd.Cells[0, 21] := 'Sgn Tx Y Off';
end;

procedure TWallEditor.FormDeactivate(Sender: TObject);
begin
  SUPERHILITE := -1;

  Ini.WriteInteger('WINDOWS', 'Wall Editor    X', WallEditor.Left);
  Ini.WriteInteger('WINDOWS', 'Wall Editor    Y', WallEditor.Top);
  Ini.WriteInteger('WINDOWS', 'Wall Editor    W', WallEditor.Width);
  Ini.WriteInteger('WINDOWS', 'Wall Editor    H', WallEditor.Height);
  if WallEditor.FormStyle = fsStayOnTop then
   Ini.WriteInteger('WINDOWS', 'Wall Editor    T', 1)
  else
   Ini.WriteInteger('WINDOWS', 'Wall Editor    T', 0);
  Ini.WriteInteger('WINDOWS', 'Wall Editor    G', WlEd.ColWidths[0]);
end;

procedure TWallEditor.SBOpenINFClick(Sender: TObject);
begin
  MapWindow.SpeedButtonINFClick(Sender);
end;

procedure TWallEditor.SBCommitClick(Sender: TObject);
begin
  DO_Commit_WallEditor;
  MapWindow.SetFocus;
end;

procedure TWallEditor.SBRollbackClick(Sender: TObject);
begin
  DO_Fill_WallEditor;
  MapWindow.SetFocus;
end;

procedure TWallEditor.CopyMIDTxtoTOPandBOT1Click(Sender: TObject);
begin
 WLEd.Cells[1, 11] := WLEd.Cells[1,  7];
 WLEd.Cells[1, 15] := WLEd.Cells[1,  7];
end;

procedure TWallEditor.WLEdKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Shift = [] then
    Case Key of
      VK_F1     : MapWindow.HelpTutorialClick(NIL);
      VK_F2     : SBCommitClick(NIL);
      VK_ESCAPE : SBRollbackClick(NIL);
      VK_TAB    : MapWindow.SetFocus;
      VK_HOME,
      VK_END    : WLEdDblClick(NIL);
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

procedure TWallEditor.WLEdDblClick(Sender: TObject);
var doomdata : TIniFile;
    datastr  : String;
begin
 with WLEd do
  case Row of
    4 : Cells[1,  4] := FlagEdit(Cells[1,  4], 'wl_flag1.wdf', 'Wall Flag 1');
    5 : Cells[1,  5] := FlagEdit(Cells[1,  5], 'wl_flag2.wdf', 'Wall Flag 2');
    6 : Cells[1,  6] := FlagEdit(Cells[1,  6], 'wl_flag3.wdf', 'Wall Flag 3');
    7 : Cells[1,  7] := ResEdit(Cells[1,  7], RST_BM);
   11 : Cells[1, 11] := ResEdit(Cells[1, 11], RST_BM);
   14 : if DOOM then
         begin
          {show the line action info}
          if Cells[1, 14] <> '0' then
           begin
            doomdata := TIniFile.Create(WDFUSEdir + '\WDFDATA\DOOMDATA.WDF');
            datastr  :=doomdata.ReadString('LineDef_Actions',
                                           Format('%3.3d', [StrToInt(Cells[1,14])]),
                                           'Undefined Linedef Action!');
            MapWindow.PanelText.Caption := datastr;
            doomdata.Free;
           end;
         end;
   15 : Cells[1, 15] := ResEdit(Cells[1, 15], RST_BM);
   19 : Cells[1, 19] := ResEdit(Cells[1, 19], RST_BM);
  end;
end;

procedure TWallEditor.CBClassClick(Sender: TObject);
begin
 DO_WallEditor_Specials(CBClass.ItemIndex);
end;

procedure TWallEditor.CBSlaCliClick(Sender: TObject);
begin
 SUPERHILITE := -1;
 if GetSectorNumFromName(CBSlaCli.Items[CBSlaCli.ItemIndex], SUPERHILITE)
  then MapWindow.Map.Invalidate;
end;

procedure TWallEditor.ForceCurrentFieldClick(Sender: TObject);
begin
 DO_ForceCommit_WallEditorField(WlEd.Row);
end;

procedure TWallEditor.SBHelpClick(Sender: TObject);
begin
  MapWindow.HelpTutorialClick(NIL);
end;

procedure TWallEditor.WLStayonTopCheckBoxMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   if WLStayOnTop.Checked then
  begin
   WLStayOnTop.Checked := FALSE;
   WallEditor.FormStyle := fsNormal;
  end
 else
  begin
   WLStayOnTop.Checked := TRUE;
   WallEditor.FormStyle := fsStayOnTop;
  end;
end;

end.
