unit M_resour;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, Buttons, StdCtrls, MPlayer, FileCtrl, IniFiles,
  M_Global, V_Util, V_Util32, Menus, _Files, G_Util, Spin, StrUtils;

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
    ZoomBrightness: TStaticText;
    ZoomText: TStaticText;
    ZoomIn: TSpeedButton;
    N7501: TMenuItem;
    N10001: TMenuItem;
    PALCaption: TEdit;
    BitBtn1: TBitBtn;
    PALSelect: TComboBox;
    Label2: TLabel;
    OpenPAL: TOpenDialog;
    Label1: TLabel;
    ResourceSearch: TEdit;
    SortByHeightCheckBox: TCheckBox;
    MapTextureHeightCheckBox: TCheckBox;
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
    procedure PALClick(Sender: TObject);
    procedure FilterButtonClick(Sender: TObject);
    procedure LBResourcesKeyPress(Sender: TObject; var Key: Char);
    procedure RPPlayerNotify(Sender: TObject);
    procedure ResourceSearchClick(Sender: TObject);
    procedure BuildHeaderMap;
    procedure SortByHeightCheckBoxClick(Sender: TObject);
    procedure ResourceSearchKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure LoadFileAndFilter(FileName : String = '');
    procedure ResourceSearchMouseLeave(Sender: TObject);
    procedure PickTextureOffset;
    procedure MapTextureHeightCheckBoxClick(Sender: TObject);
    procedure TextureSort;
    procedure RPPlayerClick(Sender: TObject; Button: TMPBtnType;
      var DoDefault: Boolean);


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
  HiddenFiles   : TStringList;
  SortByHeight  : Boolean;
  FormInit      : Boolean;
  MapHeights    : Boolean;

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
    LoadFileAndFilter
 else
    LoadFileAndFilter(WDFUSEdir + '\WDFDATA\' + HiddenListBox.Items[CBPickLists.ItemIndex]);
 if SortByHeight then TextureSort;
end;


procedure TResourcePicker.RPPlayerClick(Sender: TObject; Button: TMPBtnType;
  var DoDefault: Boolean);
begin
   RPPlayer.EnabledButtons := [btPlay,btPrev, btStop, btPause];
end;

procedure TResourcePicker.RPPlayerNotify(Sender: TObject);
begin
   RPPlayer.EnabledButtons := [btPlay,btPrev];
end;

procedure TResourcePicker.FormActivate(Sender: TObject);
var f, i, initidx : Integer;
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
 SortByHeight := Ini.ReadBool('RESOURCES', 'SortByHeight', False);
 MapHeights := Ini.ReadBool('RESOURCES', 'MapHeights', False);

 FormInit := True;
 ResourceSearch.Text := 'Filter...';
 HiddenFiles := TStringList.Create;

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
             ZoomText.Visible := True;
             ZoomBrightness.Visible := True;
             ZoomIn.Visible := True;
            end;
  RST_SND : begin
             ZoomText.Visible := False;
             ZoomBrightness.Visible := False;
             ZoomIn.Visible := False;
             SeContrast.Visible := False;
             Image.Visible := FALSE;
             RPPlayer.Visible := TRUE;
             BNSaveWAV.Visible := TRUE;
             BNSaveWAV.Enabled := FALSE;
             PanelPercent.Caption  := 'N/A';
             PanelPercent.Visible  := FALSE;
             if not DirectoryExists(WDFUSEdir + '\WDFSOUND') then
              ForceDirectories(WDFUSEdir + '\WDFSOUND');
             PanelSelected.Caption := '';
             TheRPRes := '';
             RPPlayer.EnabledButtons := [btPlay,btPrev];
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
 CBPickLists.ItemIndex := RES_PICKER_TYPE;

 HiddenListBox.Items.LoadFromFile(WDFUSEdir + '\WDFDATA\' + TheGOB + '.WDN');
 HiddenListBox.ItemIndex := 0;
 HiddenFileListBox.Mask := '*.' + TheEXT;
 HiddenFileListBox.Directory := LEVELPath;

 // For Textures only
 if (RES_PICKER_MODE = RST_BM) then
    begin
       if (HEADERS_MAP.Count = 0) then BuildHeaderMap;
       SortByHeightCheckBox.Checked := SortByHeight;
       SortByHeightCheckBox.Visible := True;

       // Walls Only
       if (RES_PICKER_LEN <> 0) then
         begin
           MapTextureHeightCheckBox.Visible := True;
           MapTextureHeightCheckBox.Checked := MapHeights;
         end
       else
         begin
           MapTextureHeightCheckBox.Visible := False;
         end;
       LBResources.Sorted := not SortByHeight;
    end
  else
   begin
     SortByHeightCheckBox.Visible := False;
     MapTextureHeightCheckBox.Visible := False;
     LBResources.Sorted := True;
   end;

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
     if SortByHeight then TextureSort;

    end
   else
   {then in the gob file}
    begin
     LoadFileAndFilter(WDFUSEdir + '\WDFDATA\' + HiddenListBox.Items[RES_PICKER_TYPE]);
     f := LBResources.Items.IndexOf(RES_PICKER_VALUE);
     if f <> -1 then
      begin
       RGSource.ItemIndex := 1;
       LBResources.ItemIndex := f;
      end;
    end;
  end
 else
  begin
   {if null value in entry, present the gob}
   RGSource.ItemIndex := 1;
   LoadFileAndFilter(WDFUSEdir + '\WDFDATA\' + HiddenListBox.Items[RES_PICKER_TYPE]);
  end;
  PALCaption.Text := LEVELPath + '\' + LEVELName + '.PAL';
  if RES_PICKER_LEN <> 0 then PickTextureOffset;
  LBResources.itemindex := f;
  LBResourcesClick(NIL);
  FormInit := False;
end;

function GetHeaderHeight(AHeader : TBM_Header): Integer;
begin
  Result := 0;
  if (AHeader.Compressed = 0) and (AHeader.SizeX <> 1) or
     ((AHeader.SizeX = 1) and (AHeader.SizeY = 1)) then
     Result := AHeader.sizey
end;

function TextureCompare(AList: TStringList; left, right: Integer) : integer;
var
    left_h, right_h, txt_result : integer;
    left_tx, right_tx : string;
begin
   // Get Textures
   left_tx := AList[left];
   right_tx := AList[right];

   left_h := HEADERS_MAP[left_tx];
   right_h := HEADERS_MAP[right_tx];

   Result := left_h - right_h;

   // If Heights match then compare texture strings
   if Result = 0 then
      Result := AnsiCompareStr(left_tx, right_tx);

end;

procedure TResourcePicker.TextureSort;
var i : Integer;
    txt_name : String;
    TextHeaders : TStringList;
    txt_header : TBM_HEADER;
    txt_height : Integer;
begin

  // Dummy List to store values used to sort
  TextHeaders := TStringList.Create;

  for i := 0 to LBResources.Items.Count -1 do
    begin
      txt_name := LBResources.Items[i];

      // Populate just in case it's not in the HEADERS_MAP dict.
      if not HEADERS_MAP.ContainsKey(txt_name) then
         begin
            txt_header := GetNormalHeader(txt_name);
            txt_height := GetHeaderHeight(txt_header);
            HEADERS_MAP.Add(txt_name, txt_height);
         end;

      TextHeaders.Add(txt_name);
    end;
  // Custom Sort it in a separate list so you don't flicker LBResources
  TextHeaders.CustomSort(TextureCompare);

  // Apply the sorted headers back to the LBResources
  LBResources.Clear;
  LBResources.Items.Assign(TextHeaders);

  TextHeaders.Clear
end;

// Load height cache instead of rebuilding it.
procedure TResourcePicker.BuildHeaderMap;
var i, head_height : integer;
    wl_header : TBM_HEADER;
    texturename : String;
    heightfile : string;
    textheights : TStringList;
    rebuild : boolean;
begin

    // Populate the Texture Map for All Textures (WDF).
    HiddenFiles.clear;
    HiddenFiles.LoadFromFile(WDFUSEdir + '\WDFDATA\' + HiddenListBox.Items[0]);

    heightfile :=  WDFUSEdir + '\WDFDATA\TEXTURES.HGT';
    textheights := TstringList.Create;
    rebuild := False;

    // First check if it exists
    if FileExists(heightfile) then
       begin
          textheights.LoadFromFile(heightfile);

          // In case your cache doesn't match the GOB
          if textheights.count <> HiddenFiles.count then
            begin
              rebuild := True;
              textheights.clear;
            end
       end;

    // If it does not recalcualte heights
    if not FileExists(heightfile) or rebuild then
      begin
       for i := 0 to HiddenFiles.Count - 1  do
          begin
             // Default to zero if compressed/animated.
             texturename := HiddenFiles[i];
             wl_header := GetNormalHeader(texturename);
             head_height := GetHeaderHeight(wl_header);

             // Store the value for the future
             textheights.Add(inttostr(head_height))
          end;

        // Save the heights to the HGT file for reuse (caching).
        textheights.SaveToFile(heightfile);
      end;

    for i := 0 to HiddenFiles.Count - 1  do
       HEADERS_MAP.Add(HiddenFiles[i], strtoint(textheights[i]));

end;

procedure TResourcePicker.CBPickListsChange(Sender: TObject);
begin
 if RGSource.ItemIndex = 1 then
  begin

   // NOOP if blank selection
   if HiddenListBox.Items[CBPickLists.ItemIndex] = 'SEP.WDF' then exit;
   LoadFileAndFilter(WDFUSEdir + '\WDFDATA\' + HiddenListBox.Items[CBPickLists.ItemIndex]);
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
    attempts : LongInt;
    TheMsg : TMsg;
    WAVFile, VOCFile : TFileName;
    exists : Boolean;
    i : Integer;
    tempAsset : String;
begin

 if PeekMessage(TheMsg, 0, WM_KEYDOWN, WM_KEYDOWN, PM_NOYIELD or PM_NOREMOVE)
 then Exit;

 // nothing to display
 if LBResources.Count = 0 then exit;

 if LBResources.ItemIndex = -1 then LBResources.ItemIndex := 0;

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
             WAVFile := WDFUSEdir + '\WDFSOUND\' + 'WDF$$$$$.WAV';
             VOCFile := WDFUSEdir + '\WDFSOUND\' + 'WDF$$$$$.VOC';
             if not FileExists(WDFUSEdir + '\WDFSOUND\' + ChangeFileExt(TheRPRes, '.WAV')) then
              begin
                try
                  RPPlayer.Close;
                except on E: Exception do
                 begin
                   Log.error('Failed to Close RPPlayer! ' + E.ClassName +
                   ' error raised, with message : '+E.Message, LogName);
                  end;
                 end;
               MemoRP.Clear;
               MemoRP.Lines.Add(PanelSelected.Caption);
               MemoRP.Lines.Add('');
               {Extract from gob, or copy file}

               SysUtils.DeleteFile(VOCFile);
               try
                 if PanelSelected.Caption[1] = '[' then
                  begin
                    GOB_ExtractResource(WDFUSEdir + '\WDFSOUND\', SOUNDSgob, TheRPRes);
                    RenameFile(WDFUSEdir + '\WDFSOUND\' + TheRPRes, VOCFile);
                  end
                 else
                  begin
                   CopyFile(PanelSelected.Caption, VOCFile);
                  end;
                except on E: Exception do
                 begin
                   Log.error('Failed to Extract Sound! ' + E.ClassName +
                   ' error raised, with message : '+E.Message, LogName);
                  end;
                 end;

               MemoRP.Lines.Add(Format('WAV length : %d', [GetFileSize(WAVFile)]));
               {Call VOC2WAV}
               IF FileExists(Voc2Wav) then
                BEGIN

                 // First attempt  (timing issue)
                 if not FileExists(VOCFIle) then
                  begin
                    sleep(500);
                    if PanelSelected.Caption[1] = '[' then
                      begin
                        GOB_ExtractResource(WDFUSEdir + '\WDFSOUND\', SOUNDSgob, TheRPRes);
                        RenameFile(WDFUSEdir + '\WDFSOUND\' + TheRPRes, VOCFile);
                      end
                     else
                      begin
                       CopyFile(PanelSelected.Caption, VOCFile);
                      end;
                    // Last attempt
                    sleep(500);
                    if not FileExists(VOCFIle) then
                      begin
                       showmessage('Failed to Extract the audio. You may need to reload the Resource Editor');
                       exit;
                      end;

                  end;


                 // Remember kids always wrap your paths in quotes
                 StrPCopy(tmp, '"' + Voc2Wav + '" "' + VOCFIle +  '" "' + WAVFILE + '"');
                 SysUtils.DeleteFile(WAVFile);
                 WinExec(PAnsiChar(AnsiString(tmp)), SW_HIDE);

                 {On a un timing problem!!! L'autre demarre en parallel !!!}
                 attempts := 0;
                 while not FileExists(WAVFile)
                  do
                    begin
                     sleep(200);
                     Inc(attempts);
                     if attempts > 10 then
                      begin
                       log.Info('Failed after 10 attempts to execute ' + PAnsiChar(AnsiString(tmp)), LogName);
                       ShowMessage('Problem in VOC => WAV conversion. Aborting.');
                       exit;
                      end;
                  end;

;
                 RPPlayer.FileName := WAVFILE;
                try
                  RPPlayer.Open;
                except on E: Exception do
                 begin
                   Log.error('Failed to Open RPPlayer! ' + E.ClassName +
                   ' error raised, with message : '+E.Message, LogName);
                    sleep(100);
                    try
                     RPPlayer.Open;
                    except on E: Exception do
                        begin
                         showmessage('Failed to open RPPlayer!');
                        end;
                    end;
                  end;
                 end;
                 BNSaveWAV.Enabled := TRUE;

                 { Cache this File }
                 CopyFile(WAVFile, WDFUSEdir + '\WDFSOUND\' + ChangeFileExt(TheRPRes, '.WAV'));
               END;
              end
             else
             {the WAV exists in WDFSOUND, so use it for faster hearing}
              begin
               WAVFile := WDFUSEdir + '\WDFSOUND\' + ChangeFileExt(TheRPRes, '.WAV');
               BNSaveWAV.Enabled := FALSE;
               MemoRP.Clear;
               MemoRP.Lines.Add('[Played from WAV file in WDFSOUND]');
               MemoRP.Lines.Add(PanelSelected.Caption);
               MemoRP.Lines.Add('');
               MemoRP.Lines.Add(Format('WAV length : %d', [GetFileSize(WAVFile)]));
               RPPlayer.FileName := WDFUSEdir + '\WDFSOUND\' + ChangeFileExt(TheRPRes, '.WAV');
               RPPlayer.Open;
              end;
            end;

 END;
 if ResourceSearch.Text = '' then
   begin
     i := LBResources.ItemIndex;
     ResourceSearch.Text := 'Filter...';
     LBResources.ItemIndex := i;
   end;

end;

// Play the audio when you press Enter instead of constantly playing the Play button.
procedure TResourcePicker.LBResourcesKeyPress(Sender: TObject; var Key: Char);
begin

if (RES_PICKER_MODE = RST_SND) and (Word(Key) = VK_RETURN) then
  begin
     RPPlayer.EnabledButtons := [btPlay,btPrev, btStop, btPause];
     RPPlayer.play();
  end;
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
 Ini.WriteBool('RESOURCES', 'SortByHeight', SortByHeight);
 Ini.WriteBool('RESOURCES', 'MapHeights', MapHeights);

 // Reset texture type to all textures
 RES_PICKER_TYPE := 0;
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


procedure TResourcePicker.ResourceSearchClick(Sender: TObject);
begin
     if ResourceSearch.Text = 'Filter...' then
        ResourceSearch.Text := ''

end;

procedure TResourcePicker.ResourceSearchKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  FilterButtonClick(NIL);
end;

// If you do not put anything and move your mouse away reset to Filter...
procedure TResourcePicker.ResourceSearchMouseLeave(Sender: TObject);
begin
  if ResourceSearch.Text = '' then ResourceSearch.Text := 'Filter...';
  LBResources.SetFocus;
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

procedure TResourcePicker.PALClick(Sender: TObject);
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

//Filters the file list from HiddenFiles and updates LBResources.
procedure TResourcePicker.FilterButtonClick(Sender: TObject);
Var s : string;
    i : Integer;
begin
     if (Length(ResourceSearch.Text) > 0) and  (ResourceSearch.Text <> 'Filter...') then
      begin
        LBResources.Clear;

        s := ResourceSearch.Text;
        for i := 0 to HiddenFiles.Count - 1 do begin
          if ContainsText(UpperCase(HiddenFiles[i]), UpperCase(s)) then
            LBResources.Items.Add(HiddenFiles[i]);
        end;
      end
     else if LBResources.items.count <> HiddenFiles.count then
           LBResources.items.Assign(HiddenFiles);
     if SortByHeight then TextureSort

end;

procedure TResourcePicker.BNSaveWAVClick(Sender: TObject);
begin
 CopyFile(WDFUSEdir + '\WDFSOUND\' + 'WDF$$$$$.WAV', WDFUSEdir + '\WDFSOUND\' + ChangeFileExt(TheRPRes, '.WAV'));
 MemoRP.Lines.Add('Saved Sound file to ' + WDFUSEdir + '\WDFSOUND\' + ChangeFileExt(TheRPRes, '.WAV'));
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
 if not FormInit and (LBResources.Count <> 0) then
   LBResourcesClick(Sender); { hangs up, because list is not yet created}
end;

procedure TResourcePicker.SortByHeightCheckBoxClick(Sender: TObject);
begin

   // Don't bother to do this on init - only when user clicks it themselves.
   if FormInit then exit;

   SortByHeight := SortByHeightCheckBox.Checked;
   LBResources.Sorted := not SortByHeight;

   // Can't pick height texture if not sorted by height.
   if not SortByHeight then
     MapTextureHeightCheckBox.Checked := False;


   CBPickListsChange(NIL);
end;

// If you want to automatically map the texture height to a texture
procedure TResourcePicker.MapTextureHeightCheckBoxClick(Sender: TObject);
begin
   if FormInit then exit;

   MapHeights := MapTextureHeightCheckBox.Checked;
   if MapHeights and not SortByHeightCheckBox.Checked then
     begin
       SortByHeightCheckBox.Checked := True;
       SortByHeightCheckBoxClick(NIL);
     end;
   PickTextureOffset;
end;

// This is just a load wrapper to prevent flickering of the list as you
// load it and then apply a filter. If no file - just load the hidden items.
procedure TResourcePicker.LoadFileAndFilter(FileName : String = '');
begin
   HiddenFiles.clear;

   // Load from GOB
   if FileName <> '' then
     HiddenFiles.LoadFromFile(FileName)
   else
    begin
      // Load local assets from curdir (LEVELPATH).
      HiddenFileListBox.Update;
      HiddenFiles.AddStrings(HiddenFileListBox.Items);
    end;

    // This filters and updates the LBresources
   FilterButtonClick(NIL);

   if LBResources.Items.Count > 0 then
     begin
      if RES_PICKER_LEN <> 0 then PickTextureOffset;
      if not FormInit then LBResourcesClick(TObject(NIL));
     end;
end;

procedure TResourcePicker.PickTextureOffset;
var i, textlen : integer;
begin
  if MapHeights and SortByHeight then
   begin
    if LBResources.Count > 0 then
     begin
      if (RES_PICKER_LEN <> 0)  then
        begin
           for i := 0 to LBResources.Count - 1 do
             begin
               textlen := trunc(HEADERS_MAP[LBResources.Items[i]]/8);
               if textlen >= RES_PICKER_LEN then break
             end;
           if LBResources.Count = i then
              LBResources.ItemIndex := i-1
           else
              LBResources.ItemIndex := i;
        end
     end;
    LBResourcesClick(TObject(NIL));
   end;
end;

end.
