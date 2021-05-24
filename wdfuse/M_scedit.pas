unit M_scedit;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Buttons, ExtCtrls, Grids, IniFiles,
  M_Global, Menus, StdCtrls;

type
  TSectorEditor = class(TForm)
    SCEd: TStringGrid;
    PanelButtons: TPanel;
    PanelInfo: TPanel;
    PanelInfoLeft: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    PanelVXNum: TPanel;
    PanelWLnum: TPanel;
    SBCommit: TSpeedButton;
    SBRollback: TSpeedButton;
    SCEdPopupMenu: TPopupMenu;
    CommitF21: TMenuItem;
    RollbackEsc1: TMenuItem;
    ShapeMulti: TShape;
    Panel5: TPanel;
    PanelElev: TPanel;
    PanelSlaCli: TPanel;
    PanelTrig: TPanel;
    CBClass: TComboBox;
    CBSlaCli: TComboBox;
    N1: TMenuItem;
    ForceCurrentField: TMenuItem;
    N2: TMenuItem;
    StayOnTop: TMenuItem;
    ShapeINF: TShape;
    Panel1: TPanel;
    SBHelp: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure SBCommitClick(Sender: TObject);
    procedure SBRollbackClick(Sender: TObject);
    procedure SCEdKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SCEdDblClick(Sender: TObject);
    procedure CBClassClick(Sender: TObject);
    procedure CBSlaCliClick(Sender: TObject);
    procedure ForceCurrentFieldClick(Sender: TObject);
    procedure SBHelpClick(Sender: TObject);
    procedure StayOnTopClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SectorEditor: TSectorEditor;

implementation
uses M_Util, M_Editor, Mapper;

{$R *.DFM}

procedure TSectorEditor.FormCreate(Sender: TObject);
var OnTop : Integer;
begin
  SectorEditor.Left   := Ini.ReadInteger('WINDOWS', 'Sector Editor  X', 0);
  SectorEditor.Top    := Ini.ReadInteger('WINDOWS', 'Sector Editor  Y', 72);
  SectorEditor.Width  := Ini.ReadInteger('WINDOWS', 'Sector Editor  W', 186);
  SectorEditor.Height := Ini.ReadInteger('WINDOWS', 'Sector Editor  H', 412);
  OnTop               := Ini.ReadInteger('WINDOWS', 'Sector Editor  T', 0);
  ScEd.ColWidths[0]   := Ini.ReadInteger('WINDOWS', 'Sector Editor  G', 73);
  PanelInfoLeft.Width := Ini.ReadInteger('WINDOWS', 'Sector Editor  G', 73);
  if OnTop = 0 then
   begin
    StayOnTop.Checked := FALSE;
    SectorEditor.FormStyle := fsNormal;
   end
  else
   begin
    StayOnTop.Checked := TRUE;
    SectorEditor.FormStyle := fsStayOnTop;
   end;

  SCEd.Cells[0,  0] := 'Name';
  SCEd.Cells[0,  1] := 'Ambient Light';
  SCEd.Cells[0,  2] := '+Flag 1';
  SCEd.Cells[0,  3] := '+Flag 2';
  SCEd.Cells[0,  4] := '+Flag 3';
  SCEd.Cells[0,  5] := 'Floor Alt';
  SCEd.Cells[0,  6] := '+Floor Tx Nam';
  SCEd.Cells[0,  7] := 'Floor Tx X Off';
  SCEd.Cells[0,  8] := 'Floor Tx Z Off';
  SCEd.Cells[0,  9] := 'Floor Tx #';
  SCEd.Cells[0, 10] := 'Ceil. Alt';
  SCEd.Cells[0, 11] := '+Ceil. Tx Nam';
  SCEd.Cells[0, 12] := 'Ceil. Tx X Off';
  SCEd.Cells[0, 13] := 'Ceil. Tx Z Off';
  SCEd.Cells[0, 14] := 'Ceil. Tx #';
  SCEd.Cells[0, 15] := 'Second Alt';
  SCEd.Cells[0, 16] := 'Layer';
end;

