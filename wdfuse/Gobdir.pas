unit Gobdir;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Buttons, ExtCtrls, StdCtrls, M_Global, G_Util, Clipbrd;

type
  TGOBDIRWindow = class(TForm)
    SpeedBar: TPanel;
    SpeedButtonExit: TSpeedButton;
    SP_Main: TPanel;
    SP_Time: TPanel;
    SP_Text: TPanel;
    SP_Time_: TTimer;
    GOBDIRContents: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    SpeedButton1: TSpeedButton;
    Panel5: TPanel;
    PanelGOBName: TPanel;
    PanelSize: TPanel;
    PanelDate: TPanel;
    procedure SpeedButtonExitClick(Sender: TObject);
    procedure SP_Time_Timer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure DisplayHint(Sender: TObject);
  end;

var
  GOBDIRWindow: TGOBDIRWindow;

implementation

{$R *.DFM}

procedure TGOBDIRWindow.SpeedButtonExitClick(Sender: TObject);
begin
  GOBDIRWindow.Close;
end;

procedure TGOBDIRWindow.SP_Time_Timer(Sender: TObject);
begin
  SP_Time.Caption := FormatDateTime('hh:mm', Time);
end;

procedure TGOBDIRWindow.FormShow(Sender: TObject);
begin
  SP_Time.Caption := FormatDateTime('hh:mm', Time);
end;

procedure TGOBDIRWindow.DisplayHint(Sender: TObject);
begin
  SP_Text.Caption := Application.Hint;
end;

procedure TGOBDIRWindow.FormActivate(Sender: TObject);
var f : Integer;
begin
  Application.OnHint := DisplayHint;
  f := FileOpen(CurrentGOB, fmOpenRead);
  PanelGOBName.Caption := CurrentGOB;
  PanelSize.Caption := 'Size:' + IntToStr(FileSizing(f)) + ' bytes';
  PanelDate.Caption := 'Timestamp: '
                       + DateToStr(FileDateToDateTime(FileGetDate(f)))
                       + '  '
                       + TimeToStr(FileDateToDateTime(FileGetDate(f)));
  FileClose(f);
  CASE GOB_GetDetailedDirList(CurrentGOB , GOBDIRWindow.GOBDirContents) OF
   -1 : Application.MessageBox('File does not exist', 'GOB File Manager Error', mb_Ok or mb_IconExclamation);
   -2 : Application.MessageBox('File is not a GOB file', 'GOB File Manager Error', mb_Ok or mb_IconExclamation);
  END;
  
end;

procedure TGOBDIRWindow.SpeedButton1Click(Sender: TObject);
begin
  GOBDIRContents.SelectAll;
  GOBDIRContents.CopyToClipboard;
  GOBDIRContents.SelLength := 0;
end;

end.
