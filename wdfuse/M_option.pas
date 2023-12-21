unit M_option;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, TabNotBk, StdCtrls, Buttons, FileCtrl, M_global, ExtCtrls,
  ColorGrd, StrUtils, registry, IOUtils, System.RegularExpressions,
  System.RegularExpressionsCore, UrlMon, System.zip,
{$IFDEF WDF32}
  ComCtrls,
{$ENDIF}
  DdeMan, ShellAPI, Vcl.Imaging.pngimage;

type
  TOptionsDialog = class(TForm)
    OptionsNotebook: TTabbedNotebook;
    SteamButton: TBitBtn;
    CancelBtn: TBitBtn;
    OptionsTestLaunchDF: TCheckBox;
    OptionToolsLabel2: TLabel;
    ToolsOptionsInfEditor: TEdit;
    ToolsOptionsBrowseInfEditor: TBitBtn;
    ToolsOptionsLabelVOC2WAV: TLabel;
    ToolsOptionsVoc2Wav: TEdit;
    ToolsOptionsBrowseVOC2WAV: TBitBtn;
    Panel1: TPanel;
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
    LaunchLabel: TLabel;
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
    RenderPathLabel: TLabel;
    RenderPathEdit: TEdit;
    RenderPathBrowse: TBitBtn;
    Image5: TImage;
    RenderAboutBackground: TPanel;
    RenderAbout1: TPanel;
    RenderAbout2: TPanel;
    RenderAbout4: TPanel;
    RenderAbout5: TPanel;
    RenderAbout3: TPanel;
    RenderDownload: TImage;
    OpenDialogueRender: TOpenDialog;
    RenderPath: TLabel;
    OKBtn: TBitBtn;
    GOGButton: TBitBtn;
    Panel3: TPanel;
    OptionsLaunchPrevPRJChkBox: TCheckBox;
    Label4: TLabel;
    OptionsEnableLogging: TCheckBox;
    OptionsEnableLoggingInfo: TLabel;
    LoggingPanel: TEdit;
    Label3: TLabel;
    OptionsViewLogFile: TButton;
    OptionsViewLogFolder: TButton;
    OptionsAutoSave: TCheckBox;
    OptionsSkipCutscene: TCheckBox;
    Label15: TLabel;
    CBAutoCommit: TCheckBox;
    Label16: TLabel;
    CBNormalizeWalls: TCheckBox;
    UseShowCaseCheckBox: TCheckBox;
    StartShowCaseCheckBox: TCheckBox;
    CBUseAltPan : TCheckBox;
    Panel8: TPanel;
    Label18: TLabel;
    DarkForcesBrowse: TBitBtn;
    DosBoxBrowse: TBitBtn;
    TFEBrowse: TBitBtn;
    EngineTypeBox: TRadioGroup;
    LauncherType: TGroupBox;
    LauncherDarkForcesLabel: TEdit;
    LauncherDosBoxLabel: TEdit;
    LauncherTFELabel : TEdit;
    OriginButton: TBitBtn;
    GroupBox8: TGroupBox;
    OpenDialogueTFE: TOpenDialog;
    OpenDialogueDosBox: TOpenDialog;
    OpenDialogueDark: TOpenDialog;
    LauncherTypeLabel: TPanel;
    BackupLimit: TEdit;
    Label17: TLabel;
    RenderDownloading: TImage;
    Label19: TLabel;
    procedure FormShow(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
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
    procedure RenderDownloadClick(Sender: TObject);
    procedure DosBoxBrowseClick(Sender: TObject);
    procedure TfeBrowseClick(Sender: TObject);
    procedure SteamButtonClick(Sender: TObject);
    procedure GOGButtonClick(Sender: TObject);
    procedure OriginButtonClick(Sender: TObject);
    procedure RenderBrowseClick(Sender: TObject);
    procedure RenderAbout4Click(Sender: TObject);
    procedure FindDosBoxConf(DOSBOX_FLD: String);
    procedure OptionsViewLogFolderClick(Sender: TObject);
    procedure OptionsViewLogFileClick(Sender: TObject);
    procedure DarkForcesBrowseClick(Sender: TObject);
    procedure EngineTypeBoxClick(Sender: TObject);
    procedure RefreshFields;
    procedure BackupLimitChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OptionsDialog: TOptionsDialog;
  LoadingForm : boolean;

implementation
uses Mapper;

{$R *.DFM}

procedure TOptionsDialog.FormShow(Sender: TObject);
begin
  LoadingForm := True;
  RenderPath.Caption            := RenderInst;
  UseShowCaseCheckBox.Checked   := UseShowCase;
  StartShowCaseCheckBox.Checked := AutoStartShowCase;

  ToolsOptionsInfEditor.Text   := INFEditor;

  if not FileExists(Voc2Wav) and FileExists(WDFUSEDir + '\WDFSOUND\SOX.EXE') then
    Voc2Wav := WDFUSEDir + '\WDFSOUND\SOX.EXE';
  if not FileExists(Wav2Voc) and FileExists(WDFUSEDir + '\WDFSOUND\SOX.EXE') then
    Wav2Voc := WDFUSEDir + '\WDFSOUND\SOX.EXE';


  ToolsOptionsVoc2Wav.Text     := Voc2Wav;
  ToolsOptionsWav2Voc.Text     := Wav2Voc;

  if FileExists(WDFUSEdir + '\WDFDATA\external.wdl') then
   MemoLabels.Lines.LoadFromFile(WDFUSEdir + '\WDFDATA\external.wdl')
  else
   begin
     MemoLabels.Clear;
   end;
  if FileExists(WDFUSEdir + '\WDFDATA\external.wdn') then
   MemoCmdLines.Lines.LoadFromFile(WDFUSEdir + '\WDFDATA\external.wdn')
  else
   MemoCmdLines.Clear;

  OptionsTestLaunchDF.Checked        := TestLaunch;
  OptionsLaunchPrevPRJChkBox.Checked := LOADPREVPRJ;
  OptionsAutoSave.Checked            := AUTOSAVE;
  OptionsSkipCutscene.Checked        := SKIPCUT;

  RG_Backup.ItemIndex          := Backup_Method;

  LBColors.ItemIndex           := 0;
  ShapeColorBack.Brush.Color   := col_back;
  ShapeColorFore.Brush.Color   := col_back;
  ShapeColorFore.Pen.Color     := col_select;

  CBAutoCommit.Checked         := AUTOCOMMIT;
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
  CBUseAltPan.checked          := USE_ALT_PAN;


  CBUsePlusVX.Checked          := UsePlusVX;
  CBUsePlusOBShad.Checked      := UsePlusOBShad;
  CBSpecialsVX.Checked         := SpecialsVX;
  CBSpecialsOB.Checked         := SpecialsOB;
  CBNormalizeWalls.Checked     := NORMALIZE_WALLS;

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


  DOSBOX_PATH   := Ini.ReadString('DARK FORCES', 'DOSBOX_PATH', 'c:\dark\dosbox.exe');
  DOSBOX_CONF   := Ini.ReadString('DARK FORCES', 'DOSBOX_CONF', '');
  LAUNCHER_TYPE := Ini.ReadString('DARK FORCES', 'LAUNCHER_TYPE', 'Custom');
  ENGINE_TYPE   := Ini.ReadString('DARK FORCES', 'ENGINE_TYPE', 'JEDI');
  TFE_FLD       := Ini.ReadString('DARK FORCES', 'TFE_FLD', 'c:\dark');
  MAXBACKUPS    := Ini.ReadInteger('DARK FORCES', 'MAXBACKUPS', 150);

  UseLog        := Ini.ReadBool('DARK FORCES', 'Logger', True);
  BackupLimit.text := IntToStr(MAXBACKUPS);

  if ENGINE_TYPE = 'JEDI' then
    EngineTypeBox.ItemIndex := 0
  else
    EngineTypeBox.ItemIndex := 1;

  OptionsTestLaunchDF.Checked := TestLaunch;
  OptionsEnableLogging.Checked := UseLog;
  LauncherDosBoxLabel.Text := DOSBOX_PATH;
  LoggingPanel.Text := LogPath;
  LoadingForm := False;
  darkexe := ExcludeTrailingPathDelimiter(darkinst) + '\Dark.exe';
  TFE_EXE       := ExcludeTrailingPathDelimiter(TFE_FLD) + '\TheForceEngine.exe';
  LauncherDarkForcesLabel.Text := darkexe;
  LauncherDosBoxLabel.Text := DOSBOX_PATH;
  LauncherTFELabel.Text := TFE_EXE
end;

procedure TOptionsDialog.RefreshFields;
begin
    LauncherTypeLabel.Invalidate;
    LauncherType.Invalidate;
    LauncherDosBoxLabel.Invalidate;
    LauncherTFELabel.Invalidate;
end;

procedure TOptionsDialog.OkButtonClick(Sender: TObject);
begin
  Log.Info('Updating Options', LogName);
  DarkExe       := LauncherDarkForcesLabel.Text;
  DarkInst      := ExcludeTrailingPathDelimiter(ExtractFileDir(DarkExe));
  RenderInst    := RenderPath.Caption;
  DOSBOX_PATH   := LauncherDosBoxLabel.Text;
  TFE_EXE       := LauncherTFELabel.Text;
  TFE_FLD       := ExtractFileDir(TFE_EXE);

  Log.Info('Options DarkInst = ' + DarkInst, LogName);
  Log.Info('Options RenderInst = ' + RenderInst, LogName);
  Log.Info('Options DOSBOX_PATH = ' + DOSBOX_PATH, LogName);

  if not FileExists(DarkExe) then
    begin
      log.warn('Options Dark Forces Path is missing DARK.EXE', LogName);
      showmessage('Warning! Could not find DARK.EXE at this path' + EOL  + DarkExe);
    end;

  if (not FileExists(DOSBOX_PATH)) and (ENGINE_TYPE = 'JEDI') then
    begin
      log.warn('Options DOSBOX Path is missing DOSBOX.EXE', LogName);
      showmessage('Warning! Could not find DOSBOX.EXE at this path ' + EOL  + DOSBOX_PATH);
    end;

   if (not FileExists(TFE_EXE)) and (ENGINE_TYPE = 'TFE') then
    begin
      log.warn('Options TFE executable is missing! ', LogName);
      showmessage('Warning! Could not find TheForceEngine.exe at this path ' + EOL  + TFE_EXE);
    end;

  INFEditor         := ToolsOptionsINFEditor.Text;
  Voc2Wav           := ToolsOptionsVoc2Wav.Text;
  Wav2Voc           := ToolsOptionsWav2Voc.Text;
  TestLaunch        := OptionsTestLaunchDF.Checked;
  LOADPREVPRJ       := OptionsLaunchPrevPRJChkBox.Checked;
  AUTOSAVE          := OptionsAutoSave.Checked;
  SKIPCUT           := OptionsSkipCutscene.Checked;
  UseLog            := OptionsEnableLogging.Checked;
  Backup_Method     := RG_Backup.ItemIndex;
  UseShowCase       := UseShowCaseCheckBox.Checked;
  AutoStartShowCase := StartShowCaseCheckBox.Checked;
  MAXBACKUPS        := StrToInt(BackupLimit.text);

  Ini.WriteString('DARK FORCES', 'Installed', DarkInst);
  Ini.WriteString('DARK FORCES', 'RenderPath', RenderInst);
  Ini.WriteBool('DARK FORCES', 'UseShowCase', UseShowCase);
  Ini.WriteBool('DARK FORCES', 'AutoStartShowCase', AutoStartShowCase);
  Ini.WriteInteger('DARK FORCES', 'MAXBACKUPS', MAXBACKUPS);



  Ini.WriteString('DARK FORCES', 'CD_Letter', DarkCD);

  Ini.WriteString('TOOLS',   'INF Editor', INFEditor);
  Ini.WriteString('TOOLS',   'VOC2WAV', Voc2Wav);
  Ini.WriteString('TOOLS',   'WAV2VOC', Wav2Voc);


  Ini.WriteString('DARK FORCES', 'TFE_FLD', TFE_FLD);
  Ini.WriteString('DARK FORCES', 'DOSBOX_PATH', DOSBOX_PATH);
  Ini.WriteString('DARK FORCES', 'DOSBOX_CONF', DOSBOX_CONF);
  Ini.WriteString('DARK FORCES', 'LAUNCHER_TYPE', LAUNCHER_TYPE);
  Ini.WriteString('DARK FORCES', 'ENGINE_TYPE', ENGINE_TYPE);

  Ini.WriteInteger('DARK FORCES', 'UNDO_LIMIT', UNDO_LIMIT);
  Ini.WriteBool('DARK FORCES', 'Logger', UseLog);

  Log.Info('Options Launcher Type = ' + LAUNCHER_TYPE, LogName);
  Log.Info('Options DOSBOX_CONF  = ' + DOSBOX_CONF, LogName);
  Log.Info('Options ENGINE_TYPE = ' + ENGINE_TYPE, LogName);
  Log.Info('Options TFE_FLD = ' + TFE_FLD, LogName);

  Ini.WriteBool('DARK FORCES', 'LOADPREVPRJ', LOADPREVPRJ);
  Ini.WriteBool('DARK FORCES', 'PROMPT_SAVE', AUTOSAVE);
  Ini.WriteBool('DARK FORCES', 'SKIP CUTSCENE', SKIPCUT);

  if DirectoryExists(WDFUSEdir + '\WDFDATA') then
    begin
      MemoLabels.Lines.SaveToFile(WDFUSEdir + '\WDFDATA\external.wdl');
      MemoCmdLines.Lines.SaveToFile(WDFUSEdir + '\WDFDATA\external.wdn');
    end;

  Ini.WriteBool('TESTING', 'Launch DF', TestLaunch);

  Log.Info('Options LaunchDF  = ' + BoolToStr(TestLaunch), LogName);

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
  Ini.WriteInteger('MAP-COLORS',  'cmpl',      col_cmpl);
  Ini.WriteInteger('MAP-COLORS',  'boss',      col_boss);

  Ini.WriteInteger('MAP-COLORS',  'dm_low',    col_dm_low);
  Ini.WriteInteger('MAP-COLORS',  'dm_high',   col_dm_high);
  Ini.WriteInteger('MAP-COLORS',  'dm_gas',    col_dm_gas);
  Ini.WriteInteger('MAP-COLORS',  '2a_water',  col_2a_water);
  Ini.WriteInteger('MAP-COLORS',  '2a_catwlk', col_2a_catwlk);
  Ini.WriteInteger('MAP-COLORS',  'sp_sky',    col_sp_sky);
  Ini.WriteInteger('MAP-COLORS',  'sp_pit',    col_sp_pit);
  Ini.WriteInteger('MAP-COLORS',  'sp_sector', col_sec_inner);

  CONFIRMMultiDelete  := CBMultiDel.Checked;
  CONFIRMMultiUpdate  := CBMultiUpd.Checked;
  CONFIRMMultiInsert  := CBMultiIns.Checked;

  CONFIRMSectorDelete := CBSCDel.Checked;
  CONFIRMWallDelete   := CBWLDel.Checked;
  CONFIRMVertexDelete := CBVXDel.Checked;
  CONFIRMObjectDelete := CBOBDel.Checked;

  CONFIRMWallSplit    := CBWallSplit.Checked;
  CONFIRMWallExtrude  := CBWallExtrude.Checked;
  AUTOCOMMIT          := CBAutoCommit.Checked;

  Ini.WriteBool('CONFIRM', 'AutoCommit',   AUTOCOMMIT);
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
  { Hardcode it for now
  //FastDRAG := CBFastDRAG.Checked; }

  FastDRAG   := TRUE;

  Ini.WriteBool('FINE TUNING',  'FastScroll',  FastSCROLL);
  Ini.WriteBool('FINE TUNING',  'FastDrag',    FastDRAG);
  Ini.WriteBool('FINE TUNING',  'LAYER_SHADOW', SHADOW);

  UsePlusVX     := CBUsePlusVX.Checked;
  UsePlusOBShad := CBUsePlusOBShad.Checked;
  SpecialsVX    := CBSpecialsVX.Checked;
  SpecialsOB    := CBSpecialsOB.Checked;
  NORMALIZE_WALLS := CBNormalizeWalls.Checked;
  USE_ALT_PAN  :=  CBUseAltPan.Checked;

  if USE_ALT_PAN then AltPanning := False;

  Ini.WriteBool('FINE TUNING',  'UsePlusVX',       CBUsePlusVX.Checked);
  Ini.WriteBool('FINE TUNING',  'UsePlusOBShad',   CBUsePlusOBShad.Checked);
  Ini.WriteBool('FINE TUNING',  'SpecialsVX',      CBSpecialsVX.Checked);
  Ini.WriteBool('FINE TUNING',  'SpecialsOB',      CBSpecialsOB.Checked);
  Ini.WriteBool('FINE TUNING',  'NORMALIZE_WALLS', CBNormalizeWalls.Checked);
  Ini.WriteBool('FINE TUNING',  'UseAltPan',       CBUseAltPan.Checked);

  if USE_ALT_PAN then
   begin
      PAN_SEL_STATE  := [ssAlt] + [ssLeft];
      MULTI_SEL_STATE := [ssLeft];
      AltPanning    := False;
   end
  else
   begin
      PAN_SEL_STATE  := [ssLeft];
      MULTI_SEL_STATE := [ssLeft] + [ssAlt] ;
   end;



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



procedure TOptionsDialog.OptionsViewLogFileClick(Sender: TObject);
begin
  MapWindow.ToolsLogFilePathClick(NIL);
end;

procedure TOptionsDialog.OptionsViewLogFolderClick(Sender: TObject);
begin
  MapWindow.ToolsLogFolderClick(NIL);
end;

procedure TOptionsDialog.RenderDownloadClick(Sender: TObject);
var url,
    renderpath,
    zippath : String;
    zipfile : TZipFile;

begin
    RenderDownload.Visible := False;
    RenderDownloading.Visible := True;
    OptionsDialog.Invalidate;
    OptionsDialog.RePaint;
    url := 'https://df-21.net/downloads/utilities/renderer/renderer.zip';
    renderpath :=  WDFUSEdir + '\RENDERER';

    if not DirectoryExists(renderpath) then
       CreateDir(renderpath);

    zippath := renderpath + '\renderer.zip';
    log.info('Downloading from ' + url + ' to ' + zippath, LogName);
    if FileExists(renderpath + '\Dark Forces Showcase.exe') then
      begin
        if Application.MessageBox('WARNING: You already have Dark Forces Renderer. Redownload?',
                                  'WDFUSE 3D Renderer',
                                   mb_YesNo or mb_IconQuestion) = idNo then
                                    begin
                                       RenderDownload.Visible := True;
                                       RenderDownloading.Visible := False;
                                       exit
                                    end;
      end;
    // Download showcase
    try
      URLDownloadToFile(nil, PChar(url), PChar(zippath), 0, nil);

      zipfile := TZipFile.Create;
      zipfile.Open(zippath, zmRead);
      try
        zipfile.ExtractAll(renderpath);
        zipfile.Close;
      finally
        zipfile.Free;
      end;

      DeleteFile(PChar(zippath));
    finally
      RenderDownload.Visible := True;
      RenderDownloading.Visible := False;
    end;
    showmessage('Downloaded Showcase and Installed.');

end;

{ TO DO - handle steam installs on other drives }
procedure TOptionsDialog.SteamButtonClick(Sender: TObject);
var
  RegPath: string;
  Registry: TRegistry;
  textTmp : AnsiString;
  LibPath : String;
  LibRexStr : String;
  LibRex : TRegex;
  LibGroup    : TGroup;
  LibMatch    : TMatch;
  LibMatches  : TMatchCollection;
  fileTmp : TextFile;
  LibSteamPath : String;
begin
  RegPath := '';
  Registry := TRegistry.Create;
  try
    Log.Info('Options Loading Steam', LogName);
    Registry.RootKey := HKEY_LOCAL_MACHINE;
    if Registry.OpenKeyReadOnly(steam_reg) then
     begin
      RegPath := Registry.ReadString('InstallPath');
      Log.Info('Options REGPATH = ' + RegPath, LogName);
      if DirectoryExists(RegPath) then
        { Check ACF }
        begin
         darkinst := RegPath + '\steamapps\common\Dark Forces\GAME';
         DarkExe  := darkinst + 'DARK.EXE';

         // Check other Steam Drives
         if not FileExists(RegPath + '\steamapps\appmanifest_32400.acf') then
          begin
            LibPath := RegPath + '\steamapps\libraryfolders.vdf';
            LibRexStr := '(\d\"\s+\"(.*?)")|(path\"\s+\"(.*?)")';
            LibRex := TRegex.Create(LibRexStr);
            if FileExists(LibPath) then
              begin
                AssignFile(fileTmp, LibPath);
                FileMode := fmOpenRead;
                Reset(fileTmp);
                while not Eof(fileTmp) do
                 begin
                   ReadLn(fileTmp, textTmp);
                   LibMatches := LibRex.Matches(textTmp);
                   for LibMatch in LibMatches do
                    for LibGroup in LibMatch.Groups do
                      begin
                        LibSteamPath := LibGroup.Value + '\steamapps\appmanifest_32400.acf';
                        if FileExists(LibSteamPath) then
                          begin
                           darkinst := StringReplace(LibGroup.Value , '\\', '\', [rfReplaceAll, rfIgnoreCase]) +
                                       '\steamapps\common\Dark Forces\GAME';
                           break;
                          end;
                      end;
                 end;
              end;
          end;

          DarkExe := darkinst + '\Dark.exe';
          LauncherDarkForcesLabel.Text := DarkExe;
          DOSBOX_PATH := ExpandFileName(darkinst + '\..\DOSBOX\DOSBox.exe');
          LauncherDosBoxLabel.Text := DOSBOX_PATH;
          DOSBOX_CONF := ExpandFileName(ExtractFileDir(darkinst) + '\..\dosbox.conf');
          LAUNCHER_TYPE := 'STEAM';
          Log.Info('Options STEAM darkinst = ' + darkinst, LogName);
          Log.Info('Options STEAM DOSBOX_PATH = ' + DOSBOX_PATH, LogName);
          Log.Info('Options STEAM DOSBOX_CONF = ' + DOSBOX_CONF, LogName);
          LauncherTypeLabel.Caption := LAUNCHER_TYPE;
          if not FileExists(DOSBOX_PATH) then
            begin
              log.Info('Options STEAM DOSBOX_PATH does not exist!', LogName );
              showmessage('Could not find Steam DOSBOX at this path ' + DOSBOX_PATH);
            end;
          OptionsDialog.Invalidate;
          exit;
        end;
     end;
    Log.error('Options Coult not find DARK.EXE in = ' + RegPath, LogName);
    showmessage('Could not find DARK.EXE in ' + RegPath + '\Game\DARK.EXe');
  except
    on E : Exception do
       HandleException('Options Error', E);
  end;
  OptionsDialog.Invalidate;
end;

procedure TOptionsDialog.GOGButtonClick(Sender: TObject);
var
  RegPath: string;
  Registry: TRegistry;
begin
  RegPath := '';
  Registry := TRegistry.Create;
  try
    Log.Info('Options Loading GOG', LogName);
    Registry.RootKey := HKEY_LOCAL_MACHINE;
    if Registry.OpenKeyReadOnly(gog_reg) then
      begin
        RegPath := Registry.ReadString('Path');
        Log.Info('Options REGPATH = ' + RegPath, LogName);
      end;
    if FileExists(RegPath + '\DARK.EXE') then
     begin
      darkinst := RegPath;
      DarkExe := darkinst + '\Dark.exe';
      LauncherDarkForcesLabel.Text := DarkExe;
      DOSBOX_PATH := RegPath + '\DOSBOX\DOSBox.exe';
      DOSBOX_CONF := RegPath + '\dosbox_DF_single.conf';
      Log.Info('Options GOG darkinst = ' + darkinst, LogName);
      Log.Info('Options GOG DOSBOX_PATH = ' + DOSBOX_PATH, LogName);
      Log.Info('Options GOG DOSBOX_CONF = ' + DOSBOX_CONF, LogName);
      LauncherDosBoxLabel.Text := DOSBOX_PATH;
      LAUNCHER_TYPE := 'GOG';
      LauncherTypeLabel.Caption := LAUNCHER_TYPE;
      if not FileExists(DOSBOX_PATH) then
        begin
          log.Info('Options GOG DOSBOX_PATH does not exist!', LogName );
          showmessage('Could not find GOG DOSBOX at this path ' + DOSBOX_PATH);
        end;
     end
    else
      begin
        Log.error('Options Coult not find DARK.EXE in = ' + RegPath, LogName);
        showmessage('Could not find DARK.EXE in ' + RegPath + '\DARK.EXE');
      end;
  except
   on E : Exception do
      HandleException('Options Error', E);
  end;
  OptionsDialog.Invalidate;
end;

procedure TOptionsDialog.OriginButtonClick(Sender: TObject);
var
  RegPath: string;
  Registry: TRegistry;
  textTmp : AnsiString;
  LibPath : String;
  LibRexStr : String;
  LibRex : TRegex;
  LibGroup    : TGroup;
  LibMatch    : TMatch;
  LibMatches  : TMatchCollection;
  fileTmp : TextFile;
  LibEAPath : String;
begin
  RegPath := '';
  Registry := TRegistry.Create;
  try
    Log.Info('Options Loading Origin', LogName);
    Registry.RootKey := HKEY_LOCAL_MACHINE;
    if Registry.OpenKeyReadOnly(origin_reg) then
     begin
      RegPath := Registry.ReadString('Install Dir');
      Log.Info('Options REGPATH = ' + RegPath, LogName);
      if DirectoryExists(RegPath) then
        begin
          darkinst := RegPath + 'DOSBOX\GAME';
          DarkExe  := darkinst + '\DARK.EXE';
          LauncherDarkForcesLabel.Text := DarkExe;
          DOSBOX_PATH := ExpandFileName(ExtractFileDir(RegPath) + '\DOSBOX\DOSBox.exe');
          LauncherDosBoxLabel.Text := DOSBOX_PATH;
          DOSBOX_CONF := ExpandFileName(ExtractFileDir(DOSBOX_PATH) + '\dosbox.conf');
          LAUNCHER_TYPE := 'ORIGIN';
          Log.Info('Options ORIGIN darkinst = ' + darkinst, LogName);
          Log.Info('Options ORIGIN DOSBOX_PATH = ' + DOSBOX_PATH, LogName);
          Log.Info('Options ORIGIN DOSBOX_CONF = ' + DOSBOX_CONF, LogName);
          LauncherTypeLabel.Caption := LAUNCHER_TYPE;
          if not FileExists(DOSBOX_PATH) then
            begin
              log.Info('Options ORIGIN DOSBOX_PATH does not exist!', LogName );
              showmessage('Could not find Steam DOSBOX at this path ' + DOSBOX_PATH);
            end;
          OptionsDialog.Invalidate;
          exit;
        end;
     end;
    Log.error('Options Coult not find DARK.EXE in = ' + RegPath, LogName);
    showmessage('Could not find DARK.EXE in ' + RegPath + '\Game\DARK.EXe');
  except
    on E : Exception do
       HandleException('Options Error', E);
  end;
   OptionsDialog.Invalidate;
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
  col_cmpl   := Ini.ReadInteger('MAP-COLORS',  'cmpl',   Ccol_cmpl);
  col_boss   := Ini.ReadInteger('MAP-COLORS',  'boss',   Ccol_boss);
  MapWindow.Color := col_back;
  MapWindow.Map.Invalidate;
end;



procedure TOptionsDialog.FindDosBoxConf(DOSBOX_FLD: String);
begin
   // Check Dark Forces GOG style
   if FileExists(DOSBOX_FLD + '\dosbox_DF_single.conf') then
     DOSBOX_CONF := DOSBOX_FLD + '\dosbox_DF_single.conf'

   else if FileExists(DOSBOX_FLD + '\..\dosbox_DF_single.conf') then
     DOSBOX_CONF := DOSBOX_FLD + '\..\dosbox_DF_single.conf'

   // Check dosbox.conf Steam Style
   else if FileExists(DOSBOX_FLD + '\..\dosbox.conf')  then
     DOSBOX_CONF := DOSBOX_FLD + '\..\dosbox.conf'

   // Check dosbox.conf Origin Style
   else if FileExists(DOSBOX_FLD + '\dosbox.conf')  then
     DOSBOX_CONF := DOSBOX_FLD + '\dosbox.conf'

   // Make it blank so it picks up the default one from WDFDATA
   else
     begin
       DOSBOX_CONF := '';
       showmessage('WARNING! Cannot find Dosbox.conf! Please put Dosbox.conf in same folder as the executable!');
     end;
end;

procedure TOptionsDialog.TfeBrowseClick(Sender: TObject);
begin
 with OpenDialogueTFE do
  begin
   InitialDir  := TFE_FLD;
   if Execute then
    if not StrUtils.ContainsStr(LowerCase(FileName), 'theforceengine.exe') then
     begin
       showmessage('Missing Dark Forces Executable TheForceEngine.exe in [' + FileName +']');
       exit;
     end;
     if FileName = '' then exit;

     LauncherTFELabel.Text := FileName;
     TFE_EXE := LauncherTFELabel.Text;
     TFE_FLD := ExtractFileDir(TFE_EXE);
  end;
  LauncherTFELabel.Text  := TFE_EXE;
  Log.Info('Options CUSTOM TFE_PATH = ' + TFE_FLD, LogName);
 // OptionsDialog.Invalidate;
end;

procedure TOptionsDialog.DosBoxBrowseClick(Sender: TObject);
begin
 with OpenDialogueDosBox do
  begin
   InitialDir  := DOSBOX_PATH;
   if Execute then
    if not StrUtils.ContainsStr(LowerCase(FileName), 'dosbox.exe') then
     begin
       showmessage('Missing Dark Forces Executable DOSBOX.EXE in [' + FileName +']');
       exit;
     end;
     if FileName = '' then exit;
     DOSBOX_PATH := FileName;
     FindDosBoxConf(ExtractFileDir(DOSBOX_PATH));
  end;
  LauncherDosBoxLabel.Text  := DOSBOX_PATH;
  Log.Info('Options CUSTOM DOSBOX_PATH = ' + DOSBOX_PATH, LogName);
//  OptionsDialog.Invalidate;
end;

procedure TOptionsDialog.DarkForcesBrowseClick(Sender: TObject);
begin
 with OpenDialogueDark do
  begin
   InitialDir  := darkinst;
   if Execute then
    if not StrUtils.ContainsStr(LowerCase(FileName), 'dark.exe') then
     begin
       showmessage('Missing Dark Forces Executable DARK.EXE in [' + FileName +']');
       exit;
     end;

     if FileName = '' then exit;

     LauncherDarkForcesLabel.Text := FileName;
     DarkExe := LauncherDarkForcesLabel.Text;
     DarkInst := ExtractFileDir(DarkExe);

     if FileExists(DarkInst + '\DosBox\DOSBOX.EXE') then
       begin
         DOSBOX_PATH := DarkInst + '\DosBox\DOSBOX.EXE';
         FindDosBoxConf(ExtractFileDir(DOSBOX_PATH));
         LauncherDosBoxLabel.Text  := DOSBOX_PATH;
       end;

     if FileExists(DarkInst + '\..\DosBox\DOSBOX.EXE') then
       begin
         DOSBOX_PATH := ExpandFileName(DarkInst + '\..\DosBox\DOSBOX.EXE');
         FindDosBoxConf(ExtractFileDir(DOSBOX_PATH));
         LauncherDosBoxLabel.Text  := DOSBOX_PATH;
       end;

  end;
  LauncherDarkForcesLabel.Text := DarkExe;
  LAUNCHER_TYPE := 'Custom';
  LauncherTypeLabel.Caption := LAUNCHER_TYPE;
  Log.Info('Options CUSTOM DARK INST = ' + DarkInst, LogName);
 // OptionsDialog.Invalidate;
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
  10: ShapeColorFore.Pen.Color  := col_cmpl;
  11: ShapeColorFore.Pen.Color  := col_boss;
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
  8: ShapeColorFore.Brush.Color   := col_sec_inner;
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
  10: TheColor  := col_cmpl;
  11: TheColor  := col_boss;

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
    10: col_cmpl  := TheColor;
    11: col_boss  := TheColor;
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
  8: TheColor   := col_sec_inner;
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
    8: col_sec_inner  := TheColor
   END;
   ShapeColorFore.Brush.Color := TheColor;
   MapWindow.Map.Invalidate;
  end;
end;

procedure TOptionsDialog.BNHelpClick(Sender: TObject);
begin
  MapWindow.HelpTutorialClick(NIL);
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
 with OpenDialogueRender do
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

procedure TOptionsDialog.EngineTypeBoxClick(Sender: TObject);
begin
  if EngineTypeBox.ItemIndex = 0 then
    ENGINE_TYPE := 'JEDI'
  else
    ENGINE_TYPE := 'TFE';
end;

procedure TOptionsDialog.RenderAbout4Click(Sender: TObject);
var url : string;
begin
  url := 'http://www.mzzt.net';
  ShellExecute(HInstance, 'open', PChar(url), nil, nil, SW_NORMAL);
end;

procedure TOptionsDialog.RenderBrowseClick(Sender: TObject);
begin
 with OpenDialogueRender do
  begin
   if Execute then
    if not StrUtils.ContainsStr(LowerCase(FileName), 'dark forces showcase.exe') then
     begin
       showmessage('Missing Dark Forces ShowCase.exe in ' + FileName);
       exit;
     end;
     RenderPath.Caption := FileName;
     RenderInst := RenderPath.Caption;
  end;
  RenderPath.Caption := RenderInst;
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


procedure TOptionsDialog.BackupLimitChange(Sender: TObject);
var backupnum : integer;
begin
  try
    backupnum := StrToInt(BackupLimit.Text);
    if (backupnum <1) or (backupnum > 500) then
        showmessage('# of Backups should be above 1 and less than 500!')
    else
        exit;
  except
    on E : Exception do
        ShowMessage('Invalid number provided as a backup! ' + EOL +  E.ClassName+' error raised, with message : '+E.Message);
    end;
    BackupLimit.text := IntToStr(MAXBACKUPS);
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
    Value   : array[0..255] of char;
    reg : TRegistry;
    wdppath : string;
    result : boolean;
begin

  with TRegistry.Create do
    try
      RootKey := HKEY_CURRENT_USER;
      if OpenKey('\Software\Classes\.wdp', true) then
        WriteString('', 'wdpfile');
      if OpenKey('\Software\Classes\wdpfile', true) then
        WriteString('', 'WDFUSE Project File');
      if OpenKey('\Software\Classes\wdpfile\DefaultIcon', true) then
        WriteString('', 'F:\wdfuse2.6\wdfuse32.exe');
      if OpenKey('\Software\Classes\wdpfile\shell\open\command', true) then
        WriteString('', 'F:\wdfuse2.6\wdfuse32.exe "%1"');
    finally
      Free;
    end;
end;


procedure TOptionsDialog.BitBtnRegGOBClick(Sender: TObject);
var Key     : HKey;
    Value   : array[0..255] of char;
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
    Value   : array[0..255] of char;
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
