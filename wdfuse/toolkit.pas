unit Toolkit;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Buttons, ExtCtrls, IniFiles,
  StdCtrls, FileCtrl, Grids, Menus, TabNotBk,
  Gobs, Lfds,
  M_About, M_Global, M_Stat, V_Util, C_Util, R_Util,
  T_Info, T_Convrt, T_PalOpt,
{$IFDEF WDF32}
  ComCtrls,
{$ENDIF}
  _undoc, Spin;

type
  TTktWindow = class(TForm)
    PanelTop: TPanel;
    PanelBottom: TPanel;
    PanelX: TPanel;
    PanelText: TPanel;
    SpeedButtonExit: TSpeedButton;
    PanelAbout: TPanel;
    SpeedButtonAbout: TSpeedButton;
    SpeedButtonHelp: TSpeedButton;
    SpeedButtonStat: TSpeedButton;
    TabbedNotebook: TTabbedNotebook;
    Panel7: TPanel;
    PanelViewerTop: TPanel;
    Panel9: TPanel;
    Panel10: TPanel;
    PanelViewerLeft: TPanel;
    ViewerFile: TFileListBox;
    ViewerDrive: TDriveComboBox;
    ViewerDirectory: TDirectoryListBox;
    ViewerFilter: TFilterComboBox;
    Panel12: TPanel;
    ViewerPalette: TEdit;
    ViewerPaletteSelect: TBitBtn;
    LabelViewPalette: TLabel;
    Panel13: TPanel;
    LabelCMP: TLabel;
    LabelFMESetInsert: TLabel;
    BNInfo: TBitBtn;
    BNConvert: TBitBtn;
    SpeedButtonGobFM: TSpeedButton;
    SpeedButtonLfdFM: TSpeedButton;
    BNViewRefresh: TBitBtn;
    LabelDELTSetOffsets: TLabel;
    ScrollBox: TScrollBox;
    LabelSND: TLabel;
    OpenPALorPLTT: TOpenDialog;
    LabelViewFilter: TLabel;
    LabelViewDirectory: TLabel;
    LabelViewFile: TLabel;
    LabelViewDrive: TLabel;
    Image: TImage;
    SEcontrast: TSpinEdit;
    SBFirstFrame: TSpeedButton;
    SBPrevFrame: TSpeedButton;
    SBNextFrame: TSpeedButton;
    SBLastFrame: TSpeedButton;
    EDFrameNum: TEdit;
    ANIMLabAnimName: TEdit;
    LabelANIMCurrent: TLabel;
    ANIMLabSplitDir: TFileListBox;
    LabelANIMSplit: TLabel;
    ANIMLabSplit: TBitBtn;
    ANIMLabGroup: TBitBtn;
    ANIMLabSplitDirName: TLabel;
    ANIMLabNewAnim: TBitBtn;
    ANIMLabOpenNewAnim: TOpenDialog;
    LabelBMCurrent: TLabel;
    BMLabBMName: TEdit;
    LabelBMSplit: TLabel;
    BMLabNewBM: TBitBtn;
    BMLabSplitDirName: TLabel;
    BMLabSplitDir: TFileListBox;
    BMLabSplit: TBitBtn;
    BMLabGroup: TBitBtn;
    BMLabOpenNewBM: TOpenDialog;
    BMLabSpeed: TSpinEdit;
    BMLabSpeedLabel: TLabel;
    ANIMLabConvert: TBitBtn;
    BMLabConvert: TBitBtn;
    Bevel1: TBevel;
    BMLabTransparent: TBitBtn;
    BMLabOpaque: TBitBtn;
    Shape1: TShape;
    Bevel2: TBevel;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    Bevel3: TBevel;
    LabelDELTCurrent: TLabel;
    DELTLabDELTName: TEdit;
    Shape5: TShape;
    Bevel4: TBevel;
    LabelFMECurrent: TLabel;
    FMELabFMEName: TEdit;
    Shape6: TShape;
    Bevel5: TBevel;
    Shape7: TShape;
    Shape8: TShape;
    Bevel6: TBevel;
    FMELabCompress: TBitBtn;
    FMELabUncompress: TBitBtn;
    Shape9: TShape;
    Shape10: TShape;
    Bevel7: TBevel;
    FMELabFlip: TBitBtn;
    FMELabUnFlip: TBitBtn;
    DELTLabApplyOffsets: TBitBtn;
    DELTLabGetOffsets: TBitBtn;
    DELTLabXOffset: TEdit;
    DELTLabYOffset: TEdit;
    LabelDELTX: TLabel;
    LabelDELTy: TLabel;
    LabelFMEx: TLabel;
    LabelFMEy: TLabel;
    FMELabXInsert: TEdit;
    FMELabYInsert: TEdit;
    FMELabGetInserts: TBitBtn;
    FMELabApplyInserts: TBitBtn;
    LabelFMESetCompress: TLabel;
    LabelFMESetFlip: TLabel;
    LabelBMSetTransparent: TLabel;
    LabelBMMan: TLabel;
    LabelANIMFrameMan: TLabel;
    ANIMLabSplitFilter: TFilterComboBox;
    BMLabSplitFilter: TFilterComboBox;
    ANIMLabPalOpt: TBitBtn;
    BMLabPalOpt: TBitBtn;
    BMLabWeapon: TBitBtn;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    LabelPALCurrent: TLabel;
    PALLabPALName: TEdit;
    Panel5: TPanel;
    Panel6: TPanel;
    ScrollBoxPAL: TScrollBox;
    ImagePAL: TImage;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    LabelPALr: TLabel;
    LabelPALg: TLabel;
    LabelPALb: TLabel;
    SEPalRed: TSpinEdit;
    SEPalGreen: TSpinEdit;
    SEPalBlue: TSpinEdit;
    Bevel8: TBevel;
    Shape11: TShape;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    LabelPALFirst: TLabel;
    LabelPALLast: TLabel;
    Bevel9: TBevel;
    Shape12: TShape;
    BitBtn3: TBitBtn;
    Bevel10: TBevel;
    Shape13: TShape;
    LabelPALColor: TLabel;
    Edit1: TEdit;
    Panel8: TPanel;
    Panel11: TPanel;
    Panel14: TPanel;
    Panel15: TPanel;
    Panel16: TPanel;
    ScrollBoxWAX: TScrollBox;
    ImageWAX: TImage;
    LabelWAXCurrent: TLabel;
    WAXLabWAXName: TEdit;
    LabelWAXwax: TLabel;
    WAXLabSEWax: TSpinEdit;
    LabelWAXSeq: TLabel;
    WAXLabSESeq: TSpinEdit;
    LabelWAXFrame: TLabel;
    WAXLabSEFrm: TSpinEdit;
    LabelWAXFrameRate: TLabel;
    WAXLabSEFrameRate: TSpinEdit;
    Panel17: TPanel;
    LabelFILMCurrent: TLabel;
    FILMLabFilmName: TEdit;
    Panel18: TPanel;
    Panel19: TPanel;
    Panel20: TPanel;
    FILMLabMemo: TMemo;
    FILMLabDecompile: TBitBtn;
    FILMLabCompile: TBitBtn;
    Bevel11: TBevel;
    Bevel12: TBevel;
    FILMLabExport: TBitBtn;
    FILMLabImport: TBitBtn;
    Shape14: TShape;
    Shape15: TShape;
    Shape16: TShape;
    FILMLabNew: TBitBtn;
    SaveExportFILM: TSaveDialog;
    OpenImportFILM: TOpenDialog;
    SaveNewFILM: TSaveDialog;
    Bevel13: TBevel;
    FILMLabClear: TBitBtn;
    Shape17: TShape;
    Shape18: TShape;
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SpeedButtonExitClick(Sender: TObject);
    procedure SpeedButtonAboutClick(Sender: TObject);
    procedure SpeedButtonStatClick(Sender: TObject);
    procedure SpeedButtonHelpClick(Sender: TObject);
    procedure SpeedButtonGobFMClick(Sender: TObject);
    procedure SpeedButtonLfdFMClick(Sender: TObject);
    procedure BNInfoClick(Sender: TObject);
    procedure ViewerPaletteSelectClick(Sender: TObject);
    procedure ViewerFilterClick(Sender: TObject);
    procedure BNConvertClick(Sender: TObject);
    procedure ViewerFileClick(Sender: TObject);
    procedure BNViewRefreshClick(Sender: TObject);
    procedure ViewerFileChange(Sender: TObject);
    procedure SEcontrastChange(Sender: TObject);
    procedure SBFirstFrameClick(Sender: TObject);
    procedure SBPrevFrameClick(Sender: TObject);
    procedure SBNextFrameClick(Sender: TObject);
    procedure SBLastFrameClick(Sender: TObject);
    procedure TabbedNotebookChange(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
    procedure TabbedNotebookClick(Sender: TObject);
    procedure ANIMLabNewAnimClick(Sender: TObject);
    procedure ANIMLabSplitClick(Sender: TObject);
    procedure ANIMLabGroupClick(Sender: TObject);
    procedure BMLabNewBMClick(Sender: TObject);
    procedure ANIMLabConvertClick(Sender: TObject);
    procedure BMLabSplitClick(Sender: TObject);
    procedure BMLabGroupClick(Sender: TObject);
    procedure BMLabConvertClick(Sender: TObject);
    procedure BMLabTransparentClick(Sender: TObject);
    procedure BMLabOpaqueClick(Sender: TObject);
    procedure DELTLabGetOffsetsClick(Sender: TObject);
    procedure DELTLabApplyOffsetsClick(Sender: TObject);
    procedure FMELabGetInsertsClick(Sender: TObject);
    procedure FMELabApplyInsertsClick(Sender: TObject);
    procedure FMELabFlipClick(Sender: TObject);
    procedure FMELabUnFlipClick(Sender: TObject);
    procedure FMELabCompressClick(Sender: TObject);
    procedure FMELabUncompressClick(Sender: TObject);
    procedure ImageMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ANIMLabPalOptClick(Sender: TObject);
    procedure BMLabPalOptClick(Sender: TObject);
    procedure BMLabWeaponClick(Sender: TObject);
    procedure FILMLabDecompileClick(Sender: TObject);
    procedure FILMLabCompileClick(Sender: TObject);
    procedure FILMLabExportClick(Sender: TObject);
    procedure FILMLabImportClick(Sender: TObject);
    procedure FILMLabNewClick(Sender: TObject);
    procedure FILMLabClearClick(Sender: TObject);
  private
    { Private declarations }
  protected

  public
    { Public declarations }
    procedure DisplayHint(Sender: TObject);
    procedure UpdateANIMLab;
    procedure UpdateBMLab;
  end;

var
  TktWindow  : TTktWindow;
  TktHelp    : String;
  TheBMP     : TBitmap;
  OldRes     : String;
  MinusFrame : Integer;

implementation
{$R *.DFM}

procedure TTktWindow.DisplayHint(Sender: TObject);
begin
  PanelText.Caption := Application.Hint;
end;

{  **********  **********  **********  **********  **********  **********  }

procedure TTktWindow.FormCreate(Sender: TObject);
begin
  TktWindow.Left   := Ini.ReadInteger('WINDOWS', 'WDFUSE Toolkit X', 0);
  TktWindow.Top    := Ini.ReadInteger('WINDOWS', 'WDFUSE Toolkit Y', 72);
  TktWindow.Width  := Ini.ReadInteger('WINDOWS', 'WDFUSE Toolkit W', 629);
  TktWindow.Height := Ini.ReadInteger('WINDOWS', 'WDFUSE Toolkit H', 440);

  Application.CreateForm(TTktInfoWindow, TktInfoWindow);
  Application.CreateForm(TConvertWindow, ConvertWindow);
  Application.CreateForm(TTktPalette, TktPalette);

  SEcontrast.Value := _VGA_MULTIPLIER;
  OldRes     := '';
  ThePAL     := '';
  MinusFrame := -1;
  TktHelp    := 'wdftkt_help_viewconvert';
end;

procedure TTktWindow.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Ini.WriteInteger('WINDOWS', 'WDFUSE Toolkit X', TktWindow.Left);
  Ini.WriteInteger('WINDOWS', 'WDFUSE Toolkit Y', TktWindow.Top);
  Ini.WriteInteger('WINDOWS', 'WDFUSE Toolkit W', TktWindow.Width);
  Ini.WriteInteger('WINDOWS', 'WDFUSE Toolkit H', TktWindow.Height);

  TktPalette.Destroy;
  ConvertWindow.Destroy;
  TktInfoWindow.Destroy;
end;

procedure TTktWindow.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
 CanClose := TRUE;
end;

procedure TTktWindow.FormActivate(Sender: TObject);
begin
  KeyPreview := TRUE;
  Application.OnHint := DisplayHint;
  if not DirectoryExists(WDFUSEdir + '\WDFGRAPH') then
    ForceDirectories(WDFUSEdir + '\WDFGRAPH');
  if not DirectoryExists(WDFUSEdir + '\WDFSOUND') then
    ForceDirectories(WDFUSEdir + '\WDFSOUND');
end;

procedure TTktWindow.SpeedButtonAboutClick(Sender: TObject);
begin
  Application.CreateForm(TAboutBox, AboutBox);
  AboutBox.ShowModal;
  AboutBox.Destroy;
end;

procedure TTktWindow.SpeedButtonExitClick(Sender: TObject);
begin
  TktWindow.Close;
end;

procedure TTktWindow.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Shift = [] then
  Case Key of
    VK_RETURN  : begin
                 end;
  end;

  if Shift = [ssShift] then
  Case Key of
    VK_RETURN  : begin
                 end;
  end;

  if Shift = [ssCtrl] then
  Case Key of
    VK_RETURN  : begin
                 end;
  end;

  if Shift = [ssAlt] then
  Case Key of
    VK_RETURN  : begin
                 end;
  end;
end;

procedure TTktWindow.SpeedButtonStatClick(Sender: TObject);
begin
  Application.CreateForm(TStatWindow, StatWindow);
  StatWindow.ShowModal;
  StatWindow.Destroy;
end;

procedure TTktWindow.SpeedButtonHelpClick(Sender: TObject);
begin
 Application.HelpJump(TktHelp);
end;

procedure TTktWindow.SpeedButtonGobFMClick(Sender: TObject);
begin
 Application.CreateForm(TGOBWindow, GOBWindow);
 GOBWindow.ShowModal;
 GOBWindow.Destroy;
 Application.OnHint := DisplayHint;
end;

procedure TTktWindow.SpeedButtonLfdFMClick(Sender: TObject);
begin
 Application.CreateForm(TLFDWindow, LFDWindow);
 LFDWindow.ShowModal;
 LFDWindow.Destroy;
 Application.OnHint := DisplayHint;
end;

procedure TTktWindow.ImageMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin

 if ViewerFile.ItemIndex <> -1 then
  begin
   Image.Hint := Format('|%3.3d : %3.3d', [X, Y]);
   if ViewerFilter.Mask = '*.3DO' then
    Image.Hint := '';
   if (ViewerFilter.Mask = '*.PAL') or
      (ViewerFilter.Mask = '*.PLT') then
    Image.Hint := Format('|Color %3.3d  0x%2.2X',
                        [(X div rs) + 16 * (Y div rs),
                         (X div rs) + 16 * (Y div rs)]);
   if ViewerFilter.Mask = '*.CMP' then
    Image.Hint := Format('|Color %3.3d  0x%2.2X  Light %2.2d  0x%2.2X',
                        [Y div rcs, Y div rcs,
                         31 - (X div rcs), 31 - (X div rcs)]);
  end
 else
  Image.Hint := '';

end;

procedure TTktWindow.BNViewRefreshClick(Sender: TObject);
begin
 ViewerDrive.Update;
 ViewerDirectory.Update;
 ViewerFile.Update;
end;

procedure TTktWindow.ViewerPaletteSelectClick(Sender: TObject);
var n : Integer;
begin
 with OpenPALorPLTT do
   BEGIN
    if FilterIndex = 1 then
     HistoryList := PAL_History
    else
     HistoryList := PLT_History;

    if Execute then
     begin
      ViewerPalette.Text := LowerCase(FileName);
      ThePAL             := LowerCase(FileName);
      if FilterIndex = 1 then
       begin
        n := PAL_HISTORY.IndexOf(LowerCase(FileName));
        if n <> -1 then PAL_History.Delete(n);
        PAL_History.Insert(0, LowerCase(FileName));
       end
      else
       begin
        n := PLT_HISTORY.IndexOf(LowerCase(FileName));
        if n <> -1 then PLT_History.Delete(n);
        PLT_History.Insert(0, LowerCase(FileName));
       end;
     end;
   END;
end;

procedure TTktWindow.ViewerFilterClick(Sender: TObject);
begin

 SBFirstFrame.Visible := FALSE;
 SBPrevFrame.Visible  := FALSE;
 SBNextFrame.Visible  := FALSE;
 SBLastFrame.Visible  := FALSE;
 EDFrameNum.Text      := '';
 EDFrameNum.Visible   := FALSE;

 if ViewerFilter.Mask = '*.3DO' then
   OpenPALorPLTT.FilterIndex := 1;

 if ViewerFilter.Mask = '*.ANM' then
  begin
   OpenPALorPLTT.FilterIndex := 2;
   SBFirstFrame.Visible := TRUE;
   SBPrevFrame.Visible  := TRUE;
   SBNextFrame.Visible  := TRUE;
   SBLastFrame.Visible  := TRUE;
   CurFrame             := 0;
   EDFrameNum.Text      := '0';
   EDFrameNum.Visible   := TRUE;
  end;

 if ViewerFilter.Mask = '*.BM' then
   OpenPALorPLTT.FilterIndex := 1;

 if ViewerFilter.Mask = '*.BMP' then
   OpenPALorPLTT.FilterIndex := 1;

 if ViewerFilter.Mask = '*.CMP' then
   OpenPALorPLTT.FilterIndex := 1;

 if ViewerFilter.Mask = '*.DLT' then
   OpenPALorPLTT.FilterIndex := 2;

 if ViewerFilter.Mask = '*.FLM' then
   OpenPALorPLTT.FilterIndex := 1;

 if ViewerFilter.Mask = '*.FME' then
   OpenPALorPLTT.FilterIndex := 1;

 if ViewerFilter.Mask = '*.PAL' then
   OpenPALorPLTT.FilterIndex := 1;

 if ViewerFilter.Mask = '*.PLT' then
   OpenPALorPLTT.FilterIndex := 1;

 if ViewerFilter.Mask = '*.WAX' then
   OpenPALorPLTT.FilterIndex := 1;

 Image.Height := 0;
 Image.Width := 0;
 Image.ReFresh;
end;

procedure TTktWindow.BNInfoClick(Sender: TObject);
begin
 TktInfoWindow.ShowModal;
end;

procedure TTktWindow.BNConvertClick(Sender: TObject);
begin
 ConvertWindow.ShowModal;
end;

procedure TTktWindow.ViewerFileClick(Sender: TObject);
var s      : String;
    noPAL  : array[0..60] of char;
    noPLTT : array[0..60] of char;
    TlKit  : array[0..60] of char;
begin
 strcopy(noPAL, 'You must select a PAL palette !');
 strcopy(noPLTT, 'You must select a PLTT palette !');
 strcopy(TlKit, 'WDFUSE Toolkit');

 BNInfo.Enabled    := TRUE;

 s := ViewerDirectory.Directory;
 if Length(s) <> 3 then s := s + '\';
 TheRes := LowerCase(s + ViewerFile.Items[ViewerFile.ItemIndex]);
 if TheRes <> OldRes then
  begin
   CurFrame := 0;
   EDFrameNum.Text := IntToStr(CurFrame);
   OldRes   := TheRes;
  end;

 if ExtractFileExt(TheRes) = '.3do' then
  begin
   TheBMP := TBitmap.Create;
   Image.Picture.Graphic := TheBMP;
   Display3DO(TheRes , UpperCase(ViewerFile.Items[ViewerFile.ItemIndex]), Image, TktInfoWindow.MemoInfo);
   Image.Height := Image.Picture.Graphic.Height;
   Image.Width  := Image.Picture.Graphic.Width;
   TheBMP.Free;
   BNConvert.Enabled := FALSE;
  end;

 if ExtractFileExt(TheRes) = '.anm' then
  begin
   if LowerCase(ExtractFileExt(ViewerPalette.Text)) = '.plt' then
    begin
     TheBMP := TBitmap.Create;
     Image.Picture.Graphic := TheBMP;
     LoadPLTTPalette(ViewerPalette.Text);
     SetBitmapPalette(HPLTTPalette, Image);
     DisplayANIMDELT(TheRes, Image, TktInfoWindow.MemoInfo, CurFrame);
     Image.Height := Image.Picture.Graphic.Height;
     Image.Width  := Image.Picture.Graphic.Width;
     DeleteObject(TheBMP.ReleasePalette);
     TheBMP.Free;
     BNConvert.Enabled := TRUE;
    end
   else
    Application.MessageBox(noPLTT, TlKit, mb_Ok or mb_IconExclamation);
  end;

 if ExtractFileExt(TheRes) = '.bmp' then
  begin
   DisplayBMP(TheRes, Image, TktInfoWindow.MemoInfo);
   BNConvert.Enabled := TRUE;
  end;

 if ExtractFileExt(TheRes) = '.bm' then
  begin
   if LowerCase(ExtractFileExt(ViewerPalette.Text)) = '.pal' then
    begin
     TheBMP := TBitmap.Create;
     Image.Picture.Graphic := TheBMP;
     LoadPALPalette(ViewerPalette.Text);
     SetBitmapPalette(HPALPalette, Image);
     DisplayBMHuge(TheRes, Image, TktInfoWindow.MemoInfo);
     Image.Height := Image.Picture.Graphic.Height;
     Image.Width  := Image.Picture.Graphic.Width;
     DeleteObject(TheBMP.ReleasePalette);
     TheBMP.Free;
     BNConvert.Enabled := TRUE;
    end
   else
    Application.MessageBox(noPAL, TlKit, mb_Ok or mb_IconExclamation);
  end;

 if ExtractFileExt(TheRes) = '.cmp' then
  begin
   if LowerCase(ExtractFileExt(ViewerPalette.Text)) = '.pal' then
    begin
     TheBMP := TBitmap.Create;
     Image.Picture.Graphic := TheBMP;
     LoadPALPalette(ViewerPalette.Text);
     SetBitmapPalette(HPALPalette, Image);
     DisplayCMP(TheRes, Image, TktInfoWindow.MemoInfo);
     Image.Height := Image.Picture.Graphic.Height;
     Image.Width  := Image.Picture.Graphic.Width;
     DeleteObject(TheBMP.ReleasePalette);
     TheBMP.Free;
     BNConvert.Enabled := FALSE;
    end
   else
    Application.MessageBox(noPAL, TlKit, mb_Ok or mb_IconExclamation);
  end;

 if ExtractFileExt(TheRes) = '.dlt' then
  begin
   if LowerCase(ExtractFileExt(ViewerPalette.Text)) = '.plt' then
    begin
     TheBMP := TBitmap.Create;
     Image.Picture.Graphic := TheBMP;
     LoadPLTTPalette(ViewerPalette.Text);
     SetBitmapPalette(HPLTTPalette, Image);
     {ZeroFrame, because this is a VAR parameter}
     DisplayANIMDELT(TheRes, Image, TktInfoWindow.MemoInfo, MinusFrame);
     Image.Height := Image.Picture.Graphic.Height;
     Image.Width  := Image.Picture.Graphic.Width;
     DeleteObject(TheBMP.ReleasePalette);
     TheBMP.Free;
     BNConvert.Enabled := TRUE;
    end
   else
    Application.MessageBox(noPLTT, TlKit, mb_Ok or mb_IconExclamation);
  end;

 if ExtractFileExt(TheRes) = '.flm' then
  begin
   {
   *** write a procedure that displays an X in the BMP for the
       non viewable resources ?
   }
   DisplayFILM(TheRes, TktInfoWindow.MemoInfo);
   BNConvert.Enabled := FALSE;
  end;

 if ExtractFileExt(TheRes) = '.fme' then
  begin
   if LowerCase(ExtractFileExt(ViewerPalette.Text)) = '.pal' then
    begin
     TheBMP := TBitmap.Create;
     Image.Picture.Graphic := TheBMP;
     LoadPALPalette(ViewerPalette.Text);
     SetBitmapPalette(HPALPalette, Image);
     DisplayFMEHuge(TheRes, Image, TktInfoWindow.MemoInfo);
     Image.Height := Image.Picture.Graphic.Height;
     Image.Width  := Image.Picture.Graphic.Width;
     DeleteObject(TheBMP.ReleasePalette);
     TheBMP.Free;
     BNConvert.Enabled := TRUE;
    end
   else
    Application.MessageBox(noPAL, TlKit, mb_Ok or mb_IconExclamation);
  end;

 if ExtractFileExt(TheRes) = '.pal' then
  begin
   ViewerPalette.Text := TheRes;
   TheBMP := TBitmap.Create;
   Image.Picture.Graphic := TheBMP;
   LoadPALPalette(ViewerPalette.Text);
   SetBitmapPalette(HPALPalette, Image);
   DisplayPAL(TheRes, Image, TktInfoWindow.MemoInfo);
   Image.Height := Image.Picture.Graphic.Height;
   Image.Width  := Image.Picture.Graphic.Width;
   DeleteObject(TheBMP.ReleasePalette);
   TheBMP.Free;
   BNConvert.Enabled := TRUE;
  end;

 if ExtractFileExt(TheRes) = '.plt' then
  begin
   ViewerPalette.Text := TheRes;
   TheBMP := TBitmap.Create;
   Image.Picture.Graphic := TheBMP;
   LoadPLTTPalette(ViewerPalette.Text);
   SetBitmapPalette(HPLTTPalette, Image);
   DisplayPLTT(TheRes, Image, TktInfoWindow.MemoInfo);
   Image.Height := Image.Picture.Graphic.Height;
   Image.Width  := Image.Picture.Graphic.Width;
   DeleteObject(TheBMP.ReleasePalette);
   TheBMP.Free;
   BNConvert.Enabled := TRUE;
  end;

 if ExtractFileExt(TheRes) = '.wax' then
  begin
   if LowerCase(ExtractFileExt(ViewerPalette.Text)) = '.pal' then
    begin
     TheBMP := TBitmap.Create;
     Image.Picture.Graphic := TheBMP;
     LoadPALPalette(ViewerPalette.Text);
     SetBitmapPalette(HPALPalette, Image);
     DisplayWAXHuge(TheRes, Image, TktInfoWindow.MemoInfo);
     Image.Height := Image.Picture.Graphic.Height;
     Image.Width  := Image.Picture.Graphic.Width;
     DeleteObject(TheBMP.ReleasePalette);
     TheBMP.Free;
     BNConvert.Enabled := FALSE;
    end
   else
    Application.MessageBox(noPAL, TlKit, mb_Ok or mb_IconExclamation);
  end;
end;

procedure TTktWindow.ViewerFileChange(Sender: TObject);
begin
 {Update the Info and Convert buttons status}
 if ViewerFile.ItemIndex = -1 then
  begin
   BNInfo.Enabled    := TRUE;
   BNConvert.Enabled := FALSE;
  end;
end;

procedure TTktWindow.SEcontrastChange(Sender: TObject);
begin
 _VGA_MULTIPLIER := SEcontrast.Value;
 if ViewerFile.ItemIndex <> -1 then
  ViewerFileClick(NIL);
end;

procedure TTktWindow.SBFirstFrameClick(Sender: TObject);
begin
 CurFrame := 0;
 if ViewerFile.ItemIndex <> -1 then
  begin
   ViewerFileClick(NIL);
   EDFrameNum.Text      := IntToStr(CurFrame);
  end;
end;

procedure TTktWindow.SBPrevFrameClick(Sender: TObject);
begin
 Dec(CurFrame);
 if CurFrame < 0 then CurFrame := 0;
 if ViewerFile.ItemIndex <> -1 then
  begin
   ViewerFileClick(NIL);
   EDFrameNum.Text      := IntToStr(CurFrame);
  end;
end;

procedure TTktWindow.SBNextFrameClick(Sender: TObject);
begin
 Inc(CurFrame);
 if ViewerFile.ItemIndex <> -1 then
  begin
   ViewerFileClick(NIL);
   EDFrameNum.Text      := IntToStr(CurFrame);
  end;
end;

procedure TTktWindow.SBLastFrameClick(Sender: TObject);
begin
 CurFrame := 30000;
 if ViewerFile.ItemIndex <> -1 then
  begin
   ViewerFileClick(NIL);
   EDFrameNum.Text      := IntToStr(CurFrame);
  end;
end;

procedure TTktWindow.TabbedNotebookChange(Sender: TObject;
  NewTab: Integer; var AllowChange: Boolean);
begin
  AllowChange := FALSE;
  TktHelp    := 'wdftkt_help_viewconvert'; {by default}

  if TabbedNotebook.GetIndexForPage('View/Convert') = NewTab then
   begin
    AllowChange := TRUE;
   end;

  if TabbedNotebook.GetIndexForPage('ANIM Lab') = NewTab then
   begin
    TktHelp    := 'wdftkt_help_labanim';
    if (ViewerFilter.Mask = '*.ANM') and (ViewerFile.ItemIndex <> -1) then
     begin
      UpdateANIMLab;
     end
    else
     begin
      ANIMLabAnimName.Text    := 'Select an ANIM in View/Convert OR Create a new ANIM !';
      ANIMLabGroup.Enabled    := FALSE;
      ANIMLabSplit.Enabled    := FALSE;
      ANIMLabSplitDirName.Caption := 'Not split !';
      ANIMLabSplitDir.Visible := FALSE;
      ANIMLabSplitFilter.Visible := FALSE;
      ANIMLabConvert.Visible  := FALSE;
      ANIMLabPalOpt.Visible  := FALSE;
     end;
    AllowChange := TRUE;
   end;

  if TabbedNotebook.GetIndexForPage('BM Lab') = NewTab then
   begin
    TktHelp    := 'wdftkt_help_labbm';
    if (ViewerFilter.Mask = '*.BM') and (ViewerFile.ItemIndex <> -1) then
     begin
      UpdateBMLab;
      BMLabTransparent.Enabled := TRUE;
      BMLabOpaque.Enabled := TRUE;
      BMLabWeapon.Enabled := TRUE;
     end
    else
     begin
      BMLabBMName.Text := 'Select a BM in View/Convert OR Create a new multiple BM !';
      BMLabGroup.Enabled := FALSE;
      BMLabSplit.Enabled := FALSE;
      BMLabSplitDirName.Caption := 'Not split !';
      BMLabSplitDir.Visible := FALSE;
      BMLabSplitFilter.Visible := FALSE;
      BMLabConvert.Visible := FALSE;
      BMLabPalOpt.Visible  := FALSE;
      BMLabTransparent.Enabled := FALSE;
      BMLabOpaque.Enabled := FALSE;
      BMLabWeapon.Enabled := FALSE;
     end;
    AllowChange := TRUE;
   end;

  if TabbedNotebook.GetIndexForPage('DELT Lab') = NewTab then
   begin
    TktHelp    := 'wdftkt_help_labdelt';
    if (ViewerFilter.Mask = '*.DLT') and (ViewerFile.ItemIndex <> -1) then
     begin
      DELTLabGetOffsets.Enabled := TRUE;
      DELTLabApplyOffsets.Enabled := TRUE;
      DELTLabDeltName.Text := TheRES;
      DELTLabGetOffsetsClick(NIL);
     end
    else
     begin
      DELTLabDeltName.Text := 'Select a DELT in View/Convert !';
      DELTLabXOffset.Text := '';
      DELTLabYOffset.Text := '';
      DELTLabGetOffsets.Enabled := FALSE;
      DELTLabApplyOffsets.Enabled := FALSE;
     end;
    AllowChange := TRUE;
   end;

  if TabbedNotebook.GetIndexForPage('FILM Lab') = NewTab then
   begin
    TktHelp    := 'wdftkt_help_labfilm';   {!!!!!}
    if (ViewerFilter.Mask = '*.FLM') and (ViewerFile.ItemIndex <> -1) then
     begin
      FILMLabFilmName.Text     := TheRES;
      FILMLabDecompile.Enabled := TRUE;
      FILMLabCompile.Enabled   := TRUE;
      FILMLabExport.Enabled    := TRUE;
      FILMLabImport.Enabled    := TRUE;
      FILMLabNew.Enabled       := TRUE;
     end
    else
     begin
      FILMLabFilmName.Text     := 'Select a FILM in View/Convert !';
      FILMLabDecompile.Enabled := FALSE;
      FILMLabCompile.Enabled   := FALSE;
      FILMLabExport.Enabled    := FALSE;
      FILMLabImport.Enabled    := FALSE;
      FILMLabNew.Enabled       := TRUE;
     end;
    AllowChange := TRUE;
   end;

  if TabbedNotebook.GetIndexForPage('FME Lab') = NewTab then
   begin
    TktHelp    := 'wdftkt_help_labfme';
    if (ViewerFilter.Mask = '*.FME') and (ViewerFile.ItemIndex <> -1) then
     begin
      FMELabGetInserts.Enabled := TRUE;
      FMELabApplyInserts.Enabled := TRUE;
      FMELabFlip.Enabled := TRUE;
      FMELabUnFlip.Enabled := TRUE;
      FMELabCompress.Enabled := TRUE;
      FMELabUnCompress.Enabled := TRUE;
      FMELabFMEName.Text := TheRES;
      FMELabGetInsertsClick(NIL);
     end
    else
     begin
      FMELabFMEName.Text := 'Select a FME in View/Convert !';
      FMELabXInsert.Text := '';
      FMELabYInsert.Text := '';
      FMELabGetInserts.Enabled := FALSE;
      FMELabApplyInserts.Enabled := FALSE;
      FMELabFlip.Enabled := FALSE;
      FMELabUnFlip.Enabled := FALSE;
      FMELabCompress.Enabled := FALSE;
      FMELabUnCompress.Enabled := FALSE;
     end;
    AllowChange := TRUE;
   end;

  if not AllowChange then ShowMessage('Not Implemented Yet !')
  else TktPalette.ConvertPalette.Text := ThePAL;
end;

procedure TTktWindow.TabbedNotebookClick(Sender: TObject);
begin
 {ShowMessage('Page was clicked');}
end;

{ ANIM Lab *************************************************************** }

procedure TTktWindow.UpdateANIMLab;
var outdir : String;
begin

 ANIMLabAnimName.Text := TheRES;
 outdir := ChangeFileExt(ANIMLabAnimName.Text, '.an_');
 if DirectoryExists(outdir) then
  begin
   ANIMLabGroup.Enabled := TRUE;
   ANIMLabSplit.Enabled := FALSE;
   ANIMLabSplitDirName.Caption := outdir;
   ANIMLabSplitDir.Visible := TRUE;
   ANIMLabSplitDir.Directory := outdir;
   ANIMLabSplitFilter.Visible := TRUE;
   ANIMLabConvert.Visible := TRUE;
   ANIMLabPalOpt.Visible  := TRUE;
  end
 else
  begin
   ANIMLabGroup.Enabled := FALSE;
   ANIMLabSplit.Enabled := TRUE;
   ANIMLabSplitDirName.Caption := 'Not split !';
   ANIMLabSplitDir.Visible := FALSE;
   ANIMLabSplitFilter.Visible := FALSE;
   ANIMLabConvert.Visible := FALSE;
   ANIMLabPalOpt.Visible  := FALSE;
  end;

end;

procedure TTktWindow.ANIMLabNewAnimClick(Sender: TObject);
begin
 with ANIMLabOpenNewAnim do
  if Execute then
   begin
    TheRES := Copy(LowerCase(ExtractFilePath(FileName)),1, Length(ExtractFilePath(FileName))-2) + 'm';
    UpdateAnimLab;
    ANIMLabGroupClick(NIL);
   end;
end;

procedure TTktWindow.ANIMLabSplitClick(Sender: TObject);
var outdir : String;
begin
 outdir := ChangeFileExt(ANIMLabAnimName.Text, '.an_');
 {create the directory if it does not exist}
 if not DirectoryExists(outdir) then
  begin
   ForceDirectories(outdir);
   ViewerDirectory.Update;
  end;

 ANIMSplit(ANIMLabAnimName.Text, outdir + '\');

 ANIMLabGroup.Enabled := TRUE;
 ANIMLabSplit.Enabled := FALSE;
 ANIMLabSplitDirName.Caption := outdir;
 ANIMLabSplitDir.Visible := TRUE;
 ANIMLabSplitFilter.Visible := TRUE;
 ANIMLabConvert.Visible := TRUE;
 ANIMLabPalOpt.Visible  := TRUE;
 ANIMLabSplitDir.Directory := ANIMLabSplitDirName.Caption;
end;

procedure TTktWindow.ANIMLabGroupClick(Sender: TObject);
begin
 {reset so that the correct type (bm) shows}
 ANIMLabSplitFilter.ItemIndex := 0;
 ANIMLabSplitDir.Mask := '*.dlt';
 ANIMLabSplitDir.Update;
 ANIMGroup(ANIMLabAnimName.Text, ChangeFileExt(ANIMLabAnimName.Text, '.an_') + '\', ANIMLabSplitDir.Items);
end;

procedure TTktWindow.ANIMLabConvertClick(Sender: TObject);
var i : Integer;
begin

 if ANIMLabSplitFilter.Mask = '*.dlt' then
  begin
   {convert the selected dlt to bmp}
    if TktPalette.ConvertPalette.Text = '' then
     begin
      Application.MessageBox('You must select a palette !',
                          'WDFUSE Toolkit - Convert', mb_Ok or mb_IconExclamation);
      exit;
     end;
    for i := 0 to ANIMLabSplitDir.Items.Count - 1 do
     if ANIMLabSplitDir.Selected[i] then
      ConvertANIMDELT2BMP(ANIMLabSplitDir.Directory + '\' + ANIMLabSplitDir.Items[i],
                          TktPalette.ConvertPalette.Text,
                          ANIMLabSplitDir.Directory + '\' + ChangeFileExt(ANIMLabSplitDir.Items[i], '.bmp'),
                          -1 {it is a DELT, not an ANIM});
  end
 else
  begin
   {convert the selected bmp to dlt}
   if (TktPalette.ConvertPalette.Text = '') and not TktPalette.ConvertNoPal.Checked then
    begin
     Application.MessageBox('You must select a palette !',
                            'WDFUSE Toolkit - Convert', mb_Ok or mb_IconExclamation);
     exit;
    end;
   {always convert with 0 offsets in this multiple conversion }
   for i := 0 to ANIMLabSplitDir.Items.Count - 1 do
    if ANIMLabSplitDir.Selected[i] then
     ConvertBMP2DELT(ANIMLabSplitDir.Directory + '\' + ANIMLabSplitDir.Items[i],
                     ANIMLabSplitDir.Directory + '\' + ChangeFileExt(ANIMLabSplitDir.Items[i], '.dlt'),
                     TktPalette.ConvertPalette.Text,
                     0, 0, not TktPalette.ConvertNoPal.Checked);
  end;
  ANIMLabSplitDir.Update;
end;

procedure TTktWindow.ANIMLabPalOptClick(Sender: TObject);
begin
 TktPalette.ShowModal;
end;

{ BM Lab ***************************************************************** }

procedure TTktWindow.UpdateBMLab;
var BMIni  : TIniFile;
    Outdir : String;
begin

 BMLabBMName.Text := TheRES;
 OutDir := ChangeFileExt(TheRES, '.bm_');
 if DirectoryExists(OutDir) then
  begin
   BMLabGroup.Enabled := TRUE;
   BMLabSplit.Enabled := FALSE;
   BMLabSplitDirName.Caption := OutDir;
   BMLabSplitDir.Visible := TRUE;
   BMLabSplitDir.Directory := OutDir;
   BMLabSplitFilter.Visible := TRUE;
   BMLabConvert.Visible := TRUE;
   BMLabPalOpt.Visible  := TRUE;
   BMLabSpeed.Visible := TRUE;
   BMLabSpeedLabel.Visible := TRUE;
   BMIni := TIniFile.Create(OutDir + '\' + 'multi_bm.ini');
   BMLabSpeed.Value := BMIni.ReadInteger('MULTI_BM', 'Frame Rate', -1);
   BMIni.Free;
  end
 else
  begin
   BMLabGroup.Enabled := FALSE;
   BMLabSplit.Enabled := TRUE;
   BMLabSplitDirName.Caption := 'Not split !';
   BMLabSplitDir.Visible := FALSE;
   BMLabSplitFilter.Visible := FALSE;
   BMLabConvert.Visible := FALSE;
   BMLabPalOpt.Visible  := FALSE;
   BMLabSpeed.Value := -1;
   BMLabSpeed.Visible := FALSE;
   BMLabSpeedLabel.Visible := FALSE;
  end;

end;

procedure TTktWindow.BMLabNewBMClick(Sender: TObject);
begin
 with BMLabOpenNewBM do
  if Execute then
   begin
    TheRES := Copy(LowerCase(ExtractFilePath(FileName)),1, Length(ExtractFilePath(FileName))-2);
    UpdateBMLab;
    BMLabGroupClick(NIL);
    BMLabTransparent.Enabled := TRUE;
    BMLabOpaque.Enabled := TRUE;
    BMLabWeapon.Enabled := TRUE;
   end;
end;

procedure TTktWindow.BMLabSplitClick(Sender: TObject);
var outdir : String;
    BMIni  : TIniFile;
begin
 outdir := ChangeFileExt(BMLabBmName.Text, '.bm_');
 {create the directory if it does not exist}
 if not DirectoryExists(outdir) then
  begin
   ForceDirectories(outdir);
   ViewerDirectory.Update;
  end;

 if BMSplit(BMLabBmName.Text, outdir + '\') then
  begin
   BMLabGroup.Enabled := TRUE;
   BMLabSplit.Enabled := FALSE;
   BMLabSplitDirName.Caption := outdir;
   BMLabSplitDir.Visible := TRUE;
   BMLabSplitFilter.Visible := TRUE;
   BMLabConvert.Visible := TRUE;
   BMLabPalOpt.Visible  := TRUE;
   BMLabSplitDir.Directory := outdir;
   BMLabSpeedLabel.Visible := TRUE;
   BMLabSpeed.Visible := TRUE;
   BMIni := TIniFile.Create(OutDir + '\' + 'multi_bm.ini');
   BMLabSpeed.Value := BMIni.ReadInteger('MULTI_BM', 'Frame Rate', -1);
   BMIni.Free;
  end;
end;

procedure TTktWindow.BMLabGroupClick(Sender: TObject);
var outdir : String;
    BMIni  : TIniFile;
begin
 outdir := ChangeFileExt(BMLabBmName.Text, '.bm_');

 {update the frame rate except if -1 }
 if BMLabSpeed.Value <> -1 then
  begin
   BMIni := TIniFile.Create(OutDir + '\' + 'multi_bm.ini');
   BMIni.WriteInteger('MULTI_BM', 'Frame Rate', BMLabSpeed.Value);
   BMIni.Free;
  end;

 {reset so that the correct type (bm) shows}
 BMLabSplitFilter.ItemIndex := 0;
 BMLabSplitDir.Mask := '*.bm';
 BMLabSplitDir.Update;

 BMGroup(BMLabBmName.Text,
         outdir + '\',
         BMLabSplitDir.Items);
end;

procedure TTktWindow.BMLabConvertClick(Sender: TObject);
var i  : Integer;
    tr : Boolean;
begin

 if BMLabSplitFilter.Mask = '*.bm' then
  begin
   {convert the selected bm to bmp}
    if TktPalette.ConvertPalette.Text = '' then
     begin
      Application.MessageBox('You must select a palette !',
                          'WDFUSE Toolkit - Convert', mb_Ok or mb_IconExclamation);
      exit;
     end;
    for i := 0 to BMLabSplitDir.Items.Count - 1 do
     if BMLabSplitDir.Selected[i] then
      ConvertBM2BMP(BMLabSplitDir.Directory + '\' + BMLabSplitDir.Items[i],
                    TktPalette.ConvertPalette.Text,
                    BMLabSplitDir.Directory + '\' + ChangeFileExt(BMLabSplitDir.Items[i], '.bmp'));
  end
 else
  begin
   {convert the selected bmp to bm}
   if (TktPalette.ConvertPalette.Text = '') and not TktPalette.ConvertNoPal.Checked then
    begin
     Application.MessageBox('You must select a palette !',
                            'WDFUSE Toolkit - Convert', mb_Ok or mb_IconExclamation);
     exit;
    end;

   if Application.MessageBox('Transparent ?',
                            'WDFUSE Toolkit - Convert', mb_YesNo or mb_IconQuestion) = IDYes then
    tr := TRUE
   else
    tr := FALSE;

   for i := 0 to BMLabSplitDir.Items.Count - 1 do
    if BMLabSplitDir.Selected[i] then
     ConvertBMP2BM(BMLabSplitDir.Directory + '\' + BMLabSplitDir.Items[i],
                     BMLabSplitDir.Directory + '\' + ChangeFileExt(BMLabSplitDir.Items[i], '.bm'),
                     TktPalette.ConvertPalette.Text,
                     not TktPalette.ConvertNoPal.Checked,
                     tr);
  end;
  BMLabSplitDir.Update;
end;

procedure TTktWindow.BMLabPalOptClick(Sender: TObject);
begin
 TktPalette.ShowModal;
end;

procedure TTktWindow.BMLabTransparentClick(Sender: TObject);
begin
 BMSetTransparent(BMLabBMName.Text, $3E);
end;

procedure TTktWindow.BMLabOpaqueClick(Sender: TObject);
begin
 BMSetTransparent(BMLabBMName.Text, $36);
end;

procedure TTktWindow.BMLabWeaponClick(Sender: TObject);
begin
 BMSetTransparent(BMLabBMName.Text, $08);
end;

{ DELT Lab *************************************************************** }

procedure TTktWindow.DELTLabGetOffsetsClick(Sender: TObject);
var x,y : Integer;
begin
 if DELTGetOffsets(DELTLabDeltName.Text, x, y) then
  begin
   DELTLabXOffset.Text := IntToStr(x);
   DELTLabYOffset.Text := IntToStr(y);
  end;
end;

procedure TTktWindow.DELTLabApplyOffsetsClick(Sender: TObject);
var x,y  : Integer;
    code : Integer;
begin
 Val(DELTLabXOffset.Text, x, code);
 if code <> 0 then
  begin
   Application.MessageBox('Invalid X Offset',
                          'WDFUSE Toolkit - DELT Offsets',
                           mb_Ok or mb_IconExclamation);
   exit;
  end;

 Val(DELTLabYOffset.Text, y, code);
 if code <> 0 then
  begin
   Application.MessageBox('Invalid Y Offset',
                          'WDFUSE Toolkit - DELT Offsets',
                           mb_Ok or mb_IconExclamation);
   exit;
  end;

 DELTSetOffsets(DELTLabDeltName.Text, x, y);
end;

{ FME Lab **************************************************************** }

procedure TTktWindow.FMELabGetInsertsClick(Sender: TObject);
var x,y : LongInt;
begin
 if FMEGetInserts(FMELabFmeName.Text, x, y) then
  begin
   FMELabXInsert.Text := IntToStr(x);
   FMELabYInsert.Text := IntToStr(y);
  end;
end;

procedure TTktWindow.FMELabApplyInsertsClick(Sender: TObject);
var x,y  : LongInt;
    code : Integer;
begin
 Val(FMELabXInsert.Text, x, code);
 if code <> 0 then
  begin
   Application.MessageBox('Invalid X Insertion point',
                          'WDFUSE Toolkit - FME Inserts',
                           mb_Ok or mb_IconExclamation);
   exit;
  end;

 Val(FMELabYInsert.Text, y, code);
 if code <> 0 then
  begin
   Application.MessageBox('Invalid Y Insertion point',
                          'WDFUSE Toolkit - FME Inserts',
                           mb_Ok or mb_IconExclamation);
   exit;
  end;

 FMESetInserts(FMELabFmeName.Text, x, y);
end;

procedure TTktWindow.FMELabFlipClick(Sender: TObject);
begin
 FMESetFlip(FMELabFmeName.Text, TRUE);
end;

procedure TTktWindow.FMELabUnFlipClick(Sender: TObject);
begin
 FMESetFlip(FMELabFmeName.Text, FALSE);
end;

procedure TTktWindow.FMELabCompressClick(Sender: TObject);
begin
 ShowMessage('Not Implemented Yet !')
end;

procedure TTktWindow.FMELabUncompressClick(Sender: TObject);
begin
 ShowMessage('Not Implemented Yet !')
end;

procedure TTktWindow.FILMLabDecompileClick(Sender: TObject);
begin
 FILMDecompile(FILMLabFilmName.Text, FILMLabMemo);
end;

procedure TTktWindow.FILMLabCompileClick(Sender: TObject);
begin
 FILMCompile(FILMLabFilmName.Text, FILMLabMemo);
end;

procedure TTktWindow.FILMLabExportClick(Sender: TObject);
begin
 with SaveExportFILM do
  begin
   FileName := ChangeFileExt(FILMLabFilmName.Text, '.scr');
   if Execute then
    FILMLabMemo.Lines.SaveToFile(FileName);
  end;
end;

procedure TTktWindow.FILMLabImportClick(Sender: TObject);
begin
  with OpenImportFILM do
  if Execute then
   begin
    FILMLabMemo.Lines.LoadFromFile(FileName);
    FILMLabFilmName.Text := ChangeFileExt(FileName, '.flm');
   end;
end;

procedure TTktWindow.FILMLabNewClick(Sender: TObject);
begin
 with SaveNewFILM do
  if Execute then
   begin
    FILMLabFilmName.Text := FileName;
   end;
end;

procedure TTktWindow.FILMLabClearClick(Sender: TObject);
begin
 FILMLabMemo.Clear;
end;

end.
