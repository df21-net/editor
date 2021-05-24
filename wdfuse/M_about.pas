unit M_about;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, M_Global;

type
  TAboutBox = class(TForm)
    Panel1: TPanel;
    OKButton: TBitBtn;
    ImageMap: TImage;
    ProductName: TLabel;
    Version: TLabel;
    Panel2: TPanel;
    Panel3: TPanel;
    Image1: TImage;
    Memo1: TMemo;
    Panel4: TPanel;
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
  Version.Caption := WDFUSE_VERSION;
end;

end.

