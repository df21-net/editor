unit M_newwdp;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, FileCtrl, ExtCtrls, Dialogs, SysUtils, IniFiles,
  M_Global, _files, _strings, M_Util, G_Util, M_Wads, W_Util;

type
  TNewProjectDialog = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    RGProjectSource: TRadioGroup;
    CBLevelChoice: TComboBox;
    EDProjectName: TEdit;
    Label1: TLabel;
    OpenUserGOB: TOpenDialog;
    HiddenListBox: TListBox;
    openUserTxt: TOpenDialog;
    OpenUserLEV: TOpenDialog;
    BNHelp: TBitBtn;
    OpenWAD: TOpenDialog;
    CBNewLevelChoice: TComboBox;
    procedure RGProjectSourceClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BNHelpClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  NewProjectDialog: TNewProjectDialog;


implementation

{$R *.DFM}

procedure TNewProjectDialog.RGProjectSourceClick(Sender: TObject);

begin
  if RGProjectSource.ItemIndex = 0 then
     begin
     CBLevelChoice.Enabled := True;
     CBNewLevelChoice.Enabled := False ;
   end
  else
      begin
      CBLevelChoice.Enabled := False;
      CBNewLevelChoice.Enabled := True ;

end;
     end;

procedure TNewProjectDialog.OKBtnClick(Sender: TObject);
var pjf    : TIniFile;
    lname  : String;
    i      : Integer;
    openok : Boolean;


