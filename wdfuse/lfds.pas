unit Lfds;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Buttons, ExtCtrls, Menus, StdCtrls, IniFiles,
  FileCtrl, Gauges, M_About, L_Util, Lfddir, M_Global, ClipBrd;

type
  TLFDWindow = class(TForm)
    SpeedBar: TPanel;
    SP_Main: TPanel;
    SP_Progress: TPanel;
    SP_Text: TPanel;
    LFDDirList: TListBox;
    DirectoryListBox1: TDirectoryListBox;
    DriveComboBox1: TDriveComboBox;
    FilterComboBox1: TFilterComboBox;
    FileNameEdit: TEdit;
    ProgressBar: TGauge;
    LFDBrowseLFD: TOpenDialog;
    DirLabel: TLabel;
    LFDAdd: TBitBtn;
    LFDRemove: TBitBtn;
    LFDExtract: TBitBtn;
    LFDCreateSaveDialog: TSaveDialog;
    FSPopupMenu: TPopupMenu;
    SelectAll1: TMenuItem;
    DeselectAll1: TMenuItem;
    N2: TMenuItem;
    LFDPopupMenu: TPopupMenu;
    SelectAll2: TMenuItem;
    DeSelectAll2: TMenuItem;
    MenuItem3: TMenuItem;
    InvertSelection1: TMenuItem;
    InvertSelection2: TMenuItem;
    BNRefresh: TBitBtn;
    SpeedButtonHelp: TSpeedButton;
    SelectANM1: TMenuItem;
    SelectDLT1: TMenuItem;
    SelectFLM1: TMenuItem;
    SelectFNT1: TMenuItem;
    SelectGMD1: TMenuItem;
    SelectPLT1: TMenuItem;
    SelectTXT1: TMenuItem;
    SelectVOC1: TMenuItem;
    SelectANIM1: TMenuItem;
    SelectDELT1: TMenuItem;
    SelectFILM1: TMenuItem;
    SelectFONT1: TMenuItem;
    SelectGMID1: TMenuItem;
    SelectPLTT1: TMenuItem;
    SelectTEXT1: TMenuItem;
    SelectVOIC1: TMenuItem;
    FileListBox1: TFileListBox;
    PanelLFDName: TPanel;
    PanelLFDEntries: TPanel;
    LFDCreate: TBitBtn;
    LFDDelete: TBitBtn;
    LFDInfo: TBitBtn;
    LFDHintListBox: TListBox;
    Label1: TLabel;
    RadioGroup1: TRadioGroup;
    LFDChkBx: TCheckBox;
    Open: TBitBtn;
    Bevel1: TBevel;
    LabelTitle: TLabel;
    LFDCancelBtn: TBitBtn;
    LFDOKBtn: TBitBtn;
    procedure SpeedButtonExitClick(Sender: TObject);
    procedure Popup_ExitClick(Sender: TObject);
    procedure LFDBrowseClick(Sender: TObject);
    procedure LFDInfoClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure LFDCreateClick(Sender: TObject);
    procedure LFDDeleteClick(Sender: TObject);
    procedure SelectAll1Click(Sender: TObject);
    procedure DeselectAll1Click(Sender: TObject);
    procedure FileNameEditKeyPress(Sender: TObject; var Key: Char);
    procedure LFDExtractClick(Sender: TObject);
    procedure FileListBox1DragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure FileListBox1DragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure SelectAll2Click(Sender: TObject);
    procedure DeSelectAll2Click(Sender: TObject);
    procedure InvertSelection1Click(Sender: TObject);
    procedure InvertSelection2Click(Sender: TObject);
    procedure SpeedButtonAboutClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PanelLFDNameDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure PanelLFDNameDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure LFDAddClick(Sender: TObject);
    procedure LFDDirListDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure LFDDirListDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure LFDRemoveClick(Sender: TObject);
    procedure BNRefreshClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SpeedButtonHelpClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SelectANM1Click(Sender: TObject);
    procedure SelectANIM1Click(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure DoChangeColorNormal ;
    procedure DoChangeColorDark ;
    procedure DoChangeColorNone;
    procedure LFDChkBxClick(Sender: TObject);
    procedure FSTextChange(Sender: TObject);
    procedure FileListBox1Change(Sender: TObject);
    procedure PanelLFDNameClick(Sender: TObject);
    procedure LFDCancelBtnClick(Sender: TObject);
    procedure LFDOKBtnClick(Sender: TObject);
    procedure LFDUpdateINI;


  private
    { Private declarations }
  public
    { Public declarations }


    procedure DisplayHint(Sender: TObject);
  end;

var
  LFDWindow: TLFDWindow;
  LFDText : Boolean;
implementation

{$R *.DFM}

uses MAPPER;

procedure TLFDWindow.LFDUpdateINI;
begin
  Ini.WriteInteger('WINDOWS', 'LFD Manager    X', LFDWindow.Left);
  Ini.WriteInteger('WINDOWS', 'LFD Manager    Y', LFDWindow.Top);
  Ini.WriteInteger('WINDOWS', 'LFD Manager    W', LFDWindow.Width);
  Ini.WriteInteger('WINDOWS', 'LFD Manager    H', LFDWindow.Height);
end;

procedure TLFDWindow.DisplayHint(Sender: TObject);
begin
  SP_Text.Caption := Application.Hint;
end;

procedure TLFDWindow.FormCreate(Sender: TObject);
begin
  LFDWindow.Left   := Ini.ReadInteger('WINDOWS', 'LFD Manager    X', 0);
  LFDWindow.Top    := Ini.ReadInteger('WINDOWS', 'LFD Manager    Y', 72);
  LFDWindow.Width  := Ini.ReadInteger('WINDOWS', 'LFD Manager    W', 983);
  LFDWindow.Height := Ini.ReadInteger('WINDOWS', 'LFD Manager    H', 932);
  Application.CreateForm(TLFDDIRWindow, LFDDIRWindow);
  LFDChkBx.Checked := LFDText;
  RadioGroup1.ItemIndex := 0;
  FSTextChange(Sender);
end;

procedure TLFDWindow.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  LFDUpdateINI;
  LFDDIRWindow.Destroy;
end;

procedure TLFDWindow.SpeedButtonExitClick(Sender: TObject);
begin
  LFDUpdateINI;
  LFDWindow.Close;
end;

procedure TLFDWindow.Popup_ExitClick(Sender: TObject);
begin
  LFDUpdateINI;
  LFDWindow.Close;
end;

procedure TLFDWindow.LFDBrowseClick(Sender: TObject);
var n : Integer;
begin
 with LFDBrowseLFD do
 BEGIN
  HistoryList := LFD_History;
  if Execute then
    begin
      InitialDir := ExtractFilePath(FileName);

      CASE LFD_GetDirList(FileName , LFDDirList) OF
        0 : begin
             CurrentLFDir := ExtractFilePath(FileName);
             CurrentLFD := ExtractFileName(FileName);
             PanelLFDName.Caption    := FileName;
             PanelLFDEntries.Caption := IntTOStr(LFDDirList.Items.Count);
             PanelLFDName.Hint  := FileName + ' | Name of the currently selected LFD file';
             LFDDelete.Enabled  := TRUE;
             LFDInfo.Enabled    := TRUE;
             LFDAdd.Enabled     := TRUE;
             LFDExtract.Enabled := TRUE;
             LFDRemove.Enabled  := TRUE;
             n := LFD_HISTORY.IndexOf(LowerCase(FileName));
             if n <> -1 then LFD_History.Delete(n);
             LFD_History.Insert(0, LowerCase(FileName));
            end;
       -1 : Application.MessageBox('File does not exist', 'LFD File Manager Error', mb_Ok or mb_IconExclamation);
       -2 : Application.MessageBox('File is not a LFD file', 'LFD File Manager Error', mb_Ok or mb_IconExclamation);
      END;
    end;
 END;
end;

procedure TLFDWindow.LFDInfoClick(Sender: TObject);
begin
  LFDDIRWindow.ShowModal;
  Application.OnHint := DisplayHint;
end;

procedure TLFDWindow.LFDOKBtnClick(Sender: TObject);
begin
  LFDUpdateINI;
end;

procedure TLFDWindow.FormActivate(Sender: TObject);
begin
  Application.OnHint := DisplayHint;
end;

procedure TLFDWindow.LFDCreateClick(Sender: TObject);
begin
 with LFDCreateSaveDialog do
  if Execute then
    begin
      CurrentLFDir := ExtractFilePath(FileName);
      LFDDirList.Items.Clear;
      LFD_CreateEmpty(FileName);
      CurrentLFD := ExtractFileName(FileName);
      PanelLFDName.Caption := FileName;
      PanelLFDEntries.Caption := '0';
      PanelLFDName.Hint := FileName + ' | Name of the currently selected LFD file';
      LFDDelete.Enabled  := TRUE;
      LFDInfo.Enabled    := TRUE;
      LFDAdd.Enabled     := TRUE;
      LFDExtract.Enabled := TRUE;
      LFDRemove.Enabled  := TRUE;
      LFD_History.Insert(0, LowerCase(FileName));
      FileListBox1.Update;
    end;
end;

procedure TLFDWindow.LFDDeleteClick(Sender: TObject);
var tmp, tmp2 : array[0..255] of char;
    n         : Integer;
begin
  strcopy(tmp, 'Delete ');
  strcat(tmp, strPcopy(tmp2, CurrentLFD));
  if Application.MessageBox(tmp, 'LFD File Manager', mb_YesNo or mb_IconQuestion) =  IDYes
   then
    begin
      SysUtils.DeleteFile(CurrentLFDir + '\' + CurrentLFD);
      PanelLFDName.Caption := '';
      PanelLFDEntries.Caption := '';
      n := LFD_HISTORY.IndexOf(LowerCase(CurrentLFD));
      if n <> -1 then LFD_History.Delete(n);
      CurrentLFD := '';
      CurrentLFDir := '';
      PanelLFDName.Hint := 'LFD Name | Name of the currently selected LFD file';
      LFDDelete.Enabled  := FALSE;
      LFDInfo.Enabled    := FALSE;
      LFDAdd.Enabled     := FALSE;
      LFDExtract.Enabled := FALSE;
      LFDRemove.Enabled  := FALSE;
      LFDDIRList.Clear;
      FileListBox1.Update;
    end;
end;

procedure TLFDWindow.SelectAll1Click(Sender: TObject);
var i : LongInt;
begin
  for i := 0 to FileListBox1.Items.Count - 1 do
   FileListBox1.Selected[i] := TRUE;
end;

procedure TLFDWindow.DeselectAll1Click(Sender: TObject);
var i : LongInt;
begin
  for i := 0 to FileListBox1.Items.Count - 1 do
   FileListBox1.Selected[i] := FALSE;
end;

procedure TLFDWindow.FileNameEditKeyPress(Sender: TObject; var Key: Char);
begin
 if Key = #13 then
  begin
    FileListBox1.ApplyFilePath(FileNameEdit.Text);
    Key := #0;
  end;
end;

procedure TLFDWindow.LFDExtractClick(Sender: TObject);
begin
   LFD_ExtractFiles(DirectoryListBox1.Directory, CurrentLFDir + '\' + CurrentLFD, LFDDirList, ProgressBar);
   FileListBox1.Update;
end;

procedure TLFDWindow.FileListBox1DragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin
  if Source = LFDDirList then
  begin
    LFDExtractClick(Sender);
  end;
end;

procedure TLFDWindow.FileListBox1DragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
   Accept := Source = LFDDirList;
end;

procedure TLFDWindow.SelectAll2Click(Sender: TObject);
var i : LongInt;
begin
  for i := 0 to LFDDirList.Items.Count - 1 do
   LFDDirList.Selected[i] := TRUE;
end;

procedure TLFDWindow.DeSelectAll2Click(Sender: TObject);
var i : LongInt;
begin
  for i := 0 to LFDDirList.Items.Count - 1 do
   LFDDirList.Selected[i] := FALSE;
end;

procedure TLFDWindow.InvertSelection1Click(Sender: TObject);
var i : LongInt;
begin
  for i := 0 to FileListBox1.Items.Count - 1 do
    FileListBox1.Selected[i] := not FileListBox1.Selected[i];
end;

procedure TLFDWindow.InvertSelection2Click(Sender: TObject);
var i : LongInt;
begin
  for i := 0 to LFDDirList.Items.Count - 1 do
    LFDDirList.Selected[i] := not LFDDirList.Selected[i];
end;



procedure TLFDWindow.SpeedButtonAboutClick(Sender: TObject);
begin
  Application.CreateForm(TAboutBox, AboutBox);
  AboutBox.ShowModal;
  AboutBox.Destroy;
end;


procedure TLFDWindow.PanelLFDNameDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := TRUE;
  if Source <> FileListBox1 then Accept := FALSE;
  if UpperCase(ExtractFileExt(FileNameEdit.Text)) <> '.LFD' then Accept := FALSE;
end;

procedure TLFDWindow.PanelLFDNameClick(Sender: TObject);
begin
 if PanelLFDName.Caption <> '' then
  begin
   Clipboard.AsText := PanelLFDName.Caption;
   showmessage('Copied ' + PanelLFDName.Caption + ' to clipboard !');
  end;
end;

procedure TLFDWindow.PanelLFDNameDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var FileName : TFileName;
    tmp      : array[0..255] of char;
begin
  FileName := DirectoryListBox1.Directory;
  if Length(Filename) <> 3 then FileName := FileName + '\';
  FileName := FileName + FileNameEdit.Text;
  if LFD_GetDirList(FileName , LFDDirList) = 0 then
    begin
      CurrentLFD := FileName;
      PanelLFDName.Caption    := ExtractFileName(FileName);
      PanelLFDEntries.Caption := IntToStr(LFDDirList.Items.Count);
      PanelLFDName.Hint  := FileName + ' | Name of the currently selected LFD file';
      LFDDelete.Enabled  := TRUE;
      LFDInfo.Enabled    := TRUE;
      LFDAdd.Enabled     := TRUE;
      LFDExtract.Enabled := TRUE;
      LFDRemove.Enabled  := TRUE;
    end
  else
   begin
    strPcopy(tmp, FileName);
    Application.MessageBox(tmp, 'LFD File Manager cannot open LFD', mb_Ok);
   end;
end;


procedure TLFDWindow.LFDAddClick(Sender: TObject);
begin
    LFD_AddFiles(DirectoryListBox1.Directory, CurrentLFDir + '\' + CurrentLFD, FileListBox1, ProgressBar);
    LFD_GetDirList(CurrentLFDir + '\' + CurrentLFD , LFDDirList);
    PanelLFDEntries.Caption := IntToStr(LFDDirList.Items.Count);
end;


procedure TLFDWindow.LFDDirListDragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin
  if Source = FileListBox1 then
  begin
    LFDAddClick(Sender);
  end;
end;

procedure TLFDWindow.LFDDirListDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := (Source = FileListBox1) and (CurrentLFD <> '');
end;

procedure TLFDWindow.LFDRemoveClick(Sender: TObject);
begin
  LFD_RemoveFiles(CurrentLFDir + '\' + CurrentLFD, LFDDirList, ProgressBar);
  LFD_GetDirList(CurrentLFDir + '\' + CurrentLFD , LFDDirList);
  PanelLFDEntries.Caption := IntToStr(LFDDirList.Items.Count);
end;


procedure TLFDWindow.BNRefreshClick(Sender: TObject);
begin
  FileListBox1.Update;
end;


procedure TLFDWindow.FSTextChange(Sender: TObject);
begin
   FileNameEdit.Text := FilterComboBox1.Mask;
   FileListBox1.ApplyFilePath(FileNameEdit.Text);
end;


procedure TLFDWindow.SpeedButtonHelpClick(Sender: TObject);
begin
 MapWindow.HelpTutorialClick(NIL);
end;

procedure TLFDWindow.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if (Shift = []) and (Key = VK_F1) then
  SpeedButtonHelpClick(NIL);
    if Key = VK_DELETE then
     begin
      LFDRemoveClick(Sender);
     end;
end;

procedure TLFDWindow.SelectANM1Click(Sender: TObject);
var i   : LongInt;
    ext : String;
begin
  ext := '';
  if Sender = SelectANM1 then ext := '.anm';
  if Sender = SelectDLT1 then ext := '.dlt';
  if Sender = SelectFLM1 then ext := '.flm';
  if Sender = SelectFNT1 then ext := '.fon';
  if Sender = SelectGMD1 then ext := '.gmd';
  if Sender = SelectPLT1 then ext := '.plt';
  if Sender = SelectTXT1 then ext := '.txt';
  if Sender = SelectVOC1 then ext := '.voc';

  for i := 0 to FileListBox1.Items.Count - 1 do
   if ExtractFileExt(FileListBox1.Items.Strings[i]) = ext
    then FileListBox1.Selected[i] := TRUE;
end;

procedure TLFDWindow.SelectANIM1Click(Sender: TObject);
var i   : LongInt;
    ext : String;
begin
  ext := '';
  if Sender = SelectANIM1 then ext := 'ANIM';
  if Sender = SelectDELT1 then ext := 'DELT';
  if Sender = SelectFILM1 then ext := 'FILM';
  if Sender = SelectFONT1 then ext := 'FONT';
  if Sender = SelectGMID1 then ext := 'GMID';
  if Sender = SelectPLTT1 then ext := 'PLTT';
  if Sender = SelectTEXT1 then ext := 'TEXT';
  if Sender = SelectVOIC1 then ext := 'VOIC';

  for i := 0 to LFDDirList.Items.Count - 1 do
   if Copy(LFDDirList.Items.Strings[i],1,4) = ext
    then LFDDirList.Selected[i] := TRUE;
end;

procedure TLFDWindow.RadioGroup1Click(Sender: TObject);

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



procedure TLFDWindow.DoChangeColorNone ;
  begin
FileNameEdit.Color := clBtnFace;
FileNameEdit.Font.Color := clBlack ;
DirectoryListBox1.Color := clBtnFace ;
DirectoryListBox1.Font.Color := clBlack ;
FileListBox1.Color := clBtnFace ;
FileListBox1.Font.Color := clBlack ;
DriveComboBox1.Color := clBtnFace ;
DriveComboBox1.Font.Color := clBlack ;
PanelLFDName.Color := clBtnFace;
PanelLFDName.Font.Color := clBlack ;
LFDDirList.Color := clBtnFace ;
LFDDirList.Font.Color := clBlack ;
PanelLFDEntries.Color := clBtnFace ;
PanelLFDEntries.Font.Color := clBlack ;
SP_Text.Color := clBtnFace ;
SP_Text.Font.Color :=clBlack ;
ProgressBar.BackColor := clBtnFace ;
ProgressBar.Font.Color := clBlack ;
LFDHintListBox.Color := clBtnFace ;
LFDHintListBox.Font.Color := clBlack ;
end;

procedure TLFDWindow.DoChangeColorNormal ;
  begin
FileNameEdit.Color := clSilver;
FileNameEdit.Font.Color := clBlack ;
DirectoryListBox1.Color := clSilver ;
DirectoryListBox1.Font.Color := clBlack ;
FileListBox1.Color := clSilver ;
FileListBox1.Font.Color := clBlack ;
DriveComboBox1.Color := clSilver ;
DriveComboBox1.Font.Color := clBlack ;
PanelLFDName.Color := clSilver;
PanelLFDName.Font.Color := clBlack ;
LFDDirList.Color := clSilver ;
LFDDirList.Font.Color := clBlack ;
PanelLFDEntries.Color := clSilver ;
PanelLFDEntries.Font.Color := clBlack ;
SP_Text.Color := clSilver ;
SP_Text.Font.Color :=clBlack ;
ProgressBar.BackColor := clSilver ;
ProgressBar.Font.Color := clBlack ;
  LFDHintListBox.Color := clSilver ;
   LFDHintListBox.Font.Color := clBlack ;
end;

  procedure TLFDWindow.DoChangeColorDark ;
  begin
 FileNameEdit.Color :=clBlack ;
FileNameEdit.Font.Color :=clWhite ;
DirectoryListBox1.Color := clBlack ;
DirectoryListBox1.Font.Color := clWhite ;
FileListBox1.Color := clBlack ;
FileListBox1.Font.Color := clWhite ;
DriveComboBox1.Color := clBlack ;
DriveComboBox1.Font.Color := clWhite ;
PanelLFDName.Color := clBlack ;
PanelLFDName.Font.Color := clWhite ;
LFDDirList.Color := clBlack ;
LFDDirList.Font.Color := clWhite ;
PanelLFDEntries.Color := clBlack ;
PanelLFDEntries.Font.Color := clWhite ;
SP_Text.Color :=clBlack ;
SP_Text.Font.Color :=clWhite ;
ProgressBar.BackColor := clBlack ;
ProgressBar.Font.Color := clWhite ;
LFDHintListBox.Color := clGray ;
   LFDHintListBox.Font.Color := clWhite ;


  end;


procedure TLFDWindow.LFDCancelBtnClick(Sender: TObject);
begin
  LFDUpdateINI;
end;

procedure TLFDWindow.LFDChkBxClick(Sender: TObject);
begin
 if LFDChkBx.Checked then
    begin
       LFDHintListBox.Visible := False;
       LFDTEXT := TRUE;
    end
 else
   begin
      LFDHintListBox.Visible := True;
      LFDTEXT := False;
   end;
end;



procedure TLFDWindow.FileListBox1Change(Sender: TObject);
var i : Integer;
    n : Integer;
    FileName : String;
begin
   for i := 0 to FileListBox1.Items.Count - 1 do
    if FileListBox1.Selected[i] = True then
     if UpperCase(ExtractFileExt(FileListBox1.Items[i])) = '.LFD' then
       begin
        CurrentLFDir := DirectoryListBox1.Directory;
        FileName := FileListBox1.Items[i];
        CurrentLFD := FileName;
        LFD_GetDirList(CurrentLFDir + '\' + FileName , LFDDirList);
        PanelLFDName.Caption    := CurrentLFDir + '\' + FileName;
        PanelLFDEntries.Caption := IntTOStr(LFDDirList.Items.Count);
        PanelLFDName.Hint  := FileName + ' | Name of the currently selected LFD file';
        LFDDelete.Enabled  := TRUE;
        LFDInfo.Enabled    := TRUE;
        LFDAdd.Enabled     := TRUE;
        LFDExtract.Enabled := TRUE;
        LFDRemove.Enabled  := TRUE;
        n := LFD_HISTORY.IndexOf(LowerCase(FileName));
        if n <> -1 then LFD_History.Delete(n);
        LFD_History.Insert(0, LowerCase(FileName));
       end;
end;
end.
