unit T_info;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, M_Global, ExtCtrls;

type
  TTktInfoWindow = class(TForm)
    MemoInfo: TMemo;
    Panel1: TPanel;
    BNOk: TBitBtn;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TktInfoWindow: TTktInfoWindow;

implementation

{$R *.DFM}

procedure TTktInfoWindow.FormActivate(Sender: TObject);
begin
 TktInfoWindow.Caption := 'TOOLKIT Information - ' + TheRES;
end;

end.
