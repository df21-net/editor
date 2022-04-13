unit M_option;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, TabNotBk, StdCtrls, Buttons, FileCtrl, M_global, ExtCtrls,
  ColorGrd, StrUtils, registry, IOUtils, System.RegularExpressions,
  System.RegularExpressionsCore,
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
    ComboInstall: TDriveComboBox;
    DirectoryListBox1: TDirectoryListBox;
    DirectoryListBox2: TDirectoryListBox;
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
    dosboxlabel: TLabel;
    Panel3: TPanel;
    dosboxdrive: TDriveComboBox;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    LauncherTypeLabel: TLabel;
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
    procedure RenderBrowseClick(Sender: TObject);
    procedure SteamButtonClick(Sender: TObject);
    procedure GOGButtonClick(Sender: TObject);
    procedure CustomLauncherClick(Sender: TObject);
    procedure RenderAbout4Click(Sender: TObject);
    procedure OptionsViewLogFolderClick(Sender: TObject);
    procedure OptionsViewLogFileClick(Sender: TObject);
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
  if TPath.DriveExists(DarkInst[1] + ':') then
    ComboInstall.Drive := DarkInst[1]
  else
    ComboInstall.Drive  := 'C';
  if DirectoryExists(DarkInst) then
   DirectoryListBox1.Directory  := DarkInst
  else
   DirectoryListBox1.Directory  := 'c:\';
  ComboDFCD.Drive              := Char(DarkCD[1]);
  RenderPath.Caption           := RenderInst;

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
   MemoLabels.Clear;
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

  DOSBOX_PATH   := Ini.ReadString('DARK FORCES', 'DOSBOX_PATH', '');
  DOSBOX_CONF   := Ini.ReadString('DARK FORCES', 'DOSBOX_CONF', '');
  LAUNCHER_TYPE := Ini.ReadString('DARK FORCES', 'LAUNCHER_TYPE', 'Custom');
  UseLog        := Ini.ReadBool('DARK FORCES', 'Logger', True);
  OptionsTestLaunchDF.Checked := TestLaunch;
  OptionsEnableLogging.Checked := UseLog;
  dosboxlabel.Caption := DOSBOX_PATH;
  LoggingPanel.Text := LogPath;
  LoadingForm := False;
  LabelDFInstalled.Caption := darkinst;
end;

procedure TOptionsDialog.OkButtonClick(Sender: TObject);
begin
  Log.Info('Updating Options', LogName);
  DarkInst      := LabelDFInstalled.Caption;
  RenderInst    := RenderPath.Caption;
  DOSBOX_PATH   := dosboxlabel.Caption;
  DarkCD[1]     := AnsiChar(ComboDFCD.Drive);

  Log.Info('Options DarkInst = ' + DarkInst, LogName);
  Log.Info('Options RenderInst = ' + RenderInst, LogName);
  Log.Info('Options DOSBOX_PATH = ' + DOSBOX_PATH, LogName);

  if not FileExists(DarkInst + '\DARK.EXE') then
    begin
      log.warn('Options Dark Forces Path is missing DARK.EXE', LogName);
      showmessage('Warning! Could not find DARK.EXE in this folder ' + EOL  + DarkInst);
    end;


  if not FileExists(DOSBOX_PATH) then
    begin
      log.warn('Options DOSBOX Path is missing DOSBOX.EXE', LogName);
      showmessage('Warning! Could not find DOSBOX.EXE at this path ' + EOL  + DOSBOX_PATH);
    end;

  INFEditor     := ToolsOptionsINFEditor.Text;
  Voc2Wav       := ToolsOptionsVoc2Wav.Text;
  Wav2Voc       := ToolsOptionsWav2Voc.Text;
  TestLaunch    := OptionsTestLaunchDF.Checked;
  LOADPREVPRJ   := OptionsLaunchPrevPRJChkBox.Checked;
  AUTOSAVE      := OptionsAutoSave.Checked;
  SKIPCUT       := OptionsSkipCutscene.Checked;
  UseLog        := OptionsEnableLogging.Checked;
  Backup_Method := RG_Backup.ItemIndex;

  Ini.WriteString('DARK FORCES', 'Installed', DarkInst);
  Ini.WriteString('DARK FORCES', 'RenderPath', RenderInst);
  DarkCD    := '?';
  DarkCD[1] := AnsiChar(ComboDFCD.Drive);
  Ini.WriteString('DARK FORCES', 'CD_Letter', DarkCD);

  Ini.WriteString('TOOLS',   'INF Editor', INFEditor);
  Ini.WriteString('TOOLS',   'VOC2WAV', Voc2Wav);
  Ini.WriteString('TOOLS',   'WAV2VOC', Wav2Voc);

  Ini.WriteString('DARK FORCES', 'DOSBOX_PATH', DOSBOX_PATH);
  Ini.WriteString('DARK FORCES', 'DOSBOX_CONF', DOSBOX_CONF);
  Ini.WriteString('DARK FORCES', 'LAUNCHER_TYPE',LAUNCHER_TYPE);
  Ini.WriteInteger('DARK FORCES', 'UNDO_LIMIT', UNDO_LIMIT);
  Ini.WriteBool('DARK FORCES', 'Logger', UseLog);

  Log.Info('Options Launcher Type = ' + LAUNCHER_TYPE, LogName);
  Log.Info('Options DOSBOX_CONF  = ' + DOSBOX_CONF, LogName);
  Ini.WriteBool('DARK FORCES', 'LOADPREVPRJ', LOADPREVPRJ);
  Ini.WriteBool('DARK FORCES', 'PROMPT_SAVE', AUTOSAVE);
  Ini.WriteBool('DARK FORCES', 'SKIP CUTSCENE', SKIPCUT);

  MemoLabels.Lines.SaveToFile(WDFUSEdir + '\WDFDATA\external.wdl');
  MemoCmdLines.Lines.SaveToFile(WDFUSEdir + '\WDFDATA\external.wdn');

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

