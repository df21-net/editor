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
    Panel7: TPanel;
    PanelVXNum: TPanel;
    PanelWLnum: TPanel;
    PanelSCHeight : TPanel;
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
    SCStayOnTopCheckBox: TCheckBox;
    INFButton: TSpeedButton;
    INFBUttonOff: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure SBOpenINFClick(Sender: TObject);
    procedure SBRollbackClick(Sender: TObject);
    procedure SCEdKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SCEdDblClick(Sender: TObject);
    procedure CBClassClick(Sender: TObject);
    procedure CBSlaCliClick(Sender: TObject);
    procedure ForceCurrentFieldClick(Sender: TObject);
    procedure SBHelpClick(Sender: TObject);
    procedure StayOnTopClick(Sender: TObject);
    procedure SBCommitClick(Sender: TObject);
    procedure SCStayOnTopCheckBoxClick(Sender: TObject);
    procedure SCEdMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure UpdateTexturePos(cell_idx : integer; increment : boolean = True);
    procedure MoveTexture(direction : Integer);
  private
    SC_MODIFIED : Boolean ;
    OrigSC : TSector;
    { Private declarations }
    texture_type : integer;
  public
    { Public declarations }
  end;

var
  SectorEditor: TSectorEditor;

implementation
uses M_Util, M_Editor, Mapper, infedit2;

{$R *.DFM}


procedure TSectorEditor.FormCreate(Sender: TObject);
var OnTop : Integer;
begin
  SectorEditor.Left   := Ini.ReadInteger('WINDOWS', 'Sector Editor  X', 0);
  SectorEditor.Top    := Ini.ReadInteger('WINDOWS', 'Sector Editor  Y', 90);
  SectorEditor.Width  := Ini.ReadInteger('WINDOWS', 'Sector Editor  W', 280);
  SectorEditor.Height := Ini.ReadInteger('WINDOWS', 'Sector Editor  H', 566);
  OnTop               := Ini.ReadInteger('WINDOWS', 'Sector Editor  T', 1);
  ScEd.ColWidths[0]   := Ini.ReadInteger('WINDOWS', 'Sector Editor  G', 90);
  PanelInfoLeft.Width := Ini.ReadInteger('WINDOWS', 'Sector Editor  G', 90);

  texture_type := 0;

  if OnTop = 0 then
   begin
    StayOnTop.Checked := FALSE;
    SCStayOnTopCheckBox.Checked := FALSE;
    SectorEditor.FormStyle := fsNormal;
   end
  else
   begin
    StayOnTop.Checked := TRUE;
    SCStayOnTopCheckBox.Checked := TRUE;
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

  // This is a hack to prevent refocus on own object
  // Don't autocommit when you have multiple sectors - dangerous!
  if AUTOCOMMIT and (SC_MULTIS.Count = 0) then
    begin
      AUTOCOMMIT_FLAG := True;
      DO_Commit_SectorEditor;
      AUTOCOMMIT_FLAG := False;
    end;

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

procedure TSectorEditor.FormKeyPress(Sender: TObject; var Key: Char);
begin
   if Integer(Key) = 13 then
     SBCommitClick(NIL);
end;

// Ignore shift changes
procedure TSectorEditor.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
var stcut : string;
    state : integer;
begin
 stcut := ShortCutToText(ShortCut(Msg.CharCode, KeyDataToShiftState(Msg.KeyData)));
 if (stcut = 'Shift+Up') or (stcut = 'Shift+Down') or (stcut = 'Shift+Left') or (stcut = 'Shift+Right') then
    Handled := True;
end;

procedure TSectorEditor.SBOpenINFClick(Sender: TObject);
begin
  MapWindow.SpeedButtonINFClick(Sender);
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
      VK_F1     : MapWindow.HelpTutorialClick(NIL);
      VK_F2     : MapWindow.SpeedButtonINFClick(NIL);
      VK_F3,
      VK_RETURN : SBCommitClick(NIL);
      VK_ESCAPE : SBRollbackClick(NIL);
      VK_TAB    : MapWindow.SetFocus;
      VK_HOME,
      VK_END    : SCEdDblClick(NIL);
    end;

   // Move floor/ceiling
   if Shift = [ssShift] then
     case Key of
      VK_RIGHT  : MoveTexture(1);
      VK_LEFT   : MoveTexture(0);
      VK_UP     : MoveTexture(3);
      VK_DOWN   : MoveTexture(2);
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

