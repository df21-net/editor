unit M_leved;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, Buttons, M_global, TabNotBk, Vcl.ComCtrls{, ComCtrls};

type
  TLevelEditorWindow = class(TForm)
    BNOk: TBitBtn;
    BNCancel: TBitBtn;
    TabbedNotebook1: TTabbedNotebook;
    Panel1: TPanel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label8: TLabel;
    ED_LEV_VERSION: TEdit;
    ED_LEV_LEVELNAME: TEdit;
    ED_LEV_PALETTE: TEdit;
    ED_LEV_MUSIC: TEdit;
    ED_LEV_PARALLAX1: TEdit;
    ED_LEV_PARALLAX2: TEdit;
    Panel2: TPanel;
    Label7: TLabel;
    Label9: TLabel;
    ED_O_VERSION: TEdit;
    ED_O_LEVELNAME: TEdit;
    Panel3: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    ED_INF_VERSION: TEdit;
    ED_INF_LEVELNAME: TEdit;
    procedure BNOkClick(Sender: TObject);
    procedure BNHelpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  LevelEditorWindow: TLevelEditorWindow;

implementation

{$R *.DFM}

procedure TLevelEditorWindow.BNOkClick(Sender: TObject);
var value  : Real;
    code   : Integer;
begin
 LEV_VERSION   := ED_LEV_VERSION.Text;
 LEV_LEVELNAME := ED_LEV_LEVELNAME.Text;
 LEV_PALETTE   := ED_LEV_PALETTE.Text;
 LEV_MUSIC     := ED_LEV_MUSIC.Text;
 Val(ED_LEV_PARALLAX1.Text, value, code);
 if code = 0 then LEV_PARALLAX1 := value;
 Val(ED_LEV_PARALLAX2.Text, value, code);
 if code = 0 then LEV_PARALLAX2 := value;
 O_VERSION     := ED_O_VERSION.Text;
 O_LEVELNAME   := ED_O_LEVELNAME.Text;
 INF_VERSION   := ED_INF_VERSION.Text;
 INF_LEVELNAME := ED_INF_LEVELNAME.Text;

 MODIFIED      := TRUE;
end;

procedure TLevelEditorWindow.BNHelpClick(Sender: TObject);
begin
 ShowMessage('Not implemented yet !');
end;

end.
