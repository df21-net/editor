unit M_about;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, GlobalVars;

type
  TAboutBox = class(TForm)
    OKButton: TBitBtn;
    Memo1: TMemo;
    Panel4: TPanel;
    Panel1: TPanel;
    ProductName: TLabel;
    Version: TLabel;
    Image1: TImage;
    Panel2: TPanel;
    James: TImage;
    Panel3: TPanel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;

implementation

{$R *.DFM}

procedure TAboutBox.FormCreate(Sender: TObject);
begin
  Version.Caption := VersionString;
end;

end.

