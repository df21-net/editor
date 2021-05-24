unit Goledit;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, StdCtrls, Tabs, Buttons, Spin,
  M_Global, M_Test, I_Util,
{$IFDEF WDF32}
  ComCtrls ,
{$ENDIF}
  TabNotBk;

type
  TGOLWindow = class(TForm)
    GOLStatus: TPanel;
    GOLToolbar: TPanel;
    MainNotebook: TTabbedNotebook;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    MemoGOL: TMemo;
    SBCommit: TSpeedButton;
    SBRollback: TSpeedButton;
    SBCheck: TSpeedButton;
    SBFont: TSpeedButton;
    Panel9: TPanel;
    SBHelp: TSpeedButton;
    Panel11: TPanel;
    SBCommitWiz: TSpeedButton;
    SBRollbackWiz: TSpeedButton;
    SBHelpWiz: TSpeedButton;
    procedure SBRollbackClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  GOLWindow: TGOLWindow;

procedure HiliteGOLMemoLine(TheLine : Integer);

implementation
uses Mapper;

{$R *.DFM}

procedure HiliteGOLMemoLine(TheLine : Integer);
var Line : Integer;
begin
 {check input, these SendMesage are quite touchy}
 if TheLine < 0 then Line := 0;
 if TheLine > GOLWindow.MemoGOL.Lines.Count-1 then Line := GOLWindow.MemoGOL.Lines.Count-1;

 GOLWindow.MemoGOL.SelStart  := SendMessage(GOLWindow.MemoGOL.Handle, EM_LINEINDEX, Line, 0);
 GOLWindow.MemoGOL.SelLength := Length(GOLWindow.MemoGOL.Lines[Line]);
end;

procedure TGOLWindow.SBRollbackClick(Sender: TObject);
begin
 Close;
end;

end.
