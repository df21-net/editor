unit M_diff;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls;

type
  TDIFFEditor = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Panel1: TPanel;
    SBCommit: TSpeedButton;
    SBRollback: TSpeedButton;
    RGDiff: TListBox;
    SBHelp: TSpeedButton;
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
  DIFFEditor: TDIFFEditor;

implementation

{$R *.DFM}

uses MAPPER;

procedure TDIFFEditor.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
if Shift = [] then
    Case Key of
      VK_F1     : MapWindow.HelpTutorialClick(NIL);
      VK_F2,
      VK_RETURN : DiffEditor.ModalResult := mrOk;
      VK_ESCAPE : DiffEditor.ModalResult := mrCancel;
    end;
end;

procedure TDIFFEditor.SBCommitClick(Sender: TObject);
begin
 DiffEditor.ModalResult := mrOk;
end;

procedure TDIFFEditor.SBRollbackClick(Sender: TObject);
begin
 DiffEditor.ModalResult := mrCancel;
end;

procedure TDIFFEditor.SBHelpClick(Sender: TObject);
begin
 MapWindow.HelpTutorialClick(NIL);
end;

end.