procedure TSectorEditor.FormDeactivate(Sender: TObject);
begin
  SUPERHILITE := -1;

  Ini.WriteInteger('WINDOWS', 'Sector Editor  X', SectorEditor.Left);
  Ini.WriteInteger('WINDOWS', 'Sector Editor  Y', SectorEditor.Top);
  Ini.WriteInteger('WINDOWS', 'Sector Editor  W', SectorEditor.Width);
  Ini.WriteInteger('WINDOWS', 'Sector Editor  H', SectorEditor.Height);
  if SectorEditor.FormStyle = fsStayOnTop then
   Ini.WriteInteger('WINDOWS', 'Sector Editor  T', 1)
  else
   Ini.WriteInteger('WINDOWS', 'Sector Editor  T', 0);
  Ini.WriteInteger('WINDOWS', 'Sector Editor  G', ScEd.ColWidths[0]);
end;

procedure TSectorEditor.SBCommitClick(Sender: TObject);
begin
  DO_Commit_SectorEditor;
  MapWindow.SetFocus;
end;

procedure TSectorEditor.SBRollbackClick(Sender: TObject);
begin
  DO_Fill_SectorEditor;
  MapWindow.SetFocus;
end;

procedure TSectorEditor.SCEdKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Shift = [] then
    Case Key of
      VK_F1     : Application.HelpJump('wdfuse_help_SCeditor');
      VK_F2     : SBCommitClick(NIL);
      VK_ESCAPE : SBRollbackClick(NIL);
      VK_TAB    : MapWindow.SetFocus;
      VK_HOME,
      VK_END    : SCEdDblClick(NIL);
    end;
  if Shift = [ssCtrl] then
    Case Key of
      VK_LEFT   : begin
                   if ScEd.ColWidths[0] > 1 then
                    begin
                     ScEd.ColWidths[0] := ScEd.ColWidths[0] - 1;
                     PanelInfoLeft.Width := PanelInfoLeft.Width - 1;
                    end;
                  end;
      VK_RIGHT  : begin
                   ScEd.ColWidths[0] := ScEd.ColWidths[0] + 1;
                   PanelInfoLeft.Width := PanelInfoLeft.Width + 1;
                  end;
    end;
end;

procedure TSectorEditor.SCEdDblClick(Sender: TObject);
var doomdata : TIniFile;
    datastr  : String;
begin
 with SCEd do
  case Row of
    2 : Cells[1,  2] := FlagEdit(Cells[1,  2], 'sc_flag1.wdf', 'Sector Flag 1');
    3 : Cells[1,  3] := FlagEdit(Cells[1,  3], 'sc_flag2.wdf', 'Sector Flag 2');
    4 : Cells[1,  4] := FlagEdit(Cells[1,  4], 'sc_flag3.wdf', 'Sector Flag 3');
    6 : Cells[1,  6] := ResEdit(Cells[1,  6], RST_BM);
   11 : Cells[1, 11] := ResEdit(Cells[1, 11], RST_BM);
   14 : if DOOM then
         begin
          {show the line action info}
          if Cells[1, 14] <> '0' then
           begin
            doomdata := TIniFile.Create(WDFUSEdir + '\WDFDATA\DOOMDATA.WDF');
            datastr  :=doomdata.ReadString('Sector_Types',
                                           Format('%2.2d', [StrToInt(Cells[1,14])]),
                                           'Undefined Sector Type!');
            MapWindow.PanelText.Caption := datastr;
            doomdata.Free;
           end;
         end;
  end;
end;

procedure TSectorEditor.CBClassClick(Sender: TObject);
begin
 DO_SectorEditor_Specials(CBClass.ItemIndex);
end;

procedure TSectorEditor.CBSlaCliClick(Sender: TObject);
begin
 SUPERHILITE := -1;
 if GetSectorNumFromName(CBSlaCli.Items[CBSlaCli.ItemIndex], SUPERHILITE)
  then MapWindow.Map.Invalidate;
end;

procedure TSectorEditor.ForceCurrentFieldClick(Sender: TObject);
begin
 DO_ForceCommit_SectorEditorField(ScEd.Row);
end;

procedure TSectorEditor.SBHelpClick(Sender: TObject);
begin
 Application.HelpJump('wdfuse_help_SCeditor');
end;

procedure TSectorEditor.StayOnTopClick(Sender: TObject);
begin
 if StayOnTop.Checked then
  begin
   StayOnTop.Checked := FALSE;
   SectorEditor.FormStyle := fsNormal;
  end
 else
  begin
   StayOnTop.Checked := TRUE;
   SectorEditor.FormStyle := fsStayOnTop;
  end;
end;

end.
