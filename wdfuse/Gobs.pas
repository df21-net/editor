 unit Gobs;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Buttons, ExtCtrls, Menus, StdCtrls, IniFiles,
  FileCtrl, Gauges, M_About, G_Util, Gobdir, M_Global;

type
  TGOBWindow = class(TForm)
    SpeedBar: TPanel;
    SP_Main: TPanel;
    SP_Progress: TPanel;
    SP_Text: TPanel;
    GOBDirList: TListBox;
    DirectoryListBox1: TDirectoryListBox;
    DriveComboBox1: TDriveComboBox;
    FilterComboBox1: TFilterComboBox;
    FileNameEdit: TEdit;
    ProgressBar: TGauge;
    GOBBrowseGOB: TOpenDialog;
    DirLabel: TLabel;
    GOBAdd: TBitBtn;
    GOBRemove: TBitBtn;
    GOBExtract: TBitBtn;
    GOBCreateSaveDialog: TSaveDialog;
    FSPopupMenu: TPopupMenu;
    SelectAll1: TMenuItem;
    DeselectAll1: TMenuItem;
    N2: TMenuItem;
    SelectBM1: TMenuItem;
    SelectFME1: TMenuItem;
    SelectVOC1: TMenuItem;
    Select3DO1: TMenuItem;
    SelectVUE1: TMenuItem;
    SelectGMD1: TMenuItem;
    SelectWAX1: TMenuItem;
    N3: TMenuItem;
    N5: TMenuItem;
    SelectTXT1: TMenuItem;
    SelectLVL1: TMenuItem;
    N6: TMenuItem;
    SelectMSG1: TMenuItem;
    SelectLST1: TMenuItem;
    Levels1: TMenuItem;
    SelectSECBASE1: TMenuItem;
    SelectTALAY1: TMenuItem;
    SelectSEWERS1: TMenuItem;
    SelectPAL1: TMenuItem;
    GOBPopupMenu: TPopupMenu;
    SelectAll2: TMenuItem;
    DeSelectAll2: TMenuItem;
    MenuItem3: TMenuItem;
    Select3DO2: TMenuItem;
    SelectBM2: TMenuItem;
    SelectFME2: TMenuItem;
    SelectPAL2: TMenuItem;
    SelectWAX2: TMenuItem;
    MenuItem9: TMenuItem;
    SelectGMD2: TMenuItem;
    SelectVOC2: TMenuItem;
    MenuItem12: TMenuItem;
    SelectLST2: TMenuItem;
    SelectLVL2: TMenuItem;
    SelectMSG2: TMenuItem;
    SelectTXT2: TMenuItem;
    SelectVUE2: TMenuItem;
    MenuItem18: TMenuItem;
    Levels2: TMenuItem;
    SelectSECBASE2: TMenuItem;
    SelectTALAY2: TMenuItem;
    SelectSEWERS2: TMenuItem;
    InvertSelection1: TMenuItem;
    InvertSelection2: TMenuItem;
    BNRefresh: TBitBtn;
    SelectTESTBASE1: TMenuItem;
    SelectGROMAS1: TMenuItem;
    SelectDTENTION1: TMenuItem;
    SelectRAMSHED1: TMenuItem;
    SelectROBOTICS1: TMenuItem;
    SelectNARSHADA1: TMenuItem;
    SelectJABSHIP1: TMenuItem;
    SelectIMPCITY1: TMenuItem;
    SelectFUELSTAT1: TMenuItem;
    SelectEXECUTOR1: TMenuItem;
    SelectARC1: TMenuItem;
    SelectTESTBASE2: TMenuItem;
    SelectGROMAS2: TMenuItem;
    SelectDTENTION2: TMenuItem;
    SelectRAMSHED2: TMenuItem;
    SelectROBOTICS2: TMenuItem;
    SelectNARSHADA2: TMenuItem;
    SelectJABSHIP2: TMenuItem;
    SelectIMPCITY2: TMenuItem;
    SelectFUELSTAT2: TMenuItem;
    SelectEXECUTOR2: TMenuItem;
    SelectARC2: TMenuItem;
    SpeedButtonHelp: TSpeedButton;
    FileListBox1: TFileListBox;
    PanelGOBName: TPanel;
    GOBCreate: TBitBtn;
    GOBDelete: TBitBtn;
    GOBInfo: TBitBtn;
    GOBHintListBox: TListBox;
    PanelGOBEntries: TPanel;
    Label1: TLabel;
    RadioGroup1: TRadioGroup;
    GOBChkBx: TCheckBox;
    GOBBrowse: TBitBtn;
    GOBOKBtn: TBitBtn;
    GOBCancelBtn: TBitBtn;
    PanelRight: TPanel;
    PanelRightBottom: TPanel;
    PanelTop: TPanel;
    PanelMiddle: TPanel;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    procedure SpeedButtonExitClick(Sender: TObject);
    procedure Popup_ExitClick(Sender: TObject);
    procedure GOBBrowseClick(Sender: TObject);
    procedure GOBInfoClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure GOBCreateClick(Sender: TObject);
    procedure GOBDeleteClick(Sender: TObject);
    procedure GOBExtractClick(Sender: TObject);
    procedure FileListBox1DragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure FileListBox1DragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure SelectAll1Click(Sender: TObject);
    procedure DeselectAll1Click(Sender: TObject);
    procedure InvertSelection1Click(Sender: TObject);
    procedure Select3DO1Click(Sender: TObject);
    procedure SelectSECBASE1Click(Sender: TObject);
    procedure SelectAll2Click(Sender: TObject);
    procedure DeSelectAll2Click(Sender: TObject);
    procedure InvertSelection2Click(Sender: TObject);
    procedure Select3DO2Click(Sender: TObject);
    procedure SelectSECBASE2Click(Sender: TObject);
    procedure SpeedButtonAboutClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PanelGOBNameDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure PanelGOBNameDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure GOBAddClick(Sender: TObject);
    procedure GOBDirListDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure GOBDirListDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure GOBRemoveClick(Sender: TObject);
    procedure BNRefreshClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SpeedButtonHelpClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure RadioGroup1Click(Sender: TObject);
    procedure DoChangeColorNormal;
    procedure DoChangeColorDark ;
    procedure DoChangeColorNone;
    procedure GOBChkBxClick(Sender: TObject);
    procedure FSTextChange(Sender: TObject);
    procedure FileListBox1Change(Sender: TObject);
    // procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure GOBOKBtnClick(Sender: TObject);
    procedure GOBCancelBtnClick(Sender: TObject);
    procedure GOBUpdateINI;
    procedure FileNameEditKeyPress(Sender: TObject; var Key: Char);

  private
    { Private declarations }
  public
    { Public declarations }
    procedure DisplayHint(Sender: TObject);
  end;

