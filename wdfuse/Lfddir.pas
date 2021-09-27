unit Lfddir;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Buttons, ExtCtrls, StdCtrls, M_Global, L_Util, Clipbrd;

type
  TLFDDIRWindow = class(TForm)
    SpeedBar: TPanel;
    SpeedButtonExit: TSpeedButton;
    SP_Main: TPanel;
    SP_Time: TPanel;
    SP_Text: TPanel;
    SP_Time_: TTimer;
    LFDDIRContents: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    SpeedButton1: TSpeedButton;
    Panel5: TPanel;
    PanelLFDName: TPanel;
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
  LFDDIRWindow: TLFDDIRWindow;

implementation

{$R *.DFM}

procedure TLFDDIRWindow.SpeedButtonExitClick(Sender: TObject);
begin
  LFDDIRWindow.Close;
end;

procedure TLFDDIRWindow.SP_Time_Timer(Sender: TObject);
begin
  SP_Time.Caption := FormatDateTime('hh:mm', Time);
end;

procedure TLFDDIRWindow.FormShow(Sender: TObject);
begin
  SP_Time.Caption := FormatDateTime('hh:mm', Time);
end;


procedure TLFDDIRWindow.DisplayHint(Sender: TObject);
begin
  SP_Text.Caption := Application.Hint;
end;

procedure TLFDDIRWindow.FormActivate(Sender: TObject);
var f : Integer;
begin
  Application.OnHint := DisplayHint;
  f := FileOpen(CurrentLFDir + '\' + CurrentLFD, fmOpenRead);
  PanelLFDName.Caption := CurrentLFDir + '\' + CurrentLFD;
  PanelSize.Caption := 'Size:' + IntToStr(FileSizing(f)) + ' bytes';
  PanelDate.Caption := 'Timestamp: '
                       + DateToStr(FileDateToDateTime(FileGetDate(f)))
                       + '  '
                       + TimeToStr(FileDateToDateTime(FileGetDate(f)));
  FileClose(f);
  CASE LFD_GetDetailedDirList(CurrentLFDir + '\' + CurrentLFD , LFDDIRWindow.LFDDirContents) OF
   -1 : Application.MessageBox('File does not exist', 'LFD File Manager Error', mb_Ok or mb_IconExclamation);
   -2 : Application.MessageBox('File is not a LFD file', 'LFD File Manager Error', mb_Ok or mb_IconExclamation);
  END;
  
end;

procedure TLFDDIRWindow.SpeedButton1Click(Sender: TObject);
begin
  LFDDIRContents.SelectAll;
  LFDDIRContents.CopyToClipboard;
  LFDDIRContents.SelLength := 0;
end;

end.
