unit M_obclas;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, M_Global, ExtCtrls;

type
  TOBClassWindow = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    LBClass: TListBox;
    Panel1: TPanel;
    SBHelp: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SBHelpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OBClassWindow: TOBClassWindow;

implementation

{$R *.DFM}

uses MAPPER;

procedure TOBClassWindow.FormCreate(Sender: TObject);
begin
  OBClassWindow.Left   := Ini.ReadInteger('WINDOWS', 'OBClass Select X', 0);
  OBClassWindow.Top    := Ini.ReadInteger('WINDOWS', 'OBClass Select Y', 72);
end;

procedure TOBClassWindow.FormDeactivate(Sender: TObject);
begin
  Ini.WriteInteger('WINDOWS', 'OBClass Select X', OBClassWindow.Left);
  Ini.WriteInteger('WINDOWS', 'OBClass Select Y', OBClassWindow.Top);
end;

procedure TOBClassWindow.OKBtnClick(Sender: TObject);
begin
 OBCLASS_VALUE := LBClass.Items[LBClass.ItemIndex];
 OBClassWindow.Close;
end;

procedure TOBClassWindow.CancelBtnClick(Sender: TObject);
begin
 OBClassWindow.Close;
end;

procedure TOBClassWindow.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
if Shift = [] then
    Case Key of
      VK_F1     : MapWindow.HelpTutorialClick(NIL);
      VK_F2     : OKBtnClick(NIL);
      VK_ESCAPE : CancelBtnClick(NIL);
    end;
end;

procedure TOBClassWindow.SBHelpClick(Sender: TObject);
begin
 MapWindow.HelpTutorialClick(NIL);
end;

end.