var
  GOBWindow: TGOBWindow;
   GOBText: Boolean ;
implementation

{$R *.DFM}

uses MAPPER;

procedure TGOBWindow.GOBUpdateINI;
begin
  Ini.WriteInteger('WINDOWS', 'GOB Manager    X', GOBWindow.Left);
  Ini.WriteInteger('WINDOWS', 'GOB Manager    Y', GOBWindow.Top);
  Ini.WriteInteger('WINDOWS', 'GOB Manager    W', GOBWindow.Width);
  Ini.WriteInteger('WINDOWS', 'GOB Manager    H', GOBWindow.Height);
end;

procedure TGOBWindow.DisplayHint(Sender: TObject);
begin
  SP_Text.Caption := Application.Hint;
end;

procedure TGOBWindow.FormCreate(Sender: TObject);
begin
  GOBWindow.Left   := Ini.ReadInteger('WINDOWS', 'GOB Manager    X', 0);
  GOBWindow.Top    := Ini.ReadInteger('WINDOWS', 'GOB Manager    Y', 72);
  GOBWindow.Width  := Ini.ReadInteger('WINDOWS', 'GOB Manager    W', 888);
  GOBWindow.Height := Ini.ReadInteger('WINDOWS', 'GOB Manager    H', 908);

  Application.CreateForm(TGOBDIRWindow, GOBDIRWindow);
  GOBChkBx.Checked := GOBText;
  RadioGroup1.ItemIndex := 0;
  FSTextChange(Sender);
end;

procedure TGOBWindow.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  GOBUpdateINI;
  GOBDIRWindow.Destroy;
end;

procedure TGOBWindow.SpeedButtonExitClick(Sender: TObject);
begin
  GOBWindow.Close;
end;

