unit M_flaged;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, IniFiles, M_Global, ExtCtrls;

type
  TFlagEditor = class(TForm)
    LBFlags: TListBox;
    Panel1: TPanel;
    Title: TPanel;
    SBCommit: TSpeedButton;
    SBRollback: TSpeedButton;
    SBHelp: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SBCommitClick(Sender: TObject);
    procedure SBRollbackClick(Sender: TObject);
    procedure SBHelpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FlagEditor: TFlagEditor;

implementation

{$R *.DFM}

procedure TFlagEditor.FormCreate(Sender: TObject);
begin
  FlagEditor.Left   := Ini.ReadInteger('WINDOWS', 'Flag Editor    X', 72);
  FlagEditor.Top    := Ini.ReadInteger('WINDOWS', 'Flag Editor    Y', 72);
  {
  FlagEditor.Width  := Ini.ReadInteger('WINDOWS', 'Flag Editor    W', 629);
  FlagEditor.Height := Ini.ReadInteger('WINDOWS', 'Flag Editor    H', 440);
  }
end;

procedure TFlagEditor.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Ini.WriteInteger('WINDOWS', 'Flag Editor    X', FlagEditor.Left);
  Ini.WriteInteger('WINDOWS', 'Flag Editor    Y', FlagEditor.Top);
  {
  Ini.WriteInteger('WINDOWS', 'Flag Editor    W', FlagEditor.Width);
  Ini.WriteInteger('WINDOWS', 'Flag Editor    H', FlagEditor.Height);
  }
end;

procedure TFlagEditor.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
if Shift = [] then
    Case Key of
      VK_F1     : Application.HelpJump('wdfuse_help_secondary');
      VK_F2,
      VK_RETURN : FlagEditor.ModalResult := mrOk;
      VK_ESCAPE : FlagEditor.ModalResult := mrCancel;
    end;
end;

procedure TFlagEditor.SBCommitClick(Sender: TObject);
begin
 FlagEditor.ModalResult := mrOk;
end;

procedure TFlagEditor.SBRollbackClick(Sender: TObject);
begin
 FlagEditor.ModalResult := mrCancel;
end;

procedure TFlagEditor.SBHelpClick(Sender: TObject);
begin
 Application.HelpJump('wdfuse_help_secondary');
end;

end.
