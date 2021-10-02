unit M_resour;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, Buttons, StdCtrls, MPlayer, FileCtrl, IniFiles,
  M_Global, V_Util, Menus, _Files, G_Util, Spin;

type
  TResourcePicker = class(TForm)
    PanelLeft: TPanel;
    Panel2: TPanel;
    PanelOther: TPanel;
    Panel1: TPanel;
    RGSource: TRadioGroup;
    CBPickLists: TComboBox;
    LBResources: TListBox;
    PanelButtonbar: TPanel;
    SpeedButtonCommit: TSpeedButton;
    SpeedButtonRollback: TSpeedButton;
    PanelBrol: TPanel;
    PanelImage: TPanel;
    HiddenFileListBox: TFileListBox;
    HiddenListBox: TListBox;
    MemoRP: TMemo;
    PopupMenu1: TPopupMenu;
    N3001: TMenuItem;
    N2001: TMenuItem;
    N1001: TMenuItem;
    N501: TMenuItem;
    N4001: TMenuItem;
    N5001: TMenuItem;
    N701: TMenuItem;
    PanelPercent: TPanel;
    PanelSelected: TPanel;
    ScrollBox1: TScrollBox;
    Image: TImage;
    N1: TMenuItem;
    Save1: TMenuItem;
    RPPlayer: TMediaPlayer;
    BNSaveWAV: TBitBtn;
    SBHelp: TSpeedButton;
    SEcontrast: TSpinEdit;
    Panel3: TPanel;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    ZoomIn: TSpeedButton;
    N7501: TMenuItem;
    N10001: TMenuItem;
    PALCaption: TEdit;
    BitBtn1: TBitBtn;
    PALSelect: TComboBox;
    Label2: TLabel;
    OpenPAL: TOpenDialog;
    Label1: TLabel;
    procedure SpeedButtonCommitClick(Sender: TObject);
    procedure RGSourceClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure CBPickListsChange(Sender: TObject);
    procedure LBResourcesClick(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure N3001Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure SpeedButtonRollbackClick(Sender: TObject);
    procedure BNSaveWAVClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SBHelpClick(Sender: TObject);
    procedure SEcontrastChange(Sender: TObject);
    procedure ZoomInClick(Sender: TObject);
    procedure PALSelectChange(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
  //  procedure TResourcePicker.ViewerPaletteSelectClick(Sender: TObject);
  private
    { Private declarations }
    procedure ResizeImage;
  public
    { Public declarations }


  end;

var
  ResourcePicker: TResourcePicker;
  GraphZoom     : Integer;
  RES_TYPE      : Integer;
  TheGOB,
  RealGOB,
  TheEXT        : String;
  TheBMP        : TBitmap;
  TheRPRes      : String;

implementation

{$R *.DFM}

uses MAPPER;

procedure TResourcePicker.SpeedButtonCommitClick(Sender: TObject);
begin
  if RES_PICKER_MODE = RST_SND then RPPlayer.Close;
  ModalResult := mrOk;
end;

procedure TResourcePicker.RGSourceClick(Sender: TObject);
begin
 LBResources.Clear;
 if RGSource.ItemIndex = 0 then
  begin
   HiddenFileListBox.Update;
   LBResources.Items.AddStrings(HiddenFileListBox.Items);
  end
 else
  begin
   LBResources.Items.LoadFromFile(WDFUSEdir + '\WDFDATA\' + HiddenListBox.Items[CBPickLists.ItemIndex]);
  end;
  LBResources.Sorted := True
end;

procedure TResourcePicker.FormActivate(Sender: TObject);
var f : Integer;
begin

  ResourcePicker.Left   := Ini.ReadInteger('WINDOWS', 'Resource Pickr X', 0);
  ResourcePicker.Top    := Ini.ReadInteger('WINDOWS', 'Resource Pickr Y', 0);
  ResourcePicker.Width  := Ini.ReadInteger('WINDOWS', 'Resource Pickr W', 1460);
  ResourcePicker.Height := Ini.ReadInteger('WINDOWS', 'Resource Pickr H', 1000);
  {
   File names are in .WDN and labels are in .WDL
   XXXXXXXX.WDF are the lists
  }
 GraphZoom := Ini.ReadInteger('RESOURCES', 'Default Zoom', 30);
 _VGA_MULTIPLIER := Ini.ReadInteger('RESOURCES', 'Brightness', 5);

 CASE RES_PICKER_MODE OF
  RST_3DO,
  RST_BM,
  RST_WAX,
  RST_FME : begin
             Image.Visible := TRUE;
             RPPlayer.Visible := FALSE;
             BNSaveWAV.Visible := FALSE;
             PanelPercent.Visible  := TRUE;
             SEcontrast.VISIBLE := TRUE;
             SEcontrast.Value := _VGA_MULTIPLIER;
             if not DirectoryExists(WDFUSEdir + '\WDFGRAPH') then
              ForceDirectories(WDFUSEdir + '\WDFGRAPH');
             GraphZoom  := GraphZoom;
             PanelPercent.Caption  := inttostr(GraphZoom) + '0%';
             PanelSelected.Caption := '';
             TheRPRes := '';
            end;
  RST_SND : begin
             Image.Visible := FALSE;
             RPPlayer.Visible := TRUE;
             BNSaveWAV.Visible := TRUE;
             BNSaveWAV.Enabled := FALSE;
             PanelPercent.Caption  := 'N/A';
             PanelPercent.Visible  := FALSE;
             SEcontrast.Visible := FALSE;
             if not DirectoryExists(WDFUSEdir + '\WDFSOUND') then
              ForceDirectories(WDFUSEdir + '\WDFSOUND');
             PanelSelected.Caption := '';
             TheRPRes := '';
            end;
 END;

 MemoRP.Clear;

 CASE RES_PICKER_MODE OF
  RST_BM  : begin
             RealGOB := TEXTURESgob;
             TheGOB  := 'TEXTURES';
             TheEXT  := 'BM';
            end;
  RST_WAX : begin
             RealGOB := SPRITESgob;
             TheGOB  := 'SPRITES';
             TheEXT  := 'WAX';
            end;
  RST_FME : begin
             RealGOB := SPRITESgob;
             TheGOB  := 'FRAMES';
             TheEXT  := 'FME';
            end;
  RST_SND : begin
             RealGOB := SOUNDSgob;
             TheGOB  := 'SOUNDS';
             TheEXT  := 'VOC';
            end;
  RST_3DO : begin
             RealGOB := DARKgob;
             TheGOB  := 'DARK';
             TheEXT  := '3DO';
            end;
 END;

 CBPickLists.Items.LoadFromFile(WDFUSEdir + '\WDFDATA\' + TheGOB + '.WDL');
 CBPickLists.ItemIndex := 0;
 HiddenListBox.Items.LoadFromFile(WDFUSEdir + '\WDFDATA\' + TheGOB + '.WDN');
 HiddenListBox.ItemIndex := 0;
 HiddenFileListBox.Mask := '*.' + TheEXT;
 HiddenFileListBox.Directory := LEVELPath;

 {Try to find the passed value first in the level dir}
 if RES_PICKER_VALUE <> '' then
  begin
   f := HiddenFileListBox.Items.IndexOf(LowerCase(RES_PICKER_VALUE));
   if f <> -1 then
    begin
     RGSource.ItemIndex := 0;
     LBResources.Clear;
     LBResources.Items.AddStrings(HiddenFileListBox.Items);
     LBResources.ItemIndex := f;
     LBResourcesClick(TObject(NIL));
    end
   else
   {then in the gob file}
    begin
     LBResources.Items.LoadFromFile(WDFUSEdir + '\WDFDATA\' + HiddenListBox.Items[0]);
     f := LBResources.Items.IndexOf(RES_PICKER_VALUE);
     if f <> -1 then
      begin
       RGSource.ItemIndex := 1;
       LBResources.ItemIndex := f;
       LBResourcesClick(TObject(NIL));
      end;
    end;
  end
 else
  begin
   {if null value in entry, present the gob}
   RGSource.ItemIndex := 1;
   LBResources.Items.LoadFromFile(WDFUSEdir + '\WDFDATA\' + HiddenListBox.Items[0]);
  end;
  LBResources.Sorted := True;
  PALCaption.Text := LEVELPath + '\' + LEVELName + '.PAL';
end;

procedure TResourcePicker.CBPickListsChange(Sender: TObject);
begin
 if RGSource.ItemIndex = 1 then
  begin
   LBResources.Clear;
   LBResources.Items.LoadFromFile(WDFUSEdir + '\WDFDATA\' + HiddenListBox.Items[CBPickLists.ItemIndex]);
   LBResources.Sorted := True
  end

end;

procedure TResourcePicker.PALSelectChange(Sender: TObject);
var PALName : String;
begin
  PALName := WDFUSEdir + '\WDFDATA\' + PALSelect.text;
  log.info('Loading Custom Pallette ' + PALName, LogName);
  if not FileExists(PALName) then
    begin
      showmessage('PAL does not exist in this location. What happened? ' + EOL + PALName);
      exit;
    end;

  CopyFile(PALName, LEVELPath + '\' + LEVELName + '.PAL');
  LoadPALPalette(LEVELPath + '\' + LEVELName + '.PAL');
  SetBitmapPalette(HPALPalette, Image);
  PALCaption.Text := WDFUSEdir + '\WDFDATA\' + PALSelect.text;
  LBResourcesClick(NIL);
end;



function ArrayToString(const a: array of Char): string;
begin
  if Length(a)>0 then
    SetString(Result, PChar(@a[0]), Length(a))
  else
    Result := '';
end;

procedure TResourcePicker.LBResourcesClick(Sender: TObject);
var tmp  : array[0..255] of Char;
    t : PAnsiChar;
    wait : LongInt;
    TheMsg : TMsg;
begin
 if PeekMessage(TheMsg, 0, WM_KEYDOWN, WM_KEYDOWN, PM_NOYIELD or PM_NOREMOVE)
 then Exit;

 TheRPRes := UpperCase(LBResources.Items[LBResources.ItemIndex]);
 RES_PICKER_VALUE := TheRPRes;
 if RGSource.ItemIndex = 0 then
  PanelSelected.Caption := Uppercase(LEVELPath) + '\' + TheRPRes
 else
  PanelSelected.Caption := '[' + Uppercase(RealGob) + ']' + TheRPRes;

 {draw/play PanelSelected.Caption}
 CASE RES_PICKER_MODE OF
  RST_3DO,
  RST_BM,
  RST_WAX,
  RST_FME : begin
             if not FileExists(WDFUSEdir + '\WDFGRAPH\' + ChangeFileExt(TheRPRes, '.BMP')) then
              begin
               TheBMP := TBitmap.Create;
               Image.Picture.Graphic := TheBMP;
               LoadPALPalette(LEVELPath + '\' + LEVELName + '.PAL');
               SetBitmapPalette(HPALPalette, Image);
               CASE RES_PICKER_MODE OF
                RST_BM  : DisplayBMHuge(PanelSelected.Caption, Image, MemoRP);
                RST_WAX : DisplayWAXHuge(PanelSelected.Caption, Image, MemoRP);
                RST_FME : DisplayFMEHuge(PanelSelected.Caption, Image, MemoRP);
                RST_3DO : Display3DO(PanelSelected.Caption, TheRPRes, Image, MemoRP);
               END;
               TheBMP.ReleasePalette;
               TheBMP.Free;
              end
             else
             {the BMP exists in WDFGRAPH, so use it for faster display}
              begin
               TheBMP.ReleasePalette;
               Image.Picture.LoadFromFile(WDFUSEdir + '\WDFGRAPH\' + ChangeFileExt(TheRPRes, '.BMP'));
               MemoRP.Clear;
               MemoRP.Lines.Add('QuickShow... ' + WDFUSEdir + '\WDFGRAPH\' + TheRPRes + 'P');
               MemoRP.Lines.Add(' ');
               MemoRP.Lines.Add('Size X      : ' + IntToStr(Image.Picture.Bitmap.Width));
               MemoRP.Lines.Add('Size Y      : ' + IntToStr(Image.Picture.Bitmap.Height));
               MemoRP.Lines.Add(' ');
               MemoRP.Lines.Add('[No additional info from BMP file]');
              end;
             {Image.Invalidate;}
             ResizeImage;
            end;
  RST_SND : begin
             if not FileExists(WDFUSEdir + '\WDFSOUND\' + ChangeFileExt(TheRPRes, '.WAV')) then
              begin
               RPPlayer.Close;
               MemoRP.Clear;
               MemoRP.Lines.Add(PanelSelected.Caption);
               MemoRP.Lines.Add('');
               {Extract from gob, or copy file}
               SysUtils.DeleteFile(WDFUSEdir + '\WDFSOUND\' + 'WDF$$$$$.VOC');
               if PanelSelected.Caption[1] = '[' then
                begin
                 GOB_ExtractResource(WDFUSEdir + '\WDFSOUND\', SOUNDSgob, TheRPRes);
                 RenameFile(WDFUSEdir + '\WDFSOUND\' + TheRPRes, WDFUSEdir + '\WDFSOUND\' + 'WDF$$$$$.VOC');
                end
               else
                begin
                 CopyFile(PanelSelected.Caption, WDFUSEdir + '\WDFSOUND\' + 'WDF$$$$$.VOC');
                end;

               MemoRP.Lines.Add(Format('VOC length : %d', [GetFileSize(WDFUSEdir + '\WDFSOUND\' + 'WDF$$$$$.VOC')]));
               {Call VOC2WAV}
               IF FileExists(Voc2Wav) then
                BEGIN
                 StrPCopy(tmp, Voc2Wav + ' '
                             + WDFUSEdir + '\WDFSOUND\' + 'WDF$$$$$.VOC '
                             + WDFUSEdir + '\WDFSOUND\' + 'WDF$$$$$.WAV');
                 SysUtils.DeleteFile(WDFUSEdir + '\WDFSOUND\' + 'WDF$$$$$.WAV');

                 WinExec(PAnsiChar(AnsiString(tmp)), SW_HIDE);
                 {On a un timing problem!!! L'autre demarre en parallel !!!}
                 Wait := 0;
                 while not FileExists(WDFUSEdir + '\WDFSOUND\' + 'WDF$$$$$.WAV')
                 do
                  begin
                   Yield;
                   Inc(Wait);
                   if Wait > 100000 then
                    begin
                     ShowMessage('Problem in VOC => WAV conversion. Aborting.');
                     exit;
                    end;
                  end;

                 RPPlayer.FileName := WDFUSEdir + '\WDFSOUND\' + 'WDF$$$$$.WAV';
                 RPPlayer.Open;
                 BNSaveWAV.Enabled := TRUE;
               END;
              end
             else
             {the WAV exists in WDFSOUND, so use it for faster hearing}
              begin
               BNSaveWAV.Enabled := FALSE;
               MemoRP.Clear;
               MemoRP.Lines.Add('[Played from WAV file in WDFSOUND]');
               RPPlayer.FileName := WDFUSEdir + '\WDFSOUND\' + ChangeFileExt(TheRPRes, '.WAV');
               RPPlayer.Open;
              end;
            end;
 END;

end;

procedure TResourcePicker.FormDeactivate(Sender: TObject);
begin
 CASE RES_PICKER_MODE OF
  RST_3DO,
  RST_BM,
  RST_WAX,
  RST_FME : begin
            end;
  RST_SND : begin
             RPPlayer.Close;
            end;
 END;
 Ini.WriteInteger('WINDOWS', 'Resource Pickr X', ResourcePicker.Left);
 Ini.WriteInteger('WINDOWS', 'Resource Pickr Y', ResourcePicker.Top);
 Ini.WriteInteger('WINDOWS', 'Resource Pickr W', ResourcePicker.Width);
 Ini.WriteInteger('WINDOWS', 'Resource Pickr H', ResourcePicker.Height);
 Ini.WriteInteger('RESOURCES', 'Default Zoom', GraphZoom);
 Ini.WriteInteger('RESOURCES', 'Brightness', _VGA_MULTIPLIER);

end;

procedure TResourcePicker.ResizeImage;
var He,Wi : Integer;
begin
  He := (Image.Picture.Bitmap.Height * GraphZoom) div 10;
  Wi := (Image.Picture.Bitmap.Width  * GraphZoom) div 10;
  Image.Height := He;
  Image.Width  := Wi;
  PanelPercent.Caption := IntToStr(GraphZoom*10) + '%';
end;

procedure TResourcePicker.N3001Click(Sender: TObject);
begin
 CASE RES_PICKER_MODE OF
  RST_3DO,
  RST_BM,
  RST_WAX,
  RST_FME : begin
             if Sender = N10001 then     GraphZoom  := 100;
             if Sender = N7501  then      GraphZoom  := 75;
             if Sender = N5001  then      GraphZoom  := 50;
             if Sender = N4001  then      GraphZoom  := 40;
             if Sender = N3001  then      GraphZoom  := 30;
             if Sender = N2001  then      GraphZoom  := 20;
             if Sender = N1001  then      GraphZoom  := 10;
             if Sender = N701   then      GraphZoom  :=  7;
             if Sender = N501   then      GraphZoom  :=  5;
             ResizeImage;
            end;
 END;
end;

procedure TResourcePicker.Save1Click(Sender: TObject);
begin
if PanelSelected.Caption <> '' then
 CASE RES_PICKER_MODE OF
  RST_3DO,
  RST_BM,
  RST_WAX,
  RST_FME : begin
             Image.Picture.SaveToFile(WDFUSEdir + '\WDFGRAPH\' + ChangeFileExt(TheRPRes, '.BMP'));
            end;
 END;
end;

procedure TResourcePicker.SpeedButtonRollbackClick(Sender: TObject);
begin
 if RES_PICKER_MODE = RST_SND then RPPlayer.Close;
 ModalResult := mrCancel;
end;

procedure TResourcePicker.ZoomInClick(Sender: TObject);
begin
  PopUpMenu1.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure TResourcePicker.BitBtn1Click(Sender: TObject);
begin
 with OpenPAL do
   BEGIN
    if Execute then
     begin
        CopyFile(FileName, LEVELPath + '\' + LEVELName + '.PAL');
        LoadPALPalette(LEVELPath + '\' + LEVELName + '.PAL');
        SetBitmapPalette(HPALPalette, Image);
        PALCaption.Text := FileName;
        LBResourcesClick(NIL);
     end;
   END;
end;

procedure TResourcePicker.BNSaveWAVClick(Sender: TObject);
begin
 CopyFile(WDFUSEdir + '\WDFSOUND\' + 'WDF$$$$$.WAV', WDFUSEdir + '\WDFSOUND\' + ChangeFileExt(TheRPRes, '.WAV'));
end;

procedure TResourcePicker.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
if Shift = [] then
    Case Key of
      VK_F1     : MapWindow.HelpTutorialClick(NIL);
      VK_F2     : SpeedButtonCommitClick(NIL);
      VK_ESCAPE : SpeedButtonRollbackClick(NIL);
    end;
end;

procedure TResourcePicker.SBHelpClick(Sender: TObject);
begin
 MapWindow.HelpTutorialClick(NIL);
end;

procedure TResourcePicker.SEcontrastChange(Sender: TObject);
begin
 _VGA_MULTIPLIER := SEcontrast.Value;
 if LBResources.Count <> 0 then
   LBResourcesClick(Sender); { hangs up, because list is not yet created}
end;

end.