procedure TGOBWindow.Popup_ExitClick(Sender: TObject);
begin
  GOBWindow.Close;
end;

procedure TGOBWindow.GOBBrowseClick(Sender: TObject);
var n : Integer;
begin
 with GOBBrowseGOB do
 BEGIN
  HistoryList := GOB_History;
  if Execute then
    begin
      CurrentGOBDir := ExtractFilePath(FileName);

      CASE GOB_GetDirList(FileName , GOBDirList) OF
        0 : begin
             CurrentGOB := ExtractFileName(FileName);
             PanelGOBName.Caption    := FileName;
             PanelGOBEntries.Caption := IntTOStr(GOBDirList.Items.Count);
             PanelGOBName.Hint  := FileName + ' | Name of the currently selected GOB file';
             GOBDelete.Enabled  := TRUE;
             GOBInfo.Enabled    := TRUE;
             GOBAdd.Enabled     := TRUE;
             GOBExtract.Enabled := TRUE;
             GOBRemove.Enabled  := TRUE;
             n := GOB_HISTORY.IndexOf(LowerCase(FileName));
             if n <> -1 then GOB_History.Delete(n);
             GOB_History.Insert(0, LowerCase(FileName));
            end;
       -1 : Application.MessageBox('File does not exist', 'GOB File Manager Error', mb_Ok or mb_IconExclamation);
       -2 : Application.MessageBox('File is not a GOB file', 'GOB File Manager Error', mb_Ok or mb_IconExclamation);
      END;
    end;
 END;
end;

procedure TGOBWindow.GOBInfoClick(Sender: TObject);
begin
  GOBDIRWindow.ShowModal;
  Application.OnHint := DisplayHint;
end;

procedure TGOBWindow.GOBOKBtnClick(Sender: TObject);
begin
  GOBUpdateINI;
end;

procedure TGOBWindow.FormActivate(Sender: TObject);
begin
  Application.OnHint := DisplayHint;
end;

procedure TGOBWindow.GOBCreateClick(Sender: TObject);
begin
 with GOBCreateSaveDialog do
  if Execute then
    begin
      CurrentGOBDir := ExtractFilePath(FileName);
      GOBDirList.Items.Clear;
      GOB_CreateEmpty(FileName);
      CurrentGOB := ExtractFileName(FileName);
      PanelGOBName.Caption := FileName;
      PanelGOBEntries.Caption := '0';
      PanelGOBName.Hint := FileName + ' | Name of the currently selected GOB file';
      GOBDelete.Enabled  := TRUE;
      GOBInfo.Enabled    := TRUE;
      GOBAdd.Enabled     := TRUE;
      GOBExtract.Enabled := TRUE;
      GOBRemove.Enabled  := TRUE;
      GOB_History.Insert(0, LowerCase(FileName));
      FileListBox1.Update;
    end;
end;


procedure TGOBWindow.GOBDeleteClick(Sender: TObject);
var tmp, tmp2 : array[0..255] of char;
    n         : Integer;