procedure TSectorEditor.SCEdMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

  // Figure out the texture type
  with SCED do
    case ROW of
      5,
      6,
      7,
      8:   texture_type := 0; // Floor
      10,
      11,
      12,
      13 : texture_type := 1; // Ceiling
   end;

  // This is a hack to prevent refocus on own object
  if AUTOCOMMIT and (SC_MULTIS.Count = 0) then
    begin
      AUTOCOMMIT_FLAG := True;
      DO_Commit_SectorEditor;
      AUTOCOMMIT_FLAG := False;
    end;
end;

procedure TSectorEditor.SCStayOnTopCheckBoxClick(Sender: TObject);
begin
  if StayOnTop.Checked then
  begin
   StayOnTop.Checked := FALSE;
   SCStayOnTopCheckBox.Checked := False;
   SectorEditor.FormStyle := fsNormal;
  end
 else
  begin
   SCStayOnTopCheckBox.Checked := True;
   StayOnTop.Checked := TRUE;
   SectorEditor.FormStyle := fsStayOnTop;
  end;
end;

procedure TSectorEditor.SCEdDblClick(Sender: TObject);
var doomdata : TIniFile;
    datastr  : String;
    ALong    : LongInt;
    Code     : Integer;
begin
 with SCEd do
  case Row of
    2 : Cells[1,  2] := FlagEdit(Cells[1,  2], 'sc_flag1.wdf', 'Sector Flag 1');
    3 : Cells[1,  3] := FlagEdit(Cells[1,  3], 'sc_flag2.wdf', 'Sector Flag 2');
    4 : Cells[1,  4] := FlagEdit(Cells[1,  4], 'sc_flag3.wdf', 'Sector Flag 3');
    6 : Cells[1,  6] := ResEdit(Cells[1,  6], RST_BM, RST_TYPE_FLOOR );
   11 : begin
         // Special cast to flip skies vs ceiling
         Val( Cells[1, 2], ALong, Code);
         if (Code = 0) then
           begin
             if (ALong mod 2 = 1) then
               Cells[1, 11] := ResEdit(Cells[1, 11], RST_BM, RST_TYPE_SKY)
             else
               Cells[1, 11] := ResEdit(Cells[1, 11], RST_BM, RST_TYPE_CEILING);
           end;
        end;
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

  if AUTOCOMMIT and (SC_MULTIS.Count = 0) then
    SectorEditor.SBCommitClick(NIL);
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
  MapWindow.HelpTutorialClick(NIL);
end;

procedure TSectorEditor.StayOnTopClick(Sender: TObject);
begin
 if StayOnTop.Checked then
  begin
   StayOnTop.Checked := FALSE;
   SCStayOnTopCheckBox.Checked := False;
   SectorEditor.FormStyle := fsNormal;
  end
 else
  begin
   SCStayOnTopCheckBox.Checked := True;
   StayOnTop.Checked := TRUE;
   SectorEditor.FormStyle := fsStayOnTop;
  end;
end;


// Update the cell value
procedure TSectorEditor.UpdateTexturePos(cell_idx : integer; increment : boolean = True);
var AReal : Real;
    Code : Integer;
begin
  with SCEd do
    begin
      Val(Cells[1,  cell_idx], AReal, Code);
      if Code = 0 then
         begin
           if increment then
              AReal := Areal + TEXTURE_OFFSET
           else
              AReal := Areal - TEXTURE_OFFSET;
           Cells[1,  cell_idx] := PosTrim(Areal);
         end;
    end;

end;

{     Direction definition is

      0 = Increase X
      1 = Decrease X
      2 = Increase Y
      3 = Decrease Y

      CELL OFFSETS
      5,
      6,
      7,
      8: texture_type := 0;  // floor
      10,
      11
      12,
      13 : texture_type := 1; // ceiling}
procedure TSectorEditor.MoveTexture(direction : Integer);
begin

  case direction of
    0 :  UpdateTexturePos(Texture_Type*5 + 7);
    1 :  UpdateTexturePos(Texture_Type*5 + 7, False);
    2 :  UpdateTexturePos(Texture_Type*5 + 8);
    3 :  UpdateTexturePos(Texture_Type*5 + 8, False);
  end;

  if AUTOCOMMIT and (WL_MULTIS.Count = 0) then
    begin
      NO_INVALIDATE := True;
      DO_Commit_SectorEditor;
      UpdateShowCase;
      NO_INVALIDATE := False;
    end;
end;

end.