begin
 if EDProjectName.Text = '' then
  begin
   Application.MessageBox('Project Name MUST be filled', 'WDFUSE Mapper - NEW Project', mb_Ok or mb_IconExclamation);
   exit;
  end;

 if FileExists(WDFUSEdir+ '\' + EDProjectName.Text + '.wdp') or
    DirectoryExists(WDFUSEdir+ '\' + EDProjectName.Text) then
  begin
   Application.MessageBox('Project ALREADY EXISTS', 'WDFUSE Mapper - NEW Project', mb_Ok or mb_IconExclamation);
   exit;
  end;

 openok := FALSE;

 {create project directory, backups subdirectory}
 ChDir(WDFUSEdir);
 MkDir(EDProjectName.Text);
 ChDir(EDProjectName.Text);
 MkDir('BACKUPS');
 ChDir(WDFUSEdir);

 {create project file}
 PROJECTFile := WDFUSEdir+ '\' + EDProjectName.Text + '.wdp';
 pjf := TIniFile.Create(PROJECTFile);
 try
  pjf.WriteString('WDFUSE Project', 'CREATEDAT', DateTimeToStr(Now));
  pjf.WriteString('WDFUSE Project', 'LASTMODIF', ' ');
  pjf.WriteString('WDFUSE Project', 'BACKUPNUM', ' ');
  pjf.WriteString('WDFUSE Project', 'LEVELNAME', ' ');
  pjf.WriteString('WDFUSE Project', 'DIRECTORY', WDFUSEdir+ '\' + EDProjectName.Text);
 finally
  pjf.Free;
 end;

 {then extract accordingly}
  CASE RGProjectSource.ItemIndex of
  0 : begin
       lname := RTrim(Copy(CBLevelChoice.Items[CBLevelChoice.ItemIndex],1,8));
       HiddenListBox.Clear;
       HiddenListBox.Items.Add(lname + '.LEV');
       HiddenListBox.Items.Add(lname + '.O');
       HiddenListBox.Items.Add(lname + '.INF');
       HiddenListBox.Items.Add(lname + '.GOL');
       HiddenListBox.Items.Add(lname + '.PAL');
       {special case because NARSHADA.CMP isn't in dark.gob !}
       if lname <> 'NARSHADA' then
        HiddenListBox.Items.Add(lname + '.CMP');
       HiddenListBox.Items.Add('JEDI.LVL');
       HiddenListBox.Items.Add('TEXT.MSG');
       for i := 0 to HiddenListBox.Items.Count - 1 do HiddenListBox.Selected[i] := TRUE;
       GOB_ExtractFiles(WDFUSEdir+ '\' + EDProjectName.Text,
                        DARKgob, HiddenListBox, NIL);
       {now, get NARSHADA.CMP which is in textures.gob for some reason}
       if lname = 'NARSHADA' then
        begin
         HiddenListBox.Clear;
         HiddenListBox.Items.Add(lname + '.CMP');
         HiddenListBox.Selected[0] := TRUE;
         GOB_ExtractFiles(WDFUSEdir+ '\' + EDProjectName.Text,
                          TEXTURESgob, HiddenListBox, NIL);
        end;
       CopyFile(WDFUSEdir + '\WDFDATA\GOB_AUTH.TXT', WDFUSEdir+ '\' + EDProjectName.Text + '.TXT');
       pjf := TIniFile.Create(PROJECTFile);
       try
        pjf.WriteString('WDFUSE Project', 'LEVELNAME', lname);
       finally
        pjf.Free;
       end;
       openok := TRUE;
      end;
  1 : begin
      
       lname := RTrim(Copy(CBNewLevelChoice.Items[CBNewLevelChoice.ItemIndex],1,8));
       HiddenListBox.Clear;
       HiddenListBox.Items.Add(lname + '.LEV');
       HiddenListBox.Items.Add(lname + '.O');
       HiddenListBox.Items.Add(lname + '.INF');
       HiddenListBox.Items.Add(lname + '.GOL');
       HiddenListBox.Items.Add(lname + '.PAL');
       HiddenListBox.Items.Add(lname + '.CMP');
       HiddenListBox.Items.Add('JEDI.LVL');
       HiddenListBox.Items.Add('TEXT.MSG');
       for i := 0 to HiddenListBox.Items.Count - 1 do HiddenListBox.Selected[i] := TRUE;
       GOB_ExtractFiles(WDFUSEdir+ '\' + EDProjectName.Text,
                 WDFUSEdir + '\WDFDATA\WDFUSE.gob', HiddenListBox, NIL);
       CopyFile(WDFUSEdir + '\WDFDATA\GOB_AUTH.TXT', WDFUSEdir+ '\' + EDProjectName.Text + '.TXT');
       pjf := TIniFile.Create(PROJECTFile);
       try
        pjf.WriteString('WDFUSE Project', 'LEVELNAME', lname);
       finally
        pjf.Free;
       end;
       openok := TRUE;
      end;
       {CopyFile(WDFUSEdir + '\WDFDATA\SECBASE.LEV',  WDFUSEdir+ '\' + EDProjectName.Text + '\SECBASE.LEV');
       CopyFile(WDFUSEdir + '\WDFDATA\SECBASE.O',    WDFUSEdir+ '\' + EDProjectName.Text + '\SECBASE.O');
       CopyFile(WDFUSEdir + '\WDFDATA\SECBASE.INF',  WDFUSEdir+ '\' + EDProjectName.Text + '\SECBASE.INF');
       CopyFile(WDFUSEdir + '\WDFDATA\SECBASE.GOL',  WDFUSEdir+ '\' + EDProjectName.Text + '\SECBASE.GOL');
       CopyFile(WDFUSEdir + '\WDFDATA\SECBASE.PAL',  WDFUSEdir+ '\' + EDProjectName.Text + '\SECBASE.PAL');
       CopyFile(WDFUSEdir + '\WDFDATA\SECBASE.CMP',  WDFUSEdir+ '\' + EDProjectName.Text + '\SECBASE.CMP');
       HiddenListBox.Clear;
       HiddenListBox.Items.Add('JEDI.LVL');
       HiddenListBox.Items.Add('TEXT.MSG');
       for i := 0 to HiddenListBox.Items.Count - 1 do HiddenListBox.Selected[i] := TRUE;
       GOB_ExtractFiles(WDFUSEdir+ '\' + EDProjectName.Text,
                        DARKgob, HiddenListBox, NIL);
       CopyFile(WDFUSEdir + '\WDFDATA\GOB_AUTH.TXT', WDFUSEdir+ '\' + EDProjectName.Text + '.TXT');
       pjf := TIniFile.Create(PROJECTFile);
       try
        pjf.WriteString('WDFUSE Project', 'LEVELNAME', 'SECBASE');
       finally
        pjf.Free;
       end;
       openok := TRUE;
      end; }
  2 : begin
       with OpenUserGOB do
        if Execute then
          if IsGOB(FileName) then
           begin
            HiddenListBox.Clear;
            GOB_GetDirList(FileName, HiddenListBox);
            for i := 0 to HiddenListBox.Items.Count - 1 do HiddenListBox.Selected[i] := TRUE;
             GOB_ExtractFiles(WDFUSEdir+ '\' + EDProjectName.Text,
                              FileName, HiddenListBox, NIL);
            OpenUserLEV.InitialDir := WDFUSEdir+ '\' + EDProjectName.Text;
            if OpenUserLEV.Execute then
              begin
               lname := ExtractFileName(Copy(OpenUserLEV.FileName,1,Length(OpenUserLEV.FileName)-4));
               {now, search for O, INF, GOL, PAL, CMP, JEDI.LVL, TEXT.MSG
                if any of them is not there, extract it from DARK.GOB}
               HiddenListBox.Clear;
               if not FileExists(WDFUSEdir+ '\' + EDProjectName.Text + '\' + lname + '.O') then
                HiddenListBox.Items.Add(lname + '.O');
               if not FileExists(WDFUSEdir+ '\' + EDProjectName.Text + '\' + lname + '.INF') then
                HiddenListBox.Items.Add(lname + '.INF');
               if not FileExists(WDFUSEdir+ '\' + EDProjectName.Text + '\' + lname + '.GOL') then
                HiddenListBox.Items.Add(lname + '.GOL');
               if not FileExists(WDFUSEdir+ '\' + EDProjectName.Text + '\' + lname + '.PAL') then
                HiddenListBox.Items.Add(lname + '.PAL');
               if not FileExists(WDFUSEdir+ '\' + EDProjectName.Text + '\' + lname + '.CMP') then
                begin
                 if lname <> 'NARSHADA' then
                  HiddenListBox.Items.Add(lname + '.CMP')
                 else
                  HiddenListBox.Items.Add('SECBASE.CMP');
                end;
               if not FileExists(WDFUSEdir+ '\' + EDProjectName.Text + '\JEDI.LVL') then
                HiddenListBox.Items.Add('JEDI.LVL');
               if not FileExists(WDFUSEdir+ '\' + EDProjectName.Text + '\TEXT.MSG') then
                HiddenListBox.Items.Add('TEXT.MSG');
               for i := 0 to HiddenListBox.Items.Count - 1 do HiddenListBox.Selected[i] := TRUE;
                GOB_ExtractFiles(WDFUSEdir+ '\' + EDProjectName.Text,
                                 DARKgob, HiddenListBox, NIL);

               if lname = 'NARSHADA' then
                if FileExists(WDFUSEdir+ '\' + EDProjectName.Text + '\SECBASE.CMP') then
                   RenameFile(WDFUSEdir+ '\' + EDProjectName.Text + '\SECBASE.CMP',
                              WDFUSEdir+ '\' + EDProjectName.Text + '\NARSHADA.CMP');

               { ask if the text file exists else create it }
               if OpenUserTXT.Execute then
                CopyFile(OpenUserTXT.FileName, WDFUSEdir + '\' + EDProjectName.Text + '.TXT')
               else
                CopyFile(WDFUSEdir + '\WDFDATA\GOB_AUTH.TXT',WDFUSEdir + '\' + EDProjectName.Text + '.TXT');
               pjf := TIniFile.Create(PROJECTFile);
               try
                pjf.WriteString('WDFUSE Project', 'LEVELNAME', lname);
               finally
                pjf.Free;
               end;
               openok := TRUE;
             end;
           end
          else
           Application.MessageBox('Invalid GOB file',
                                  'WDFUSE Mapper - NEW Project',
                                   mb_Ok or mb_IconExclamation)
         else ;
      end;
  3 : begin
       with OpenWAD do
        if Execute then
          if IsWAD(FileName) then
           begin
            CopyFile(WDFUSEdir + '\WDFDATA\SECBASE.LEV',  WDFUSEdir+ '\' + EDProjectName.Text + '\SECBASE.LEV');
            CopyFile(WDFUSEdir + '\WDFDATA\SECBASE.O',    WDFUSEdir+ '\' + EDProjectName.Text + '\SECBASE.O');
            CopyFile(WDFUSEdir + '\WDFDATA\SECBASE.INF',  WDFUSEdir+ '\' + EDProjectName.Text + '\SECBASE.INF');
            CopyFile(WDFUSEdir + '\WDFDATA\SECBASE.GOL',  WDFUSEdir+ '\' + EDProjectName.Text + '\SECBASE.GOL');
            CopyFile(WDFUSEdir + '\WDFDATA\DOOM.PAL',     WDFUSEdir+ '\' + EDProjectName.Text + '\SECBASE.PAL');
            CopyFile(WDFUSEdir + '\WDFDATA\DOOM.CMP',     WDFUSEdir+ '\' + EDProjectName.Text + '\SECBASE.CMP');
            HiddenListBox.Clear;
            HiddenListBox.Items.Add('JEDI.LVL');
            HiddenListBox.Items.Add('TEXT.MSG');
            for i := 0 to HiddenListBox.Items.Count - 1 do HiddenListBox.Selected[i] := TRUE;
            GOB_ExtractFiles(WDFUSEdir+ '\' + EDProjectName.Text,
                             DARKgob, HiddenListBox, NIL);
            CopyFile(WDFUSEdir + '\WDFDATA\GOB_AUTH.TXT', WDFUSEdir+ '\' + EDProjectName.Text + '.TXT');
            pjf := TIniFile.Create(PROJECTFile);
            try
             pjf.WriteString('WDFUSE Project', 'LEVELPATH', WDFUSEdir+ '\' + EDProjectName.Text);
             LEVELPath := WDFUSEdir+ '\' + EDProjectName.Text;
             pjf.WriteString('WDFUSE Project', 'LEVELNAME', 'SECBASE');
             LEVELName := 'SECBASE';
             pjf.WriteInteger('WDFUSE Project', 'BACKUPNUM', -1);
             pjf.WriteBool('WDFUSE Project', 'DOOM', TRUE);
             LEVELBNum := -1;
            finally
             pjf.Free;
            end;
            openok := TRUE;
           end
          else
           Application.MessageBox('Invalid WAD file',
                                  'WDFUSE Mapper - NEW Project',
                                   mb_Ok or mb_IconExclamation);
      end;
 END;

 { Copy the project file in the Backups subdirectory.
   This is not mandatory, put it serves to set at least one file in the
   subdirectory, because pkzip will not save the directory if empty !! }
 CopyFile(PROJECTFile,
          WDFUSEdir + '\' + EDProjectName.Text + '\BACKUPS\' + EDProjectName.Text + '.wdp');

 {proceed by loading the new level}

 if openok and (RGProjectSource.ItemIndex <> 3) then DO_LoadLevel;
 if openok and (RGProjectSource.ItemIndex = 3) then DO_LoadWAD(OpenWAD.FileName);

end;

procedure TNewProjectDialog.FormCreate(Sender: TObject);
begin
 CBLevelChoice.ItemIndex := 0;
 CBNewLevelChoice.ItemIndex := 0;
end;

procedure TNewProjectDialog.BNHelpClick(Sender: TObject);
begin
  Application.HelpJump('wdfuse_help_projects');
end;

procedure TNewProjectDialog.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if Shift = [] then
    Case Key of
      VK_F1     : BNHelpClick(NIL);
    end;
end;

end.
