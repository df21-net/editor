unit M_about;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, M_Global, ShellApi, Vcl.Imaging.pngimage, DateUtils,
  SysUtils;

type
  TAboutBox = class(TForm)
    Panel1: TPanel;
    OKButton: TBitBtn;
    ImageMap: TImage;
    Version: TLabel;
    Panel2: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel8: TPanel;
    Panel7: TPanel;
    Image2: TImage;
    Build: TLabel;
    Image1: TImage;
    Panel3: TPanel;
    Image3: TImage;
    procedure FormCreate(Sender: TObject);
    procedure LogoClick(Sender: TObject);
    procedure Image3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;

implementation
   uses Mapper;

{$R *.DFM}

procedure TAboutBox.FormCreate(Sender: TObject);
var
builddate : TDateTime;
begin
  Version.Caption := WDFUSE_VERSION;
  builddate := UnixToDateTime(StrToInt(BuildVersion));
  Build.Caption := 'Build ' + FormatDateTime('YYYY-MMM-dd HH:MM:SS', builddate);;
end;




procedure TAboutBox.Image3Click(Sender: TObject);
begin
  MapWindow.WDFUSESupportDiscordClick(NIL);
end;

procedure TAboutBox.LogoClick(Sender: TObject);
var url : String;
begin
  url := 'https://df-21.net';
  ShellExecute(HInstance, 'open', PChar(url), nil, nil, SW_NORMAL);
end;

end.

