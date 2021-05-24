unit m_WadMap;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls;

type
  TMapSelectWindow = class(TForm)
    WadDirList: TListBox;
    Label1: TLabel;
    OkBtn: TBitBtn;
    CancelBtn: TBitBtn;
    HelpBtn: TBitBtn;
    CBExecWad2Gob: TCheckBox;
    CBShowLog: TCheckBox;
    RGIwad: TRadioGroup;
    ED_Doom: TEdit;
    ED_Doom2: TEdit;
    ED_W2GSwitches: TEdit;
    Label2: TLabel;
    BNDoom: TBitBtn;
    BNDoom2: TBitBtn;
    OpenDoom: TOpenDialog;
    OpenDoom2: TOpenDialog;
    procedure WadDirListClick(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure BNDoomClick(Sender: TObject);
    procedure BNDoom2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MapSelectWindow: TMapSelectWindow;

implementation

{$R *.DFM}

procedure TMapSelectWindow.WadDirListClick(Sender: TObject);
begin
 OkBtn.Enabled := TRUE;
end;

procedure TMapSelectWindow.HelpBtnClick(Sender: TObject);
begin
 Application.HelpJump('wdfuse_help_wadconvert');
end;

procedure TMapSelectWindow.BNDoomClick(Sender: TObject);
begin
 with OpenDoom do
  if Execute then
   ED_Doom.Text := FileName;
end;

procedure TMapSelectWindow.BNDoom2Click(Sender: TObject);
begin
 with OpenDoom2 do
  if Execute then
   ED_Doom2.Text := FileName;
end;

end.