procedure TOptionsDialog.OptionsViewLogFileClick(Sender: TObject);
begin
  MapWindow.ToolsLogFilePathClick(NIL);
end;

procedure TOptionsDialog.OptionsViewLogFolderClick(Sender: TObject);
begin
  MapWindow.ToolsLogFolderClick(NIL);
end;

procedure TOptionsDialog.RenderDownloadClick(Sender: TObject);
var url : String;
begin
  url := 'https://github.com/The-MAZZTer/DarkForces/releases/tag/v0.2';
  ShellExecute(HInstance, 'open', PChar(url), nil, nil, SW_NORMAL);
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

          LabelDFInstalled.Caption := darkinst;
          DOSBOX_PATH := ExpandFileName(darkinst + '\..\DOSBOX\DOSBox.exe');
          dosboxlabel.Caption := DOSBOX_PATH;
          DOSBOX_CONF := ExpandFileName(darkinst + '\..\dosbox.conf');
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
          exit;
        end;
     end;
    Log.error('Options Coult not find DARK.EXE in = ' + RegPath, LogName);
    showmessage('Could not find DARK.EXE in ' + RegPath + '\Game\DARK.EXe');
  except
    on E : Exception do
      begin
        Log.error('Options Error ' + E.ClassName+' error raised, with message : '+E.Message, LogName);
        ShowMessage(E.ClassName+' error raised, with message : '+E.Message);
      end
  end;
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
      LabelDFInstalled.Caption := darkinst;
      DOSBOX_PATH := RegPath + '\DOSBOX\DOSBox.exe';
      DOSBOX_CONF := RegPath + '\dosbox_DF_single.conf';
      Log.Info('Options GOG darkinst = ' + darkinst, LogName);
      Log.Info('Options GOG DOSBOX_PATH = ' + DOSBOX_PATH, LogName);
      Log.Info('Options GOG DOSBOX_CONF = ' + DOSBOX_CONF, LogName);
      dosboxlabel.Caption := DOSBOX_PATH;
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
      begin
        Log.error('Options Error ' + E.ClassName+' error raised, with message : '+E.Message, LogName);
        ShowMessage(E.ClassName+' error raised, with message : '+E.Message);
      end
  end;
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

procedure TOptionsDialog.CustomLauncherClick(Sender: TObject);
begin
  if LoadingForm then exit;

  if Sender = DirectoryListBox1 then
    begin
      if FileExists(ExpandFileName( LabelDFInstalled.Caption + '\DOSBOX\DOSBOX.EXE')) then
        Dosboxlabel.caption := ExpandFileName(LabelDFInstalled.Caption + '\DOSBOX\DOSBOX.EXE');
    end;

  Log.Info('Options CUSTOM start', LogName);
  if StrUtils.RightStr(Dosboxlabel.caption,11) = '\DOSBOX.EXE' then
    DOSBOX_PATH := Dosboxlabel.caption
  else
    DOSBOX_PATH := Dosboxlabel.caption + '\DOSBOX.EXE';

  if FileExists(DOSBOX_PATH) then
    begin
      // Check Dark Forces GOG style
      if FileExists(DarkInst + '\dosbox_DF_single.conf') then
        DOSBOX_CONF := DarkInst + '\dosbox_DF_single.conf'

      // Check dosbox.conf Steam Style
      else if FileExists(DarkInst + '\..\dosbox.conf')  then
        DOSBOX_CONF := DarkInst + '\..\dosbox.conf'

      // Check dosbox.conf Origin Style
      else if FileExists(DOSBOX_PATH + '\dosbox.conf')  then
        DOSBOX_CONF := DOSBOX_PATH + '\dosbox.conf'

      // Make it blank so it picks up the default one from WDFDATA
      else
        DOSBOX_CONF := '';

    end;

  Log.Info('Options CUSTOM DOSBOX_PATH = ' + DOSBOX_PATH, LogName);
  LAUNCHER_TYPE := 'Custom';
  LauncherTypeLabel.Caption := LAUNCHER_TYPE;
  Dosboxlabel.caption := DOSBOX_PATH;
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
    if not StrUtils.ContainsStr(LowerCase(FileName), 'showcase.exe') then
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
