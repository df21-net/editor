unit M_option;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, TabNotBk, StdCtrls, Buttons, FileCtrl, M_global, ExtCtrls,
  ColorGrd,
{$IFDEF WDF32}
  ComCtrls,
{$ENDIF}
  DdeMan, ShellAPI;

type
  TOptionsDialog = class(TForm)
    OptionsNotebook: TTabbedNotebook;
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    OptionsTestLaunchDF: TCheckBox;
    OptionToolsLabel2: TLabel;
    ToolsOptionsInfEditor: TEdit;
    ToolsOptionsBrowseInfEditor: TBitBtn;
    ToolsOptionsLabelVOC2WAV: TLabel;
    ToolsOptionsVoc2Wav: TEdit;
    ToolsOptionsBrowseVOC2WAV: TBitBtn;
    ComboInstall: TDriveComboBox;
    DirectoryListBox1: TDirectoryListBox;
    LabelDFInstalled: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    ComboDFCD: TDriveComboBox;
    OpenDialogInfEditor: TOpenDialog;
    OpenDialogVoc2Wav: TOpenDialog;
    RG_Backup: TRadioGroup;
    LBColors: TListBox;
    ColorDialog: TColorDialog;
    ShapeColorBack: TShape;
    ShapeColorFore: TShape;
    BitBtnColor: TBitBtn;
    CBSCDel: TCheckBox;
    CBMultiDel: TCheckBox;
    CBMultiUpd: TCheckBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    CBWLDel: TCheckBox;
    CBVXDel: TCheckBox;
    CBOBDel: TCheckBox;
    CBWallSplit: TCheckBox;
    GroupBox3: TGroupBox;
    CBMultiIns: TCheckBox;
    CBWallExtrude: TCheckBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    BNHelp: TBitBtn;
    Bevel1: TBevel;
    MemoLabels: TMemo;
    MemoCmdLines: TMemo;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    CBUsePlusVX: TCheckBox;
    CBSpecialsVX: TCheckBox;
    CBSpecialsOB: TCheckBox;
    CBUsePlusOBShad: TCheckBox;
    EDVXScale: TEdit;
    EDVXDimMax: TEdit;
    EDBigVXScale: TEdit;
    EDBigVXDimMax: TEdit;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    EDOBScale: TEdit;
    EDOBDimMax: TEdit;
    EDBigOBScale: TEdit;
    EDBigOBDimMax: TEdit;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    CBFastSCROLL: TCheckBox;
    CBFastDRAG: TCheckBox;
    BitBtnRegGOB: TBitBtn;
    BitBtnRegWDP: TBitBtn;
    BitBtnGrpStart: TBitBtn;
    DdeClientConv: TDdeClientConv;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    BitBtnRegLFD: TBitBtn;
    Image4: TImage;
    LBColors2: TListBox;
    BitBtnColor2: TBitBtn;
    ToolsOptionsLabelWAV2VOC: TLabel;
    ToolsOptionsWav2Voc: TEdit;
    ToolsOptionsBrowseWAV2VOC: TBitBtn;
    OpenDialogWav2Voc: TOpenDialog;
    CBChecksHeaders: TCheckBox;
    CBChecksAMW: TCheckBox;
    CBChecksSector: TCheckBox;
    CBChecksPlayer: TCheckBox;
    CBChecksLayering: TCheckBox;
    CBChecksGeneral: TCheckBox;
    CBChecksParsing: TCheckBox;
    CBChecksSCT: TCheckBox;
    CBChecksBM: TCheckBox;
    CBChecksFME: TCheckBox;
    CBChecksWAX: TCheckBox;
    CBChecks3DO: TCheckBox;
    CBChecksVOC: TCheckBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    GroupBox6: TGroupBox;
    GroupBox7: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    procedure FormShow(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure LBColorsClick(Sender: TObject);
    procedure LBColorsDblClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure BNHelpClick(Sender: TObject);
    procedure ToolsOptionsBrowseInfEditorClick(Sender: TObject);
    procedure ToolsOptionsBrowseVOC2WAVClick(Sender: TObject);
    procedure BitBtnGrpStartClick(Sender: TObject);
    procedure BitBtnRegWDPClick(Sender: TObject);
    procedure BitBtnRegGOBClick(Sender: TObject);
    procedure BitBtnRegLFDClick(Sender: TObject);
    procedure LBColors2Click(Sender: TObject);
    procedure LBColors2DblClick(Sender: TObject);
    procedure ToolsOptionsBrowseWAV2VOCClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OptionsDialog: TOptionsDialog;

implementation
uses Mapper;

{$R *.DFM}

procedure TOptionsDialog.FormShow(Sender: TObject);
begin
  ComboInstall.Drive           := DarkInst[1];
  if DirectoryExists(DarkInst) then
   DirectoryListBox1.Directory  := DarkInst
  else
   DirectoryListBox1.Directory  := 'c:\';
  ComboDFCD.Drive              := Char(DarkCD[1]);

  ToolsOptionsInfEditor.Text   := INFEditor;
  ToolsOptionsVoc2Wav.Text     := Voc2Wav;
  ToolsOptionsWav2Voc.Text     := Wav2Voc;

  if FileExists(WDFUSEdir + '\WDFDATA\external.wdl') then
   MemoLabels.Lines.LoadFromFile(WDFUSEdir + '\WDFDATA\external.wdl')
  else
   MemoLabels.Clear;
  if FileExists(WDFUSEdir + '\WDFDATA\external.wdn') then
   MemoCmdLines.Lines.LoadFromFile(WDFUSEdir + '\WDFDATA\external.wdn')
  else
   MemoCmdLines.Clear;

  OptionsTestLaunchDF.Checked  := TestLaunch;
  RG_Backup.ItemIndex          := Backup_Method;

  LBColors.ItemIndex           := 0;
  ShapeColorBack.Brush.Color   := col_back;
  ShapeColorFore.Brush.Color   := col_back;
  ShapeColorFore.Pen.Color     := col_select;

  CBMultiDel.Checked           := CONFIRMMultiDelete;
  CBMultiUpd.Checked           := CONFIRMMultiUpdate;
  CBMultiIns.Checked           := CONFIRMMultiInsert;
  CBSCDel.Checked              := CONFIRMSectorDelete;
  CBWLDel.Checked              := CONFIRMWallDelete;
  CBVXDel.Checked              := CONFIRMVertexDelete;
  CBOBDel.Checked              := CONFIRMObjectDelete;
  CBWallSplit.Checked          := CONFIRMWallSplit;
  CBWallExtrude.Checked        := CONFIRMWallExtrude;

  CBFastSCROLL.Checked         := FastSCROLL;
  CBFastDRAG.Checked           := FastDRAG;

  CBUsePlusVX.Checked          := UsePlusVX;
  CBUsePlusOBShad.Checked      := UsePlusOBShad;
  CBSpecialsVX.Checked         := SpecialsVX;
  CBSpecialsOB.Checked         := SpecialsOB;

  EDvxscale.Text               := IntToStr(vx_scale);
  EDvxdimmax.Text              := IntToStr(vx_dim_max);
  EDbigvxscale.Text            := IntToStr(bigvx_scale);
  EDbigvxdimmax.Text           := IntToStr(bigvx_dim_max);

  EDobscale.Text               := IntToStr(ob_scale);
  EDobdimmax.Text              := IntToStr(ob_dim_max);
  EDbigobscale.Text            := IntToStr(bigob_scale);
  EDbigobdimmax.Text           := IntToStr(bigob_dim_max);

  CBChecksAMW.Checked          := Ini.ReadBool('CHECKS', 'AMW',      TRUE);
  CBChecksSector.Checked       := Ini.ReadBool('CHECKS', 'Sector',   TRUE);
  CBChecksPlayer.Checked       := Ini.ReadBool('CHECKS', 'Player',   TRUE);
  CBChecksLayering.Checked     := Ini.ReadBool('CHECKS', 'Layering', TRUE);
  CBChecksGeneral.Checked      := Ini.ReadBool('CHECKS', 'General',  TRUE);
  CBChecksParsing.Checked      := Ini.ReadBool('CHECKS', 'Parsing',  TRUE);
  CBChecksSCT.Checked          := Ini.ReadBool('CHECKS', 'SCT',      TRUE);
  CBChecksBM.Checked           := Ini.ReadBool('CHECKS', 'BM',       TRUE);
  CBChecksFME.Checked          := Ini.ReadBool('CHECKS', 'FME',      TRUE);
  CBChecksWAX.Checked          := Ini.ReadBool('CHECKS', 'WAX',      TRUE);
  CBChecks3DO.Checked          := Ini.ReadBool('CHECKS', '3DO',      TRUE);
  CBChecksVOC.Checked          := Ini.ReadBool('CHECKS', 'VOC',      TRUE);
  CBChecksHeaders.Checked      := Ini.ReadBool('CHECKS', 'Headers',  TRUE);
end;

procedure TOptionsDialog.OKBtnClick(Sender: TObject);
begin
  DarkInst      := LabelDFInstalled.Caption;
  DarkCD[1]     := AnsiChar(ComboDFCD.Drive);

  INFEditor     := ToolsOptionsINFEditor.Text;
  Voc2Wav       := ToolsOptionsVoc2Wav.Text;
  Wav2Voc       := ToolsOptionsWav2Voc.Text;
  TestLaunch    := OptionsTestLaunchDF.Checked;
  Backup_Method := RG_Backup.ItemIndex;

  Ini.WriteString('DARK FORCES', 'Installed', DarkInst);
  DarkCD    := '?';
  DarkCD[1] := AnsiChar(ComboDFCD.Drive);
  Ini.WriteString('DARK FORCES', 'CD_Letter', DarkCD);

  Ini.WriteString('TOOLS',   'INF Editor', INFEditor);
  Ini.WriteString('TOOLS',   'VOC2WAV', Voc2Wav);
  Ini.WriteString('TOOLS',   'WAV2VOC', Wav2Voc);

  MemoLabels.Lines.SaveToFile(WDFUSEdir + '\WDFDATA\external.wdl');
  MemoCmdLines.Lines.SaveToFile(WDFUSEdir + '\WDFDATA\external.wdn');

  Ini.WriteBool('TESTING', 'Launch DF', TestLaunch);
  Ini.WriteInteger('BACKUP',  'Method', Backup_Method);

  Ini.WriteInteger('MAP-COLORS',  'back',      col_back);
  Ini.WriteInteger('MAP-COLORS',  'wall_n',    col_wall_n);
  Ini.WriteInteger('MAP-COLORS',  'wall_a',    col_wall_a);
  Ini.WriteInteger('MAP-COLORS',  'shadow',    col_shadow);
  Ini.WriteInteger('MAP-COLORS',  'grid',      col_grid);
  Ini.WriteInteger('MAP-COLORS',  'select',    col_select);
  Ini.WriteInteger('MAP-COLORS',  'multis',    col_multis);
  Ini.WriteInteger('MAP-COLORS',  'elev',      col_elev);
  Ini.WriteInteger('MAP-COLORS',  'trig',      col_trig);
  Ini.WriteInteger('MAP-COLORS',  'goal',      col_goal);
  Ini.WriteInteger('MAP-COLORS',  'secr',      col_secr);

  Ini.WriteInteger('MAP-COLORS',  'dm_low',    col_dm_low);
  Ini.WriteInteger('MAP-COLORS',  'dm_high',   col_dm_high);
  Ini.WriteInteger('MAP-COLORS',  'dm_gas',    col_dm_gas);
  Ini.WriteInteger('MAP-COLORS',  '2a_water',  col_2a_water);
  Ini.WriteInteger('MAP-COLORS',  '2a_catwlk', col_2a_catwlk);
  Ini.WriteInteger('MAP-COLORS',  'sp_sky',    col_sp_sky);
  Ini.WriteInteger('MAP-COLORS',  'sp_pit',    col_sp_pit);

  CONFIRMMultiDelete  := CBMultiDel.Checked;
  CONFIRMMultiUpdate  := CBMultiUpd.Checked;
  CONFIRMMultiInsert  := CBMultiIns.Checked;

  CONFIRMSectorDelete := CBSCDel.Checked;
  CONFIRMWallDelete   := CBWLDel.Checked;
  CONFIRMVertexDelete := CBVXDel.Checked;
  CONFIRMObjectDelete := CBOBDel.Checked;

  CONFIRMWallSplit    := CBWallSplit.Checked;
  CONFIRMWallExtrude  := CBWallExtrude.Checked;

  Ini.WriteBool('CONFIRM', 'MultiDelete',  CONFIRMMultiDelete);
  Ini.WriteBool('CONFIRM', 'MultiUpdate',  CONFIRMMultiUpdate);
  Ini.WriteBool('CONFIRM', 'MultiInsert',  CONFIRMMultiInsert);
  Ini.WriteBool('CONFIRM', 'SectorDelete', CONFIRMSectorDelete);
  Ini.WriteBool('CONFIRM', 'WallDelete',   CONFIRMWallDelete);
  Ini.WriteBool('CONFIRM', 'VertexDelete', CONFIRMVertexDelete);
  Ini.WriteBool('CONFIRM', 'ObjectDelete', CONFIRMObjectDelete);
  Ini.WriteBool('CONFIRM', 'WallSplit',    CONFIRMWallSplit);
  Ini.WriteBool('CONFIRM', 'WallExtrude',  CONFIRMWallExtrude);

  FastSCROLL := CBFastSCROLL.Checked;
  FastDRAG   := CBFastDRAG.Checked;

  Ini.WriteBool('FINE TUNING',  'FastScroll',  FastSCROLL);
  Ini.WriteBool('FINE TUNING',  'FastDrag',    FastDRAG);

  UsePlusVX     := CBUsePlusVX.Checked;
  UsePlusOBShad := CBUsePlusOBShad.Checked;
  SpecialsVX    := CBSpecialsVX.Checked;
  SpecialsOB    := CBSpecialsOB.Checked;

  Ini.WriteBool('FINE TUNING',  'UsePlusVX',     CBUsePlusVX.Checked);
  Ini.WriteBool('FINE TUNING',  'UsePlusOBShad', CBUsePlusOBShad.Checked);
  Ini.WriteBool('FINE TUNING',  'SpecialsVX',    CBSpecialsVX.Checked);
  Ini.WriteBool('FINE TUNING',  'SpecialsOB',    CBSpecialsOB.Checked);


  vx_scale      := StrToInt(EDvxscale.Text);
  vx_dim_max    := StrToInt(EDvxdimmax.Text);
  bigvx_scale   := StrToInt(EDbigvxscale.Text);
  bigvx_dim_max := StrToInt(EDbigvxdimmax.Text);

  ob_scale      := StrToInt(EDobscale.Text);
  ob_dim_max    := StrToInt(EDobdimmax.Text);
  bigob_scale   := StrToInt(EDbigobscale.Text);
  bigob_dim_max := StrToInt(EDbigobdimmax.Text);

  Ini.WriteInteger('FINE TUNING',  'vx_scale',      vx_scale);
  Ini.WriteInteger('FINE TUNING',  'vx_dim_max',    vx_dim_max);
  Ini.WriteInteger('FINE TUNING',  'bigvx_scale',   bigvx_scale);
  Ini.WriteInteger('FINE TUNING',  'bigvx_dim_max', bigvx_dim_max);

  Ini.WriteInteger('FINE TUNING',  'ob_scale',      ob_scale);
  Ini.WriteInteger('FINE TUNING',  'ob_dim_max',    ob_dim_max);
  Ini.WriteInteger('FINE TUNING',  'bigob_scale',   bigob_scale);
  Ini.WriteInteger('FINE TUNING',  'bigob_dim_max', bigob_dim_max);

  Ini.WriteBool('CHECKS', 'AMW',      CBChecksAMW.Checked);
  Ini.WriteBool('CHECKS', 'Sector',   CBChecksSector.Checked);
  Ini.WriteBool('CHECKS', 'Player',   CBChecksPlayer.Checked);
  Ini.WriteBool('CHECKS', 'Layering', CBChecksLayering.Checked);
  Ini.WriteBool('CHECKS', 'General',  CBChecksGeneral.Checked);
  Ini.WriteBool('CHECKS', 'Parsing',  CBChecksParsing.Checked);
  Ini.WriteBool('CHECKS', 'SCT',      CBChecksSCT.Checked);
  Ini.WriteBool('CHECKS', 'BM',       CBChecksBM.Checked);
  Ini.WriteBool('CHECKS', 'FME',      CBChecksFME.Checked);
  Ini.WriteBool('CHECKS', 'WAX',      CBChecksWAX.Checked);
  Ini.WriteBool('CHECKS', '3DO',      CBChecks3DO.Checked);
  Ini.WriteBool('CHECKS', 'VOC',      CBChecksVOC.Checked);
  Ini.WriteBool('CHECKS', 'Headers',  CBChecksHeaders.Checked);

  MapWindow.Map.Invalidate;
end;

procedure TOptionsDialog.CancelBtnClick(Sender: TObject);
begin
  col_back   := Ini.ReadInteger('MAP-COLORS',  'back',   Ccol_back);
  col_wall_n := Ini.ReadInteger('MAP-COLORS',  'wall_n', Ccol_wall_n);
  col_wall_a := Ini.ReadInteger('MAP-COLORS',  'wall_a', Ccol_wall_a);
  col_shadow := Ini.ReadInteger('MAP-COLORS',  'shadow', Ccol_shadow);
  col_grid   := Ini.ReadInteger('MAP-COLORS',  'grid',   Ccol_grid);
  col_select := Ini.ReadInteger('MAP-COLORS',  'select', Ccol_select);
  col_multis := Ini.ReadInteger('MAP-COLORS',  'multis', Ccol_multis);
  col_elev   := Ini.ReadInteger('MAP-COLORS',  'elev',   Ccol_elev);
  col_trig   := Ini.ReadInteger('MAP-COLORS',  'trig',   Ccol_trig);
  col_goal   := Ini.ReadInteger('MAP-COLORS',  'goal',   Ccol_goal);
  col_secr   := Ini.ReadInteger('MAP-COLORS',  'secr',   Ccol_secr);
  MapWindow.Color := col_back;
  MapWindow.Map.Invalidate;
end;

procedure TOptionsDialog.LBColorsClick(Sender: TObject);
begin
 CASE LBColors.ItemIndex OF
  0: ShapeColorFore.Pen.Color   := col_select;
  1: ShapeColorFore.Pen.Color   := col_multis;
  2: ShapeColorFore.Pen.Color   := col_wall_n;
  3: ShapeColorFore.Pen.Color   := col_wall_a;
  4: ShapeColorFore.Pen.Color   := col_shadow;
  5: ShapeColorFore.Pen.Color   := col_grid;
  6: ShapeColorFore.Pen.Color   := col_elev;
  7: ShapeColorFore.Pen.Color   := col_trig;
  8: ShapeColorFore.Pen.Color   := col_goal;
  9: ShapeColorFore.Pen.Color   := col_secr;
  ELSE ShapeColorFore.Pen.Color := col_back;
 END;
end;

procedure TOptionsDialog.LBColors2Click(Sender: TObject);
begin
 CASE LBColors2.ItemIndex OF
  0: ShapeColorFore.Brush.Color   := col_back;
  1: ShapeColorFore.Brush.Color   := col_dm_low;
  2: ShapeColorFore.Brush.Color   := col_dm_high;
  3: ShapeColorFore.Brush.Color   := col_dm_gas;
  4: ShapeColorFore.Brush.Color   := col_2a_water;
  5: ShapeColorFore.Brush.Color   := col_2a_catwlk;
  6: ShapeColorFore.Brush.Color   := col_sp_sky;
  7: ShapeColorFore.Brush.Color   := col_sp_pit;
  ELSE ShapeColorFore.Brush.Color := col_back;
 END;
end;

procedure TOptionsDialog.LBColorsDblClick(Sender: TObject);
var TheColor : TColor;
begin
 CASE LBColors.ItemIndex OF
  0: TheColor   := col_select;
  1: TheColor   := col_multis;
  2: TheColor   := col_wall_n;
  3: TheColor   := col_wall_a;
  4: TheColor   := col_shadow;
  5: TheColor   := col_grid;
  6: TheColor   := col_elev;
  7: TheColor   := col_trig;
  8: TheColor   := col_goal;
  9: TheColor   := col_secr;
 END;

 ColorDialog.Color := TheColor;
 if ColorDialog.Execute then
  begin
   TheColor := ColorDialog.Color;
   CASE LBColors.ItemIndex OF
    0: col_select := TheColor;
    1: col_multis := TheColor;
    2: col_wall_n := TheColor;
    3: col_wall_a := TheColor;
    4: col_shadow := TheColor;
    5: col_grid   := TheColor;
    6: col_elev   := TheColor;
    7: col_trig   := TheColor;
    8: col_goal   := TheColor;
    9: col_secr   := TheColor;
   END;
   ShapeColorFore.Pen.Color := TheColor;
   MapWindow.Map.Invalidate;
  end;
end;

procedure TOptionsDialog.LBColors2DblClick(Sender: TObject);
var TheColor : TColor;
begin
 CASE LBColors2.ItemIndex OF
  0: TheColor   := col_back;
  1: TheColor   := col_dm_low;
  2: TheColor   := col_dm_high;
  3: TheColor   := col_dm_gas;
  4: TheColor   := col_2a_water;
  5: TheColor   := col_2a_catwlk;
  6: TheColor   := col_sp_sky;
  7: TheColor   := col_sp_pit;
 END;

 ColorDialog.Color := TheColor;
 if ColorDialog.Execute then
  begin
   TheColor := ColorDialog.Color;
   CASE LBColors2.ItemIndex OF
    0: begin
        col_back   := TheColor;
        ShapeColorBack.Brush.Color := col_back;
        {
        MapWindow.Color := col_back;
        }
        MapWindow.PanelMapALL.Color := col_back;
       end;
    1: col_dm_low     := TheColor;
    2: col_dm_high    := TheColor;
    3: col_dm_gas     := TheColor;
    4: col_2a_water   := TheColor;
    5: col_2a_catwlk  := TheColor;
    6: col_sp_sky     := TheColor;
    7: col_sp_pit     := TheColor;
   END;
   ShapeColorFore.Brush.Color := TheColor;
   MapWindow.Map.Invalidate;
  end;
end;

procedure TOptionsDialog.BNHelpClick(Sender: TObject);
begin
 {Application.HelpJump('wdfuse_help_options');}
 case OptionsNotebook.PageIndex of
  0: Application.HelpJump('wdfuse_help_optionsdarkforces');
  1: Application.HelpJump('wdfuse_help_optionsbackupandtest');
  2: Application.HelpJump('wdfuse_help_optionsconfirmations');
  3: Application.HelpJump('wdfuse_help_optionschecks');
  4: Application.HelpJump('wdfuse_help_optionsfinetuning');
  5: Application.HelpJump('wdfuse_help_optionscolors');
  6: Application.HelpJump('wdfuse_help_optionsexternal');
  7: Application.HelpJump('wdfuse_help_optionswindows');
 end;
end;

procedure TOptionsDialog.ToolsOptionsBrowseInfEditorClick(Sender: TObject);
begin
 with OpenDialogInfEditor do
  begin
   Filename := INFEditor;
   InitialDir := ExtractFilePath(INFEditor);

   if Execute then
     ToolsOptionsInfEditor.Text := FileName;
  end;
end;

procedure TOptionsDialog.ToolsOptionsBrowseVOC2WAVClick(Sender: TObject);
begin
 with OpenDialogVoc2Wav do
  begin
   if UpperCase(Voc2Wav) = 'VOC2WAV.PIF' then
    begin
     FileName   := WDFUSEdir + '\VOC2WAV.PIF';
     InitialDir := WDFUSEDir;
    end
   else
    begin
     Filename := Voc2Wav;
     InitialDir := ExtractFilePath(Voc2Wav);
    end;

   if Execute then
     ToolsOptionsVoc2Wav.Text := FileName;
  end;
end;

procedure TOptionsDialog.ToolsOptionsBrowseWAV2VOCClick(Sender: TObject);
begin
 with OpenDialogWav2Voc do
  begin
   if UpperCase(Wav2Voc) = 'WAV2VOC.PIF' then
    begin
     FileName   := WDFUSEdir + '\WAV2VOC.PIF';
     InitialDir := WDFUSEDir;
    end
   else
    begin
     Filename := Wav2Voc;
     InitialDir := ExtractFilePath(Wav2Voc);
    end;

   if Execute then
     ToolsOptionsWav2Voc.Text := FileName;
  end;
end;

procedure TOptionsDialog.BitBtnGrpStartClick(Sender: TObject);
var cmd : TStringList;
begin
cmd := TStringList.Create;
cmd.Add('[DeleteGroup("WDFUSE")]');
cmd.Add('[CreateGroup("WDFUSE")]');
cmd.Add('[ShowGroup("Win DFUSE",1)]');
cmd.Add('[AddItem('+WDFUSEDir+'\wdfuse.exe,WDFUSE,'+WDFUSEDir+'\wdfuse.exe)]');
cmd.Add('[AddItem('+WDFUSEDir+'\wdfuse32.exe,WDFUSE32,'+WDFUSEDir+'\wdfuse32.exe)]');
cmd.Add('[AddItem('+WDFUSEDir+'\wdfuse.hlp,WDFUSE Help,'+WDFUSEDir+'\wdfuse.hlp)]');
cmd.Add('[AddItem('+WDFUSEDir+'\wdftutor.hlp,WDFUSE Tutorial,'+WDFUSEDir+'\wdftutor.hlp)]');
cmd.Add('[AddItem('+WDFUSEDir+'\df_specs.hlp,DARK FORCES Specs,'+WDFUSEDir+'\df_specs.hlp)]');

if DdeClientConv.OpenLink then
 begin
  DdeClientConv.ExecuteMacroLines(cmd, TRUE);
  DdeClientConv.CloseLink;
 end;

cmd.Free;
end;

procedure TOptionsDialog.BitBtnRegWDPClick(Sender: TObject);
var Key     : HKey;
    Value   : array[0..127] of char;
begin
if RegCreateKey(HKEY_CLASSES_ROOT, '.wdp', Key) = ERROR_SUCCESS then
 begin
  strPCopy(Value,  'wdp_auto_file');
  RegSetValue(Key, '', REG_SZ, Value, StrLen(Value));
 end;

if RegCreateKey(HKEY_CLASSES_ROOT, '\wdp_auto_file', Key) = ERROR_SUCCESS then
 begin
  strPCopy(Value,  'WDFUSE Project Files');
  RegSetValue(Key, '', REG_SZ, Value, StrLen(Value));
 end;

if RegCreateKey(HKEY_CLASSES_ROOT, '\wdp_auto_file\shell\open\command', Key) = ERROR_SUCCESS then
 begin
{$IFNDEF WDF32}
  strPCopy(Value,  WDFUSEdir + '\wdfuse.exe %1');
{$ELSE}
  strPCopy(Value,  WDFUSEdir + '\wdfuse32.exe %1');
{$ENDIF}
  RegSetValue(Key, '', REG_SZ, Value, StrLen(Value));
 end;
end;

procedure TOptionsDialog.BitBtnRegGOBClick(Sender: TObject);
var Key     : HKey;
    Value   : array[0..127] of char;
begin

if RegCreateKey(HKEY_CLASSES_ROOT, '.gob', Key) = ERROR_SUCCESS then
 begin
  strPCopy(Value,  'gob_auto_file');
  RegSetValue(Key, '', REG_SZ, Value, StrLen(Value));
 end;

if RegCreateKey(HKEY_CLASSES_ROOT, '\gob_auto_file', Key) = ERROR_SUCCESS then
 begin
  strPCopy(Value,  'Dark Forces GOB Files');
  RegSetValue(Key, '', REG_SZ, Value, StrLen(Value));
 end;

if RegCreateKey(HKEY_CLASSES_ROOT, '\gob_auto_file\shell\open\command', Key) = ERROR_SUCCESS then
 begin
{$IFNDEF WDF32}
  strPCopy(Value,  WDFUSEdir + '\wdfuse.exe %1');
{$ELSE}
  strPCopy(Value,  WDFUSEdir + '\wdfuse32.exe %1');
{$ENDIF}
  RegSetValue(Key, '', REG_SZ, Value, StrLen(Value));
 end;
end;

procedure TOptionsDialog.BitBtnRegLFDClick(Sender: TObject);
var Key     : HKey;
    Value   : array[0..127] of char;
begin

if RegCreateKey(HKEY_CLASSES_ROOT, '.lfd', Key) = ERROR_SUCCESS then
 begin
  strPCopy(Value,  'lfd_auto_file');
  RegSetValue(Key, '', REG_SZ, Value, StrLen(Value));
 end;

if RegCreateKey(HKEY_CLASSES_ROOT, '\lfd_auto_file', Key) = ERROR_SUCCESS then
 begin
  strPCopy(Value,  'Dark Forces LFD Files');
  RegSetValue(Key, '', REG_SZ, Value, StrLen(Value));
 end;

if RegCreateKey(HKEY_CLASSES_ROOT, '\lfd_auto_file\shell\open\command', Key) = ERROR_SUCCESS then
 begin
{$IFNDEF WDF32}
  strPCopy(Value,  WDFUSEdir + '\wdfuse.exe %1');
{$ELSE}
  strPCopy(Value,  WDFUSEdir + '\wdfuse32.exe %1');
{$ENDIF}
  RegSetValue(Key, '', REG_SZ, Value, StrLen(Value));
 end;
end;



end.