begin
  strcopy(tmp, 'Delete ');
  strcat(tmp, strPcopy(tmp2, CurrentGOB));
  if Application.MessageBox(tmp, 'GOB File Manager', mb_YesNo or mb_IconQuestion) =  IDYes
   then
    begin
      SysUtils.DeleteFile(CurrentGOBDir + '\' + CurrentGOB);
      PanelGOBName.Caption := '';
      PanelGOBEntries.Caption := '';
      n := GOB_HISTORY.IndexOf(LowerCase(CurrentGOB));
      if n <> -1 then GOB_History.Delete(n);
      CurrentGOB := '';
      CurrentGOBDir := '';
      PanelGOBName.Hint := 'GOB Name | Name of the currently selected GOB file';
      GOBDelete.Enabled  := FALSE;
      GOBInfo.Enabled    := FALSE;
      GOBAdd.Enabled     := FALSE;
      GOBExtract.Enabled := FALSE;
      GOBRemove.Enabled  := FALSE;
      GOBDIRList.Clear;
      FileListBox1.Update;
    end;
end;


procedure TGOBWindow.SelectAll1Click(Sender: TObject);
var i : LongInt;
begin
  for i := 0 to FileListBox1.Items.Count - 1 do
   FileListBox1.Selected[i] := TRUE;
end;

procedure TGOBWindow.DeselectAll1Click(Sender: TObject);
var i : LongInt;
begin
  for i := 0 to FileListBox1.Items.Count - 1 do
   FileListBox1.Selected[i] := FALSE;
end;

procedure TGOBWindow.Select3DO1Click(Sender: TObject);
var i   : LongInt;
    ext : String;
begin
  if Sender = Select3DO1 then ext := '.3do';
  if Sender = SelectBM1  then ext := '.bm';
  if Sender = SelectFME1 then ext := '.fme';
  if Sender = SelectPAL1 then ext := '.pal';
  if Sender = SelectWAX1 then ext := '.wax';
  if Sender = SelectGMD1 then ext := '.gmd';
  if Sender = SelectVOC1 then ext := '.voc';
  if Sender = SelectLST1 then ext := '.lst';
  if Sender = SelectLVL1 then ext := '.lvl';
  if Sender = SelectMSG1 then ext := '.msg';
  if Sender = SelectTXT1 then ext := '.txt';
  if Sender = SelectVUE1 then ext := '.vue';

  for i := 0 to FileListBox1.Items.Count - 1 do
   if ExtractFileExt(FileListBox1.Items.Strings[i]) = ext
    then FileListBox1.Selected[i] := TRUE;
end;

procedure TGOBWindow.SelectSECBASE1Click(Sender: TObject);
var i        : LongInt;
    TheLevel : String;
begin
if Sender = SelectSECBASE1  then TheLevel := 'secbase';
if Sender = SelectTALAY1    then TheLevel := 'talay';
if Sender = SelectSEWERS1   then TheLevel := 'sewers';
if Sender = SelectTESTBASE1 then TheLevel := 'testbase';
if Sender = SelectGROMAS1   then TheLevel := 'gromas';
if Sender = SelectDTENTION1 then TheLevel := 'dtention';
if Sender = SelectRAMSHED1  then TheLevel := 'ramshed';
if Sender = SelectROBOTICS1 then TheLevel := 'robotics';
if Sender = SelectNARSHADA1 then TheLevel := 'narshada';
if Sender = SelectJABSHIP1  then TheLevel := 'jabship';
if Sender = SelectIMPCITY1  then TheLevel := 'impcity';
if Sender = SelectFUELSTAT1 then TheLevel := 'fuelstat';
if Sender = SelectEXECUTOR1 then TheLevel := 'executor';
if Sender = SelectARC1      then TheLevel := 'arc';

  for i := 0 to FileListBox1.Items.Count - 1 do
   if Copy(FileListBox1.Items.Strings[i],
           1, Length(FileListBox1.Items.Strings[i])-
              Length(ExtractFileExt(FileListBox1.Items.Strings[i])))
      = TheLevel
    then FileListBox1.Selected[i] := TRUE;
end;

procedure TGOBWindow.FileNameEditKeyPress(Sender: TObject; var Key: Char);
begin
 if Key = #13 then
  begin
    FileListBox1.ApplyFilePath(FileNameEdit.Text);
    Key := #0;
  end
end;

procedure TGOBWindow.FSTextChange(Sender: TObject);
begin
   FileNameEdit.Text := FilterComboBox1.Mask;
   FileListBox1.ApplyFilePath(FileNameEdit.Text);
end;

procedure TGOBWindow.GOBExtractClick(Sender: TObject);
begin
   GOB_ExtractFiles(DirectoryListBox1.Directory, CurrentGOBDir + '\' + CurrentGOB, GOBDirList, ProgressBar);
   FileListBox1.Update;
end;

procedure TGOBWindow.FileListBox1DragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin
  if Source = GOBDirList then
  begin
    GOB_ExtractFiles(DirectoryListBox1.Directory, CurrentGOBDir + '\' + CurrentGOB, GOBDirList, ProgressBar);
    FileListBox1.Update;
  end;
end;

procedure TGOBWindow.FileListBox1DragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
   Accept := Source = GOBDirList;
end;

procedure TGOBWindow.SelectAll2Click(Sender: TObject);
var i : LongInt;
begin
  for i := 0 to GOBDirList.Items.Count - 1 do
   GOBDirList.Selected[i] := TRUE;
end;

procedure TGOBWindow.DeSelectAll2Click(Sender: TObject);
var i : LongInt;
begin
  for i := 0 to GOBDirList.Items.Count - 1 do
   GOBDirList.Selected[i] := FALSE;
end;

procedure TGOBWindow.Select3DO2Click(Sender: TObject);
var i   : LongInt;
    ext : String;
begin
  if Sender = Select3DO2 then ext := '.3DO';
  if Sender = SelectBM2  then ext := '.BM';
  if Sender = SelectFME2 then ext := '.FME';
  if Sender = SelectPAL2 then ext := '.PAL';
  if Sender = SelectWAX2 then ext := '.WAX';
  if Sender = SelectGMD2 then ext := '.GMD';
  if Sender = SelectVOC2 then ext := '.VOC';
  if Sender = SelectLST2 then ext := '.LST';
  if Sender = SelectLVL2 then ext := '.LVL';
  if Sender = SelectMSG2 then ext := '.MSG';
  if Sender = SelectTXT2 then ext := '.TXT';
  if Sender = SelectVUE2 then ext := '.VUE';

  for i := 0 to GOBDirList.Items.Count - 1 do
   if ExtractFileExt(GOBDirList.Items.Strings[i]) = ext
    then GOBDirList.Selected[i] := TRUE;
end;

procedure TGOBWindow.SelectSECBASE2Click(Sender: TObject);
var i        : LongInt;
    TheLevel : String;
begin
if Sender = SelectSECBASE2  then TheLevel := 'SECBASE';
if Sender = SelectTALAY2    then TheLevel := 'TALAY';
if Sender = SelectSEWERS2   then TheLevel := 'SEWERS';
if Sender = SelectTESTBASE2 then TheLevel := 'TESTBASE';
if Sender = SelectGROMAS2   then TheLevel := 'GROMAS';
if Sender = SelectDTENTION2 then TheLevel := 'DTENTION';
if Sender = SelectRAMSHED2  then TheLevel := 'RAMSHED';
if Sender = SelectROBOTICS2 then TheLevel := 'ROBOTICS';
if Sender = SelectNARSHADA2 then TheLevel := 'NARSHADA';
if Sender = SelectJABSHIP2  then TheLevel := 'JABSHIP';
if Sender = SelectIMPCITY2  then TheLevel := 'IMPCITY';
if Sender = SelectFUELSTAT2 then TheLevel := 'FUELSTAT';
if Sender = SelectEXECUTOR2 then TheLevel := 'EXECUTOR';
if Sender = SelectARC2      then TheLevel := 'ARC';

 for i := 0 to GOBDirList.Items.Count - 1 do
   if Copy(GOBDirList.Items.Strings[i],
           1, Length(GOBDirList.Items.Strings[i])-Length(ExtractFileExt(GOBDirList.Items.Strings[i])))
      = TheLevel
    then GOBDirList.Selected[i] := TRUE;
end;

procedure TGOBWindow.InvertSelection1Click(Sender: TObject);
var i : LongInt;
begin
  for i := 0 to FileListBox1.Items.Count - 1 do
    FileListBox1.Selected[i] := not FileListBox1.Selected[i];
end;

procedure TGOBWindow.InvertSelection2Click(Sender: TObject);
var i : LongInt;
begin
  for i := 0 to GOBDirList.Items.Count - 1 do
    GOBDirList.Selected[i] := not GOBDirList.Selected[i];
end;

procedure TGOBWindow.SpeedButtonAboutClick(Sender: TObject);
begin
  Application.CreateForm(TAboutBox, AboutBox);
  AboutBox.ShowModal;
  AboutBox.Destroy;
end;


procedure TGOBWindow.PanelGOBNameDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := TRUE;
  if Source <> FileListBox1 then Accept := FALSE;
  if UpperCase(ExtractFileExt(FileNameEdit.Text)) <> '.GOB' then Accept := FALSE;
end;

procedure TGOBWindow.PanelGOBNameDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var FileName : TFileName;
    tmp      : array[0..255] of char;
begin
  FileName := DirectoryListBox1.Directory;
  if Length(Filename) <> 3 then FileName := FileName + '\';
  FileName := FileName + FileNameEdit.Text;
  if GOB_GetDirList(FileName , GOBDirList) = 0 then
    begin
      CurrentGOBDir :=  ExtractFilePath(FileName);
      CurrentGOB := ExtractFileName(FileName);
      PanelGOBName.Caption    := ExtractFileName(FileName);
      PanelGOBEntries.Caption := IntToStr(GOBDirList.Items.Count);
      PanelGOBName.Hint  := FileName + ' | Name of the currently selected GOB file';
      GOBDelete.Enabled  := TRUE;
      GOBInfo.Enabled    := TRUE;
      GOBAdd.Enabled     := TRUE;
      GOBExtract.Enabled := TRUE;
      GOBRemove.Enabled  := TRUE;
    end
  else
   begin
    strPcopy(tmp, FileName);
    Application.MessageBox(tmp, 'GOB File Manager cannot open GOB', mb_Ok);
   end;
end;

procedure TGOBWindow.GOBAddClick(Sender: TObject);
begin
  GOB_AddFiles(DirectoryListBox1.Directory, CurrentGOBDir + '\' + CurrentGOB, FileListBox1, ProgressBar);
  GOB_GetDirList(CurrentGOBDir + '\' + CurrentGOB , GOBDirList);
  PanelGOBEntries.Caption := IntToStr(GOBDirList.Items.Count);
end;

procedure TGOBWindow.GOBDirListDragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin
  if Source = FileListBox1 then
  begin
    GOB_AddFiles(DirectoryListBox1.Directory, CurrentGOBDir + '\' + CurrentGOB, FileListBox1, ProgressBar);
    GOB_GetDirList(CurrentGOBDir + '\' + CurrentGOB , GOBDirList);
    PanelGOBEntries.Caption := IntToStr(GOBDirList.Items.Count);
  end;
end;

procedure TGOBWindow.GOBDirListDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := (Source = FileListBox1) and (CurrentGOB <> '');
end;

procedure TGOBWindow.GOBRemoveClick(Sender: TObject);
begin
  GOB_RemoveFiles(CurrentGOBDir + '\' + CurrentGOB, GOBDirList, ProgressBar);
  GOB_GetDirList(CurrentGOBDir + '\' + CurrentGOB , GOBDirList);
  PanelGOBEntries.Caption := IntToStr(GOBDirList.Items.Count);
end;

procedure TGOBWindow.BNRefreshClick(Sender: TObject);
begin
  FileListBox1.Update;
end;

procedure TGOBWindow.SpeedButtonHelpClick(Sender: TObject);
begin
 MapWindow.HelpTutorialClick(NIL);
end;


procedure TGOBWindow.FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
var Action : TCloseAction;
begin
  Action := cafree;
  if Key = VK_DELETE then
   begin
    GOB_RemoveFiles(CurrentGOBDir + '\' + CurrentGOB, GOBDirList, ProgressBar);
    GOB_GetDirList(CurrentGOBDir + '\' + CurrentGOB , GOBDirList);
    PanelGOBEntries.Caption := IntToStr(GOBDirList.Items.Count);
   end;
  if (Key = VK_ESCAPE) and GOBDIRWindow.Visible then
  begin
    Key := Word(#0);
    ModalResult := mrCancel;
    GOBWindow.FormClose(Sender, Action);
  end;
end;

procedure TGOBWindow.RadioGroup1Click(Sender: TObject);
 begin
  If RadioGroup1.ItemIndex=-1 then RadioGroup1.ItemIndex := 0 ;
  If RadioGroup1.ItemIndex=0 then
    begin
     DoChangeColorNone ;
    end;
  If RadioGroup1.ItemIndex=1 Then
    begin
     DoChangeColorNormal;
    end;
  If RadioGroup1.ItemIndex=2 Then
    begin
     DoChangeColorDark;
    end;
 end;


procedure TGOBWindow.DoChangeColorNone ;
  begin
FileNameEdit.Color := clBtnFace;
FileNameEdit.Font.Color := clBlack ;
DirectoryListBox1.Color := clBtnFace ;
DirectoryListBox1.Font.Color := clBlack ;
FileListBox1.Color := clBtnFace ;
FileListBox1.Font.Color := clBlack ;
DriveComboBox1.Color := clBtnFace ;
DriveComboBox1.Font.Color := clBlack ;
PanelGOBName.Color := clBtnFace;
PanelGOBName.Font.Color := clBlack ;
GOBDirList.Color := clBtnFace ;
GOBDirList.Font.Color := clBlack ;
PanelGOBEntries.Color := clBtnFace ;
PanelGOBEntries.Font.Color := clBlack ;
SP_Text.Color := clBtnFace ;
SP_Text.Font.Color :=clBlack ;
ProgressBar.BackColor := clBtnFace ;
ProgressBar.Font.Color := clBlack ;
  GOBHintListBox.Color := clBtnFace ;
   GOBHintListBox.Font.Color := clBlack ;
end;

procedure TGOBWindow.DoChangeColorNormal ;
  begin
FileNameEdit.Color := clSilver;
FileNameEdit.Font.Color := clBlack ;
DirectoryListBox1.Color := clSilver ;
DirectoryListBox1.Font.Color := clBlack ;
FileListBox1.Color := clSilver ;
FileListBox1.Font.Color := clBlack ;
DriveComboBox1.Color := clSilver ;
DriveComboBox1.Font.Color := clBlack ;
PanelGOBName.Color := clSilver;
PanelGOBName.Font.Color := clBlack ;
GOBDirList.Color := clSilver ;
GOBDirList.Font.Color := clBlack ;
PanelGOBEntries.Color := clSilver ;
PanelGOBEntries.Font.Color := clBlack ;
SP_Text.Color := clSilver ;
SP_Text.Font.Color :=clBlack ;
ProgressBar.BackColor := clSilver ;
ProgressBar.Font.Color := clBlack ;
  GOBHintListBox.Color := clSilver ;
   GOBHintListBox.Font.Color := clBlack ;
end;

  procedure TGOBWindow.DoChangeColorDark ;
  begin
 FileNameEdit.Color :=clBlack ;
FileNameEdit.Font.Color :=clWhite ;
DirectoryListBox1.Color := clBlack ;
DirectoryListBox1.Font.Color := clWhite ;
FileListBox1.Color := clBlack ;
FileListBox1.Font.Color := clWhite ;
DriveComboBox1.Color := clBlack ;
DriveComboBox1.Font.Color := clWhite ;
PanelGOBName.Color := clBlack ;
PanelGOBName.Font.Color := clWhite ;
GOBDirList.Color := clBlack ;
GOBDirList.Font.Color := clWhite ;
PanelGOBEntries.Color := clBlack ;
PanelGOBEntries.Font.Color := clWhite ;
SP_Text.Color :=clBlack ;
SP_Text.Font.Color :=clWhite ;
ProgressBar.BackColor := clBlack ;
ProgressBar.Font.Color := clWhite ;
GOBHintListBox.Color := clGray ;
   GOBHintListBox.Font.Color := clWhite ;


  end;


procedure TGOBWindow.GOBCancelBtnClick(Sender: TObject);
begin
  GOBUpdateINI;
end;

procedure TGOBWindow.GOBChkBxClick(Sender: TObject);
begin

if GOBChkBx.Checked then
    begin
   GOBHintListBox.Visible := False;
   GOBTEXT := TRUE;
  end
  else
    begin
   GOBHintListBox.Visible := True;
   GOBTEXT := False;
 end;
end;

procedure TGOBWindow.FileListBox1Change(Sender: TObject);
var i : Integer;
    n : Integer;
    FileName : String;
    InitialDir : String;
begin
   for i := 0 to FileListBox1.Items.Count - 1 do
    if FileListBox1.Selected[i] = True then
      if UpperCase(ExtractFileExt(FileListBox1.Items[i])) = '.GOB' then
       begin
        CurrentGOBDir := DirectoryListBox1.Directory;
        FileName := FileListBox1.Items[i];
        CurrentGOB := ExtractFileName(FileName);
        GOB_GetDirList(CurrentGOBDir + '\' + FileName , GOBDirList);
        PanelGOBName.Caption    := CurrentGOBDir + '\' + CurrentGOB;
        PanelGOBEntries.Caption := IntTOStr(GOBDirList.Items.Count);
        PanelGOBName.Hint  := FileName + ' | Name of the currently selected GOB file';
        GOBDelete.Enabled  := TRUE;
        GOBInfo.Enabled    := TRUE;
        GOBAdd.Enabled     := TRUE;
        GOBExtract.Enabled := TRUE;
        GOBRemove.Enabled  := TRUE;
        n := GOB_HISTORY.IndexOf(LowerCase(FileName));
        if n <> -1 then GOB_History.Delete(n);
        GOB_History.Insert(0, LowerCase(FileName));
       end;
end;


end.
