unit M_smledt;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, FileCtrl, SysUtils, Dialogs;

type
  TSmallTextEditor = class(TForm)
    Memo: TMemo;
    SpeedBar: TPanel;
    SpeedButtonCOmmit: TSpeedButton;
    SpeedButtonRollback: TSpeedButton;
    SpeedButtonFont: TSpeedButton;
    FontDialog1: TFontDialog;
    SBHelp: TSpeedButton;
    procedure FormActivate(Sender: TObject);
    procedure SpeedButtonCOmmitClick(Sender: TObject);
    procedure SpeedButtonRollbackClick(Sender: TObject);
    procedure SpeedButtonFontClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SBHelpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    TheFile : TFileName;
  end;

var
  SmallTextEditor: TSmallTextEditor;

implementation

{$R *.DFM}

uses MAPPER;

procedure TSmallTextEditor.FormActivate(Sender: TObject);
begin
  SmallTextEditor.Caption := 'WDFUSE Small Textfile Editor - ' + TheFile;
  Memo.Lines.LoadFromFile(TheFile);
end;

procedure TSmallTextEditor.SpeedButtonCOmmitClick(Sender: TObject);
begin
 Memo.Lines.SaveToFile(TheFile);
 SmallTextEditor.Close;
end;

procedure TSmallTextEditor.SpeedButtonRollbackClick(Sender: TObject);
begin
  SmallTextEditor.Close;
end;

procedure TSmallTextEditor.SpeedButtonFontClick(Sender: TObject);
begin
 with FontDialog1 do
  begin
   Font := Memo.Font;
   if Execute then
    begin
     Memo.Font   := Font;
    end;
  end;
end;

procedure TSmallTextEditor.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Shift = [] then
    Case Key of
      VK_F1     : MapWindow.HelpTutorialClick(NIL);
      VK_F2     : SpeedButtonCommitClick(NIL);
      VK_ESCAPE : SpeedButtonRollbackClick(NIL);
    end;
end;

procedure TSmallTextEditor.SBHelpClick(Sender: TObject);
begin
 MapWindow.HelpTutorialClick(NIL);
end;

end.
